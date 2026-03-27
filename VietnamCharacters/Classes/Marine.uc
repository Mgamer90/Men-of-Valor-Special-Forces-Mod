//----------------------------------
// Base class for all Marine actors
//----------------------------------

class Marine extends VietnamPawn;

//#exec obj load file="..\animations\ModelHuman_Marine_Average.ukx" package=ModelHuman_Marine_Average

function name GetWeaponBoneFor(Inventory I)
{
	return 'Bip_RHand';
}

defaultproperties
{
     Head=Class'VietnamGame.USMC_Helmet'
     Back=Class'VietnamGame.USMC_Backpack_a'
     LeftFrontBelt=Class'VietnamGame.USMC_M16Ammo_LeftFront'
     RightFrontBelt=Class'VietnamGame.USMC_M16Ammo_RightFront'
     RightBackBelt=Class'VietnamGame.USMC_Canteen_RightBack'
     BackBelt=Class'VietnamGame.USMC_FirstAid'
     Begin Object Class=AIFriendlyParams Name=AIFriendlyParams4
         Name="AIFriendlyParams4"
     End Object
     AI=AIFriendlyParams'VietnamCharacters.AIFriendlyParams4'
     MenuName="Marine"
     MyNationality=N_AMERICAN
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
     AssetName="ModelHuman_Marine_Average.Marine_Average"
}
