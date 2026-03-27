//===============================================================================
//  [ M60 ]
// Firing modes:
//  auto
//===============================================================================

class WeaponM60 extends VietnamWeapon;

var Material AmmoBeltMaterial;
var Material TransparentMaterial;

var int iAmmoStartIndex, iAmmoEndIndex;

//var EMitter MFEmitter;

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	CopyMaterialsToSkins();
	AmmoBeltMaterial = Skins[1];
	TransparentMaterial = Shader(DynamicLoadObject("Decals_tex.transparency_tex_shader", class'Shader'));
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

// Should be implemented by individual weapons which use bDisplayAmmoType==false
simulated function string GetCurrentWeaponModeName()
{
	return AutoString;
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

defaultproperties
{
     iAmmoStartIndex=1
     iAmmoEndIndex=19
     PlayerCrouchViewOffset=(X=24.049999,Y=1.950000,Z=-18.620001)
     PlayerAimViewOffset=(X=19.000000,Y=-0.200000,Z=-17.000000)
     Magnification=1.300000
     Accuracy=200.000000
     m_maximumRecoil=750.000000
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
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="M60Outdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="M60NP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(4)=(PackageName="weapon_snd",ResourceName="M60Reload")
     AutoFireSpeed=1.000000
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
     bUsesFireEnd=True
     ShellEjectMeshName="weapons_stat.shells.shell_556_stat"
     ForceFeedbackEffect="Fire gun"
     fCriticalHitPercent=0.400000
     WeaponAnimationFrameCount(0)=3.000000
     WeaponAnimationFrameCount(1)=7.000000
     WeaponAnimationFrameCount(2)=175.000000
     WeaponAnimationFrameCount(3)=66.000000
     WeaponAnimationFrameCount(4)=43.000000
     MultiplayerDamage=40.000000
     PreferredWeaponMenuIndex=4
     m_meleeHitSound="MeleeFistHit"
     m_melee3DHitSound="MeleeFistHit3D"
     AmmoName=Class'VietnamWeapons.Ammo762NATOBeltFed'
     ReloadCount=100
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MaxRange=10000.000000
     bDrawMuzzleFlash=True
     MFTextureName="effects_tex.MuzzleFlash.MuzzleflashM60_tex"
     MFMinScale=0.080000
     MFMaxScale=0.100000
     specificReloadAnim="Th_Ab_M60_Reload"
     MeshName="USMC_Viewmodels.fps_M60"
     InventoryGroup=7
     PickupType="PickupM60"
     PlayerViewOffset=(X=24.049999,Y=1.950000,Z=-18.620001)
     PlayerHorizSplitViewOffset=(X=24.049999,Y=1.950000,Z=-16.620001)
     PlayerVertSplitViewOffset=(X=24.049999,Y=1.950000,Z=-18.620001)
     ThirdPersonRelativeLocation=(X=10.000000,Y=-4.000000,Z=-2.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponM60Attachment'
     ItemName="M60"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
