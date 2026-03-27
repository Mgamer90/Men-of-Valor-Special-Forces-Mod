class VietnamNeutralTeamInfo extends VietnamTeamInfo;

//#exec TEXTURE IMPORT NAME=I_TeamB FILE=..\TEXTURES\placeholder.PCX GROUP="Icons" MIPS=OFF MASKED=1

function Spawned()
{
	//TeamIcon=Texture(DynamicLoadObject("VietnamCharacters.I_TeamB",class'Texture'));		
	Super.Spawned();
}

defaultproperties
{
     AllowedTeamMembers(0)="VietnamCharacters.Neutral_Female"
     AllowedTeamMembers(1)="VietnamCharacters.Neutral_Villager_a"
     AllowedTeamMembers(2)="VietnamCharacters.Neutral_Villager_b"
     AllowedTeamMembers(3)="VietnamCharacters.VC_Prisoner"
     HudTeamColor=(G=64,R=64)
     TeamName="Neutral"
     TeamColor=(B=255,R=0)
     AltTeamColor=(B=200,R=0)
     bIsNeutral=True
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
