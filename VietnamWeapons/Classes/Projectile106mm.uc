//=============================================================================
// Projectile106mm.uc
//=============================================================================
class Projectile106mm extends VietnamProjectile;

var bool bArmed;	// It takes time to arm
var bool bDud;		// If it hits something without arming, it becomes a dud
var config float fArmTime;
var config int	iMinNumShrapnelPieces;
var config int	iMaxNumShrapnelPieces;


var Actor HomingTarget;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.3125, false);                  //Projectile begins unarmed, arms at 10m

	Instigator = Pawn(Owner);

	if ( Role == ROLE_Authority )
	{
		Velocity = GetModifiedTossVelocity(InstigatorVelocity, Rotation);
		
		if (Instigator? )
		{
			Instigator.EnsurePhysVolsNotBorked( );

			if ( Instigator.HeadVolume.bWaterVolume )
			{
				bHitWater = True;
				Velocity *= 0.6;
			}
		}
	}	
}

// Arm after a half-second
simulated function Timer()
{
	if(bDud != true)
		bArmed = true;
	else
		Destroy();
}

// Make the RPG7 turn into a dud
function GoDud()
{
	if(!bDud)
	{
		bDud = true;
		SetTimer(10.0,false);
	}
}

// Boom!
// Don't explode if grenade isn't armed yet
simulated function Explode(vector HitLocation, vector HitNormal)
{
	local ProjectileShrapnel Shrapnel;
	local int i;
	local vector Direction;
	local Emitter ExplosionEmitter;
	local int iNumShrapnelPieces;

	// If something is hit before grenade is armed, it becomes a dud
	if(!bArmed)
	{
		if(!bDud)
		{
			GoDud();
			return;
		}
		else
			return;
	}


	BlowUp(HitLocation);

	// Our owner should not be immune to taking damage!
	SetOwner(None);

	if(bHitWater)
	{
		// Spawn the explosion
		
		//ExplosionEmitter = spawn(class'WaterGrenadeExplosionEffect',self,,vEnterWaterLocation,rot(16384,0,0));
		ExplosionEmitter = spawn(class'HackDefaultParticleEffect',self,,vEnterWaterLocation,rot(16384,0,0));
		//log("constructing WaterGrenadeExplosionEffect");
		
		// only start the effect on the server
		if ( Level.NetMode != NM_Client )
		{
			ExplosionEmitter.LookupConstruct("WaterGrenadeExplosionEffect");	
		}

		// Make a neato sound
		if ( Level.NetMode != NM_DedicatedServer )
		{
			ExplosionEmitter.PlaySound( ProjectileSounds[
				EProjectileSound.EPS_WaterExplosion ],
				SLOT_Misc, 1.0, , 10000, , false );
		}
	}
	else
	{
		// Spawn the explosion 			
		//ExplosionEmitter = spawn(class'RPGExplosion',self,,HitLocation + vect(0,0,10),rot(16384,0,0));
		ExplosionEmitter = spawn(class'HackDefaultParticleEffect',self,,HitLocation + vect(0,0,10),rot(16384,0,0));
		//log("constructing RPGExplosion");

		// only start the effect on the server
		if ( Level.NetMode != NM_Client )
		{
			ExplosionEmitter.LookupConstruct("RPGExplosion");	
		}

		// Make a neato sound
		if ( Level.NetMode != NM_DedicatedServer )
		{
			ExplosionEmitter.PlaySound( ProjectileSounds[
				EProjectileSound.EPS_Explosion ], SLOT_Misc,
				1.0, , 10000, , false );
		}
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		RadiusShake(ShakeParams, m_flShakeRadius);
	}

	// Now spawn some fragments
	// only start the effect on the server
	if ( Level.NetMode != NM_Client )
	{
		iNumShrapnelPieces = iMaxNumShrapnelPieces - iMinNumShrapnelPieces;
		iNumShrapnelPieces = Rand( iNumShrapnelPieces ) + iMinNumShrapnelPieces;
		for(i=0;i<iNumShrapnelPieces;i++)
		{
			Direction = VRand();
			
			// This will produce a result that isn't normalized, but who really cares, no one sees
			// the damn shrapnel anyway it's so damn small...
			
			// Spawn may fail sometimes (can't spawn inside another object?), so check the result
			Shrapnel = spawn(class'ProjectileShrapnel',self,,Location+(Direction + HitNormal * 10));
			if(Shrapnel != None)
			{
				Shrapnel.Velocity = Direction * Shrapnel.Speed;
				Shrapnel.InstigatorController = InstigatorController;
			}
		}
	}

 	Destroy();
}

// This function is never reached??  This needs more investigation
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local vector HitNormal;

//	log("RPG7 touched: " $ Other.Name);

	if(Other.bBlockProjectiles)
	{
		HitNormal = Normal(HitLocation - Other.Location);
	
		BounceCollision(-Normal(Velocity), Other);

		Explode(HitLocation, HitNormal);
	}
}

// This is called for anything hit, wall, player, etc.
simulated function HitWall( vector HitNormal, actor Wall )
{
	local bool bPuncture;

	// Hit something without arming means become a dud
	// Possibly spear a guy, and if not then bounce
	if(!bArmed)
	{
		GoDud();

		if(Pawn(Wall) != None)
		{
			Wall.TakeDamage( 100, Pawn(Owner), Location, vect(0,0,0), class'DamageBullet', InstigatorController);
			bPuncture = CheckForPuncture(Wall);
		}

		// If we didn't puncture the guy, bounce off of him
		if(!bPuncture)
		{
			Wall.TakeDamage( 25, Pawn(Owner), Location, vect(0,0,0), class'DamageBullet', InstigatorController);

			BounceCollision(HitNormal, Wall);
		}
	}
	else
	{
		// If it's armed and hits something, it will explode
		Explode(Location, HitNormal);
	}
}

function bool CheckForPuncture(Actor Other)
{
	local vector HitLocation, HitNormal, TraceStart, EndTrace, vForward;
//	local actor Other;
	local int iHitBone;
	local VietnamPawn tmpPawn;
	local name StabbedBoneName;
	local vector KnifePosition;

	TraceStart = Location;

	vForward = Normal(Velocity);

	EndTrace = Other.Location;

	// Do the trace
	Other = Trace(HitLocation,HitNormal,EndTrace,TraceStart,True, , , iHitBone);

//	log("Trace for puncture Other: " $ Other);

	if ( Other != None && Other.IsA('VietnamPawn'))
	{
		tmpPawn = VietnamPawn(Other);
		tmpPawn.LastHitBone = iHitBone;

		StabbedBoneName = tmpPawn.GetBoneName(iHitBone);

/*
		// If the hit location is not the head or chest, do bounce
		switch(tmpPawn.DetermineHitLocation(iHitBone))
		{
		case tmpPawn.HitLocation_e.HL_Head:
		case tmpPawn.HitLocation_e.HL_Torso:
			break;
		}
*/

		// SetLocation() is unnecessary
		tmpPawn.AttachToBone(self, StabbedBoneName);

		HitLocation = HitLocation - tmpPawn.GetBoneCoords(StabbedBoneName).Origin;
		KnifePosition = HitLocation << tmpPawn.GetBoneRotation(StabbedBoneName);

//		SetRelativeLocation(KnifePosition);
		SetRelativeLocation(vect(0,0,0));
		// This sets the rocket to point down the guy's vForward
//		SetRelativeRotation(rotator(vForward << tmpPawn.GetBoneRotation(StabbedBoneName))/* + rot(0,32768,0)*/);
		SetRelativeRotation(rotator(vForward >> tmpPawn.GetBoneRotation(StabbedBoneName)) + rot(0,16384,0));

		return true;
	}

	return false;
}

// Does physics calculation for bouncing off of a surface
// TODO: After RPG7 hits ground, does it keep thrusting or should it stop?
simulated function BounceCollision(Vector HitNormal, Actor Other)
{
	local rotator TempRotation;
	local bool bGround;

	Velocity += ((Velocity dot HitNormal) * HitNormal  * -2);
	Velocity *= 0.2;

//	log("Velocity: " $ Velocity);

	speed = VSize(Velocity);

	bGround = HitNormal.z > 0.7;

	if ( Level.NetMode != NM_DedicatedServer )
		PlaySound(ImpactSound, SLOT_Misc, 1.5,,150,,true);


	if ( Other.bWorldGeometry && speed < 40 && bGround) 
	{
//		log("RPG7 coming to rest");

		bBounce = False;
		SetPhysics(PHYS_Rotating);
		Acceleration = vect(0,0,0);

//		log("Rotation: " $ Rotation.pitch);
//		log("Rotation comparison: " $ CompareRotationComponent(Rotation.pitch, 0));

		// Make sure object comes to a rest in an appropriate looking position
		TempRotation = Rotation;
		if(abs(CompareRotationComponent(Rotation.pitch, 0)) < 16384)
			TempRotation.Pitch = 0;
		else
			TempRotation.Pitch = 32768;

		bRotateToDesired = true;
		DesiredRotation = TempRotation;
		RotationRate = rot(30000,30000,30000);
	}
	else
	{
//		log("RPG7 bouncing");

		// After bouncing, thrust turns off
		SetPhysics(PHYS_Falling);
		RandSpin(10000);
	}
}

function Tick(float DeltaTime)
{
	local vector DesiredDirection;

	Super.Tick(DeltaTime);

	if(HomingTarget?)
	{
		DesiredDirection = HomingTarget.Location - Location;
		DesiredDirection = Normal(DesiredDirection);

		// Update our rotation
		SetRotation(rotator(DesiredDirection));

		// Update our velocity
		Velocity = VSize(Velocity) * DesiredDirection;
	}
}

static function StaticPrecacheAssets(optional Object MyLevel)
{
	local class<Actor> ShrapnelClass;

	Super.StaticPrecacheAssets(MyLevel);

	ShrapnelClass = class<Actor>(DynamicLoadObject("VietnamGame.ProjectileShrapnel", class'StaticMesh'));
	ShrapnelClass.static.StaticPrecacheAssets();
}

defaultproperties
{
     fArmTime=0.312500
     iMinNumShrapnelPieces=10
     iMaxNumShrapnelPieces=12
     ProjectileSoundNames(0)=(PackageName="weapon_snd",ResourceName="GrenadeExplodeClose")
     ProjectileSoundNames(1)=(PackageName="weapon_snd",ResourceName="BombInWater")
     m_flShakeRadius=1200.000000
     ShakeParams=(RotationAmount=(X=500.000000,Y=500.000000),MaxRotationAmount=(X=500.000000),bRandomDirection=True,bRecoverBetweenKicks=True,DecayTime=1.500000,BlurScale=3.000000)
     speed=4000.000000
     MaxSpeed=5000.000000
     TossZ=0.000000
     Damage=220.000000
     DamageRadius=1200.000000
     MomentumTransfer=10.000000
     MyDamageType=Class'VietnamGame.DamageGrenade'
     ExplosionDecal=Class'VietnamEffects.Decal'
     ExploWallOut=10.000000
     bUnlit=False
     bBlockActors=True
     bBlockPlayers=True
     bUseCylinderCollision=True
     bBounce=True
     DrawType=DT_StaticMesh
     LifeSpan=10.000000
     SoundRadius=10.000000
     SoundVolume=218
     CollisionRadius=5.000000
     CollisionHeight=5.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     AssetName="weapons_stat.shells.rpg7_shot_stat"
}
