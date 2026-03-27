//===============================================================================
//  [ M79 ]
//===============================================================================

class WeaponM79 extends VietnamWeapon
	native
	nativereplication;

//#exec OBJ LOAD FILE=..\Textures\weapons_tex.utx
//#exec OBJ LOAD FILE=..\Textures\decals_tex.utx

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// defines the number of different types of ammo
// that this gun can fire
const NUMBER_OF_AMMO_TYPES = 3;

// Ammo variables
// AmmoType will point to the currently used entry in the Ammo array
var Array<class<ammunition> > AmmoTypes;			
var travel Ammunition Ammo[ NUMBER_OF_AMMO_TYPES ];
var int PickupAmmoCounts[NUMBER_OF_AMMO_TYPES];	// Stores PickupAmmoCount for each ammo type

var Array<Material> ShellTextures;

var bool			AllowAmmoChange;

var int				iBuckshotTraces;

var texture CrosshairCopy;	// Primary crosshair when player shouldn't shoot

var travel int iAmmoIndex;	// Index in the Ammo array that's currently being used

var bool bForceChangeAmmo;	// If true, weapon should change ammo next time it has a chance

// replication strategy:  the client needs enough info
// to function properly, so we need to send it the
// ammo array for its HasAmmo( ) check
replication
{
	reliable if ( bNetDirty && ( Role == ROLE_Authority ) )
		Ammo;
}

// Functions overridden to handle multiple AmmoTypes /////////////////////////////////////

event TravelPostAccept()
{
	local int iCounter;

	log("M79 TravelPostAccept");

	if ( Pawn(Owner) == None )
		return;
	for(iCounter = 0; iCounter < NUMBER_OF_AMMO_TYPES; iCounter++)
	{
		Ammo[iCounter] = Ammunition(Pawn(Owner).FindInventoryType(AmmoTypes[iCounter]));

			if ( Ammo[ iCounter ] == NONE )
			{
			log("Couldn't find inventory " $ AmmoTypes[iCounter] $ " spawning");

				Ammo[iCounter] = Spawn(AmmoTypes[iCounter]);	// Create ammo type required		
				Pawn(Owner).AddInventory(Ammo[iCounter]);		// and add to player's inventory
				Ammo[iCounter].AmmoAmount = 0;					// No more pickup ammo
				Ammo[iCounter].GotoState('');
			}
			else
			{
			log("Found inventory " $ AmmoTypes[iCounter]);
			}
		}
	GotoState('');

	Super.TravelPostAccept();

	UpdateSkins();
	AllowAmmoChange = true;
}

function bool HandlePickupQuery( Pickup Item )
{
	local int NewAmmo;
	local int iCounter;
	local Pawn P;

	local int iNumWeapons;
	local bool bHasWeapon;
	local class<Weapon> PkWepClass;
	local Ammunition LoadedAmmo;
	local bool bAmmoAdded;

//	local class<Pickup> AmmoClassForWeapon;

	log("Weapon::HandlePickupQuery called on " $self $" for " $item, 'Pickup');
	P = Pawn(Owner);

	if(P == None)
	{
		log("Weapon: " $self $" had no owner that was a pawn");
	}	

	PkWepClass = class<Weapon>(Item.InventoryType);
	log("PkWepClass: " $PkWepClass);
	if((PkWepClass != None)/* &&
		!PkWepClass.Default.bExcludeFromWeapSwap*/)
	{
		bHasWeapon = P.HasInventoryType(Item.InventoryType);
		//log("bHasWeapon: " $bHasWeapon $" CurPick InvType: " $Item.InventoryType);
		iNumWeapons = P.GetNumWeapons(false);
		//log("Weaponclass: " $PkWepClass $" bHas: " $bHasWeapon $" iNumWeap: " $iNumWeapons $" bExcl: " $PkWepClass.Default.bExcludeFromWeapSwap);
		if(!bHasWeapon && iNumWeapons >= 4)
		{
			//log("didn't have weapon and weapons >=3");
			//we're not going to pick it up for ammo,
			//and we already have the max # of weapons, so don't pick it up
			return true;//don't allow pickup.. true means "dont take"
		}	
	}

	if (Item.InventoryType == Class)
	{
		if ( item.bWeaponStay && ((item.inventory == None) || item.inventory.bTossedOut) )
		{
			return true;
		}

		if ( Item.Inventory != None )
		{
			// Add in value of reloadcount
			log("Adding ammo " $ Weapon(Item.Inventory).ReloadCount $ " rounds of " $ Ammo[iAmmoIndex].class $ " ammo", 'Pickup');
			Ammo[iAmmoIndex].AddAmmo(Weapon(Item.Inventory).ReloadCount);

			for(iCounter = 0; iCounter < NUMBER_OF_AMMO_TYPES; iCounter++)
			{
				NewAmmo = WeaponM79(Item.Inventory).PickupAmmoCounts[iCounter];

				if(NewAmmo > 0)
				{
					// Figure out what ammo pickup class is associated with this weapon pickup
					// First try VietnamItems package, if not found try VietnamWeapons package
					// All pickups are in one or the other
					///AmmoClassForWeapon = class<Pickup>(DynamicLoadObject("VietnamItems." $ Ammo[iCounter].PickupType, class'class'));

					log("Adding ammo " $ NewAmmo $ " rounds of " $ Ammo[iCounter].class $ " ammo", 'Pickup');
					if(Ammo[iCounter].AddAmmo(NewAmmo))
					{
						// Prints out a message for a player picking up a weapon he already has, and therefore
						// getting ammo for it
						P.ClientInventoryMessage(Ammo[iCounter].Class);

					bAmmoAdded = true;
					}
				}
			}

			if(PkWepClass != None 
				&& !bAmmoAdded)
			{
				//log("HPQ returning false to get rid of pickup, no ammo in item");
				// Return true to not get the pickup, not false
				return true;//just get rid of the pickup since its empty and we have one
			}
		}

//		AmmoType = Ammo[0];
		Item.AnnouncePickup(Pawn(Owner));
		return true;
	}
	if ( Inventory == None )
	{
		return false;
	}

	return Inventory.HandlePickupQuery(Item);
}

// Takes whatever ammo the weapon uses and puts it into easy to use variables
function LoadAmmoIntoPickupAmmoCount()
{
	local int i;

	for (i=0;i<NUMBER_OF_AMMO_TYPES;i++)
	{
		PickupAmmoCounts[i] = Ammo[i].AmmoAmount;
		Ammo[i].AmmoAMount = 0;
	}
}


// Stops weapon from using any ammo other than clip
// Called when a weapon is dropped using DropCurrentWeapon()
function DisconnectAmmo()
{
	local int i;

	for (i=0;i<NUMBER_OF_AMMO_TYPES;i++)
	{
		Ammo[ i ] = None;
	}

	Super.DisconnectAmmo();
}

function GiveFullAmmo()
{
	local int i;
	local Ammunition TempAmmo;

	// Give default clips
	for (i=0;i<NUMBER_OF_AMMO_TYPES;i++)
	{
		TempAmmo = Ammunition(Instigator.FindInventoryType(AmmoTypes[i]));
		if ( TempAmmo != None )
		{
			Ammo[ i ] = TempAmmo;
		}
		else
		{
			Ammo[i] = Spawn(AmmoTypes[i]);
			Instigator.AddInventory(Ammo[i]);
		}

		// Max out each ammo type
		Ammo[i].AmmoAmount = Ammo[i].MaxAmmo;
	}

	// Set current ammo type to frag grenade
	AmmoType = Ammo[0];
}

function GiveAmmo( Pawn Other )
{
	local int i;
	local Ammunition TempAmmo;

	log("M79 GiveAmmo");

	// Give default clips
	for (i=0;i<NUMBER_OF_AMMO_TYPES;i++)
	{
		TempAmmo = Ammunition(Other.FindInventoryType(AmmoTypes[i]));
		if ( TempAmmo != None )
		{
			log("Found " $ AmmoTypes[i]);

			// Check if everything is setup correctly already
			if(TempAmmo == Ammo[ i ])
			{
				log("Weapon's ammo is the same ");
				continue;
			}
			
			// Add old ammo amount to existing ammo
			if(Ammo[ i ]?)
			{
				TempAmmo.AmmoAmount += Ammo[ i ].AmmoAmount;
				Ammo[i].Destroy();
				log("Adding " $ Ammo[ i ].AmmoAmount $ " rounds of " $ Ammo[ i ].class);
			}
			else
				log("M79 contains no ammotypes, assigning pawn's ammotype");

			Ammo[ i ] = TempAmmo;
		}
		else
		{
			log("Couldn't find " $ AmmoTypes[i] $ " spawning");

			TempAmmo = Spawn(AmmoTypes[i]);
			Other.AddInventory(TempAmmo);

			// Add old ammo amount to existing ammo
			if(Ammo[ i ]?)
			{
				TempAmmo.AmmoAmount = Ammo[i].AmmoAmount;
				log("Adding " $ Ammo[ i ].AmmoAmount $ " rounds of " $ Ammo[ i ].class);
			}
			else
				log("Pawn doesn't have correct ammotype, spawning " $ TempAmmo.class);
			Ammo[i] = TempAmmo;
		}
	}

// default behavior
// 
//	// Set current ammo type to frag grenade
//	AmmoType = Ammo[0];

	// pick the first ammo type that has an
	// ammoamount > 0, default to grenades if
	// all are empty
	//for ( i = 0; i < NUMBER_OF_AMMO_TYPES && Ammo[ i ].AmmoAmount == 0; ++i )
	//{
	//	// keep looking for an ammo type that has ammo
	//}
	//if ( i >= NUMBER_OF_AMMO_TYPES )
	//{
	//	i = 0;
	//}
	//AmmoType = Ammo[ i ];
}

////////////////////////////////////////////////////////////////////////////////////////

// overloaded:  sets up the materials so
// that skins can be swapped in and out
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (UnReal Event)
simulated function PostNetBeginPlay( )
{
	// let the parent do its tasks first
	Super.PostNetBeginPlay( );

	// then, initialize the materials
	CopyMaterialsToSkins( );
}

function GiveTo(Pawn Other, optional bool bDontGiveAmmo)
{
	local Inventory TempInventory;
	local int iCounter;

	Super.GiveTo(Other, bDontGiveAmmo);

	// Spawn in all necessary ammo for the M79 and give it
	// to the guy picking up the weapon
	// Setup local Ammo array to point to correct ammunition in pawn
	for(iCounter = 0; iCounter < NUMBER_OF_AMMO_TYPES; iCounter++)
	{
		TempInventory = Other.FindInventoryType(AmmoTypes[iCounter]);
		if(!TempInventory)
		{
			TempInventory = Spawn(AmmoTypes[iCounter]);
			TempInventory.GiveTo(Other, bDontGiveAmmo);
			Ammo[iCounter].AddAmmo(PickupAmmoCounts[iCounter]);

			log(self $ " spawning new ammo of type " $ TempInventory.class $ " giving ammo amount of " $ PickupAmmoCounts[iCounter], 'Pickup');
		}
		else
		{
			log(self $ " setting ammo index " $ iCounter $ " to " $ Ammunition(TempInventory).class $ " which has " $ PickupAmmoCounts[iCounter] $ " rounds", 'Pickup');

			Ammo[iCounter].AddAmmo(PickupAmmoCounts[iCounter]);
		}

		// Reset ammo count
		PickupAmmoCounts[iCounter] = 0;
	}

	// Set ammo type to be the ammo already loaded in the gun
	AmmoType = Ammo[iAmmoIndex];

	// Do first time update (after the weapon has its AmmoType)
	UpdateSkins();
	AllowAmmoChange = true;	// Reset this value as UpdateSkins will set it to false
}

// This function is only used to fire buckshot
function TraceFire(float Accuracy, float YOffset, float ZOffset )
{
	local vector HitLocation, StartTrace, EndTrace, vForward, vRight, vUp;
	
	local int iCounter;

	CurrentAimImprovementAmount = 0;

	// FIXME TEMP
	if ( Instigator.bIgnorePlayFiring )
		return;

	Owner.MakeNoise(1.0);
	
	GetAxes(Instigator.GetViewRotation(),vForward, vRight, vUp);

	// Get start and end points for the trace
	VietnamPawn(Instigator).BroadcastAIEvent(VietnamPawn(Instigator).GetAIEventForName('AI_EV_WEAPON_FIRE'), StartTrace);

	for(iCounter=0;iCounter<iBuckshotTraces;iCounter++)
	{
		EndTrace = GetFireEnd(StartTrace);
		InnerTraceFire(StartTrace, EndTrace);
	}
	
	if (ThirdPersonActor!=None)
		VietnamWeaponAttachment(ThirdPersonActor).HitLoc = HitLocation;
}

function ProjectileFire()
{
	local Vector Start, X,Y,Z;
	local vector SpawnPoint, StartPoint, EndPoint;
	local VietnamPlayerController VController;
	local VietnamBot VBot;
	local bool bPlayer;
	local rotator AdjustedAim;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	Start = GetFireStart(X,Y,Z); 

	VController = VietnamPlayerController(Instigator.Controller);

	if(VController != None)
	{
		bPlayer = true;
	}
	else
	{
		bPlayer = false;
		VBot = VietnamBot(Instigator.Controller);
		if(VBot == None)
			warn("GetFireEnd() called by non-VietnamPlayerController and non-VietnamBot");
	}


	// TODO: We should probably do a trace before firing the grenade
	if(FirstPersonView())
	{
		EndPoint = GetFireEnd(StartPoint);
		AdjustedAim = rotator(EndPoint - StartPoint);


		// Spawn at muzzle point, but also need to push out beyond pawn's collision cylinder
		SpawnPoint = StartPoint;
		SpawnPoint += X * 40;
	}
	else
	{
		// FIXME: Hmm, what bone to use here??
		SpawnPoint = Instigator.GetBoneCoords('Bip_RHand').origin + (X * 30);
	}

	if(bPlayer)
		AdjustedAim = VController.VietnamAdjustAim(AmmoType, SpawnPoint, AdjustedAim);
	else
		AdjustedAim = VBot.VietnamAdjustAim(AmmoType, SpawnPoint, rotator(X));

	AmmoType.SpawnProjectile(SpawnPoint,AdjustedAim);
}

simulated function MinimumDistanceCheck(float DeltaTime)
{
	if( AmmoType != None && AmmoType.IsA('AmmoM79FragGrenade') && ReloadCount != 0)
		Super.MinimumDistanceCheck(DeltaTime);
	else
		Crosshair = NormalCrosshair;
}

simulated state Idle
{
	simulated function BeginState()
	{
		Super.BeginState();

		log("BeginState Idle");

		// This catches the situation where the M79 starts off with buckshot ammo instead
		// of switching to it
		if(AmmoType.IsA('AmmoM79Buckshot'))
			bNoAccuracyModifications = true;
		else
			bNoAccuracyModifications = false;

		if(bForceChangeAmmo)
		{
			ServerAltFire();
			bForceChangeAmmo = false;
		}
	}

	function ServerAltFire()
	{
		ChangeGrenadeAmmo();
	}
}

// Used while playing rechamber anim
state Rechamber
{
	ignores Fire, ForceReload;

	// Don't let remote players call AltFire as it causes weirdness due to lag, etc.
	simulated function AltFire( float Value )
	{
		if(Role == ROLE_Authority)
			Global.AltFire(Value);
	}

	// This state kinda counts as reloading
	simulated function bool IsReloading()
	{
		return true;
	}

	simulated function BeginState()
	{
		local AnimInfo myAnim;
		
		// Ammo skin will change during this animation
		PlayAnim( 'Rechamber', 1.3f, 0.05,
			FIRING_ANIMATION_CHANNEL );
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_ACTION_TWEEN_TIME,
			WEAPON_ACTION_TWEEN_TIME, );

		log("BeginState rechamber");
		bClientReadyForCommand = false;
	}

	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			GotoState('Idle');
		}
	}
	
	// Override non-state functionality
	simulated function DoRechamber() {}

	function ServerAltFire()
	{
		ChangeGrenadeAmmo();
	}

	// Rechamber could be complete or maybe player switched weapons
	simulated function EndState()
	{
		log("EndState rechamber");
		bClientReadyForCommand = true;
		AllowAmmoChange = true;
	}
}

simulated function AltFire( float Value )
{
	ServerAltFire();

	if(Level.NetMode == NM_Client)
		DoRechamber();
}

// Used while playing rechamber anim
state Reloading
{
	ignores Fire, ForceReload;

	// Don't let remote players call AltFire as it causes weirdness due to lag, etc.
	simulated function AltFire( float Value )
	{
		if(Role == ROLE_Authority)
			ServerAltFire();
	}

	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			AllowAmmoChange = true;

			Super.AnimEnd( Channel );
		}
	}
	
	// Override non-state functionality
	simulated function DoRechamber() {}

	function ServerAltFire()
	{
		ChangeGrenadeAmmo();
	}

	// Reload could be complete or maybe player switched weapons
	simulated function BeginState()
	{
		log("BeginState reload");
		Super.BeginState();

		AllowAmmoChange = true;
	}
	
	// Reload could be complete or maybe player switched weapons
	simulated function EndState()
	{
		log("EndState reload");
		Super.EndState();

		AllowAmmoChange = true;
	}

}

simulated function DoRechamber()
{
	if(ReloadCount == 0)
		GotoState('Reloading');
	else
		GotoState('Rechamber');
	
	if ( Level.NetMode != NM_Client )
	{
	// Rechambering counts as reloading
		DoReload();
	}
}

// Make sure M79 updates its skins after the hand texture has been applied
simulated function ApplyHandTexture( VietnamPawn.HandTextureEnum inHandTexture )
{
	Super.ApplyHandTexture(inHandTexture);

	UpdateSkins();
	AllowAmmoChange = true;
}

// Called from AnimNotify
simulated function ForceUpdateSkins()
{
	UpdateSkins();
}

// Called by AnimNotify during rechamber animation and activate
simulated function UpdateSkins()
{
	local int iCounter;
	local Material NewMaterial;

	AllowAmmoChange = false;

	// Find the material of the loaded shell
	// Assign to NewMaterial
	for(iCounter = 0; iCounter < NUMBER_OF_AMMO_TYPES; iCounter++)
	{
		if(AmmoType == Ammo[iCounter])
		{
			NewMaterial = ShellTextures[iCounter];
			break;
		}
	}

	// Assign textures (buckshot and flare are special)
	if ( NewMaterial != NONE )
	{
		if ( AmmoType.Class == Class'AmmoM79Buckshot' )
		{
			Skins[2] = Material(DynamicLoadObject("Decals_tex.transparency_tex_shader", class'Shader'));
			Skins[3] = NewMaterial;
			Skins[4] = Material(DynamicLoadObject("Decals_tex.transparency_tex_shader", class'Shader'));
		}
/*
		else if ( AmmoType.Class == Class'AmmoM79Flare' )
		{
			Skins[2] = Material(DynamicLoadObject("Decals_tex.transparency_tex_shader", class'Shader'));
			Skins[3] = Material(DynamicLoadObject("Decals_tex.transparency_tex_shader", class'Shader'));
			Skins[4] = NewMaterial;
		}
*/
		else
		{
			// assign everyone else this way
			skins[2]=NewMaterial;
			skins[3]=Material(DynamicLoadObject("decals_tex.transparency_tex_shader",class'Shader'));
			skins[4]=Material(DynamicLoadObject("decals_tex.transparency_tex_shader",class'Shader'));
		}
	}
	else
	{
		log( self $ "(" $ ItemName $ "):  Unable to use " $ AmmoType.ItemName );
	}
}

// Changes the ammo used by the grenade launcher
// It's called from several states where ammo changing is possible
simulated function ChangeGrenadeAmmo()
{
	local int iNextAmmoIndex;
	local int iCounter;
	local Ammunition CurrentAmmoType;

	// If we aren't allowed to change the ammo type, then return without doing anything
	if(AllowAmmoChange == false)
	{
		// If this is a server and the guy using the weapon is a remote client
		// queue up this command and execute it at the next opportunity
		if(Role==ROLE_Authority && !Instigator.IsLocallyControlled())
		{
			bForceChangeAmmo = true;
		}
		return;
	}

	VietnamPawn(Instigator).EndSpawnInvulnerability();

// Added for some reason, but it's causing a bug
// for some other reason, so we're taking it out
//
//	// also, don't proceed if the controller
//	// is precisely aiming
//	if( Instigator.Controller.IsInPreciseAimMode() )
//	{
//		return;
//	}

	CurrentAmmoType = AmmoType;

	for(iCounter = 0; iCounter < NUMBER_OF_AMMO_TYPES; iCounter++)
	{
		if(AmmoType == Ammo[iCounter])
		{
			// Start checking the one after what we're currently using
			iNextAmmoIndex = iCounter + 1;
			// Check through list searching for first ammotype that actually has ammo
			for(iCounter = 0; iCounter < NUMBER_OF_AMMO_TYPES; iCounter++)
			{
				// Reset back to the beginning of the list if we went off the end
				if(iNextAmmoIndex >= NUMBER_OF_AMMO_TYPES )
					iNextAmmoIndex = 0;
				if(Ammo[iNextAmmoIndex].AmmoAmount > 0 && Ammo[iNextAmmoIndex] != CurrentAmmoType)
				{
					AmmoType.AmmoAmount += ReloadCount;	// Return the shell to reserve ammo
					ReloadCount = 0;
					AmmoType = Ammo[iNextAmmoIndex];
					//AmmoType.AmmoAmount--;	// Get next shot from new AmmoType
					iAmmoIndex = iNextAmmoIndex;
					break;
				}
				
				// UScript can't have two statements in a for loop, so here is another increment
				iNextAmmoIndex++;
			}
			break;
		}
	}
	
	// Consider the weapon reloaded upon ammo change
	if(CurrentAmmoType != AmmoType)
	{
		DoRechamber();

		// Server will handle this, and rep to client
		if(Role == ROLE_Authority)
		{
		if(AmmoType.IsA('AmmoM79Buckshot'))
			bNoAccuracyModifications = true;
		else
			bNoAccuracyModifications = false;
		}
	}
}

// overloaded:  occassionally plays a different
// putaway animation
//
// inputs:
// -- none --
//
// outputs:
// name of the animation to play
simulated function Name GetPutAwayAnimationName( )
{
	if ( FRand( ) > 0.75 )
	{
		return 'putaway_alt';
	}
	// else....
	
	return Super.GetPutAwayAnimationName( );
}

// returns true if this gun has any ammo left,
// of any type
//
// inputs:
// -- none --
//
// outputs:
// true if some ammo left, false otherwise
simulated function bool HasAmmo( )
{
	local int currentAmmo;

	if(Super.HasAmmo())
		return true;
	else
	{
	// search through all of the ammos	
	for( currentAmmo = 0;
		currentAmmo < NUMBER_OF_AMMO_TYPES;
		++currentAmmo )
	{
		if ( Ammo[ currentAmmo ] != NONE &&
			Ammo[ currentAmmo ].HasAmmo( ) )
		{
			return true;
		}
	}
	
	return false;
}
}



// Change the current ammo used to whatever is specified
function AIChangeAmmo(class<Ammunition> NewAmmo)
{
	local int iCounter;

	for(iCounter = 0; iCounter < NUMBER_OF_AMMO_TYPES; iCounter++)
	{
		if(Ammo[iCounter].Class == NewAmmo)
		{
			AmmoType = Ammo[iCounter];
			break;
		}
	}
}

static function StaticPrecacheAssets(optional Object MyLevel)
{
	DynamicLoadObject("weapons_tex.shells.m79_frag_shader",class'Shader');		
	DynamicLoadObject("weapons_tex.shells.m79_smoke_shader",class'Shader');		
	DynamicLoadObject("weapons_tex.shells.m79_buckshot_shader",class'Shader');		

	Super.StaticPrecacheAssets(MyLevel);
}

simulated function Spawned()
{
	Super.Spawned();

	ShellTextures[0]=Shader(DynamicLoadObject("weapons_tex.shells.m79_frag_shader",class'Shader'));		
	ShellTextures[1]=Shader(DynamicLoadObject("weapons_tex.shells.m79_buckshot_shader",class'Shader'));		
	ShellTextures[2]=Shader(DynamicLoadObject("weapons_tex.shells.m79_smoke_shader",class'Shader'));		

	//Crosshair=Texture(DynamicLoadObject("interface_tex.HUD.reticledot_tex",class'Texture'));		
	//SecondaryCrosshair=Texture(DynamicLoadObject("interface_tex.HUD.reticlering_tex",class'Texture'));		
	CrosshairCopy = Crosshair;
}

// overloaded:  properly accounts for the
// multiple types of ammo that this gun can
// use
//
// inputs:
// inAmmo - to use
//
// outputs:
// -- none --
function AddAmmo( Ammunition inAmmo )
{
	local Int i;
	
	// check the incoming ammo against all of
	// the possible ammo types
	for ( i = 0; i < NUMBER_OF_AMMO_TYPES; ++i )
	{
		if ( !Ammo[ i ] && inAmmo.Class == AmmoTypes[ i ] )
		{
log( self $ ":  Assigning " $ inAmmo $ " for " $ i $ " == " $ AmmoTypes[ i ] );		
			Ammo[ i ] = inAmmo;
		}
	}
}

// overloaded:  forces a reload on stow, if necessary
state DownWeapon
{
	// overloaded:  force a reload if we can
	//
	// inputs:
	// inChannel - the channel that ended
	//
	// outputs:
	// -- none --
	simulated function AnimEnd( Int inChannel )
	{
		// reload first (if we need)
		if ( inChannel == IDLE_ANIMATION_CHANNEL )
		{
			if ( CanReload( ) )
			{
				// Reload M79 automagically, but only on the server
				// If this is a client its low ammo will be cleared by OnPostReceive_ReloadCount
				if(Role == ROLE_Authority)
				{
					DoReload( );

					CheckForLowAmmo();
				}
			}
		}

		// then do the parent stuff
		Super.AnimEnd( inChannel );
	}
}

// Overridden to support buckshot mode specific sound
simulated function PlayFiring()
{
	local VietnamPlayerController VController;

	// Only play the non-positional sound if the controller is on this machine
	if(Instigator.IsLocallyControlled() && Instigator.IsHumanControlled())
	{
		VController = VietnamPlayerController(Instigator.Controller);

		if(ForceFeedbackEffect?)
			VController.PlayForceFeedbackEffect(ForceFeedbackEffect, 2);

		if( VController.IsInstancePlaying(FPFireVoices[FPFireVoiceIndex]))
		{
			VController.ClientStopRegisteredSound(FPFireVoices[FPFireVoiceIndex]);
		}

		// If using buckshot, play custom sound
		if(AmmoType.class == AmmoTypes[1])
			VController.ClientPlayRegisteredSound(WeaponSoundNames[6].ResourceName,FPFireVoices[FPFireVoiceIndex]);
		else
			VController.ClientPlayRegisteredSound(WeaponSoundNames[EWeaponSound.EWS_FPFire].ResourceName,FPFireVoices[FPFireVoiceIndex]);

		FPFireVoiceIndex++;
		if(FPFireVoiceIndex == ArrayCount(FPFireVoices))
			FPFireVoiceIndex = 0;

		TriggerShellEjector();
	}

	// Always play the third person sound (which will replicate to clients), if this is
	// a locally controlled pawn the sound won't be heard

	WeaponPlayRemoteFireSound();

	TriggerMuzzleFlashAttachment();
	if(WeaponMode==EWM_Auto)
	{
		PlayFiringAnimation(AutoFireSpeed);
	}
	else
	{
		ReadyToFire=false;
		PlayFiringAnimation(SemiAutoSpeed);
	}
}

// Overridden to support buckshot mode specific sound
function WeaponPlayRemoteFireSound()
{
	// NOTE: The replicated stop func doesn't seem to work correctly on clients
	Instigator.RemoteStopRegisteredSound(TPFireVoices[TPFireVoiceIndex]);

	// If using buckshot, play custom sound
	if(AmmoType.class == AmmoTypes[1])
		Instigator.RemotePlayRegisteredSound(WeaponSoundNames[7].ResourceName, TPFireVoices[TPFireVoiceIndex]);
	else
		Instigator.RemotePlayRegisteredSound(WeaponSoundNames[EWeaponSound.EWS_TPFire].ResourceName, TPFireVoices[TPFireVoiceIndex]);

	TPFireVoiceIndex++;
	if(TPFireVoiceIndex == ArrayCount(TPFireVoices))
		TPFireVoiceIndex = 0;
}

// Update aim type depending upon what ammo is being used
function OnPostReceive_AmmoType()
{
	if(AmmoType.IsA('AmmoM79Buckshot'))
		bNoAccuracyModifications = true;
	else
		bNoAccuracyModifications = false;
}

defaultproperties
{
     AmmoTypes(0)=Class'VietnamWeapons.AmmoM79FragGrenade'
     AmmoTypes(1)=Class'VietnamWeapons.AmmoM79Buckshot'
     AmmoTypes(2)=Class'VietnamWeapons.AmmoM79SmokeGrenade'
     AllowAmmoChange=True
     iBuckshotTraces=14
     PlayerCrouchViewOffset=(X=5.450000,Y=2.800000,Z=-14.550000)
     PlayerAimViewOffset=(X=5.450000,Y=-1.600000,Z=-14.550000)
     Magnification=1.000000
     Accuracy=0.000000
     Recoil=0.000000
     m_maximumRecoil=750.000000
     Damage=0.000000
     WeaponDamageType=Class'VietnamGame.DamageBulletNoStat'
     PrecisionAimTransitionTime=0.200000
     bUseWeaponDamage=False
     bUseWeaponAccuracy=False
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     bDisplayAmmoType=True
     fMinimumDistance=1250.000000
     WeaponSoundNames(0)=(PackageName="weapon_snd",ResourceName="M79Outdoor")
     WeaponSoundNames(1)=(PackageName="weapon_snd",ResourceName="M79NP")
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="RifleUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="RifleEquip")
     WeaponSoundNames(6)=(PackageName="weapon_snd",ResourceName="M79BuckshotOutdoor")
     WeaponSoundNames(7)=(PackageName="weapon_snd",ResourceName="M79BuckshotNP")
     SemiAutoSpeed=1.000000
     m_fViewYawKick=192.000000
     m_fViewPitchKick=750.000000
     m_fViewDegradeYaw=0.000000
     m_fViewDegradePitch=2048.000000
     m_fViewKickMaxYawDelta=8192.000000
     m_fViewKickMaxPitchDelta=16384.000000
     MinTurnRateScale=0.550000
     TurnRateRampPower=10.000000
     AimAssistAngle=20.000000
     MinPrecisionTurnRateScale=1.000000
     PrecisionTurnRateRampPower=10.000000
     PrecisionAimAssistAngle=20.000000
     MinScreenPercent=0.000050
     ForceFeedbackEffect="Fire gun"
     PreferredWeaponMenuIndex=4
     bAutoReload=True
     AmmoName=Class'VietnamWeapons.AmmoM79FragGrenade'
     ReloadCount=1
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     specificReloadAnim="Th_Ab_M79_Reload"
     MeshName="USMC_Viewmodels.fps_m79"
     PickupType="PickupM79"
     PlayerViewOffset=(X=5.450000,Y=2.800000,Z=-14.550000)
     PlayerHorizSplitViewOffset=(X=5.450000,Y=2.800000,Z=-14.550000)
     PlayerVertSplitViewOffset=(X=5.450000,Y=2.800000,Z=-14.550000)
     ThirdPersonRelativeLocation=(X=7.000000,Y=-11.000000,Z=11.000000)
     AttachmentClass=Class'VietnamWeapons.WeaponM79Attachment'
     ItemName="M79"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
