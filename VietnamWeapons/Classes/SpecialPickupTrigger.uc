// Trigger for giving the user some type of inventory
class SpecialPickupTrigger extends NewTrigger
	hidecategories(Travel)
	hidecategories(Force)
	hidecategories(Sound)
	placeable;

var() class<Inventory> ItemToGive;

function Triggered( Pawn User )
{
	local Inventory CreatedInventory;

	Super.Triggered(user);

	SendStateMessages('Used');

	// Give the user the inventory item
	UnrealPawn(User).CreateInventory(ItemToGive);
	// Now that he has it, get a ref to it
	CreatedInventory = User.FindInventoryType(ItemToGive);

	// Set the inventory's tag to be the trigger's tag to match them up later
	CreatedInventory.SetTriggerOwner(self);

	bHidden = true;
}

defaultproperties
{
     strMessage="Press Use to place some item (LD localize me!)"
     strUsedMessage="Some item was placed (LD localize me!)"
     bDisableAfterUse=True
     bRestrictPlayerFacing=True
     bHidden=False
     DrawType=DT_StaticMesh
     CollisionHeight=10.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     m_arrEventStates(2)="InventoryDropped"
     AssetName="enemy_gear_stat.enemy_satchelcharge_01_stat"
}
