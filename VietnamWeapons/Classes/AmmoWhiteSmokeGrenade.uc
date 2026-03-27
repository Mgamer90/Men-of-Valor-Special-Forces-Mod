//=============================================================================
// AmmoWhiteSmokeGrenade
// class for white puffy smoke grenade
//=============================================================================
class AmmoWhiteSmokeGrenade extends VietnamAmmo;

function SpawnThrownProjectile(vector Start, rotator Dir, float ThrowStrength)
{
	local VietnamProjectile SpawnedGrenade;
	
	SpawnedGrenade = Spawn(MyProjectileClass,Owner,, Start,Dir);
	
	ProjectileSmokeGrenade(SpawnedGrenade).Initialize(ThrowStrength);
}

defaultproperties
{
     MyProjectileClass=Class'VietnamWeapons.ProjectileWhiteSmokeGrenade'
     MaxAmmo=4
     AmmoAmount=0
     bInstantHit=False
     PickupType="WeaponWhiteSmokeGrenade"
     ItemName="White Smoke Grenades"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
