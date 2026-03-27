class Neutral_Villager_a extends VietnamPawn dependson(AI_Neutral_Villager_Params);

defaultproperties
{
     Begin Object Class=AI_Neutral_Villager_Params Name=AI_Neutral_Villager_Params2
         Name="AI_Neutral_Villager_Params2"
     End Object
     AI=AI_Neutral_Villager_Params'VietnamCharacters.AI_Neutral_Villager_Params2'
     MyNationality=N_VIETNAMESE
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
     AssetName="ModelHuman_Villager_one.Villager_one"
}
