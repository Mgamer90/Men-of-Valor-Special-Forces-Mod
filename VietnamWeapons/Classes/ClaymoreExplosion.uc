// does exactly what the GrenadeExplosion does,
// except that it causes damage in an arc
//
// Revision History:
//
// Create on 1-29-2004
//

class ClaymoreExplosion extends GrenadeExplosion;

// the blast arc of a claymore explosion
const BLAST_ARC = 10922; // roughly, a 60 degree arc

// returns true if the specified location is
// withing the facing arc described by the
// input arc size and facing direction
//
// inputs:
// inArcSize - in UnReal Radians
// inArcFacingDirection - direction the center-most
// arc point faces
// inTargetPoint - to test
//
// outputs:
// true if point is within arc, false if otherwise
simulated function Bool IsWithinFacingArc(
	Int inArcSize, Vector inArcFacingDirection,
	Vector inTargetPoint )
{
	local Int facingYaw, yawToTarget, angleBetween;

	Assert( inArcSize >= 0 );
	
	// compute the facing yaw
	facingYaw    = Rotator( inArcFacingDirection ).Yaw;
	
	// compute the yaw to the target
	yawToTarget  = Rotator( inTargetPoint - Location ).Yaw;
	
	// compute the angle between
	// the to vector and the facing
	// vector
	angleBetween = Max( facingYaw, yawToTarget ) -
		Min( facingYaw, yawToTarget );
	if ( angleBetween > 32768 )
	{
		angleBetween = 65536 - angleBetween;
	}

	// the point is within the arc if the angle
	// between the two vectors is <= 1/2 the
	// specified arc size
	if ( angleBetween <= ( inArcSize / 2 ) )
	{
		return true;
	}
	// else....
	
	return false;
}

// like the HurtRadius function, but you specify
// a facing vector and an arc size (<= 65536)
//
// inputs:
// DamageAmount - amount of hurt to create
// DamageRadius - width of the arc
// inArcSize - degree spread of the arc (in UnReal radians)
// inArcFacingDirection - facing direction of the
// center-most part of the arc
// DamageType - type of hurt to create
// Momentum - ?
// HitLocation - ??
simulated final function HurtArc( float DamageAmount,
	float DamageRadius, Int inArcSize, Vector inArcFacingDirection,
	class<DamageType> DamageType,float Momentum, vector HitLocation )
{
	local Actor Victims;
	local float damageScale, dist;
	local vector dir;
	
	if( bHurtEntry )
		return;

	bHurtEntry = true;
	//foreach VisibleCollidingActors( class'Actor', Victims, DamageRadius, HitLocation)
	// do not use VisibleCollidingActors ... its doesn't work when HurtRadius is called from within a volume ( i.e. water )
	// CollidingActors does not do a trace which means it "hits" things through solid objects
	foreach VisibleCollidingActors( class'Actor', Victims, DamageRadius, HitLocation)
	{
		if( ( Victims != self ) && ( Victims.Role == ROLE_Authority ) &&
			IsWithinFacingArc( inArcSize, inArcFacingDirection, Victims.Location ) )
		{
			// TSS: This needs to be able to damage triggers, 

			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
		}
	}
	bHurtEntry = false;
}

// overloaded:  directional, fan-shaped damage
//
// inputs:
// -- none --
//
// outputs:
// -- none --
function CauseDamage( )
{
	// Need to use the spanky new hurt arc code
	// for a claymore
	HurtArc( fDamageAmount, fDamageRadius, BLAST_ARC,
		Vector( Rotation ), class'DamageGrenade',
		fDamageAmount, Location );
}

defaultproperties
{
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
