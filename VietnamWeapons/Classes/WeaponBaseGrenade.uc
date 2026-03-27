//===============================================================================
//  [ WeaponBaseGrenade ]
//
//  Base class for frag and smoke grenades
//===============================================================================

class WeaponBaseGrenade extends VietnamWeapon;

var float ThrowStrength;	// Strength at which to throw grenade

var bool bForceThrow;		// Force grenade throw as soon as state is HoldingGrenade

replication
{
	// From client to server
	reliable if( Role<ROLE_Authority )
		ServerThrowGrenade;
}

/////////////////////////////////////////////////////////////////////////////////////////////

// efd - grenades cannot be used for melee attack
simulated function bool CanMelee()
{
	return false;
}
// end efd

// This is triggered by an AnimNotify in Fire
function ThrowGrenadeFP()
{
//	if(FirstPersonView())
		ThrowGrenade();
}

// Called during tick to process when we're ready to fire
simulated function DoReadyToFire()
{
	// Reset ReadyToFire variable
	if(ReadyToFire==false && !Instigator.PressingFire())
		ReadyToFire=true;
}

// Overridden to do nothing, we want the grenade to be thrown based on an AnimNotify
// not the usual ProjectileFire function call
function ProjectileFire() {}

// Triggered by an AnimNotify during 'throw' anim
function ThrowGrenade()
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

		// Always 0.75 on PC
		ThrowStrength = 0.75;
	}
	else
	{
		AdjustedAim = rotator(Forward);

		SpawnPoint = Instigator.GetBoneCoords('Bip_RFinger21').origin;	//mm: changed - new anim package
//		log("Grenade spawnpoint: " $ SpawnPoint);
		SpawnPoint += Forward * (Instigator.CollisionRadius);
//		log("Grenade spawnpoint + collisionradius: " $ SpawnPoint);

		ThrowStrength = 1.0;
	}

	// Set to false to fake a grenade throw when popping smoke
	if ( m_bSpawnProjectile == true )
	{
		VietnamAmmo(AmmoType).SpawnThrownProjectile(SpawnPoint, AdjustedAim, ThrowStrength);
	}
}

// returns a bone to animate from for
// grenade throw animations
//
// inputs:
// -- none --
//
// outputs:
// name of the bone to animate from
simulated function Name GetGrenadeThrowAnimationBone( )
{
	if ( Instigator.bIsProne )
	{
		return 'Bip_Spine2';
	}
	// else....
	
	return 'Bip_Spine1';
}

// starts the grenade throw animation
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment)
simulated function InstigatorPlayGrenadeThrowStart( )
{
	local VietnamPawn           myPawn;
	local AnimSet.SAnimPoseInfo Pose;
	local AnimInfo              newAnimation;

	myPawn = VietnamPawn( Instigator );
	if ( myPawn? )
	{
		Pose = myPawn.GetAnimPose( );

		newAnimation.Alpha     = 1.0f;
		newAnimation.AnimName  = Pose.m_grenadeThrowStart;
		newAnimation.bLooping  = false;
		newAnimation.Channel   = myPawn.FIRINGCHANNEL;
		newAnimation.Rate      = 1.0f;
		newAnimation.StartBone = GetGrenadeThrowAnimationBone( ); 

		myPawn.StartAnimation( newAnimation, true, false, WEAPON_DEPLOY_RATE );
	}
}

simulated function PlayFiring()
{
	local sound FireSound;

	FireSound   = AmmoType.FireSound;
	ReadyToFire = false;

	PlayAnim( 'Load', 1.0f, 0.0f,
		FIRING_ANIMATION_CHANNEL );
	AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
		, , , , WEAPON_ACTION_TWEEN_TIME,
		WEAPON_ACTION_TWEEN_TIME, );

	// trigger third-person animation that
	// starts the grenade throwing cycle
	InstigatorPlayGrenadeThrowStart( );
}

simulated function PlayReloading( )
{
	local Float frames, rate;
	
	PlayAnim( 'Takeout', GetReloadAnimationRate( ), 0.0f,
		FIRING_ANIMATION_CHANNEL );
	AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
		, , , , WEAPON_RELOAD_TWEEN_TIME,
		WEAPON_RELOAD_TWEEN_TIME, );

	// play a third person animation too
	GetAnimSequenceParams( 'Takeout', frames, rate );
	Instigator.PlayReload( frames / rate, GetReloadAnimationRate( ) );
	
	// trigger a timer to re-enable the view model
	// in the Instigator's hand at the appropriate time
	SetDelegateTimer( 'Enable3rdPersonModel', 0.1f );
}

// unhides the third person view model
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (timer function)
simulated function Enable3rdPersonModel( )
{
	// reveal the viewmodel in the player's hand
	if ( ThirdPersonActor? )
	{
		ThirdPersonActor.bHidden = false;
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

/*
function DoReload()
{
	if(AmmoType.AmmoAmount > 0)
		ReloadCount = 1;
}
*/

simulated function Name GetPutAwayAnimationName( )
{
	if ( m_bInstantFire == true )
	{
		return 'nothing';
	}
	else
	{
		return Super.GetPutAwayAnimationName();
		//return 'putaway';
	}
}

// DownWeapon
// Putting down weapon in favor of a new one.  No firing in this state
//
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

		// I guess if there's no ammo, then play no anim, but do we really need this anymore?
		if(HasAmmo())
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

	simulated function AnimEnd( int Channel )
	{
		// this class only cares about animations
		// that end on channel FIRING_ANIMATION_CHANNEL
		// (ones that it started)
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			log(self $ " NormalFire::AnimEnd",'Weapons');

			bClientReadyForCommand = false;

			GotoState( 'HoldingGrenade' );

			CheckAnimating( );
		}
	}

	simulated function EndState()
	{
		StopFiringTime = Level.TimeSeconds;

		log(self $ " NormalFire::EndState",'Weapons');
	}

	simulated function BeginState()
	{
		Super.BeginState();

		log(self $ " NormalFire::BeginState",'Weapons');
	}
}

// plays the grenade throw hold idle
// on the instigator
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment)
simulated function InstigatorPlayGrenadeThrowHoldIdle( )
{
	local VietnamPawn           myPawn;
	local AnimSet.SAnimPoseInfo Pose;
	local AnimInfo              newAnimation;

	myPawn = VietnamPawn( Instigator );
	if ( myPawn? )
	{
		Pose = myPawn.GetAnimPose( );

		newAnimation.Alpha     = 1.0f;
		newAnimation.AnimName  = Pose.m_grenadeThrowHoldIdle;
		newAnimation.bLooping  = true;
		newAnimation.Channel   = myPawn.FIRINGCHANNEL;
		newAnimation.StartBone = GetGrenadeThrowAnimationBone( );

		myPawn.StartAnimation( newAnimation, false, false );
	}
}

state HoldingGrenade
{
	ignores Fire, ForceReload;

	function ServerFire() {}
	simulated function TriggerClientFire() {}

	// overloaded:  needs to do some extra work
	// to resolve this state
	//
	// inputs:
	// StartLocation - initial location to spawn at
	// StartRotation - initial rotation
	// bDropAmmo     - also drop my ammo
	//
	// outputs:
	// -- none --
	function Pickup DropFrom( vector StartLocation,
		optional rotator StartRotation,
		optional bool bDropAmmo )
	{
		// then, resolve some problems this
		// state has created
		if ( bDropAmmo )
		{
			// put back the grenade being held
			++AmmoType.AmmoAmount;
		}

		bLowAmmo = false;

		// quick load me with some ammo!
		if ( ReloadCount == 0 )
		{
			ReloadCount = 1;
			--AmmoType.AmmoAmount;
		}
		
		// turn this back on so the player
		// can throw me!
		bClientReadyForCommand = true;

		// stop the holding animation
		StopAnimationChannel( FIRING_ANIMATION_CHANNEL );

		// then do the parent tasks
		return Super.DropFrom( StartLocation,
			StartRotation, bDropAmmo );
	}

	// If user hits alt-fire, put grenade away
	simulated function AltFire( float Value )
	{
		ServerAltFire();

		if(Level.NetMode == NM_Client)
			GotoState('PutPinBackIn');
	}

	function ServerAltFire()
	{
		GotoState('PutPinBackIn');
	}

	simulated function Tick( float DeltaTime )
	{
		if(VietnamPlayerController(Instigator.Controller) != None )
		{
			//5/14/04: PC mod
			//if(VietnamPlayerController(Instigator.Controller).XBoxGrenadeThrowing == false)
			//{
				// New idea: ThrowStrength is always at max
				ThrowStrength = 0.75; //1.0;
			//}
			//else
			//{
			//	// Record the most pulled back the trigger was
			//	if(VietnamPlayerController(Instigator.Controller).axbFire > ThrowStrength)
			//		ThrowStrength = VietnamPlayerController(Instigator.Controller).axbFire;

			//	// Record the most pulled back the trigger was
			//	if(VietnamPlayerController(Instigator.Controller).LastValue > ThrowStrength)
			//		ThrowStrength = VietnamPlayerController(Instigator.Controller).LastValue;
			//}
		}

		if(Instigator.IsLocallyControlled())
		{
			if(!Instigator.PressingFire())
			{
				log(self $ " HoldingGrenade going to ThrowingGrenade",'Weapons');

				GotoState('ThrowingGrenade');
				ServerThrowGrenade();
			}
		}

		// Client asked to throw grenade in a previous state, so do it now
		if(bForceThrow)
		{
			GotoState('ThrowingGrenade');
			bForcethrow = false;
		}
	}

	simulated function EndState()
	{
		StopFiringTime = Level.TimeSeconds;
		
		// leave the nothing running to make
		// the transition to the throw as smooth
		// as possible
		
		// the looping third person animation will
		// be killed off by the stow or whatever
		// that will play in the next state

		//log(self $ " HoldingGrenade::EndState",'Weapons');
	}

	simulated function BeginState()
	{
		Super.BeginState();

		// start a different idle--the hold grenade throw idle--
		// on the FIRING_ANIMATION_CHANNEL
		LoopAnim( 'Nothing', 1.0f, 0.0f,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_ACTION_TWEEN_TIME );
			
		// trigger the third person grenade throw pose as well
		InstigatorPlayGrenadeThrowHoldIdle( );

		//log(self $ " HoldingGrenade::BeginState",'Weapons');
	}

	// Client requested a grenade toss
	function ServerThrowGrenade()
	{
		GotoState('ThrowingGrenade');
	}
}

// Replicates to the server telling it to throw the grenade
function ServerThrowGrenade()
{
	//log("ServerThrowGrenade received in state: " $ GetStateName());

	bForceThrow = true;
}

// plays the animation to restore the
// grenade's pin on the instigator
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment)
simulated function InstigatorPlayGrenadeThrowPutBackPin( )
{
	local VietnamPawn           myPawn;
	local AnimSet.SAnimPoseInfo Pose;
	local AnimInfo              newAnimation;

	myPawn = VietnamPawn( Instigator );
	if ( myPawn? )
	{
		Pose = myPawn.GetAnimPose( );

		newAnimation.Alpha     = 1.0f;
		newAnimation.AnimName  = Pose.m_grenadeThrowPutBackPin;
		newAnimation.bLooping  = false;
		newAnimation.Channel   = myPawn.FIRINGCHANNEL;
		newAnimation.Rate      = 1.0f;
		newAnimation.StartBone = GetGrenadeThrowAnimationBone( ); 

		myPawn.StartAnimation( newAnimation, true, true,
			WEAPON_DEPLOY_RATE, WEAPON_DEPLOY_RATE );
	}
}

state PutPinBackIn
{
	ignores Fire, AltFire, ForceReload;

	function ServerFire() {}
	function ServerAltFire() {}

	simulated function BeginState()
	{
		PlayAnim('replace_grenade', 1.0f, 0.0f,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_RELOAD_TWEEN_TIME,
			WEAPON_RELOAD_TWEEN_TIME, );

		// put the pin back third person as well
		// (this anim doesn't loop, so we don't
		// need to worry excessively about stopping
		// it at the proper time)
		InstigatorPlayGrenadeThrowPutBackPin( );
	}
	
	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			// set reload count to 1, the only
			// value possible for a grenade
			// when its clip is full
			ReloadCount = 1;

			// do this so the server's ammo
			// count won't stay red
			if ( Level.NetMode != NM_Client )
			{
				CheckForLowAmmo( );
			}

			bClientReadyForCommand = true;
			GotoState('Idle');
		}
	}
}

// plays the animation to throw the grenade
// from the hold idle animation
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment)
simulated function InstigatorPlayGrenadeThrowEnd( )
{
	local VietnamPawn           myPawn;
	local AnimSet.SAnimPoseInfo Pose;
	local AnimInfo              newAnimation;

	myPawn = VietnamPawn( Instigator );
	if ( myPawn? )
	{
		Pose = myPawn.GetAnimPose( );

		newAnimation.Alpha     = 1.0f;
		newAnimation.AnimName  = Pose.m_grenadeThrowEnd;
		newAnimation.bLooping  = false;
		newAnimation.Channel   = myPawn.FIRINGCHANNEL;
		newAnimation.Rate      = 1.0f;
		newAnimation.StartBone = GetGrenadeThrowAnimationBone( ); 

		myPawn.StartAnimation( newAnimation, true, true,
			WEAPON_DEPLOY_RATE, WEAPON_DEPLOY_RATE );
	}
}

simulated state ThrowingGrenade
{
	ignores Fire, AltFire;

	simulated function TriggerClientFire() {}
	simulated function ServerFire() {}

	simulated function AnimEnd( int Channel )
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			//PC mod
			// Reset ThrowStrength variable
			ThrowStrength = 0.75; //ThrowStrength = 0;
			
			if( CanReload( ) )
			{
				GotoState( 'Reloading' );
			}
			else
			{
				bClientReadyForCommand = true;
				GotoState( 'Idle' );
			}

			CheckAnimating( );
		}
	}

	simulated function BeginState()
	{
		PlayAnim( 'Fire', 1.0f, 0.0f,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_ACTION_TWEEN_TIME,
			WEAPON_ACTION_TWEEN_TIME, );
		
		
		// trigger the third person animation too
		InstigatorPlayGrenadeThrowEnd( );
		
		// hide the viewmodel in the player's hand
		if ( ThirdPersonActor? )
		{
			ThirdPersonActor.bHidden = true;
			
			// also, disable the function that
			// could reveal the model now (just
			// in case)
			SetDelegateTimer( 'Enable3rdPersonModel', 0.0f );
		}
	}
}

//
// Added play of the 'Walk' anim while walking
//
simulated state Idle
{
	// overloaded:  starts an animation on channel
	// SPECIAL_ANIMATION_CHANNEL to use when the
	// weapon owner moves faster
	//
	// inputs:
	// -- none --
	//
	// outputs:
	// -- none -- (UnReal Event)
	simulated function BeginState( )
	{
		// do the parent stuff first
		Super.BeginState( );
	
		if(!HasAmmo())
		{
			// Destroy weapon if out of ammo
			if(ROLE == Role_Authority)
				Destroy();
		}
		// start a walking idle animation
		// on channel SPECIAL_ANIMATION_CHANNEL
		// (set alpha to 0 so it will be hidden
		// until needed)
		LoopAnim( 'Walk', 1.0f, 0.0f,
			SPECIAL_ANIMATION_CHANNEL );
		AnimBlendParams( SPECIAL_ANIMATION_CHANNEL,
			0.0f );
	}
	
	// overloaded:  stops the special animation
	// on channel SPECIAL_ANIMATION_CHANNEL
	//
	// inputs:
	// -- none --
	//
	// outputs:
	// -- none -- (UnReal Event)
	simulated function EndState( )
	{
		// stop the special animation
		StopAnimationChannel( SPECIAL_ANIMATION_CHANNEL );
		
		// turn off its alpha
		AnimBlendParams( SPECIAL_ANIMATION_CHANNEL, 0.0f );
		
		// do the parent stuff too!
		Super.EndState( );
	}

	// overloaded:  blends in and out a special
	// walking idle animation based on the owner's
	// walking speed
	//
	// inputs:
	// DeltaTime - time elapsed this frame
	//
	// outputs:
	// -- none --
	simulated function Tick( float DeltaTime )
	{
		local float currentAlpha;

		// what is the current blend value on
		// the special channel?
		GetBlendInfo( SPECIAL_ANIMATION_CHANNEL, currentAlpha );

		// if the instigator is moving fast enough and the
		// blend is set to less than SPECIAL_ANIMATION_CHANNEL
		// for the special animation, blend it up to
		// SPECIAL_ANIMATION_CHANNEL
		if( VSize( Instigator.Velocity ) > 100 && HasAmmo( ) &&
			currentAlpha < 1.0f && !IsFiring( ) )
		{
			AnimBlendToAlpha( SPECIAL_ANIMATION_CHANNEL, 1.0f, 0.3f );
		}
		else
		{
			// otherwise, blend out the channel and
			// let the basic idle take over
			AnimBlendToAlpha( SPECIAL_ANIMATION_CHANNEL, 0.0f, 0.3f );
		}
		
		// do the parent stuff too
		Super.Tick( DeltaTime );
	}

	// AnimEnd( ) was removed because looping is now handled
	// by the animation system directly

Begin:

	bPointing=False;
	
	// We only reload when the user calls forcereload or fires while needing to reload	
	if ( Instigator.PressingAltFire() ) AltFire(0.0);
	
	if( bChangeWeapon )
	{
		if( Instigator.PendingWeapon != self )
		{
			GotoState( 'DownWeapon' );
		}
		else
		{
			Instigator.PendingWeapon = None;
		}
	}
	else
	{
		if( HasAmmo( ) && (m_bInstantFire == false) )
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
			//log( " PlayAnim( 'nothing' )" );
			PlayAnim( 'nothing', 1.0, 0.05, 0 );
		}
	}
}

state Active
{
	// DTW
	simulated function BeginState()
	{
		Super.BeginState();

		// DTW: Set to true to bypass the equip anim go straight to the smoke grenade throw
		if ( m_bInstantFire == true )
		{
			GotoState('ThrowingGrenade');
		}
	}

	function ServerFire()
	{
		bForceFire = true;
	}

	simulated function EndState()
	{
		Super.EndState( );
		if ( HasAmmo( ) )
		{
			DoReload();		// This prevents us from bringing up the 
							// grenade in active and *THEN* bringing it up again
							// to "reload"
		}
	}
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

defaultproperties
{
     PlayerCrouchViewOffset=(X=16.950001,Y=2.850000,Z=-16.500000)
     PlayerAimViewOffset=(X=16.950001,Y=2.850000,Z=-16.500000)
     Magnification=1.000000
     Accuracy=0.000000
     Recoil=0.000000
     Damage=0.000000
     AimImprovementRate=0.000000
     WeaponGrip=EWG_Grenade
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(6)=(PackageName="weapon_snd",ResourceName="GrenadePinPull")
     WeaponSoundNames(7)=(PackageName="weapon_snd",ResourceName="GrenadeThrow")
     m_pawnTakeoutAnimation="Gr_Ab_takeout"
     m_pawnStowAnimation="Gr_Ab_Putaway"
     m_pawnProneTakeoutAnimation="OH_Pr_takeout"
     m_pawnProneStowAnimation="OH_Pr_Putaway"
     bAutoReload=True
     bCanUseRedCrosshair=False
     ReloadCount=1
     AutoSwitchPriority=7
     AIRating=0.700000
     MaxRange=3000.000000
     PlayerViewOffset=(X=16.950001,Y=2.850000,Z=-16.500000)
     ThirdPersonRelativeLocation=(X=13.000000,Y=-9.000000,Z=8.000000)
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
