class Pilot extends Marine;

//#exec obj load file="..\animations\ModelHuman_Jumpsuit.ukx" package=ModelHuman_Jumpsuit

defaultproperties
{
     Head=None
     Back=None
     LeftFrontBelt=None
     RightFrontBelt=None
     RightBackBelt=None
     BackBelt=None
     Begin Object Class=AIFriendlyParams Name=AIFriendlyParams12
         Name="AIFriendlyParams12"
     End Object
     AI=AIFriendlyParams'VietnamCharacters.AIFriendlyParams12'
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
     AssetName="ModelHuman_Jumpsuit.Jumpsuit"
}
