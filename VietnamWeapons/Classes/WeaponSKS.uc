//===============================================================================
//  [ M16 ]
// Firing modes:
//	semi-auto
//  auto
//===============================================================================

class WeaponSKS extends VietnamWeapon;

var bool			bDoDownWeapon;

// returns the name of the firing animation to play
//
// inputs:
// -- none --
//
// outputs:
// animation name
simulated function Name GetFiringAnimationName( )
{
	if ( WeaponMode == EWM_Bayonet )
	{
		return 'Bayonet_Fire';
	}
	// else....
	
	return Super.GetFiringAnimationName( );
}

// Switch to bayonet mode and back to regular fire mode
function ServerAltFire()
{
	VietnamPawn(Instigator).EndSpawnInvulnerability();

	if(WeaponMode==EWM_Semiauto)
	{
		WeaponMode=EWM_Bayonet;
		GotoState('TakeoutBayonet');
	}
	else if(WeaponMode==EWM_Bayonet)
	{
		WeaponMode=EWM_Semiauto;
		GotoState('PutawayBayonet');
	}
}

simulated function bool IsSemiAuto()
{
	if(WeaponMode == EWM_Bayonet)
		return true;
	else
		return Super.IsSemiAuto();
}

state TakeoutBayonet
{
	ignores Fire, AltFire, ForceReload;
	
	simulated function BeginState()
	{
		PlayAnim( 'Bayonet_Takeout', 1.0, 0.05,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_ACTION_TWEEN_TIME,
			WEAPON_ACTION_TWEEN_TIME, );
		PlaySound(WeaponSounds[6]);
	}
	
	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			GotoState('Idle');
		}
	}
}

state PutawayBayonet
{
	ignores Fire, AltFire, ForceReload;

	simulated function BeginState()
	{
		PlayAnim( 'Bayonet_Putaway', 1.0, 0.05,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_ACTION_TWEEN_TIME,
			WEAPON_ACTION_TWEEN_TIME, );
		PlaySound(WeaponSounds[7]);
	}
	
	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			if(bDoDownWeapon)
			{
				bDoDownWeapon = false;
				GotoState('DownWeapon');
			}
			else
				GotoState('Idle');
		}
	}
}

// overloaded:  plays a special animation if the
// bayonet is attached
//
// inputs:
// -- none --
//
// outputs:
// animation Name
Simulated Function Name GetIdleAnimationName( )
{
	if( WeaponMode == EWM_Bayonet )
	{
		return 'Bayonet_idle';
	}
	// else....

	return Super.GetIdleAnimationName( );
}

// Returns true/false if player can reload current weapon
// Only allow reload for SKS when ammo is completely out
simulated function bool CanReload()
{
	if (bBotControlled)
	{
		return true;
	}
	// Can only reload when there is reserve ammo
	if ( AmmoType.HasAmmo() && ReloadCount == 0)
		return true;
	else
		return false;
}

simulated function bool CanMelee()
{
	return Super.CanMelee() || WeaponMode == EWM_Bayonet;
}

function bool SKSStabTrace()
{
	local vector HitLocation, HitNormal, TraceStart, EndTrace, vForward, vRight, vUp;
	local actor Other;
	local rotator Rotation;
	local int iHitBone;
	local VietnamPawn tmpPawn;

	Rotation = VietnamPlayerController(Instigator.Controller).Rotation;

	TraceStart = VietnamPlayerController(Instigator.Controller).CalcFirstPersonViewLocation();
		
	GetAxes(Rotation, vForward, vRight, vUp);

	EndTrace = TraceStart + vForward * 150;

	// Do the trace
	Other = CustomTrace(TraceStart, EndTrace, TRACEFLAG(STRACE_AllBlocking), HitLocation, HitNormal,,,BLOCKFLAG(SBLOCK_Actors) | BLOCKFLAG(SBLOCK_Players) | BLOCKFLAG(SBLOCK_Bots) | BLOCKFLAG(SBLOCK_World),,iHitBone);


	if ( Other? && Other.IsA( 'VietnamPawn' ) )
	{
		tmpPawn = VietnamPawn(Other);
		tmpPawn.LastHitBone = iHitBone;

		// HACK!!: For some reason HitLocation is returning <0,0,0> when a pawn is hit
		HitLocation = Other.Location;
		
		// Bayonet does a ton of damage
		Other.TakeDamage(100,  Instigator, HitLocation, 30000.0*vForward, WeaponDamageType);	
		tmpPawn.SpawnBloodEffect(100, Instigator, HitLocation, rotator(vForward));
		// Rep to everybody around target pawn (except weapon's owner)
		tmpPawn.RemotePlayRegisteredSound( Level.PawnSoundNames[110].ResourceName, '');
		// Rep to weapon's owner so he hears it to
		Instigator.ClientPlayRegisteredReplicatedSound( Level.PawnSoundNames[110].ResourceName, '');

		return true;
	}
	
	return false;
}

state Melee
{
	simulated function BeginState()
	{
		// do something special if the bayonet is deployed
		if ( WeaponMode == EWM_Bayonet )
		{
			// TODO: Check if this is the right anim
			PlayAnim( 'Bayonet_Attack_Start', 1.0, 0.05,
				FIRING_ANIMATION_CHANNEL );
			AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
				, , , , WEAPON_ACTION_TWEEN_TIME,
				WEAPON_ACTION_TWEEN_TIME, );
				
			ReadyToFire = false;

			Instigator.PlayMeleeAttackAnimation( );

			// trigger the melee attack sound
			if(Instigator.IsLocallyControlled())
				ClientPlayRegisteredSound( MELEE_SWING_SOUND, 'melee_swing' );

			// Everyone but owner should hear 3D version, only make the call on server who
			// will rep it to all clients (except owner)
			if(Role==ROLE_Authority)
				Instigator.RemotePlayRegisteredSound( MELEE_SWING3D_SOUND, 'melee_swing3D' );
		}
		else
		{
			Super.BeginState( );
		}
	}
	
	simulated function AnimEnd(int Channel)
	{
		// do something special if the bayonet is deployed
		if ( WeaponMode == EWM_Bayonet )
		{
			if ( Channel == FIRING_ANIMATION_CHANNEL )
			{
				// Do StabTrace here instead of in AnimNotify
				if(SKSStabTrace())
					GotoState('RecoverFromBayonetStabHit');
				else
					GotoState('RecoverFromBayonetStabMiss');
			}
		}
		else
		{
			Super.AnimEnd( Channel );
		}
	}
}

state RecoverFromBayonetStabHit
{
	ignores Fire, AltFire, ForceReload;
	
	simulated function BeginState()
	{
		// TODO: Check if this is the right anim
		PlayAnim( 'Bayonet_Attack_hit', 1.0, 0.05,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_ACTION_TWEEN_TIME,
			WEAPON_ACTION_TWEEN_TIME, );
	}
	
	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			GotoState('Idle');
		}
	}
}

state RecoverFromBayonetStabMiss
{
	ignores Fire, AltFire, ForceReload;
	
	simulated function BeginState()
	{
		// TODO: Check if this is the right anim
		PlayAnim( 'Bayonet_Attack_miss', 1.0, 0.05,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_ACTION_TWEEN_TIME,
			WEAPON_ACTION_TWEEN_TIME, );
	}
	
	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			GotoState('Idle');
		}
	}
}

// DownWeapon
// Putting down weapon in favor of a new one.  No firing in this state
//
State DownWeapon
{
	function Fire( float Value )
	{
//##USDEBUG
//		CommentOwner("WeaponSKS: State DownWeapon: Fire: Fire called with F"@Value);
//##END

	}
	function AltFire( float Value ) {}

	function ServerFire() {}

	// Designed to be overridden by weapons that need special PutDown processing
	// Instead of overriding DownWeapon::BeginState
	simulated function HandlePutdown()
	{
		if(WeaponMode == EWM_Bayonet)
		{
			bDoDownWeapon = true;
			Global.ServerAltFire();
		}
		else
			TweenDown();
	}
}

// Plays the animation and the accompanying sound
simulated function PlayReloading()
{
	local PlayerController PController;
	local Float            animationLength, animationRate, frames, rate;

	PController = PlayerController(Instigator.Controller);
	if(PController?)
		PController.ClientPlaySound(WeaponSounds[EWeaponSound.EWS_Reload]);

	if(UseAnimTimer())
	{
		WeaponAnimTimer(WeapAnim_Reload, FIRING_ANIMATION_CHANNEL, 1.0);
		
		animationLength = ComputeWeaponAnimTimerLength( WeapAnim_Reload, 1.0 );
		animationRate   = 1.0f;
	}
	else
	{
		if(WeaponMode == EWM_Bayonet)
		{
			PlayAnim( 'Bayonet_Reload', GetReloadAnimationRate( ), 0.05,
				FIRING_ANIMATION_CHANNEL );
			
			GetAnimSequenceParams( 'Bayonet_Reload', frames, rate );
		}
		else
		{
			PlayAnim( 'Reload', GetReloadAnimationRate( ), 0.05,
				FIRING_ANIMATION_CHANNEL );
			
			GetAnimSequenceParams( 'Reload', frames, rate );
		}
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_RELOAD_TWEEN_TIME,
			WEAPON_RELOAD_TWEEN_TIME, );

		animationLength = frames / rate;
		animationRate   = GetReloadAnimationRate( );
	}

	// third person anims
	Instigator.PlayReload( animationLength, animationRate );
}

// Should be implemented by individual weapons which use bDisplayAmmoType==false
simulated function string GetCurrentWeaponModeName()
{
	return SemiAutoString;
}

simulated function AltFire( float Value )
{
	ServerAltFire();

	if(Level.NetMode == NM_Client)
	{
		if(WeaponMode==EWM_Semiauto)
		{
			WeaponMode=EWM_Bayonet;
			GotoState('TakeoutBayonet');
		}
		else if(WeaponMode==EWM_Bayonet)
		{
			WeaponMode=EWM_Semiauto;
			GotoState('PutawayBayonet');
		}
	}
}

defaultproperties
{
     PlayerCrouchViewOffset=(X=10.300000,Y=0.200000,Z=-15.450000)
     PlayerAimViewOffset=(X=5.800000,Y=-3.150000,Z=-15.450000)
     Magnification=1.600000
     Accuracy=0.000000
     m_maximumRecoil=750.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     MuzzleClass=Class'VietnamGame.BaseFPMuzzleFlash'
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="SKSOutdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="SKSNP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(5)=(PackageName="weapon_snd",ResourceName="AK47SemiAutoSelect")
     WeaponSoundNames(6)=(PackageName="weapon_snd",ResourceName="BayonetEquip")
     WeaponSoundNames(7)=(PackageName="weapon_snd",ResourceName="BaynetUnequip")
     SemiAutoSpeed=0.800000
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
     MinScreenPercent=0.000100
     bCanOnlyReloadWhenEmpty=True
     ShellEjectMeshName="weapons_stat.shells.sks_shell_stat"
     ForceFeedbackEffect="Fire gun"
     fCriticalHitPercent=0.400000
     WeaponAnimationFrameCount(0)=10.000000
     WeaponAnimationFrameCount(2)=136.000000
     WeaponAnimationFrameCount(3)=52.000000
     WeaponAnimationFrameCount(4)=52.000000
     MultiplayerDamage=40.000000
     PreferredWeaponMenuIndex=1
     AmmoName=Class'VietnamWeapons.Ammo762WP'
     ReloadCount=10
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MaxRange=10000.000000
     bDrawMuzzleFlash=True
     MFTextureName="effects_tex.MuzzleFlash.MuzzleflashPistol_tex"
     bMFRandomRotation=True
     specificReloadAnim="Th_Ab_SKS_Reload"
     MeshName="USMC_Viewmodels.fps_sks"
     InventoryGroup=9
     PickupType="PickupSKS"
     PlayerViewOffset=(X=10.300000,Y=0.200000,Z=-15.450000)
     PlayerHorizSplitViewOffset=(X=10.300000,Y=0.200000,Z=-14.450000)
     PlayerVertSplitViewOffset=(X=10.300000,Y=0.200000,Z=-15.450000)
     ThirdPersonRelativeLocation=(X=13.000000,Y=-6.000000,Z=3.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponSKSAttachment'
     ItemName="SKS"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
