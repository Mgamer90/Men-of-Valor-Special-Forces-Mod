//===============================================================================
//  [ M14 ]
// Firing modes:
//	semi-auto
//  auto
// NOTE: Doesn't support bayonet anymore
//===============================================================================

class WeaponM14 extends VietnamWeapon;


simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	CopyMaterialsToSkins();
}

simulated function bool CanMelee()
{
	return Super.CanMelee() || bBayonetAttached;
}

// Called by animnotify
function StabTrace()
{
	local vector HitLocation, HitNormal, TraceStart, EndTrace, vForward, vRight, vUp;
	local actor Other;
	local int iHitBone;
	local VietnamPawn tmpPawn;

	TraceStart = VietnamPlayerController(Instigator.Controller).CalcFirstPersonViewLocation();

	GetAxes(Instigator.Controller.Rotation, vForward, vRight, vUp);

	EndTrace = TraceStart + vForward * 150;

	// Do the trace
	Other = CustomTrace(TraceStart, EndTrace, TRACEFLAG(STRACE_AllBlocking), HitLocation, HitNormal,,,BLOCKFLAG(SBLOCK_Actors) | BLOCKFLAG(SBLOCK_Players) | BLOCKFLAG(SBLOCK_Bots) | BLOCKFLAG(SBLOCK_World),,iHitBone);

	if ( Other.IsA('VietnamPawn') )
	{
		tmpPawn = VietnamPawn(Other);
		tmpPawn.LastHitBone = iHitBone;

		// Bayonet does a ton of damage
		tmpPawn.TakeDamage(100,  Instigator, HitLocation, 30000.0*vForward, WeaponDamageType);	
		tmpPawn.SpawnBloodEffect(100, Instigator, HitLocation, rotator(vForward));
		tmpPawn.PlaySound(Level.PawnSounds[110]);	// Bayonet stab sound
	}
}

state Melee
{
	simulated function BeginState()
	{
		local name AnimName;

		ReadyToFire = false;

		if(bBayonetAttached)
			AnimName = 'Bayonet_Attack';
		else
			AnimName = 'Buttstroke';

		PlayAnim( AnimName, 1.0, 0.05,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_ACTION_TWEEN_TIME,
			WEAPON_ACTION_TWEEN_TIME, );
			
		// trigger the melee attack sound
		if(Instigator.IsLocallyControlled())
			ClientPlayRegisteredSound( MELEE_SWING_SOUND, 'melee_swing' );

		// Everyone but owner should hear 3D version, only make the call on server who
		// will rep it to all clients (except owner)
		if(Role==ROLE_Authority)
			Instigator.RemotePlayRegisteredSound( MELEE_SWING3D_SOUND, 'melee_swing3D' );
			
		Instigator.PlayMeleeAttackAnimation( );
	}

	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			GotoState('Idle');
		}
	}
}

// Overridden to play 'bayonet_Reload' animation
simulated function PlayReloading()
{
	local PlayerController PController;
	local Float            animationLength, animationRate, frames, rate;

	PController = PlayerController(Instigator.Controller);
	if(PController != NONE && WeaponSounds[
		EWeaponSound.EWS_Reload ] != NONE )
	{
		PController.ClientPlaySound( WeaponSounds[
			EWeaponSound.EWS_Reload ] );
	}

	if(UseAnimTimer())
	{
		WeaponAnimTimer(WeapAnim_Reload, FIRING_ANIMATION_CHANNEL, 1.0);
		
		animationLength = ComputeWeaponAnimTimerLength( WeapAnim_Reload, 1.0 );
		animationRate   = 1.0f;
	}
	else	// play the first person animation
	{
		PlayAnim( 'bayonet_Reload', GetReloadAnimationRate( ), 0.05,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_RELOAD_TWEEN_TIME,
			WEAPON_RELOAD_TWEEN_TIME, );

		GetAnimSequenceParams( 'bayonet_Reload', frames, rate );
		animationLength = frames / rate;
		animationRate   = GetReloadAnimationRate( );
	}
	// third person anims
	Instigator.PlayReload( animationLength, animationRate );
}

state DownWeapon
{
	simulated function AnimEnd(int Channel)
	{
		if ( Channel == IDLE_ANIMATION_CHANNEL )
		{
			if(Master?)
			{		
				Master.EndWeaponRelationship();
				Master = None;
				
				// stop the animation on the idle
				// channel (just to be safe and
				// ensure that it won't nerf the
				// next takeout)
				StopAnimationChannel( IDLE_ANIMATION_CHANNEL );
			}
			else
			{
				Super.AnimEnd( Channel );
			}
		}
	}
}

// Should be implemented by individual weapons which use bDisplayAmmoType==false
simulated function string GetCurrentWeaponModeName()
{
	return SemiAutoString;
}

// overloaded:  has special putaway animations when
// equipped with the bayonet
//
// inputs:
// -- none --
//
// outputs:
// name of the animation to play
simulated function Name GetPutAwayAnimationName( )
{
	return 'bayonet_putaway';
}

// overloaded:  uses a different takeout if the
// bayonet is attached
//
// inputs:
// -- none --
//
// outputs:
// name of the animation to play
simulated function Name ResolveTakeoutAnimation( )
{
	return 'bayonet_takeout';
}

// returns the Name of the idle animation to play
//
// inputs:
// -- none --
//
// outputs:
// animation Name
Simulated Function Name GetIdleAnimationName( )
{
	return 'Bayonet_idle';
}

simulated function UpdateBayonetSkin()
{
}

state TakeoutBayonet
{
	ignores Fire, AltFire, ForceReload, NextWeapon, PrevWeapon;

	simulated function BeginState()
	{
		bBayonetAttached = true;
		// No tweening on this anim or bayonet shows up too early
		PlayAnim( 'Bayonet_attach', 1.0, 0.00,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_ACTION_TWEEN_TIME,
			WEAPON_ACTION_TWEEN_TIME, );

		//Skins[BAYONETINDEX] = BayonetMaterial;
	}

	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			// Mark this as complete
			bAttachingBayonet = false;
			GotoState('Idle');
		}
	}
}

state PutawayBayonet
{
	ignores Fire, AltFire, ForceReload, NextWeapon, PrevWeapon;

	simulated function BeginState()
	{
		PlayAnim( 'Bayonet_detach', 1.0, 0.05,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_ACTION_TWEEN_TIME,
			WEAPON_ACTION_TWEEN_TIME, );
	}

	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			//Skins[BAYONETINDEX] = Material(DynamicLoadObject("Decals_tex.transparency_tex_shader", class'Shader'));		
			bBayonetAttached = false;
			GotoState('DownWeapon');
		}
	}
}

defaultproperties
{
     PlayerCrouchViewOffset=(X=9.750000,Y=1.350000,Z=-15.150000)
     PlayerAimViewOffset=(X=-2.800000,Y=-2.000000,Z=-15.050000)
     Magnification=1.600000
     Accuracy=0.000000
     m_maximumRecoil=750.000000
     Damage=50.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     MuzzleClass=Class'VietnamGame.BaseFPMuzzleFlash'
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="M14Outdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="M14NP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(5)=(PackageName="weapon_snd",ResourceName="AK47SemiAutoSelect")
     SemiAutoSpeed=0.800000
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
     m_basicFiringAnimation="Bayonet_Fire"
     ShellEjectMeshName="weapons_stat.shells.shell_556_stat"
     ForceFeedbackEffect="Fire gun"
     fCriticalHitPercent=0.500000
     WeaponAnimationFrameCount(0)=10.000000
     WeaponAnimationFrameCount(2)=114.000000
     WeaponAnimationFrameCount(3)=24.000000
     WeaponAnimationFrameCount(4)=20.000000
     MultiplayerDamage=50.000000
     PreferredWeaponMenuIndex=1
     AmmoName=Class'VietnamWeapons.Ammo762NATO'
     ReloadCount=20
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MaxRange=10000.000000
     bDrawMuzzleFlash=True
     MFTextureName="effects_tex.MuzzleFlash.MuzzleflashPistol_tex"
     bMFRandomRotation=True
     bCanUseBayonet=True
     MeshName="USMC_Viewmodels.fps_m14"
     InventoryGroup=8
     PickupType="PickupM14"
     PlayerViewOffset=(X=9.750000,Y=1.350000,Z=-15.150000)
     PlayerHorizSplitViewOffset=(X=9.750000,Y=1.350000,Z=-14.150000)
     PlayerVertSplitViewOffset=(X=9.750000,Y=1.350000,Z=-15.150000)
     ThirdPersonRelativeLocation=(X=13.000000,Y=-6.000000,Z=7.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponM14Attachment'
     ItemName="M14"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
