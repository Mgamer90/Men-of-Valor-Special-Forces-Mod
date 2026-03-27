//===============================================================================
//  [ Satchel Charge ]
//===============================================================================

class WeaponSatchelCharge extends VietnamWeapon;

// Play takeout anim as reload anim
simulated function PlayReloading()
{
	local PlayerController PController;

	PlayAnim( 'takeout', 1.0, 0.0,
		FIRING_ANIMATION_CHANNEL);
	AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
		, , , , WEAPON_RELOAD_TWEEN_TIME,
		WEAPON_RELOAD_TWEEN_TIME, );
	PController = PlayerController(Instigator.Controller);
	if(PController?)
		PController.ClientPlaySound(WeaponSounds[EWeaponSound.EWS_Reload]);
}

// Instead of a projectile, this places a satchel charge
// TODO: Put on AnimNotify instead?
function ProjectileFire()
{

}

// overridden:  has special put aways
//
// inputs:
// -- none --
//
// outputs:
// name of the animation to play
simulated function Name GetPutAwayAnimationName( )
{
	if (!HasAmmo())
	{
		return 'nothing';
	}
	// else....
	
	return Super.GetPutAwayAnimationName();
}

// Should be implemented by individual weapons which use bDisplayAmmoType==false
simulated function string GetCurrentWeaponModeName()
{
	// Mode name is too long to coexist with weapon name
	return "";
}

// Called by AnimNotify
function SpawnC4()
{
	local vector Forward, Right, Up;
	local vector SpawnPoint;
	local rotator SpawnRotation;
	local C4Trigger PlacedC4;
	local int iCounter;

	GetAxes(Instigator.Rotation, Forward, Right, Up);

	// Spawn a little down and forward from the player
	SpawnPoint = Instigator.Location + Forward * 30 - Up * 30;

	SpawnRotation.Roll = -16768;
	SpawnRotation.Yaw = Owner.Rotation.Yaw + 16768;

	PlacedC4 = Spawn(class'VietnamWeapons.C4Trigger',self.Owner,,SpawnPoint, SpawnRotation);
	PlacedC4.SetPhysics(PHYS_Falling);
	PlacedC4.fUseTime = 3.0;	// For disarming purposes
	PlacedC4.bResettable = false;
	PlacedC4.Triggered( Instigator );
	PlacedC4.bBlockActors = true;	// Prevent it from falling through bridges

	if(Instigator.PlayerReplicationInfo.Team?)
		PlacedC4.AllowedTeam = Instigator.PlayerReplicationInfo.Team.TeamIndex;
	else
		PlacedC4.AllowedTeam = 255;

	PlacedC4.bRestrictPlayerTeam = true;
}

simulated function Timer()
{
	VietnamHUD( PlayerController(Instigator.Controller).MyHUD ).RecieveUsageMessage( "" );
}

// Weapon needs to auto-reload
state NormalFire
{
	ignores ForceReload, ClientMeleeAttack, LocalStartFire;

	simulated function FiringAnimEndTimer()
	{
		if(CanReload())
			GotoState('Reloading');
		else
		{
			GotoState('Idle');
		}
	}
}

state Active
{
	simulated function EndState()
	{
		Super.EndState( );
		if ( HasAmmo( ) )
		{
			DoReload();		// This prevents us from bringing up the 
							// satchel charge in active and *THEN* bringing it up again
							// to "reload"
		}
	}
}

state Idle
{
	simulated function BeginState( )
	{
		// do the parent stuff first
		Super.BeginState( );

		if(!HasAmmo())
		{
			// Destroy weapon on server
			if(ROLE == Role_Authority)
				Destroy();
		}
	}
}

simulated function Destroyed()
{
	// Have player switch to another weapon
	if(Instigator? && Instigator.IsLocallyControlled() && Instigator.Weapon == self)
	{
		if(Instigator.Controller.IsInPreciseAimMode())
			VietnamPlayerController(Instigator.Controller).StopPreciseAim();

		Instigator.Weapon = None;
		VietnamPlayerController(Instigator.Controller).ForceSwitchToBestWeapon();
	}

	Super.Destroyed();
}

// overloaded:  needs ammo to proceed
//
// inputs:
// CurrentChoice - the currently selected weapon
//
// outputs:
// -- none -- (code segment)
simulated function SelectNextWeapon(
	out Weapon CurrentChoice, Weapon CurrentWeapon )
{
	if ( HasAmmo( ) )
	{
		Super.SelectNextWeapon(
			CurrentChoice, CurrentWeapon );
	}
}

// overloaded:  needs ammo to proceed
//
// inputs:
// CurrentChoice - the currently selected weapon
//
// outputs:
// -- none -- (code segment)
simulated function SelectPreviousWeapon(
	out Weapon CurrentChoice, Weapon CurrentWeapon )
{
	if ( HasAmmo( ) )
	{
		Super.SelectPreviousWeapon(
			CurrentChoice, CurrentWeapon );
	}
}

defaultproperties
{
     PlayerCrouchViewOffset=(X=13.300000,Y=-7.050000,Z=-17.750000)
     PlayerAimViewOffset=(X=13.300000,Y=-7.050000,Z=-17.750000)
     Magnification=1.300000
     Accuracy=25.000000
     Recoil=0.000000
     m_maximumRecoil=750.000000
     AimImprovementRate=0.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     iRoundsPerTracer=2
     WeaponGrip=EWG_Grenade
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     AutoFireSpeed=0.700000
     SemiAutoSpeed=0.400000
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
     PrecisionAimAssistAngle=20.000000
     MinScreenPercent=0.000100
     fCriticalHitPercent=0.300000
     WeaponAnimationFrameCount(0)=2.000000
     WeaponAnimationFrameCount(1)=6.000000
     WeaponAnimationFrameCount(2)=117.000000
     WeaponAnimationFrameCount(3)=43.000000
     WeaponAnimationFrameCount(4)=14.000000
     MultiplayerDamage=40.000000
     bCanUseRedCrosshair=False
     AmmoName=Class'VietnamWeapons.AmmoSatchelCharge'
     ReloadCount=1
     bExcludeFromWeapSwap=True
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MaxRange=10000.000000
     bMFRandomRotation=True
     MeshName="USMC_Viewmodels.fps_Satchel"
     InventoryGroup=29
     PickupType="PickupSatchelCharge"
     PlayerViewOffset=(X=13.300000,Y=-7.050000,Z=-17.750000)
     PlayerHorizSplitViewOffset=(X=13.300000,Y=-7.050000,Z=-17.750000)
     PlayerVertSplitViewOffset=(X=13.300000,Y=-7.050000,Z=-17.750000)
     ThirdPersonRelativeLocation=(X=7.000000,Y=-5.000000,Z=-3.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponSatchelChargeAttachment'
     ItemName="Satchel Charge"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
