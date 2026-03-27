//===============================================================================
//  [ M16 ]
// Firing modes:
//	semi-auto
//  auto
//===============================================================================

class WeaponM16Scope extends WeaponM16;

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	OverlayTexture = Material(DynamicLoadObject( "interface_tex.SCOPE.Scope_FinalBlend",class'Material'));
}

// Give a little kick
simulated function EnterAimMode()
{
	shakemag=350.000000;
	shaketime=1.200000;
	shakevert=vect(0.0,0.0,6.00000);
	shakespeed=vect(100.0,100.0,100.0);

	Accuracy = -200;

	bRenderOverlay = true;
}

// restores the default aiming characteristics
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment)
simulated function RestoreAimingDefaults( )
{
	shakemag = Default.shakemag;
	shaketime = Default.shaketime;
	shakevert = Default.shakevert;
	shakespeed = Default.shakespeed;

	Accuracy = Default.Accuracy;

	bRenderOverlay = false;
}

// Remove kick
simulated function ExitAimMode()
{
	RestoreAimingDefaults( );
}

// overloaded:  turns off the overlay and
// aiming enhancements for the sniper mode
//
// inputs:
// StartLocation - initial location to spawn at
// StartRotation - initial rotation
// bDropAmmo     - also drop my ammo
//
// outputs:
// -- none --
function Pickup DropFrom(vector StartLocation, optional rotator StartRotation, optional bool bDropAmmo)
{
	RestoreAimingDefaults( );
	
	return Super.DropFrom( StartLocation, StartRotation, bDropAmmo );
}

static function StaticPrecacheAssets(optional Object MyLevel)
{
	Super.StaticPrecacheAssets(MyLevel);

	DynamicLoadObject("interface_tex.SCOPE.Scope_FinalBlend",class'Material');
	DynamicLoadObject("weapons_stat.us.m21_scope_stat",class'StaticMesh');
}

simulated function PrecacheAssets()
{
	Super.PrecacheAssets();

	DynamicLoadObject("interface_tex.SCOPE.Scope_FinalBlend",class'Material');
	DynamicLoadObject("weapons_stat.us.m21_scope_stat",class'StaticMesh');
}

defaultproperties
{
     bUsePrecisionAimOverlay=True
     PlayerCrouchViewOffset=(X=9.750000,Y=1.350000,Z=-14.550000)
     PlayerAimViewOffset=(X=3.000000,Y=-3.000000,Z=-12.900000)
     Magnification=8.000000
     Accuracy=0.000000
     Recoil=150.000000
     m_maximumRecoil=750.000000
     Damage=20.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     MuzzleClass=Class'VietnamGame.BaseFPMuzzleFlash'
     bFiresTracerRounds=True
     iRoundsPerTracer=2
     WeaponMode=EWM_Auto
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="M16Outdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="M16NP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(4)=(PackageName="weapon_snd",ResourceName="M16Reload")
     WeaponSoundNames(5)=(PackageName="weapon_snd",ResourceName="AK47SemiAutoSelect")
     AutoFireSpeed=0.700000
     SemiAutoSpeed=0.500000
     m_fViewYawKick=150.000000
     m_fViewPitchKick=300.000000
     m_fViewDegradeYaw=0.000000
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
     bUsesFireEnd=True
     bDoubleShortRangeDamage=True
     ShellEjectMeshName="weapons_stat.shells.shell_556_stat"
     ForceFeedbackEffect="Fire gun"
     fCriticalHitPercent=0.250000
     WeaponAnimationFrameCount(0)=2.000000
     WeaponAnimationFrameCount(1)=7.000000
     WeaponAnimationFrameCount(2)=108.000000
     WeaponAnimationFrameCount(3)=20.000000
     WeaponAnimationFrameCount(4)=14.000000
     MultiplayerDamage=20.000000
     PreferredWeaponMenuIndex=1
     iHandSkinIndex=1
     AmmoName=Class'VietnamWeapons.Ammo556NATO'
     ReloadCount=30
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MaxRange=10000.000000
     bDrawMuzzleFlash=True
     MFTextureName="effects_tex.MuzzleFlash.MuzzleflashM16_tex"
     MFRotationMultiple=13107
     bMFRandomRotation=True
     specificReloadAnim="TH_Ab_M16_Reload"
     bCanUseBayonet=True
     MeshName="USMC_Viewmodels.fps_m16"
     InventoryGroup=2
     PickupType="PickupM16"
     PlayerViewOffset=(X=9.750000,Y=1.350000,Z=-14.550000)
     PlayerHorizSplitViewOffset=(X=9.750000,Y=1.350000,Z=-14.550000)
     PlayerVertSplitViewOffset=(X=9.750000,Y=1.350000,Z=-14.550000)
     ThirdPersonRelativeLocation=(X=6.000000,Y=-6.000000,Z=-4.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponM16Attachment'
     ItemName="M16"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
