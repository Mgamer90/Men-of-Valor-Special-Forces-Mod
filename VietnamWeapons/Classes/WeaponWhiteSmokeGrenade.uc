//===============================================================================
//  [ WeaponWhiteSmokeGrenade ]
//===============================================================================

class WeaponWhiteSmokeGrenade extends WeaponBaseGrenade;

// FIXME
/*
// Specific function for weapons to precache first person specific assets
simulated static function StaticPreCacheFPAssets(Object MyLevel)
{
	Super.StaticPreCacheFPAssets(MyLevel);

	DynamicLoadObject("weapons_tex.us_grenade_smoke.grenade_smoke_white_Shade",class'Shader');
}
*/

// Yes, I know I'm appropriating this function for non-hand texture related purposes,
// but this has to ship tonight!
simulated function ApplyHandTexture( VietnamPawn.HandTextureEnum inHandTexture )
{
	Super.ApplyHandTexture(inHandTexture);

	Skins[1]=Material(DynamicLoadObject("weapons_tex.us_grenade_smoke.grenade_smoke_white_Shade",class'Shader'));
}

defaultproperties
{
     PlayerCrouchViewOffset=(X=17.900000,Y=2.900000,Z=-16.100000)
     PlayerAimViewOffset=(X=17.900000,Y=2.900000,Z=-16.100000)
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
     PreferredWeaponMenuIndex=1
     AmmoName=Class'VietnamWeapons.AmmoWhiteSmokeGrenade'
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MeshName="USMC_Viewmodels.fps_smokenade"
     InventoryGroup=28
     PickupType="PickupWhiteSmokeGrenade"
     PlayerViewOffset=(X=17.900000,Y=2.900000,Z=-16.100000)
     PlayerHorizSplitViewOffset=(X=17.900000,Y=2.900000,Z=-16.100000)
     PlayerVertSplitViewOffset=(X=17.900000,Y=2.900000,Z=-16.100000)
     ThirdPersonRelativeLocation=(X=15.000000,Y=-6.000000,Z=-8.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponWhiteSmokeGrenadeAttachment'
     ItemName="White Smoke Grenade"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
