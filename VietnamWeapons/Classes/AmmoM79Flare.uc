//=============================================================================
// AmmoM79Flare
// class for flares
//=============================================================================
class AmmoM79Flare extends VietnamAmmo;

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
     ProjectileClass=Class'VietnamWeapons.ProjectileM79Flare'
     PickupType="PickupAmmoM79Flare"
     ItemName="Flares"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
