// Weapon specific ThirdPersonEffects
class WeaponWhiteSmokeGrenadeAttachment extends VietnamWeaponAttachment;

// Spawn and attach muzzleclass
// Spawn and attach shell eject class
event simulated PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	Skins[0]=Material(DynamicLoadObject("weapons_tex.lowpoly.grenadesmokewhite_tex",class'Texture'));
}

static function StaticPrecacheAssets(optional Object MyLevel)
{
	Super.StaticPrecacheAssets(MyLevel);

	DynamicLoadObject("weapons_tex.lowpoly.grenadesmokewhite_tex",class'Texture');
}

defaultproperties
{
     MuzzleOffset=(Y=-8.000000,Z=-1.500000)
     StaticMeshName="low_poly_weapons_stat.m18_low_poly_stat"
     DrawType=DT_StaticMesh
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
