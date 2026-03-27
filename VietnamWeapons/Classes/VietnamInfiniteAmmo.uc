class VietnamInfiniteAmmo extends VietnamAmmo;

simulated function bool HasAmmo()
{
	return true;
}

defaultproperties
{
     MaxAmmo=1000
     AmmoAmount=1000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
