//=============================================================================
// ProjectileWhiteSmokeGrenade.uc
//=============================================================================
class ProjectileWhiteSmokeGrenade extends ProjectileSmokeGrenade;

// Boom!
simulated function Explode(vector HitLocation, vector HitNormal)
{
	BlowUp(HitLocation);

	if ( Level.NetMode != NM_DedicatedServer )
	{
		// Make a sound
		PlaySound(ProjectileSounds[EProjectileSound.EPS_Explosion],,,,1000,,true);
	}

	// Spawn the explosion
	// only spawn the effect on the server
	if ( Level.NetMode != NM_Client )
	{
		//MyEmitter = spawn(class'SmokeGrenadeRedEffect',self,,Location + vect(0,0,5),rot(16384,0,0));
		MyEmitter = spawn(class'HackDefaultParticleEffect',,,Location + vect(0,0,5),rot(16384,0,0));
		//log("constructing SmokeGrenadeRedEffect");

		MyEmitter.LookupConstruct("SmokeGrenadeWhiteCover");	

		MyEmitter.setBase( self );
		MyEmitter.PlaySound(ProjectileSounds[2],,,,1000,,true);
	}
}

static function StaticPrecacheAssets(optional Object MyLevel)
{
	Super.StaticPrecacheAssets(MyLevel);

	DynamicLoadObject("weapons_tex.low_poly.grenadesmokewhite_tex",class'Texture');
}


simulated event Spawned()
{
	Super.Spawned();

	Skins[0] = Material(DynamicLoadObject("weapons_tex.low_poly.grenadesmokewhite_tex",class'Texture'));
}

defaultproperties
{
     ProjectileSoundNames(0)=(PackageName="weapon_snd",ResourceName="SmokeGrenade")
     ProjectileSoundNames(1)=(PackageName="weapon_snd",ResourceName="GrenadeHitDirt")
     ProjectileSoundNames(2)=(PackageName="weapon_snd",ResourceName="SmokeGrenadeHiss")
     LifeSpan=15.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
