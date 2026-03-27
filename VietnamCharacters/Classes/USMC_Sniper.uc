class USMC_Sniper extends Marine;

//#exec obj load file="..\animations\ModelHuman_Marine_Thin_Two.ukx" package=ModelHuman_Marine_Thin_Two
//#exec obj load file="..\Textures\Marine_Thin_Tex.utx" package=Marine_Thin_Tex

simulated function PostBeginPlay()
{
	//SetDelegateTimer('SetPoseBlink',2.5f,true); // No Blinking on Sniper.
	Super.PostBeginPlay();
}

function Spawned()
{
	Skins[1]=Texture(DynamicLoadObject("Marine_Thin_Tex.marine_thin_tex",class'Texture'));		
	Super.Spawned();
}

defaultproperties
{
     Head=Class'VietnamGame.USMC_BoonieHat'
     Back=None
     LeftBackBelt=Class'VietnamGame.USMC_Canteen_LeftBack'
     RightBackBelt=None
     BackBelt=Class'VietnamGame.USMC_ButtPack'
     Begin Object Class=AIFriendlyParams Name=AIFriendlyParams24
         Name="AIFriendlyParams24"
     End Object
     AI=AIFriendlyParams'VietnamCharacters.AIFriendlyParams24'
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
     AssetName="ModelHuman_Marine_Thin_Two.Marine_Thin_Two"
}
