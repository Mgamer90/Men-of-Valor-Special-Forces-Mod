//===============================================================================
//  [ Claymore ]
// Firing modes:
//	ECM_Claymore
//  ECM_Trigger
//	TODO: Replace RecieveUsageMessage with actual Messages
//===============================================================================

class WeaponClaymore extends VietnamWeapon
	native
	nativereplication;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum ClaymoreFireMode
{
	ECM_Claymore,
	ECM_Trigger
};

var ClaymoreFireMode	SpecialWeaponMode;

// FIXME: How many Claymore triggers will our missions require?
var Actor PlacedClaymores[10];

var bool bDestroyWeapon;		// If true, the weapon should be destroyed
var bool bCampaignGameType;		// Is the current gametype VietnamCampaign derived?
								// Controls several aspects of weapon's functionality
// will be true if this weapon has any
// active sub-claymores loose in the
// game world
var Bool m_hasActiveClaymores;

var rotator ThirdPersonRelativeRotationClacker;
var vector ThirdPersonRelativeLocationClacker;

var rotator ThirdPersonRelativeRotationClaymore;
var vector ThirdPersonRelativeLocationClaymore;

var localized string ClackerName;

replication
{
	// This needs to be replicated to the client so it knows if it has a legitimate placed
	// claymore
	reliable if ( bNetDirty && (Role==ROLE_Authority) )
		m_hasActiveClaymores;
}

// overloaded:  ensures that the proper third
// person view model has been set
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (UnReal event)
simulated function PostNetBeginPlay( )
{
	// then do the parent's tasks
	Super.PostNetBeginPlay( );

	// set the proper view model
	SetThirdPersonViewModel( SpecialWeaponMode );
}

// use this call to set the SpecialWeaponMode
// (if you don't, the claymore won't do all the
// housework it needs to when the mode changes)
//
// inputs:
// inNewMode - the new mode to set
//
// outputs:
// -- none --
simulated function SetSpecialWeaponMode(
	ClaymoreFireMode inNewMode )
{
	// change the 3rd person view model
	SetThirdPersonViewModel( inNewMode );
	
	// switch the mode variable
	SpecialWeaponMode = inNewMode;
}

// switches the viewmodel based on the
// specified input
//
// inputs:
// inMode - the new mode to match models with
//
// outputs:
// -- none --
simulated function SetThirdPersonViewModel(
	ClaymoreFireMode inMode )
{
	local WeaponClaymoreAttachment myAttachment;
	
	myAttachment = WeaponClaymoreAttachment( ThirdPersonActor );
	if ( myAttachment? )
	{
		if ( inMode == ECM_Claymore )
		{
			myAttachment.ShowClaymore( );
			myAttachment.NewRelativeLocation = ThirdPersonRelativeLocationClaymore;
			myAttachment.NewRelativeRotation = ThirdPersonRelativeRotationClaymore;
		}
		else if ( inMode == ECM_Trigger )
		{
			myAttachment.ShowClacker( );
			myAttachment.NewRelativeLocation = ThirdPersonRelativeLocationClacker;
			myAttachment.NewRelativeRotation = ThirdPersonRelativeRotationClacker;
		}
	}
}

// use this function to update the state
// of the m_hasActiveClaymores variable
// (read, don't do this by hand, call this
// function any time you change the state
// of the PlaceClaymores[] array)
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment)
function UpdateHasActiveClaymores( )
{
	local Int currentClaymore;
	
	for ( currentClaymore = 0;
		currentClaymore < ArrayCount( PlacedClaymores );
		++currentClaymore )
	{
		// stop if we find an active claymore
		// and set the boolean to true
		if ( PlacedClaymores[ currentClaymore ]? )
		{
			m_hasActiveClaymores = true;
			return;
		}
	}
	
	// at this point, there are no
	// active claymores
	m_hasActiveClaymores = false;
}

// Plays the animation and the accompanying sound
simulated function PlayReloading()
{
	local PlayerController PController;
	local Float            frames, rate;

	PlayAnim( 'Claymore_takeout', GetReloadAnimationRate( ), 0.0,
		FIRING_ANIMATION_CHANNEL);
	AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
		, , , , WEAPON_RELOAD_TWEEN_TIME,
		WEAPON_RELOAD_TWEEN_TIME, );
	PController = PlayerController(Instigator.Controller);
	if(PController?)
		PController.ClientPlaySound(WeaponSounds[EWeaponSound.EWS_Reload]);

	// play a third person animation too
	GetAnimSequenceParams( 'Claymore_takeout', frames, rate );
	Instigator.PlayReload( frames / rate, GetReloadAnimationRate( ) );
}

// overridden:  has two different and unique idle states
//
// inputs:
// -- none --
//
// outputs:
// animation Name
Simulated Function Name GetIdleAnimationName( )
{
	if ( SpecialWeaponMode == ECM_Claymore )
	{
		return 'Claymore_idle';
	}
	// else....

	return 'Trigger_idle';
}

//
// Weapon is up and ready to fire, but not firing.
//
simulated state Idle
{		
Begin:
	bPointing=False;

	// Force a switch if the claymore should be destroyed
	if(bDestroyWeapon)
	{
		// Destroy weapon if out of ammo
		if(ROLE == Role_Authority)
			Destroy();
	}

	// We need to do something if we're out of claymore ammo
	if ( ReloadCount == 0 && !CanReload( ) && HasActiveClaymore( ) &&
		SpecialWeaponMode == ECM_Claymore )
	{
		AltFire( 0.0 );
	}

	// We only reload when the user calls forcereload or fires while needing to reload
	// Also, don't change weapon on no ammo unless user wants to change weapon

	if ( NeedsToReload() && AmmoType.HasAmmo() )
		GotoState('Reloading');
	if ( Instigator.PressingFire() ) Fire(1.0);		// Don't check for reload
	if ( Instigator.PressingAltFire() ) AltFire(0.0);

	if(bChangeWeapon)
	{
		if(Instigator.PendingWeapon != self)
			GotoState('DownWeapon');
		else
			Instigator.PendingWeapon = None;
	}
	else
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
}

State DownWeapon
{
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function ServerFire() {}
	function ServerAltFire() {}

	simulated function AnimEnd(int Channel)
	{
		if ( Channel == IDLE_ANIMATION_CHANNEL )
		{
			// call the parent task first
			Super.AnimEnd( Channel );
			
			// then destroy self, if necessary
			if(bDestroyWeapon)
			{
				Destroy();
			}
		}
	}

	simulated function BeginState()
	{
		bChangeWeapon = false;
		bMuzzleFlash = false;

		TweenDown();
		
		// disable the spawning function,
		// just in case it was activated
		SetDelegateTimer( 'SpawnClaymore', 0.0f, false );
	}
}

// Called during tick to process when we're ready to fire
// NETHINT: this function is called on the owning client only
//simulated function DoReadyToFire()
//{
//	ReadyToFire = true;
//}

// overridden:  claymores use custom takeout animations
//
// inputs:
// -- none --
//
// outputs:
// name of the animation to play
simulated function Name ResolveTakeoutAnimation( )
{
	if ( SpecialWeaponMode == ECM_Trigger )
	{
		return 'trigger_takeout';
	}
	// else....

	return 'Claymore_takeout';
}

// overridden:  has special firing modes
//
// inputs:
// -- none --
//
// outputs:
// animation name
simulated function Name GetFiringAnimationName( )
{
	if( SpecialWeaponMode == ECM_Claymore )
	{
		return 'Claymore_throw';
	}
	// else....

	return 'Trigger_fire';
}

// Instead of a projectile, this detonates the claymores, or places a claymore
function ProjectileFire()
{
	local AnimInfo newAnimation;
	local int      iCounter;

	if(SpecialWeaponMode == ECM_Trigger)
	{
		// Trigger "PlacedClaymores" to blow
		for(iCounter = 0;iCounter < ArrayCount(PlacedClaymores); iCounter++)
		{
			if(PlacedClaymores[iCounter] != None)
			{
				if(NewClaymoretrigger(PlacedClaymores[iCounter])?)
					NewClaymoretrigger(PlacedClaymores[iCounter]).Detonate();
				else if(C4Trigger(PlacedClaymores[iCounter])?)
					C4Trigger(PlacedClaymores[iCounter]).Detonate();
				else
					log("WeaponClaymore can't trigger object: " $ PlacedClaymores[iCounter]);

				if(bCampaignGameType)
					bDestroyWeapon = true;
			}
		}
	}
	else
	{
		// play the 3rd person placement animation
		if ( Instigator? )
		{
			newAnimation.Alpha    = 1.0f;
			
			// stance defines what animation to play
			if ( Instigator.bIsProne )
			{
				newAnimation.AnimName = 'Knife_pr_stab';
			}
			else if ( Instigator.bIsCrouched )
			{
				newAnimation.AnimName = 'Medic_Cr_to_Heal';
			}
			else if ( Instigator.bIsCrawl )
			{
				newAnimation.AnimName = 'OH_tunnel_knees_to_Cr';
			}
			else
			{
				newAnimation.AnimName = 'Medic_ab_to_helping';
			}
			
			newAnimation.bLooping = false;
			newAnimation.Channel  = Instigator.FIRINGCHANNEL;
			newAnimation.Rate     = 1.0f;
			
			Instigator.StartAnimation( newAnimation, true, true );
		}
		
		// set up a timer to spawn the claymore
		SetDelegateTimer( 'SpawnClaymore', 0.33f, false );
	}
}

// Changes weapon modes
// Note: This function does nothing at the moment, in single-player
// the player can always place a Claymore with 'Use'
function ServerAltFire()
{
	VietnamPawn(Instigator).EndSpawnInvulnerability();

	LocalAltFire();
}

simulated function AltFire( float Value )
{
	// Can't change the mode in SP
	if(bCampaignGameType)
		return;

	ServerAltFire();

	// If this is running in a singleplayer game we don't want 
	// LocalAltFire called twice (ServerAltFire calls it also)
	if(Level.NetMode == NM_Client)
		LocalAltFire();
}

simulated function LocalAltFire()
{
	if(SpecialWeaponMode==ECM_Claymore)
	{
		SetSpecialWeaponMode( ECM_Trigger );
		GotoState('SwitchToTrigger');
	}
	else if(SpecialWeaponMode==ECM_Trigger && HasAmmo())
	{
		SetSpecialWeaponMode( ECM_Claymore );
		GotoState('SwitchToClaymore');
	}
}

state SwitchToTrigger
{
	ignores Fire, AltFire, ServerAltFire, NextWeapon, PrevWeapon;

	simulated function BeginState()
	{
		// If I have a claymore in my hand, put it away, otherwise
		// skip to the part where I take out the trigger
		if( ReloadCount == 1 && Instigator.IsLocallyControlled())
		{
			PlayAnim( 'claymore_putaway', 1.0, 0.0,
				FIRING_ANIMATION_CHANNEL );
			AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
				, , , , WEAPON_ACTION_TWEEN_TIME,
				WEAPON_ACTION_TWEEN_TIME, );
		}
		else
		{
			AnimEnd( FIRING_ANIMATION_CHANNEL );
		}
	}
	
	simulated function AnimEnd(int Channel)
	{
		if( Channel == FIRING_ANIMATION_CHANNEL )
		{
			PlayAnim('trigger_takeout', 1.0, 0.0,
				SPECIAL_ANIMATION_CHANNEL );
			AnimBlendParams( SPECIAL_ANIMATION_CHANNEL, 1.0f,
				, , , , WEAPON_ACTION_TWEEN_TIME,
				WEAPON_ACTION_TWEEN_TIME, );
		}
		else if ( Channel == SPECIAL_ANIMATION_CHANNEL )
		{
			GotoState( 'Idle' );
		}
	}

}

state SwitchToClaymore
{
	ignores Fire, AltFire, ServerAltFire, NextWeapon, PrevWeapon;

	simulated function BeginState()
	{
		// Switching to claymore counts as reloading it
		if(Role == ROLE_Authority && HasAmmo())
			DoReload();

		if(Instigator.IsLocallyControlled())
		{
			PlayAnim('trigger_putaway', 1.0, 0.0,
				FIRING_ANIMATION_CHANNEL );
			AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
				, , , , WEAPON_ACTION_TWEEN_TIME,
				WEAPON_ACTION_TWEEN_TIME, );
		}
		else
		{
			AnimEnd( FIRING_ANIMATION_CHANNEL );
		}
	}
	
	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			PlayAnim('claymore_takeout', 1.0, 0.0,
				SPECIAL_ANIMATION_CHANNEL );
			AnimBlendParams( SPECIAL_ANIMATION_CHANNEL, 1.0f,
				, , , , WEAPON_ACTION_TWEEN_TIME,
				WEAPON_ACTION_TWEEN_TIME, );
		}
		else if ( Channel == SPECIAL_ANIMATION_CHANNEL )
		{
			GotoState('Idle');
		}
	}
}

simulated function BringUp()
{
	// Change startup weapon modes
	local PlayerController PController;
	local int i;

	PController = PlayerController(Instigator.Controller);

	// Set member variable up to reflect the game type running
	if(PController?)
		bCampaignGameType = ClassIsChildOf(PController.GameReplicationInfo.GetClass(), class(DynamicLoadObject("VietnamGame.VietnamCampaign", class'class')));
	else
		bCampaignGameType = false;

	// Now decide what weapon mode to start up in

	// A campaign game always starts in trigger mode
	// Start in trigger mode if he has no claymores
	if(bCampaignGameType || !HasAmmo())
	{
		SetSpecialWeaponMode( ECM_Trigger );
	}
	else
	{
		// If there is an active claymore placed, default to trigger
		if(HasActiveClaymore())
		{
			SetSpecialWeaponMode( ECM_Trigger );
		}
		else
		{
			SetSpecialWeaponMode( ECM_Claymore );
		}
	}

	Super.BringUp();
}

state Active
{

	simulated function EndState()
	{
		Super.EndState( );
		if ( HasAmmo( ) )
		{
			DoReload();		// This prevents us from bringing up the 
							// claymore in active and *THEN* bringing it up again
							// to "reload", copied from WeaponBaseGrenade
		}
	}
}

// overridden:  has special put aways
//
// inputs:
// -- none --
//
// outputs:
// name of the animation to play
simulated function Name GetPutAwayAnimationName( )
{
	if ( SpecialWeaponMode == ECM_Trigger )
	{
		return 'trigger_putaway';
	}
	// else....
	
	return 'claymore_putaway';
}

// Should be implemented by individual weapons which use bDisplayAmmoType==false
simulated function string GetCurrentWeaponModeName()
{
	// Mode name is too long to coexist with weapon name
	return "";
}

function bool PlaceAClaymore()
{
	local Actor A;
	local int iCounter;
	local float DotForward;
	local bool bFoundClaymore;

	if(bCampaignGameType)
		return false;
	else
	{
		GotoState('PlaceClaymore');
	}

	return true;
}

function SpawnClaymore()
{
	local vector Forward, Right, Up;
	local vector SpawnPoint;
	local rotator SpawnRotation;
	local NewClaymoreTrigger PlacedClaymore;
	local int iCounter;

	GetAxes(Instigator.Rotation, Forward, Right, Up);

	// Spawn a little down and forward from the player
//	SpawnPoint = Instigator.Location + Forward * 30 - Up * 30;
// so many problems with the above line of code....
	SpawnPoint = Instigator.Location
		+ Forward * ( Instigator.CollisionRadius - class'NewClaymoreTrigger'.Default.CollisionRadius )
		- Up      * ( Instigator.CollisionHeight - class'NewClaymoreTrigger'.Default.CollisionHeight );

	SpawnRotation.Yaw = Owner.Rotation.Yaw;

	PlacedClaymore = Spawn(class'VietnamWeapons.NewClaymoreTrigger',self.Owner,,SpawnPoint, SpawnRotation);
	PlacedClaymore.SetPhysics(PHYS_Falling);
	PlacedClaymore.fUseTime = 0.0;	// Just make these instant for now
	PlacedClaymore.bResettable = false; // do this before triggering, or it won't work right
	PlacedClaymore.Triggered( Instigator );	// Calls RegisterPlacedClaymore
	PlacedClaymore.bBlockActors = true;

	if(Instigator.PlayerReplicationInfo.Team?)
		PlacedClaymore.AllowedTeam = Instigator.PlayerReplicationInfo.Team.TeamIndex;
	else
		PlacedClaymore.AllowedTeam = 255;
}

// Add a claymore to the local array
function RegisterPlacedClaymore(Actor PlacedClaymore)
{
	local int iCounter;

	for(iCounter = 0; iCounter < ArrayCount(PlacedClaymores); iCounter++)
	{
		if(PlacedClaymores[iCounter] == None)
		{
			PlacedClaymores[iCounter] = PlacedClaymore;
			UpdateHasActiveClaymores( );
			break;
		}
	}
}

// Remove a claymore from the local array
function RemoveClaymore(Actor PlacedClaymore)
{
	local int iCounter;

	for(iCounter = 0; iCounter < ArrayCount(PlacedClaymores); iCounter++)
	{
		if(PlacedClaymores[iCounter] == PlacedClaymore)
		{
			PlacedClaymores[iCounter] = None;
			UpdateHasActiveClaymores( );
			return;
		}
	}
}

simulated function Timer()
{
	VietnamHUD( PlayerController(Instigator.Controller).MyHUD ).RecieveUsageMessage( "" );
}

// Returns true if this player has active claymores in the world
simulated function bool HasActiveClaymore()
{
	return m_hasActiveClaymores;
}

simulated function bool NeedsToReload()
{
	if(SpecialWeaponMode == ECM_Trigger)
		return false;
	else
		return ( bForceReload || (Default.ReloadCount > 0) && (ReloadCount == 0) );
}

// This is the fire function replicated from client to server
// Or called on a listen-server or standalone game
function ServerFire()
{
	local float fStartFrameSeconds;
	local VietnamPlayerController VPController;
	
	//Log( "Brendan - VietnamWeapon::ServerFire" );

	VietnamPawn(Instigator).EndSpawnInvulnerability();

	// APT: 6-8-04 use the base function to determine whether we should
	// fake fire
	m_bBotFakeFiring = ShouldFakeFire();
	/*
	// are we actually firing the weapon?
	// 0.5 ms is what were shooting for
	if(bBotControlled)
	{
		m_bBotFakeFiring = (frand() >= (1 - (Level.Game.m_fWeaponFireFrameTime * 1000.f * (1.f / 0.25f))));
		//log("Z: Fake Firing:"$m_bBotFakeFiring$" WeaponFireFrameTime:"$Level.Game.m_fWeaponFireFrameTime);
	}
	*/

	fStartFrameSeconds = VietnamPawn(Instigator).appSeconds();

	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	// Check that the weapon has enough ammo to fire
	if ( ReloadCount > 0 || default.ReloadCount == 0 || SpecialWeaponMode == ECM_Trigger)
	{
		GotoState('NormalFire');

		if(SpecialWeaponMode == ECM_Claymore)
			ReloadCount--;

		CheckForLowAmmo();

		TimeSinceFired = 0;

		// M7 has no ammo for instance, so don't do a TraceFire
		if(AmmoType?)
		{
			if ( AmmoType.bInstantHit )
			{
				if(m_bBotFakeFiring || m_bScriptFakeFiring)
				{
					//Log( "Brendan - VietnamWeapon::ServerFire, about to call PlayFiring" );
					PlayFiring(); // Fire, but not actually fire
				}
				else
				{
					//Log( "Brendan - VietnamWeapon::ServerFire, about to call TraceFire" );
					TraceFire(TraceAccuracy,0,0);	// Fire the gun
				}
			}
			else	// Make sure we have some kind of
			{
				ProjectileFire();
			}
		}
		//Log( "Brendan - VietnamWeapon::ServerFire, about to call localfire" );
		LocalFire();
	}
	
	Level.Game.m_fWeaponFireFrameTime += VietnamPawn(Instigator).appSeconds() - fStartFrameSeconds;
	m_bBotFakeFiring = false;
}

simulated function DrawHud(canvas Canvas, VietnamHud Hud, float Scale)
{
	if(SpecialWeaponMode == ECM_Trigger)
		ItemName = ClackerName;
	else
		ItemName = Default.ItemName;

	Super.DrawHud(Canvas,Hud,Scale);
}

// overloaded:  makes the proper considerations
// for melee attacks based on the usage specs of
// the claymore
//
// inputs:
// -- none --
//
// outputs:
// true if okay to do a melee attack, false if
// otherwise
simulated function Bool CanMelee( )
{
	// no melee attacks while there are active claymores
	// lurking about
	return ( !HasActiveClaymore( ) && Super.CanMelee( ) );
}

// Only on client
simulated function TriggerClientFire()
{
	log("TriggerClientFire at " $ Level.TimeSeconds, 'Weapons');
	
	// Only simulate ammo count locally for one-shot weapons (so they won't try to fire again)
	if(default.ReloadCount == 1 && SpecialWeaponMode == ECM_Claymore)
		ReloadCount--;

	LocalFire();
	GotoState('NormalFire');
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

// Overridden by claymore to switch to clacker mode
simulated function SwitchToClacker()
{
	log("SwitchToClacker");
	SetSpecialWeaponMode( ECM_Trigger );
}

// Claymore is always semi-auto
simulated function bool IsSemiAuto()
{
	return true;
}

defaultproperties
{
     SpecialWeaponMode=ECM_Trigger
     ThirdPersonRelativeRotationClacker=(Yaw=49152)
     ThirdPersonRelativeLocationClacker=(X=6.000000,Y=-6.000000,Z=2.000000)
     ThirdPersonRelativeRotationClaymore=(Pitch=256,Yaw=256,Roll=256)
     ThirdPersonRelativeLocationClaymore=(X=13.000000,Y=-19.000000,Z=5.000000)
     PlayerCrouchViewOffset=(X=8.900000,Y=-4.300000,Z=-15.150000)
     PlayerAimViewOffset=(X=8.900000,Y=-4.300000,Z=-15.150000)
     Magnification=1.000000
     Accuracy=0.000000
     Recoil=0.000000
     m_maximumRecoil=750.000000
     Damage=35.000000
     AimImprovementRate=0.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     DelayAfterFire=0.900000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     WeaponGrip=EWG_Grenade
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     AutoFireSpeed=1.000000
     SemiAutoSpeed=1.000000
     m_fViewPitchKick=0.000000
     m_fViewKickMaxYawDelta=0.000000
     m_fViewKickMaxPitchDelta=0.000000
     MinTurnRateScale=0.550000
     TurnRateRampPower=10.000000
     AimAssistAngle=20.000000
     MinPrecisionTurnRateScale=0.350000
     PrecisionTurnRateRampPower=10.000000
     PrecisionAimAssistAngle=10.000000
     MinScreenPercent=0.000050
     bAllowWeaponSwitch=False
     MultiplayerDamage=35.000000
     bCanUseRedCrosshair=False
     AmmoName=Class'VietnamWeapons.AmmoClaymore'
     ReloadCount=1
     bExcludeFromWeapSwap=True
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MeshName="USMC_Viewmodels.fps_Claymore"
     InventoryGroup=16
     PickupType="PickupClaymore"
     PlayerViewOffset=(X=8.900000,Y=-4.300000,Z=-15.150000)
     PlayerHorizSplitViewOffset=(X=8.900000,Y=-4.300000,Z=-15.150000)
     PlayerVertSplitViewOffset=(X=8.900000,Y=-4.300000,Z=-15.150000)
     ThirdPersonRelativeLocation=(X=9.000000,Y=-6.000000,Z=5.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponClaymoreAttachment'
     ItemName="Claymore"
     bActorShouldTravel=False
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
