//////////////////////////////////////////////////////////////////////////////
//	File:	TurretMinigun.uc
//
//	Description	:	This is a mountable minigun
//----------------------------------------------------------------------------
class TurretMinigun extends ConsolidatedTurret
	placeable;

#exec OBJ LOAD FILE="..\Textures\Interface_tex.utx" PACKAGE=Interface_tex

var() float TimeTillNextShot;
var float TimeTillNextShotCounter;

var bool bPlayingFireSound;

var float TimeTillNextFireSound;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Make the muzzle flashes significantly smaller since it's hard to see
	MF.MinScale = 0.4;
	MF.MaxScale = 0.6;
}

// The player using this turret has pressed the fire button
function Fire()
{
	local VietnamPlayerController VPController;

	if ( bAutoTurret == true )
	{
		if(!bAnimBasedAiming)
			LoopAnim('Fire_start', 1.0, 0.0, 0);

		TraceFire();
		MF.Flash();
		if(!bPlayingFireSound)
		{
			bPlayingFireSound = true;
			SetDelegateTimer('PlayFireSound', default.TimeTillNextFireSound, true);
		//	PlaySound(FireSound,,,,1000,,true,true);
		}

		CurrentRecoil += Recoil;
	}
	else
	{
		// For stats tracking
		VPController = VietnamPlayerController(User);
		if(VPController?)
			VPController.PlayerReplicationInfo.iShotsFired++;

		// bNoOverrride must be true for this to always play in the helo on op1_l3a
		if(!bPlayingFireSound)
		{
			bPlayingFireSound = true;
			SetDelegateTimer('PlayFireSound', default.TimeTillNextFireSound, true);
		//	PlaySound(FireSound,,,,1000,,true,true);
		}

		TraceFire();

		CurrentRecoil += Recoil;

		//		ShellEject.UpdateShellEjectLocation(GetBoneCoords('tag_eject').Origin, GetBoneRotation('tag_eject'));
		if(ShellEject?)
			ShellEject.SpawnParticle(1);
		MF.Flash();

		GotoState('NormalFire');
	}
}

// Timer function to play the fire sound
function PlayFireSound()
{
	local VietnamPlayerController VPController;

	// For stats tracking
	VPController = VietnamPlayerController(User);

	if( VPController.IsInstancePlaying( FPFireVoices[FPFireVoiceIndex] ) )
	{
		VPController.ClientStopRegisteredSound( FPFireVoices[FPFireVoiceIndex] );
	}
	VPController.ClientPlayRegisteredSound(TurretSoundNames[ETurretSound.ETS_FPFire].ResourceName,FPFireVoices[FPFireVoiceIndex]);

	FPFireVoiceIndex++;
	if(FPFireVoiceIndex == ArrayCount(FPFireVoices))
		FPFireVoiceIndex = 0;

	Instigator.RemoteStopRegisteredSound( TPFireVoices[TPFireVoiceIndex] );
	Instigator.RemotePlayRegisteredSound(TurretSoundNames[ETurretSound.ETS_TPFire].ResourceName, TPFireVoices[TPFireVoiceIndex]);

	TPFireVoiceIndex++;
	if(TPFireVoiceIndex == ArrayCount(TPFireVoices))
		TPFireVoiceIndex = 0;


	TimeTillNextFireSound += default.TimeTillNextFireSound;
}

state NormalFire
{
	function BeginState()
	{
		local float AnimFrameCount, AnimRate;

		if(bAnimBasedAiming)
		{
			GetAnimSequenceParams(StartFireAnim, AnimFrameCount, AnimRate );

			SetTimer(AnimFrameCount/AnimRate,false);
		}
		else
			PlayFiringAnimation(StartFireAnim);
	}

	function Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		// Fire as many shots as appropriate this tick
		while(TimeTillNextShotCounter <= 0.0)
		{
			Global.Fire();
			TimeTillNextShotCounter += TimeTillNextShot;
		}

			TimeTillNextShotCounter -= DeltaTime;
	}

	function AnimEnd(int Channel)
	{
		if(!UserWantsToFire())
			GotoState('FireEnd');
		else
			BeginState();
	}	
}

state FireEnd
{
	function Fire()
	{
		Global.Fire();
	}

	function AnimEnd(int Channel)
	{
		GotoState('Idle');
	}

	function BeginState()
	{
		local float AnimFrameCount, AnimRate;

		//StopSound(self,FireSound);
		SetDelegateTimer('PlayFireSound', 0.0);
		bPlayingFireSound = false;

		if(bAnimBasedAiming)
		{
			GetAnimSequenceParams(EndFireAnim, AnimFrameCount, AnimRate );

			SetTimer(AnimFrameCount/AnimRate,false);
		}
		else
			PlayAnim(EndFireAnim,1.0,0.0);
	}
}

function PlayFiringAnimation(name Animation)
{
	LoopAnim(Animation, 1.0, 0.00);
//	if(User? && PlayerController(User)?)
//	{
//		PlayerController(User).PlayForceFeedbackEffect("Fire gun", 2);
//		PlayerController(User).ConfigureForceFeedbackChannel(2, true);
//	}
}

defaultproperties
{
     TimeTillNextShot=0.033300
     TimeTillNextFireSound=0.100000
     AimUpAnimation="Tur_Huey_Down_Up"
     AimDownAnimation="Tur_Huey_Right_Left"
     AimLeftAnimation="Tur_Huey_Diagonal_Left"
     AimRightAnimation="Tur_Huey_Diagonal_right"
     MaxReticuleSize=500.000000
     iBurstAmount=999
     iBurstVariance=5
     fPauseBetweenBursts=2.500000
     fPauseVariance=0.000000
     MaxRange=5000.000000
     Damage=100.000000
     ProjectileClass=Class'VietnamWeapons.ProjectileRPG7'
     BaseAccuracy=25.000000
     MFClass=MF_50Cal
     ShellEjectType=3
     MeshName="USMC_Viewmodels.turret_minigun"
     MuzzleBone="tag_muzzle"
     ShellEjectBone="tag_eject"
     StartFireAnim="Fire_start"
     EndFireAnim="fire_end"
     iRoundsPerSecond=30
     TurretSoundNames(0)=(PackageName="weapon_snd",ResourceName="M60Outdoor")
     TurretSoundNames(1)=(PackageName="weapon_snd",ResourceName="M60NP")
     m_fViewYawKick=200.000000
     m_fViewPitchKick=200.000000
     m_fViewDegradeYaw=1536.000000
     m_fViewDegradePitch=1536.000000
     m_fViewKickMaxYawDelta=200.000000
     m_fViewKickMaxPitchDelta=200.000000
     m_painAnimations(0)="SCR_AB_Tur_center_pain"
     m_painAnimations(1)="SCR_AB_Tur_center_pain2"
     m_crouchingPainAnimations(0)="SCR_CR_Tur_center_pain"
     m_crouchingPainAnimations(1)="SCR_CR_Tur_center_pain2"
     bBlockNonZeroExtentTraces=False
     CollisionRadius=30.000000
     CollisionHeight=20.000000
     m_arrEventStates(0)="LostTarget"
     m_arrEventStates(1)="FoundTarget"
     m_arrEventStates(2)="used"
}
