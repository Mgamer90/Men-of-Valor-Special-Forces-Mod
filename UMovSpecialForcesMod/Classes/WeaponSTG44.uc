//===============================================================================
//  [ STG44 ]
// Firing modes:
//	single shot
//  auto
//===============================================================================

class WeaponSTG44 extends WeaponAK47;

defaultproperties
{
     PlayerCrouchViewOffset=(X=11.400000,Y=3.750000,Z=-15.250000)
     PlayerAimViewOffset=(X=7.700000,Y=-0.250000,Z=-14.250000)
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
     bBurstCapable=True
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="AK47Outdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="AK47NP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(5)=(PackageName="weapon_snd",ResourceName="AK47SemiAutoSelect")
     WeaponSoundNames(6)=(PackageName="weapon_snd",ResourceName="AK47InsertMag")
     WeaponSoundNames(7)=(PackageName="weapon_snd",ResourceName="AK47RemoveMag")
     WeaponSoundNames(8)=(PackageName="weapon_snd",ResourceName="AK47Action")
     AutoFireSpeed=0.700000
     SemiAutoSpeed=0.400000
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
     MeshName="USMC_Viewmodels.fps_ak47"
     InventoryGroup=0
     PickupType="PickupAK47"
     PlayerViewOffset=(X=11.400000,Y=3.750000,Z=-15.250000)
     PlayerHorizSplitViewOffset=(X=11.400000,Y=3.750000,Z=-13.250000)
     PlayerVertSplitViewOffset=(X=11.400000,Y=3.750000,Z=-15.250000)
     ThirdPersonRelativeLocation=(X=7.000000,Y=-5.000000,Z=-3.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponAK47Attachment'
     ItemName="AK47"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
