class USMC_Machinegunner_Medic extends USMC_Machinegunner;

//#exec obj load file="../animations/ModelHuman_Marine_large.ukx" package=ModelHuman_Marine_large

//=============================== *UMODGAME* New Vars ===============================
/*var UseSquadMateTrigger m_useTrigger;

var bool m_bUseableByPlayer;
//=============================== *UMODGAME* End ===============================

simulated function PostBeginPlay()
{
	SetDelegateTimer('SetPoseBlink',2.5f,true);
	Super.PostBeginPlay();

	//=============================== *UMODGAME* Begin ===============================
	m_bUseableByPlayer = true;

	if ( m_bUseableByPlayer == true )
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
	//=============================== *UMODGAME* End ===============================
}

//=============================== *UMODGAME* New Functions ===============================
function Trigger( actor Other, pawn EventInstigator )
{
	local VietnamPlayerController pVPC;

	pVPC = VietnamPlayerController( EventInstigator.Controller );
	log( "Medic used by " $pVPC );

	VietnamMedicBot(Controller).MedicCheckPatient( VietnamPawn( pVPC.Pawn ) );

	Super.Trigger( Other, EventInstigator );
}

//=============================== *UMODGAME* End ===============================

function SpawnedInEditor()
{
	if ((!Skins.Length || !Skins[1]) && UniformName?)
	{
		Skins[1] = Texture(DynamicLoadObject(UniformName, class'Texture'));
	}

	Super.SpawnedInEditor();
}

static function StaticPrecacheAssets(optional Object MyLevel)
{
	local class cl;
	Super.StaticPrecacheAssets(MyLevel);

	cl = class'VC_SniperHat';
	cl.static.StaticPrecacheAssets();	
}

function PostEditChange()
{
	if ((!Skins.Length || !Skins[1]) && UniformName?)
	{
		Skins[1] = Texture(DynamicLoadObject(UniformName, class'Texture'));
	}

	Super.PostEditChange();
}

simulated function PostBeginPlay()
{
	if ((!Skins.Length || !Skins[1]) && UniformName?)
	{
		Skins[1] = Texture(DynamicLoadObject(UniformName, class'Texture'));
	}
	
	Super.PostBeginPlay();
}

static function StaticPrecacheAssets(optional Object MyLevel)
{
	Super.StaticPrecacheAssets(MyLevel);

	if(default.UniformName?)
		DynamicLoadObject(default.UniformName,class'Material');
}

function PrecacheAssets()
{
	Super.PrecacheAssets();

	if(UniformName?)
		DynamicLoadObject(UniformName,class'Material');
}

function Spawned()
{
	Skins[1]=Texture(DynamicLoadObject("Marine_Thin_Tex.marine_thin_tex",class'Texture'));		
	Super.Spawned();
}*/

defaultproperties
{
     ControllerClass=Class'UMovSpecialForcesMod.USMC_Marine_Medic_Bot'
     m_bUseableByPlayer = true
     //RequiredEquipment[0]=Class'VietnamWeapons.WeaponM1';

	
	
	
	
	
	
	
	
	
	
	

     // Back=None
     // LeftFrontBelt=Class'VietnamGame.USMC_BarAmmo_LeftFront'
     // LeftBackBelt=Class'VietnamGame.USMC_Canteen_LeftBack'
     // RightFrontBelt=None
     // RightBackBelt=None
     // Begin Object Class=AIFriendlyParams Name=AIFriendlyParams19
         // Name="AIFriendlyParams19"
     // End Object
     // AI=AIFriendlyParams'VietnamCharacters.AIFriendlyParams19'
     // m_arrEventStates(0)="Activated"
     // m_arrEventStates(1)="DeActivated"
     // m_arrEventStates(2)="Idle"
     // m_arrEventStates(3)="Curious"
     // m_arrEventStates(4)="Attack"
     // m_arrEventStates(5)="Combat"
     // m_arrEventStates(6)="Suppressed"
     // m_arrEventStates(7)="Pain"
     // m_arrEventStates(8)="Killed"
     // m_arrEventStates(9)="GotFootball"
     // m_arrEventStates(10)="GotPreciseAimedFootball"
     // m_arrEventStates(11)="Destroyed"
     // AssetName="ModelHuman_Marine_large.Marine_large"
}
