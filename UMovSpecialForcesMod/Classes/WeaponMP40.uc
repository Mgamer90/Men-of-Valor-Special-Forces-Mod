//===============================================================================
//  [ MP40 ]
// Firing modes:
//	semi-auto
//  auto
//===============================================================================

class WeaponMP40 extends WeaponPPSH41;

defaultproperties
{
     PlayerCrouchViewOffset=(X=9.100000,Y=2.100000,Z=-14.550000)
     PlayerAimViewOffset=(X=3.000000,Y=-3.000000,Z=-12.900000)
     Magnification=1.400000
     Accuracy=200.000000
     Recoil=150.000000
     m_maximumRecoil=750.000000
     Damage=35.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     MuzzleClass=Class'VietnamGame.BaseFPMuzzleFlash'
     bFiresTracerRounds=True
     iRoundsPerTracer=2
     WeaponMode=EWM_Auto
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="PPSHOutdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="PPSHNP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     AutoFireSpeed=0.700000
     SemiAutoSpeed=1.000000
     MHEType=EMHE_Small
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
     MinScreenPercent=0.000150
     m_basicFiringAnimation="Fire_start"
     bUsesFireEnd=True
     ShellEjectMeshName="weapons_stat.shells.shell_stat"
     ForceFeedbackEffect="Fire gun"
     fCriticalHitPercent=0.250000
     WeaponAnimationFrameCount(0)=2.000000
     WeaponAnimationFrameCount(1)=6.000000
     WeaponAnimationFrameCount(2)=131.000000
     WeaponAnimationFrameCount(3)=12.000000
     WeaponAnimationFrameCount(4)=9.000000
     MultiplayerDamage=35.000000
     PreferredWeaponMenuIndex=1
     AmmoName=Class'VietnamWeapons.Ammo762WP'
     ReloadCount=71
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MaxRange=6000.000000
     bDrawMuzzleFlash=True
     MFTextureName="effects_tex.MuzzleFlash.MuzzleflashPistol_tex"
     bMFRandomRotation=True
     specificReloadAnim="Th_Ab_PPSH41_Reload"
     MeshName="USMC_Viewmodels.fps_ppsh41"
     InventoryGroup=19
     PickupType="PickupPPSH41"
     PlayerViewOffset=(X=9.100000,Y=2.100000,Z=-14.550000)
     PlayerHorizSplitViewOffset=(X=9.100000,Y=2.100000,Z=-12.550000)
     PlayerVertSplitViewOffset=(X=9.100000,Y=2.100000,Z=-14.550000)
     ThirdPersonRelativeLocation=(X=17.000000,Y=-25.000000,Z=8.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponPPSH41Attachment'
     ItemName="PPSH41"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
