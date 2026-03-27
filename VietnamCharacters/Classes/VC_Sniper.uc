class VC_Sniper extends VC_Army dependson(AI_Enemy_Sniper_Params);

//#exec obj load file="..\animations\ModelHuman_Enemy_Basic.ukx" package=ModelHuman_Enemy_Basic

static function StaticPrecacheAssets(optional Object MyLevel)
{
	local class cl;
	Super.StaticPrecacheAssets(MyLevel);

	cl = class'VC_SniperHat';
	cl.static.StaticPrecacheAssets();	
}

defaultproperties
{
     UniformName="skins_tex.vc_sniper_tex"
     Head=Class'VietnamGame.VC_SniperHat'
     Back=Class'VietnamGame.VC_SniperPack'
     LeftFrontBelt=None
     LeftBackBelt=Class'VietnamGame.VC_FirstAid_LeftBack'
     RightFrontBelt=Class'VietnamGame.VC_Grenades'
     Begin Object Class=AI_Enemy_Sniper_Params Name=AI_Enemy_Sniper_Params0
         Name="AI_Enemy_Sniper_Params0"
     End Object
     AI=AI_Enemy_Sniper_Params'VietnamCharacters.AI_Enemy_Sniper_Params0'
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
