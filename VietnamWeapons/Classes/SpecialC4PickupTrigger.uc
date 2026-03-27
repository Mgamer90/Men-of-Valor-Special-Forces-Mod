// Trigger for givning the user an InventoryC4
class SpecialC4PickupTrigger extends NewTrigger
	placeable;

function Triggered( Pawn User )
{
	local Inventory CreatedC4;

	Super.Triggered(user);

	SendStateMessages('Used');

	// Give the user the C4
	UnrealPawn(User).CreateInventory("VietnamItems.InventoryC4");
	// Now that he has it, get a ref to it
	CreatedC4 = User.FindInventoryByName('InventoryC4');

	// Set the inventory's tag to be the trigger's tag to match them up later
	CreatedC4.ChangeTag(Tag);

	bHidden = true;
}

simulated function Spawned()
{
	Super.Spawned();

	if(!StaticMesh)
		SetStaticMesh(StaticMesh(DynamicLoadObject("enemy_gear_stat.enemy_satchelcharge_01_stat", class'StaticMesh')));
}

defaultproperties
{
     bDisableAfterUse=True
     bRestrictPlayerFacing=True
     bHidden=False
     DrawType=DT_StaticMesh
     CollisionHeight=10.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="used"
     m_arrEventStates(2)="C4Respawn"
}
