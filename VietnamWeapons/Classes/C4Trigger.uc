// Can be placed by an LD or spawned into place in multiplayer
class C4Trigger extends BaseGlowyTrigger
	placeable;

// the different text messages to be displayed
// TSS: Got permission from Whitmore to simply call it a satchel charge instead
// of the weird dual-name system, so these separate strings aren't necessary
var deprecated localized String m_nvaPlacedString;
var deprecated localized String m_nvaUseString;
var deprecated localized String m_nvaDisarmString;
var deprecated localized String m_usaPlacedString;
var deprecated localized String m_usaUseString;
var deprecated localized String m_usaDisarmString;

var() float fTimer	"Time till C4 will detonate after being placed";

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	ExplosionSound = Sound(DynamicLoadObject(ExplosionSoundName,class'Sound'));
	RegisterSound(ExplosionSound);
}

function Triggered( Pawn User )
{
	local WeaponClaymore InventoryWeapon;
	local Controller CurrentController;
	local VietnamPlayerController VPController;
	local VietnamWeapon SatchelWeapon;

	// We could get here with an inactive trigger since an LD message
	// calls Triggered directly, so double check that it is active
	// If a guy with wire cutters shows up he can disarm the C4
	if (bClaymorePresent == true)
	{
		if(!m_bIsActive)
			return;

		// Removed User.Controller.SameTeamAs(InstigatorController) check
		// because it prevented a bomb from being disarmed if the planter
		// changed teams after planting		

		// He has disarmed the satchel charge, Give him one if he is allowed to have one
		if(User.AllowedToPickupType(PICKUPTYPE_WEAPON_SATCHELCHARGE))
		{
				if(User.FindInventoryByName('WeaponSatchelCharge')?)
					Level.GiveAmmoAmount( User, class<Ammunition>(DynamicLoadObject("VietnamWeapons.AmmoSatchelCharge", class'class')), 1 );
				else
				{
					//  If the guy has an empty slot, allow him to pick up the satchel charge
					// Otherwise, it just goes away
					if(User.GetNumWeapons(false) < 4)
						User.GiveWeaponByClass( class<Weapon>(DynamicLoadObject("VietnamWeapons.WeaponSatchelCharge", class'class')) );
				}
		}

		if(bResettable)
			Disarmed();
		else
			Reset();	// Will cause trigger to destroy itself

		// Let LD's messages work after Reset code so he can override anything he wants
		SendStateMessages('Disarmed');

		return;
	}

	if(Level.GRI.IsMultiplayerTypeGame() && bResettable)
	{
		SatchelWeapon = VietnamWeapon(User.FindInventoryByName('WeaponSatchelCharge'));

		// If user had a SatchelCharge, subtract one from his inventory
		if(SatchelWeapon?)
		{
			if(SatchelWeapon.AmmoType.AmmoAmount > 0)
				SatchelWeapon.AmmoType.AmmoAmount--;
			else
			{
				if(SatchelWeapon.ReloadCount == 1)
					SatchelWeapon.ReloadCount = 0;
			}
		}
	}

	Super.Triggered(user);

	SendStateMessages('Used');

	// If this is an LD placed trigger, tell everyone about the planting, maybe specifying team/player that planted?
	if(bResettable)
	{
		if(Level.GRI.IsMultiplayerTypeGame())
			BroadcastLocalizedMessage( class'SatchelPlantedMessage', LocalizedLocationStringIndex, User.PlayerReplicationInfo);

		Level.GRI.StartExplosiveTimer(self, fTimer);
	}

	SetDelegateTimer('Detonate', fTimer, false);
}

function Detonate()
{
	local Emitter SpawnedEmitter;

	if(CurrentUser? && CurrentUser.Controller?)
		VietnamPlayerController(CurrentUser.Controller).StopProgressBar();

	if(!bDetonated)
	{
		//Spawn(class'VietnamEffects.SatchelCharge',,,location);
		SpawnedEmitter = Spawn(class'HackDefaultParticleEffect',,,location);
		//log("constructing SatchelCharge");
		SpawnedEmitter.LookupConstruct("SatchelCharge");

		// Make sure I can hurt the guy who planted me
		SetOwner(None);

		// Hurt everyone around the C4
		HurtRadius( 300, 1400, class'DamageGrenade', 0.0, Location, InstigatorController );

		PlaySound(ExplosionSound,SLOT_Misc,1.0,,1000,,true);

		RadiusShake(ShakeParams, m_flShakeRadius);
	}

	Super.Detonate();
}

// Function to check if a certain pawn can use this trigger
// It is assumed the pawn is touching the trigger
simulated function bool CanBeUsedBy(Controller User)
{
	local VietnamWeapon SatchelWeapon;

	// For a singleplayer type game anyone can use the trigger according to normal trigger rules
	// For a multiplayer type game a user also needs to have a satchel charge in his 
	// inventory to use the trigger.
	// If the user is an enemy than he must have wirecutters
	if(Super.CanBeUsedBy(User))
	{
		if(bClaymorePresent)
			return false;
		else
			return true;
	}
	else
	{
		// Change team restriction and test if the person can use the trigger
		// It is assumed all C4 triggers have team restriction on
		bRestrictPlayerTeam = false;

		if(Super.CanBeUsedBy(User))
		{
			bRestrictPlayerTeam = true;	// Restore earlier setting
            if(bClaymorePresent)
				return true;
			else
				return false;
		}
		else
			bRestrictPlayerTeam = true;	// Restore earlier setting
	}

	return false;
}

// Returns time it will take to use the trigger
simulated function float CalcUseTime(Pawn User)
{
	if(IsOnEnemyTeam(User))
	{
		return Super.CalcUseTime(User);
	}
	else
	{
		if(User.FindInventoryByName('WeaponSatchelCharge')? || Level.GRI.IsSinglePlayerTypeGame())
		{
			return PlantTime;
		}
		else
		{
			return PlantTime * NotEquippedPenalty;
		}
	}
}

function Reset()
{
	local Controller CurrentController;
	local VietnamPlayerController VPController;

	// Disable timer
	SetDelegateTimer('Detonate', 0.0, false);

	if(bResettable)
	{
		Level.GRI.StopExplosiveTimer(self);
	}

	Super.Reset();
}

// C4 was disarmed
function Disarmed()
{
	// Disable timer
	SetDelegateTimer('Detonate', 0.0, false);

	Level.GRI.StopExplosiveTimer(self);

	bClaymorePresent = false;
	Instigator = None;
	CurrentUser = None;

	SetStaticMesh(NonUsedStaticMesh);
	skins[0] = NonUsedTexture;
}

simulated function Spawned()
{
	Super.Spawned();

	if(!StaticMesh)
		SetStaticMesh(StaticMesh(DynamicLoadObject("enemy_gear_stat.enemy_satchelcharge_01_stat", class'StaticMesh')));

	if(!UsedStaticMesh)
		UsedStaticMesh = StaticMesh(DynamicLoadObject("enemy_gear_stat.enemy_satchelcharge_01_stat", class'StaticMesh'));

	if(!NonUsedStaticMesh)
		NonUsedStaticMesh = StaticMesh(DynamicLoadObject("enemy_gear_stat.enemy_satchelcharge_01_stat", class'StaticMesh'));

	if(!NonUsedTexture)
		NonUsedTexture=Material(DynamicLoadObject("Effects_tex.common.marker_finalblend", class'FinalBlend'));
	if(!UsedTexture)
		UsedTexture=Material(DynamicLoadObject("enemy_gear_tex.enemey_satchelcharge_01_tex", class'Texture'));

}

simulated static function StaticPrecacheAssets(optional Object MyLevel)
{
	DynamicLoadObject("Effects_tex.common.marker_finalblend", class'FinalBlend');
	DynamicLoadObject("enemy_gear_tex.enemey_satchelcharge_01_tex", class'Texture');

	DynamicLoadObject(default.ExplosionSoundName,class'Sound');

	Super.StaticPrecacheAssets(MyLevel);
}

defaultproperties
{
     fTimer=20.000000
     ExplosionSoundName="Weapon_snd.DemoCharge"
     ShakeParams=(RotationAmount=(X=500.000000,Y=500.000000),MaxRotationAmount=(X=500.000000),bRandomDirection=True,bRecoverBetweenKicks=True,DecayTime=1.500000,BlurScale=3.000000)
     m_flShakeRadius=2000.000000
     UseString="Press #UseButton# to place a Satchel Charge."
     PlacedString="The Satchel Charge is in place."
     DisarmString="Press #UseButton# to disarm the Satchel Charge"
     bRestrictPlayerFacing=True
     bAlwaysRelevant=True
     CollisionHeight=10.000000
     m_arrEventStates(0)="NoClaymore"
     m_arrEventStates(1)="used"
     m_arrEventStates(2)="Detonated"
     m_arrEventStates(3)="Disarmed"
}
