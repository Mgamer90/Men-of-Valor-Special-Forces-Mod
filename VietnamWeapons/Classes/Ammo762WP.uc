//=============================================================================
// Ammo762WP
// base class of bullet ammunition used by assault rifles
// has information about clip sizes, and damage
//=============================================================================
class Ammo762WP extends VietnamAmmo;

defaultproperties
{
     MaxAmmo=500
     AmmoAmount=0
     PickupType="PickupAmmo762WP"
     ItemName="7.62 WP Ammo"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
