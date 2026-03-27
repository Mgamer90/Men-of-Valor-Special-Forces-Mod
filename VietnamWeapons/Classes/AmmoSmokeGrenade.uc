//=============================================================================
// ammosmokeGrenade
// class for smoke grenades
//=============================================================================
class AmmoSmokeGrenade extends VietnamAmmo;

function SpawnThrownProjectile(vector Start, rotator Dir, float ThrowStrength)
{
	local VietnamProjectile SpawnedGrenade;
	
	SpawnedGrenade = Spawn(MyProjectileClass,Owner,, Start,Dir);
	
	if(Instigator?)
		SpawnedGrenade.InstigatorController = Instigator.Controller;

	ProjectileSmokeGrenade(SpawnedGrenade).Initialize(ThrowStrength);
}

defaultproperties
{
     MyProjectileClass=Class'VietnamWeapons.ProjectileSmokeGrenade'
     MaxAmmo=4
     AmmoAmount=0
     bInstantHit=False
     PickupType="PickupSmokeGrenade"
     ItemName="Smoke Grenades"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
