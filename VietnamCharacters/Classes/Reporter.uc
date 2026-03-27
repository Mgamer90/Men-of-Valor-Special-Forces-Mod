class Reporter extends Marine;

//#exec OBJ LOAD FILE=..\animations\ModelHuman_Marine_Thin_Reporter.ukx PACKAGE=ModelHuman_Marine_Thin_Reporter

defaultproperties
{
     Head=None
     Back=None
     LeftFrontBelt=None
     RightFrontBelt=None
     RightBackBelt=None
     BackBelt=None
     Begin Object Class=AIFriendlyParams Name=AIFriendlyParams13
         Name="AIFriendlyParams13"
     End Object
     AI=AIFriendlyParams'VietnamCharacters.AIFriendlyParams13'
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
     AssetName="ModelHuman_Marine_Thin_Reporter.Marine_Thin_Reporter"
}
