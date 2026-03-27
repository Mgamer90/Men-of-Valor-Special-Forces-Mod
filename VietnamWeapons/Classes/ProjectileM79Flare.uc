//=============================================================================
// ProjectileM79Flare.uc
// Basically a dynamically lit object
//=============================================================================
class ProjectileM79Flare extends VietnamProjectile;

var bool bFirstTime;
var FlareCorona MyCorona;
//var FlareSmokeEmitter MySmokeEmitter;
var HackDefaultParticleEffect MySmokeEmitter;


var bool bDud;		// If it hits something without arming, it becomes a dud
var bool bArmed;	// It takes time to arm

var int m_iHDRNumBlurPasses;		//"The number of blurring passes used";
var int m_iHDRNumBlurPixels;		//"The pixel offset for each blur pass";
var byte m_cHDRHotPixelIntensity;	//"The percentage illumination that hot zone will be percieved as being";
var byte m_cHDRBlendOpacity;		//"The percentage opacity at which the bleeding will be blended in";

var bool m_bDoGammaRamp;
var float m_fBrightness;
var float m_fGamma;
var float m_fContrast;

var config float fArmTime;
var config float fFlareTime;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(fArmTime, false);                  //Grenade begins unarmed, arms at ~30m

	if ( Role == ROLE_Authority )
	{
		Velocity = GetTossVelocity(Instigator, Rotation);

//		RandSpin(35000);

		Instigator.EnsurePhysVolsNotBorked( );

		if ( WaterVolume(Instigator.HeadVolume) != None )
		{
			bHitWater = True;
			Velocity *= 0.6;
		}
	}	
}

function SaveHDRValues()
{
	m_iHDRNumBlurPasses = Level.m_iHDRNumBlurPasses;
	m_iHDRNumBlurPixels = Level.m_iHDRNumBlurPixels;
	m_cHDRHotPixelIntensity = Level.m_cHDRHotPixelIntensity;
	m_cHDRBlendOpacity = Level.m_cHDRBlendOpacity;
}

function RestoreHDRValues()
{
	Level.m_iHDRNumBlurPasses = m_iHDRNumBlurPasses;
	Level.m_iHDRNumBlurPixels = m_iHDRNumBlurPixels;
	Level.m_cHDRHotPixelIntensity = m_cHDRHotPixelIntensity;
	Level.m_cHDRBlendOpacity = m_cHDRBlendOpacity;
}

function SetNewHDRValues()
{
	Level.m_iHDRNumBlurPasses = 16;
	Level.m_iHDRNumBlurPixels = 3;
	Level.m_cHDRHotPixelIntensity = 32;
	Level.m_cHDRBlendOpacity = 255;
}

function Destroyed()
{
	if(MyCorona != None)
	{
		MyCorona.Destroy();
		MyCorona = None;
	}

	if(MySmokeEmitter != None)
	{
		MySmokeEmitter.Destroy();
		MySmokeEmitter = None;
	}

	Super.Destroyed();
}

function SaveGammaRamp()
{
	local string sTmp;
	
	sTmp = ConsoleCommand("get XboxDrv.XboxClient Brightness");
	m_fBrightness = float(sTmp);
	
	sTmp = ConsoleCommand("get XboxDrv.XboxClient Gamma");
	m_fGamma = float(sTmp);

	sTmp = ConsoleCommand("get XboxDrv.XboxClient Contrast");
	m_fContrast = float(sTmp);
	
	if(m_fBrightness == 0)
		m_fBrightness = float(ConsoleCommand("get WinDrv.WindowsClient Brightness"));
	if(m_fGamma == 0)
		m_fGamma = float(ConsoleCommand("get WinDrv.WindowsClient Gamma"));
	if(m_fContrast == 0)
		m_fContrast = float(ConsoleCommand("get WinDrv.WindowsClient Contrast"));
}

function RestoreGammaRamp()
{
	ConsoleCommand("Brightness NOSAVECONFIG "$m_fBrightness);
	ConsoleCommand("Gamma NOSAVECONFIG "$m_fGamma);
	ConsoleCommand("Contrast NOSAVECONFIG "$m_fContrast);
}

function SetGammaRamp()
{
	assert(m_bDoGammaRamp); // This must be true for this to be called
	ConsoleCommand("Brightness NOSAVECONFIG "$Level.m_fFEBrightness);
	ConsoleCommand("Gamma NOSAVECONFIG "$Level.m_fFEGamma);
	ConsoleCommand("Contrast NOSAVECONFIG "$Level.m_fFEContrast+(frand() * 0.33));
}

// Light it up, deploy parachute
function Timer()
{
	if(bDud)
	{
		if(bFirstTime)
			SetTimer(10.0, false);
		else
			Destroy();
	}
	else if(bFirstTime)
	{
		// Chute opens, light deploys
		Acceleration = vect(0,0,1500);	// Cancel out gravity
		Velocity = vect(0,0,-100);

		if(Level.m_bFlareIsActive)
			m_bDoGammaRamp = false;
		else
			m_bDoGammaRamp = true;

		//bDynamicLight = true; // Light bad
		
		// Light Environment
		//SaveHDRValues();	
		//SetNewHDRValues();	
		
		if(m_bDoGammaRamp)
		{
			Level.m_bFlareIsActive = true;
			SaveGammaRamp();
			SetGammaRamp();
			SetDelegateTimer('SetGammaRamp', 0.05, true);
		}

		// One web reference said this burns for 40 seconds
		SetTimer(fFlareTime, false);
		bFirstTime = false;
		bArmed = true;

		// Spawn in various effects
		MyCorona = Spawn(class'FlareCorona');
		MyCorona.SetLocation(self.Location);
		MyCorona.SetBase(self);


		//MySmokeEmitter = Spawn(class'FlareSmokeEmitter');
		MySmokeEmitter = Spawn(class'HackDefaultParticleEffect');
		//log("constructing FlareSmokeEmitter");
		MySmokeEmitter.LookupConstruct("FlareSmokeEmitter");	

		MySmokeEmitter.SetLocation(self.Location);
		MySmokeEmitter.SetBase(self);
	}
	else
	{
		if(m_bDoGammaRamp)
		{
			// Now the flare has burned off
			SetDelegateTimer('SetGammaRamp', 0);
			RestoreGammaRamp();
			Level.m_bFlareIsActive = false;
		}

		//RestoreHDRValues();

		// Kill off corona
//		MyCorona.StartFade();
		MyCorona.Destroy();
		MyCorona = None;

		// Kill off smoke emitter
		MySmokeEmitter.Emitters[0].m_bPauseSpawning = true;
		MySmokeEmitter.TimeToDie();
		MySmokeEmitter = None;

		Destroy();
	}
}

// Check if we hit something before we're armed
simulated function Explode(vector HitLocation, vector HitNormal)
{
	if(!bArmed)
	{
		bDud = true;
		return;
	}
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local vector HitNormal;

	if(Other != Instigator && Other.bBlockProjectiles)
	{
		HitNormal = Normal(HitLocation - Other.Location);
	
		BounceCollision(-Normal(Velocity), Other);

		Explode(HitLocation, HitNormal);
	}
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	BounceCollision(HitNormal, Wall);

	Explode(Location, HitNormal);
}

// Does physics calculation for bouncing off of a surface
simulated function BounceCollision(Vector HitNormal, Actor Other)
{
	if(bArmed && Other.bWorldGeometry)
	{
		bBounce = False;
		SetPhysics(PHYS_None);
		return;
	}

	Velocity += (Velocity dot HitNormal * HitNormal * -2);
	Velocity *= 0.4;

	RandSpin(35000);
	speed = VSize(Velocity);

	if ( Level.NetMode != NM_DedicatedServer )
		PlaySound(ImpactSound, SLOT_Misc, 1.5,,150,,true);

//	if ( Velocity.Z > 400 )
//		Velocity.Z = 0.5 * (400 + Velocity.Z);
//	else 
	if ( Other.bWorldGeometry && speed < 50 ) 
	{
		bBounce = False;
		SetPhysics(PHYS_None);
	}
}

defaultproperties
{
     bFirstTime=True
     fArmTime=1.000000
     fFlareTime=20.000000
     speed=4000.000000
     MaxSpeed=5000.000000
     TossZ=300.000000
     Damage=220.000000
     DamageRadius=1200.000000
     MomentumTransfer=10.000000
     MyDamageType=None
     ExploWallOut=10.000000
     bUnlit=False
     bBlockZeroExtentTraces=False
     bUseCylinderCollision=True
     bBounce=True
     bFixedRotationDir=True
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
     LifeSpan=0.000000
     SoundRadius=10.000000
     SoundVolume=218
     CollisionRadius=5.000000
     CollisionHeight=5.000000
     LightType=LT_Steady
     LightBrightness=255.000000
     LightHue=64
     LightSaturation=128
     LightRadius=1024.000000
     ForceRadius=100.000000
     ForceScale=200.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     AssetName="weapons_stat.shells.flare_shot_stat"
}
