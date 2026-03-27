class M60Patton extends VietnamVehicleTank;

//**********************************************************************
//*
//*	FUNCTIONS
//*
//**********************************************************************

//------------------------------------------------
function UpdateWheels()
// Texture panning and scrolling set by vehicle speed
//------------------------------------------------
{
	//log( "1.UpdateWheels() for " $self $" m_treadPanner=" $m_treadPanner $" m_treadPanner.PanRate=" $m_treadPanner.PanRate $" m_fCurrentSpeed=" $m_fCurrentSpeed );

	//m_fAccurateSpeed = 200;

	// Tread...
	m_treadPanner.PanRate = m_fAccurateSpeed * -0.01;

	// Wheels...
	m_wheelRotator[0].Rotation.Yaw = m_fAccurateSpeed * -250;
	m_wheelRotator[1].Rotation.Yaw = m_fAccurateSpeed * -250;
	m_wheelRotator[2].Rotation.Yaw = m_fAccurateSpeed * 250;
	
	// Empty any saved material states as this shader updates dynamically
	m_treadPanner.SavedMaterialState.Length = 0;
	m_wheelRotator[0].SavedMaterialState.Length = 0;
	m_wheelRotator[1].SavedMaterialState.Length = 0;
	m_wheelRotator[2].SavedMaterialState.Length = 0;

	//log( "2.UpdateWheels() for " $self $" m_treadPanner=" $m_treadPanner $" m_treadPanner.PanRate=" $m_treadPanner.PanRate $" m_fCurrentSpeed=" $m_fCurrentSpeed );
}

function LimitCannonPitch()
{
	if ( m_verticalAimRotation.Pitch > 2000 )
	{
		m_verticalAimRotation.Pitch = 2000;
	}

	if ( m_verticalAimRotation.Pitch < -12000 )
	{
		m_verticalAimRotation.Pitch = -12000;
	}
}

//--------------------------------------------------------------------
//
// INITIALIZATION
//
//--------------------------------------------------------------------
function AutoStateConstructor()
{
	local TexPanner  defaultPanner;
	local TexRotator defaultRotator;

	//m_shader = New(None) class'Shader';
	//m_shader.Diffuse = m_treadPanner;
	//Skins[6] = m_shader;

	//log( "M48Patton::AutoStateConstructor() " );

	defaultPanner = TexPanner(DynamicLoadObject("vehicles_tex.M48_patton.m48_patton_thread_texpan", class'TexPanner'));
	m_treadPanner = New(None) class'TexPanner';
    m_treadPanner.PanDirection = defaultPanner.PanDirection;
	m_treadPanner.Material = defaultPanner.Material;
	Skins[4] = m_treadPanner;
	
	defaultRotator    = TexRotator(DynamicLoadObject("vehicles_tex.M48_patton.m48_patton_w1_texrotator", class'TexRotator'));
	m_wheelRotator[0] = New(None) class'TexRotator';
	m_wheelRotator[0].TexRotationType = defaultRotator.TexRotationType;
	m_wheelRotator[0].UOffset = defaultRotator.UOffset;
	m_wheelRotator[0].VOffset = defaultRotator.VOffset;
	m_wheelRotator[0].Material = defaultRotator.Material;
	Skins[0] = m_wheelRotator[0];

	defaultRotator    = TexRotator(DynamicLoadObject("vehicles_tex.M48_patton.m48_patton_w2_texrotator", class'TexRotator'));
	m_wheelRotator[1] = New(None) class'TexRotator';
	m_wheelRotator[1].TexRotationType = defaultRotator.TexRotationType;
	m_wheelRotator[1].UOffset = defaultRotator.UOffset;
	m_wheelRotator[1].VOffset = defaultRotator.VOffset;
	m_wheelRotator[1].Material = defaultRotator.Material;
	Skins[3] = m_wheelRotator[1];

	defaultRotator    = TexRotator(DynamicLoadObject("vehicles_tex.M48_patton.m48_patton_w4_texrotator", class'TexRotator'));
	m_wheelRotator[2] = New(None) class'TexRotator';
	m_wheelRotator[2].TexRotationType = defaultRotator.TexRotationType;
	m_wheelRotator[2].UOffset = defaultRotator.UOffset;
	m_wheelRotator[2].VOffset = defaultRotator.VOffset;
	m_wheelRotator[2].Material = defaultRotator.Material;
	Skins[2] = m_wheelRotator[2];
	
	//m_wheelDust[ 0 ] = spawn( class'WheelDustEmitter', self );
	//m_wheelDust[ 1 ] = spawn( class'WheelDustEmitter', self );
	m_wheelDust[ 0 ] = spawn( class'HackDefaultParticleEffect', self );
	m_wheelDust[ 1 ] = spawn( class'HackDefaultParticleEffect', self );

	//log("constructing WheelDustEmitter");
	m_wheelDust[ 0 ].LookupConstruct("WheelDustEmitter");	
	m_wheelDust[ 1 ].LookupConstruct("WheelDustEmitter");
	
	super.AutoStateConstructor();
}	

defaultproperties
{
     m_springFrequency=0.100000
     m_springMagnitude=10.000000
     Damping=0.990000
     m_cannonYawBone="Top"
     m_cannonPitchBone="cannon_anchor"
     m_ROF=3.000000
     m_fWheelBaseWidth=320.000000
     m_fWheelBaseLength=420.000000
     mWheelBone(0)="ground_bone_front_left"
     mWheelBone(1)="ground_bone_rear_left"
     mWheelBone(2)="ground_bone_front_right"
     mWheelBone(3)="ground_bone_rear_right"
     m_attachmentsCount=2
     m_attachmentsList(0)=(AttachmentClass=Class'Vehicles.StaticPATTON',Title="StaticPATTON",Bone="Patton_root")
     m_attachmentsList(1)=(AttachmentClass=Class'VietnamWeapons.TurretPatton',Title="Patton_M60",Bone="M60turret_attach",bUseAsBase=True)
     m_fMaxSpeed=30.000000
     m_fAcceleration=2.000000
     m_fMaxTurningAngle=24000.000000
     m_fFriction=0.250000
     m_steeringWheelBone="Tag_drivingwheel"
     fMaxSpeed=800.000000
     mSeatBone(0)="Tag_driver_seat"
     mSeatBone(1)="Tag_horizontal"
     mExitBone(0)="Tag_driver_getin"
     SoundStates(1)=(bUseRPC=True,RPCName="RPM",SoundName="M603D")
     SoundStates(2)=(bUseRPC=True,RPCName="RPM",SoundName="M60")
     m_bUseCollisionBoxes=True
     m_vStopBoxLoc=(Z=120.000000)
     m_vStopBoxExtent=(X=930.000000,Y=320.000000,Z=100.000000)
     m_vPathBoxLoc=(Z=120.000000)
     m_vPathBoxExtent=(X=495.000000,Y=255.000000,Z=100.000000)
     mCrew(0)=(tagString="None")
     mCrew(1)=(tagString="None")
     mCrew(2)=(tagString="None")
     mCrew(3)=(tagString="None")
     mCrew(4)=(tagString="None")
     mCrew(5)=(tagString="None")
     mCrew(6)=(tagString="None")
     mCrew(7)=(tagString="None")
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
     AssetName="USMC_Landcraft.USMC_Patton"
}
