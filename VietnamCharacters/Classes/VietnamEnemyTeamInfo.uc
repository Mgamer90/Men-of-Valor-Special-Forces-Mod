class VietnamEnemyTeamInfo extends VietnamTeamInfo;

//#exec TEXTURE IMPORT NAME=I_TeamB FILE=..\TEXTURES\placeholder.PCX GROUP="Icons" MIPS=OFF MASKED=1


function Spawned()
{
	//TeamIcon=Texture(DynamicLoadObject("VietnamCharacters.I_TeamB",class'Texture'));		
	Super.Spawned();
}

defaultproperties
{
     AllowedTeamMembers(0)="VietnamCharacters.VC_Army"
     AllowedTeamMembers(1)="VietnamCharacters.VC_Sniper"
     AllowedTeamMembers(2)="VietnamCharacters.VC_MachineGunner"
     AllowedTeamMembers(3)="VietnamCharacters.nva"
     AllowedTeamMembers(4)="VietnamCharacters.VC_Army_LowPoly"
     AllowedTeamMembers(5)="VietnamCharacters.VC_Villager_a"
     AllowedTeamMembers(6)="VietnamCharacters.VC_Villager_b"
     AllowedTeamMembers(7)="VietnamCharacters.VC_Female"
     AllowedTeamMembers(8)="VietnamCharacters.VC_female"
     AllowedTeamMembers(9)="VietnamCharacters.NVA_MachineGunner"
     AllowedTeamMembers(10)="VietnamCharacters.NVA_Officer"
     AllowedTeamMembers(11)="VietnamMPCharacters.MP_NVAMachinegunner"
     AllowedTeamMembers(12)="VietnamMPCharacters.MP_NVAMedic"
     AllowedTeamMembers(13)="VietnamMPCharacters.MP_NVARifleman"
     AllowedTeamMembers(14)="VietnamMPCharacters.MP_NVASapper"
     AllowedTeamMembers(15)="VietnamMPCharacters.MP_VietCongForwardObserver"
     AllowedTeamMembers(16)="VietnamMPCharacters.MP_VietCongGuerrilla"
     AllowedTeamMembers(17)="VietnamMPCharacters.MP_VietCongSniper"
     HudTeamColor=(G=64,R=64)
     TeamName="NVA"
     TeamColor=(B=255,R=0)
     AltTeamColor=(B=200,R=0)
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
