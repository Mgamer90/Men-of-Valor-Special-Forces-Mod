//===============================================================================
//  [ M1 ]
// Firing modes:
//	single shot
//  auto
//===============================================================================

class WeaponM1Commander extends VietnamWeapon;

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
}

defaultproperties
{
     PlayerCrouchViewOffset=(X=14.650000,Y=1.800000,Z=-13.750000)
     PlayerAimViewOffset=(X=9.000000,Y=-1.400000,Z=-13.250000)
     Magnification=1.400000
     Accuracy=160.000000
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
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="ThompsonOutdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="ThompsonNP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(5)=(PackageName="weapon_snd",ResourceName="AK47SemiAutoSelect")
     AutoFireSpeed=0.700000
     SemiAutoSpeed=0.400000
     MHEType=EMHE_Small
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
     MinScreenPercent=0.000150
     m_basicFiringAnimation="Fire_start"
     bUsesFireEnd=True
     ShellEjectMeshName="weapons_stat.shells.shell_stat"
     ForceFeedbackEffect="Fire gun"
     bAllowWeaponSwitch=False
     fCriticalHitPercent=0.200000
     MultiplayerDamage=35.000000
     AmmoName=Class'VietnamWeapons.Ammo45Cal'
     ReloadCount=30
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MaxRange=6000.000000
     bDrawMuzzleFlash=True
     MFTextureName="effects_tex.MuzzleFlash.MuzzleflashPistol_tex"
     MFMinScale=0.040000
     MFMaxScale=0.060000
     bMFRandomRotation=True
     MeshName="USMC_Viewmodels.fps_Thompson_commander"
     InventoryGroup=25
     PickupType="PickupM1Commander"
     PlayerViewOffset=(X=14.650000,Y=1.800000,Z=-13.750000)
     PlayerHorizSplitViewOffset=(X=14.650000,Y=1.800000,Z=-12.750000)
     PlayerVertSplitViewOffset=(X=14.650000,Y=1.800000,Z=-13.750000)
     ThirdPersonRelativeLocation=(X=7.000000,Y=-8.000000,Z=-2.000000)
     ThirdPersonRelativeRotation=(Yaw=17500)
     AttachmentClass=Class'VietnamWeapons.WeaponM1CommanderAttachment'
     ItemName="M1"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
