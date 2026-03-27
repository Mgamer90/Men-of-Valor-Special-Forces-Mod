class VC_Machinegunner extends VC_Army dependson(AI_VC_MachineGunner_Params);

//#exec obj load file="..\animations\ModelHuman_Enemy_Basic.ukx" package=ModelHuman_Enemy_Basic

defaultproperties
{
     UniformName="skins_tex.vc_machinegunner_tex"
     Back=Class'VietnamGame.VC_BackPack_a'
     LeftFrontBelt=Class'VietnamGame.VC_Knife'
     LeftBackBelt=Class'VietnamGame.VC_FirstAid_LeftBack'
     RightFrontBelt=Class'VietnamGame.VC_Grenades'
     RightBackBelt=Class'VietnamGame.VC_RpdAmmo'
     Begin Object Class=AI_VC_MachineGunner_Params Name=AI_VC_MachineGunner_Params0
         Name="AI_VC_MachineGunner_Params0"
     End Object
     AI=AI_VC_MachineGunner_Params'VietnamCharacters.AI_VC_MachineGunner_Params0'
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
