//=============================================================================
// AmmoM79SmokeGrenade
// class for smoke grenades
//=============================================================================
class AmmoM79SmokeGrenade extends VietnamAmmo;

function SpawnProjectile(vector Start, rotator Dir)
{
//	AmmoAmount -= 1;
	Spawn(ProjectileClass,Owner,, Start,Dir);	
}

defaultproperties
{
     MaxAmmo=10
     AmmoAmount=0
     bInstantHit=False
     ProjectileClass=Class'VietnamWeapons.ProjectileM79SmokeGrenade'
     PickupType="PickupAmmoM79SmokeGrenade"
     ItemName="Smoke Grenades"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
