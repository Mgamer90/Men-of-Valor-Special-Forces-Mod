class VC_Villager_a extends VC_Army dependson(AI_VC_Villager_Params);

//#exec obj load file="..\animations\ModelHuman_Villager_one.ukx" package=ModelHuman_Villager_one

defaultproperties
{
     UniformName=""
     Head=None
     LeftFrontBelt=None
     RightFrontBelt=None
     RightBackBelt=None
     Begin Object Class=AI_VC_Villager_Params Name=AI_VC_Villager_Params1
         Name="AI_VC_Villager_Params1"
     End Object
     AI=AI_VC_Villager_Params'VietnamCharacters.AI_VC_Villager_Params1'
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
