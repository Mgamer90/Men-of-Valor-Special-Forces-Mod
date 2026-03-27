//===============================================================================
//  [ M7 Bayonet]
// Firing modes:
//	slash
//	stab
//===============================================================================

class WeaponM7 extends VietnamWeapon
	native
	nativereplication;

// special animations used by this class
const M7_STAB_ANIMATION        = 'Knife_Ab_stab';
const M7_SLASH_ANIMATION       = 'Knife_Ab_slash';
const M7_PRONE_STAB_ANIMATION  = 'Knife_pr_stab';
const M7_PRONE_SLASH_ANIMATION = 'Knife_pr_slash';

// special bones used for the grenade throwing animations
const M7_THROW_BONE            = 'Bip_Spine1';
const M7_PRONE_THROW_BONE      = 'Bip_Spine2';

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum M7FireMode
{
	E7M_Slash,
	E7M_Stab,
	E7M_Attach,
	E7M_Attached,
	E7M_Detach
};

var M7FireMode SpecialWeaponMode;

var VietnamWeapon Slave;			// Send fire, reload commands to this weapon if in
									// state ProxyWeapon

var bool bDetachingFromSlave;		// Checked in EndWeaponRelationship

var localized string SlashString;
var localized string StabString;
var localized string AttachString;
var localized string AttachedString;
var localized string DetachString;

replication
{
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		SpecialWeaponMode;
}

simulated function BringUp()
{
	if ( Instigator.IsHumanControlled() )
	{
		SetHand(PlayerController(Instigator.Controller).Handedness);
		PlayerController(Instigator.Controller).EndZoom();
	}	
	bWeaponUp = false;
	PlaySelect();
	if(Slave?)
	{
		GotoState('CommandingSlave');
		BringUp();	// Will be routed to Slave
	}
	else
		GotoState('Active');
}

state CommandingSlave
{
	// Proxying can be ended by changing weapons, or detaching the bayonet
	function EndWeaponRelationship()
	{
		if(bDetachingFromSlave)
		{
			// Reset the weapon
			SpecialWeaponMode = E7M_Slash;
			Slave = None;
			bDetachingFromSlave = false;
			Global.BringUp();
		}
		else
			GotoState('DownWeapon');
	}

	function BeginState()
	{
		Slave.Master = self;
	}

	function float GetWeaponAccuracy()
	{
		if(Slave?)
		{
			return Slave.GetWeaponAccuracy();
		}
		else
			log("No Slave!");
	}

	simulated function DrawHud(canvas Canvas, VietnamHud Hud, float Scale)
	{
		local float tScale;
		local float ScreenScale;

		if ( Instigator == None )
			return;

		tScale = Scale;
		if (Scale<1)
			Scale=1;

		ScreenScale = Canvas.ClipX/1024;

		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetDrawColor(255,255,0);

		//	Instigator.ClientMessage("SpaceX, SpaceY: " $ Canvas.SpaceX $ "," $ Canvas.SpaceY);

		// Draw weapon name
		Canvas.SetPos(Canvas.ClipX - 300*ScreenScale,Canvas.ClipY - 180*ScreenScale);
		Canvas.DrawText(ItemName, false);

		// Everything after the weapon name will fade in
		if ( Hud.WeaponFadeTime > Level.TimeSeconds)
			Canvas.DrawColor = Canvas.DrawColor * (Hud.Default.WeaponFadeTime - (Hud.WeaponFadeTime - Level.TimeSeconds)) * (1.0/Hud.Default.WeaponFadeTime);

		// Draw ammo type
		Canvas.SetPos(Canvas.ClipX - 200*ScreenScale,Canvas.ClipY - 180*ScreenScale);

		if(bDisplayAmmoType)
			Canvas.DrawText(Slave.AmmoType.ItemName, false);
		else
			Canvas.DrawText(GetCurrentWeaponModeName(), false);

		// Draw clip/backpack ammo amount
		Canvas.SetPos(Canvas.ClipX - 250*ScreenScale,Canvas.ClipY - 130*ScreenScale);

		// Don't display current clip ammo if there's no clip
		// Don't display ammo at all if there's no ammo
		if(Slave.Default.ReloadCount == 1)
			Canvas.DrawText(Slave.AmmoType.AmmoAmount, false);
		else if(Slave.Default.ReloadCount != 0)
		{
			if(Slave.bLowAmmo)
			{
				// TODO: Make the current clip count only flash
				// Right now 2 DrawText calls will always put a carriage return in
				Canvas.SetDrawColor(225,20,20);
				Canvas.DrawText(Slave.ReloadCount $ "/" $ Slave.AmmoType.AmmoAmount, false);
			}
			else
				Canvas.DrawText(Slave.ReloadCount $ "/" $ Slave.AmmoType.AmmoAmount, false);
		}

		Scale=tScale;
	}

	simulated event RenderOverlays( canvas Canvas )
	{
		if(Slave?)
		{
			// TODO: DesiredWeaponRotation could probably be eliminated and simply call
			// Pawn.GetWeaponRotation() instead
			Slave.DesiredWeaponRotation = DesiredWeaponRotation;
			Slave.RenderOverlays(Canvas);
		}
		else
			log("No Slave!");
	}

	simulated function bool PutDown()
	{
		if(Slave?)
		{
			Slave.PutDown();
		}
		else
			log("No Slave!");
		
		return True;
	}

	simulated function BringUp()
	{
		if(Slave?)
		{
			Slave.BringUp();
		}
		else
			log("No Slave!");
	}	

	simulated function ForceReload()
	{
		if(Slave?)
			Slave.ForceReload();
		else
			log("No Slave!");
	}

	function Fire(float Value)
	{
		local float fStartFrameSeconds;

		// APT: 6-8-04 use the base function to determine whether we should
		// fake fire
		m_bBotFakeFiring = ShouldFakeFire();
		/*
		// are we actually firing the weapon?
		// 0.5 ms is what were shooting for
		if(bBotControlled)
		{
			m_bBotFakeFiring = (frand() >= (1 - (Level.Game.m_fWeaponFireFrameTime * 1000.f * (1.f / 0.25f))));
			//log("Z: Fake Firing:"$m_bBotFakeFiring$" WeaponFireFrameTime:"$Level.Game.m_fWeaponFireFrameTime);
		}
		*/
	
		fStartFrameSeconds = VietnamPawn(Instigator).appSeconds();

		switch(SpecialWeaponMode)
		{
		case E7M_Attached:
			if(Slave?)
				Slave.Fire(0);
			else
				log("No Slave!");
			break;
		case E7M_Detach:
			// Detach M7 from proxy
			Slave.GotoState('PutawayBayonet');
			bDetachingFromSlave = true;
			break;
		}
		
		Level.Game.m_fWeaponFireFrameTime += VietnamPawn(Instigator).appSeconds() - fStartFrameSeconds;
	}
}

// Called during tick to process when we're ready to fire
// NETHINT: this function is called on the owning client only
//simulated function DoReadyToFire()
//{
//	ReadyToFire = true;
//}



simulated function PlayFiring()
{
	// Always play the third person sound (which will replicate to clients), if this is
	// a locally controlled pawn the sound won't be heard

	// trigger third-person anims
	Instigator.PlayGrenadeThrowing( );
	
	Super.PlayFiring();
}



simulated function bool HasAmmo()
{
	return true;
}

// Changes weapon modes
function ServerAltFire()
{
	VietnamPawn(Instigator).EndSpawnInvulnerability();

	switch(SpecialWeaponMode)
	{
		case E7M_Slash:
			SpecialWeaponMode = E7M_Stab;
			break;
		case E7M_Stab:
			SpecialWeaponMode = E7M_Slash;
			break;
		case E7M_Attach:
			SpecialWeaponMode = E7M_Slash;
			break;
		case E7M_Attached:
			SpecialWeaponMode = E7M_Detach;
			break;
		case E7M_Detach:
			SpecialWeaponMode = E7M_Attached;
			break;
	}
}

// updates the grenade throw animation used based
// on the current weapon mode
//
// inputs:
// inNewMode - the new weapon mode
//
// outputs:
// -- none --
simulated function UpdateGrenadeThrowAnimation(
	M7FireMode inNewMode )
{
	// set the animation
	if ( Instigator.bIsProne )
	{
		switch( inNewMode )
		{
			case E7M_Slash:
				m_specialGrenadeThrowAnimation =
					M7_PRONE_SLASH_ANIMATION;
				break;
			case E7M_Stab:
			case E7M_Attach:
			case E7M_Attached:
			case E7M_Detach:
			default:
				m_specialGrenadeThrowAnimation =
					M7_PRONE_STAB_ANIMATION;
				break;
		}
	}
	else
	{
		switch( inNewMode )
		{
			case E7M_Slash:
				m_specialGrenadeThrowAnimation =
					M7_SLASH_ANIMATION;
				break;
			case E7M_Stab:
			case E7M_Attach:
			case E7M_Attached:
			case E7M_Detach:
			default:
				m_specialGrenadeThrowAnimation =
					M7_STAB_ANIMATION;
				break;
		}
	}


	// set the aiming bone
	if ( Instigator.bIsProne || !Instigator.bIsCrawl ||
		Instigator.bIsCrouched )
	{
		// crawl, crouch, and prone all use this bone
		m_specialGrenadeThrowBone =	M7_PRONE_THROW_BONE;
	}
	else
	{
		// for standing only
		m_specialGrenadeThrowBone =	M7_THROW_BONE;
	}
}

simulated function AltFire( float Value )
{
	ServerAltFire();
}

// Should be implemented by individual weapons which use bDisplayAmmoType==false
simulated function string GetCurrentWeaponModeName()
{	
	switch(SpecialWeaponMode)
	{
		case E7M_Slash:
			return "Slash";			
			break;
		case E7M_Stab:
			return "Stab";			
			break;
		case E7M_Attach:
			return "Attach";			
			break;
		case E7M_Attached:
			return "Attached";			
			break;
		case E7M_Detach:
			return "Detach";			
			break;
	}
}

// returns the name of the firing animation to play
//
// inputs:
// -- none --
//
// outputs:
// animation name
simulated function Name GetFiringAnimationName( )
{
	if(SpecialWeaponMode == E7M_Stab)
	{
		return 'Attack_B';
	}
	else if(SpecialWeaponMode == E7M_Slash)
	{
		return 'Attack_A';
	}
	else
	{
		return 'Attack_A';
	}
}

function SlashTrace()
{
	TraceFire(0,0,0);
}

function StabTrace()
{
	TraceFire(0,0,0);
}

// This is how this weapon "fires"
function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local vector HitLocation, HitNormal, TraceStart, EndTrace, vForward, vRight, vUp;
	local actor Other;
	local int iHitBone;
	local VietnamPawn tmpPawn;
	local int Damage;

	TraceStart = VietnamPlayerController(Instigator.Controller).CalcFirstPersonViewLocation();

	GetAxes(Instigator.Controller.Rotation, vForward, vRight, vUp);

	EndTrace = TraceStart + vForward * 150;

	// Do the trace
	//		Other = Trace(HitLocation,HitNormal,EndTrace,TraceStart,True, , , iHitBone);
	Other = CustomTrace(TraceStart, EndTrace, TRACEFLAG(STRACE_AllBlocking), HitLocation, HitNormal,,,BLOCKFLAG(SBLOCK_Actors) | BLOCKFLAG(SBLOCK_Players) | BLOCKFLAG(SBLOCK_Bots) | BLOCKFLAG(SBLOCK_World),,);

	if ( VietnamPawn(Other)? )
	{
		tmpPawn = VietnamPawn(Other);
		tmpPawn.LastHitBone = iHitBone;

		if(SpecialWeaponMode == E7M_Stab)
		{
			Damage = 100;
		}
		else if(SpecialWeaponMode == E7M_Slash)
		{
			Damage = 40;
		}

		// If stabbing/beating someone in the back, they take double damage
		// Being behind someone is defined as having less than a 45 degree difference between
		// their yaw and yours
		if(abs(CompareRotationComponent(tmpPawn.Rotation.Yaw,Instigator.Rotation.Yaw)) < 8192)
		{
			Damage *= 2;
		}


		// Bayonet does a ton of damage
		tmpPawn.SpawnBloodEffect(Damage, Instigator, HitLocation, rotator(vForward));
		tmpPawn.TakeDamage(Damage,  Instigator, HitLocation, 30000.0*vForward, WeaponDamageType);	
		tmpPawn.PlaySound(Level.PawnSounds[110]);	// Bayonet stab sound
		
		//TODO:
		// now is a good time to play the melee hit sound
		//ClientPlayRegisteredSound( m_meleeHitSound, 'melee_hit_sound' );
	}
}

// Attach the bayonet to a weapon
function AttachToWeapon()
{
	local Inventory CurrentInventory;
	local VietnamWeapon CurrentWeapon;

	// Find a weapon in the player's inventory that can take a bayonet
	// Then set the bAttachingBayonet = true for that weapon
	// Then change to that weapon
	for(CurrentInventory = Owner.Inventory; CurrentInventory?; CurrentInventory = CurrentInventory.Inventory)
	{
		CurrentWeapon = VietnamWeapon(CurrentInventory);
		if(CurrentWeapon?)
		{
			if(CurrentWeapon.bCanUseBayonet)
			{
				CurrentWeapon.bAttachingBayonet = true;
				PlayerController(Instigator.Controller).SwitchWeapon(CurrentWeapon.InventoryGroup);
				SpecialWeaponMode = E7M_Attached;
				Slave = CurrentWeapon;
				break;
			}
		}
	}
}

State DownWeapon
{
	simulated function BeginState()
	{
		bChangeWeapon = false;
		bMuzzleFlash = false;

		if(!(Slave?))
			TweenDown();
		else
			Pawn(Owner).ChangedWeapon();
	}
}

// overridden:  has special putaway animations
//
// inputs:
// -- none --
//
// outputs:
// name of the animation to play
simulated function Name GetPutAwayAnimationName( )
{
	if ( FRand( ) > 0.5 )
	{
		return 'putaway';
	}
	// else....
	
	return 'putaway_alternate';
}

state NormalFire
{
	// overloaded:  plays the slash noise
	// for each knife swing or stab
	//
	// inputs:
	// -- none --
	//
	// outputs:
	// -- none -- (code segment?)
	simulated function LocalFire( )
	{
		Super.LocalFire( );
		
		//if ( SpecialWeaponMode != E7M_Stab )
		//{
		//	// trigger the melee attack sound
		//	ClientPlayRegisteredSound( MELEE_SWING_SOUND, 'melee_swing' );
		//}
	}

	simulated function AnimEnd(int Channel)
	{
		local name CompletedAnim, NewAnim;
		local float Dummy1, Dummy2;

		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			// If the M7 is stabbing, we want it to play a stab-hit or stab-miss anim
			// before returning to normal

			GetAnimParams( Channel, CompletedAnim, Dummy1, Dummy2 );

			if(CompletedAnim == 'Attack_B')	// Stab
			{
				PlayAnim( 'Attack_B_miss',
					1.0, 0.0,
					FIRING_ANIMATION_CHANNEL );
				AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
					, , , , WEAPON_ACTION_TWEEN_TIME,
					WEAPON_ACTION_TWEEN_TIME, );
			}
			else 
				Super.AnimEnd(Channel);
		}
	}
}

// overloaded:  sets the grenade throw and aim
// bone before calling the parent version
//
// inputs:
// outAnimInfo - the data structure to set
//
// outputs:
// true if structure set properly, false otherwise
simulated function Bool GetSpecialGrenadeThrowAnimation(
	out AnimInfo outAnimInfo )
{
	// change the grenade throwing animation to
	// match the current weapon state
	UpdateGrenadeThrowAnimation( SpecialWeaponMode );

	return Super.GetSpecialGrenadeThrowAnimation( outAnimInfo );
}

// Can't reload a knife
simulated function bool CanReload()
{
	return false;
}

// M7 doesn't count as firing a shot
function CheckIncrementShotsFiredStat(optional bool bDontCheck)
{
}

// M7 is always semi-auto
simulated function bool IsSemiAuto()
{
	return true;
}

defaultproperties
{
     PlayerCrouchViewOffset=(X=5.000000,Y=1.300000,Z=-14.350000)
     PlayerAimViewOffset=(X=5.000000,Y=1.300000,Z=-14.350000)
     Magnification=1.000000
     Accuracy=0.000000
     Recoil=0.000000
     m_maximumRecoil=0.000000
     Damage=75.000000
     WeaponDamageType=Class'VietnamGame.DamageBullet'
     PrecisionAimTransitionTime=0.200000
     DelayAfterFire=0.700000
     CrosshairNoShoot=Texture'Interface_tex.HUD.reticle_noshoot_tex'
     SecondaryCrosshair=Texture'Interface_tex.HUD.reticlering_tex'
     WeaponGrip=EWG_Knife
     WeaponMode=EWM_Special
     AutoFireSpeed=1.000000
     SemiAutoSpeed=1.000000
     m_fViewPitchKick=0.000000
     m_fViewDegradeYaw=0.000000
     m_fViewDegradePitch=0.000000
     m_fViewKickMaxYawDelta=0.000000
     m_fViewKickMaxPitchDelta=0.000000
     MinTurnRateScale=0.550000
     TurnRateRampPower=10.000000
     AimAssistAngle=20.000000
     MinPrecisionTurnRateScale=0.350000
     PrecisionTurnRateRampPower=10.000000
     PrecisionAimAssistAngle=10.000000
     MinScreenPercent=0.000050
     fCriticalHitPercent=0.300000
     MultiplayerDamage=75.000000
     m_meleeHitSound="M7CutFlesh"
     m_melee3DHitSound="M7CutFlesh3D"
     bCanUseRedCrosshair=False
     AutoSwitchPriority=7
     ShakeMag=0.000000
     ShakeVert=(Z=0.000000)
     MeshName="USMC_ViewModels.fps_m7_bayonet"
     InventoryGroup=14
     PickupType="PickupM7"
     PlayerViewOffset=(X=5.000000,Y=1.300000,Z=-14.350000)
     PlayerHorizSplitViewOffset=(X=5.000000,Y=1.300000,Z=-14.350000)
     PlayerVertSplitViewOffset=(X=5.000000,Y=1.300000,Z=-14.350000)
     ThirdPersonRelativeLocation=(X=9.000000,Y=-5.000000,Z=10.000000)
     ThirdPersonRelativeRotation=(Roll=16384)
     AttachmentClass=Class'VietnamWeapons.WeaponM7Attachment'
     ItemName="M7"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
