//=============================================================================
// Ammo50Cal
// base class of bullet ammunition used by assault rifles
// has information about clip sizes, and damage
//=============================================================================
class Ammo50Cal extends VietnamAmmo;

defaultproperties
{
     MaxAmmo=500
     AmmoAmount=0
     PickupType="PickupAmmo50Cal"
     ItemName=".50 Cal. Ammo"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
