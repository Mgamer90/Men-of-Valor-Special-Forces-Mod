//===============================================================================
//  [ WeaponSmokeGrenade ]
//===============================================================================

class WeaponSmokeGrenade extends WeaponBaseGrenade;

// Triggered by an AnimNotify during 'throw' anim
function ThrowGrenade()
{
	local VietnamPlayerController VPC;

	if(bBotControlled)
		Super.ThrowGrenade();
	else if(Instigator.Controller?)
	{
		VPC = VietnamPlayerController(Instigator.Controller);
		if(VPC? && VPC.bCanThrowSmokeGrenade)
		{
			Super.ThrowGrenade();
			if(Level.GRI.IsMultiplayerTypeGame())
			{
				VPC.bCanThrowSmokeGrenade = false;
				//log("TSS: Grenade thrown, " $ VPC);
			}
			//else
				//log("Singleplayer, can always throw a smoke grenade");
		}
		else
		{
			//log("TSS: " $ VPC $ " is not allowed to throw a grenade at this time");
			// Put the grenade back into the ammo stockpile
			AmmoType.AddAmmo(1);
		}
	}
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
     PreferredWeaponMenuIndex=3
     AmmoName=Class'VietnamWeapons.AmmoSmokeGrenade'
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MeshName="USMC_Viewmodels.fps_smokenade"
     InventoryGroup=5
     PickupType="PickupSmokeGrenade"
     PlayerViewOffset=(X=17.900000,Y=2.900000,Z=-16.100000)
     PlayerHorizSplitViewOffset=(X=17.900000,Y=2.900000,Z=-16.100000)
     PlayerVertSplitViewOffset=(X=17.900000,Y=2.900000,Z=-16.100000)
     ThirdPersonRelativeLocation=(X=10.000000,Y=-6.000000,Z=-8.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponSmokeGrenadeAttachment'
     ItemName="Smoke Grenade"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
