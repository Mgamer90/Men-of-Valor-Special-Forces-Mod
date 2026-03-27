// Weapon specific ThirdPersonEffects
class WeaponEnemyFragGrenadeAttachment extends VietnamWeaponAttachment;


simulated event ThirdPersonEffects()
{
	// spawn 3rd person effects

	// have pawn play firing anim
	if ( Instigator != None )
		Instigator.PlayGrenadeThrowing();
}

defaultproperties
{
     MuzzleOffset=(Y=-8.000000,Z=-1.500000)
     StaticMeshName="weapons_stat.nva.vc_stickgrenade_stat"
     DrawType=DT_StaticMesh
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
