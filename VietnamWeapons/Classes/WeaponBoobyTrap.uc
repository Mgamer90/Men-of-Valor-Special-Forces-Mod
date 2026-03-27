//===============================================================================
//  [ BoobyTrap ]
// This is a booby trap that players can set
//===============================================================================

class WeaponBoobyTrap extends VietnamWeapon;

var bool				bDoDownWeapon;
var bool				bPlacedFirstStake;
var Actor				FirstStake;
var BoobyTrapGrenade	GrenadeActor;

replication
{
	reliable if( Role==ROLE_Authority )
		ClientDropStake;
}

/* ClientDropStake()
Tell client he dropped a boobytrap
*/
simulated function ClientDropStake(optional name NewState, optional name NewLabel)
{
	if(ReloadCount > 0)
		ReloadCount--;
	bPlacedFirstStake = false;
	FirstStake = None;

	GotoState(NewState,NewLabel);
}

// Just reroute to appropriate state on both server and client
state NormalFire
{
	ignores ForceReload, ClientMeleeAttack, LocalStartFire;

	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
	{
		if(bPlacedFirstStake)
			{
				//log("SpawnSecondStake, decrementing ammo at " $ Level.TimeSeconds);
				SpawnSecondStake();
				// Occasionally the client will receive a packet from the server with 0 ammo
				// right before decrementing it locally, causing ammo to be displayed as 255
				if(ReloadCount > 0)
					ReloadCount--;
				bPlacedFirstStake = false;

				FirstStake = None;

				if(CanReload())
					GotoState('Reloading');
		else
					GotoState('Idle');
}
			else
			{
				//log("SpawnFirstStake at " $ Level.TimeSeconds);
				SpawnFirstStake();

				bPlacedFirstStake = true;

				GotoState('Idle');
			}
		}
	}
}

// This is the fire function replicated from client to server
// Or called on a listen-server or standalone game
function ServerFire()
{
	local float fStartFrameSeconds;
	
//##USDEBUG
//	CommentOwner("VietnamWeapon: ServerFire: entry");
//##END

	//Log( "Brendan - VietnamWeapon::ServerFire " $ self);

	// Force spawn invulnerability to end if player fired their gun
	VietnamPawn(Instigator).EndSpawnInvulnerability();

	// APT: 6-8-04 use the base function to determine whether we should
	// fake fire
	m_bBotFakeFiring = ShouldFakeFire();
	/*
	// are we actually firing the weapon?
	// 0.5 ms is what were shooting for
	if(bBotControlled)
	{
		// efd - increase tolerance to 500 ms for bot firing time before fake firing kicks in
		m_bBotFakeFiring = (frand() >= (1 - (Level.Game.m_fWeaponFireFrameTime * 1000.f * (1.f / 0.5f))));
		//m_bBotFakeFiring = (frand() >= (1 - (Level.Game.m_fWeaponFireFrameTime * 1000.f * (1.f / 0.25f))));
		//log("Z: Fake Firing:"$m_bBotFakeFiring$" WeaponFireFrameTime:"$Level.Game.m_fWeaponFireFrameTime * 1000.0f);
	}
	*/

	fStartFrameSeconds = VietnamPawn(Instigator).Level.TimeSeconds;

	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	// Check that the weapon has enough ammo to fire
	if ( ReloadCount > 0 || default.ReloadCount == 0)
	{
		GotoState('NormalFire');

//		if(default.ReloadCount > 0)
//			ReloadCount--;

		//log("ServerFire at " $ Level.TimeSeconds);

		CheckIncrementShotsFiredStat();

		CheckForLowAmmo();

		// M7 has no ammo for instance, so don't do a TraceFire
		if(AmmoType?)
		{
		if ( AmmoType.bInstantHit )
		{
			if(m_bBotFakeFiring || m_bScriptFakeFiring)
			{
					//log( "Brendan - VietnamWeapon::ServerFire, about to call PlayFiring " $ self);
				PlayFiring(); // Fire, but not actually fire
			}
			else
			{
					//log( "Brendan - VietnamWeapon::ServerFire, about to call TraceFire " $ self);
				TraceFire(TraceAccuracy,0,0);	// Fire the gun
			}
		}
			else	// Make sure we have some kind of
		{
			ProjectileFire();
		}
		}
		//log( "Brendan - VietnamWeapon::ServerFire, about to call localfire " $ self);
		LocalFire();
	}

	Level.Game.m_fWeaponFireFrameTime += VietnamPawn(Instigator).Level.TimeSeconds - fStartFrameSeconds;
	m_bBotFakeFiring = false;
}

function TraceFire(float pAccuracy, float YOffset, float ZOffset );

function ProjectileFire();

// overridden:  special take out animations are
// used for the booby trap
//
// inputs:
// -- none --
//
// outputs:
// name of the animation to play
simulated function Name ResolveTakeoutAnimation( )
{
	if ( bPlacedFirstStake )
	{
		return 'second_takeout';
	}
	// else....

	return 'first_takeout';
}

// Plays the animation and the accompanying sound
simulated function PlayReloading()
{
	local PlayerController PController;
	local Float            frames, rate;

	PController = PlayerController(Instigator.Controller);
	if(PController?)
		PController.ClientPlaySound(WeaponSounds[EWeaponSound.EWS_Reload]);

	PlayAnim( 'first_takeout', GetReloadAnimationRate( ), 0.05,
		FIRING_ANIMATION_CHANNEL );
	AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
		, , , , WEAPON_RELOAD_TWEEN_TIME,
		WEAPON_RELOAD_TWEEN_TIME, );

	// third person anims
	GetAnimSequenceParams( 'first_takeout', frames, rate );
	Instigator.PlayReload( frames / rate, GetReloadAnimationRate( ) );
}

// overridden:  has special putaway animations
//
// inputs:
// -- none --
//
// outputs:
// name of the animation to play
simulated function Name GetPutAwayAnimationName( )
{
	if ( bPlacedFirstStake )
	{
		return 'second_putaway';
	}
	// else....
	
	return 'first_putaway';
}

function SpawnFirstStake()
{
	local vector Forward, Right, Up;
	local vector SpawnPoint;

	GetAxes(Instigator.Rotation, Forward, Right, Up);

	// Spawn a little down and forward from the player
	// Unless prone, then spawn forward and above the player
	if(Instigator.bIsProne)
		SpawnPoint = Instigator.Location + Forward * 40 + Up * 30;
	else
	SpawnPoint = Instigator.Location + Forward * 30 - Up * 30;


	FirstStake = Spawn(class'VietnamWeapons.BoobyTrapStick',self.Owner,,SpawnPoint, rot(0,0,0));
	FirstStake.SetPhysics(PHYS_Falling);
}

function SpawnSecondStake()
{
	local vector VectorToFirstStake;
	local rotator RotationToFirstStake;
	local rotator StakeRotation;

	local vector Forward, Right, Up;
	local vector SpawnPoint;

	GetAxes(Instigator.Rotation, Forward, Right, Up);

	// Spawn a little down and forward from the player
	// Unless prone, then spawn forward and above the player
	if(Instigator.bIsProne)
		SpawnPoint = Instigator.Location + Forward * 40 + Up * 30;
	else
		SpawnPoint = Instigator.Location + Forward * 30 - Up * 30;

	VectorToFirstStake = FirstStake.Location - Location;

	// Figure out the rotation this stake should have
	RotationToFirstStake = rotator(VectorToFirstStake);
	StakeRotation.Yaw = RotationToFirstStake.Yaw;

	GrenadeActor = Spawn(class'VietnamWeapons.BoobyTrapGrenade',self.Owner,,SpawnPoint, StakeRotation);
	GrenadeActor.StickActor = FirstStake;
	GrenadeActor.Instigator = self.Instigator;
	GrenadeActor.bResettable = false;	// Make sure it gets cleaned up after Reset
	GrenadeActor.InstigatorController = Instigator.Controller;

	GrenadeActor.SetPhysics(PHYS_Falling);
}

// Called during tick to process when we're ready to fire
simulated function DoReadyToFire()
{
	// Reset ReadyToFire variable
	if(ReadyToFire==false)
		ReadyToFire=true;
}

simulated function PlayFiring()
{
	local VietnamPlayerController VController;

//##USDEBUG
//	CommentOwner("VietnamWeapon: PlayFiring: entry");
//##END

	// Only play the non-positional sound if the controller is on this machine
	if(Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
	{
		VController = VietnamPlayerController(Instigator.Controller);

		if(ForceFeedbackEffect?)
			VController.PlayForceFeedbackEffect(ForceFeedbackEffect, 2);

		if( VController.IsInstancePlaying(FPFireVoices[FPFireVoiceIndex]))
		{
			VController.ClientStopRegisteredSound(FPFireVoices[FPFireVoiceIndex]);
		}
		VController.ClientPlayRegisteredSound(WeaponSoundNames[EWeaponSound.EWS_FPFire].ResourceName,FPFireVoices[FPFireVoiceIndex]);

		FPFireVoiceIndex++;
		if(FPFireVoiceIndex == ArrayCount(FPFireVoices))
			FPFireVoiceIndex = 0;

		TriggerShellEjector();
	}

	// Always play the third person sound (which will replicate to clients), if this is
	// a locally controlled pawn the sound won't be heard

	WeaponPlayRemoteFireSound();

	TriggerMuzzleFlashAttachment();

	PlayFiringAnimation(AutoFireSpeed);
}

// overloaded:  has two unique idle states
//
// inputs:
// -- none --
//
// outputs:
// animation Name
Simulated Function Name GetIdleAnimationName( )
{
	if ( bPlacedFirstStake )
	{
		return 'second_idle';
	}
	// else....

	return 'first_idle';
}

// Should be implemented by individual weapons which use bDisplayAmmoType==false
simulated function string GetCurrentWeaponModeName()
{
	return "";
}

state Active
{
	simulated function EndState()
	{
		Super.EndState();
		if ( HasAmmo( ) )
		{
			DoReload();		// This prevents us from bringing up the 
							// boobytrap in active and *THEN* bringing it up again
							// to "reload"
		}
	}
}

//
// Added play of the 'Walk' anim while walking
//
simulated state Idle
{
	// Overridden to ditch this weapon if it's out of ammo
	simulated function BeginState( )
	{
		// do the parent stuff first
		Super.BeginState( );
		if(!HasAmmo())
		{
			// Destroy weapon if out of ammo
			if(ROLE == Role_Authority)
				Destroy();
		}
	}

Begin:
	bPointing=False;
	
	// We only reload when the user calls forcereload or fires while needing to reload	
	if ( Instigator.PressingAltFire() ) AltFire(0.0);
	
	if(bChangeWeapon)
	{
		if( Instigator.PendingWeapon != self )
		{
			GotoState( 'DownWeapon' );
		}
		else
		{
			Instigator.PendingWeapon = None;
		}
	}
	else
	{
		if( HasAmmo( ) )
		{
			// blend up the idle on channel 
			// BLENDING_ANIMATION_CHANNEL
			LoopAnim( GetIdleAnimationName( ), 1.0, 0.0f,
				BLENDING_ANIMATION_CHANNEL );
			AnimBlendParams( BLENDING_ANIMATION_CHANNEL,
				0.0f );
			AnimBlendToAlpha( BLENDING_ANIMATION_CHANNEL,
				1.0f, 0.3f );
			
			// sleep till it's done
			Sleep( GetAnimationLength(
				BLENDING_ANIMATION_CHANNEL ) );
			
			// start the real anim on channel 0
			LoopAnim( GetIdleAnimationName( ),
				1.0f, 0.0f, 0 );
			
			// blend out the animation on channel
			// BLENDING_ANIMATION_CHANNEL
			AnimBlendToAlpha( BLENDING_ANIMATION_CHANNEL,
				0.0f, 0.3f );
		}
		else
		{
			PlayAnim( 'nothing', 1.0, 0.05 );
		}
	}
}

simulated event Tick( float DeltaTime )
{
	local vector DistanceToStick;

	Super.Tick(DeltaTime);

	// Let's do distance check on server only
	if(Role == ROLE_Authority && FirstStake?)
	{
		DistanceToStick = FirstStake.Location - Instigator.Location;

		if(VSize(DistanceToStick) > 625)	// 5 meters
		{
			//log("Triggering stick dropping");
			if(!IsInState('PlaceSecondStake'))
			{
				//log("SpawnSecondStake called, decrementing ammo, FirstStake =" $ FirstStake);
				SpawnSecondStake();

				// Occasionally the client will receive a packet from the server with 0 ammo
				// right before decrementing it locally, causing ammo to be displayed as 255
//				if(ReloadCount > 0)
				ReloadCount--;
				bPlacedFirstStake = false;
				FirstStake = None;

				if(CanReload())
				{
					ClientDropStake('Reloading');
					GotoState('Reloading');
				}
				else
				{
					Destroy();
				}
			}
		}
	}
}

// Does the weapon have ammo, or is there ammo on the current pawn that can be used in
// the weapon?
simulated function bool HasAmmo()
{
	if(bBotControlled)
		return true;
	else
	{
		// switch statement changed to account for "weapons" that have no ammo: cameras, microphones, etc
		if (AmmoType?)
			return AmmoType.HasAmmo() || ReloadCount > 0;
		else
			return false;
	}
}

// overloaded:  needs ammo to proceed
//
// inputs:
// CurrentChoice - the currently selected weapon
//
// outputs:
// -- none -- (code segment)
simulated function SelectNextWeapon(
	out Weapon CurrentChoice, Weapon CurrentWeapon )
{
	if ( HasAmmo( ) )
	{
		Super.SelectNextWeapon(
			CurrentChoice, CurrentWeapon );
	}
}

// overloaded:  needs ammo to proceed
//
// inputs:
// CurrentChoice - the currently selected weapon
//
// outputs:
// -- none -- (code segment)
simulated function SelectPreviousWeapon(
	out Weapon CurrentChoice, Weapon CurrentWeapon )
{
	if ( HasAmmo( ) )
	{
		Super.SelectPreviousWeapon(
			CurrentChoice, CurrentWeapon );
	}
}

// Overridden to not play the putaway animation if the weapon is out of ammo
State DownWeapon
{
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function ServerFire() {}
	function ServerAltFire() {}

	simulated function BeginState()
	{
		bChangeWeapon = false;
		bMuzzleFlash = false;

		if(AmmoType.HasAmmo())
			TweenDown();
		else
			AnimEnd(0);
	}
}

// Only on client
simulated function TriggerClientFire()
{
	//log("TriggerClientFire at " $ Level.TimeSeconds);
	
	// Only simulate ammo count locally for one-shot weapons (so they won't try to fire again)
//	if(default.ReloadCount == 1)
//		ReloadCount--;

	LocalFire();
	GotoState('NormalFire');
}

// returns the name of the firing animation to play
//
// inputs:
// -- none --
//
// outputs:
// animation name
simulated function Name GetFiringAnimationName( )
{
	if(bPlacedFirstStake)
		return 'second_fire';
	else
		return 'first_fire';
}

simulated function Destroyed()
{
	// Have player switch to another weapon
	if(Instigator? && Instigator.IsLocallyControlled() && Instigator.Weapon == self)
	{
		if(Instigator.Controller.IsInPreciseAimMode())
			VietnamPlayerController(Instigator.Controller).StopPreciseAim();

		Instigator.Weapon = None;
		VietnamPlayerController(Instigator.Controller).ForceSwitchToBestWeapon();
	}

	Super.Destroyed();
}

defaultproperties
{
     PlayerCrouchViewOffset=(X=6.600000,Y=-6.400000,Z=-15.250000)
     PlayerAimViewOffset=(X=6.600000,Y=-6.400000,Z=-15.250000)
     Magnification=1.000000
     Recoil=0.000000
     m_maximumRecoil=0.000000
     AimImprovementRate=0.000000
     PrecisionAimTransitionTime=0.200000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     WeaponGrip=EWG_Grenade
     WeaponMode=EWM_Special
     WeaponSoundNames(0)=(PackageName="effects_snd",ResourceName="BoobyTrapImpale")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     AutoFireSpeed=1.000000
     SemiAutoSpeed=1.000000
     m_fViewPitchKick=0.000000
     m_fViewDegradeYaw=0.000000
     m_fViewDegradePitch=0.000000
     m_fViewKickMaxYawDelta=0.000000
     m_fViewKickMaxPitchDelta=0.000000
     MinTurnRateScale=0.550000
     TurnRateRampPower=10.000000
     AimAssistAngle=20.000000
     MinPrecisionTurnRateScale=0.350000
     PrecisionTurnRateRampPower=10.000000
     PrecisionAimAssistAngle=10.000000
     MinScreenPercent=0.000050
     m_basicFiringAnimation="None"
     MultiplayerDamage=80.000000
     m_meleeHitSound="MeleeFistHit"
     m_melee3DHitSound="MeleeFistHit3D"
     bCanUseRedCrosshair=False
     AmmoName=Class'VietnamWeapons.AmmoBoobyTrap'
     ReloadCount=1
     bExcludeFromWeapSwap=True
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MeshName="USMC_Viewmodels.fps_BoobyTrap"
     InventoryGroup=22
     PickupType="PickupBoobyTrap"
     PlayerViewOffset=(X=6.600000,Y=-6.400000,Z=-15.250000)
     PlayerHorizSplitViewOffset=(X=6.600000,Y=-6.400000,Z=-15.250000)
     PlayerVertSplitViewOffset=(X=6.600000,Y=-6.400000,Z=-15.250000)
     ThirdPersonRelativeLocation=(X=13.000000,Y=-6.000000,Z=3.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponBoobyTrapAttachment'
     ItemName="Booby Trap"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
