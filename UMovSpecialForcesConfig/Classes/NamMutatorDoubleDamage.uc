//=============================================================================
// NamMutatorDoubleDamage.
//=============================================================================
class NamMutatorDoubleDamage extends Mutator
	placeable;

function bool MutatorIsAllowed()
{
	return true;
}

function ModifyPlayer(Pawn Other)
{
	local Inventory Inv;
	local VietnamAmmo NamAmmo;
	local VietnamWeapon NamWeapon;

	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);

	for( Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory )
	{
		if( Inv.IsA('VietnamWeapon') )
		{
			NamWeapon = VietnamWeapon(Inv);

			if( NamWeapon != None )
			{
				NamAmmo = VietnamAmmo(NamWeapon.AmmoType);

				if( NamAmmo != None )
				{
					NamAmmo.Damage = 2*NamAmmo.Damage;
				}
			}
		}
	}
}

defaultproperties
{
     ListInServerBrowser=True
     GroupName="DoubleDamage"
     FriendlyName="DoubleDamage"
     Description="Double Damage on all weapons."

     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
