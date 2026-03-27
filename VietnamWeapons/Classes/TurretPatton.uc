//////////////////////////////////////////////////////////////////////////////
//	File:	TurretPBR.uc
//
//	Description	:	This is a mountable turret
//----------------------------------------------------------------------------
class TurretPatton extends ConsolidatedTurret
	placeable;

defaultproperties
{
     TurnRate=2000
     MaxRange=5000.000000
     Damage=100.000000
     ProjectileClass=Class'VietnamWeapons.ProjectileRPG7'
     MFClass=MF_50Cal
     MeshName="USMC_Landcraft.USMC_Patton_M60turret"
     bUseBonePivots=True
     YawBonePivot="M60turret_rotate"
     PitchBonePivot="M60turret_pitch"
     MuzzleBone="M60turret_flash"
     ShellEjectBone="M60turret_flash"
     StartFireAnim="Fire"
     iRoundsPerSecond=8
     TurretSoundNames(0)=(PackageName="weapon_snd",ResourceName="M60Outdoor")
     TurretSoundNames(1)=(PackageName="weapon_snd",ResourceName="M60NP")
     m_fViewYawKick=128.000000
     m_fViewPitchKick=128.000000
     m_fViewDegradeYaw=1536.000000
     m_fViewDegradePitch=1536.000000
     m_fViewKickMaxYawDelta=128.000000
     m_fViewKickMaxPitchDelta=128.000000
     m_painAnimations(0)="SCR_AB_Tur_center_pain"
     m_painAnimations(1)="SCR_AB_Tur_center_pain2"
     m_crouchingPainAnimations(0)="SCR_CR_Tur_center_pain"
     m_crouchingPainAnimations(1)="SCR_CR_Tur_center_pain2"
     bUseLightingFromBase=True
     bBlockNonZeroExtentTraces=False
     CollisionRadius=30.000000
     CollisionHeight=20.000000
     m_arrEventStates(0)="LostTarget"
     m_arrEventStates(1)="FoundTarget"
     m_arrEventStates(2)="used"
}
