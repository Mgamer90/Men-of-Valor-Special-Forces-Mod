class Marine_InUnderwear extends Marine;

//#exec obj load file="..\animations\ModelHuman_Marine_Underwear.ukx" package=ModelHuman_Marine_Underwear

//=============================== *UMODGAME* New Vars ===============================
var UseSquadMateTrigger m_useTrigger;

var bool m_bUseableByPlayer;

var Pawn thePlayerPawn;
//=============================== *UMODGAME* End ===============================

simulated function PostBeginPlay()
{
//=============================== *UMODGAME* Begin ===============================
	local VietnamBot NamBot;
	local VietnamAmmo NamAmmo;
	local VietnamWeapon NamWeapon;

	// fire off blinking for ai
	SetDelegateTimer('SetPoseBlink',2.5f,true);

	Super.PostBeginPlay();

	m_bUseableByPlayer = true;

	if ( (m_bDemiGodMode == true || bGodMode == true) && m_bUseableByPlayer == true )
	{
		m_useTrigger = spawn( class'UseSquadMateTrigger', self );
		m_useTrigger.SetBase( self );
		m_useTrigger.SetRelativeLocation( vect(0,0,0) );
		m_useTrigger.bRestrictPlayerFacing = true;
		m_useTrigger.ActorToFaceTag = tag;
		m_useTrigger.ActorToFace = self;
		m_useTrigger.strMessage = "Request support";
		m_useTrigger.fFacingThreshold=0.100000;
		log( "USMC_Medic::PostBeginPlay() m_useTrigger=" $m_useTrigger );
	}
	else
	{
		log( "USMC_Medic::PostBeginPlay() m_bUseableByPlayer=" $m_bUseableByPlayer );
	}

	GroundSpeed[0] *= class'ModRepositoryConfig'.default.m_GroundSpeedMultiplier;
	GroundSpeed[1] *= class'ModRepositoryConfig'.default.m_GroundSpeedMultiplier;
	GroundSpeed[2] *= class'ModRepositoryConfig'.default.m_GroundSpeedMultiplier;
	GroundSpeed[3] *= class'ModRepositoryConfig'.default.m_GroundSpeedMultiplier;

	// if ( Level.Game != None && Level.Game.Difficulty >= class'ModRepositoryConfig'.default.m_GameDifficulty )
	if ( class'ModRepositoryConfig'.default.m_OverrideAIParams == true )
	{
		NamWeapon = VietnamWeapon(Weapon);

		if( NamWeapon != None )
		{
			NamAmmo = VietnamAmmo(NamWeapon.AmmoType);

			if( NamAmmo != None )
			{
				NamAmmo.AmmoAmount = NamAmmo.MaxAmmo;
			}
		}

		NamBot = VietnamBot(Controller);

		if ( NamBot != None && NamBot.AIParams != None )
		{
			NamBot.AIParams.m_fAccuracyMultiplier = class'ModRepositoryConfig'.default.m_fAccuracyMultiplier; // Modifies BaseAccuracy
			NamBot.AIParams.MinAccuracyMultiplier = class'ModRepositoryConfig'.default.MinAccuracyMultiplier; // set this higher to force inaccuracy regardless of aimtime
			NamBot.AIParams.m_fDamageScale = class'ModRepositoryConfig'.default.m_fDamageScale;
			NamBot.AIParams.bGrenadeAware = class'ModRepositoryConfig'.default.bGrenadeAware;
		}
	}
}

//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	Super.PreBeginPlay();
	
	ControllerClass = class<AIController>(DynamicLoadObject(class'ModRepositoryConfig'.default.m_ControllerClassName,class'class'));
}

function Trigger( actor Other, pawn EventInstigator )
{
	local VietnamPlayerController pVPC;

	pVPC = VietnamPlayerController( EventInstigator.Controller );
	log( "Medic used by " $pVPC );

	VietnamMedicBot(Controller).MedicCheckPatient( VietnamPawn( pVPC.Pawn ) );

	//Super.Trigger( Other, EventInstigator );
}

//=============================== *UMODGAME* End ===============================

defaultproperties
{
     Head=None
     Back=None
     LeftFrontBelt=None
     RightFrontBelt=None
     RightBackBelt=None
     BackBelt=None
     Begin Object Class=AIFriendlyParams Name=AIFriendlyParams11
         Name="AIFriendlyParams11"
     End Object
     AI=AIFriendlyParams'VietnamCharacters.AIFriendlyParams11'
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
     AssetName="ModelHuman_Marine_Underwear.Marine_Underwear"
}
