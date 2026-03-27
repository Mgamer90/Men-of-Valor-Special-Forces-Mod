//===============================================================================
//  [ WeaponRPG7 ]
// Rocket launcher
// Firing modes:
//	semi-auto
//===============================================================================

class WeaponRPG7 extends VietnamWeapon;

// the length of time to wait before revealing
// the rocket model in the third person actor
const UNHIDE_ROCKET_RELOAD_DELAY = 2.4f;

// overloaded:  uses a special animation
// when the weapon is empty
//
// inputs:
// -- none --
//
// outputs:
// animation Name
Simulated Function Name GetIdleAnimationName( )
{
	if ( ReloadCount == 1  || bClientPreventReload)
	{
		return Super.GetIdleAnimationName( );
	}
	// else....

	return 'idle_empty';
}

// overloaded:  plays a special takeout when out
// of ammo(?)
//
// inputs:
// -- none --
//
// outputs:
// name of the animation to play
simulated function Name ResolveTakeoutAnimation( )
{
	if ( ReloadCount == 1 )
	{
		return Super.ResolveTakeoutAnimation( );
	}
	// else....

	return 'takeout_empty';
}

// overloaded:  uses a different putaway when
// the gun is empty
//
// inputs:
// -- none --
//
// outputs:
// name of the animation to play
simulated function Name GetPutAwayAnimationName( )
{
	if (ReloadCount == 1 )
	{
		return Super.GetPutAwayAnimationName( );
	}
	// else....
	
	return 'putaway_empty';
}

// overloaded to catch the end of the reload
state Reloading
{
	// overloaded:  turns back on the rocket model
	//
	// inputs:
	// -- none --
	//
	// outputs:
	// -- none --
	simulated function BeginState( )
	{
		// do the parent stuff first
		Super.BeginState( );
		
		// then set a timer to turn back on the
		// rocket model
		SetDelegateTimer( 'ShowRocket',
			UNHIDE_ROCKET_RELOAD_DELAY, false );
	}

}


// reveals the rocket model (timer function)
//
// inputs:
// -- none --
//
// outputs:
// -- none --
simulated function ShowRocket( )
{
	local WeaponRPG7Attachment myAttachment;

	// now turn on the rocket model
	myAttachment = WeaponRPG7Attachment( ThirdPersonActor );
	if ( myAttachment? )
	{
		myAttachment.ShowRocket( );
	}
}


// Overridden to do auto-reloading, could be moved into a variable
state NormalFire
{
	// overloaded:  turns off the rocket model
	// when the projectile launches
	//
	// inputs:
	// -- none --
	//
	// outputs:
	// -- none -- (code segment?)
	function ProjectileFire( )
	{
		local WeaponRPG7Attachment myAttachment;

		// do the parent stuff first
		Super.ProjectileFire( );
		
		// then turn off the rocket model
		myAttachment = WeaponRPG7Attachment( ThirdPersonActor );
		if ( myAttachment? )
		{
			myAttachment.HideRocket( );
		}
	}
}

state Melee
{
	simulated function BeginState()
	{
		local name MeleeAnimName;

		ReadyToFire = false;

		if(ReloadCount == 1)
		{
			MeleeAnimName = 'Buttstroke_loaded';
		}
		else
		{
			MeleeAnimName = 'Buttstroke';
		}

		PlayAnim( MeleeAnimName, 1.0, 0.05,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_ACTION_TWEEN_TIME,
			WEAPON_ACTION_TWEEN_TIME, );
			
		Instigator.PlayMeleeAttackAnimation( );

		// trigger the melee attack sound
		if(Instigator.IsLocallyControlled())
			ClientPlayRegisteredSound( MELEE_SWING_SOUND, 'melee_swing' );

		// Everyone but owner should hear 3D version, only make the call on server who
		// will rep it to all clients (except owner)
		if(Role==ROLE_Authority)
			Instigator.RemotePlayRegisteredSound( MELEE_SWING3D_SOUND, 'melee_swing3D' );
	}
}

defaultproperties
{
     PlayerCrouchViewOffset=(X=3.100000,Y=5.850000,Z=-14.350000)
     PlayerAimViewOffset=(X=-4.750000,Y=1.150000,Z=-14.350000)
     Magnification=1.400000
     Accuracy=0.000000
     Recoil=0.000000
     m_maximumRecoil=750.000000
     Damage=0.000000
     AILeadDistance=512.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     fMinimumDistance=1550.000000
     WeaponGrip=EWG_SpecialHanded
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="RPG7Outdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="RPG7NP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(5)=(PackageName="weapon_snd",ResourceName="AK47SemiAutoSelect")
     SemiAutoSpeed=1.000000
     m_pawnTakeoutAnimation="SH_Ab_takeout"
     m_pawnStowAnimation="SH_Ab_takeout_putaway"
     m_fViewYawKick=256.000000
     m_fViewPitchKick=1800.000000
     m_fViewDegradeYaw=1024.000000
     m_fViewDegradePitch=1024.000000
     m_fViewKickMaxYawDelta=8192.000000
     m_fViewKickMaxPitchDelta=16384.000000
     MinTurnRateScale=0.550000
     TurnRateRampPower=10.000000
     AimAssistAngle=20.000000
     MinPrecisionTurnRateScale=0.500000
     PrecisionTurnRateRampPower=10.000000
     PrecisionAimAssistAngle=20.000000
     MinScreenPercent=0.000050
     ForceFeedbackEffect="Fire gun"
     WeaponAnimationFrameCount(0)=37.000000
     WeaponAnimationFrameCount(2)=155.000000
     WeaponAnimationFrameCount(3)=30.000000
     WeaponAnimationFrameCount(4)=32.000000
     PreferredWeaponMenuIndex=4
     bAutoReload=True
     m_meleeHitSound="MeleeFistHit"
     m_melee3DHitSound="MeleeFistHit3D"
     AmmoName=Class'VietnamWeapons.AmmoRPG7'
     ReloadCount=1
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MeshName="USMC_Viewmodels.fps_RPG7"
     InventoryGroup=13
     PickupType="PickupRPG7"
     PlayerViewOffset=(X=3.100000,Y=5.850000,Z=-14.350000)
     PlayerHorizSplitViewOffset=(X=3.100000,Y=5.850000,Z=-13.350000)
     PlayerVertSplitViewOffset=(X=3.100000,Y=5.850000,Z=-14.350000)
     ThirdPersonRelativeLocation=(X=30.000000,Y=-8.000000,Z=-8.000000)
     ThirdPersonRelativeRotation=(Yaw=14000)
     AttachmentClass=Class'VietnamWeapons.WeaponRPG7Attachment'
     ItemName="RPG7"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
