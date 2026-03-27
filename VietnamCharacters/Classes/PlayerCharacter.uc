class PlayerCharacter extends Marine;

//#exec OBJ LOAD FILE=..\animations\ModelHuman_Marine_Average.ukx PACKAGE=ModelHuman_Marine_Average

var( ) String m_playerTwoModelName;

event PreBeginPlay()
{
	super.PreBeginPlay();
	
	if( Level.NetMode < NM_Client ) // only do this if we are a server or a standalone game
	{
		ChangeTag( Name( "Player" $ Level.PlayerNo ) );
		Level.PlayerNo++;
	}
}

simulated event PostBeginPlay()
{
//=============================== *UMODGAME* Begin ===============================
	local VietnamWeaponPickup NamWeaponPickup;
	local class<VietnamWeaponPickup> NamWeaponPickupClass;
	local VietnamWeaponPickup NamSniperRiflePickup;
	local class<VietnamWeaponPickup> NamSniperRiflePickupClass;
	local string NamSniperRifleName;
	local string NamNewWeaponName;
	//local PickupArmor NamArmorPickup;
	//local PickupArmor NamHelmetPickup;

	// added this here to ensure that if a player spawns in after all the human
	// players have died he becomes the leader.
	Level.UpdateLeader();

	Super.PostBeginPlay();

	if ( class'ModRepositoryConfig'.default.m_SpawnSniperRifleAtStart == true )
	{
		NamSniperRifleName = class'ModRepositoryConfig'.default.m_SniperRifleName;
		NamSniperRiflePickupClass = class<VietnamWeaponPickup>(DynamicLoadObject(NamSniperRifleName, class'Class'));

		NamSniperRiflePickup = Spawn(NamSniperRiflePickupClass,Self,'',GetBoneCoords('bip_LFoot').origin);
	}

	if ( class'ModRepositoryConfig'.default.m_SpawnNewWeaponAtStart == true )
	{
		NamNewWeaponName = class'ModRepositoryConfig'.default.m_NewWeaponName;
		NamWeaponPickupClass = class<VietnamWeaponPickup>(DynamicLoadObject(NamNewWeaponName, class'Class'));

		NamWeaponPickup = Spawn(NamWeaponPickupClass,Self,'',GetBoneCoords('bip_LFoot').origin);
	}

	//NamArmorPickup = Spawn(class'PickupFlakJacket',Self,'',GetBoneCoords('bip_LFoot').origin);
	//NamHelmetPickup = Spawn(class'PickupSteelHelmet',Self,'',GetBoneCoords('bip_LFoot').origin);

	//NamWeaponPickupBackupClass = class<VietnamWeaponPickup>(DynamicLoadObject("UMovSpecialForcesMod.PickupM16E1", class'Class'));
	//NamWeaponPickupBackup = Spawn(NamWeaponPickupBackupClass,Self,'',GetBoneCoords('bip_LFoot').origin);

	GroundSpeed[0] *= class'ModRepositoryConfig'.default.m_GroundSpeedMultiplier;
	GroundSpeed[1] *= class'ModRepositoryConfig'.default.m_GroundSpeedMultiplier;
	GroundSpeed[2] *= class'ModRepositoryConfig'.default.m_GroundSpeedMultiplier;
	GroundSpeed[3] *= class'ModRepositoryConfig'.default.m_GroundSpeedMultiplier;

	/*RequiredEquipment[0]=Class'VietnamWeapons.WeaponM21';
	RequiredEquipment[1]=Class'VietnamWeapons.WeaponCar15';
	RequiredEquipment[2]=Class'VietnamWeapons.WeaponM60';
	RequiredEquipment[3]=Class'VietnamWeapons.WeaponM79';
	RequiredEquipment[4]=Class'VietnamWeapons.WeaponPU';
	RequiredEquipment[5]=Class'VietnamWeapons.WeaponAK47';
	RequiredEquipment[6]=Class'VietnamWeapons.WeaponRPD';
	RequiredEquipment[7]=Class'VietnamWeapons.WeaponM1';
	RequiredEquipment[8]=Class'VietnamWeapons.WeaponM1911S';
	RequiredEquipment[9]=Class'VietnamWeapons.WeaponPPSH41';
	RequiredEquipment[10]=Class'VietnamWeapons.WeaponRPG7';
	RequiredEquipment[11]=Class'VietnamWeapons.WeaponSKS';
	RequiredEquipment[12]=Class'VietnamWeapons.WeaponM14';
	RequiredEquipment[13]=Class'VietnamWeapons.WeaponSmokeGrenade';
	RequiredEquipment[14]=Class'VietnamWeapons.WeaponM67';
	RequiredEquipment[15]=Class'VietnamWeapons.WeaponClaymore';
	//RequiredEquipment[15]=Class'VietnamWeapons.WeaponBoobyTrap';
	//RequiredEquipment[15]=Class'VietnamWeapons.PickupAmmo45Cal';
	//RequiredEquipment[15]=Class'VietnamWeapons.PickupAmmo50Cal';
	//RequiredEquipment[15]=Class'VietnamWeapons.PickupAmmo556NATO';
	//RequiredEquipment[15]=Class'VietnamWeapons.PickupAmmo762NATO';
	//RequiredEquipment[15]=Class'VietnamWeapons.PickupAmmo762NATOBeltFed';
	//RequiredEquipment[15]=Class'VietnamWeapons.PickupAmmo762WP';
	//RequiredEquipment[15]=Class'VietnamWeapons.PickupAmmoM21';
	//RequiredEquipment[15]=Class'VietnamWeapons.PickupAmmoM79Buckshot';

	AddDefaultInventory();

	for( Inv = Inventory; Inv != None; Inv = Inv.Inventory )
	{
		NamWeapon = VietnamWeapon(Inv);

		if( NamWeapon != None )
		{
			NamAmmo = VietnamAmmo(NamWeapon.AmmoType);

			if( NamAmmo != None )
			{
				NamAmmo.AmmoAmount = NamAmmo.MaxAmmo;
				//NamAmmo.Damage = 2*NamAmmo.Damage;
			}
		}
	}*/

//=============================== *UMODGAME* End ===============================

}

simulated event TravelPostAccept()
{
	if( Weapon != None )
	{
		if( Level.m_bKeepWeaponHidden == false )
		{
				PendingWeapon = Weapon;
				Weapon = None;
				ChangedWeapon();
		}
		else
		{
			Weapon.PutDown();
		}
	}
}

// return true if controlled by a Player (AI or human)
// BJ added this override so can tell on other client machines whether this 
// pawn is human controlled
simulated function bool IsPlayerPawn()
{
	return true;  // player character is always human controlled.
}


//
// JG - Added for LD controlled player equipment
//
function AddDefaultInventory()
{
	local int i;

	for (i = 0; i < Level.RequiredEquipmentByClass.length; i++)
	{
		if(Level.RequiredEquipmentByClass[i]?)
			CreateInventoryFromClass(Level.RequiredEquipmentByClass[i]);
	}

	for (i = 0; i < Level.OptionalEquipmentByClass.length; i++)
	{
		if(Level.OptionalEquipmentByClass[i]?)
			CreateInventoryFromClass(Level.OptionalEquipmentByClass[i]);
	}

	AddDefaultAmmo();

	// HACK FIXME
	if ( inventory != None )
		inventory.OwnerEvent('LoadOut');
}

function AddDefaultAmmo()
{
	local int i;
	

	// Check the PlayerStartingAmmo array
	for (i = 0; i < Level.PlayerStartingAmmo.length; i++)
	{
		Level.GiveAmmoAmount(self, Level.PlayerStartingAmmo[i].AmmoClass, Level.PlayerStartingAmmo[i].iAmount);
	}

	// Prevent LD's from using the old way
/*
	// Also check the old way of giving the player ammo
	// changed so that the player doesn't get ammo type if not being given any ammo - BJ 05-19-03
	if( Level.i45Cal > 0 )
		Level.GiveAmmoAmount( self, class'Ammo45Cal', Level.i45Cal );
	if( Level.i50Cal > 0 )
		Level.GiveAmmoAmount( self, class'Ammo50Cal', Level.i50Cal );
	if( Level.i556NATO > 0 )
		Level.GiveAmmoAmount( self, class'Ammo556NATO', Level.i556NATO );
	if( Level.i762NATO > 0 )
		Level.GiveAmmoAmount( self, class'Ammo762NATO', Level.i762NATO );
	if( Level.i762NATOBeltFed > 0 )
		Level.GiveAmmoAmount( self, class'Ammo762NATOBeltFed', Level.i762NATOBeltFed );
	if( Level.i762WP > 0 )
		Level.GiveAmmoAmount( self, class'Ammo762WP', Level.i762WP );

	if( Level.iFragGrenade > 0 )
		Level.GiveAmmoAmount( self, class'AmmoFragGrenade', Level.iFragGrenade );
	if( Level.iM79Buckshot > 0 )
		Level.GiveAmmoAmount( self, class'AmmoM79Buckshot', Level.iM79Buckshot );
	if( Level.iM79Flare > 0 )
		Level.GiveAmmoAmount( self, class'AmmoM79Flare', Level.iM79Flare );
	if( Level.iM79FragGrenade > 0 )
		Level.GiveAmmoAmount( self, class'AmmoM79FragGrenade', Level.iM79FragGrenade );
	if( Level.iM79SmokeGrenade > 0 )
		Level.GiveAmmoAmount( self, class'AmmoM79SmokeGrenade', Level.iM79SmokeGrenade );
	if( Level.iRPG7 > 0 )
		Level.GiveAmmoAmount( self, class'AmmoRPG7', Level.iRPG7 );
	if( Level.iSmokeGrenade > 0 )
		Level.GiveAmmoAmount( self, class'AmmoSmokeGrenade', Level.iSmokeGrenade );
*/
}

// TSS: Added so that the player will play his damn idle
simulated function PlayWaiting();

// In singleplayer, no headshots on the playercharacter
// TODO: This should be dependent upon difficulty level
// Easy: only torso hits
// Normal: No headshots
// Hard: All hits are enabled
function HitLocation_e DetermineHitLocation(int iHitBone)
{
	local int                     difficulty;
	local VietnamPlayerController myController;
	
	// figure out the difficulty setting
	myController = VietnamPlayerController( Controller );
	if ( myController? )
	{
		difficulty =
			myController.ComputePlayerProfile( ).iGetDifficulty(myController.GameReplicationInfo.GameClass);
	}
	else
	{
		log( self $ ":  I do not have a VietnamPlayerController.  Difficulty defaulting to Medium." );
		difficulty = 1;
	}
	
	// what type of game is the player playing?
	// 0 - Easy
	// 1 - Medium (default)
	// 2 - Hard
	Switch ( difficulty )
	{
	Case 2:
		// get hit just like any other character
		// in the game (head shots count)
		return Super.DetermineHitLocation( iHitBone );
		break;

	Case 1:
		// All hit locations are acceptable,
		// except head shots, which become
		// torso hits instead
		switch(GetBoneName(iHitBone))
		{
			case 'Bip_Head':
			case 'Bip_HeadNub':
			case 'Bip_Neck':
			case 'Bip_LClavicle':
			case 'Bip_RClavicle':
				return HL_Torso;
			default:
				return Super.DetermineHitLocation(iHitBone);
		}
		break;

	Case 0:
	Default:
		// Torso hits only
		return HL_Torso;
		break;
	}
}

// overloaded:  changes the view model for the player
// if they are not "player 0"
//
// inputs:
// inController - that does the possessing
//
// outputs:
// -- none --
function PossessedBy( Controller inController )
{
	// swap the model
	if ( inController.Tag != 'PlayerController0' )
	{
		//AssetName = m_playerTwoModelName;
		//LinkMesh( Mesh( DynamicLoadObject(
		//	AssetName, class'Mesh' ) ), true, true );
		//LinkSkelAnims( );

		AnimEnd( IDLECHANNEL );
		AnimEnd( IDLECHANNEL );

		// mtb - changed this for coop
		ChangeTag( Name( "Player1" ) );
	}
	else ChangeTag( Name( "Player0" ) );
	
	// then do the parent stuff
	Super.PossessedBy( inController );
}

defaultproperties
{
     m_playerTwoModelName="ModelHuman_Marine_large_black.Marine_Large_Black"
     bSpawnedInEditor=True
     Back=None
     LeftFrontBelt=None
     RightFrontBelt=None
     RightBackBelt=None
     BackBelt=None
     Begin Object Class=AIParams Name=AIParams0
         Name="AIParams0"
     End Object
     AI=AIParams'VietnamCharacters.AIParams0'
     bCanPickupInventory=True
     bActorShouldTravel=False
     Tag="Player"
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
     AssetName="ModelHuman_MarineShephard.MarineShephard"
}
