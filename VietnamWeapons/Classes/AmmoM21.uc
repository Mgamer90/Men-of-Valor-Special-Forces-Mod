//=============================================================================
// AmmoM21
// base class of bullet ammunition used by assault rifles
// has information about clip sizes, and damage
//=============================================================================
class AmmoM21 extends VietnamAmmo;

defaultproperties
{
     Damage=50.000000
     MaxAmmo=500
     AmmoAmount=0
     PickupType="PickupAmmoM21"
     ItemName="7.62 Sniper Ammo"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
