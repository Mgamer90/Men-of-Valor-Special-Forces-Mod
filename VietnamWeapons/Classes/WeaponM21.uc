//===============================================================================
//  [ M21 ]
// Firing modes:
//	semi-auto
//  auto
// NOTE: Doesn't support bayonet anymore
//===============================================================================

class WeaponM21 extends VietnamWeapon;


simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	OverlayTexture = Material(DynamicLoadObject( "interface_tex.SCOPE.Scope_FinalBlend",class'Material'));
}

// Overridden to play 'bayonet_Reload' animation
simulated function PlayReloading()
{
	local PlayerController PController;
	local Float            animationLength, animationRate, frames, rate;

	PController = PlayerController(Instigator.Controller);
	if(PController != NONE && WeaponSounds[
		EWeaponSound.EWS_Reload ] != NONE )
	{
		PController.ClientPlaySound( WeaponSounds[
			EWeaponSound.EWS_Reload ] );
	}

	if(UseAnimTimer())
	{
		WeaponAnimTimer(WeapAnim_Reload, FIRING_ANIMATION_CHANNEL, 1.0);
		
		animationLength = ComputeWeaponAnimTimerLength( WeapAnim_Reload, 1.0 );
		animationRate   = 1.0f;
	}
	else	// play the first person animation
	{
		PlayAnim( 'bayonet_Reload', GetReloadAnimationRate( ), 0.05,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_RELOAD_TWEEN_TIME,
			WEAPON_RELOAD_TWEEN_TIME, );

		GetAnimSequenceParams( 'bayonet_Reload', frames, rate );
		animationLength = frames / rate;
		animationRate   = GetReloadAnimationRate( );
	}

	// third person anims
	Instigator.PlayReload( animationLength, animationRate );
}

// overloaded:  has special putaway animations when
// equipped with the bayonet
//
// inputs:
// -- none --
//
// outputs:
// name of the animation to play
simulated function Name GetPutAwayAnimationName( )
{
	return 'bayonet_putaway';
}

// overloaded:  uses a different takeout if the
// bayonet is attached
//
// inputs:
// -- none --
//
// outputs:
// name of the animation to play
simulated function Name ResolveTakeoutAnimation( )
{
	return 'bayonet_takeout';
}

// returns the Name of the idle animation to play
//
// inputs:
// -- none --
//
// outputs:
// animation Name
Simulated Function Name GetIdleAnimationName( )
{
	return 'Bayonet_idle';
}

// Should be implemented by individual weapons which use bDisplayAmmoType==false
simulated function string GetCurrentWeaponModeName()
{
	return SemiAutoString;
}

// Give a little kick
simulated function EnterAimMode()
{
	shakemag=350.000000;
	shaketime=1.200000;
	shakevert=vect(0.0,0.0,6.00000);
	shakespeed=vect(100.0,100.0,100.0);

	Accuracy = -200;

	bRenderOverlay = true;
}

// restores the default aiming characteristics
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment)
simulated function RestoreAimingDefaults( )
{
	shakemag = Default.shakemag;
	shaketime = Default.shaketime;
	shakevert = Default.shakevert;
	shakespeed = Default.shakespeed;

	Accuracy = Default.Accuracy;

	bRenderOverlay = false;
}

// Remove kick
simulated function ExitAimMode()
{
	RestoreAimingDefaults( );
}

// overloaded:  turns off the overlay and
// aiming enhancements for the sniper mode
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
	RestoreAimingDefaults( );
	
	return Super.DropFrom( StartLocation, StartRotation, bDropAmmo );
}

static function StaticPrecacheAssets(optional Object MyLevel)
{
	Super.StaticPrecacheAssets(MyLevel);

	DynamicLoadObject("interface_tex.SCOPE.Scope_FinalBlend",class'Material');
	DynamicLoadObject("weapons_stat.us.m21_scope_stat",class'StaticMesh');
}

simulated function PrecacheAssets()
{
	Super.PrecacheAssets();

	DynamicLoadObject("interface_tex.SCOPE.Scope_FinalBlend",class'Material');
	DynamicLoadObject("weapons_stat.us.m21_scope_stat",class'StaticMesh');
}

defaultproperties
{
     PlayerCrouchViewOffset=(X=9.750000,Y=2.150000,Z=-15.650000)
     PlayerAimViewOffset=(X=-3.500000,Y=-4.050000,Z=-14.050000)
     ROF=2.000000
     Magnification=8.000000
     Accuracy=0.000000
     Recoil=200.000000
     m_maximumRecoil=750.000000
     Damage=60.000000
     RecoilDampeningRate=500.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     bUsePrecisionAimOverlay=True
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="M21Outdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="M21NP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(5)=(PackageName="weapon_snd",ResourceName="AK47SemiAutoSelect")
     SemiAutoSpeed=1.000000
     m_fViewYawKick=125.000000
     m_fViewPitchKick=400.000000
     m_fViewDegradeYaw=1024.000000
     m_fViewDegradePitch=1024.000000
     m_fViewKickMaxYawDelta=8192.000000
     m_fViewKickMaxPitchDelta=16384.000000
     MinTurnRateScale=0.550000
     TurnRateRampPower=10.000000
     AimAssistAngle=20.000000
     MinPrecisionTurnRateScale=0.500000
     PrecisionTurnRateRampPower=10.000000
     PrecisionAimAssistAngle=10.000000
     MinScreenPercent=0.000050
     m_basicFiringAnimation="Bayonet_Fire"
     ShellEjectMeshName="weapons_stat.shells.shell_556_stat"
     ForceFeedbackEffect="Fire gun"
     fCriticalHitPercent=0.600000
     WeaponAnimationFrameCount(0)=10.000000
     WeaponAnimationFrameCount(2)=114.000000
     WeaponAnimationFrameCount(3)=24.000000
     WeaponAnimationFrameCount(4)=20.000000
     MultiplayerDamage=60.000000
     AmmoName=Class'VietnamWeapons.AmmoM21'
     ReloadCount=20
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeTime=0.000000
     ShakeVert=(Z=0.000000)
     ShakeSpeed=(X=0.000000,Y=0.000000,Z=0.000000)
     MaxRange=15000.000000
     MeshName="USMC_Viewmodels.fps_m21"
     InventoryGroup=3
     PickupType="PickupM21"
     PlayerViewOffset=(X=9.750000,Y=2.150000,Z=-15.650000)
     PlayerHorizSplitViewOffset=(X=9.750000,Y=2.150000,Z=-15.100000)
     PlayerVertSplitViewOffset=(X=9.750000,Y=2.150000,Z=-15.650000)
     ThirdPersonRelativeLocation=(X=13.000000,Y=-6.000000,Z=8.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponM21Attachment'
     ItemName="M21"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
