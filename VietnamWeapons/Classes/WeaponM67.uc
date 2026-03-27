//===============================================================================
//  [ WeaponM67 ]
// Rocket launcher
// Firing modes:
//	semi-auto
//===============================================================================

class WeaponM67 extends VietnamWeapon;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	OverlayTexture = Material(DynamicLoadObject( "interface_tex.SCOPE.Scope_FinalBlend",class'Material'));
}

// Overridden to do auto-reloading, could be moved into a variable
state NormalFire
{
	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			if(CanReload())
			{
				GotoState('Reloading');
			}
			else
				GotoState('Idle');

			CheckAnimating();
		}
	}
}

static function StaticPrecacheAssets(optional Object MyLevel)
{
	Super.StaticPrecacheAssets(MyLevel);

	DynamicLoadObject("interface_tex.SCOPE.Scope_FinalBlend",class'Material');
}

function PrecacheAssets()
{
	Super.PrecacheAssets();

	DynamicLoadObject("interface_tex.SCOPE.Scope_FinalBlend",class'Material');
}

simulated function EnterAimMode()
{
	bRenderOverlay = true;
}

simulated function ExitAimMode()
{
	bRenderOverlay = false;
}

// overloaded:  turns off the aiming overlay
//
// inputs:
// StartLocation - initial location to spawn at
// StartRotation - initial rotation
// bDropAmmo     - also drop my ammo
//
// outputs:
// -- none --
function Pickup DropFrom(vector StartLocation, optional rotator StartRotation, optional bool bDropAmmo)
{
	bRenderOverlay = false;
	
	return Super.DropFrom( StartLocation, StartRotation, bDropAmmo );
}

defaultproperties
{
     PlayerCrouchViewOffset=(X=10.900000,Y=9.000000,Z=-14.350000)
     PlayerAimViewOffset=(X=1.000000,Y=7.250000,Z=-13.000000)
     Magnification=1.600000
     Accuracy=0.000000
     Recoil=0.000000
     m_maximumRecoil=750.000000
     Damage=0.000000
     AILeadDistance=768.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     bUsePrecisionAimOverlay=True
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     fMinimumDistance=1550.000000
     WeaponGrip=EWG_SpecialHanded_M67
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="M67Outdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="M67NP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     SemiAutoSpeed=1.000000
     m_pawnTakeoutAnimation="SH_M67_Ab_takeout"
     m_pawnStowAnimation="SH_M67_Ab_putaway"
     m_fViewYawKick=700.000000
     m_fViewPitchKick=4096.000000
     m_fViewKickMaxYawDelta=16384.000000
     m_fViewKickMaxPitchDelta=32768.000000
     MinTurnRateScale=0.550000
     TurnRateRampPower=10.000000
     AimAssistAngle=20.000000
     MinPrecisionTurnRateScale=0.500000
     PrecisionTurnRateRampPower=10.000000
     PrecisionAimAssistAngle=20.000000
     MinScreenPercent=0.000050
     ForceFeedbackEffect="Fire gun"
     WeaponAnimationFrameCount(0)=36.000000
     WeaponAnimationFrameCount(2)=271.000000
     WeaponAnimationFrameCount(3)=28.000000
     WeaponAnimationFrameCount(4)=33.000000
     PreferredWeaponMenuIndex=4
     m_meleeHitSound="MeleeFistHit"
     m_melee3DHitSound="MeleeFistHit3D"
     AmmoName=Class'VietnamWeapons.AmmoM67'
     ReloadCount=1
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MeshName="USMC_Viewmodels.fps_M67"
     InventoryGroup=18
     PickupType="PickupM67"
     PlayerViewOffset=(X=10.900000,Y=9.000000,Z=-14.350000)
     PlayerHorizSplitViewOffset=(X=10.900000,Y=9.000000,Z=-14.350000)
     PlayerVertSplitViewOffset=(X=10.900000,Y=9.000000,Z=-14.350000)
     ThirdPersonRelativeLocation=(X=11.000000,Y=-7.000000,Z=1.000000)
     ThirdPersonRelativeRotation=(Pitch=-3000,Yaw=-11000,Roll=16384)
     AttachmentClass=Class'VietnamWeapons.WeaponM67Attachment'
     ItemName="M67"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
