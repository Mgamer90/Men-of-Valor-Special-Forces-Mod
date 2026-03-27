class CameraMan extends Marine;

//#exec OBJ LOAD FILE=..\textures\us_skins_tex.utx PACKAGE=us_skins_tex
//#exec obj load file="..\animations\ModelHuman_Marine_Fat_Cameraman.ukx" package=ModelHuman_Marine_Fat_Cameraman

simulated function PostBeginPlay()
{
	// fire off blinking for ai
	SetDelegateTimer('SetPoseBlink',2.5f,true);

	Super.PostBeginPlay();
}

defaultproperties
{
     Head=None
     Back=None
     LeftFrontBelt=None
     RightFrontBelt=None
     RightBackBelt=None
     BackBelt=None
     Begin Object Class=AIFriendlyParams Name=AIFriendlyParams5
         Name="AIFriendlyParams5"
     End Object
     AI=AIFriendlyParams'VietnamCharacters.AIFriendlyParams5'
     RequiredEquipment(0)=Class'VietnamWeapons.WeaponCamera'
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
     AssetName="ModelHuman_Marine_Fat_Cameraman.Marine_Fat_Cameraman"
}
