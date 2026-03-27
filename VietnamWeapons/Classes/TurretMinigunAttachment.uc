//////////////////////////////////////////////////////////////////////////////
//	File:	TurretMinigunAttachment.uc
//
//	Description	:	This is a minigun attached to something like a Huey's wing
//----------------------------------------------------------------------------
class TurretMinigunAttachment extends TurretMinigun
	placeable;

var float SpinRate;		// Roll rotation change per second
var float MaxSpinRate;	// Maximum spinrate

function PostBeginPlay()
{
	if(DrawType == DT_Mesh)
	{

		log("TurretMinigunAttachment unexpected DT_Mesh type, memory is being wasted, tell burgess");
		
		// Check if we need to load mesh and animation dynamically
		if (!Mesh && MeshName?)
			LinkMesh(Mesh(DynamicLoadObject(MeshName,class'Mesh')),false);
	}
	else
	{
		// Check if we need to load staticmesh dynamically
		if (!StaticMesh && StaticMeshName?)
			SetStaticMesh(StaticMesh(DynamicLoadObject(StaticMeshName,class'staticMesh')));
	}

	// Create and setup crosshair rotator
	CrosshairRotator = new(none) class'TexRotator';

	CrosshairRotator.Material = SecondaryCrossHair;
	CrosshairRotator.UOffset = 32;
	CrosshairRotator.VOffset = 32;


	// Save my current rotation as the base to which the limits are relative
	BaselineRotation = Rotation;

	// Convert units to Unreal units, if specified in degrees
	if(abs(fMinYaw) <= 360.0) 
		fMinYaw *= 65536.0/360.0;
	if(abs(fMaxYaw) <= 360.0) 
		fMaxYaw *= 65536.0/360.0;
	if(abs(fMinPitch) <= 360.0) 
		fMinPitch *= 65536.0/360.0;
	if(abs(fMaxPitch) <= 360.0) 
		fMaxPitch *= 65536.0/360.0;

	// If specified in positive units, convert to negative units
	if(fMinYaw > 0)
		fMinYaw = -fMinYaw;
	if(fMinPitch > 0)
		fMinPitch = -fMinPitch;

	// Change our accuracy based on LD setting
	BaseAccuracy += BaseAccuracy * AccuracyMultiplier;
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

	if(bAnimBasedAiming || bFakeFire)
	{
		Forward = vector(rotation);
	}
	else
	{
		GetAxes(Rotation, Forward, Right, Up);

		if(!bPerfectAim)
		{
			AdjustedAim = rotator(Forward);
			AdjustedAim = VietnamAdjustAim(AdjustedAim);

			Forward = vector(AdjustedAim);
		}
	}

	// Now that we have forward, project out along the forward vector to the MaxRange 
	// of our weapon
	vEnd = vStart + (MaxRange * Forward);

	// Set value to optional vector
	Start = vStart;

	return vEnd; 
}

// Overridden from ConsolidatedTurret to use GetFireStart for the starting point
// for tracers, since this thing has no muzzlebone
function TraceFire()
{
	local vector HitLocation, StartTrace, EndTrace, vForward, vRight, vUp;

	GetAxes(Rotation,vForward, vRight, vUp);

	// Get start and end points for the trace
	EndTrace = GetFireEnd(StartTrace);

	// Don't trace if we're only fake firing (still fire tracer though)
	if(bFakeFire)
		HitLocation = EndTrace;
	else
		HitLocation = InnerTraceFire(StartTrace, EndTrace);

	// If no target was hit, just fire a tracer forward
	// Otherwise fire it at the point that was hit

	if(HitLocation == vect(0,0,0))
		HandleTracer(GetFireStart(), EndTrace, vRight);
	else
		HandleTracer(GetFireStart(), HitLocation, vRight);
}

function SetupAttachments()
{
	// Setup shell eject system
	ShellEject = spawn(class'ShellEjectEmitter',self);
	if(ShellEject?)
	{
		Base.AttachToBone(ShellEject, AttachmentBone);
		ShellEject.SetRelativeLocation(vect(-75,0,0));
	}

	// Setup muzzle flash
	MF = spawn( class'MuzzleFlashAttachment',self );
	if (MF?)
	{
		MF.SetMuzzleFlashVariant( MFClass );
		Base.AttachToBone(MF, AttachmentBone);
		MF.SetRelativeLocation(vect(65,0,6));
		MF.SetRelativeRotation(rot(0,16384,0));
	}
	else
		log("Muzzleflash not created");
}

function Tick(float DeltaTime)
{
	local rotator NewRotation;

	SpinRate -= 84381 * DeltaTime;	// 196608 / 2.3
	if(SpinRate < 0)
		SpinRate = 0;

	NewRotation = Relativerotation;
	NewRotation.Roll += SpinRate * DeltaTime;

	SetRelativeRotation(NewRotation);

	Super.Tick(DeltaTime);
}

function vector GetFireStart()
{
	local vector vForward, vRight, vUp;

	// Our rotation will change, so check against our base's rotation (which is the helo's)
	GetAxes(Base.Rotation, vForward, vRight, vUp);

	return location + vForward * 58 + vUp * 6;
}

// The player using this turret has pressed the fire button
function ForceFire()
{
	local VietnamPlayerController VPController;

	SpinRate = MaxSpinRate;

	if ( bAutoTurret == true  || IsInState('ScriptedShoot'))
	{
		TraceFire();
		TriggerFiringEffects();
		CurrentRecoil += Recoil;
	}
	else
	{
		// For stats tracking
		VPController = VietnamPlayerController(User);
		if(VPController?)
		{
			VPController.ClientPlaySound(TurretSounds[ETurretSound.ETS_FPFire]);
			VPController.PlayerReplicationInfo.iShotsFired++;
		}

		TraceFire();

		CurrentRecoil += Recoil;

		TriggerFiringEffects();

		GotoState('NormalFire');
	}
}

state NormalFire
{
	function BeginState()
	{
//		PlayFiringAnimation('Fire');
	}

	function Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		if(TimeTillNextShot <= 0.0)
		{
			Fire();
			TimeTillNextShot = default.TimeTillNextShot;
		}
		else
			TimeTillNextShot -= DeltaTime;
	}

	function AnimEnd(int Channel)
	{
		if(!Instigator.PressingFire())
			GotoState('FireEnd');
	}	
}

state FireEnd
{
	ignores Fire;

	function AnimEnd(int Channel)
	{
		GotoState('Idle');
	}

	function BeginState()
	{
//		PlayAnim('fire_end',1.0,0.0);
	}
}

// We have an active target
state AutoTurretFiring
{
	function Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		// If fakefire is true, just fire regardless of target
		if(bFakeFire)
		{
			// Blast away
			DecideToFire(DeltaTime);
			return;
		}

		// Check if we can't see the enemy, maybe give up and go to searching mode?
		if(bCanSeeTarget)
			fTimeSinceTargetLastSighted = 0.0f;
		else
			fTimeSinceTargetLastSighted += DeltaTime;

		if(fTimeSinceTargetLastSighted >= fTimeTillGiveUp)
		{
			TargetActor = None;
			GotoState('AutoTurretSearching');
			return;
		}

		// Periodically check if the target is still there
		fTimeTillTargetCheck -= DeltaTime;
		if(fTimeTillTargetCheck <= 0)
		{
			fTimeTillTargetCheck = Default.fTimeTillTargetCheck;
			TargetActor = UpdateThreat();
		}

		if(TargetActor == None && !bForceFire)
		{
			GotoState('AutoTurretSearching');
			return;
		}

		// NOTE: Doesn't rotate like other turrets
		
		if(bTracersLeadTarget)
			CalculateLead(DeltaTime);

		// Blast away
		DecideToFire(DeltaTime);

		// Save location this frame for leading purposes
		vTargetLastLocation = TargetActor.Location;
	}
}

simulated static function StaticPrecacheAssets(optional Object MyLevel)
{
	//precache the static mesh by default.
	//if somehow we actually wanted a mesh we'd be wasting memory.
	//some spam is placed elsewhere in this class to alert us of this.

//log("calling SPCA TMA");

	DynamicLoadObject("Vehicle_attachments_stat.huey.hueyattach_rotate", class'StaticMesh');

	LoadSounds(Default.TurretSoundNames, Default.TurretSounds);

	Super.StaticPrecacheAssets(MyLevel);
}

defaultproperties
{
     MaxSpinRate=196608.000000
     TimeTillNextShot=0.067000
     ConnectingAnimation="VEH_Jeep_seat2_GetIn"
     DisconnectingAnimation="VEH_Jeep_seat2_GetOut"
     IdleAnimation="VEH_Huey_gunner_idle"
     AimUpAnimation="VEH_Huey_gunner_idle_up"
     AimDownAnimation="VEH_Huey_gunner_idle_down"
     AimLeftAnimation="VEH_Huey_gunner_idle_left"
     AimRightAnimation="VEH_Huey_gunner_idle_right"
     FireTurretAnimation="VEH_Huey_gunner_fire"
     m_bLimitRotation=True
     fMinYaw=60.000000
     fMaxYaw=60.000000
     fMinPitch=60.000000
     fMaxPitch=60.000000
     bAutoTurret=True
     iBurstAmount=30
     Damage=15.000000
     bOnlyFireWithTracers=True
     bFakeFire=True
     BaseAccuracy=50.000000
     StaticMeshName="Vehicle_attachments_stat.huey.hueyattach_rotate"
     TurretSoundNames(0)=(PackageName="weapon_snd",ResourceName="M60Outdoor")
     TurretSoundNames(1)=(PackageName="weapon_snd",ResourceName="M60NP")
     m_painAnimations(0)="SCR_AB_Tur_center_pain"
     m_painAnimations(1)="SCR_AB_Tur_center_pain2"
     m_crouchingPainAnimations(0)="SCR_CR_Tur_center_pain"
     m_crouchingPainAnimations(1)="SCR_CR_Tur_center_pain2"
     bCollideActors=False
     bBlockZeroExtentTraces=False
     m_bIsActive=False
     DrawType=DT_StaticMesh
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     m_arrEventStates(0)="LostTarget"
     m_arrEventStates(1)="FoundTarget"
     m_arrEventStates(2)="used"
}
