//////////////////////////////////////////////////////////////////////////////
//	File:	TurretType24.uc
//
//	Description	:	This is a mountable turret
//----------------------------------------------------------------------------
class TurretType24 extends ConsolidatedTurret
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
     AimUpAnimation="TUR_T24_CR_Down_Up"
     AimDownAnimation="TUR_T24_CR_Right_Left"
     AimLeftAnimation="TUR_T24_CR_Diagonal_left"
     AimRightAnimation="TUR_T24_CR_Diagonal_right"
     m_bLimitRotation=True
     fMinPitch=60.000000
     fMaxPitch=60.000000
     TurnRate=2000
     MaxRange=5000.000000
     Damage=50.000000
     ProjectileClass=Class'VietnamWeapons.ProjectileRPG7'
     MFClass=MF_50Cal
     ShellEjectType=1
     MeshName="Turrets.Type24"
     bUseBonePivots=True
     YawBonePivot="neck_24"
     PitchBonePivot="gun_24"
     MuzzleBone="gun_flash"
     ShellEjectBone="tag_eject"
     TriggerBone="soldier"
     iRoundsPerSecond=10
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
