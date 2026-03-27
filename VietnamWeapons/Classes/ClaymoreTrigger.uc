class ClaymoreTrigger extends UseTrigger
	notplaceable;

var bool bClaymorePresent, bDetonated;
var StaticMesh NonUsedStaticMesh;
var StaticMesh UsedStaticMesh;
var Texture NonUsedTexture;
var Texture UsedTexture;

var float MaxRange;
var float Damage;
var float Penetration;
var float BaseAccuracy;
var int iBuckshotTraces;
var deprecated float fVerticalOffset;

//var string ExplosionSoundName;
var sound ExplosionSound;

function Spawned()
{
	Super.Spawned();

	if(!StaticMesh)
		SetStaticMesh(StaticMesh(DynamicLoadObject("weapons_stat.us.claymore_stat", class'StaticMesh')));
	
	if(!UsedStaticMesh)
		UsedStaticMesh=StaticMesh(DynamicLoadObject("weapons_stat.us.claymore_stat", class'StaticMesh'));

	if(!NonUsedTexture)
		NonUsedTexture= Texture(DynamicLoadObject("Effects_tex.common.marker_finalblend", class'FinalBlend'));
	if(!UsedTexture)
		UsedTexture= Texture(DynamicLoadObject("weapons_tex.Claymore.claymore_bomb", class'Texture'));
}


static function StaticPrecacheAssets(optional Object MyLevel)
{
	DynamicLoadObject("Effects_tex.common.marker_finalblend", class'FinalBlend');
	DynamicLoadObject("weapons_tex.Claymore.claymore_bomb", class'Texture');

	Super.StaticPrecacheAssets(MyLevel);
}


function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(NonUsedStaticMesh != None)
		SetStaticMesh(NonUsedStaticMesh);

	if(NonUsedTexture != None)
		skins[0] = NonUsedTexture;

	//ExplosionSound = Sound(DynamicLoadObject(ExplosionSoundName,class'Sound'));
	RegisterSound(ExplosionSound);
}

function Touch( Actor Other )
{
	Log("Place a claymore?");
	if( (Message != "") && (Other.Instigator != None) )
		// Send a string message to the toucher.
		Other.Instigator.ClientMessage( Message );
}

function bool SetClaymore( Pawn user )
{
	if (bClaymorePresent == true)
		return true;

//	Log("Placed a claymore");

	Instigator = user;

	SendStateMessages('Claymore');

	SetStaticMesh(UsedStaticMesh);
	skins[0] = UsedTexture;

	bClaymorePresent = true;
	SetStaticMesh(UsedStaticMesh);
	TriggerEvent(Event, self, user);

	return true;
}

function Detonate()
{
	if(!bDetonated)
	{
		SendStateMessages('Detonated');
		Spawn(class'GrenadeExplosion',,,location);
		PlaySound(ExplosionSound);
		TraceFire();
		bDetonated = true;
		Destroy();
	}
}

// Bastardized from VietnamControllerShared
function rotator VietnamAdjustAim(rotator AimDirection)
{
	local rotator FinalAim;
	local float AimAccuracy, PitchAdjustment, YawAdjustment;
//	local string Msg;

	AimAccuracy = GetFinalAccuracy();

	// Start off with the direction we're facing
	// Or if the AimDirection is supplied, use it instead
	if(AimDirection == rot(0,0,0))
		FinalAim = Owner.Rotation;
	else
		FinalAim = AimDirection;

	// Generate random point in a box
//	RandRange( float Min, float Max )
	PitchAdjustment = (2*AimAccuracy) * (FRand() - 0.5);
	FinalAim.Pitch += PitchAdjustment;

	YawAdjustment = (2*AimAccuracy) * (FRand() - 0.5);
	FinalAim.Yaw += YawAdjustment;

//	Msg = "Base, Weapon: <" $ BaseAccuracy $ "," $ aimerror $ ">";
//	ClientMessage(Msg);

	return FinalAim;
}

function float GetFinalAccuracy()
{
	local float	AimAccuracy;

	AimAccuracy = BaseAccuracy;

	return AimAccuracy;
}

// We have this overridden to use our accuracy calculations
function TraceFire()
{
	local vector StartTrace, EndTrace;
	
	local int iCounter;

	// FIXME TEMP
	if ( Instigator.bIgnorePlayFiring )
		return;

	Instigator.MakeNoise(1.0);
	
	for(iCounter=0;iCounter<iBuckshotTraces;iCounter++)
	{
		EndTrace = GetFireEnd(StartTrace);
		InnerTraceFire(StartTrace, EndTrace, Penetration);
	}

	VietnamPawn(Instigator).BroadcastAIEvent(VietnamPawn(Instigator).GetAIEventForName('AI_EV_WEAPON_FIRE'), StartTrace);

	// We want the tracer coming from the gun, not your eye
//	HandleTracer(GetBoneCoords('tag_muzzle').Origin, HitLocation, vRight);
}

// Determine firing position
function vector InnerTraceFire(vector vStart, vector vEnd, float RemainingPenetration)
{
	local vector HitLocation, HitNormal, vForward;
	local vector vNextStart, vNextEnd;
	local actor Other;
	local int iHitBone;
	local VietnamPawn tmpPawn;
	local Material HitMaterial;
	local bool bPenetration;
	local vector vPenetrationEnd;
	
	// Making the unit of size 2 seems to be the best way for now
	// Doing a size 1 trace will not trigger a collision inside a staticmesh
	vForward = Normal(vEnd - vStart) * 2;

	// Do the trace
	Other = CustomTrace(vStart, vEnd, TRACEFLAG(STRACE_Actors) | TRACEFLAG(STRACE_Level) | TRACEFLAG(STRACE_OnlyProjActor) | TRACEFLAG(STRACE_IgnoreBlocking), HitLocation, HitNormal, , , , HitMaterial, iHitBone);

	// If we hit a guy, damage him and then we're done; no penetration
	if(Other != none)
	{
		if ( Other.IsA('VietnamPawn') )
		{
			tmpPawn = VietnamPawn(Other);
			tmpPawn.LastHitBone = iHitBone;

			// Don't spawn blood on player
			if(!tmpPawn.IsHumanControlled())
				tmpPawn.ClientSpawnBloodEffect(iHitBone, HitLocation, rotator(vForward));
		}
		else if(Other.bWorldGeometry == true)
		{
			// We hit a wall, let the AI know
			VietnamPawn(Instigator).BroadcastAIEvent(VietnamPawn(Instigator).GetAIEventForName('AI_EV_WEAPON_IMPACT'), HitLocation);

			if(HitMaterial != None)
			{
//				Instigator.ClientMessage("Immediate Material.Name: " $ HitMaterial.Name);
//				Instigator.ClientMessage("Final MaterialHitEffect: " $ HitMaterial.GetMHE());
				
				// Check for penetration
				// If we hit a wall, check material and tunnel through it
				if(HitMaterial.GetMHE() == MHE_ThinWood && RemainingPenetration > 0)
				{
					vNextStart = HitLocation;
					vNextEnd = HitLocation + vForward;

					bPenetration = true;
				}
			}
		}
		else if(Other.IsA('WaterVolume'))	// Volumes are not WorldGeometry
		{
			SpawnWaterEffect(HitLocation, HitNormal, vForward);

			bPenetration = false;
		}

		// ProcessTraceHit will handle MHE and damage to pawns
		// This func wants a full orientation, but we're not going to give it one :-P
		if(HitMaterial != None)
			ProcessTraceHit(Other, HitLocation, HitNormal, vForward, vForward, vForward, HitMaterial.GetMHE());
		else
			ProcessTraceHit(Other, HitLocation, HitNormal, vForward, vForward, vForward);

		if(bPenetration)
		{
			// Start digging
			// Loop the traces until we did not hit WorldGemometry, or run out of penetration
			for(RemainingPenetration -= 1.0;RemainingPenetration > 0.0; RemainingPenetration -= 1.0)
			{
				Other = Trace(HitLocation, HitNormal, vNextEnd, vNextStart, True, , HitMaterial, iHitBone);

				if(Other == None || Other.bWorldGeometry == false)
				{
					// If we get out, recursively call InnerTraceFire to essentially fire again
					// after getting out of the wall (but with less penetration this time)
					vPenetrationEnd = InnerTraceFire(vNextStart, vEnd, RemainingPenetration);
					break;
				}
				else
				{
					vNextStart = vNextEnd;
					vNextEnd = vNextEnd + vForward;
				}
			}
			// After penetration, tracer should go where?
			return vPenetrationEnd;
		}
		else
		{
			// No penetration, tracer should go where?
			return HitLocation;
		}
	}
	else
	{
		// Didn't hit anything, tracer should go where?
		return vEnd;
	}
}

// Spawn a water effect at the specified location, etc.
function SpawnWaterEffect(vector Location, optional vector Normal, optional vector ShotDirection)
{
//	Spawn(class'ParticleHitWaterSmall',,, Location, Rotator(Normal));
}

// Checks what the weapon hit and spawns effects and does damage as appropriate
// This function will serve as a default effect, however this function should be implemented
// on a per weapon basis
function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z, optional Material.EMaterialHitEffect MaterialHitEffect)
{
	if ( Other == None )
		return;

	if ( Other.bWorldGeometry || (Mover(Other) != None) )
	{
		if(MaterialHitEffect != MHE_None)
		{
			SpawnLevelEffect(HitLocation, HitNormal, MaterialHitEffect);
		}
	}
	else
		Other.TakeDamage(Damage,  Instigator, HitLocation, 30000.0*X, class'DamageBullet');
}

// Spawns appropriate effects
function SpawnLevelEffect(Vector pLocation, Vector Normal, Material.EMaterialHitEffect MaterialHitEffect)
{
}

function SpawnWoodSplinter(Vector Location, Vector Normal)
{
	local rotator			TempRotator;
	local StaticMeshEffect	SpawnedStaticMeshEffect;
	local vector			vOffset;

	// This effect isn't very cool looking yet.
	return;

	if(FRand() > 0.5)
		vOffset.z = FRand() * 5 + 4;
	else
		vOffset.z = FRand() * -5 - 4;

	SpawnedStaticMeshEffect = Spawn(class'StaticMeshEffect',,, Location + vOffset, Rotator(Normal));
//	SpawnedStaticMeshEffect.SetStaticMesh(StaticMesh'woodsplinter.woodsplinter_stat');
//			SpawnedStaticMeshEffect.SetStaticMesh(StaticMesh'objects_stat.world.woodchip1_stat');
	TempRotator = SpawnedStaticMeshEffect.Rotation;
	TempRotator.Yaw += 49152 + (FRand() - 0.5) * 8000;

	if(vOffset.z > 0)
		TempRotator.Roll += 8192 + (FRand() - 0.5) * 5000;
	else
		TempRotator.Roll -= 8192 + (FRand() - 0.5) * 5000;
	SpawnedStaticMeshEffect.SetRotation(TempRotator);
	SpawnedStaticMeshEffect.SetDrawScale(0.8 + (FRand() - 0.5) / 2);
}

function vector GetFireStart(optional vector X, optional vector Y, optional vector Z)
{
	return location;
}

// This calculates the end point of a line (doesn't do a trace)
// It takes into account precision aiming mode, accuracy, and max weapon range
// This also can optionally return the GetFireStart() position, eliminating the need to call
// GetFireStart() explicitly
// This function is bot-friendly
function vector GetFireEnd(optional out vector Start, optional bool bPerfectAim)
{
	local vector vStart, vEnd;
	local vector Forward, Right, Up;
	local rotator AdjustedAim;

	vStart = GetFireStart();

	GetAxes(Rotation, Forward, Right, Up);

	AdjustedAim = rotator(Forward);
	AdjustedAim = VietnamAdjustAim(AdjustedAim);

	Forward = vector(AdjustedAim);

	// Now that we have forward, project out along the forward vector to the MaxRange 
	// of our weapon
	vEnd = vStart + (MaxRange * Forward);

	// Set value to optional vector
	Start = vStart;

	return vEnd; 
}

defaultproperties
{
     MaxRange=5000.000000
     Damage=60.000000
     BaseAccuracy=5000.000000
     iBuckshotTraces=50
     ExplosionSound=Sound'weapon_snd.Omni.Claymore'
     bHidden=False
     bUseCylinderCollision=True
     bDirectional=True
     DrawType=DT_StaticMesh
     CollisionRadius=50.000000
     CollisionHeight=20.000000
     m_arrEventStates(0)="NoClaymore"
     m_arrEventStates(1)="Claymore"
     m_arrEventStates(2)="Detonated"
}
