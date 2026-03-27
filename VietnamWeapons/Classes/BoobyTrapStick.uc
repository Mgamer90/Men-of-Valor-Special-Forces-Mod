// This is a static mesh of a stick for a boobytrap
class BoobyTrapStick extends Actor
	placeable;

var string StaticMeshName;

event simulated PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if(StaticMeshName? && !StaticMesh)
		SetStaticMesh(StaticMesh(DynamicLoadObject(StaticMeshName,class'StaticMesh')));
}

// If something changed, reinitialize stuff
event SpawnedInEditor()
{
	// DLO the StaticMesh if necessary
	if (!StaticMesh && StaticMeshName?)
	{
		SetStaticMesh(StaticMesh(DynamicLoadObject(StaticMeshName,class'StaticMesh')));
	}
}

// If something changed, reinitialize stuff
event PostEditLoad()
{
	// DLO the StaticMesh if necessary
	if (!StaticMesh && StaticMeshName?)
	{
		SetStaticMesh(StaticMesh(DynamicLoadObject(StaticMeshName,class'StaticMesh')));
	}
}

defaultproperties
{
     StaticMeshName="boobytraps_stat.grenadetrap_stat"
     bOrientOnSlope=True
     bCollideActors=True
     bCollideWorld=True
     bUseCylinderCollision=True
     DrawType=DT_StaticMesh
     CollisionRadius=5.000000
     CollisionHeight=20.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
