//=============================================================================
// AmmoM79FragGrenade
// class for frag grenades
//=============================================================================
class AmmoM79FragGrenade extends VietnamAmmo;

function SpawnProjectile(vector Start, rotator Dir)
{
	local Projectile SpawnedProjectile;

//	AmmoAmount -= 1;
	SpawnedProjectile = Spawn(ProjectileClass,Owner,, Start,Dir);
	SpawnedProjectile.InstigatorController = Instigator.Controller;
}

defaultproperties
{
     MaxAmmo=15
     AmmoAmount=0
     bInstantHit=False
     ProjectileClass=Class'VietnamWeapons.ProjectileM79FragGrenade'
     PickupType="PickupAmmoM79FragGrenade"
     ItemName="Frag Grenades"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
