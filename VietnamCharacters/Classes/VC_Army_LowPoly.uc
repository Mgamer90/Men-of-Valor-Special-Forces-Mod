class VC_Army_LowPoly extends VC_Army;

//#exec obj load file=..\animations\ModelHuman_Enemy_Basic_lowpoly.ukx package=ModelHuman_Enemy_Basic_lowpoly

defaultproperties
{
     Begin Object Class=AI_VC_Army_Params Name=AI_VC_Army_Params1
         Name="AI_VC_Army_Params1"
     End Object
     AI=AI_VC_Army_Params'VietnamCharacters.AI_VC_Army_Params1'
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
     AssetName="ModelHuman_Enemy_Basic_lowpoly.Enemy_Basic_lowpoly"
}
