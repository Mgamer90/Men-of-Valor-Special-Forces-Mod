// Can be placed by an LD or spawned into place in multiplayer
class SpecialPlacementTrigger extends BaseGlowyTrigger
	placeable
	hidecategories(Travel)
	hidecategories(Force)
	hidecategories(BaseGlowyTrigger)
	hidecategories(Sound);


var() class<Inventory> RequiredItem;

replication
{
	reliable if( (Role==ROLE_Authority) && bNetInitial)
		RequiredItem;
}


simulated function PostNetBeginPlay()
{
	// Update mesh in case of new AssetName
	if(Role < ROLE_Authority)
		Spawned();

	Super.PostNetBeginPlay();

	// Update the UseString and PlacedString similarly to how the NewTrigger updates its strings
	if(m_iLocalizedMessageIdentifier != -1)
		UseString = Level.LocalizedMessageStrings[m_iLocalizedMessageIdentifier];
	if(m_iLocalizedUsedMessageIdentifier != -1)
		PlacedString = Level.LocalizedMessageStrings[m_iLocalizedUsedMessageIdentifier];
}

function Triggered( Pawn User )
{
	local Controller CurrentController;
	local VietnamPlayerController VPController;
	local Inventory UserItem;

	// We could get here with an inactive trigger since an LD message
	// calls Triggered directly, so double check that it is active
	// If a guy with wire cutters shows up he can disarm the C4
	if (bClaymorePresent == true)
	{
		return;
	}

	UserItem = User.FindInventoryType(RequiredItem);

	// Remove C4 from inventory
	if(UserItem?)
	{
		UserItem.Destroy();
	}
	else
		log("SpecialPlacementTrigger used by user w/o RequiredItem");

	Super(BaseGlowyTrigger).Triggered(user);

	SendStateMessages('Used');

//	BroadcastLocalizedMessage( class'SatchelPlantedMessage', , User.PlayerReplicationInfo,, self);
}

// Function to check if a certain pawn can use this trigger
// It is assumed the pawn is touching the trigger
simulated function bool CanBeUsedBy(Controller User)
{
	local VietnamWeapon SatchelWeapon;

	// For a singleplayer type game anyone can use the trigger according to normal trigger rules
	// For a multiplayer type game a user also needs to have a satchel charge in his 
	// inventory to use the trigger.
	// If the user is an enemy than he must have wirecutters
	if(Super(BaseGlowyTrigger).CanBeUsedBy(User))
	{
		if(bClaymorePresent)
		{
			return false;
		}
		else
		{
			// Check that user has the RequiredItem
			if(User.Pawn.FindInventoryType(RequiredItem)?)
				return true;			// user has the RequiredItem
			else
				return false;		// user has no RequiredItem
		}
	}
	else
	{
		// Change team restriction and test if the person can use the trigger
		// It is assumed all C4 triggers have team restriction on
		bRestrictPlayerTeam = false;

		if(Super(BaseGlowyTrigger).CanBeUsedBy(User))
		{
			bRestrictPlayerTeam = true;	// Restore earlier setting
            if(bClaymorePresent)
				return true;
			else
				return false;
		}
		else
			bRestrictPlayerTeam = true;	// Restore earlier setting
	}

	return false;
}

// Always disable and hide SpecialPlacementTrigger
function Reset()
{
	Super.Reset();

	bHidden = true;
	m_bIsActive = false;
}

simulated function BeginUse( Pawn inUser )
{
	// Overridden to play no anims, doesn't call Super
}

simulated function Spawned()
{
	Super.Spawned();

	SetStaticMesh(StaticMesh(DynamicLoadObject(AssetName, class'StaticMesh')));
		
	UsedStaticMesh = StaticMesh(DynamicLoadObject(AssetName, class'StaticMesh'));

	NonUsedStaticMesh = StaticMesh(DynamicLoadObject(AssetName, class'StaticMesh'));

	// Make sure our skins array is setup
	CopyMaterialsToSkins();

	NonUsedTexture = Material(DynamicLoadObject("Effects_tex.common.marker_finalblend", class'FinalBlend'));

	UsedTexture = skins[0];
}

defaultproperties
{
     UseString="Press Use to place some item (LD localize me!)"
     bRestrictPlayerFacing=True
     bAlwaysRelevant=True
     bReplicateAssetName=True
     CollisionHeight=10.000000
     m_arrEventStates(0)="NoClaymore"
     m_arrEventStates(1)="used"
     m_arrEventStates(2)="Detonated"
     AssetName="enemy_gear_stat.enemy_satchelcharge_01_stat"
}
