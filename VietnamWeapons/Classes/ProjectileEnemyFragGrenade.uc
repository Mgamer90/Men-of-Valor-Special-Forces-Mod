//=============================================================================
// ProjectileEnemyFragGrenade.uc
// When a bot throws this grenade it won't arm until it hits the ground
//=============================================================================
class ProjectileEnemyFragGrenade extends ProjectileFragGrenade;

var bool bHitGround;

simulated function PostBeginPlay()
{
	Super(VietnamProjectile).PostBeginPlay();
	//SetTimer(0.1,false);
//	SetDelegateTimer( 'DebrisTimer', fArmTime, false ); //Grenade begins unarmed

	registerWithPlayerControllers();

	RotationRate.Yaw = 0;
	RotationRate.Pitch = -65535;
	RotationRate.Roll = 0;
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if(Instigator.IsHumanControlled())
		StartDetonationTimer();
}

/*
// Do nothing, whereas the US frag grenade spawns in the "spoon"
simulated function DebrisTimer()
{
}
*/

// Does physics calculation for bouncing off of a surface
simulated function BounceCollision(Vector HitNormal, Actor Other)
{
	Super.BounceCollision(HitNormal, Other);

	// Start timer when the grenade hits the ground
	if(!bHitGround && !Instigator.IsHumanControlled())
	{
		bHitGround = true;
		StartDetonationTimer();
	}
}

static function StaticPrecacheAssets(optional Object MyLevel)
{
	local class<Actor> ShrapnelClass;

	Super.StaticPrecacheAssets(MyLevel);

	ShrapnelClass = class<Actor>(DynamicLoadObject("VietnamWeapons.ProjectileShrapnel", class'class'));
	ShrapnelClass.static.StaticPrecacheAssets();
}

defaultproperties
{
     ProjectileSoundNames(0)=(PackageName="weapon_snd",ResourceName="GrenadeExplodeClose")
     ProjectileSoundNames(1)=(PackageName="weapon_snd",ResourceName="BombInWater")
     ProjectileSoundNames(3)=(PackageName="weapon_snd",ResourceName="GrenadeHitDirt")
     m_useRandomSpin=False
     DamageRadius=1200.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     AssetName="weapons_stat.nva.vc_stickgrenade_stat"
}
