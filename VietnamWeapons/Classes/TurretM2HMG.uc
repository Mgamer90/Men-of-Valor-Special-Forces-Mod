//////////////////////////////////////////////////////////////////////////////
//	File:	TurretM2HMG.uc
//
//	Description	:	This is a mountable turret
//----------------------------------------------------------------------------
class TurretM2HMG extends ConsolidatedTurret
	placeable;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	bForceUpdateAnimation = true;
}

// overridden:  must crouch for this turret
//
// inputs:
// -- none --
//
// outputs:
// true if user must crouch to fire, false
// if otherwise
simulated function Bool MustCrouchToFire( )
{
	return true;
}

defaultproperties
{
     ConnectingAnimation="SCR_CR_Tur_center"
     DisconnectingAnimation="SCR_CR_Tur_center"
     AimUpAnimation="Tur_M2HMG_CR_Down_Up"
     AimDownAnimation="Tur_M2HMG_CR_Right_Left"
     AimLeftAnimation="Tur_M2HMG_CR_Diagonal_Left"
     AimRightAnimation="Tur_M2HMG_CR_Diagonal_Right"
     m_bLimitRotation=True
     fMinPitch=30.000000
     fMaxPitch=60.000000
     TurnRate=2000
     MaxRange=5000.000000
     Damage=50.000000
     ProjectileClass=Class'VietnamWeapons.ProjectileRPG7'
     MFClass=MF_50Cal
     ShellEjectType=2
     MeshName="Turrets.M2HMG"
     bUseBonePivots=True
     YawBonePivot="neck"
     PitchBonePivot="gun"
     MuzzleBone="tag_muzzle"
     ShellEjectBone="tag_eject"
     TriggerBone="gunner"
     iRoundsPerSecond=15
     TurretSoundNames(0)=(PackageName="weapon_snd",ResourceName="M60Outdoor")
     TurretSoundNames(1)=(PackageName="weapon_snd",ResourceName="M60NP")
     m_fViewYawKick=100.000000
     m_fViewPitchKick=100.000000
     m_fViewDegradeYaw=1000.000000
     m_fViewDegradePitch=1000.000000
     m_fViewKickMaxYawDelta=100.000000
     m_fViewKickMaxPitchDelta=100.000000
     m_painAnimations(0)="SCR_AB_Tur_center_pain"
     m_painAnimations(1)="SCR_AB_Tur_center_pain2"
     m_crouchingPainAnimations(0)="SCR_CR_Tur_center_pain"
     m_crouchingPainAnimations(1)="SCR_CR_Tur_center_pain2"
     bBlockNonZeroExtentTraces=False
     CollisionRadius=30.000000
     CollisionHeight=20.000000
     m_arrEventStates(0)="LostTarget"
     m_arrEventStates(1)="FoundTarget"
     m_arrEventStates(2)="used"
}
