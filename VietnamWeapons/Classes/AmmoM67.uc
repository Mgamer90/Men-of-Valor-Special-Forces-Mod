//=============================================================================
// AmmoM67
// base class of bullet ammunition used by assault rifles
// has information about clip sizes, and damage
//=============================================================================
class AmmoM67 extends VietnamAmmo;

function SpawnHomingProjectile(vector Start, rotator Dir, optional Actor HomingTarget)
{
	local ProjectileM67 SpawnedProjectile;

//	AmmoAmount -= 1;
	SpawnedProjectile = ProjectileM67(Spawn(ProjectileClass,Owner,, Start,Dir));
	SpawnedProjectile.HomingTarget = HomingTarget;
	SpawnedProjectile.InstigatorController = Instigator.Controller;
}

defaultproperties
{
     MaxAmmo=10
     AmmoAmount=0
     bInstantHit=False
     ProjectileClass=Class'VietnamWeapons.ProjectileM67'
     PickupType="PickupAmmoM67"
     ItemName="M67 Shells"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
