class VC_Female extends VC_Army;

//#exec obj load file="..\animations\ModelHuman_Enemy_female.ukx"

defaultproperties
{
     UniformName=""
     Head=None
     LeftFrontBelt=None
     RightFrontBelt=None
     RightBackBelt=None
     Begin Object Class=AIEnemyParams Name=AIEnemyParams0
         Name="AIEnemyParams0"
     End Object
     AI=AIEnemyParams'VietnamCharacters.AIEnemyParams0'
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
     AssetName="ModelHuman_Enemy_female.Enemy_female"
}
