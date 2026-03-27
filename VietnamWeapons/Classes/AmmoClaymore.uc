//=============================================================================
// AmmoClaymore
// class for booby traps
// Spawning of trap is handled by weapon
//=============================================================================
class AmmoClaymore extends VietnamAmmo;

// Do nothing boobytrap is handled differently than other weapons
function SpawnProjectile(vector Start, rotator Dir)
{
}

defaultproperties
{
     MaxAmmo=3
     AmmoAmount=0
     bInstantHit=False
     PickupType="PickupClaymore"
     ItemName="Claymore Mines"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
