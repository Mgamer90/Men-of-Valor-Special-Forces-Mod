class BoobyTrapTrigger extends NewTrigger;

var float fWireCutterUseTime;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	ActorToFace = self;
}

// If the trigger is triggered, disable the trap
function Triggered(Pawn user)
{
	BoobyTrapGrenade(Owner).DisableTrap();
}

// Who can use a booby trap trigger is a little different from regular NewTriggers
// So I've completely overridden the function here
simulated function bool CanBeUsedBy(Controller User)
{
	local float fCurrentFacingDot;

	if(!m_bIsActive)
	{
		//log("Can't use trigger " $ self $ ", trigger is inactive");
		return false;
	}

	if (!User)
	{
		//log("Can't use trigger " $ self $ ", no controller");
		return false;
	}

	// Dead men use no triggers
	if(User.IsDead())
	{
		//log(self $ " touched by dead guy, can't use trigger");
		return false;
	}
	
	// If there is a team retriction, check if the player's team is allowed
	// to use this trigger
	if(bRestrictPlayerTeam)
	{
		if(User.PlayerReplicationInfo.Team?)
		{
			if(User.PlayerReplicationInfo.Team.TeamIndex != AllowedTeam)
			{
//				log("Can't use trigger " $ self $ ", my team is not allowed and trigger is team restricted");
				return false;
			}
		}
	}

	// Prevent user from disarming own trap
	if(User == Instigator)
	{
//		log("Can't use trigger " $ self $ ", user is instigator");
		return false;
	}

	// Check if someone else is using the trigger
	if(CurrentUser? && CurrentUser != User.Pawn)
	{
//		log("Can't use trigger " $ self $ ", trigger is already in use by someone else");
		return false;
	}

	// If we're playing singleplayer, any player can disarm a trap
	// For multiplayer he must have wire cutters
	if(Level.GRI.IsSingleplayerTypeGame())
	{
		// PlayerCharacter's always have wire cutters without actually having them
		if(User.Pawn.IsA('PlayerCharacter'))
		{
			//log("Can use trigger " $ self $ ", because user is player is SP game");
			return true;
		}
	}

	// If the controller's facing is restricted, check that it passes that restriction
	if(bRestrictPlayerFacing && ActorToFace != None)
	{
		if (!VietnamPlayerController(User))
		{
			//log("Can't use trigger " $ self $ ", I'm not human");
			return false;
		}
		else
		{
			VietnamPlayerController(User).FacingDirection(ActorToFace.location, fCurrentFacingDot);

			if(fCurrentFacingDot >= fFacingThreshold)
			{
				//log("User can use trigger");
				return true;
			}
			else
			{
				//log("Can't use trigger " $ self $ ", I'm not looking at it");
				return false;
			}
		}
	}
	else
	{
		//log("User can use trigger");
		return true;
	}
}

// Returns time it will take to use the trigger
simulated function float CalcUseTime(Pawn User)
{
	// Really fast use for guy w/ wire cutters or for singleplayer
	if(User.FindInventoryByName('WireCutters')? || User.IsA('PlayerCharacter'))
		return fWireCutterUseTime;
	else
		return fUseTime;
}

defaultproperties
{
     strMessage="Press #UseButton# to cut wire"
     fFacingThreshold=0.600000
     fUseTime=2.000000
     bHidden=False
     bUseCylinderCollision=False
     bDirectional=True
     bAllowBoxEncroachment=True
     DrawType=DT_StaticMesh
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     AssetName="boobytraps_stat.trip_wire_collision_stat"
}
