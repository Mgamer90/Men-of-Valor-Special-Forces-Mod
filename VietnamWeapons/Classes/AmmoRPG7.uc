//=============================================================================
// Ammo45Cal
// base class of bullet ammunition used by assault rifles
// has information about clip sizes, and damage
//=============================================================================
class AmmoRPG7 extends VietnamAmmo;

function SpawnHomingProjectile(vector Start, rotator Dir, optional Actor HomingTarget)
{
	local ProjectileRPG7 SpawnedProjectile;

//	AmmoAmount -= 1;
	SpawnedProjectile = ProjectileRPG7(Spawn(ProjectileClass,Owner,, Start,Dir));
	SpawnedProjectile.HomingTarget = HomingTarget;

	if(Instigator?)
	{
		SpawnedProjectile.InstigatorVelocity = Instigator.Velocity;
		SpawnedProjectile.InstigatorController = Instigator.Controller;
	}
}

defaultproperties
{
     MaxAmmo=10
     AmmoAmount=0
     bInstantHit=False
     ProjectileClass=Class'VietnamWeapons.ProjectileRPG7'
     PickupType="PickupAmmoRPG7"
     ItemName="RPG Rockets"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
