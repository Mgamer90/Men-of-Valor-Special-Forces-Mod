//===============================================================================
//  [ PU ]
// Firing modes:
//	semi-auto
//  auto
//===============================================================================

class WeaponPU extends VietnamWeapon;

// since this constant is used in two
// different function calls, make sure
// the functions will agree on the value
const SIZE_OF_PU_CLIP_WHEN_DROPPED = 2;

var int iNeedToReloadCount;	// Holds amount to reload when reloading for client

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	OverlayTexture = Material(DynamicLoadObject( "interface_tex.SCOPE.Scope_FinalBlend",class'Material'));
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

simulated state Reloading
{
	ignores Fire, AltFire, ServerForceReload, ClientForceReload;

	function bool IsReloading()
	{
		return true;
	}

	function ServerFire()
	{
		bForceFire = true;
	}

	function ServerAltFire()
	{
		bForceAltFire = true;
	}

	// We now allow a weapon change during reloading
	simulated function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

	simulated function ReloadComplete()
	{
//		DoReload();
		
		CheckForLowAmmo();

		GotoState('Idle');
/*
		if ( Role < ROLE_Authority )
			ClientFinish();
		else
			Finish();
*/
		CheckAnimating();
	}

	simulated function AnimEnd(int Channel){}

	function CheckAnimating()
	{
		if ( !IsAnimating() )
			warn(self$" stuck in Reloading and not animating!");
	}

	simulated function PlayReloadingSound()
	{
		local PlayerController PController;

		PController = PlayerController(Instigator.Controller);
		if(PController?)
			PController.ClientPlaySound(WeaponSounds[EWeaponSound.EWS_Reload]);
	}

	// plays the reload begin animation
	// for the instigator
	//
	// inputs:
	// -- none --
	//
	// outputs:
	// -- none -- (code segment)
	simulated function InstigatorPlayReloadStart( )
	{
		Instigator.PlayAnim( 'TH_Ab_PU_Reload_start',
			1.0f, 0.0f, Instigator.FIRINGCHANNEL );
		Instigator.AnimBlendParams( Instigator.FIRINGCHANNEL,
			1.0f, , , 'Bip_Spine1' );
	}
	
	// plays the reload "load one bullet"
	// animation for the instigator
	//
	// inputs:
	// -- none --
	//
	// outputs:
	// -- none -- (code segment)
	simulated function InstigatorPlayReloadLoad( )
	{
		Instigator.PlayAnim( 'TH_Ab_PU_Reload_load',
			1.0f, 0.0f, Instigator.FIRINGCHANNEL );
		Instigator.AnimBlendParams( Instigator.FIRINGCHANNEL,
			1.0f, , , 'Bip_Spine1' );
	}

	// plays the reload end animation
	// for the instigator
	//
	// inputs:
	// -- none --
	//
	// outputs:
	// -- none -- (code segment)
	simulated function InstigatorPlayReloadEnd( )
	{
		Instigator.PlayAnim( 'TH_Ab_PU_Reload_end',
			1.0f, 0.0f, Instigator.FIRINGCHANNEL );
		Instigator.AnimBlendParams( Instigator.FIRINGCHANNEL,
			1.0f, , , 'Bip_Spine1' );
	}

Begin:
	// Play local sound
	PlayReloadingSound( );

	// figure out how much to reload
	iNeedToReloadCount = default.ReloadCount - ReloadCount;

	// Bots use the anim timer, players use the complex reload
	if(UseAnimTimer())
	{
		// trigger the animation
		Instigator.PlayReload( ComputeWeaponAnimTimerLength(
			WeapAnim_Reload, 1.0 ), 1.0f );

		// set a timer to wake us up when the
		// reloading is done
		WeaponAnimTimer(WeapAnim_Reload, FIRING_ANIMATION_CHANNEL, 1.0);
	}
	else
	{
		InstigatorPlayReloadStart( );
		
		PlayAnim('reload_start', 1.0, 0.0, FIRING_ANIMATION_CHANNEL);
		WaitForAnimation(FIRING_ANIMATION_CHANNEL);
	}

ReloadShot:
	if(!bBotControlled)
	{
		InstigatorPlayReloadLoad( );
		
		PlayAnim('reload_load', 1.0, 0.0, FIRING_ANIMATION_CHANNEL);
		WaitForAnimation(FIRING_ANIMATION_CHANNEL);
	}
	if(Role == ROLE_Authority)
	{
		ReloadCount++;
		if(!bBotControlled)
			AmmoType.AmmoAmount--;
	}

CheckReloadComplete:
	// Clientside, base off of iNeedToReloadCount variable
	if(Role < ROLE_Authority)
	{
		iNeedToReloadCount--;
		if(iNeedToReloadCount == 0)
			Goto('CloseBreach');
		else
			Goto('ReloadShot');	
	}
	else	// Serverside, use real authority values
	{
		// Check if we're done reloading or if we're out of ammo and can't reload
		if(ReloadCount == Default.ReloadCount || (!AmmoType.HasAmmo() && !bBotControlled))
			Goto('CloseBreach');
		else
			Goto('ReloadShot');
	}

CloseBreach:
	if(!bBotControlled)
	{
		InstigatorPlayReloadEnd( );
		
		PlayAnim('reload_end', 1.0, 0.0, FIRING_ANIMATION_CHANNEL);
		WaitForAnimation(FIRING_ANIMATION_CHANNEL);
	}
	ReloadComplete();
}

simulated function PlayFiring()
{
	local VietnamPlayerController VController;

	// Only play the non-positional sound if the controller is on this machine
	if(Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
	{
//		log("Playing first person fire sound");

		VController = VietnamPlayerController(Instigator.Controller);

		VController.PlayForceFeedbackEffect("Fire gun", 2);

		if( VController.IsInstancePlaying( FPFireVoices[FPFireVoiceIndex] ) )
		{
			VController.ClientStopRegisteredSound( FPFireVoices[FPFireVoiceIndex] );
		}
		VController.ClientPlayRegisteredSound(WeaponSoundNames[EWeaponSound.EWS_FPFire ].ResourceName,FPFireVoices[FPFireVoiceIndex]);

		FPFireVoiceIndex++;
		if(FPFireVoiceIndex == ArrayCount(FPFireVoices))
			FPFireVoiceIndex = 0;
	}

	// Always play the third person sound (which will replicate to clients), if this is
	// a locally controlled pawn the sound won't be heard

//	log("Playing third person fire sound");
	Instigator.RemoteStopRegisteredSound(TPFireVoices[TPFireVoiceIndex]);
	Instigator.RemotePlayRegisteredSound(WeaponSoundNames[EWeaponSound.EWS_TPFire].ResourceName, TPFireVoices[TPFireVoiceIndex]);

	TPFireVoiceIndex++;
	if(TPFireVoiceIndex == ArrayCount(TPFireVoices))
		TPFireVoiceIndex = 0;

	TriggerMuzzleFlashAttachment();
//	TriggerShellEjector();	// Performed by AnimNotify for PU
	if(WeaponMode==EWM_Auto)
	{
		PlayFiringAnimation(AutoFireSpeed);
	}
	else
	{
		ReadyToFire=false;
		PlayFiringAnimation(SemiAutoSpeed);
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

// overridden:  LDs don't want dropped PUs to have
// exactly 2 bullets
//
// inputs:
// -- none --
//
// outputs:
// Ammo count to set when dropped
simulated static function Int ComputeDefaultDroppedAmmoCount( )
{
	return SIZE_OF_PU_CLIP_WHEN_DROPPED;
}

// overridden:  PUs have a restricted
// clip when dropped by an enemy
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (event style function)
simulated function SetAmmoInClipWhenDropped( )
{
	// force the clip size to be smaller
	ReloadCount = SIZE_OF_PU_CLIP_WHEN_DROPPED;
}

/*
simulated function Spawned()
{
	Super.Spawned();

	NormalCrosshair=None;
	Crosshair=None;
	CrosshairNoShoot=None;
	SecondaryCrosshair=None;
	CrosshairFriendlyFire=None;

	if(MFTextureName?)
		MFTexture=Texture(DynamicLoadObject(MFTextureName,class'Texture'));		
}
*/

defaultproperties
{
     PlayerCrouchViewOffset=(X=11.550000,Y=-0.450000,Z=-15.650000)
     PlayerAimViewOffset=(X=3.900000,Y=-4.950000,Z=-14.000000)
     Magnification=8.000000
     Accuracy=0.000000
     Recoil=0.000000
     m_maximumRecoil=750.000000
     Damage=100.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     bUsePrecisionAimOverlay=True
     DelayAfterFire=1.000000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     MuzzleClass=Class'VietnamGame.BaseFPMuzzleFlash'
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
     m_fViewKickMaxYawDelta=1200.000000
     m_fViewKickMaxPitchDelta=1200.000000
     MinTurnRateScale=0.550000
     TurnRateRampPower=10.000000
     AimAssistAngle=20.000000
     MinPrecisionTurnRateScale=1.000000
     PrecisionTurnRateRampPower=10.000000
     PrecisionAimAssistAngle=10.000000
     MinScreenPercent=0.000050
     ShellEjectMeshName="weapons_stat.shells.shell_556_stat"
     ForceFeedbackEffect="Fire gun"
     fCriticalHitPercent=0.700000
     WeaponAnimationFrameCount(0)=38.000000
     WeaponAnimationFrameCount(2)=124.000000
     WeaponAnimationFrameCount(3)=22.000000
     WeaponAnimationFrameCount(4)=13.000000
     MultiplayerDamage=125.000000
     AmmoName=Class'VietnamWeapons.AmmoM21'
     ReloadCount=5
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeTime=0.000000
     ShakeVert=(Z=0.000000)
     ShakeSpeed=(X=0.000000,Y=0.000000,Z=0.000000)
     MaxRange=15000.000000
     bDrawMuzzleFlash=True
     MFTextureName="effects_tex.MuzzleFlash.MuzzleflashPistol_tex"
     bMFRandomRotation=True
     specificReloadAnim="TH_Ab_PU_Reload_empty"
     MeshName="USMC_Viewmodels.fps_mosinnagant"
     InventoryGroup=24
     PickupType="PickupPU"
     PlayerViewOffset=(X=11.550000,Y=-0.450000,Z=-15.650000)
     PlayerHorizSplitViewOffset=(X=11.550000,Y=-0.450000,Z=-15.650000)
     PlayerVertSplitViewOffset=(X=11.550000,Y=-0.450000,Z=-15.650000)
     ThirdPersonRelativeLocation=(X=13.000000,Y=-6.000000,Z=8.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponPUAttachment'
     ItemName="PU"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
