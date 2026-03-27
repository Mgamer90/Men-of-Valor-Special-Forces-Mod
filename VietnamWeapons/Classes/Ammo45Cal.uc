//=============================================================================
// Ammo45Cal
// base class of bullet ammunition used by assault rifles
// has information about clip sizes, and damage
//=============================================================================
class Ammo45Cal extends VietnamAmmo;

defaultproperties
{
     MaxAmmo=500
     AmmoAmount=0
     PickupType="PickupAmmo45Cal"
     ItemName=".45 Cal. Ammo"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
