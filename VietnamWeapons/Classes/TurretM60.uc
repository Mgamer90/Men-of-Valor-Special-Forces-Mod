//////////////////////////////////////////////////////////////////////////////
//	File:	TurretM60.uc
//
//	Description	:	This is a mountable M60
//  NOTE: The GetFireStart, TraceFire, and all similar functions were copied from
//  VietnamWeapons.  This is a *HACK* and a better solution should be used in the future.
//----------------------------------------------------------------------------
class TurretM60 extends ConsolidatedTurret
	placeable;

defaultproperties
{
     AimUpAnimation="TUR_M60_Down_Up"
     AimDownAnimation="TUR_M60_Right_Left"
     AimLeftAnimation="TUR_M60_Diagonal_left"
     AimRightAnimation="TUR_M60_Diagonal_right"
     MaxRange=5000.000000
     Damage=50.000000
     ProjectileClass=Class'VietnamWeapons.ProjectileRPG7'
     MFClass=MF_M60
     ShellEjectType=2
     MeshName="USMC_Viewmodels.turret_m60"
     MuzzleBone="tag_muzzle"
     ShellEjectBone="tag_eject"
     TriggerBone="Player"
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
