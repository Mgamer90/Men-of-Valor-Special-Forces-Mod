//=============================================================================
// AmmoBoobyTrap
// class for booby traps
// Spawning of trap is handled by weapon
//=============================================================================
class AmmoBoobyTrap extends VietnamAmmo;

// Do nothing boobytrap is handled differently than other weapons
function SpawnProjectile(vector Start, rotator Dir)
{
}

defaultproperties
{
     MaxAmmo=3
     AmmoAmount=0
     bInstantHit=False
     PickupType="PickupBoobyTrap"
     ItemName="Booby Traps"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
