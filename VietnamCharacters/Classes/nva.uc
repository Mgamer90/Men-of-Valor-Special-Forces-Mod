class NVA extends VietnamPawn dependson(AI_NVA_Params);

//#exec OBJ LOAD FILE=..\textures\NVA_skins_tex.utx PACKAGE=NVA_skins_tex
//#exec obj load file="..\animations\ModelHuman_Enemy_Basic.ukx" package=ModelHuman_Enemy_Basic

defaultproperties
{
     Head=Class'VietnamGame.VC_PithHelmet'
     Back=Class'VietnamGame.VC_BackPack_a'
     LeftFrontBelt=Class'VietnamGame.VC_Knife'
     LeftBackBelt=Class'VietnamGame.VC_FirstAid_LeftBack'
     RightFrontBelt=Class'VietnamGame.VC_Grenades'
     RightBackBelt=Class'VietnamGame.VC_RpdAmmo'
     Begin Object Class=AI_NVA_Params Name=AI_NVA_Params0
         Name="AI_NVA_Params0"
     End Object
     AI=AI_NVA_Params'VietnamCharacters.AI_NVA_Params0'
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
     AssetName="ModelHuman_NVA_Basic.NVA_Basic"
}
