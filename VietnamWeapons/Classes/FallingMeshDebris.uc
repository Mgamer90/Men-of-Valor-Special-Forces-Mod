//====================================================================================
// FallingMeshDebris
// Class for stuff that falls and bounces slightly, despite the name it's a staticmesh
// by default
//====================================================================================

class FallingMeshDebris extends Projectile;

var bool bHitWater;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Role == ROLE_Authority )
	{
//		Velocity = GetTossVelocity(Instigator, Rotation);

		RandSpin(35000);
		
		Instigator.EnsurePhysVolsNotBorked( );

		if ( WaterVolume(Instigator.HeadVolume) != None )
		{
			bHitWater = True;
			Velocity *= 0.6;
		}
	}	
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	// Who cares?  I'm a timed grenade!
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	Velocity += (Velocity dot HitNormal * HitNormal * -2);
	Velocity *= 0.2;

	RandSpin(35000);
	speed = VSize(Velocity);

	if ( Level.NetMode != NM_DedicatedServer )
		PlaySound(ImpactSound, SLOT_Misc, 1.5,,150,,true);

	if ( speed < 100 ) 
	{
		bBounce = False;
		SetPhysics(PHYS_None);
	}
}

defaultproperties
{
     speed=400.000000
     TossZ=0.000000
     bUnlit=False
     bCollideActors=False
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bUseCylinderCollision=True
     bBounce=True
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
     LifeSpan=2.000000
     CollisionRadius=5.000000
     CollisionHeight=5.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
