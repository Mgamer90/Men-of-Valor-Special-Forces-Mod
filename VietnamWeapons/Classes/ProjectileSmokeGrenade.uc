//=============================================================================
// ProjectileSmokeGrenade.uc
//=============================================================================
class ProjectileSmokeGrenade extends VietnamProjectile;

var Emitter MyEmitter;
var bool bFirstTimer;

var config float fArmTime;
// Move these two vars up to VietnamProjectile
//var config float fMinWaitTime;
//var config float fMaxWaitTime;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(fArmTime,false);                  //Grenade begins unarmed
}

// First time through drop the handle thingy, next time blow up
simulated function Timer()
{
//	local FallingMeshDebris	Debris;
	local float fWaitTime;

	if(bFirstTimer)
	{
		bFirstTimer = false;
		
		// BJ changed so can use config vars to specify how long the grenade smokes for
		fWaitTime = FRand() * (fMaxWaitTime-fMinWaitTime);
		fWaitTime += fMinWaitTime;
		SetTimer(fWaitTime,false);
/*
		// Spawn handle
		Debris = Spawn(class'FallingMeshDebris', self);
//		Debris.SetStaticMesh(StaticMesh'Grenade_smoke_shell_stat');
		Debris.SetStaticMesh(
			StaticMesh(DynamicLoadObject("Weapons_stat.Grenade_smoke_shell_stat",class'StaticMesh')));

		Debris.Velocity = Velocity * 0.4;
*/
	}
	else
	{
		Explode(Location+Vect(0,0,1)*16, vect(0,0,1));
	}
}

// Boom!
simulated function Explode(vector HitLocation, vector HitNormal)
{
	if(ROLE == ROLE_Authority)
	{
		Level.Game.CallMortarStrike(InstigatorController, Location);
	}

	BlowUp(HitLocation);

	if ( Level.NetMode != NM_DedicatedServer )
	{
		// Make a sound
		PlaySound(ProjectileSounds[EProjectileSound.EPS_Explosion],,,,1000,,true);
	}

	// Spawn the explosion
	// only spawn the effect on the server
	if ( Level.NetMode != NM_Client )
	{
		//MyEmitter = spawn(class'SmokeGrenadeRedEffect',self,,Location + vect(0,0,5),rot(16384,0,0));
		MyEmitter = spawn(class'HackDefaultParticleEffect',,,Location + vect(0,0,5),rot(16384,0,0));
		//log("constructing SmokeGrenadeRedEffect");

		MyEmitter.LookupConstruct("SmokeGrenadeRedEffect");	

		MyEmitter.setBase( self );
		MyEmitter.PlaySound(ProjectileSounds[2],,,,1000,,true);
	}
}

// Does physics calculation for bouncing off of a surface
simulated function BounceCollision(Vector HitNormal, Actor Other)
{
//	Velocity = 0.5*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	Velocity += (Velocity dot HitNormal * HitNormal * -2);
	Velocity *= 0.4;

	RandSpin(35000);
	speed = VSize(Velocity);
	
	// Play impact sound
	PlaySound(ProjectileSounds[1], SLOT_Misc, 1.5,,150,,true);

//	if ( Velocity.Z > 400 )
//		Velocity.Z = 0.5 * (400 + Velocity.Z);
//	else 

	if ( Other.bWorldGeometry && speed < 50 ) 
	{
		// this makes sure that the smoke emitted from the grenade points up
		MyEmitter.setRotation( rot( 16384, 0, 0 ) );

		bBounce = False;
		SetPhysics(PHYS_None);
	}
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if(Other != Instigator && Other.bBlockProjectiles)
		BounceCollision(-Normal(Velocity), Other);
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	BounceCollision(HitNormal, Wall);
}

simulated function Destroyed()
{
	local VietnamPlayerController VPC;

	Super.Destroyed();

	if(InstigatorController?)
	{
		VPC = VietnamPlayerController(InstigatorController);
		if(VPC?)
		{
			VietnamPlayerController(InstigatorController).bCanThrowSmokeGrenade = true;
			//log("TSS: Letting " $ VPC $ " throw again");
		}
	}
}

defaultproperties
{
     bFirstTimer=True
     fArmTime=0.100000
     ProjectileSoundNames(0)=(PackageName="weapon_snd",ResourceName="SmokeGrenade")
     ProjectileSoundNames(1)=(PackageName="weapon_snd",ResourceName="GrenadeHitDirt")
     ProjectileSoundNames(2)=(PackageName="weapon_snd",ResourceName="SmokeGrenadeHiss")
     speed=400.000000
     DamageRadius=0.000000
     MomentumTransfer=10.000000
     MyDamageType=None
     ExploWallOut=10.000000
     bUnlit=False
     bBlockActors=True
     bUseCylinderCollision=True
     bBounce=True
     bFixedRotationDir=True
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
     LifeSpan=30.000000
     SoundRadius=10.000000
     SoundVolume=218
     CollisionRadius=5.000000
     CollisionHeight=7.500000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     AssetName="weapons_stat.us.grenade_smoke_bullet_stat"
}
