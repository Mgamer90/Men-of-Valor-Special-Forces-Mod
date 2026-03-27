class VietnamFriendlyTeamInfo extends VietnamTeamInfo;

//#exec TEXTURE IMPORT NAME=I_TeamR FILE=..\TEXTURES\placeholder.PCX GROUP="Icons" MIPS=OFF MASKED=1

function Spawned()
{
	//TeamIcon=Texture(DynamicLoadObject("VietnamCharacters.I_TeamR",class'Texture'));		
	Super.Spawned();
}

defaultproperties
{
     AllowedTeamMembers(0)="VietnamCharacters.Marine"
     AllowedTeamMembers(1)="VietnamCharacters.PlayerCharacter"
     AllowedTeamMembers(2)="VietnamCharacters.Pilot"
     AllowedTeamMembers(3)="VietnamCharacters.Reporter"
     AllowedTeamMembers(4)="VietnamCharacters.CameraMan"
     AllowedTeamMembers(5)="VietnamCharacters.USMC_Machinegunner"
     AllowedTeamMembers(6)="VietnamCharacters.USMC_Sniper"
     AllowedTeamMembers(7)="VietnamCharacters.USMC_Officer"
     AllowedTeamMembers(8)="VietnamCharacters.ARVN"
     AllowedTeamMembers(9)="VietnamCharacters.USMC_Medic"
     AllowedTeamMembers(10)="VietnamCharacters.USMC_RadioMan"
     AllowedTeamMembers(11)="VietnamCharacters.Marine_Black"
     AllowedTeamMembers(12)="VietnamCharacters.Marine_Black_Alt"
     AllowedTeamMembers(13)="VietnamCharacters.Marine_InUnderwear"
     AllowedTeamMembers(14)="VietnamCharacters.GreenBeret"
     AllowedTeamMembers(15)="VietnamCharacters.USMC_HodgesRadioMan"
     AllowedTeamMembers(16)="VietnamCharacters.USMC_SturgesRadioMan"
     AllowedTeamMembers(17)="VietnamCharacters.USMC_ZookRadioMan"
     AllowedTeamMembers(18)="VietnamCharacters.USMC_Marine_Lowpoly"
     AllowedTeamMembers(19)="VietnamCharacters.USMC_Harlan"
     AllowedTeamMembers(20)="VietnamCharacters.Spooky"
     AllowedTeamMembers(21)="VietnamCharacters.BoomBoomGirl"
     AllowedTeamMembers(22)="VietnamMPCharacters.MP_ARVNRanger"
     AllowedTeamMembers(23)="VietnamMPCharacters.MP_GreenBeret"
     AllowedTeamMembers(24)="VietnamMPCharacters.MP_MarineCorpsman"
     AllowedTeamMembers(25)="VietnamMPCharacters.MP_MarineMachinegunner"
     AllowedTeamMembers(26)="VietnamMPCharacters.MP_MarineRifleman"
     AllowedTeamMembers(27)="VietnamMPCharacters.MP_MarineSniper"
     AllowedTeamMembers(28)="VietnamMPCharacters.MP_TunnelRat"
     HudTeamColor=(G=64,R=64)
     TeamName="USA"
     TeamColor=(B=255,R=0)
     AltTeamColor=(B=200,R=0)
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
