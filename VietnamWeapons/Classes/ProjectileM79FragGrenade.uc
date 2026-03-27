//=============================================================================
// ProjectileM79FragGrenade.uc
//=============================================================================
class ProjectileM79FragGrenade extends VietnamProjectile;

var bool bArmed;	// It takes time to arm
var bool bDud;		// If it hits something without arming, it becomes a dud

var config float fArmTime;
var config int	iMinNumShrapnelPieces;
var config int	iMaxNumShrapnelPieces;

var bool bTriggerExplosionEffects;


replication
{
	reliable if ( bNetDirty && ( Role == ROLE_Authority ) )
		bDud, bTriggerExplosionEffects;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(fArmTime, false);                  //Grenade begins unarmed, arms at 10m
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

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	// Check if this actor just came into relevancy and exploded
	OnPostReceive_bTriggerExplosionEffects();
}

// Server has notified client to cause blow up effect
simulated function OnPostReceive_bTriggerExplosionEffects()
{
	if(bTriggerExplosionEffects)
	{
		TriggerExplosionEffects();
		GoHidden();
	}
}

// Arm after a half-second
simulated function Timer()
{
	if(bDud != true)
		bArmed = true;
}

// Grenade blew up, trigger sound, particle effect
simulated function TriggerExplosionEffects()
{
	local Emitter ExplosionEmitter;	// Play sound on this, since the projectile is destroyed quickly

	if(bHitWater)
	{
		// Spawn the explosion
		//ExplosionEmitter = spawn(class'WaterGrenadeExplosionEffect',self,,vEnterWaterLocation,rot(16384,0,0));
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
		//ExplosionEmitter = spawn(class'VietnamEffects.FragGrenade',self,,HitLocation + vect(0,0,10),rot(0,0,0));
		ExplosionEmitter = spawn(class'HackDefaultParticleEffect',self,,Location,rot(0,0,0));
		//log("constructing FragGrenade");
		
		ExplosionEmitter.LookupConstruct("FragGrenade");	
		ExplosionEmitter.RemoteRole = ROLE_None;

		ExplosionEmitter.ClientPlayRegisteredSound( ProjectileSoundNames[
			EProjectileSound.EPS_Explosion ].ResourceName, 'Boom');
	}

	bTriggerExplosionEffects = true;
}

// Boom!
// Don't explode if grenade isn't armed yet
function Explode(vector HitLocation, vector HitNormal)
{
	local ProjectileShrapnel Shrapnel;
	local int i;
	local vector Direction;
	local int iNumShrapnelPieces;

	// If something is hit before grenade is armed, it becomes a dud
	if(!bArmed)
	{
		bDud = true;
		return;
	}

	BlowUp(HitLocation);

	// Our owner should not be immune to taking damage!
	SetOwner(None);

	TriggerExplosionEffects();

	RadiusShake(ShakeParams, m_flShakeRadius);

	VietnamPawn(Instigator).BroadcastAIEvent(VietnamPawn(Instigator).GetAIEventForName('AI_EV_EXPLOSION'), HitLocation + vect(0,0,10));
	
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
	bArmed = false;
}

function DestroyTimer()
{
	Destroy();
}

function SendAIGrenadeNotification()
{
	local float fRadius;
	local VietnamBot B;
	local float fDistSquared, fRadiusSquared;
	local vector vDelta;
	local int iType;

	iType = VietnamPawn(Instigator).GetAIEventForName('AI_EV_GRENADE');
	fRadius = VietnamPawn(Instigator).GetAIEventRadius(iType);

	fRadiusSquared = fRadius * fRadius;
	
	ForEach DynamicActors(class'VietnamBot', B)
	{
		if(!B.IsDead())
		{
			vDelta = B.Pawn.Location - Location;
			fDistSquared = vDelta dot vDelta;
			
			//B.DrawLine(B.Pawn.Location, Location, class'Canvas'.Static.MakeColor(255,255,0));

			if(fDistSquared <= fRadiusSquared)
			{
				//Log("Sending AI Event:"$iType$" with Radius("$fRadius$")");
				B.ProcessAIEvent(iType, Location, self, fDistSquared, fRadiusSquared);
			}
		}
	}
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local vector HitNormal;

	if(Other != Instigator && Other.bBlockProjectiles)
	{
		HitNormal = Normal(HitLocation - Other.Location);
	
		BounceCollision(-Normal(Velocity), Other);

		Explode(HitLocation, HitNormal);
	}
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	// Do force setzone otherwise shots in the water in e.g. op1_l4a,
	// typically do a land explosion
	ForceSetZone();

	BounceCollision(HitNormal, Wall);

	Explode(Location, HitNormal);
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
	PlaySound(ProjectileSounds[3], SLOT_Misc, 1.5,,150,,true);

	// DTW: So it doesn't knock bots off of vehicles (op1_l4a)
	// and doesn't fly through a bot
	bBlockBots = false;

//	if ( Velocity.Z > 400 )
//		Velocity.Z = 0.5 * (400 + Velocity.Z);
//	else 

	if ( (Other.bWorldGeometry || Other.IsA('BlockingVolume')) && speed < 50 ) 
	{
		bBounce = False;
		SetPhysics(PHYS_None);
	}

	SendAIGrenadeNotification();
}

// Detonate on impact with water
simulated event PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	Super.PhysicsVolumeChange(NewVolume);

	if(WaterVolume(NewVolume)?)
		Explode(location, vect(0,0,0));
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
     ProjectileSoundNames(3)=(PackageName="weapon_snd",ResourceName="GrenadeHitDirt")
     m_flShakeRadius=1000.000000
     ShakeParams=(RotationAmount=(X=500.000000,Y=500.000000),MaxRotationAmount=(X=500.000000),bRandomDirection=True,bRecoverBetweenKicks=True,DecayTime=1.500000,BlurScale=10.000000)
     speed=4000.000000
     MaxSpeed=5000.000000
     TossZ=300.000000
     Damage=220.000000
     DamageRadius=1000.000000
     MomentumTransfer=10.000000
     MyDamageType=Class'VietnamGame.DamageGrenade'
     ExplosionDecal=Class'VietnamEffects.Decal'
     ExploWallOut=10.000000
     bUnlit=False
     bUseCylinderCollision=True
     bBounce=True
     bFixedRotationDir=True
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
     LifeSpan=10.000000
     Acceleration=(Z=-2000.000000)
     DrawScale=2.000000
     SoundRadius=10.000000
     SoundVolume=218
     CollisionRadius=5.000000
     CollisionHeight=5.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     AssetName="weapons_stat.shells.frag_shot_stat"
}
