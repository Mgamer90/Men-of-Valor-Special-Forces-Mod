class MainMenuPlayerCharacter extends PlayerCharacter;

function AddDefaultInventory()
{
	// no inventory
}

function AddDefaultAmmo()
{
	// no ammo
}

defaultproperties
{
     Begin Object Class=AIParams Name=AIParams40
         Name="AIParams40"
     End Object
     AI=AIParams'VietnamCharacters.AIParams40'
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     m_arrEventStates(2)="Idle"
     m_arrEventStates(3)="Curious"
     m_arrEventStates(4)="Attack"
     m_arrEventStates(5)="Combat"
     m_arrEventStates(6)="Suppressed"
     m_arrEventStates(7)="Pain"
     m_arrEventStates(8)="Killed"
     m_arrEventStates(9)="GotFootball"
     m_arrEventStates(10)="GotPreciseAimedFootball"
     m_arrEventStates(11)="Destroyed"
     AssetName=""
}
