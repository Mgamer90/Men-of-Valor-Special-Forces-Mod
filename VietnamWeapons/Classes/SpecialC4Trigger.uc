// Can be placed by an LD or spawned into place in multiplayer
class SpecialC4Trigger extends C4Trigger
	placeable;

function Triggered( Pawn User )
{
	local Controller CurrentController;
	local VietnamPlayerController VPController;
	local Inventory C4Inventory;

	// We could get here with an inactive trigger since an LD message
	// calls Triggered directly, so double check that it is active
	// If a guy with wire cutters shows up he can disarm the C4
	if (bClaymorePresent == true)
	{
		if(!m_bIsActive)
			return;

		// Removed User.Controller.SameTeakAs check because it 
		// prevented the bomb from being disarmed by the player
		// switching teams after planting the bomb
		Disarmed();

		// Let LD's messages work after Reset code so he can override anything he wants
		SendStateMessages('Disarmed');

		return;
	}

	C4Inventory = User.FindInventoryByName('InventoryC4');

	// Remove C4 from inventory
	if(C4Inventory?)
	{
		C4Inventory.Destroy();
	}
	else
		log("SpecialC4Trigger used by user w/o InventoryC4");

	Super(BaseGlowyTrigger).Triggered(user);

	SendStateMessages('Used');

	// If this is an LD placed trigger, tell everyone about the planting, maybe specifying team/player that planted?
	if(bResettable)
	{
		if(Level.GRI.IsMultiplayerTypeGame())
			BroadcastLocalizedMessage( class'SatchelPlantedMessage', LocalizedLocationStringIndex, User.PlayerReplicationInfo);

		Level.GRI.StartExplosiveTimer(self, fTimer);
	}

	SetDelegateTimer('Detonate', fTimer, false);
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
			// Check that user has the InventoryC4
			if(User.Pawn.FindInventoryByName('InventoryC4')?)
				return true;			// user has the C4
			else
				return false;		// user has no C4
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

// Returns time it will take to use the trigger
simulated function float CalcUseTime(Pawn User)
{
	if(IsOnEnemyTeam(User))
	{
		return Super.CalcUseTime(User);
	}
	else
	{
		return PlantTime;
	}
}

// Always disable and hide SpecialC4Trigger
function Reset()
{
	Super.Reset();

	bHidden = true;
	m_bIsActive = false;
}

defaultproperties
{
     UseString="Press #UseButton# to place the C4"
     PlacedString="The C4 is in place"
     DisarmString="Press #UseButton# to disarm the C4"
     m_arrEventStates(0)="NoClaymore"
     m_arrEventStates(1)="used"
     m_arrEventStates(2)="Detonated"
     m_arrEventStates(3)="Disarmed"
}
