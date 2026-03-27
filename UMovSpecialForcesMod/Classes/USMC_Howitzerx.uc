class USMC_Howitzerx extends VietnamVehicleLand;

#exec OBJ LOAD FILE="..\Sounds\Weapon_snd.uax"

//var vector		m_targetLocation;
//var () bool		m_bPseudoAiming;

var int			m_tracerRatio; 
var () int		m_tracerLifeTime;
var () float	m_tracerScale;
var () float	m_muzzleFlashScale;

var Emitter		m_FireEffect;

//******************************************************************
//*
//*	FUNCTIONS
//*
//**********************************************************************


//------------------------------------------------
//
function PostBeginPlay()
//
//------------------------------------------------
{
	Super.PostBeginPlay();
	bInterpolating = false;
}


//**********************************************************************
//
// STATES: Idling, Starting, Moving, Stopping, Blocked
//
//**********************************************************************

//--------------------------------------------------------------------
//
State Idling
//
//--------------------------------------------------------------------
{
}	// End State::Idling


//--------------------------------------------------------------------
//
State Starting
//
//--------------------------------------------------------------------
{
}


function DoMuzzleFlash()
{
	local TracerEffect Tracer;
	local vector SpawnLocation, vTracerUp;
	local rotator boneRotation;

	//log( "NVAZU23::DoMuzzleFlash()" );

	m_FireEffect = Spawn(class'HackDefaultParticleEffect');
	m_FireEffect.LookupConstruct("M48FireEffect");	

	m_FireEffect.SetRotation( GetBoneRotation( 'tag_muzzle' ) );
	m_FireEffect.SetLocation( GetBoneCoords( 'tag_muzzle' ).Origin );	
	
	PlaySound(sound'Weapon_snd.AntiAircraftGun');
}

//-----------------------------------------------------------------
//
State Moving
//
//-----------------------------------------------------------------
{
	//---------------------------
	function BeginState()
	//---------------------------
	{
		LoopAnim( 'Fire' );
		//SetTimer(3.0, true);
	}
}


//--------------------------------------------------------------------
//
// INITIALIZATION
//
//--------------------------------------------------------------------
function AutoStateConstructor()
{
//	RegisterSound(sound'Weapon_snd.AntiAircraftGun');
}	

// overloaded:  caches assets for the muzzle flash
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (UnReal event)
static simulated function StaticPrecacheAssets(optional Object MyLevel)
{
	// make sure to let the parent class do its work
	Super.StaticPrecacheAssets( );
	
	// force caching of the muzzle flash attachment type's assets
	//class'MuzzleFlashAttachment'.Static.ForceMuzzleFlashPrecache(
	//	default.MFClass );
}

function WarpToRabbit()
{
	//dont want to do anything as the zu23 never moves. 
	//if this changes, be aware that VietnamVehicleLand calls
	//orienttoterrain, which will stick the zu something like 30 units
	//into the ground.
}

defaultproperties
{
     m_tracerLifeTime=2000
     m_tracerScale=2.000000
     m_muzzleFlashScale=0.500000
     m_fWheelBaseWidth=80.000000
     m_fWheelBaseLength=160.000000
     mWheelBone(0)="Howitzer_base"
     mWheelBone(1)="Howitzer_base"
     mWheelBone(2)="Howitzer_base"
     mWheelBone(3)="Howitzer_base"
     m_attachmentsList(0)=(AttachmentClass=Class'Vehicles.StaticHowitzer',Title="HowitzerCollision",Bone="Howitzer_base")
     m_fMaxSpeed=1.000000
     m_fAcceleration=2.000000
     m_fMaxTurningAngle=24000.000000
     m_fFriction=0.010000
     m_animationSet="Human_SCR_Howitzer.SCR_Howitzer"
     mCrewCount=1
     mSeatBone(0)="Howitzer_seat01"
     mExitBone(0)="Howitzer_seat01"
     mCrew(0)=(tagString="None",IdleAnim="Idle")
     mCrew(1)=(tagString="None")
     mCrew(2)=(tagString="None")
     mCrew(3)=(tagString="None")
     mCrew(4)=(tagString="None")
     mCrew(5)=(tagString="None")
     mCrew(6)=(tagString="None")
     mCrew(7)=(tagString="None")
     bCollideWorld=True
     bProjTarget=True
     bBlockZeroExtentTraces=True
     bBlockNonZeroExtentTraces=True
     Physics=PHYS_Walking
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     m_arrEventStates(2)="used"
     m_arrEventStates(3)="Mounted"
     m_arrEventStates(4)="Dismounted"
     m_arrEventStates(5)="Damage_0_Level"
     m_arrEventStates(6)="Damage_1_Level"
     m_arrEventStates(7)="PassengerLoaded"
     m_arrEventStates(8)="PassengerUnloaded"
     m_arrEventStates(9)="WeaponFired"
     AssetName="USMC_Landcraft.USMC_Howitzer"
}
