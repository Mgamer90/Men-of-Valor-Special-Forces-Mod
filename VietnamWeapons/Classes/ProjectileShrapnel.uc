//=============================================================================
// ProjectileFragGrenade.uc
//=============================================================================
class ProjectileShrapnel extends VietnamProjectile;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Role == ROLE_Authority )
	{
		if ( Instigator? )
		{
			Instigator.EnsurePhysVolsNotBorked( );

			if ( WaterVolume(Instigator.HeadVolume) != None )
			{
				bHitWater = True;
				Velocity *= 0.6;			
			}
		}
	}	
}

// We need to decelerate the shrapnel
function Tick(float DeltaTime)
{
	local float Deceleration;

	Deceleration = 1.0;

	Velocity *= 1 - (Deceleration * DeltaTime);

	Super.Tick(DeltaTime);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	// It's owner is the grenade (or other explosive object) that exploded
	// since we're spawning from it, we don't want t touch it
	if ( Other != Owner && !Other.IsA('Projectile'))
	{
		Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * Velocity, MyDamageType, InstigatorController);	
		Destroy();
	}
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	Velocity += (Velocity dot HitNormal * HitNormal * -2);

	speed = VSize(Velocity);

	//TODO: This ricochet sound is a bit overpowering so tone it down some
//	RegisterSound(ImpactSound);
//	PlaySound(ImpactSound, SLOT_Misc, 0.6,,100,,true);
	if ( Level.NetMode != NM_Client )
	{
//		spawn(class'PclSparks');
//		spawn(class'SmallSpark');
	}
}

defaultproperties
{
     speed=1500.000000
     MaxSpeed=10000.000000
     TossZ=0.000000
     Damage=10.000000
     DamageRadius=0.000000
     MomentumTransfer=10.000000
     MyDamageType=Class'VietnamGame.DamageGrenade'
     ImpactSound=Sound'effects_snd.BulletRicochet'
     ExploWallOut=10.000000
     bNetTemporary=True
     bUnlit=False
     bUseCylinderCollision=True
     bBounce=True
     bFixedRotationDir=True
     DrawType=DT_StaticMesh
     LifeSpan=0.450000
     DrawScale=5.000000
     SoundRadius=10.000000
     SoundVolume=218
     CollisionRadius=5.000000
     CollisionHeight=5.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     AssetName="weapons_stat.us.grenade_fragment_stat"
}
