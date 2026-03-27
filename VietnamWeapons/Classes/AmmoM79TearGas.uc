//=============================================================================
// AmmoM79TearGas
// class for tear gas
//=============================================================================
class AmmoM79TearGas extends VietnamAmmo;

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
     ProjectileClass=Class'VietnamWeapons.ProjectileM79TearGas'
     ItemName="Tear Gas Grenades"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
