//////////////////////////////////////////////////////////////////////////////
//	File:	TurretType24_Post.uc
//
//	Description	:	This is a mountable turret
//----------------------------------------------------------------------------
class TurretType24_Barrel extends TurretType24
	placeable;

var(ConsolidatedTurret) enum ETurretPose
{
	ETP_Standing,
	ETP_Crouching
}TurretPose;

// overridden:  this can be a standing or
// crouching turret
//
// inputs:
// -- none --
//
// outputs:
// true if user must crouch to fire, false
// if otherwise
simulated function Bool MustCrouchToFire( )
{
	return ( TurretPose == ETP_Crouching );
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	bForceUpdateAnimation = true;

	if(TurretPose == ETP_Standing)
	{
		IdleAnimation = 'SCR_AB_Tur_center';
		AimUpAnimation = 'TUR_T24_Down_Up';
		AimDownAnimation = 'TUR_T24_Right_Left';
		AimLeftAnimation = 'TUR_T24_Diagonal_left';
		AimRightAnimation = 'TUR_T24_Diagonal_right';
		FireTurretAnimation = 'TH_AB_Fire';
	}
	else if(TurretPose == ETP_Crouching)
	{
		IdleAnimation = 'SCR_CR_Tur_center';
		AimUpAnimation = 'TUR_T24_CR_Down_Up';
		AimDownAnimation = 'TUR_T24_CR_Right_Left';
		AimLeftAnimation = 'TUR_T24_CR_Diagonal_left';
		AimRightAnimation = 'TUR_T24_CR_Diagonal_right';
		FireTurretAnimation = 'TH_CR_Fire';
	}
}

defaultproperties
{
     MeshName="Turrets.Type24_barrel"
     ShellEjectBone="shell_ejector"
     iRoundsPerSecond=15
     TurretSoundNames(0)=(PackageName="weapon_snd",ResourceName="M60Outdoor")
     TurretSoundNames(1)=(PackageName="weapon_snd",ResourceName="M60NP")
     m_painAnimations(0)="SCR_AB_Tur_center_pain"
     m_painAnimations(1)="SCR_AB_Tur_center_pain2"
     m_crouchingPainAnimations(0)="SCR_CR_Tur_center_pain"
     m_crouchingPainAnimations(1)="SCR_CR_Tur_center_pain2"
     m_arrEventStates(0)="LostTarget"
     m_arrEventStates(1)="FoundTarget"
     m_arrEventStates(2)="used"
}
