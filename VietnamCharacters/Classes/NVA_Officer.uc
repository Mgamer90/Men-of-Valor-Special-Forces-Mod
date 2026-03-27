class NVA_Officer extends NVA dependson(AI_NVA_Officer_Params);

defaultproperties
{
     Begin Object Class=AI_NVA_Officer_Params Name=AI_NVA_Officer_Params0
         Name="AI_NVA_Officer_Params0"
     End Object
     AI=AI_NVA_Officer_Params'VietnamCharacters.AI_NVA_Officer_Params0'
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
     AssetName="ModelHuman_Enemy_Basic.Enemy_Basic"
}
