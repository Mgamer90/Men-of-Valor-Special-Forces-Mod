//=============================================================================
// Ammo762NATOBeltFed
// base class of bullet ammunition used by assault rifles
// has information about clip sizes, and damage
//=============================================================================
class Ammo762NATOBeltFed extends VietnamAmmo;

defaultproperties
{
     Damage=40.000000
     MaxAmmo=500
     AmmoAmount=0
     PickupType="PickupAmmo762NATOBeltFed"
     ItemName="7.62 Belt-Fed Ammo"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
