//=============================================================================
// ProjectileRPG7.uc
// Uses two trail emitters, one visible to the player who fired the rocket
// and one visible only to those who didn't fire the rocket
//=============================================================================
class ProjectileRPG7 extends VietnamProjectile
	native
	nativereplication;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var bool bArmed;	// It takes time to arm
var bool bDud;		// If it hits something without arming, it becomes a dud
var bool bPunctured;	// Punctured something

//var RPG1stPersonTrail FPEmitter;
//var RPG3rdPersonTrail TPEmitter;
var HackDefaultParticleEffect FPEmitter;
var HackDefaultParticleEffect TPEmitter;

var Actor HomingTarget;

var config float fArmTime;
var config int	iMinNumShrapnelPieces;
var config int	iMaxNumShrapnelPieces;

var bool bTriggerExplosionEffects;

replication
{
	reliable if( (Role==ROLE_Authority) && bNetInitial)
		HomingTarget;

	reliable if ( bNetDirty && ( Role == ROLE_Authority ) )
		bDud, bTriggerExplosionEffects;

}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(fArmTime, false);                  //Projectile begins unarmed, arms at 10m

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

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	// The SetBase( ) called here isn't replicating to the client
	// for some reason.  So we're going to just spawn the emitters
	// separately and not allow the server to replicate its copy

	// Make first person emitter face out the back of the rocket
	FPEmitter = Spawn(class'HackDefaultParticleEffect',self,,Location, rotator(-vector(Rotation)));
	//log("constructing RPG1stPersonTrail");
	FPEmitter.LookupConstruct("RPG1stPersonTrail");	
	FPEmitter.SetBase(self);
	FPEmitter.RemoteRole = ROLE_None;

	TPEmitter = Spawn(class'HackDefaultParticleEffect',self,,Location, rotator(-vector(Rotation)));
	//log("constructing RPGTrailEmitter");
	TPEmitter.LookupConstruct("RPG3rdPersonTrail");	
	TPEmitter.SetBase(self);
	TPEmitter.RemoteRole = ROLE_None;

	// If this thing spawned in either dud already or exploded already then trigger that
	OnPostReceive_bDud();
	OnPostReceive_bTriggerExplosionEffects();
}

simulated function OnPostReceive_bDud()
{
	if(bDud)
	{
		// Have to fake out GoDud on client by setting bDud to false before calling it
		bDud = false;
		GoDud();
	}
}

// Server has notified client to cause blow up effect
simulated function OnPostReceive_bTriggerExplosionEffects()
{
	if(bTriggerExplosionEffects)
	{
		TriggerExplosionEffects();
		KillEmitters();
		GoHidden();
	}
}

simulated function Destroyed()
{
	KillEmitters();

	Super.Destroyed();
}

// Arm after a half-second
function Timer()
{
	if(bDud != true)
		bArmed = true;
	else
		Destroy();
}

function DestroyTimer()
{
	Destroy();
}

// Detonate on impact with water
simulated event PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	Super.PhysicsVolumeChange(NewVolume);

	if(WaterVolume(NewVolume)?)
		Explode(location, vect(0,0,0));
}

simulated function KillEmitters()
{
	if(TPEmitter?)
	{
		TPEmitter.Kill();
		TPEmitter = None;
	}

	if(FPEmitter?)
	{
		FPEmitter.Kill();
		FPEmitter = None;
	}
}

// Make the RPG7 turn into a dud
simulated function GoDud()
{
	if(!bDud)
	{
		bDud = true;

		KillEmitters();

		SetTimer(10.0,false);

		// After going dud, turn off player collision to avoid a player jumping on
		// it and riding it
		SetCollision(true, true, false);
	}
}

// Boom!
// Don't explode if grenade isn't armed yet
function Explode(vector HitLocation, vector HitNormal)
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

	TriggerExplosionEffects();

	RadiusShake(ShakeParams, m_flShakeRadius);

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

	GoHidden();

	// Set timer to destroy this projectile, wait for explosion to have time to replicate
	SetDelegateTimer('DestroyTimer', 1.0);
}

simulated function GoHidden()
{
	// Now prevent grenade from doing anything until it is destroyed
	SetCollision(false,false,false);
	Velocity = vect(0,0,0);
	SetPhysics(PHYS_None);
	bHidden = true;
}

simulated function BlowUp(vector HitLocation)
{
	local Controller C;

	// TSS: Optimized to use ControllerList instead of AllActors
	C = level.ControllerList;
	while( C != None )
	{
		C.removeProjectileFromList( self );

		C = C.NextController;
	}

	if(Level.GRI.IsSingleplayerTypeGame())
		HurtRadius(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation, InstigatorController );
	else // Do extra damage, should kill a player on a direct hit
		HurtRadius(220,DamageRadius, MyDamageType, MomentumTransfer, HitLocation, InstigatorController );

	if ( Role == ROLE_Authority )
		MakeNoise(1.0);
}

// This function is never reached??  This needs more investigation
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local vector HitNormal;

	//log("RPG7 touched: " $ Other.Name);

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
	local bool bAlreadyDud;

	//log("RPG7 HitWall: " $ Wall $ " Normal: " $ HitNormal);
	//log("At " $ Level.TimeSeconds);

	// Do nothig if some guy already punctured
	if(bPunctured)
		return;

	// Do force setzone otherwise shots in the water in e.g. op1_l4a,
	// typically do a land explosion
	ForceSetZone();

	// Hit something without arming means become a dud
	// Possibly spear a guy, and if not then bounce
	if(!bArmed)
	{
		if(bDud)
			bAlreadyDud = true;

		GoDud();

		if(VietnamPawn(Wall) != None)
		{
			// Don't puncture if already bounced off of something
			if(!bAlreadyDud)
				bPunctured = CheckForPuncture(Wall);
		}

		// If we didn't puncture the guy, bounce off of him
		if(!bPunctured)
		{
			Wall.TakeDamage(20, Pawn(Owner), Location, vect(0,0,0), class'DamageBullet', InstigatorController);

			BounceCollision(HitNormal, Wall);
		}
		else
			Wall.TakeDamage(1000, Pawn(Owner), Location, vect(0,0,0), class'DamageBullet', InstigatorController);
	}
	else
	{
		// DTW 05/18/04: Changed from "if(Wall.IsA('StaticPATTON'))" to any vehicle...
		// E3 HACK
		if(Wall.IsA('StaticVehicle'))
		{
			Wall.TakeDamage(250, Pawn(Owner), Location, vect(0,0,0), class'DamageGrenade', InstigatorController);
		}
		// If it's armed and hits something, it will explode
		Explode(Location, HitNormal);
	}
}

simulated function bool CheckForPuncture(Actor Other)
{
	local vector HitLocation, HitNormal, TraceStart, EndTrace, vForward;
//	local actor Other;
	local int iHitBone;
	local VietnamPawn tmpPawn;
	local name StabbedBoneName;
	local vector KnifePosition;

	if(VietnamPawn(Other).bSpawnInvulnerability)
		return false;

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

	bGround = HitNormal.z > 0.7;

	Velocity = MirrorVectorByNormal( Velocity, HitNormal ) * 0.2;

	if ( Other.bWorldGeometry && speed < 40 && bGround) 
	{
		ComeToRest();
	}
	else
	{
		// After bouncing, thrust turns off
		SetPhysics(PHYS_Falling);
		RandSpin(10000);
	}

	speed = VSize(Velocity);

	if ( Level.NetMode != NM_DedicatedServer )
		PlaySound(ImpactSound, SLOT_Misc, 1.5,,150,,true);
}

simulated function Tick(float DeltaTime)
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

// Grenade blew up, trigger sound, particle effect
simulated function TriggerExplosionEffects()
{
	local Emitter ExplosionEmitter;	// Play sound on this, since the projectile is destroyed quickly

	if(bHitWater)
	{
		// Spawn the explosion
		ExplosionEmitter = spawn(class'HackDefaultParticleEffect',self,,vEnterWaterLocation,rot(16384,0,0));
		//log("constructing WaterGrenadeExplosionEffect");

		ExplosionEmitter.LookupConstruct("WaterGrenadeExplosionEffect");
		ExplosionEmitter.RemoteRole = ROLE_None;

		ExplosionEmitter.ClientPlayRegisteredSound( ProjectileSoundNames[
			EProjectileSound.EPS_WaterExplosion ].ResourceName, 'Boom');
	}
	else
	{
		// Spawn the explosion			
		//ExplosionEmitter = spawn(class'RPGExplosion',self,,HitLocation + vect(0,0,10),rot(16384,0,0));
		ExplosionEmitter = spawn(class'HackDefaultParticleEffect',self,,Location,rot(16384,0,0));
		//log("constructing RPGExplosion");

		ExplosionEmitter.LookupConstruct("RPGExplosion");
		ExplosionEmitter.RemoteRole = ROLE_None;

		ExplosionEmitter.ClientPlayRegisteredSound( ProjectileSoundNames[
			EProjectileSound.EPS_Explosion ].ResourceName, 'Boom');
	}

	bTriggerExplosionEffects = true;
}

static function StaticPrecacheAssets(optional Object MyLevel)
{
	local class<Actor> ShrapnelClass;

	Super.StaticPrecacheAssets(MyLevel);

	ShrapnelClass = class<Actor>(DynamicLoadObject("VietnamWeapons.ProjectileShrapnel", class'class'));
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
     ShakeParams=(RotationAmount=(X=500.000000,Y=500.000000),MaxRotationAmount=(X=500.000000),bRandomDirection=True,bRecoverBetweenKicks=True,DecayTime=1.500000,BlurScale=10.000000)
     speed=4000.000000
     MaxSpeed=5000.000000
     TossZ=0.000000
     Damage=110.000000
     DamageRadius=1200.000000
     MomentumTransfer=10.000000
     MyDamageType=Class'VietnamGame.DamageGrenade'
     ExplosionDecal=Class'VietnamEffects.Decal'
     ExploWallOut=10.000000
     bDynamicLight=True
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
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=1024.000000
     LightHue=28
     LightSaturation=32
     LightRadius=15.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     AssetName="weapons_stat.shells.rpg7_shot_stat"
}
