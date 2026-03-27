// This is a static mesh of a stick for a boobytrap
class BoobyTrapString extends Actor;

simulated function PostNetBeginPlay()
{
	local Vector OldLocation;

	Super.PostNetBeginPlay();

	// Wacky HACK to get the rotation to replicate
	// Without a SetLocation the string gets rotation (0,0,0) even though it replicated correctly
	OldLocation = Location;
	SetLocation(vect(100,100,100));
	SetLocation(OldLocation);
}

// In a team game, no one on the team of the boobytrap planter should set it off
// And in DM, the guy who planted it should not be able to set it off
event Touch( Actor Other )
{
	local Pawn VictimPawn;

	VictimPawn = Pawn(Other);

	// Only pawns can trip boobytraps
	if(!VictimPawn)
		return;

	// Don't allow the owner to set it off
	if(VictimPawn == Instigator)
		return;

	// No VC can set it off
	if(Pawn(Other).PlayerReplicationInfo.Team.TeamIndex == 1)
		return;

	BaseTrap(Owner).BaseFire();
}

// If something changed, reinitialize stuff
event SpawnedInEditor()
{
	// DLO the StaticMesh if necessary
	if (!StaticMesh)
	{
		SetStaticMesh(StaticMesh(DynamicLoadObject(AssetName,class'StaticMesh')));
	}
}

// If something changed, reinitialize stuff
event PostEditLoad()
{
	// DLO the StaticMesh if necessary
	if (!StaticMesh)
	{
		SetStaticMesh(StaticMesh(DynamicLoadObject(AssetName,class'StaticMesh')));
	}
}

defaultproperties
{
     bCollideActors=True
     bBlockZeroExtentTraces=False
     DrawType=DT_StaticMesh
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     AssetName="boobytraps_stat.trip_wire_stat"
}
