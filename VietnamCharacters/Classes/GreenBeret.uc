class GreenBeret extends Marine;

//#exec obj load file="..\animations\ModelHuman_Green_Beret.ukx" package=ModelHuman_Green_Beret

defaultproperties
{
     Head=None
     Back=None
     LeftBackBelt=Class'VietnamGame.USMC_Canteen_LeftBack'
     BackBelt=None
     Chest=Class'VietnamGame.USMC_V40_Grenades'
     Begin Object Class=AIFriendlyParams Name=AIFriendlyParams21
         Name="AIFriendlyParams21"
     End Object
     AI=AIFriendlyParams'VietnamCharacters.AIFriendlyParams21'
     MenuName="Green_Beret"
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
     AssetName="ModelHuman_Green_Beret.Green_Beret"
}
