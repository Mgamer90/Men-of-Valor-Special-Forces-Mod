class USMC_Marine_Medic extends USMC_Medic;

var Pawn thePlayerPawn;

//#exec obj load file="..\animations\ModelHuman_Marine_Average.ukx" package=ModelHuman_Marine_Average

simulated function PostBeginPlay()
{
	local Controller C;
	local VietnamBot NamBot;
	local PickupAmmo NamPAmmo;
	local PickupHealth NamPHealth;

	SetDelegateTimer('SetPoseBlink',2.5f,true);

	Super.PostBeginPlay();

	if ( m_bUseableByPlayer == true )
	{
		m_useTrigger = spawn( class'UseSquadMateTrigger', self );
		m_useTrigger.SetBase( self );
		m_useTrigger.SetRelativeLocation( vect(0,0,0) );
		m_useTrigger.bRestrictPlayerFacing = false;
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

	for (C=Level.ControllerList; C!=None; C=C.NextController)
	{
		if (/*C.bIsPlayer*/ C.Pawn.IsPlayerPawn())
		{
			thePlayerPawn = C.Pawn;
		}
	}

	/*if ( RequiredEquipment[0] == None )
	{
		RequiredEquipment[0]=Class'VietnamWeapons.WeaponM1';
		AddDefaultInventory();
	}*/

	RequiredEquipment[0]=Class'VietnamWeapons.WeaponM1';
	AddDefaultInventory();
	
	if ( thePlayerPawn != None )
	{
		if ( thePlayerPawn.Health < 25  )
		{
			NamPHealth = Spawn(class'MedicKit',Self,'',GetBoneCoords('bip_LFoot').origin);
		}

		if ( thePlayerPawn.Weapon.IsA('WeaponM1') )
		{
			NamPAmmo = Spawn(class'PickupAmmo45Cal',Self,'',GetBoneCoords('bip_LFoot').origin);
		}
		else if ( thePlayerPawn.Weapon.IsA('WeaponM21') )
		{
			NamPAmmo = Spawn(class'PickupAmmoM21',Self,'',GetBoneCoords('bip_LFoot').origin);
		}
		else if ( thePlayerPawn.Weapon.IsA('WeaponM14') )
		{
			NamPAmmo = Spawn(class'PickupAmmo762NATO',Self,'',GetBoneCoords('bip_LFoot').origin);
		}
		else
		{
			NamPAmmo = Spawn(class'PickupAmmo556NATO',Self,'',GetBoneCoords('bip_LFoot').origin);
		}
	}

	if ( NamPAmmo != None )
	{
		NamPAmmo.AmmoAmount=100;
	}

	NamBot = VietnamBot(Controller);

	// if ( NamBot.AIParams != None && (Level.Game != None && Level.Game.Difficulty >= 3) )
	if ( NamBot.AIParams != None )
	{
		NamBot.AIParams.m_fAccuracyMultiplier = class'ModRepositoryConfig'.default.m_fAccuracyMultiplier; // Modifies BaseAccuracy
		NamBot.AIParams.MinAccuracyMultiplier = class'ModRepositoryConfig'.default.MinAccuracyMultiplier; // set this higher to force inaccuracy regardless of aimtime
		NamBot.AIParams.m_fDamageScale = class'ModRepositoryConfig'.default.m_fDamageScale;
		NamBot.AIParams.bGrenadeAware = class'ModRepositoryConfig'.default.bGrenadeAware;
	}
}

/*simulated event Tick( float DeltaTime )
{
	if ( thePlayerPawn != None && thePlayerPawn.Health < 50 )
	{
		VietnamMedicBot(Controller).MedicCheckPatient( VietnamPawn( thePlayerPawn ) );
	}

	Super.Tick(DeltaTime);
}*/

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
	local VietnamAmmo NamAmmo;
	local VietnamWeapon NamWeapon;
	
	pVPC = VietnamPlayerController( EventInstigator.Controller );
	log( "Medic used by " $pVPC );

	if ( pVPC.Pawn.Health < 100 )
	{
		VietnamMedicBot(Controller).MedicCheckPatient( VietnamPawn( pVPC.Pawn ) );

		//just do it
		if (EventInstigator.Health < 100)
		{
			EventInstigator.Health = 100;
		}

		//Level.Game.Broadcast(Self, "Medic used by "$EventInstigator.GetHumanReadableName(), 'Say');
	}
	else
	{
		NamWeapon = VietnamWeapon(EventInstigator.Weapon);

		if( NamWeapon != None )
		{
			NamAmmo = VietnamAmmo(NamWeapon.AmmoType);

			if( NamAmmo != None)
			{
				VietnamMedicBot(Controller).MedicCheckPatient( VietnamPawn( pVPC.Pawn ) );
				//USMC_Marine_Medic_Bot(Controller).RefillPawnAmmo( VietnamPawn( pVPC.Pawn ));

				if (NamAmmo.AmmoAmount < NamAmmo.MaxAmmo)
				{
					NamAmmo.AmmoAmount = NamAmmo.MaxAmmo;
				}

				//Level.Game.Broadcast(Self, "Refill Ammo used by "$EventInstigator.GetHumanReadableName(), 'Say');
			}
		}
	}
}

//---------------------------------------------------------------------------------------------------------
//

defaultproperties
{
	Mesh=SkeletalMesh'ModelHuman_army_average.army_average'

     RequiredEquipment[0]=Class'VietnamWeapons.WeaponM1';
     m_bUseableByPlayer = true

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
     ControllerClass=Class'UMovSpecialForcesMod.USMC_Marine_Medic_Bot'
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
