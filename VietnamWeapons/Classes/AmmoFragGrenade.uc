//=============================================================================
// AmmoFragGrenade
// class for frag grenades
//=============================================================================
class AmmoFragGrenade extends VietnamAmmo;

function SpawnThrownProjectile(vector Start, rotator Dir, float ThrowStrength)
{
	local VietnamProjectile SpawnedGrenade;
	
	SpawnedGrenade = Spawn(MyProjectileClass,Owner,, Start,Dir);

	if(Instigator?)
	{
		SpawnedGrenade.InstigatorVelocity = Instigator.Velocity;
		SpawnedGrenade.InstigatorController = Instigator.Controller;
	}

	ProjectileFragGrenade(SpawnedGrenade).Initialize(ThrowStrength);
}

defaultproperties
{
     MyProjectileClass=Class'VietnamWeapons.ProjectileFragGrenade'
     MaxAmmo=6
     AmmoAmount=0
     bInstantHit=False
     PickupType="PickupFragGrenade"
     ItemName="Frag Grenades"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
