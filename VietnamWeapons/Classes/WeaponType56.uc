//===============================================================================
//  [ Type56 ]
// Firing modes:
//	semi-auto
//  auto
//===============================================================================

class WeaponType56 extends VietnamWeapon;

var bool			bDoDownWeapon;

// overloaded:  does something special if the
// bayonet is attached
//
// inputs:
// -- none --
//
// outputs:
// animation name
simulated function Name GetFiringAnimationName( )
{
	if( WeaponMode == EWM_Bayonet )
	{
		return 'Bayonet_Fire_start';
	}
	// else....
	
	return Super.GetFiringAnimationName( );
}

state FireEnd
{
	simulated function BeginState()
	{
		if(UseAnimTimer())
		{
			WeaponAnimTimer(WeapAnim_FireEnd, FIRING_ANIMATION_CHANNEL, 1.0);
		}
		else	// play the first person animation
		{
			if(WeaponMode == EWM_Bayonet)
			{
				PlayAnim( 'Bayonet_Fire_end', ROF, 0.00,
					FIRING_ANIMATION_CHANNEL );
			}
			else
			{
				PlayAnim( 'fire_end', 1.0, 0.05,
					FIRING_ANIMATION_CHANNEL );
			}
			AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
				, , , , WEAPON_ACTION_TWEEN_TIME,
				WEAPON_ACTION_TWEEN_TIME, );
		}
	}
}

simulated function AltFire( float Value )
{
	ServerAltFire();

	if(Level.NetMode == NM_Client)
		if(!Instigator.Controller.IsInPreciseAimMode())
		{
			if(WeaponMode==EWM_Auto)
			{
				GotoState('TakeoutBayonet');
			}
			else if(WeaponMode==EWM_Bayonet)
			{
				GotoState('PutawayBayonet');
			}
		}
}

// Switch to bayonet mode and back to regular fire mode
function ServerAltFire()
{
	VietnamPawn(Instigator).EndSpawnInvulnerability();

	if(WeaponMode==EWM_Auto)
	{
		WeaponMode=EWM_Bayonet;
		GotoState('TakeoutBayonet');
	}
	else if(WeaponMode==EWM_Bayonet)
	{
		WeaponMode=EWM_Auto;
		GotoState('PutawayBayonet');
	}
}

state TakeoutBayonet
{
	ignores Fire, AltFire, ForceReload;
	
	simulated function BeginState()
	{
		local PlayerController PController;

		PlayAnim( 'Bayonet_Attach', 1.0, 0.05,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_ACTION_TWEEN_TIME,
			WEAPON_ACTION_TWEEN_TIME, );

		// Only play the non-positional sound if the controller is on this machine
		if(Instigator.IsLocallyControlled())
		{
			PController = PlayerController(Instigator.Controller);
			if(PController?)
				PController.ClientPlaySound(WeaponSounds[EWeaponSound.EWS_TakeoutBayonet]);
		}
	}
	
	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			GotoState('Idle');
		}
	}
}

state PutawayBayonet
{
	ignores Fire, AltFire, ForceReload;

	simulated function BeginState()
	{
		local PlayerController PController;

		PlayAnim( 'Bayonet_Detach', 1.0, 0.05,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_ACTION_TWEEN_TIME,
			WEAPON_ACTION_TWEEN_TIME, );

		// Only play the non-positional sound if the controller is on this machine
		if(Instigator.IsLocallyControlled())
		{
			PController = PlayerController(Instigator.Controller);
			if(PController?)
				PController.ClientPlaySound(WeaponSounds[EWeaponSound.EWS_PutawayBayonet]);
		}
	}
	
	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			if(bDoDownWeapon)
			{
				bDoDownWeapon = false;
				GotoState('DownWeapon');
			}
			else
				GotoState('Idle');
		}
	}
}

// overloaded:  does something special if the
// bayonet is attached
//
// inputs:
// -- none --
//
// outputs:
// animation Name
Simulated Function Name GetIdleAnimationName( )
{
	if ( WeaponMode == EWM_Bayonet )
	{
		return 'Bayonet_idle';
	}
	// else....

	return Super.GetIdleAnimationName( );
}

simulated function bool CanMelee()
{
	return Super.CanMelee() || WeaponMode == EWM_Bayonet;
}

function bool SKSStabTrace()
{
	local vector HitLocation, HitNormal, TraceStart, EndTrace, vForward, vRight, vUp;
	local actor Other;
	local rotator Rotation;
	local int iHitBone;
	local VietnamPawn tmpPawn;

	Rotation = VietnamPlayerController(Instigator.Controller).Rotation;

	TraceStart = VietnamPlayerController(Instigator.Controller).CalcFirstPersonViewLocation();
		
	GetAxes(Rotation, vForward, vRight, vUp);

	EndTrace = TraceStart + vForward * 150;

	// Do the trace
	Other = CustomTrace(TraceStart, EndTrace, TRACEFLAG(STRACE_AllBlocking), HitLocation, HitNormal,,,BLOCKFLAG(SBLOCK_Actors) | BLOCKFLAG(SBLOCK_Players) | BLOCKFLAG(SBLOCK_Bots) | BLOCKFLAG(SBLOCK_World),,iHitBone);


	if ( Other? && Other.IsA( 'VietnamPawn' ) )
	{
		tmpPawn = VietnamPawn(Other);
		tmpPawn.LastHitBone = iHitBone;

		// HACK!!: For some reason HitLocation is returning <0,0,0> when a pawn is hit
		HitLocation = Other.Location;

		// Bayonet does a ton of damage
		Other.TakeDamage(100,  Instigator, HitLocation, 30000.0*vForward, WeaponDamageType);	
		tmpPawn.SpawnBloodEffect(100, Instigator, HitLocation, rotator(vForward));
		// Rep to everybody around target pawn (except weapon's owner)
		tmpPawn.RemotePlayRegisteredSound( Level.PawnSoundNames[110].ResourceName, '');
		// Rep to weapon's owner so he hears it to
		Instigator.ClientPlayRegisteredReplicatedSound( Level.PawnSoundNames[110].ResourceName, '');
		return true;
	}
	
	return false;
}

state Melee
{
	simulated function BeginState()
	{
		// do a special attack if the bayonet is deployed
		if ( WeaponMode == EWM_Bayonet )
		{
			// TODO: Check if this is the right anim
			PlayAnim( 'Bayonet_Attack', 1.0, 0.05,
				FIRING_ANIMATION_CHANNEL );
			AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
				, , , , WEAPON_ACTION_TWEEN_TIME,
				WEAPON_ACTION_TWEEN_TIME, );
				
			ReadyToFire = false;

			Instigator.PlayMeleeAttackAnimation( );

			// trigger the melee attack sound
			if(Instigator.IsLocallyControlled())
				ClientPlayRegisteredSound( MELEE_SWING_SOUND, 'melee_swing' );

			// Everyone but owner should hear 3D version, only make the call on server who
			// will rep it to all clients (except owner)
			if(Role==ROLE_Authority)
				Instigator.RemotePlayRegisteredSound( MELEE_SWING3D_SOUND, 'melee_swing3D' );
		}
		else
		{
			Super.BeginState( );
		}
	}
	
	simulated function AnimEnd(int Channel)
	{
		// do a special attack if the bayonet is deployed
		if ( WeaponMode == EWM_Bayonet )
		{
			if ( Channel == FIRING_ANIMATION_CHANNEL )
			{
				// Do StabTrace here instead of in AnimNotify
				SKSStabTrace();
				GotoState('Idle');
			}
		}
		else
		{
			Super.AnimEnd( Channel );
		}
	}
}

/* DownWeapon
Putting down weapon in favor of a new one.  No firing in this state
*/
State DownWeapon
{
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function ServerFire() {}

	// Designed to be overridden by weapons that need special PutDown processing
	// Instead of overriding DownWeapon::BeginState
	simulated function HandlePutdown()
	{
		if(WeaponMode == EWM_Bayonet)
		{
			bDoDownWeapon = true;
			Global.ServerAltFire();
		}
		else
			TweenDown();
	}
}

// Plays the animation and the accompanying sound
simulated function PlayReloading()
{
	local PlayerController PController;
	local Float            animationLength, animationRate, frames, rate;

	PController = PlayerController(Instigator.Controller);
	if(PController?)
		PController.ClientPlaySound(WeaponSounds[EWeaponSound.EWS_Reload]);

	if(UseAnimTimer())
	{
		WeaponAnimTimer(WeapAnim_Reload, FIRING_ANIMATION_CHANNEL, 1.0);
		
		animationLength = ComputeWeaponAnimTimerLength( WeapAnim_Reload, 1.0 );
		animationRate   = 1.0f;
	}
	else
	{
		if(WeaponMode == EWM_Bayonet)
		{
			PlayAnim( 'Bayonet_Reload', GetReloadAnimationRate( ), 0.05,
				FIRING_ANIMATION_CHANNEL );
			
			GetAnimSequenceParams( 'Bayonet_Reload', frames, rate );
		}
		else
		{
			PlayAnim( 'Reload', GetReloadAnimationRate( ), 0.05,
				FIRING_ANIMATION_CHANNEL );
			
			GetAnimSequenceParams( 'Reload', frames, rate );
		}
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_RELOAD_TWEEN_TIME,
			WEAPON_RELOAD_TWEEN_TIME, );

		animationLength = frames / rate;
		animationRate   = GetReloadAnimationRate( );
	}

	// third person anims
	Instigator.PlayReload( animationLength, animationRate );
}

// Should be implemented by individual weapons which use bDisplayAmmoType==false
simulated function string GetCurrentWeaponModeName()
{
	return AutoString;
}

defaultproperties
{
     PlayerCrouchViewOffset=(X=11.400000,Y=3.750000,Z=-15.250000)
     PlayerAimViewOffset=(X=11.400000,Y=0.100000,Z=-13.500000)
     Magnification=1.400000
     Accuracy=50.000000
     m_maximumRecoil=750.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     MuzzleClass=Class'VietnamGame.BaseFPMuzzleFlash'
     bFiresTracerRounds=True
     iRoundsPerTracer=2
     WeaponMode=EWM_Auto
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="AK47Outdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="AK47NP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(5)=(PackageName="weapon_snd",ResourceName="AK47SemiAutoSelect")
     WeaponSoundNames(6)=(PackageName="weapon_snd",ResourceName="BayonetEquip")
     WeaponSoundNames(7)=(PackageName="weapon_snd",ResourceName="BaynetUnequip")
     WeaponSoundNames(8)=(PackageName="weapon_snd",ResourceName="AK47InsertMag")
     WeaponSoundNames(9)=(PackageName="weapon_snd",ResourceName="AK47RemoveMag")
     WeaponSoundNames(10)=(PackageName="weapon_snd",ResourceName="AK47Action")
     AutoFireSpeed=0.700000
     SemiAutoSpeed=0.700000
     m_fViewYawKick=150.000000
     m_fViewPitchKick=300.000000
     m_fViewDegradeYaw=1024.000000
     m_fViewDegradePitch=2048.000000
     m_fViewKickMaxYawDelta=8192.000000
     m_fViewKickMaxPitchDelta=16384.000000
     MinTurnRateScale=0.550000
     TurnRateRampPower=10.000000
     AimAssistAngle=20.000000
     MinPrecisionTurnRateScale=1.000000
     PrecisionTurnRateRampPower=10.000000
     PrecisionAimAssistAngle=20.000000
     MinScreenPercent=0.000100
     m_basicFiringAnimation="Fire_start"
     bUsesFireEnd=True
     ShellEjectMeshName="weapons_stat.shells.sks_shell_stat"
     ForceFeedbackEffect="Fire gun"
     fCriticalHitPercent=0.300000
     WeaponAnimationFrameCount(0)=2.000000
     WeaponAnimationFrameCount(1)=6.000000
     WeaponAnimationFrameCount(2)=117.000000
     WeaponAnimationFrameCount(3)=43.000000
     WeaponAnimationFrameCount(4)=14.000000
     MultiplayerDamage=40.000000
     PreferredWeaponMenuIndex=1
     AmmoName=Class'VietnamWeapons.Ammo762WP'
     ReloadCount=30
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MaxRange=10000.000000
     bDrawMuzzleFlash=True
     MFTextureName="effects_tex.MuzzleFlash.MuzzleflashPistol_tex"
     bMFRandomRotation=True
     MeshName="USMC_Viewmodels.fps_Type56"
     InventoryGroup=20
     PickupType="PickupType56"
     PlayerViewOffset=(X=11.400000,Y=3.750000,Z=-15.250000)
     PlayerHorizSplitViewOffset=(X=11.400000,Y=3.750000,Z=-13.250000)
     PlayerVertSplitViewOffset=(X=11.400000,Y=3.750000,Z=-15.250000)
     ThirdPersonRelativeLocation=(X=7.000000,Y=-5.000000,Z=-3.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponType56Attachment'
     ItemName="Type56"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
