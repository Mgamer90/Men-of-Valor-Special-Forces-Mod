class USMC_Marine_Support extends Marine;

//#exec obj load file="../animations/ModelHuman_Marine_large.ukx" package=ModelHuman_Marine_large

//=============================== *UMODGAME* New Vars ===============================
var UseSquadMateTrigger m_useTrigger;

var bool m_bUseableByPlayer;

var Pawn thePlayerPawn;
//=============================== *UMODGAME* End ===============================

function Weapon GiveWeapon( String aClassName )
{
	local class<Weapon> WeaponClass;

	WeaponClass = class<Weapon>(DynamicLoadObject(aClassName, class'Class'));

	return GiveWeaponByClass(WeaponClass);
}

/*
function SpawnedInEditor()
{
	if ((!Skins.Length || !Skins[1]) && UniformName?)
	{
		Skins[1] = Texture(DynamicLoadObject(UniformName, class'Texture'));
	}

	Super.SpawnedInEditor();
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
	local class cl;
	Super.StaticPrecacheAssets(MyLevel);

	if(default.UniformName?)
		DynamicLoadObject(default.UniformName,class'Material');

	cl = class'VC_SniperHat';
	cl.static.StaticPrecacheAssets();	
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
}

Advancing;
Assaulting;
Attacking;
AlertedGrenades;
CheckingCorpse;
DyingSpeech;
InjuredMinor;
InjuredMajor;
Killed;
OrderingVillagers;
Pain;
PostKill;
Retreating;
Suppressed;
TrapSpotted;
TrapTriggered;
Alerted;
AlertedMortars;
AlertedRockets;
AlertedSpiderHole;
CeaseFire;
ConsolingDying;
ConsolingInjured;
CoveringFire;
Emotional_SquadMateDeath;
EnemySpottedFront;
EnemySpottedLeft;
EnemySpottedRight;
EnemySpottedBack;
Investigating;
Laughing;
Orders_Accepted;
Orders_Rejected;
PissedAtPlayer;
PlayerLost;
StayingAtCover;
PostBattlePissed;
PostBattleSuccess;
PostBattleTired;
PostFireMission;
PreBattleBored;
PreBattleNervous;
TakeCover;

*/

//=============================== *UMODGAME* Begin ===============================
//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	Super.PreBeginPlay();
	
	ControllerClass = class<AIController>(DynamicLoadObject(class'ModRepositoryConfig'.default.m_ControllerClassName,class'class'));
}

simulated function PostBeginPlay()
{
	local Controller C;
	local VietnamBot NamBot;
	local VietnamAmmo NamAmmo;
	local VietnamWeapon NamWeapon;
	local VietnamWeaponPickup NamWeaponPickup;
	local class<VietnamWeaponPickup> NamWeaponPickupClass;
	local VietnamWeaponPickup NamWeaponPickupBkp;
	local class<VietnamWeaponPickup> NamWeaponPickupBkpClass;
	local VietnamWeaponPickup NamWeaponPickupNade;
	local class<VietnamWeaponPickup> NamWeaponPickupNadeClass;

	SetDelegateTimer('SetPoseBlink',2.5f,true);
	Super.PostBeginPlay();

	m_bUseableByPlayer = true;

	if ( /*(m_bDemiGodMode == true || bGodMode == true) &&*/ m_bUseableByPlayer == true )
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
		for (C=Level.ControllerList; C!=None; C=C.NextController)
		{
			if (/*C.bIsPlayer*/ C.Pawn.IsPlayerPawn())
			{
				thePlayerPawn = C.Pawn;
			}
			else
			{
				NamBot = VietnamBot(C);

				if ( NamBot != None && NamBot.Pawn.IsA('Marine') && NamBot.AIParams != None )
				{
					NamBot.AIParams.m_fAccuracyMultiplier = class'ModRepositoryConfig'.default.m_fAccuracyMultiplier; // Modifies BaseAccuracy
					NamBot.AIParams.MinAccuracyMultiplier = class'ModRepositoryConfig'.default.MinAccuracyMultiplier; // set this higher to force inaccuracy regardless of aimtime
					NamBot.AIParams.m_fDamageScale = class'ModRepositoryConfig'.default.m_fDamageScale;
					NamBot.AIParams.bGrenadeAware = class'ModRepositoryConfig'.default.bGrenadeAware;
				}
			}
		}

		//------------------------------------------------------------------------------------------

		if( thePlayerPawn != None && thePlayerPawn.Weapon != None )
		{
			//if( thePlayerPawn.Weapon.IsA('WeaponM60') || thePlayerPawn.Weapon.IsA('WeaponM1') || thePlayerPawn.Weapon.IsA('WeaponCAR15') || thePlayerPawn.Weapon.IsA('WeaponM16') )

			if( !thePlayerPawn.Weapon.IsA('WeaponM21') )
			{
				NamWeaponPickupClass = class<VietnamWeaponPickup>(DynamicLoadObject("VietnamWeapons.PickupM21", class'Class'));
			}
			else if( thePlayerPawn.Weapon.IsA('WeaponM21') )
			{
				NamWeaponPickupClass = class<VietnamWeaponPickup>(DynamicLoadObject("VietnamWeapons.PickupM60", class'Class'));
			}
			else
			{
				NamWeaponPickupClass = class<VietnamWeaponPickup>(DynamicLoadObject("VietnamWeapons.PickupM1", class'Class'));
			}
		}
		else
		{
			NamWeaponPickupClass = class<VietnamWeaponPickup>(DynamicLoadObject("UMovSpecialForcesMod.PickupM16E1", class'Class'));
		}

		//NamWeaponPickupClass = class<VietnamWeaponPickup>(DynamicLoadObject("UMovSpecialForcesMod.PickupCAR15Scope", class'Class'));

		NamWeaponPickup = Spawn(NamWeaponPickupClass,Self,'',GetBoneCoords('bip_LFoot').origin);

		//NamWeaponPickupBkpClass = class<VietnamWeaponPickup>(DynamicLoadObject("VietnamWeapons.PickupM1911S", class'Class'));
		//NamWeaponPickupBkpClass = class<VietnamWeaponPickup>(DynamicLoadObject("UMovSpecialForcesMod.PickupM1911Silenced", class'Class'));

		//NamWeaponPickupBkp = Spawn(NamWeaponPickupBkpClass,Self,'',GetBoneCoords('bip_LFoot').origin);

		//NamWeaponPickupNadeClass = class<VietnamWeaponPickup>(DynamicLoadObject("VietnamWeapons.PickupClaymore", class'Class'));

		//NamWeaponPickupNade = Spawn(NamWeaponPickupNadeClass,Self,'',GetBoneCoords('bip_LFoot').origin);

		//------------------------------------------------------------------------------------------

		NamWeapon = VietnamWeapon(Weapon);

		if( NamWeapon != None )
		{
			NamAmmo = VietnamAmmo(NamWeapon.AmmoType);

			if( NamAmmo != None )
			{
				NamAmmo.AmmoAmount = NamAmmo.MaxAmmo;
			}
		}

	}

	NamBot = VietnamBot(Controller);

	if ( NamBot != None && NamBot.AIParams != None )
	{
		NamBot.AIParams.m_fAccuracyMultiplier = class'ModRepositoryConfig'.default.m_fAccuracyMultiplier; // Modifies BaseAccuracy
		NamBot.AIParams.MinAccuracyMultiplier = class'ModRepositoryConfig'.default.MinAccuracyMultiplier; // set this higher to force inaccuracy regardless of aimtime
		NamBot.AIParams.m_fDamageScale = class'ModRepositoryConfig'.default.m_fDamageScale;
		NamBot.AIParams.bGrenadeAware = class'ModRepositoryConfig'.default.bGrenadeAware;

		NamBot.AIParams.Hearing = class'ModRepositoryConfig'.default.Hearing;
		NamBot.AIParams.Fov = class'ModRepositoryConfig'.default.Fov;
		NamBot.AIParams.Sight = class'ModRepositoryConfig'.default.Sight;
		NamBot.AIParams.MinEnemyDistance = class'ModRepositoryConfig'.default.MinEnemyDistance;
		NamBot.AIParams.MaxEnemyDistance = class'ModRepositoryConfig'.default.MaxEnemyDistance;
	}
}

simulated event Touch( Actor Other )
{
	local pawn EventInstigator;
	local VietnamAmmo NamAmmo;
	local VietnamWeapon NamWeapon;
	
	EventInstigator = pawn( Other );

	if ( EventInstigator != None && !EventInstigator.IsPlayerPawn() )
	{
		if ( EventInstigator.Health < 50 )
		{
			//VietnamMedicBot(Controller).MedicCheckPatient( VietnamPawn( EventInstigator ) );
			EventInstigator.Health = 100;
			Level.Game.Broadcast(Self, "Medic used by "$EventInstigator.GetHumanReadableName(), 'Say');
		}
		else
		{
			NamWeapon = VietnamWeapon(EventInstigator.Weapon);

			if( NamWeapon != None )
			{
				NamAmmo = VietnamAmmo(NamWeapon.AmmoType);

				if( NamAmmo != None)
				{
					NamAmmo.AmmoAmount = NamAmmo.MaxAmmo;
					Level.Game.Broadcast(Self, "Refill Ammo used by "$EventInstigator.GetHumanReadableName(), 'Say');
					//NamAmmo.Damage = 2*NamAmmo.Damage;
				}
			}
		}
	}

	Super.Touch( Other );
}

event Bump( Actor Other )
{
	local pawn EventInstigator;
	local VietnamAmmo NamAmmo;
	local VietnamWeapon NamWeapon;
	
	EventInstigator = pawn( Other );

	if ( EventInstigator != None && !EventInstigator.IsPlayerPawn() )
	{
		if ( EventInstigator.Health < 50 )
		{
			//VietnamMedicBot(Controller).MedicCheckPatient( VietnamPawn( EventInstigator ) );
			EventInstigator.Health = 100;
			Level.Game.Broadcast(Self, "Medic used by "$EventInstigator.GetHumanReadableName(), 'Say');
		}
		else
		{
			NamWeapon = VietnamWeapon(EventInstigator.Weapon);

			if( NamWeapon != None )
			{
				NamAmmo = VietnamAmmo(NamWeapon.AmmoType);

				if( NamAmmo != None && NamAmmo.AmmoAmount < 30)
				{
					NamAmmo.AmmoAmount = NamAmmo.MaxAmmo;
					Level.Game.Broadcast(Self, "Refill Ammo used by "$EventInstigator.GetHumanReadableName(), 'Say');
					//NamAmmo.Damage = 2*NamAmmo.Damage;
				}
			}
		}
	}

	Super.Bump( Other );
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
     Back=None
     LeftFrontBelt=Class'VietnamGame.USMC_BarAmmo_LeftFront'
     LeftBackBelt=Class'VietnamGame.USMC_Canteen_LeftBack'
     RightFrontBelt=None
     RightBackBelt=None
     //Begin Object Class=AIFriendlyParams Name=AIFriendlyParams19
     //    Name="AIFriendlyParams19"
     //End Object
     //AI=AIFriendlyParams'VietnamCharacters.AIFriendlyParams19'
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
     AssetName="ModelHuman_Marine_large.Marine_large"
}
