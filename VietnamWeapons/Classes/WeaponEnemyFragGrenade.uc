//===============================================================================
//  [ FragGrenade ]
//===============================================================================

class WeaponEnemyFragGrenade extends WeaponBaseGrenade;

state HoldingGrenade
{
	ignores Fire, ForceReload;

	// Other grenades can have their pin put back in, but not this grenade
	simulated function AltFire( float Value )
	{
		// Zippo...
	}

	function ServerAltFire()
	{
		// Zippo...
	}
}

defaultproperties
{
     m_maximumRecoil=0.000000
     PrecisionAimTransitionTime=0.200000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(6)=(PackageName="weapon_snd",ResourceName="GrenadePinPull")
     WeaponSoundNames(7)=(PackageName="weapon_snd",ResourceName="GrenadeThrow")
     m_fViewPitchKick=0.000000
     m_fViewDegradeYaw=0.000000
     m_fViewDegradePitch=0.000000
     m_fViewKickMaxYawDelta=0.000000
     m_fViewKickMaxPitchDelta=0.000000
     MinTurnRateScale=0.550000
     TurnRateRampPower=10.000000
     AimAssistAngle=20.000000
     MinPrecisionTurnRateScale=0.350000
     PrecisionTurnRateRampPower=10.000000
     PrecisionAimAssistAngle=10.000000
     MinScreenPercent=0.000050
     PreferredWeaponMenuIndex=3
     AmmoName=Class'VietnamWeapons.AmmoEnemyFragGrenade'
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MeshName="USMC_Viewmodels.fps_stickgrenade"
     InventoryGroup=26
     PickupType="PickupEnemyFragGrenade"
     PlayerHorizSplitViewOffset=(X=16.950001,Y=2.850000,Z=-15.000000)
     PlayerVertSplitViewOffset=(X=16.950001,Y=2.850000,Z=-16.500000)
     ThirdPersonRelativeLocation=(X=9.000000,Y=-4.000000,Z=-4.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponEnemyFragGrenadeAttachment'
     ItemName="Stick Grenade"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
