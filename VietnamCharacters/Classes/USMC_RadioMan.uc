class USMC_RadioMan extends Marine;

//#exec obj load file="..\animations\ModelHuman_Marine_Average.ukx" package=ModelHuman_Marine_Average

var UseSquadMateTrigger m_useTrigger;

var()	array<ResourceReference>	RadioManDialogPreCacheArray;
var		array<Sound>				RadioManDialog;
var		MeshAnimation				RadioManAnimations;

event PreCacheAssets()
{
	LoadSounds( RadioManDialogPreCacheArray, RadioManDialog );
	Super.PreCacheAssets();
}

//-----------------------------------------------------
//
simulated function PostBeginPlay()
//
//-----------------------------------------------------
{
	local VietnamBot NamBot; //*UMODGAME*

	SetDelegateTimer('SetPoseBlink',2.5f,true);
	Super.PostBeginPlay();
/*
	m_useTrigger = spawn( class'UseSquadMateTrigger', self );
	m_useTrigger.SetBase( self );
	m_useTrigger.SetRelativeLocation( vect(0,0,0) );
	m_useTrigger.bRestrictPlayerFacing = true;
	m_useTrigger.ActorToFaceTag = tag;
	m_useTrigger.ActorToFace = self;
	m_useTrigger.strMessage = "Use radio operator";
	*/
	class'RadioManAnimationSet'.static.LinkSetAnims( Self );

//=============================== *UMODGAME* Begin ===============================

	GroundSpeed[0] *= class'ModRepositoryConfig'.default.m_GroundSpeedMultiplier;
	GroundSpeed[1] *= class'ModRepositoryConfig'.default.m_GroundSpeedMultiplier;
	GroundSpeed[2] *= class'ModRepositoryConfig'.default.m_GroundSpeedMultiplier;
	GroundSpeed[3] *= class'ModRepositoryConfig'.default.m_GroundSpeedMultiplier;


	// if ( Level.Game != None && Level.Game.Difficulty >= class'ModRepositoryConfig'.default.m_GameDifficulty )
	if ( class'ModRepositoryConfig'.default.m_OverrideAIParams == true )
	{
		NamBot = VietnamBot(Controller);

		if ( NamBot != None && NamBot.AIParams != None )
		{
			NamBot.AIParams.m_fAccuracyMultiplier = class'ModRepositoryConfig'.default.m_fAccuracyMultiplier; // Modifies BaseAccuracy
			NamBot.AIParams.MinAccuracyMultiplier = class'ModRepositoryConfig'.default.MinAccuracyMultiplier; // set this higher to force inaccuracy regardless of aimtime
			NamBot.AIParams.m_fDamageScale = class'ModRepositoryConfig'.default.m_fDamageScale;
			NamBot.AIParams.bGrenadeAware = class'ModRepositoryConfig'.default.bGrenadeAware;
		}
	}
//=============================== *UMODGAME* End ===============================
}


//-----------------------------------------------------
//
function Trigger( actor Other, pawn EventInstigator )
//
//-----------------------------------------------------
{

	local VietnamPlayerController pVPC;
	
	pVPC = VietnamPlayerController( EventInstigator.Controller );
	log( "Radioman used by " $pVPC );

	VietnamMedicBot(Controller).MedicCheckPatient( VietnamPawn( pVPC.Pawn ) ); //*UMODGAME*

//	VietnamRadioManBot(Controller).UseRadioMan( VietnamPawn( pVPC.Pawn ) );
}

function NotifyRemoveRadioHandset()
{
	if( !Controller.IsA('VietnamRadioManBot')
	||	VietnamRadioManBot( Controller ).PendingCallStartMessage == None )
	{
		// we aren't using my radio man call code, ignore this notify.
		return;
	}
	if( m_AttachedChestEquipment == None )
	{
		Log( "YOU'VE SENT A START RADIO CALL MESSAGE TO THE RADIO OPERATOR BUT HE DOESN'T HAVE A HANDSET, Doh!" );
	}
	else if( m_AttachedChestEquipment.IsA( 'USMC_RadioHandset' ) )
	{
		m_AttachedChestEquipment.bHidden = true;
	}
	
	if( m_AttachedLeftHandEquipment != None )
	{
		Log( "YOU LEFT AN ATTACHMENT IN THE RADIO MAN'S LEFT HAND AND THEN SENT HIM A START RADIO CALL MESSAGE, Doh!" );
		m_AttachedLeftHandEquipment = None;
	}
	
	m_AttachedLeftHandEquipment = Spawn(class<Actor>(DynamicLoadObject( "VietnamGame.USMC_RadioHandset_LeftHand",class'class' )),Self);
}

function NotifyReplaceRadioHandset()
{
	if( !Controller.IsA('VietnamRadioManBot')
	||	VietnamRadioManBot( Controller ).PendingCallEndMessage == None )
	{
		// we aren't using my radio man call code, ignore this notify.
		Log( "BRENDAN - USMC_RadioMan::NotifyReplaceRadioHandset not in End Radio Call, ignoring" );
		return;
	}
	if( m_AttachedLeftHandEquipment == None )
	{
		Log( "BRENDAN - USMC_RadioMan::NotifyReplaceRadioHandset no handset in left hand" );
	}
	else if( m_AttachedLeftHandEquipment.IsA( 'USMC_RadioHandset_LeftHand' ) )
	{
		m_AttachedLeftHandEquipment.Destroy();
		m_AttachedLeftHandEquipment = None;
	}
	
	if( m_AttachedChestEquipment != None
	&&	m_AttachedChestEquipment.IsA( 'USMC_RadioHandset' )
	)
	{
		m_AttachedChestEquipment.bHidden = false;
	}
}

//---------------------------------------------------------------------------------------------------------
//

defaultproperties
{
     RadioManDialogPreCacheArray(0)=(PackageName="DialogOP3_snd",ResourceName="A_HOG_OP3_L1_14")
     Back=Class'VietnamGame.USMC_BackpackRadio'
     LeftFrontBelt=Class'VietnamGame.USMC_762Ammo'
     Chest=Class'VietnamGame.USMC_RadioHandset'
     m_mySquadRole=eSquadRoleRadioMan
     Begin Object Class=AIFriendlyParams Name=AIFriendlyParams15
         Name="AIFriendlyParams15"
     End Object
     AI=AIFriendlyParams'VietnamCharacters.AIFriendlyParams15'
     ControllerClass=Class'VietnamGame.VietnamRadioManBot'
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
