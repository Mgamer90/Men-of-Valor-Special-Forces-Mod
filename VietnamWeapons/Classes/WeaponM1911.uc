//===============================================================================
//  [ M1911 ]
// Firing modes:
//	semi-auto
//===============================================================================

class WeaponM1911 extends WeaponAutomaticPistol;

defaultproperties
{
     PlayerCrouchViewOffset=(X=-1.600000,Y=2.300000,Z=-14.450000)
     PlayerAimViewOffset=(X=-5.250000,Y=2.150000,Z=-14.350000)
     Magnification=1.300000
     Accuracy=125.000000
     Recoil=200.000000
     m_maximumRecoil=750.000000
     Damage=30.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     MuzzleClass=Class'VietnamGame.BaseFPMuzzleFlash'
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="M1911Outdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="M1911NP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="PistolUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="PistolEquip")
     WeaponSoundNames(4)=(PackageName="weapon_snd",ResourceName="M1911Reload")
     SemiAutoSpeed=1.000000
     m_fViewYawKick=100.000000
     m_fViewPitchKick=400.000000
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
     MinScreenPercent=0.000200
     ShellEjectMeshName="weapons_stat.shells.shell_stat"
     ForceFeedbackEffect="Fire gun"
     fCriticalHitPercent=0.400000
     WeaponAnimationFrameCount(0)=9.000000
     WeaponAnimationFrameCount(2)=102.000000
     WeaponAnimationFrameCount(3)=9.000000
     WeaponAnimationFrameCount(4)=12.000000
     MultiplayerDamage=40.000000
     m_meleeHitSound="MeleeSmallWeapon"
     m_melee3DHitSound="MeleeSmallWeapon3D"
     AmmoName=Class'VietnamWeapons.Ammo45Cal'
     ReloadCount=8
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     bDrawMuzzleFlash=True
     MFTextureName="effects_tex.MuzzleFlash.MuzzleflashPistol_tex"
     MFMinScale=0.040000
     MFMaxScale=0.060000
     bMFRandomRotation=True
     MeshName="USMC_Viewmodels.fps_m1911"
     InventoryGroup=10
     PickupType="PickupM1911"
     PlayerViewOffset=(X=-1.600000,Y=2.300000,Z=-14.450000)
     PlayerHorizSplitViewOffset=(X=-1.600000,Y=2.300000,Z=-13.450000)
     PlayerVertSplitViewOffset=(X=-1.600000,Y=2.300000,Z=-14.450000)
     ThirdPersonRelativeLocation=(X=10.000000,Y=-6.000000,Z=-4.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponM1911Attachment'
     ItemName="M1911"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
