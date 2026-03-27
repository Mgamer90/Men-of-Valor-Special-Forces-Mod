//=============================================================================
// ProjectileM79SmokeGrenade.uc
//=============================================================================
class ProjectileM79SmokeGrenade extends VietnamProjectile;

var Emitter MyEmitter;

// Since after hitting a wall this grenade stays around awhile and will generate more
// HitWall()'s, we have to make sure explode only gets called once
var bool bExploded;
var bool bArmed;

var config float fArmTime;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(fArmTime, false);
	if ( Role == ROLE_Authority )
	{
		Velocity = GetTossVelocity(Instigator, Rotation);

/*
		KWake();
		KSetSkelVel(Velocity);
		KAddImpulse(Velocity, Location);
		KAddForce(Velocity);
*/

//		RandSpin(35000);	

		// Adjust for model's rotation
		SetRotation(Rotation + rot(0, 16384, 0));

		Instigator.EnsurePhysVolsNotBorked( );

		if ( WaterVolume(Instigator.HeadVolume) != None )
		{
			bHitWater = True;
			Velocity *= 0.6;
		}
	}	
}

simulated function Timer()
{
	bArmed = true;

	// If we've already landed, trigger the grenade
	if(bBounce == false)
		Explode(Location, vect(0,0,0));

	// For now, don't destroy the smoke grenade
//	Destroy();
}

function NotifyControllers()
{
	local Controller C;
	
	for (C = Level.ControllerList; C?; C = C.nextController)
	{
		C.AddObstruction('SmokeGrenade',Location,512,256,20.f,0.9f,0.f,0.5f);
	}
}

// Boom!
// This (obviously) only runs once per grenade, so it checks bExploded to see if it already ran
simulated function Explode(vector HitLocation, vector HitNormal)
{
	// Check if we're already dead
	if(bExploded || !bArmed)
		return;
		
	bExploded = true;
	
	BlowUp(HitLocation);


	if ( Level.NetMode != NM_DedicatedServer )
	{
		// Make a neato sound
		PlaySound(ProjectileSounds[EProjectileSound.EPS_Explosion],,,,1000,,true);
	}

	// Spawn the explosion
	// only start the effect on the server
	if ( Level.NetMode != NM_Client )
	{
		//MyEmitter = spawn(class'SmokeGrenadeWhiteCover',self,,Location + vect(0,0,10),rot(16384,0,0));
		MyEmitter = spawn(class'HackDefaultParticleEffect',self,,Location + vect(0,0,10),rot(16384,0,0));
		//log("constructing SmokeGrenadeWhiteCover");
	
		MyEmitter.LookupConstruct("SmokeGrenadeWhiteCover");

		NotifyControllers();
	}

	SetTimer(5.0, false);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local vector HitNormal;

	if(Other != Instigator && Other.bBlockProjectiles)
	{
		HitNormal = Normal(HitLocation - Other.Location);
	
		BounceCollision(-Normal(Velocity), Other);
	}
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	BounceCollision(HitNormal, Wall);
}

// Does physics calculation for bouncing off of a surface
simulated function BounceCollision(Vector HitNormal, Actor Other)
{
	local bool bGround;

//	Velocity = 0.5*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	Velocity += (Velocity dot HitNormal * HitNormal * -2);
	Velocity *= 0.3;

	RandSpin(35000);
	speed = VSize(Velocity);

	bGround = HitNormal.z > 0.7;

	// Play impact sound
	PlaySound(ProjectileSounds[1], SLOT_Misc, 1.5,,150,,true);

	if ( Other.bWorldGeometry && speed < 50 && bGround)
	{
		bBounce = False;
		SetPhysics(PHYS_None);
		Explode(location, HitNormal);
	}
}

/*
// Make sure to turn off the emitter when the grenade disappears
function Destroyed()
{
	MyEmitter.emitters[0].InitialParticlesPerSecond = 0.0;
	MyEmitter.emitters[0].ParticlesPerSecond = 0.0;
}
*/

defaultproperties
{
     fArmTime=3.000000
     ProjectileSoundNames(0)=(PackageName="weapon_snd",ResourceName="SmokeGrenade")
     ProjectileSoundNames(1)=(PackageName="weapon_snd",ResourceName="GrenadeHitDirt")
     speed=4000.000000
     MaxSpeed=5000.000000
     DamageRadius=0.000000
     MomentumTransfer=10.000000
     MyDamageType=None
     ExploWallOut=10.000000
     bUnlit=False
     bUseCylinderCollision=True
     bBounce=True
     bFixedRotationDir=True
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
     LifeSpan=15.000000
     DrawScale=2.000000
     SoundRadius=10.000000
     SoundVolume=218
     CollisionRadius=5.000000
     CollisionHeight=5.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     AssetName="weapons_stat.shells.smoke_shot_stat"
}
