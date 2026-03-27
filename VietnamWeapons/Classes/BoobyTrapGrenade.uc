// This is a static mesh stick of a stick and grenade for a boobytrap
class BoobyTrapGrenade extends BaseTrap
	placeable
	native
	nativereplication;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() edfindable Actor StickActor;
var Actor StringActor;

var NewTrigger WireCutterTrigger;

var string StaticMeshName;

var bool	bDetonated, bDisabled;
var bool	bResettable;

var float m_flShakeRadius	"Radius in Unreal units to do a viewshake";
var ViewShakeInputParams ShakeParams	"Parameters affecting viewshake";
var() float fDamageAmount	"Amout of radius damage at the center of the grenade";
var() float fDamageRadius	"Radius in Unreal units to do damage (attenuated)";
var() name ExplosionSound	"Sound to play when booby trap explodes";

var Controller InstigatorController;	// Stores controller of the guy who placed the trap

replication
{
	// variables that the server replicates to the client
	reliable if (ROLE==ROLE_Authority)
		bDisabled;
}

function BeginPlay()
{
	Super.BeginPlay();

	ResetTriggerProperties();
}

function ResetTriggerProperties()
{
	local vector TempDrawScale;
	local vector VectorToStickActor;

	// Since this as changed asfter the LD's placed them, make sure this gets setup correctly
	if(WireCutterTrigger?)
	{
		VectorToStickActor = StickActor.Location - Location;

		// And setup collision
		WireCutterTrigger.SetLocation(StringActor.location);
		WireCutterTrigger.SetRotation(rotator(VectorToStickActor) + rot(0,16384,0));
		TempDrawScale.X = 4.0;
		TempDrawScale.Y = VSize(VectorToStickActor);
		TempDrawScale.Z = 1.0;
		WireCutterTrigger.SetDrawScale3D(TempDrawScale);
	}
}

event simulated PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if(StaticMeshName? && !StaticMesh)
		SetStaticMesh(StaticMesh(DynamicLoadObject(StaticMeshName,class'StaticMesh')));
}

// If something changed, reinitialize stuff
event PostEditChange()
{
	// DLO the StaticMesh if necessary
	if (!StaticMesh && StaticMeshName?)
	{
		SetStaticMesh(StaticMesh(DynamicLoadObject(StaticMeshName,class'StaticMesh')));
	}

	if(StickActor?)
	{
		// Check if these other actors are still around, if so delete and respawn them
		if(StringActor?)
			StringActor.Destroy();

		if(WireCutterTrigger?)
			WireCutterTrigger.Destroy();

		SetupBoobyTrapString();
	}
}

// Delete anything spawned in the editor
event PostEditDelete()
{
	StringActor.Destroy();
	WireCutterTrigger.Destroy();
}

function SpawnedInEditor()
{
	// DLO the StaticMesh if necessary
	if (!StaticMesh && StaticMeshName?)
	{
		SetStaticMesh(StaticMesh(DynamicLoadObject(StaticMeshName,class'StaticMesh')));
	}
}

// Spawns in the string for the trap
// Also spawns the WireCutterTrigger
function SetupBoobyTrapString()
{
	local rotator StringRotation;
	local vector SpawnLocation, VectorToStickActor, StringDrawScale;

	VectorToStickActor = StickActor.Location - Location;

	StringRotation = rotator(VectorToStickActor) + rot(16384,0,0);
	SpawnLocation = Location + VectorToStickActor/2;

	StringActor = Spawn(class'VietnamWeapons.BoobyTrapString',self,,SpawnLocation, StringRotation);

	StringDrawScale.X = 1.0;
	StringDrawScale.Y = 1.0;
	StringDrawScale.Z = VSize(VectorToStickActor) / 183.0;

	// Now set the size of the string so it will look right
	StringActor.SetDrawScale3D(StringDrawScale);

	// And setup collision
	WireCutterTrigger = Spawn(class'VietnamWeapons.BoobyTrapTrigger',self,,StringActor.location,rotator(VectorToStickActor) + rot(0,16384,0));
	StringDrawScale.X = 2.0;
	StringDrawScale.Y = VSize(VectorToStickActor);
	StringDrawScale.Z = 1.0;
	WireCutterTrigger.SetDrawScale3D(StringDrawScale);

}

// Now that I've landed, setup the string
event Landed(vector HitNormal)
{
	if(!CheckValidPosition())
		return;

	if(!StringActor || !WireCutterTrigger)
		SetupBoobyTrapString();
}

// Make sure booby trap doesn't go through something solid
function bool CheckValidPosition()
{
	local vector HitLocation, HitNormal;
	local Actor Other;

	// Trace against everything but volumes
	Other = CustomTrace(Location, StickActor.Location, TRACEFLAG(STRACE_Level) | TRACEFLAG(STRACE_Actors) | TRACEFLAG(STRACE_OnlyProjActor), HitLocation, HitNormal);
	if(Other? && Other != StickActor)
	{
		Destroy();
		return false;
	}

	return true;
}

// Booby trap can no longer be destroyed by shooting it
/*
// Any damage to the grenade causes it to blow up
event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	if(!bDetonated)
	{
		bDetonated = true;
		Detonate();
	}
}
*/

function Fire()
{
	
	// APT: 2-3-04 ignore all action when freeze is set
	if ( bFreeze ) return;

	if(bDisabled)
		return;
		
	log("BTG Fire() StackTrace follows:");
	StackTrace();

	Detonate();

	// Old way, now calls Detonate()
//	Spawn(class'VietnamGame.GrenadeExplosion', self);

	SendStateMessages('Detonated');
	SendMessages(m_arrTriggeredMessages);

	HideTrap();

	// APT: remove awareness mapping from the object, (ensures
	// friendlies don't attempt to disarm the trap)
    RemoveAwarenessMapping();

}

// Used to spawn GrenadeExplosion, now duplicate its properties here
// so LD's can modify them
function Detonate()
{
	local HackDefaultParticleEffect SpawnedEmitter;

	// make the stick do all the work,
	// since it really looks like the
	// grenade now.... (See model
	// hack notes in defaultproperties)

	//Spawn(class'VietnamEffects.FragGrenade');
	SpawnedEmitter = StickActor.Spawn(class'HackDefaultParticleEffect');
	//log("constructing FragGrenade");
	SpawnedEmitter.LookupConstruct("FragGrenade");

	StickActor.RadiusShake(ShakeParams, m_flShakeRadius);

	// forget about my owner now, otherwise the
	// sound won't play properly in a multiplayer,
	// same machine game when the owner sets off
	// its own booby trap
	SetOwner( NONE );
	StickActor.SetOwner( NONE );

	StickActor.RemotePlayRegisteredSound(ExplosionSound, 'Explosion');

	// for a grenade, this is enough
	StickActor.HurtRadius( fDamageAmount, fDamageRadius,
		class'DamageGrenade', fDamageAmount,
		StickActor.Location, InstigatorController );
}

// Trap has (probably) blown up, so make it disappear
function HideTrap()
{
	// APT: 2-3-04 ignore all action when freeze is set
	if ( bFreeze ) return;

	bDisabled = true;
	bHidden = true;
	StringActor.bHidden = true;
	StickActor.bHidden = true;
	SetCollision(false,false,false);
	StickActor.SetCollision(false,false,false);
	WireCutterTrigger.DisableTrigger();
}

function OnDeactivated(DeactivatedMessage Msg)
{
	DisableTrap();

	Super.OnDeactivated(Msg);
}

function Reset()
{
	// If a person planted this, blow it away
	// Otherwise, reset it to what the LD wanted
	if(!bResettable)
	{
		Destroy();
	}
	else
	{
		Super.Reset();

		log("BTG Internal Reset");

		bFreeze = false;
		bDisabled = false;
		bHidden = false;
		//	bFreeze = false;
		StringActor.bHidden = false;
		StickActor.bHidden = false;
		SetCollision(true,true,true);
		StickActor.SetCollision(true,true,true);
		WireCutterTrigger.m_bIsActive = true;
		m_bIsActive=true;
		
		// APT: 9-27-04 reset the awareness ID so the booby trap is mapped
		// back into the system on restart
		AwarenessID=-1;
	}
}

function DisableTrap()
{
	// Don't allow sticks to pile up in a multiplayer game
	if(Level.GRI.IsMultiplayerTypeGame())
	{
		SetDelegateTimer('DestroyTimer', 5.0, false);
	}

	// APT: 2-3-04 ignore all action when freeze is set
	if ( bFreeze ) return;

	StringActor.bHidden = true;

	bDisabled = true;

	WireCutterTrigger.DisableTrigger();

	SendStateMessages('Disarmed');

	// APT: remove awareness mapping from the object, (ensures
	// friendlies don't attempt to disarm the trap)
    RemoveAwarenessMapping();
}

function DestroyTimer()
{
	Destroy();
}

// Tidy up the other parts of the booby trap
event Destroyed()
{
	Super.Destroyed();

	StickActor.Destroy();

	if(StringActor?)
		StringActor.Destroy();

	if(WireCutterTrigger?)
		WireCutterTrigger.Destroy();
}

// Skip over BaseTrap touch which activates
function Touch(Actor Other)
{
	// APT: 2-3-04 ignore all action when freeze is set
	if ( bFreeze ) return;

	Super(Actor).Touch(Other);
}


// APT: 2-3-04 accessor functions for use in VietnamGame through the
// base class BaseTrap

function bool IsTrapValid()
{
	if ( bDisabled || bHidden ) return false;
	if ( StickActor == none ) return false;
	return true;
}
	

function Actor GetAuxActor()
{
	return StickActor;
}

function Tick( float fDeltaTime )
{
	// APT: makes sure the object is mapped into the awareness system,
	// (trivial after first call). Placed the check here because LD
	// mapped booby traps don't seem to make it into the awareness
	// system
    CheckAwarenessMappingSimple(1024);	// quick hack, 1024 = AWIT_BOOBYGRENADE
}

defaultproperties
{
     StaticMeshName="boobytraps_stat.grenadetrap_stick_stat"
     bResettable=True
     m_flShakeRadius=1000.000000
     ShakeParams=(RotationAmount=(X=500.000000,Y=500.000000),MaxRotationAmount=(X=500.000000,Y=500.000000),bRandomDirection=True,bRecoverBetweenKicks=True,bShellShockAudio=True,DecayTime=1.500000,BlurScale=10.000000)
     fDamageAmount=150.000000
     fDamageRadius=625.000000
     ExplosionSound="GrenadeExplodeClose"
     DrawType=DT_StaticMesh
     CollisionRadius=5.000000
     CollisionHeight=20.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     m_arrEventStates(2)="Disarmed"
     m_arrEventStates(3)="Detonated"
}
