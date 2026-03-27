//=============================================================================
// ProjectileFootball.uc
//=============================================================================
class ProjectileFootball extends VietnamProjectile;

// use for homing calculations
const SMERP_CONSTANT          = 1.0f;

// name of the bone that the head of
// a model is attached to
const HEAD_BONE               = 'Bip_Head';

// defines the amount of time by which
// to fudge a ball catch time in order
// to make the preemptive catch look
// good
const BALL_CATCH_FUDGE_FACTOR = 0.0f;

// animations used for catching
const LOW_CATCH      = 'FB_catch_ground';
const MID_CATCH      = 'FB_catch_chest';
const HIGH_CATCH     = 'FB_catch';
const PRONE_CATCH     = 'OH_Pr_fire'; // way temp here!
const CROUCHING_CATCH = 'OH_Cr_Fire'; // ditto!

// defines the frame at which the
// catch animation really catches
// the ball
const CATCH_FRAME    = 0.25f;

// always group bools together (helps save memory)

// True if the ball was thrown recently and shouldn't be catchable
// by the guy who threw it
var bool bJustThrown;

// set by the preemptive catch logic when
// this ball decides to give itself to the
// player.  The player must be given a ball
// ahead of time in order to play the
// catch animation properly, so this flag
// lets the ball know that it doesn't need
// to give the player another ball later
// when its actually caught it
var Bool  m_gaveSelfToPlayer;

// variable used to control whether or not
// this ball will preemptively trigger a
// catch animation in possible targets
var bool m_needToTriggerCatchAnimation;

// used to limit this ball to triggering 1 hit
// reaction.  This is done to prevent a single
// bot from taking multiple hit reactions to a
// single ball.  This will cause a bug if the
// ball is ever able to strike more that one
// bot at a single time (bounce off one bot and
// collide with a second, for example)
var bool m_alreadyTriggeredHitReaction;

// the target the football will home towards.
// This is done to make bots look like they
// are better at throwing the football than
// the simple aiming algorithm actually allows.
var Actor m_homingTarget;

// a record of who threw the ball.
var Pawn m_thrower;

// records that last actor that this ball
// collided with.  Used to help stabilize
// bounce collisions with complicated
// geometry, i.e. any Pawn.
var Actor m_previousBounceTarget;

// records where the ball was last frame
// (used for error recovery caused by the
// pawn landing in a dumb location)
var Vector m_previousLocation;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	StartMoving( );

	bJustThrown = true;
	SetTimer( 0.5, false );
}

// Enough time has elapsed
function Timer( )
{
	bJustThrown = false;
}

// Boom!
simulated function Explode( vector HitLocation, vector HitNormal )
{
	// just delete self for now....
 	Destroy();
}

// starts a timer that will return the
// football to its safe place if it
// waits too long in one location on
// the floor
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment)
function EnableWaitTrigger( )
{
	// enable the trigger if the level has
	// defined a safe goto location
	if ( Level.m_footballSafePoint != NONE &&
		Level.m_footballMaxWaitOnGroundLength > 0.0f )
	{
		SetDelegateTimer( 'GotoSafeLocation',
			Level.m_footballMaxWaitOnGroundLength, false );
	}
}

// turns off the timer that triggers
// the return to a safe location
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment)
function DisableWaitTrigger( )
{
	// turn off the timer to trigger
	SetDelegateTimer( 'GotoSafeLocation', 0.0f, false );
}

// causes this ball to go to its "safe" location
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment/UnReal Event)
function GotoSafeLocation( )
{
	local VietnamPlayerController currentPlayer;

	// just go straight to the safe point
	SetLocation( Level.m_footballSafePoint.Location );
	
	// and fall down
	SetPhysics( PHYS_Falling );
	
	// let the players know we've moved, if desired
	if ( Level.m_footballGotoSafePointMessage != "" )
	{
		foreach DynamicActors( class'VietnamPlayerController',
			currentPlayer )
		{
			// use the progress messages (used for
			// helpful text like which button to
			// press, etc.)
			currentPlayer.SetProgressMessage( 0,
				Level.m_footballGotoSafePointMessage,
				class'HUD'.Default.CyanColor );
			currentPlayer.SetProgressTime( 5.0f );
		}
	}
	
	// reset the bounce target
	m_previousBounceTarget = NONE;
}

// returns a scalar value that describes how to
// attenuate the velocity of a bounced football
//
// inputs:
// inHitThing - what was collided with
//
// outputs:
// scalar damping factor (floating point)
simulated function Float GetBounceDampingFactor(
	Actor inHitThing )
{
	// fleshies do not bounce me as far as non-fleshies.
	// All VietnamPawns are fleshies!
	if ( VietnamPawn( inHitThing ) != NONE )
	{
		return 0.1f;
	}
	// else....
	
	return 0.4f;
}

// performs a bounce response using the new velocity provided
//
// inputs:
// inNewVelocity - the new velocity to use
// Other - the actor that was hit
// inForceResponse - ignore check for collision with previous actor
// inNoHitReaction - disables any hit reactions (used when
// the ball needs to react, but not the Other)
//
// outputs:
// -- none --
simulated function BounceResponse( Vector inNewVelocity,
	Actor Other, bool inForceResponse, bool inNoHitReaction )
{
	// trying to prevent bots that can fly along on the
	// football
	if ( Other.Base == self )
	{
		// get it off me!!!
		Other.SetBase( NONE );
	}

	if
	(
		// proceed if forced,
		inForceResponse
		||
		// if the other is not the previously hit thing
		Other != m_previousBounceTarget
		||
		// or if the other is the previous hit thing,
		// but is in fact world geometry
		(
			Other == m_previousBounceTarget
			&&
			Other.bWorldGeometry
		)
	)
	{
		// since we've collided with something, forget
		// about our homing target( we're _not_ going to
		// get to it after a bounce)
		m_homingTarget = NONE;
	
		// play a hit sound
		if ( Level.NetMode != NM_DedicatedServer )
		{
			PlaySound(ImpactSound, SLOT_Misc, 1.5,,150,,true);
		}

		// Bounce off of the surface and slow down projectile
		Velocity = inNewVelocity;

		// figure out how fast is the ball moving
		speed = VSize( Velocity );

		// if slow enough and the thing being touched
		// is "world geometry," then stop moving
		if ( Other.bWorldGeometry && speed < 20 )
		{
			ComeToRest( );

			// Make the football easier to pickup after it has landed
			SetCollisionSize( 35, default.CollisionHeight );
			
			// call over the closest bot, if that slacker
			// player is too far away
			CallForPickup( );
			
			// also, to be 100% safe, set off a timer that cause
			// me to teleport to a safe location if I end up waiting
			// on the floor too long
			EnableWaitTrigger( );
		}
		else
		{
			// if we hit a thing that should react to being
			// struck by a football, make them react!
			if ( ShouldReactToCollision( Other ) && !inNoHitReaction )
			{
				ForceCollisionReaction( Other );
			}

			// add some random spin as the ball bounces away
			RotationRate.Pitch = RandRange(5000, 30000);
			
			// remember what we hit
			m_previousBounceTarget = Other;

			// Touching a mover across a frame boundary is bad.
			// Separate self just a bit so that doesn't happen.
			if ( Other.IsA( 'Mover' ) )
			{
				SetLocation( Location + Normal( Velocity ) );
			}
		}
	}
}

// Does physics calculation for bouncing off of a surface
simulated function BounceCollision(Vector HitNormal, Actor Other)
{
	BounceResponse( MirrorVectorByNormal( Velocity, HitNormal ) * 
		getBounceDampingFactor( Other ), Other, false, false ); 
}

simulated singular function Touch( Actor Other )
{
	local VietnamPawn asPawn;

	// only respond if this ball has stopped and if
	// the toucher is a VietnamPawn
	asPawn = VietnamPawn( Other );
	if ( !bBounce && asPawn != NONE )
	{
		// give self to the bot if it wants to pick me up
		if ( VietnamBot( asPawn.Controller ).WillPickupFootball( ) )
		{
			GiveFootball( asPawn );
		}
		else
		{
			// otherwise, act as if I've been "kicked"
			BounceResponse( asPawn.Velocity, asPawn, true, false );
		}
	}
}

// returns true if the specified actor should
// react to a football collision
//
// inputs:
// inTarget - the thing to test
//
// outputs:
// true if it should react, false if otherwise
simulated function bool ShouldReactToCollision( Actor inTarget )
{
	// only vietnam bots react to football hits
	if ( VietnamPawn( inTarget ) != NONE &&
		VietnamBot( Pawn( inTarget ).Controller ) != NONE )
	{
		return true;
	}
	// else...
	
	return false;
}

// forces the specified actor to perform
// a hit reaction
//
// inputs:
// inTarget - the thing that should react
//
// outputs:
// -- none --
function ForceCollisionReaction( Actor inTarget )
{
	local VietnamBot myTarget;
	
	if ( !m_alreadyTriggeredHitReaction )
	{
		// get a pointer to the bot's controller so we
		// can make them react to being hit by the ball
		myTarget = VietnamBot( Pawn( inTarget ).Controller );
		
		// tell the controller it's been hit
		myTarget.HitByFootball( self );

		// trigger a flag so this code won't be run again
		// (this code assumes that the football projectile
		// will only ever need to collide once because it
		// will only be thrown once before it is destroyed)
		m_alreadyTriggeredHitReaction = true;
	}
}

// performs collision response for all of the
// various ways that UnReal can collide with
// stuff
//
// inputs:
// inHitActor - who was struck
// inHitNormal - normal to the collision
//
// outputs:
// -- none --
simulated function DoCollisionResponse(
	Actor inHitActor, Vector inHitNormal )
{
	// It is possible to bump the thrower under
	// certain circumstances.  Don't allow that
	// to occur
	if
	(
		inHitActor == Instigator
		&&
		(
			m_previousBounceTarget == NONE
			||
			bJustThrown
		)
	)
	{
		return;
	}
	else
	if( VietnamPawn( inHitActor )? &&
		CanCatch( Pawn( inHitActor ) ) )
	{
		GiveFootball( VietnamPawn( inHitActor ) );
	}
	else
	{
		BounceCollision( inHitNormal, inHitActor );
	}
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	DoCollisionResponse( Wall, HitNormal );
}

// computes a good guess at a collision normal for
// the specified target
//
// inputs:
// inActor - what is being "collided" against
//
// outputs:
// normal to the point of impact
simulated function Vector ComputeCollisionNormal(
	Actor inHitTarget )
{
	local Vector surfaceNormal;
	
	// make it easy, always generate an X,Y collision ray
	// (everything is a cylinder is UnReal, so we can
	// try ignoring Z collision cases for now)
	surfaceNormal   = Location - inHitTarget.Location;
	surfaceNormal.Z = 0;
	surfaceNormal   = Normal( surfaceNormal );
	
	return surfaceNormal;
}

// overridden:  responds to bumps as a football should
//
// inputs:
// inHitTarget - what was bumped
//
// outputs:
// -- none --
simulated function Bump( Actor inHitTarget )
{
	local VietnamPawn hitPawn;
	local Vector      collisionNormal;

	hitPawn = VietnamPawn( inHitTarget );

	if ( hitPawn != NONE &&
		IsEssentiallyEncroached( hitPawn ) )
	{
		ResolveEncroachment( hitPawn );
	}
	else
	{
		if ( Physics == PHYS_Falling )
		{
			collisionNormal = ComputeCollisionNormal( inHitTarget );
			DoCollisionResponse( inHitTarget, collisionNormal );
		}
		else
		{
			if ( hitPawn != NONE && CanCatch( hitPawn ) )
			{
				GiveFootball( hitPawn );
			}
			else
			{
				if ( inHitTarget.Velocity != Vect( 0, 0, 0 ) )
				{
					StartMoving( );
					BounceResponse( inHitTarget.Velocity,
						inHitTarget, true, true );
				}
				else
				{
					DoRandomBounceResponse( hitPawn );
				}
			}
		}
	}
}

// performs a bounce response with a randomized
// velocity vector
//
// inputs:
// hitPawn - the pawn that was collided with
//
// outputs:
// -- none --
simulated function DoRandomBounceResponse( Actor inHitPawn )
{
	local Vector newVelocity;

	newVelocity.X = RandSign( );
	newVelocity.Y = RandSign( );
	newVelocity.Z = FRand( ) * RandSign( );
	
	newVelocity   = Normal( newVelocity ) * Default.Speed / 5.0f;

	StartMoving( );
	
	BounceResponse( newVelocity, inHitPawn, true, true );
}

// overridden:  Ball cannot be destroyed
event TakeDamage( int Damage, Pawn EventInstigator,
	vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller InstigatedByController)
{
	// ball ignores _all_ damage
}

// Gives the football to some guy
function GiveFootball(VietnamPawn Other)
{
	local class< WeaponFootball > footballClass;
	local WeaponFootball          football;

	// only give the target a ball if we haven't
	// already given a ball to the player (a
	// necessary step in the preemptive catch
	// response for players only)
	if ( !m_gaveSelfToPlayer )
	{
		// If a guy catches it, give him the football
		footballClass = class< WeaponFootball >( DynamicLoadObject(
			"VietnamWeapons.WeaponFootball", class'Class' ) );
			
		// don't make a new football if the player already has one
		if ( Other.FindInventoryType( footballClass ) == NONE )
		{
			// make a new football
			football = Other.Spawn( footballClass );

			// If I'm at rest, have the bot pick me up,
			// otherwise I'll need to compute the proper
			// catch animation for it to used based on
			// a comparison of locations
			if ( !bBounce )
			{
				football.SetCatchAsPickup( );
			}
			else
			{
				// catch is being made preemptively
				football.DisableCatchAnimation( );
			}
			
			// give the football to the other
			football.GiveTo( Other );
		}

		// set the ammo for the shiny new ball
		Level.GiveAmmoAmount( Other, class'AmmoFootball', 1 );
	}

	if(bPreciseAimed)
		Other.SendStateMessages('GotPreciseAimedFootball');
	else
		Other.SendStateMessages('GotFootball');

	Destroy();
}

// returns true if the ball is in front of
// the specified Actor
//
// inputs:
// inTarget - the Actor to test
//
// outputs:
// true if in front, false if otherwise
simulated function Bool InFrontOf( Actor inTarget )
{
	// if we are in front of the
	// target, then we will collide
	// with the front of the target

	// if angle between facing vector
	// of the target and vector from
	// target to self is <= 90 degrees,
	// we are in front
	if ( ( Location - inTarget.Location ) DOT
		Normal( Vector( inTarget.Rotation ) ) >= 0 )
	{
		// in front
		return true;
	}
	// behind....

	return false;
}

// returns true if this projectile
// will collide with the front of
// the specified target.
//
// Note:  The difference between this call
// and the InFrontOf( ) function is that
// this function takes into account the
// orientation of the ball and how it is
// moving, whereas InFrontOf( ) only
// considers the positions of the ball and
// target
//
// inputs:
// inTarget - to test
//
// outputs:
// true if a front collision will
// occur, false if otherwise
simulated function bool WillHitFrontOf( Actor inTarget )
{
	// if we are in front of the
	// target, then we will collide
	// with the front of the target

	// if angle between facing vector
	// of the target and vector from
	// target to self is <= 90 degrees,
	// we are in front
	if ( Normal( Vector( Rotation ) ) DOT
		Normal( Vector( inTarget.Rotation ) ) <= 0 )
	{
		// in front
		return true;
	}
	// behind....

	return false;
}

// Makes sure reporter and cameraman can't catch the football
function bool CanCatch( Pawn Other )
{
	// my homing target always wants to catch me!
	// So does a player.  So does a bot willing to
	// catch balls that I am in front of
	if
	(
		// is my homing target
		(
			m_homingTarget != NONE
			&&
			Other == m_homingTarget
		)
		||
		// is a bot that catches balls and I am in front of it
		(
			VietnamBot( Other.Controller ) != NONE
			&&
			VietnamBot( Other.Controller ).WillPickupFootball( )
			&&
			InFrontOf( Other )
		)
		||
		// is a player
		VietnamPlayerController( Other.Controller ) != NONE
	)
	{
		return true;
	}
	// else....

	return false;
}

// returns the location the ball wants
// to track to
//
// inputs:
// -- none --
//
// outputs:
// location of the desired homing target
function Vector ComputeHomingTargetLocation( )
{
	local Vector outVector;
	local Coords boneCoordinates;

	Assert( m_homingTarget != NONE );

	// does this target have a head?
	if ( m_homingTarget.GetBoneIndex( HEAD_BONE ) >= 0 )
	{
		// figure out where the target's head is
		boneCoordinates =
			m_homingTarget.GetBoneCoords( HEAD_BONE );
			
		// use it's position as the homing target
		outVector = boneCoordinates.Origin;
	}
	else
	{
	
		// no head, just shoot at it
		outVector = m_homingTarget.Location;
	}

	return outVector;
}

// overloaded:  slowly turn the
// football towards its intended
// target
//
// inputs:
// inDeltaTime - length of this tick
//
// outputs:
// -- none --
simulated function Tick( float inDeltaTime )
{
	local Vector  toTarget;
	local Rotator deltaHeading, headingModifier;
	local float   smerpAmount;

	// do the parent tasks first
	Super.Tick( inDeltaTime );
	
	// then turn towards my target
	if ( m_homingTarget != NONE )
	{
		// compute difference between our heading
		// and a vector to the target.  If the ball
		// isn't dead on, tweak it slightly so that
		// it's heading is more acceptable
		toTarget     = ComputeHomingTargetLocation( ) - Location;
		deltaHeading = Rotator( toTarget ) - Rotation;
		// for now, use bBounce to know when the
		// velocity has stopped
		if ( toTarget? && Physics == PHYS_Falling && deltaHeading? )
		{
			// smerp the delta heading a bit and
			// add that to the rotation (only
			// affect yaw, otherwise the ball starts
			// to point in odd directions, esp. up or
			// down)
			smerpAmount           = Smerp( SMERP_CONSTANT, 0, 1 );
			headingModifier.Pitch = smerpAmount * deltaHeading.Pitch;
			headingModifier.Roll  = 0; // roll is irrelevant
			headingModifier.Yaw   = smerpAmount * deltaHeading.Yaw;

			// set new rotation
			SetRotation( Rotation + headingModifier );
			
			// also mook velocity to match the rotation direction,
			// as the two should always point the same way, but
			// not necessarily be of the same length
			Velocity = Normal( Vector( Rotation ) ) * VSize( Velocity );
		}
	}

	// have we been sitting in the same place for too long?
	if ( Location == m_previousLocation && Physics == PHYS_Falling &&
		!m_previousBounceTarget.bWorldGeometry )
	{
		// perform a random bounce response to try and jar the
		// pawn out of the rut its in
		DoRandomBounceResponse( m_previousBounceTarget );
	}
	else
	{
		// keep track of the previous location
		m_previousLocation = Location;
	}

	// try and recover from encroachment and basing of
	// other actors on top of me
	RecoverFromEncroachmentAndBasing( inDeltaTime );

	// do we need to bounce away from those who might
	// walk on top of us?
	RespondToActorsThatWontPickUpFootballs( inDeltaTime );

	// notify any bots that will soon catch me that
	// they need to start playing a catch animation
	NotifyCatchers( );
}

// tells any VietnamPawns that are about to catch
// this ball that they should start playing their
// catch animation
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment)
simulated function NotifyCatchers( )
{
	local VietnamPawn    currentPawn;
	local WeaponFootball football;

	// do we even need to trigger a catch animation
	// (only needs to be done once!)
	if ( m_needToTriggerCatchAnimation )
	{
		// is someone close enough that they will soon
		// catch me?  Are they willing to catch me?
		foreach DynamicActors( class'VietnamPawn', currentPawn )
		{
			if ( IsInCatchProximity( currentPawn ) &&
				WillHitFrontOf( currentPawn ) &&
				WillIntercept( currentPawn ) &&
				CanCatch( currentPawn ) )
			{
				// tell them to play a catch animation
				StartCatchAnimation( currentPawn );
				
				// if the pawn we are going to hit is
				// a player, now is a good time to start
				// the first person animation as well
				if ( VietnamPlayerController( currentPawn.Controller )? )
				{
					// spawn a ball now, and give it to
					// the player
					football = currentPawn.Spawn( class'WeaponFootball' );
					football.DisableCatchAnimation( );
					football.GiveTo( currentPawn );
					Level.GiveAmmoAmount( currentPawn, class'AmmoFootball', 1 );
					
					// force that ball into a special
					// catching state that will
					// simulate the catch properly for
					// the player
					football.GotoState( 'Catch' );

					// note that this ball has already
					// given itself away
					m_gaveSelfToPlayer = true;
				}
				
				// stop checking
				m_needToTriggerCatchAnimation = false;
			}
		}
	}
}

// returns true if the specified VietnamPawn is
// close enough that it might catch this ball
//
// inputs:
// inPawn - to test
//
// outputs:
// true if close enough, false if otherwise
simulated function Bool IsInCatchProximity( VietnamPawn inPawn )
{
	// the pawn is close enough if it is within
	// a certain radius of this ball

	if ( VSize( inPawn.Location - Location ) <=
		ComputePreemptiveCatchCheckDistance( ) )
	{
		return true;
	}
	// else.....
	
	return false;
}

// returns the closest player
//
// inputs:
// -- none --
//
// outputs:
// closest player, may be NONE
function VietnamPlayerController FindClosestPlayer( )
{
	local VietnamPlayerController currentController;
	local VietnamPlayerController bestController;
	local float                   distanceToCurrentController;
	local float                   distanceToBestController;

	// walk the list of all actors
	bestController = NONE;
	foreach DynamicActors( class'VietnamPlayerController',
		currentController )
	{
		// only Controllers with live pawns count
		if ( currentController.Pawn != NONE &&
			currentController.Pawn.Health > 0 )
		{
			// figure out the distance to this
			// worthy Controller
			distanceToCurrentController =
				VSize( currentController.Pawn.Location - Location );
				
			// is it closer than the current best?
			if
			( 
				bestController == NONE
				||
				(
					bestController != NONE
					&&
					distanceToCurrentController <
						distanceToBestController
				)
			)
			{
				bestController           = currentController;
				distanceToBestController =
					distanceToCurrentController;
			}
		}
	}
	
	return bestController;
}

// returns the closest bot
//
// inputs:
// -- none --
//
// outputs:
// closest bot, may be NONE
function VietnamBot FindClosestBot( )
{
	local VietnamBot currentController;
	local VietnamBot bestController;
	local float      distanceToCurrentController;
	local float      distanceToBestController;

	// walk the list of all actors
	bestController = NONE;
	foreach DynamicActors( class'VietnamBot',
		currentController )
	{
		// only Controllers with live pawns count
		if ( currentController.Pawn != NONE &&
			currentController.Pawn.Health > 0 &&
			currentController.WillPickupFootball( ) )
		{
			// figure out the distance to this
			// worthy Controller
			distanceToCurrentController =
				VSize( currentController.Pawn.Location - Location );
				
			// is it closer than the current best?
			if
			( 
				bestController == NONE
				||
				(
					bestController != NONE
					&&
					distanceToCurrentController <
						distanceToBestController
				)
			)
			{
				bestController           = currentController;
				distanceToBestController =
					distanceToCurrentController;
			}
		}
	}
	
	return bestController;
}

// instructs whichever bot is the closest,
// and also closer than the player, to come
// to the spot where the ball currently is
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment)
function CallForPickup( )
{
	local float                   distanceToBestPlayer;
	local float                   distanceToBestBot;
	local VietnamPlayerController bestPlayer;
	local VietnamBot              bestBot;

	// find the closest player
	bestPlayer = FindClosestPlayer( );

	// find the closest bot
	bestBot    = FindClosestBot( );

	// it is a valid case where there
	// may be no valid bot or player(?)
	if ( bestPlayer != NONE && bestBot != NONE )
	{
		// is that bot closer than the player?
		distanceToBestPlayer =
			VSize( bestPlayer.Pawn.Location - Location );
		distanceToBestBot    =
			VSize( bestBot.Pawn.Location - Location );
		if ( distanceToBestBot < distanceToBestPlayer &&
			distanceToBestBot <= Level.m_footballMaxPickupSearchRadius )
		{
			// tell it to come over
			bestBot.SimpleMoveToTarget( self );
		}
	}
}

// determines how this football should be caught
//
// inputs:
// inCatcher - the Pawn that will hold this ball
//
// outputs:
// name of the catch animation to play on
// the catching pawn
simulated function Name GetCatchAnimationName(
	VietnamPawn inCatcher )
{
	local float  testZ;
	local Vector projectedLocation;

	// if the pawn is prone, just do a prone catch!
	// if its crouching, do a crouching catch!
	if ( inCatcher.bIsProne )
	{
		return PRONE_CATCH;
	}
	else if ( inCatcher.bIsCrouched )
	{
		return CROUCHING_CATCH;
	}

	// get the z position of the incoming pawn's pelvis
	testZ = inCatcher.GetBoneCoords( 'Bip_Pelvis' ).Origin.Z;
	
	// try to figure out where the ball will hit
	// the player
	projectedLocation = ComputeProjectedLocationFor( inCatcher );

	// determine what catch to use based
	// on the ball's location with respect
	// to the catcher's pelvis bone.
	// (Note:  using the catcher's collision
	// heigh split into three catch zones for
	// the comparison of what animation to play)
	if ( projectedLocation.Z >=
		testZ + inCatcher.CollisionHeight / 6 )
	{
		return HIGH_CATCH;
	}
	else if ( projectedLocation.Z <=
		testZ - inCatcher.CollisionHeight / 6 )
	{
		return LOW_CATCH;
	}
	// else

	return MID_CATCH;
}

// returns the name of the bone that should be used
// to play the catch animation from
//
// inputs:
// inCatcher - the pawn that is catching this ball
//
// outputs:
// name of the animation to play
simulated function Name GetCatchAnimationBlendBone(
	VietnamPawn inCatcher )
{	
	// also, it is very important to set the blend bone
	// for this animation.  The blend bone only needs to
	// be set when the character is moving (this is done
	// to prevent characters' feet from sliding)
	if ( inCatcher.Velocity == Vect( 0, 0, 0 ) )
	{
		// don't need no stinkin' bone!
		return '';
	}
	else
	{
		// use the weapon's bone, it blends just right!
		return class'VietnamWeapon'.Default.m_baseTakeoutBone;
	}
}

// forces the pawn to play a catch animation
//
// inputs:
// inCatcher - the pawn doing the catching
//
// outputs:
// -- none --
simulated function StartCatchAnimation( VietnamPawn inCatcher )
{
	inCatcher.PlayAnim( GetCatchAnimationName( inCatcher ),
		1.0f, 0.0f, inCatcher.FIRINGCHANNEL );
	inCatcher.AnimBlendParams( inCatcher.FIRINGCHANNEL, 1.0f,
		, , GetCatchAnimationBlendBone( inCatcher ), , 
		0.3f, 0.3f, );
}

// returns true if this ball will intercept the
// specified target at some point
//
// inputs:
// inTarget - the VietnamPawn to test
//
// outputs:
// true if the pawn will be intercepted,
// false if otherwise
simulated function bool WillIntercept( VietnamPawn inTarget )
{
	local Vector projectedLocation;

	// Note:  the target is considered intercepted if
	// its collision volume is penetrated by a ray
	// cast from the ball to the target's current location
	projectedLocation = ComputeProjectedLocationFor( inTarget );

	// is that inside the target's collision volume?
	return PointInsideActor( projectedLocation, inTarget );
}

// computes the ball's location when it
// will reach at point about near the
// specified target (used for look-ahead
// calculations for detection and catching
// animations)
//
// inputs:
// inTarget - the thing being thrown to
//
// outputs:
// projected location value at that actor
simulated function Vector ComputeProjectedLocationFor(
	Actor inTarget )
{
	local Vector xyVelocity;
	local float  distanceToTarget;
	local float  timeToCoverDistance;
	local Vector gravityDrop;

	// compute where the ball will be when it reaches
	// the pawn's location (take into account gravity's
	// affect if the thrower was a player)
	distanceToTarget  = VSize( inTarget.Location - Location );
	if ( VietnamPlayerController( m_thrower.Controller ) != NONE )
	{
		// use a velocity with no z component to compute
		// the time to cover the distance, as this is the
		// only relevant velocity for this test (football
		// stuff takes place in a completely 2D level)
		xyVelocity           = Velocity;
		xyVelocity.Z         = 0.0f;
		
		// compute the time needed to cover the distance to
		// the target
		timeToCoverDistance  = distanceToTarget /
			VSize( xyVelocity );
			
		// use that value to compute how much the position
		// will drop over time
		return ( Location + ( Velocity *
			timeToCoverDistance ) + ( 0.5f *
			PhysicsVolume.Gravity *
			timeToCoverDistance * timeToCoverDistance ) );
	}
	// else....

	return ( Location + Normal( Vector( Rotation
			) ) * distanceToTarget );
}

// returns true if the specified location is
// inside the target actor's collision cylinder
//
// inputs:
// inPoint - to test
// inActor - to test against
//
// outputs:
// true if inside, false if otherwise
simulated final function Bool PointInsideActor(
	Vector inPoint, Actor inActor )
{
	local Vector relativeToActor;

	// the point is inside the actor if it
	// is inside the actor's collision cylinder
	relativeToActor = inPoint - inActor.Location;
	if
	(
		Abs( relativeToActor.Z ) <= inActor.CollisionHeight
		&&
		Abs( relativeToActor.X ) <= inActor.CollisionRadius
		&&
		Abs( relativeToActor.Y ) <= inActor.CollisionRadius
	)
	{
		return true;
	}
	// else....
	
	return false;
}

// returns the length of the longest
// catch animation
//
// inputs:
// -- none --
//
// outputs:
// length in seconds of the longest
// catch animation
simulated function Float GetTimeToCatchBall( )
{
	local Name  junk;
	local Float frames, rate, longestTime;

	// compute time for low, mid and high catch animations
	m_thrower.GetAnimSequenceParams( LOW_CATCH, frames, rate );
	longestTime = frames / rate;
	m_thrower.GetAnimSequenceParams( MID_CATCH, frames, rate );
	longestTime = FMax( frames / rate, longestTime );
	m_thrower.GetAnimSequenceParams( HIGH_CATCH, frames, rate );
	longestTime = FMax( frames / rate, longestTime );

	// return the longest time computed (times .25,
	// as the catch animations seem to actually catch
	// the ball at about frame number 2.5 or so)
	return longestTime * CATCH_FRAME;
}

// computes the distance at which to start checking
// for preemptive catching
//
// inputs:
// -- none --
//
// outputs:
// max preemptive catch distance
simulated function Float ComputePreemptiveCatchCheckDistance( )
{
	local Vector xyVelocity;
	
	// take the time it will take to catch the ball,
	// multiply that by the ball's current (X, Y) velocity
	// and return that distance
	xyVelocity   = Velocity;
	xyVelocity.Z = 0.0f;

	return ( GetTimeToCatchBall( ) + BALL_CATCH_FUDGE_FACTOR ) *
		VSize( xyVelocity );
}

// signal that the ball should begin moving
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment)
function StartMoving( )
{
	// start falling, again...
	SetPhysics( PHYS_Falling );

	// restore the collision radius
	SetCollisionSize( Default.CollisionRadius,
		Default.CollisionHeight );

	// stop waiting for a pickup/teleport
	DisableWaitTrigger( );
	
	// reset some values set in the ComeToRest( )
	// function call
	bBounce          = true;
	bRotateToDesired = false;
}

// signal that the ball should stop moving
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment)
function StopMoving( )
{
	SetPhysics( PHYS_None );

	Velocity = Vect( 0, 0, 0 );
}

// returns true if the specified actor
// is about to encroach this football
//
// inputs:
// inActor - to test
//
// outputs:
// true if it will encroach,
// false if otherwise
simulated function bool AboutToEncroach(
	Actor inActor, float inDeltaTime )
{
	local Vector vectorBetween;

	// is the actor moving?	
	if ( inActor.Velocity != Vect( 0, 0, 0 ) )
	{
		// will its collision radius intrude upon
		// mine within the next few frames?
		vectorBetween   = inActor.Location - Location;
		vectorBetween.Z = 0; // ingore height differences
		if ( VSize( vectorBetween ) <=
			inActor.CollisionRadius + CollisionRadius +
			VSize( inActor.Velocity ) * inDeltaTime * 2.0f ) // scale by 2 to check ahead 2 frames
		{
			return true;
		}
	}
	// else....
	
	return false;
}

// reponds to actors that are about to
// encroach the football by acting as if
// the actor has "kicked" the ball
//
// inputs:
// inDeltaTime - length of the current frame
//
//outputs:
// -- none -- (code segment)
simulated function RespondToActorsThatWontPickUpFootballs(
	float inDeltaTime )
{
	local VietnamPawn currentPawn;
	local VietnamBot  currentController;

	// only respond while "sitting still"
	if ( Physics != PHYS_Falling )
	{
		// look for bots that are about to encroach
		ForEach DynamicActors( class'VietnamPawn', currentPawn )
		{
			currentController = VietnamBot( currentPawn.Controller );
			if ( AboutToEncroach( currentPawn, inDeltaTime ) &&
				currentController? && !currentController.WillPickupFootball( ) )
			{
				// this pawn is too close and will hit me.
				// Run away!
				StartMoving( );
				BounceResponse(
					ComputeNewVelocityFromActor(
					currentPawn ), currentPawn,
					true, true );

				// stop processing
				return;
		}
		}
	}
}

// computes a new velocity based upon the
// specified actor's velocity
//
// inputs:
// inActor - used to compute the new velocity
//
// outputs:
// new velocity
simulated function Vector ComputeNewVelocityFromActor(
	Actor inActor )
{
	local Vector newVelocity;
	
	Assert( inActor.Velocity != Vect( 0, 0, 0 ) );
	
	// base new velocity off vector cast away from
	// the actor at a speed relative to the actor's
	// velocity
	newVelocity    = Location - inActor.Location;
	newVelocity.Z  = 0.0f;
	newVelocity    = Normal( newVelocity );
	newVelocity.Z  = 1.0f;
	newVelocity    = Normal( newVelocity );
	newVelocity   *= VSize( inActor.Velocity ) *
		4.0f; // scale by 4 because it works
		
	return newVelocity;
}

// returns true if this ball is within
// the collision radius (but not height)
// of the specified actor
//
// inputs:
// inActor - to test
//
// outputs:
// true if 2D collision has occurred,
// false if otherwise
simulated function bool Is3DEncroached( Actor inActor )
{
	local Vector delta2D;
	local Float  deltaZ;
	
	delta2D   = Location - inActor.Location;
	delta2D.Z = 0;
	deltaZ    = Abs( Location.Z - inActor.Location.Z );
	if ( Vsize( delta2D ) <= inActor.CollisionRadius +
		CollisionRadius && deltaZ <=
		( inActor.CollisionHeight + CollisionHeight ) / 2 )
	{
		return true;
	}
	// else....
	
	return false;
}

// resolves encroachment by placing
// the ball on top of the specified
// actor's head and then bouncing it
//
// inputs:
// inActor - to put the ball on
//
// outputs:
// -- none --
simulated function ResolveEncroachment( Actor inActor )
{
	local Vector      newLocation;
	local Float       newZ;

	// move me onto that pawn's head and
	// then do a random collision response
	if ( inActor.Base == self )
	{
		inActor.SetBase( NONE );
	}
	newZ          = inActor.CollisionHeight /
		2.0f + CollisionHeight * 0.75f +
		inActor.Location.Z;
	newLocation   = Location;
	newLocation.Z = newZ;
	SetLocation( newLocation );
	if( inActor.Velocity != Vect( 0, 0, 0 ) )
	{
		BounceResponse(
			ComputeNewVelocityFromActor( inActor ),
			inActor, true, true );
	}
	else
	{
		DoRandomBounceResponse( inActor );
	}
}

// returns true if the ball in encroaching the
// specified VietnamPawn in some way
//
// inputs:
// inPawn - to check
//
// outputs:
// true if encroached, false if otherwise
simulated function bool IsEssentiallyEncroached(
	VietnamPawn inPawn )
{
	local VietnamBot currentBot;

	currentBot = VietnamBot( inPawn.Controller );

	// the pawn is encroached if it is based on
	// the ball or if the ball is inside the 2D
	// radius of the pawn.  Only matters if the
	// pawn belongs to a bot that doesn't catch
	// balls or the player when the ball has just
	// been thrown
	if
	(
		(
			inPawn.Base == self
			||
			Is3DEncroached( inPawn )
			&&
			(
				currentBot?
				&&
				!currentBot.WillPickupFootball( )
			)
		)
		||
		(
			VietnamPlayerController( inPawn.Controller )?
			&&
			inPawn.Base == self
		)
	)
	{
		return true;
	}
	// else....
	
	return false;
}

// tries to recover the football from encroachment
// and actors that have become based upon the ball
//
// inputs:
// inDeltaTime - length of this frame
//
// outputs:
// -- none --
simulated function RecoverFromEncroachmentAndBasing(
	Float inDeltaTime )
{
	local VietnamPawn currentPawn;

	// if I have become encroached or am serving
	// as the base for any actors in the scene,
	// move me onto that actor's head and cease
	// motion (thus causing the stuck on an actor's
	// head recovery code to take over)
	ForEach DynamicActors( class'VietnamPawn', currentPawn )
	{
		if ( IsEssentiallyEncroached( currentPawn ) )
		{
			ResolveEncroachment( currentPawn );
			
			// should only be 1 pawn to check
			return;
		}
	}
}

defaultproperties
{
     m_needToTriggerCatchAnimation=True
     ProjectileSoundNames(0)=(PackageName="weapon_snd",ResourceName="GrenadeExplodeClose")
     ProjectileSoundNames(1)=(PackageName="weapon_snd",ResourceName="BombInWater")
     m_useRandomSpin=False
     speed=2000.000000
     MaxSpeed=3000.000000
     TossZ=150.000000
     Damage=220.000000
     DamageRadius=1200.000000
     MomentumTransfer=10.000000
     MyDamageType=Class'VietnamGame.DamageGrenade'
     ExplosionDecal=Class'VietnamEffects.Decal'
     ExploWallOut=10.000000
     bUnlit=False
     bBlockPlayers=True
     bProjTarget=True
     bUseCylinderCollision=True
     bBounce=True
     bFixedRotationDir=True
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
     LifeSpan=0.000000
     SoundRadius=10.000000
     SoundVolume=218
     CollisionRadius=20.000000
     CollisionHeight=10.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     AssetName="weapons_stat.football.football_stat"
}
