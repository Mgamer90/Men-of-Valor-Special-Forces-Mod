//////////////////////////////////////////////////////////////////////////////
//	File:	TurretM60.uc
//
//	Description	:	This is a mountable M60
//  NOTE: The GetFireStart, TraceFire, and all similar functions were copied from
//  VietnamWeapons.  This is a *HACK* and a better solution should be used in the future.
//----------------------------------------------------------------------------
class TurretHueyRocketPod extends ConsolidatedTurret
	placeable;

simulated static function StaticPrecacheAssets(optional Object MyLevel)
{
//log("calling SPCA THRP");

	LoadSounds(Default.TurretSoundNames, Default.TurretSounds);

	Super.StaticPrecacheAssets(MyLevel);
}

defaultproperties
{
     ConnectingAnimation="SCR_Huey_player_getin_gunner"
     DisconnectingAnimation="VEH_Jeep_seat2_GetOut"
     IdleAnimation="VEH_Huey_gunner_idle"
     AimUpAnimation="VEH_Huey_gunner_idle_up"
     AimDownAnimation="VEH_Huey_gunner_idle_down"
     AimLeftAnimation="VEH_Huey_gunner_idle_left"
     AimRightAnimation="VEH_Huey_gunner_idle_right"
     FireTurretAnimation="VEH_Huey_gunner_fire"
     TurretDamageType=Class'VietnamGame.DamageGrenade'
     MaxReticuleSize=500.000000
     MaxRange=30000.000000
     Damage=50.000000
     bFiresTracerRounds=False
     bFireProjectiles=True
     ProjectileClass=Class'VietnamWeapons.ProjectileRPG7'
     BaseAccuracy=0.000000
     MeshName="USMC_Viewmodels.turret_m60"
     MuzzleBone="tag_muzzle"
     ShellEjectBone="tag_eject"
     TurretSoundNames(0)=(PackageName="weapon_snd",ResourceName="HueyFiringRocket")
     TurretSoundNames(1)=(PackageName="weapon_snd",ResourceName="HueyFiringRocket")
     m_painAnimations(0)="SCR_AB_Tur_center_pain"
     m_painAnimations(1)="SCR_AB_Tur_center_pain2"
     m_crouchingPainAnimations(0)="SCR_CR_Tur_center_pain"
     m_crouchingPainAnimations(1)="SCR_CR_Tur_center_pain2"
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     DrawScale=0.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     m_arrEventStates(0)="LostTarget"
     m_arrEventStates(1)="FoundTarget"
     m_arrEventStates(2)="used"
}
