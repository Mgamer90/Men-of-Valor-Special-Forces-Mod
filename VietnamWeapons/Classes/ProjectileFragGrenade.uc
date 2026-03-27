//=============================================================================
// ProjectileFragGrenade.uc
//=============================================================================
//class ProjectileFragGrenade extends Projectile;
class ProjectileFragGrenade extends VietnamProjectile;

var bool bFirstTimer;
var bool bDetonated;

var config int	iMinNumShrapnelPieces;
var config int	iMaxNumShrapnelPieces;

var config float fArmTime;
// Move these two vars up to VietnamProjectile
//var config float fMinWaitTime;
//var config float fMaxWaitTime;

var bool bTriggerExplosionEffects;

replication
{
	reliable if ( bNetDirty && ( Role == ROLE_Authority ) )
		bTriggerExplosionEffects;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	//SetTimer(0.1,false);
//	SetDelegateTimer( 'DebrisTimer', fArmTime, false ); //Grenade begins unarmed
	StartDetonationTimer();

	registerWithPlayerControllers();
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

// Grenade blew up, trigger sound, particle effect
simulated function TriggerExplosionEffects()
{
	local Emitter ExplosionEmitter;	// Play sound on this, since the projectile is destroyed quickly

	//log(self $ " TriggerExplosionEffects");

	if(bHitWater)
	{
		// Spawn the explosion
		
		//ExplosionEmitter = spawn(class'WaterGrenadeExplosionEffect',self,,vEnterWaterLocation,rot(16384,0,0));
		ExplosionEmitter = spawn(class'HackDefaultParticleEffect',self,,vEnterWaterLocation,rot(16384,0,0));
		
		//log("constructing WaterGrenadeExplosionEffect");
		ExplosionEmitter.LookupConstruct("WaterGrenadeExplosionEffect");
		// We don't want this emitter to replicate, it'll spawn locally
		ExplosionEmitter.RemoteRole = ROLE_None;

		ExplosionEmitter.ClientPlayRegisteredSound( ProjectileSoundNames[
			EProjectileSound.EPS_WaterExplosion ].ResourceName, 'Boom');
	}
	else
	{
		// Spawn the explosion
		
		//ExplosionEmitter = spawn(class'VietnamEffects.FragGrenade',self,,HitLocation + vect(0,0,10),rot(0,0,0));
		ExplosionEmitter = spawn(class'HackDefaultParticleEffect',,,Location,rot(0,0,0));

		//log("constructing FragGrenade");
		ExplosionEmitter.LookupConstruct("FragGrenade");
		// We don't want this emitter to replicate
		ExplosionEmitter.RemoteRole = ROLE_None;

		ExplosionEmitter.ClientPlayRegisteredSound( ProjectileSoundNames[
			EProjectileSound.EPS_Explosion ].ResourceName, 'Boom');
	}

	bTriggerExplosionEffects = true;
}

function DestroyTimer()
{
	Destroy();
}

/*
simulated function DebrisTimer()
{
	local FallingMeshDebris	Debris;

	// Spawn "spoon"
	Debris = Spawn(class'FallingMeshDebris', self);
	Debris.SetStaticMesh(
		StaticMesh(DynamicLoadObject("Weapons_stat.Grenade_frag_shell_stat",class'StaticMesh')));

	Debris.Velocity = Velocity * 0.2;
}
*/

simulated function DetonateTimer()
{
	Explode(Location+Vect(0,0,1)*16, vect(0,0,1));
}

// Boom!
function Explode(vector HitLocation, vector HitNormal)
{
	local ProjectileShrapnel Shrapnel;
	local int i;
	local vector Direction;
	local int iNumShrapnelPieces;

	//log(self $ " Explode");

	if(bDetonated == true)
		return;

	bDetonated = true;

	// efd move grenade effect until the explosion is emitted
	//BlowUp(HitLocation);
	// end efd

	// Our owner should not be immune to taking damage!
	SetOwner(None);

	// Play neato effects
	TriggerExplosionEffects();

	MakeNoise(1.f,'Explosion');

	RadiusShake(ShakeParams, m_flShakeRadius);

	// efd - place effect here so it coincides with explosion better?
	BlowUp(HitLocation);
	// end efd

	// TODO: Check if explosion is on the ground, then do exploding ring of smoke with rising center ring of smoke,
	// else do 360 degree sphere of smoke

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
	
	// efd - report that a grenade has been thrown
	//Log("SendAIGrenadeNotification() iType"@iType);
	//Log("SendAIGrenadeNotification() fRadius"@fRadius);
	//Log("SendAIGrenadeNotification() fRadiusSquared"@fRadiusSquared);
	// end efd

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
				
				// efd
				//Log("calling ProcessAIEvent() for"@B);
				// end efd
				B.ProcessAIEvent(iType, Location, self, fDistSquared, fRadiusSquared);
			}
		}
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
	PlaySound(ProjectileSounds[3], SLOT_Misc, 1.5,,150,,true);

//	if ( Velocity.Z > 400 )
//		Velocity.Z = 0.5 * (400 + Velocity.Z);
//	else
	if ( Other.bWorldGeometry && speed < 50 )
	{
		bBounce = False;
		SetPhysics(PHYS_None);
	}

	SendAIGrenadeNotification();
}

function StartDetonationTimer()
{
	local float fWaitTime;

	// Katy - similar to smoke grenade, use config vars to specify
	// how long until the grenade explodes
	fWaitTime = FRand() * (fMaxWaitTime-fMinWaitTime);
	fWaitTime += fMinWaitTime;

	// Grenades from bots need to take longer to blow up than human thrown grenades,
	// so I'm adding a bot multiplier
	if(Instigator? && !Instigator.IsHumanControlled())
	{
		fWaitTime *= 1.5;
	}

	SetDelegateTimer( 'DetonateTimer', fWaitTime, false ); //Grenade begins unarmed
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

static function StaticPrecacheAssets(optional Object MyLevel)
{
	local class<Actor> ShrapnelClass;

	Super.StaticPrecacheAssets(MyLevel);

	ShrapnelClass = class<Actor>(DynamicLoadObject("VietnamWeapons.ProjectileShrapnel", class'class'));
	ShrapnelClass.static.StaticPrecacheAssets();
}

defaultproperties
{
     bFirstTimer=True
     iMinNumShrapnelPieces=10
     iMaxNumShrapnelPieces=12
     fArmTime=0.100000
     ProjectileSoundNames(0)=(PackageName="weapon_snd",ResourceName="GrenadeExplodeClose")
     ProjectileSoundNames(1)=(PackageName="weapon_snd",ResourceName="BombInWater")
     ProjectileSoundNames(3)=(PackageName="weapon_snd",ResourceName="GrenadeHitDirt")
     m_flShakeRadius=1000.000000
     ShakeParams=(RotationAmount=(X=500.000000,Y=500.000000),MaxRotationAmount=(X=500.000000),bRandomDirection=True,bRecoverBetweenKicks=True,DecayTime=3.000000,BlurScale=10.000000)
     fMinWaitTime=3.000000
     fMaxWaitTime=4.000000
     speed=500.000000
     TossZ=150.000000
     Damage=220.000000
     DamageRadius=1000.000000
     MomentumTransfer=10.000000
     MyDamageType=Class'VietnamGame.DamageGrenade'
     ExplosionDecal=Class'VietnamEffects.Decal'
     ExploWallOut=10.000000
     bUnlit=False
     bBlockActors=True
     bProjTarget=True
     bUseCylinderCollision=True
     bBounce=True
     bFixedRotationDir=True
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
     LifeSpan=0.000000
     SoundRadius=10.000000
     SoundVolume=218
     CollisionRadius=5.000000
     CollisionHeight=5.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     AssetName="weapons_stat.us.grenade_frag_bullet_stat"
}
