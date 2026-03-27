// Weapon specific ThirdPersonEffects
class WeaponClaymoreAttachment extends VietnamWeaponAttachment;

// the two models that are switched in and out
const CLACKER_MODEL_NAME  = "low_poly_weapons_stat.claymore_low_poly_stat";
const CLAYMORE_MODEL_NAME = "weapons_stat.us.claymore_stat";

// the animation to play when swapping the models
const SWITCHING_ANIMATION_NAME = 'OH_Ab_takeout_putaway';
const SWITCHING_ANIMATION_RATE = 2.0f;
const SWITCHING_ANIMATION_BONE = 'Bip_Spine1';

// the length of time to wait for a model
// switch to occur (used to match up the model
// swap with the proper point in the animation)
const MODEL_SWITCH_DELAY       = 0.5f;

// holds the name of the model that will be
// swapped to when triggerModelSwitch is called
var String m_newModelName;

var vector NewRelativeLocation;
var rotator NewRelativeRotation;

// triggers a model switch when activated
//
// inputs:
// -- none --
//
// outputs:
// -- none --
function TriggerModelSwitch( )
{
	SetStaticMesh( StaticMesh( DynamicLoadObject(
		m_newModelName, class'StaticMesh' ) ) );

	SetRelativeLocation(NewRelativeLocation);
	SetRelativeRotation(NewRelativeRotation);
}

// sets up a model swap to occur later
//
// inputs:
// inNewModel - the new model to show
//
// outputs:
// -- none --
simulated function EnableModelSwap(
	String inNewModel )
{
	m_newModelName = inNewModel;
	
	SetDelegateTimer( 'TriggerModelSwitch',
		MODEL_SWITCH_DELAY, false );
}

// plays an animation to suggest that
// the Pawn is swapping out models
//
// inputs:
// -- none --
//
// outputs:
// -- none --
simulated function PlaySwapAnimation( )
{
	local AnimInfo newAnimation;
	
	if ( Instigator? )
	{
		// build the animation to play
		newAnimation.AnimName  = SWITCHING_ANIMATION_NAME;
		newAnimation.Channel   = Instigator.FIRINGCHANNEL;
		newAnimation.Rate      = SWITCHING_ANIMATION_RATE;
		newAnimation.StartBone = SWITCHING_ANIMATION_BONE;
		
		// trigger the switching animation
		Instigator.StartAnimation( newAnimation, true, true );
	}
}

// turn on the clacker model, turn off the claymore model
//
// inputs:
// -- none --
//
// outputs:
// -- none --
simulated function ShowClacker( )
{
	local Rotator newRotation;

	// set up a model switch
	EnableModelSwap( CLACKER_MODEL_NAME );
		
	// makes the Pawn look like its reaching for
	// the clacker
	PlaySwapAnimation( );
}

// turn off the clacker model, turn on the claymore model
//
// inputs:
// -- none --
//
// outputs:
// -- none --
simulated function ShowClaymore( )
{
	local Rotator newRotation;

	// set up a model switch
	EnableModelSwap( CLAYMORE_MODEL_NAME );

	// makes the Pawn look like its reaching for
	// the claymore
	PlaySwapAnimation( );
}

// overloaded:  precaches the clacker and claymore model
//
// inputs:
// -- none --
//
// outputs:
// -- none --
simulated function PrecacheAssets( )
{
	DynamicLoadObject( CLACKER_MODEL_NAME, class'StaticMesh' );
	DynamicLoadObject( CLAYMORE_MODEL_NAME, class'StaticMesh' );
	
	Super.PrecacheAssets( );
}

// overloaded:  precaches the clacker and claymore model
//
// inputs:
// -- none --
//
// outputs:
// -- none --
simulated static function StaticPrecacheAssets(optional Object MyLevel)
{
	DynamicLoadObject( CLACKER_MODEL_NAME, class'StaticMesh' );
	DynamicLoadObject( CLAYMORE_MODEL_NAME, class'StaticMesh' );
	
	Super.StaticPrecacheAssets( );
}

defaultproperties
{
     MuzzleOffset=(X=135.000000,Y=23.000000,Z=10.000000)
     MuzzleRotationOffset=(Yaw=16383)
     DrawType=DT_StaticMesh
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
