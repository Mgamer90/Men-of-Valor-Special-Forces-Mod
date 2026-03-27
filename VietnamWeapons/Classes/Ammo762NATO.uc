//=============================================================================
// Ammo762NATO
// base class of bullet ammunition used by assault rifles
// has information about clip sizes, and damage
//=============================================================================
class Ammo762NATO extends VietnamAmmo;

defaultproperties
{
     Damage=40.000000
     MaxAmmo=500
     AmmoAmount=0
     PickupType="PickupAmmo762NATO"
     ItemName="7.62 NATO Ammo"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
