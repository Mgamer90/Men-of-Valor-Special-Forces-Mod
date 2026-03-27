class USMC_Officer extends Marine;

//#exec obj load file="..\animations\ModelHuman_Marine_Average.ukx" package=ModelHuman_Marine_Average

simulated function PostBeginPlay()
{
	SetDelegateTimer('SetPoseBlink',2.5f,true);
	Super.PostBeginPlay();
}

defaultproperties
{
     Head=Class'VietnamGame.USMC_Helmet_Cigs'
     HeadAlt=Class'VietnamGame.USMC_Glasses'
     LeftFrontBelt=None
     LeftBackBelt=Class'VietnamGame.USMC_Canteen_LeftBack'
     RightFrontBelt=Class'VietnamGame.USMC_45Holster'
     BackBelt=None
     Begin Object Class=AIFriendlyParams Name=AIFriendlyParams23
         Name="AIFriendlyParams23"
     End Object
     AI=AIFriendlyParams'VietnamCharacters.AIFriendlyParams23'
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
}
