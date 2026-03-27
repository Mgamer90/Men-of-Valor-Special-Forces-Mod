//===============================================================================
//  [ M1 ]
// Firing modes:
//	single shot
//  auto
//===============================================================================

class WeaponCAR15Jamie extends VietnamWeapon;

simulated function RegisterPlayer(bool bBotOrNot)
{
	Super.RegisterPlayer(bBotOrNot);

	if(bBotControlled)
		WeaponMode = EWM_Auto;
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

defaultproperties
{
     PlayerCrouchViewOffset=(X=9.750000,Y=1.350000,Z=-14.550000)
     PlayerAimViewOffset=(X=3.000000,Y=-3.000000,Z=-12.900000)
     Magnification=1.400000
     Accuracy=0.000000
     Recoil=150.000000
     m_maximumRecoil=750.000000
     Damage=17.500000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     MuzzleClass=Class'VietnamGame.BaseFPMuzzleFlash'
     bFiresTracerRounds=True
     iRoundsPerTracer=2
     WeaponMode=EWM_Auto
     bBurstCapable=True
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="CAR15Outdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="CAR15NP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(5)=(PackageName="weapon_snd",ResourceName="AK47SemiAutoSelect")
     AutoFireSpeed=0.700000
     SemiAutoSpeed=0.500000
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
     bDoubleShortRangeDamage=True
     ShellEjectMeshName="weapons_stat.shells.shell_556_stat"
     ForceFeedbackEffect="Fire gun"
     bAllowWeaponSwitch=False
     fCriticalHitPercent=0.250000
     MultiplayerDamage=17.500000
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
     MeshName="USMC_Viewmodels.fps_car15_Jamie"
     InventoryGroup=27
     PickupType="PickupCAR15Jamie"
     PlayerViewOffset=(X=9.750000,Y=1.350000,Z=-14.550000)
     PlayerHorizSplitViewOffset=(X=9.750000,Y=1.350000,Z=-14.550000)
     PlayerVertSplitViewOffset=(X=9.750000,Y=1.350000,Z=-14.550000)
     ThirdPersonRelativeLocation=(X=5.000000,Y=-6.000000,Z=-4.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponCAR15JamieAttachment'
     ItemName="CAR15"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
