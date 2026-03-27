//////////////////////////////////////////////////////////////////////////////
//	File:	TurretMule106mm.uc
//
//	Description	:	This is a mountable turret
//----------------------------------------------------------------------------
class TurretMule106mm extends ConsolidatedTurret
	placeable;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	bForceUpdateAnimation = true;
}

defaultproperties
{
     MaxReticuleSize=500.000000
     m_bLimitRotation=True
     fMinPitch=30.000000
     fMaxPitch=30.000000
     TurnRate=2000
     MaxRange=5000.000000
     Damage=50.000000
     bFiresTracerRounds=False
     bFireProjectiles=True
     ProjectileClass=Class'VietnamWeapons.Projectile106mm'
     BaseAccuracy=50.000000
     MFClass=MF_50Cal
     MeshName="USMC_Landcraft.USMC_mule_gun"
     bUseBonePivots=True
     YawBonePivot="mule_stand_axel"
     PitchBonePivot="mule_barrel"
     MuzzleBone="muzzle_flash"
     ShellEjectBone="tag_eject"
     StartFireAnim="Idle"
     iRoundsPerSecond=1
     TurretSoundNames(0)=(PackageName="weapon_snd",ResourceName="M2HMGOutdoor")
     TurretSoundNames(1)=(PackageName="weapon_snd",ResourceName="M2HMGNP")
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
