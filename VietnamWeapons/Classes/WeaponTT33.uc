//===============================================================================
//  [ TT33 ]
// Firing modes:
//	semi-auto
//===============================================================================

class WeaponTT33 extends WeaponAutomaticPistol;

defaultproperties
{
     PlayerCrouchViewOffset=(X=0.100000,Y=3.550000,Z=-15.150000)
     PlayerAimViewOffset=(X=-6.200000,Y=0.750000,Z=-13.950000)
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
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="TT33Outdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="TT33NP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="PistolUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="PistolEquip")
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
     fCriticalHitPercent=0.300000
     WeaponAnimationFrameCount(0)=9.000000
     WeaponAnimationFrameCount(2)=102.000000
     WeaponAnimationFrameCount(3)=13.000000
     WeaponAnimationFrameCount(4)=11.000000
     MultiplayerDamage=35.000000
     m_meleeHitSound="MeleeSmallWeapon"
     m_melee3DHitSound="MeleeSmallWeapon3D"
     AmmoName=Class'VietnamWeapons.Ammo762WP'
     ReloadCount=8
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     bDrawMuzzleFlash=True
     MFTextureName="effects_tex.MuzzleFlash.MuzzleflashPistol_tex"
     MFMinScale=0.040000
     MFMaxScale=0.060000
     bMFRandomRotation=True
     MeshName="USMC_Viewmodels.fps_tt33"
     InventoryGroup=11
     PickupType="PickupTT33"
     PlayerViewOffset=(X=-5.500000,Y=1.800000,Z=-15.150000)
     PlayerHorizSplitViewOffset=(X=0.100000,Y=3.550000,Z=-14.150000)
     PlayerVertSplitViewOffset=(X=0.100000,Y=3.550000,Z=-15.150000)
     ThirdPersonRelativeLocation=(X=9.000000,Y=-5.000000,Z=-3.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponTT33Attachment'
     ItemName="TT33"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
