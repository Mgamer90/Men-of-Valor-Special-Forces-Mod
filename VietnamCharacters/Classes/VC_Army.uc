class VC_Army extends VietnamPawn dependson(AI_VC_Army_Params);

//#exec OBJ LOAD FILE=..\animations\ModelHuman_Enemy_Basic.ukx PACKAGE=ModelHuman_Enemy_Basic

var string UniformName;

function SpawnedInEditor()
{
	if ((!Skins.Length || !Skins[1]) && UniformName?)
	{
		Skins[1] = Texture(DynamicLoadObject(UniformName, class'Texture'));
	}

	Super.SpawnedInEditor();
}

function PostEditChange()
{
	if ((!Skins.Length || !Skins[1]) && UniformName?)
	{
		Skins[1] = Texture(DynamicLoadObject(UniformName, class'Texture'));
	}

	Super.PostEditChange();
}

simulated function PostBeginPlay()
{
	if ((!Skins.Length || !Skins[1]) && UniformName?)
	{
		Skins[1] = Texture(DynamicLoadObject(UniformName, class'Texture'));
	}
	
	Super.PostBeginPlay();
}

static function StaticPrecacheAssets(optional Object MyLevel)
{
	Super.StaticPrecacheAssets(MyLevel);

	if(default.UniformName?)
		DynamicLoadObject(default.UniformName,class'Material');
}

function PrecacheAssets()
{
	Super.PrecacheAssets();

	if(UniformName?)
		DynamicLoadObject(UniformName,class'Material');
}

defaultproperties
{
     UniformName="skins_tex.vc_guerrilla_tex"
     Head=Class'VietnamGame.VC_StrawHat'
     LeftFrontBelt=Class'VietnamGame.VC_3Pack'
     RightFrontBelt=Class'VietnamGame.VC_SksAmmo_RightFront'
     RightBackBelt=Class'VietnamGame.VC_Canteen_RightBack'
     Begin Object Class=AI_VC_Army_Params Name=AI_VC_Army_Params0
         Name="AI_VC_Army_Params0"
     End Object
     AI=AI_VC_Army_Params'VietnamCharacters.AI_VC_Army_Params0'
     Health=150
     MyNationality=N_VIETNAMESE
     bActorShouldTravel=False
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
