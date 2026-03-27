class USMC_Medic extends Marine;

//#exec obj load file="..\animations\ModelHuman_Marine_Average.ukx" package=ModelHuman_Marine_Average

var UseSquadMateTrigger m_useTrigger;

var () bool m_bUseableByPlayer;

//-----------------------------------------------------
//
simulated function PostBeginPlay()
//
//-----------------------------------------------------
{
	SetDelegateTimer('SetPoseBlink',2.5f,true);
	Super.PostBeginPlay();

	if ( m_bUseableByPlayer == true )
	{
		m_useTrigger = spawn( class'UseSquadMateTrigger', self );
		m_useTrigger.SetBase( self );
		m_useTrigger.SetRelativeLocation( vect(0,0,0) );
		m_useTrigger.bRestrictPlayerFacing = true;
		m_useTrigger.ActorToFaceTag = tag;
		m_useTrigger.ActorToFace = self;
		m_useTrigger.strMessage = "Use medic";
		log( "USMC_Medic::PostBeginPlay() m_useTrigger=" $m_useTrigger );
	}
	else
	{
		log( "USMC_Medic::PostBeginPlay() m_bUseableByPlayer=" $m_bUseableByPlayer );
	}
}


//-----------------------------------------------------
//
function Trigger( actor Other, pawn EventInstigator )
//
//-----------------------------------------------------
{
	local VietnamPlayerController pVPC;
	
	pVPC = VietnamPlayerController( EventInstigator.Controller );
	log( "Medic used by " $pVPC );

	if ( pVPC.Pawn.Health < 100 )
	{
		VietnamMedicBot(Controller).MedicCheckPatient( VietnamPawn( pVPC.Pawn ) );
	}
}

//---------------------------------------------------------------------------------------------------------
//

defaultproperties
{
     Head=Class'VietnamGame.USMC_MedicHelmet'
     Back=None
     LeftFrontBelt=Class'VietnamGame.USMC_MedicMedPack'
     RightFrontBelt=Class'VietnamGame.USMC_MedicFirstAid'
     RightBackBelt=None
     BackBelt=None
     m_mySquadRole=eSquadRoleMedic
     Begin Object Class=AIFriendlyParams Name=AIFriendlyParams22
         Name="AIFriendlyParams22"
     End Object
     AI=AIFriendlyParams'VietnamCharacters.AIFriendlyParams22'
     ControllerClass=Class'VietnamGame.VietnamMedicBot'
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
