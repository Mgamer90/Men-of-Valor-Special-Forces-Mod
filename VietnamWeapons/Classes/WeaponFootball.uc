//===============================================================================
//  [ WeaponFootball ]
//===============================================================================

class WeaponFootball extends VietnamWeapon;

// animation names
const FP_CATCH_ANIMATION = 'catch';
const FP_THROW_ANIMATION = 'throw';
const    THROW_ANIMATION = 'FB_throw';
const PICKUP_ANIMATION   = 'FB_pickup_ground';
const CROUCHED_PICKUP_ANIMATION = 'FB_pickup_ground'; // er... do something, right?
const PRONE_PICKUP_ANIMATION    = ''; // just do nothing, that will look okay.


var float ThrowStrength;	// Strength at which to throw grenade

var float fTimeTillIdle;			// Time until the idle is played
var float fTimeTillIdleVariance;


/////////////////////////////////////////////////////////////////////////////////////////////

// This is triggered by an AnimNotify in Fire
function ThrowFragGrenadeFP()
{
	ThrowFootball();
}

// Called during tick to process when we're ready to fire
simulated function DoReadyToFire()
{
	// Reset ReadyToFire variable
	if(ReadyToFire==false && !Instigator.PressingFire())
		ReadyToFire=true;
}

function ProjectileFire() {}

// Triggered by an AnimNotify during 'throw' anim
function ThrowFootball()
{
	local Vector Forward, Right, Up;
	local vector SpawnPoint;
	local vector StartPoint, EndPoint;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),Forward, Right, Up);

	if(FirstPersonView())
	{
		// Spawn grenades in front of us now, not at bone location since that doesn't work well
		SpawnPoint = VietnamPlayerController(Instigator.Controller).CalcFirstPersonViewLocation() + Forward * 10.0 + Right*10 /*+ Up * 100*/;

		EndPoint = GetFireEnd(StartPoint);
		AdjustedAim = rotator(EndPoint - StartPoint);
	}
	else
	{
		AdjustedAim = rotator(Forward);

		SpawnPoint = Instigator.GetBoneCoords('Bip_RFinger21').origin;	//mm: changed - new anim package
		SpawnPoint += Forward * (Instigator.CollisionRadius);

		ThrowStrength = 0.0;
	}

	if(VietnamPlayerController(Instigator.Controller)?)
	{
		AmmoFootball( AmmoType ).SpawnFootball( SpawnPoint,
			AdjustedAim, ThrowStrength, VietnamPlayerController(
			Instigator.Controller ).bInPreciseAimMode, NONE, Instigator );
	}
	else
	{
		// Bots don't use precise aim
		AmmoFootball( AmmoType ).SpawnFootball( SpawnPoint,
			AdjustedAim, ThrowStrength, false, BotHomingTarget, Instigator );
	}

	// Remove football from player's hand
	// TODO: Needs to happen clientside
	ThirdPersonActor.SetDrawType(DT_None);

	// kill self if out of ammo
	if ( !AmmoType.HasAmmo() )
	{
		if(VietnamPlayerController(Instigator.Controller)?)
			VietnamPlayerController(Instigator.Controller).StopPreciseAim();

		// force my owner to start using a better animSet
		if ( VietnamPawn( Instigator ) != NONE )
		{
			VietnamPawn( Instigator ).ServerUpdateAnimSet( NONE );
		}

		Destroy( );
	}
}

simulated function PlayFiring()
{
	local sound FireSound;

	FireSound = AmmoType.FireSound;

	ReadyToFire=false;
	PlayAnim( 'Load', 1.0f, 0.0f,
		FIRING_ANIMATION_CHANNEL );
	AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
		, , , , WEAPON_ACTION_TWEEN_TIME,
		WEAPON_ACTION_TWEEN_TIME, );

	// trigger third-person anims
	Instigator.PlayGrenadeThrowing();
}

simulated function PlayReloading()
{
	PlayAnim( 'Takeout', GetReloadAnimationRate( ), 0.0f,
		FIRING_ANIMATION_CHANNEL );
	AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
		, , , , WEAPON_RELOAD_TWEEN_TIME,
		WEAPON_RELOAD_TWEEN_TIME, );
}

function UpdateAttachment()
{
	if ( WeaponAttachment(ThirdPersonActor) != None )
	{
		WeaponAttachment(ThirdPersonActor).FiringMode = 'EWM_Grenade';
	}
}

// Make sure to go to down weapon whether or not we have another weapon to go to
function SwitchToWeaponWithAmmo()
{
	// if local player, switch weapon
	Instigator.Controller.SwitchToBestWeapon();
	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}
	else
		GotoState('DownWeapon');
}

function DoReload()
{
	if(AmmoType.AmmoAmount > 0)
		ReloadCount = 1;	
}

/* DownWeapon
Putting down weapon in favor of a new one.  No firing in this state
*/
State DownWeapon
{
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function ServerFire() {}
	function ServerAltFire() {}

	simulated function BeginState()
	{
		bChangeWeapon = false;
		bMuzzleFlash = false;

		if(AmmoType.HasAmmo())
			TweenDown();
		else
			AnimEnd(0);
	}
}

// This state plays as the pin is pulled
state NormalFire
{
	function CheckAnimating()
	{
		if ( !IsAnimating() )
			warn(self$" stuck in NormalFire and not animating!");
	}

	function ServerFire()
	{
		bForceFire = true;
	}

	function ServerAltFire()
	{
		bForceAltFire = true;
	}

	function Fire(float F) {}
	function AltFire(float F) {} 

	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			GotoState('ThrowingGrenade');
		}
	}

	function EndState()
	{
		StopFiringTime = Level.TimeSeconds;
	}
}

simulated state ThrowingGrenade
{
	ignores Fire, AltFire;

	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			// Reset ThrowStrength variable
			ThrowStrength = 0;
			
			if(CanReload())
				GotoState('Reloading');
			else
				GotoState('Idle');
			
			CheckAnimating();
		}
	}

Begin:
	PlayAnim( 'throw', 1.0f, 0.0f,
		FIRING_ANIMATION_CHANNEL );
	AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
		, , , , WEAPON_ACTION_TWEEN_TIME,
		WEAPON_ACTION_TWEEN_TIME, );
}

/*
Added play of the 'Walk' anim while walking
*/
simulated state Idle
{
	simulated function Tick( float DeltaTime )
	{
		// only allow the spin animation in a single
		// player game, where they can't notice the
		// missing third person animation
		if ( !Level.Game.IsA( 'VietnamCoop' ) )
		{
			if(fTimeTillIdle <= 0)
			{
				PlayAnim( 'spin', 1.0, 0.05 );
		
				if(FRand() > 0.5)
					fTimeTillIdle = Default.fTimeTillIdle + FRand() * fTimeTillIdleVariance;
				else
					fTimeTillIdle = Default.fTimeTillIdle - FRand() * fTimeTillIdleVariance;
			}
			else
				fTimeTillIdle -= DeltaTime;
		}

		// If the player picks up another football it should appear in his hand
		if ( NeedsToReload() && AmmoType.HasAmmo() )
		{
			GotoState('Reloading');
		}

		if(Instigator != None)
			DoReadyToFire();

		Global.Tick(DeltaTime);
	}

Begin:
	bPointing=False;
	
	// We only reload when the user calls forcereload or fires while needing to reload	
	if ( Instigator.PressingAltFire() ) AltFire(0.0);

	if(bChangeWeapon)
	{
		if(Instigator.PendingWeapon != self)
		{
			GotoState('DownWeapon');
		}
		else
		{
			Instigator.PendingWeapon = None;
		}
	}
	else
	{
		if(HasAmmo())
		{
			// blend up the idle on channel 
			// BLENDING_ANIMATION_CHANNEL
			LoopAnim( GetIdleAnimationName( ), 1.0, 0.0f,
				BLENDING_ANIMATION_CHANNEL );
			AnimBlendParams( BLENDING_ANIMATION_CHANNEL,
				0.0f );
			AnimBlendToAlpha( BLENDING_ANIMATION_CHANNEL,
				1.0f, 0.3f );
			
			// sleep till it's done
			Sleep( GetAnimationLength(
				BLENDING_ANIMATION_CHANNEL ) );
			
			// start the real anim on channel 0
			LoopAnim( GetIdleAnimationName( ),
				1.0f, 0.0f, 0 );
			
			// blend out the animation on channel
			// BLENDING_ANIMATION_CHANNEL
			AnimBlendToAlpha( BLENDING_ANIMATION_CHANNEL,
				0.0f, 0.3f );
		}
		else
		{
			PlayAnim('nothing', 1.0, 0.05);
		}
	}

}

state Active
{
	simulated function EndState()
	{
		Super.EndState();
		ReloadCount = Default.ReloadCount;	// This prevents us from bringing up the 
											// grenade in active and *THEN* bringing it up again
											// to "reload"
	}
}

// special state used to regulate the preemptive
// catch logic
simulated state Catch
{
	// triggers the catch animation
	//
	// inputs:
	// -- none --
	//
	// outputs:
	// -- none --
	simulated function BeginState( )
	{
		// start the catch animation on
		// the idle channel
		PlayAnim( FP_CATCH_ANIMATION, 1.0f, 0.0f,
			IDLE_ANIMATION_CHANNEL );
		AnimBlendParams( IDLE_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_ACTION_TWEEN_TIME,
			WEAPON_ACTION_TWEEN_TIME, );
	}
	
	// responds to the end of the
	// catch animation by ending
	// this state and going to idle(?)
	//
	// inputs:
	// inChannel - the channel that just ended
	//
	// outputs:
	// -- none --
	simulated function AnimEnd( Int inChannel )
	{
		// exit only if the catch started on
		// the idle channel has ended
		if ( inChannel == IDLE_ANIMATION_CHANNEL )
		{
			// trigger the takeout animation
			PlayFirstPersonTakeoutAnimation( );
			
			// exit this state
			GotoState( 'Takeout' );
		}
	}
	
	// Overridden to do nothing (this state has
	// no active controls)
	//
	function Fire( Float inPress );
	function AltFire( Float inPress );
	function ServerFire( );
	function ServerAltFire( );

	// overridden:  lets the user know they're
	// stuck in this state if an animation is
	// not active
	//
	// inputs:
	// -- none --
	//
	// outputs:
	// -- none -- (sanity check?)
	simulated function CheckAnimating( )
	{
		if ( !IsAnimating( ) )
		{
			Warn( self $ ":  Stuck in state Catch and not animating!!!" );
		}
	}
	
Begin:
	// nothing to do here but wait for
	// the catch animation to end
}

// returns true if this weapon is
// being used first person
//
// inputs:
// -- none --
//
// outputs:
// true if used first person,
// false if otherwise
simulated function bool IsUsedFirstPerson( )
{
	if ( Instigator != NONE &&
		PlayerController( Instigator.Controller ) != NONE &&
		Instigator.IsLocallyControlled( ) )
	{
		return true;
	}
	// else....
	
	return false;
}

// This is triggered by an AnimNotify in Fire
function ThrowFootballFP( )
{
	if ( IsUsedFirstPerson( ) && HasAmmo( ) )
	{
		ThrowFootball( );
	}
}

// overloaded:  used to catch third person
// animNotifies that cause this football
// to throw itself properly
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (UnReal Event)
function AnimNotifyThrow( )
{
	if ( Instigator != NONE && HasAmmo( ) &&
		!IsUsedFirstPerson( ) )
	{
		ThrowFootball( );
	}
}

// overridden:  returns the proper
// length for the longest "fire"
// animation for a football.  It
// compares both the first and
// third person animations
//
// inputs:
// -- none --
//
// outputs:
// longest delay, in seconds
function float GetFireDuration( )
{
	local float frameCount1, frameCount2;
	local float rate1, rate2;
	local float duration1, duration2;

	// get the rates and frame counts
	GetAnimSequenceParams( FP_THROW_ANIMATION,
		frameCount1, rate1 );
	Instigator.GetAnimSequenceParams( THROW_ANIMATION,
		frameCount2, rate2 );
	
	// compute the play lengths
	duration1 = frameCount1 / rate1;
	duration2 = frameCount2 / rate2;

	// always return the larger of the two durations
	return FMax( duration1, duration2 );
}

// this function lets the caller tell this football
// how it should be caught, namely that it will be
// explicitly picked up off the ground
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (set method, constant parameter)
function SetCatchAsPickup( )
{
	m_pawnTakeoutAnimation = PICKUP_ANIMATION;
}

// overloaded:  varies the takeout if the
// instigator is prone or crouched
//
// inputs:
// -- none --
//
// outputs:
// -- none --
simulated function PlayTakeOutAnimation( )
{
	// if this ball actually needs to be picked up,
	// do the right thing if crouching or prone
	if ( m_pawnTakeoutAnimation != '' )
	{
		if ( Instigator.bIsProne )
		{
			m_pawnTakeoutAnimation = PRONE_PICKUP_ANIMATION;
		}
		else if ( Instigator.bIsCrouched )
		{
			m_pawnTakeoutAnimation = CROUCHED_PICKUP_ANIMATION;
			
			// also fiddle the takeout bone so
			// that the animation plays properly
			m_baseTakeOutBone = class'VietnamWeapon'.Default.m_baseTakeOutBone;
		}
	}
	
	// then do the regular animation stuff
	Super.PlayTakeOutAnimation( );

	// restore the takeout bone to its proper setting, if necessary
	if ( Instigator.bIsCrouched )
	{
		m_baseTakeOutBone = Default.m_baseTakeOutBone;
	}
}

// this function lets the caller tell this football
// how it should be caught, namely that it does
// not need a pickup animation at all (used to help
// assist the ProjectileFootball with its preemptive
// catch logic)
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (set method, constant parameter)
function DisableCatchAnimation( )
{
	m_pawnTakeoutAnimation = '';
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


simulated function Spawned()
{
	Super.Spawned();
	// Make no shoot crosshair be the same as normal crosshair
	CrosshairFriendlyFire=Texture(DynamicLoadObject("interface_tex.HUD.reticledot_tex",class'Texture'));
}

// overloaded:  the football really can't be reloaded
//
// inputs:
// -- none --
//
// outputs:
// always false
simulated function Bool CanReload( )
{
	// the football cannot be reloaded
	return false;
}

defaultproperties
{
     fTimeTillIdle=8.000000
     fTimeTillIdleVariance=2.500000
     PlayerCrouchViewOffset=(X=16.950001,Y=2.850000,Z=-13.500000)
     PlayerAimViewOffset=(X=16.950001,Y=2.850000,Z=-13.500000)
     Magnification=1.200000
     Accuracy=0.000000
     Recoil=0.000000
     Damage=0.000000
     AimImprovementRate=0.000000
     m_BotsShouldAimMe=False
     WeaponGrip=EWG_Football
     m_pawnTakeoutAnimation="FB_pickup_ground"
     m_pawnStowAnimation="Nothing"
     m_baseTakeOutBone="None"
     WeaponAnimationFrameCount(0)=33.000000
     WeaponAnimationFrameCount(2)=12.000000
     WeaponAnimationFrameCount(3)=12.000000
     WeaponAnimationFrameCount(4)=8.000000
     iHandSkinIndex=1
     bCanUseRedCrosshair=False
     AmmoName=Class'VietnamWeapons.AmmoFootball'
     PickupAmmoCount=1
     ReloadCount=1
     bExcludeFromWeapSwap=True
     AutoSwitchPriority=7
     FireOffset=(X=20.000000,Y=4.000000,Z=-5.000000)
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     TraceAccuracy=0.400000
     AIRating=0.700000
     MaxRange=3000.000000
     FlashOffsetY=0.130000
     FlashOffsetX=0.170000
     MuzzleFlashSize=256.000000
     bForceAutoSwitch=True
     MeshName="USMC_Viewmodels.fps_football"
     InventoryGroup=23
     PickupType="PickupFootball"
     PlayerViewOffset=(X=16.950001,Y=2.850000,Z=-13.500000)
     BobDamping=0.097500
     ThirdPersonRelativeLocation=(X=16.000000,Y=-10.000000,Z=-3.000000)
     ThirdPersonRelativeRotation=(Pitch=16384,Yaw=0)
     AttachmentClass=Class'VietnamWeapons.WeaponFootballAttachment'
     ItemName="Football"
     bActorShouldTravel=False
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
