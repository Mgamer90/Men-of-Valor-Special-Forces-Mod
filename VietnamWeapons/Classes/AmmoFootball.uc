//=============================================================================
// AmmoFootball
// class for footballs
//=============================================================================
class AmmoFootball extends VietnamAmmo;

// produces a new football projectile
//
// inputs:
// Start - starting position in the world
// Dir - direction it should face
// ThrowStrength - how hard the football was thrown
// bPreciseAimed - if true, the ball is assumed to 
// have been thrown with "precise aim"
// inHomingTarget - who the projectile is seeking
// inThrower - who threw this ball
function SpawnFootball( vector Start, rotator Dir,
	float ThrowStrength, bool bPreciseAimed,
	Actor inHomingTarget, Pawn inThrower )
{
	local ProjectileFootball newFootball;
	
	AmmoAmount -= 1;
	newFootball = ProjectileFootball( Spawn(
		MyProjectileClass, Owner, , Start, Dir ) );

	if( Instigator? )
		newFootball.InstigatorVelocity = Instigator.Velocity;

	newFootball.Initialize( ThrowStrength );

	// Copy over parameter
	newFootball.bPreciseAimed  = bPreciseAimed;
	
	// set the homing target
	newFootball.m_homingTarget = inHomingTarget;
	
	// set the thrower
	newFootball.m_thrower      = inThrower;
}

defaultproperties
{
     MyProjectileClass=Class'VietnamWeapons.ProjectileFootball'
     MaxAmmo=1
     AmmoAmount=0
     bInstantHit=False
     ItemName="Football"
     bActorShouldTravel=False
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
