//=============================================================================
// Ammo556NATO
// base class of bullet ammunition used by assault rifles
// has information about clip sizes, and damage
//=============================================================================
class Ammo556NATO extends VietnamAmmo;

defaultproperties
{
     MaxAmmo=500
     AmmoAmount=0
     PickupType="PickupAmmo556NATO"
     ItemName="5.56 NATO Ammo"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
