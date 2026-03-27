//===============================================================================
//  [ Type63 ]
// Firing modes:
//	semi-auto
//  auto
//===============================================================================

class WeaponType63 extends WeaponSKS;

/*simulated function RegisterPlayer(bool bBotOrNot)
{
	Super.RegisterPlayer(bBotOrNot);

	if(bBotControlled)
		WeaponMode = EWM_Auto;
}

function ServerAltFire()
{
	VietnamPawn(Instigator).EndSpawnInvulnerability();

	if(WeaponMode==EWM_Semiauto)
	{
		WeaponMode=EWM_Auto;
	}
	else
	{
		WeaponMode=EWM_Semiauto;
	}

	if(!Instigator.Controller.IsInPreciseAimMode())
		GotoState('ModeSwitch');
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
}*/

defaultproperties
{
     PlayerCrouchViewOffset=(X=10.300000,Y=0.200000,Z=-15.450000)
     PlayerAimViewOffset=(X=5.800000,Y=-3.150000,Z=-15.450000)
     Magnification=1.600000
     Accuracy=0.000000
     m_maximumRecoil=750.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     MuzzleClass=Class'VietnamGame.BaseFPMuzzleFlash'
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="SKSOutdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="SKSNP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(5)=(PackageName="weapon_snd",ResourceName="AK47SemiAutoSelect")
     WeaponSoundNames(6)=(PackageName="weapon_snd",ResourceName="BayonetEquip")
     WeaponSoundNames(7)=(PackageName="weapon_snd",ResourceName="BaynetUnequip")
     SemiAutoSpeed=0.800000
     m_fViewYawKick=64.000000
     m_fViewPitchKick=275.000000
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
     bCanOnlyReloadWhenEmpty=True
     ShellEjectMeshName="weapons_stat.shells.sks_shell_stat"
     ForceFeedbackEffect="Fire gun"
     fCriticalHitPercent=0.400000
     WeaponAnimationFrameCount(0)=10.000000
     WeaponAnimationFrameCount(2)=136.000000
     WeaponAnimationFrameCount(3)=52.000000
     WeaponAnimationFrameCount(4)=52.000000
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
     specificReloadAnim="Th_Ab_SKS_Reload"
     MeshName="USMC_Viewmodels.fps_sks"
     InventoryGroup=9
     PickupType="PickupSKS"
     PlayerViewOffset=(X=10.300000,Y=0.200000,Z=-15.450000)
     PlayerHorizSplitViewOffset=(X=10.300000,Y=0.200000,Z=-14.450000)
     PlayerVertSplitViewOffset=(X=10.300000,Y=0.200000,Z=-15.450000)
     ThirdPersonRelativeLocation=(X=13.000000,Y=-6.000000,Z=3.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponSKSAttachment'
     ItemName="SKS"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
