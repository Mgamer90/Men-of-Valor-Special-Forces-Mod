//===============================================================================
//  [ RPD ]
// Firing modes:
//	semi-auto
//  auto
//===============================================================================

class WeaponRPD extends VietnamWeapon;

var Material AmmoBeltMaterial;
var Material TransparentMaterial;

var int iAmmoStartIndex, iAmmoEndIndex;

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	CopyMaterialsToSkins();
	AmmoBeltMaterial = Skins[2];
	TransparentMaterial = Shader(DynamicLoadObject("Decals_tex.transparency_tex_shader", class'Shader'));
}

function RegisterPlayer(bool bBotOrNot)
{
	Super.RegisterPlayer(bBotOrNot);

	if(bBotControlled)
		WeaponMode = EWM_Auto;
}

// This function dynamically updates the skins for the M60 to simulate the effect
// of running out of ammo
// bForceAmmo causes all bullets to be visible
simulated function UpdateSkins(optional bool bForceAmmo)
{
	local int iCounter, iEnd;

	// Make all skins transparent
	for(iCounter = iAmmoStartIndex; iCounter < iAmmoEndIndex + 1; iCounter++)
		Skins[iCounter] = TransparentMaterial;

	if(bForceAmmo)
		iEnd = iAmmoEndIndex + 1;
	else
		iEnd = Min(ReloadCount + iAmmoStartIndex,iAmmoEndIndex + 1);

	// Now determine how many skins should be made visible
	for(iCounter = iAmmoStartIndex; iCounter < iEnd; iCounter++)
		Skins[iCounter] = AmmoBeltMaterial;
}

// Changes weapon modes
function ServerAltFire()
{
	VietnamPawn(Instigator).EndSpawnInvulnerability();

	if(WeaponMode==EWM_Semiauto)
	{
		WeaponMode=EWM_Auto;
	}
	else if(WeaponMode==EWM_Auto)
	{
		WeaponMode=EWM_Semiauto;
	}
	
	if(!Instigator.Controller.IsInPreciseAimMode())
		GotoState('ModeSwitch');
}

// Called by AnimNotify
simulated function ForceUpdateSkins()
{
	UpdateSkins(true);
}

simulated function LocalFire()
{
	Super.LocalFire();

	UpdateSkins();
}

simulated state Idle
{
	// overloaded:  starts an animation on channel
	// SPECIAL_ANIMATION_CHANNEL to use when the
	// weapon owner moves faster
	//
	// inputs:
	// -- none --
	//
	// outputs:
	// -- none -- (UnReal Event)
	simulated function BeginState( )
	{
		// do the parent stuff first
		Super.BeginState( );
		
		// start a walking idle animation
		// on channel SPECIAL_ANIMATION_CHANNEL
		// (set alpha to 0 so it will be hidden
		// until needed)
		LoopAnim( 'Walk', 1.0f, 0.0f,
			SPECIAL_ANIMATION_CHANNEL );
		AnimBlendParams( SPECIAL_ANIMATION_CHANNEL,
			0.0f );
	}
	
	// overloaded:  stops the special animation
	// on channel SPECIAL_ANIMATION_CHANNEL
	//
	// inputs:
	// -- none --
	//
	// outputs:
	// -- none -- (UnReal Event)
	simulated function EndState( )
	{
		// stop the special animation
		StopAnimationChannel( SPECIAL_ANIMATION_CHANNEL );
		
		// do the parent stuff too!
		Super.EndState( );
	}

	// overloaded:  blends in and out a special
	// walking idle animation based on the owner's
	// walking speed
	//
	// inputs:
	// DeltaTime - time elapsed this frame
	//
	// outputs:
	// -- none --
	simulated function Tick( float DeltaTime )
	{
		local float currentAlpha;

		// what is the current blend value on
		// the special channel?
		GetBlendInfo( SPECIAL_ANIMATION_CHANNEL, currentAlpha );

		// if the instigator is moving fast enough and the
		// blend is set to less than SPECIAL_ANIMATION_CHANNEL
		// for the special animation, blend it up to
		// SPECIAL_ANIMATION_CHANNEL
		if( VSize( Instigator.Velocity ) > 100 && HasAmmo( ) &&
			currentAlpha < 1.0f )
		{
			AnimBlendToAlpha( SPECIAL_ANIMATION_CHANNEL, 1.0f, 0.3f );
		}
		else
		{
			// otherwise, blend out the channel and
			// let the basic idle take over
			AnimBlendToAlpha( SPECIAL_ANIMATION_CHANNEL, 0.0f, 0.3f );
		}
		
		// do the parent stuff too
		Super.Tick( DeltaTime );
	}

	// AnimEnd( ) was removed because looping is now handled
	// by the animation system directly
}

state Active
{
	simulated function BeginState()
	{
		Super.BeginState();
		UpdateSkins();	// In case player reloaded, then switched away and back
						// this is needed to keep ammo belt in sync
	}
}

// Should be implemented by individual weapons which use bDisplayAmmoType==false
simulated function string GetCurrentWeaponModeName()
{
	if(WeaponMode==EWM_Semiauto)
	{
		return SemiAutoString;
	}
	else if(WeaponMode==EWM_Auto)
	{
		return AutoString;
	}
}

defaultproperties
{
     iAmmoStartIndex=2
     iAmmoEndIndex=11
     PlayerCrouchViewOffset=(X=21.299999,Y=0.400000,Z=-14.250000)
     PlayerAimViewOffset=(X=17.000000,Y=-2.600000,Z=-14.250000)
     ROF=0.800000
     Magnification=1.300000
     Accuracy=200.000000
     m_maximumRecoil=750.000000
     Damage=30.000000
     AimImprovementRate=1300.000000
     RecoilDampeningRate=1300.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     MuzzleClass=Class'VietnamGame.BaseFPMuzzleFlash'
     bFiresTracerRounds=True
     iRoundsPerTracer=2
     WeaponGrip=EWG_TwoHandedHeavy
     WeaponMode=EWM_Auto
     bBurstCapable=True
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="RPDOutdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="RPDNP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(4)=(PackageName="weapon_snd",ResourceName="RPDReload")
     WeaponSoundNames(5)=(PackageName="weapon_snd",ResourceName="AK47SemiAutoSelect")
     AutoFireSpeed=1.000000
     SemiAutoSpeed=1.000000
     m_fViewYawKick=150.000000
     m_fViewPitchKick=325.000000
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
     bCanOnlyReloadWhenEmpty=True
     bUsesFireEnd=True
     ForceFeedbackEffect="Fire gun"
     fCriticalHitPercent=0.250000
     WeaponAnimationFrameCount(0)=2.000000
     WeaponAnimationFrameCount(1)=5.000000
     WeaponAnimationFrameCount(2)=191.000000
     WeaponAnimationFrameCount(3)=72.000000
     WeaponAnimationFrameCount(4)=48.000000
     MultiplayerDamage=30.000000
     PreferredWeaponMenuIndex=4
     AmmoName=Class'VietnamWeapons.Ammo762WP'
     ReloadCount=100
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MaxRange=10000.000000
     bDrawMuzzleFlash=True
     MFTextureName="effects_tex.MuzzleFlash.MuzzleflashPistol_tex"
     bMFRandomRotation=True
     specificReloadAnim="Th_Ab_RPD_Reload"
     MeshName="USMC_Viewmodels.fps_RPD"
     InventoryGroup=6
     PickupType="PickupRPD"
     PlayerViewOffset=(X=21.299999,Y=0.400000,Z=-14.250000)
     PlayerHorizSplitViewOffset=(X=21.299999,Y=0.400000,Z=-12.250000)
     PlayerVertSplitViewOffset=(X=21.299999,Y=0.400000,Z=-14.250000)
     ThirdPersonRelativeLocation=(X=7.000000,Y=-6.000000,Z=-5.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponRPDAttachment'
     ItemName="RPD"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
