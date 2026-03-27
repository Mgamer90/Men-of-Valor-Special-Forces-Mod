// Weapon specific ThirdPersonEffects
class WeaponRPG7Attachment extends VietnamWeaponAttachment
	native
	nativereplication;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// index of the rocket texture (the one we need to turn
// off and on
const ROCKET_SKIN              = 1;

// string name of the transparency texture
const TRANSPARENT_TEXTURE_NAME = "Decals_tex.transparency_tex_shader";

// this variable helps clients keep track of
// when to display their rockets
var Bool m_showRocket;

// caches the name of the rocket texture (need to
// keep track of it when the rocket is hidden)
var Material m_rocketTexture;

// the transparent texture used to hide the rocket
var Material m_transparentTexture;

replication
{
	reliable if ( bNetDirty && (Role == ROLE_Authority) )
		m_showRocket;
}

// makes the clients hide and unhide their rockets
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (UnReal event)
simulated function OnPostReceive_m_showRocket( )
{
	if ( m_showRocket )
	{
		ShowRocket( );
	}
	else
	{
		HideRocket( );
	}
}

// overloaded:  synch up the skins so that they can
// successfully monkeyed with
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (UnReal event)
simulated function PostNetBeginPlay( )
{
	// do the parent stuff first
	Super.PostNetBeginPlay( );
	
	// then copy over the skins arrays
	CopyMaterialsToSkins( );
	
	// and take note of the current rocket texture
	m_rocketTexture      = Skins[ ROCKET_SKIN ];
	
	// get access to the transparency texture
	m_transparentTexture = Shader( DynamicLoadObject(
		TRANSPARENT_TEXTURE_NAME, class'Shader' ) );
}

// call this to turn on the rocket model
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (trigger function)
simulated function ShowRocket( )
{
	if ( Level.NetMode != NM_Client )
	{
		m_showRocket = true;
	}

	Skins[ ROCKET_SKIN ] = m_rocketTexture;
}

// call this to turn off the rocket model
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (trigger function)
simulated function HideRocket( )
{
	if ( Level.NetMode != NM_Client )
	{
		m_showRocket = false;
	}
	
	Skins[ ROCKET_SKIN ] = m_transparentTexture;
}

defaultproperties
{
     m_showRocket=True
     MuzzleOffset=(X=115.000000,Z=13.000000)
     MuzzleRotationOffset=(Yaw=16383)
     StaticMeshName="low_poly_weapons_stat.rpg7_low_poly_stat"
     DrawType=DT_StaticMesh
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
