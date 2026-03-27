//===============================================================================
//  [ WeaponAutomaticPistol ]
// Base class for automatic pistols
// Firing modes:
//	semi-auto
//===============================================================================

class WeaponAutomaticPistol extends VietnamWeapon
	abstract;

var bool			bSlideOpen;			// True = slide is open
										// False = slide is closed

// overloaded:  has a special "open slide" state
//
// inputs:
// -- none --
//
// outputs:
// animation Name
Simulated Function Name GetIdleAnimationName( )
{
	if( bSlideOpen == true )
	{
		return 'idle_slide_open';
	}
	// else....
	
	return Super.GetIdleAnimationName( );
}

// overloaded:  returns a different name if
// the gun is empty
//
// inputs:
// -- none --
//
// outputs:
// animation name
simulated function Name GetFiringAnimationName( )
{
	// this wacky bit of logic needed to counter
	// the replicated ReloadCount logic on clients
	// (when this function is called, the reload
	// count lags behind the server by 1 bullet)
	if
	(
		ReloadCount == 0
		||
		(
			Level.NetMode == NM_Client
			&&
			ReloadCount == 1
		)
	 )
	{
		// flag the slide to be open
		bSlideOpen = true;
		return 'Fire_empty';
	}
	// else....

	return Super.GetFiringAnimationName( );
}

state Reloading
{
	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			bSlideOpen = false;

			Super.AnimEnd(Channel);
		}
	}
}

simulated function PlayReloading()
{
	local PlayerController PController;
	local Float            frames, rate;

	PController = PlayerController(Instigator.Controller);
	if(PController?)
		PController.ClientPlaySound(WeaponSounds[EWeaponSound.EWS_Reload]);

	if(UseAnimTimer())
		WeaponAnimTimer(WeapAnim_Reload, FIRING_ANIMATION_CHANNEL, 1.0);
	else
	{
		if(ReloadCount != 0)
		{
			PlayAnim('Reload_full', GetReloadAnimationRate( ), 0.05,
				FIRING_ANIMATION_CHANNEL );	// Reload, slide closed

			GetAnimSequenceParams( 'Reload_full', frames, rate );
		}
		else if(bSlideOpen == true)
		{
			PlayAnim('Reload', GetReloadAnimationRate( ), 0.05,
				FIRING_ANIMATION_CHANNEL );		// Reload, slide open, chamber round

			GetAnimSequenceParams( 'Reload', frames, rate );
		}
		else
		{
			PlayAnim('Reload_empty_clip', GetReloadAnimationRate( ), 0.05,
				FIRING_ANIMATION_CHANNEL);	// Reload, slide closed, chamber round

			GetAnimSequenceParams( 'Reload_empty_clip', frames, rate );
		}
		AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
			, , , , WEAPON_RELOAD_TWEEN_TIME,
			WEAPON_RELOAD_TWEEN_TIME, );
	}

	// third person anims
	Instigator.PlayReload( frames / rate, GetReloadAnimationRate( ) );
}

state DownWeapon
{
	simulated function HandlePutdown()
	{
		if(ReloadCount == 0 && bSlideOpen == true)
		{
			GotoState('SlideRelease');
		}
		else
			TweenDown();
	}
}

// plays the slide release animation
// on the FIRING_ANIMATION_CHANNEL
//
// inputs:
// -- none --
//
// outputs:
// -- none -- (code segment)
simulated function PlaySlideReleaseAnimation( )
{
	PlayAnim('slide_release', 1.0, 0.05,
		FIRING_ANIMATION_CHANNEL );	// Close the slide
	AnimBlendParams( FIRING_ANIMATION_CHANNEL, 1.0f,
		, , , , WEAPON_ACTION_TWEEN_TIME,
		WEAPON_ACTION_TWEEN_TIME, );
}

state SlideRelease
{
	ignores Fire, AltFire, ForceReload;

	simulated function BeginState()
	{
		PlaySlideReleaseAnimation( );
	}

	simulated function AnimEnd(int Channel)
	{
		if ( Channel == FIRING_ANIMATION_CHANNEL )
		{
			bSlideOpen = false;
			GotoState('DownWeapon');
		}
	}
}

// Should be implemented by individual weapons which use bDisplayAmmoType==false
simulated function string GetCurrentWeaponModeName()
{
	return SemiAutoString;
}

// overloaded:  returns a different animation for
// the initial takeout only
//
// inputs:
// -- none --
//
// outputs:
// name of the animation to play
simulated function Name ResolveTakeoutAnimation( )
{
	// pistols have a special initial takeout
	// animation
	if ( bFirstTimeUsed )
	{
		return 'takeout_firstime';
	}
	// else....
	
	return Super.ResolveTakeoutAnimation( );
}

// overloaded:  close the slide if melee attacks are made
state Melee
{
	// overloaded:  closes the slide if a melee attack is made
	//
	// inputs:
	// -- none --
	//
	// outputs:
	// -- none -- (UnReal event)
	simulated function BeginState( )
	{
		// if the slide is open, play the
		// slide release animation
		if ( bSlideOpen )
		{
			PlaySlideReleaseAnimation( );
			ReadyToFire = false;
		}
		else
		{
			// do the parent tasks first
			Super.BeginState( );
		}
	}
	
	// overloaded:  responds to a closing slide
	//
	// inputs:
	// inChannel - that stopped
	//
	// outputs:
	// -- none --
	simulated function AnimEnd( Int inChannel )
	{
		if ( bSlideOpen && 
			inChannel == FIRING_ANIMATION_CHANNEL )
		{
			// signal that the slide is closed
			bSlideOpen = false;
			
			// now start the melee attack animations
			PlayMeleeAttackAnimation( );
			Instigator.PlayMeleeAttackAnimation( );
			
			// and play the swing noise
			//ClientPlayRegisteredSound( MELEE_SWING_SOUND, 'melee_swing' );
		}
		else
		{
			// let the parent method handle it
			Super.AnimEnd( inChannel );
		}
	}
}

defaultproperties
{
     Magnification=1.100000
     Accuracy=0.000000
     Recoil=100.000000
     WeaponGrip=EWG_OneHanded
     WeaponSoundNames(2)=(PackageName="weapon_snd",ResourceName="PistolUnEquip")
     WeaponSoundNames(3)=(PackageName="weapon_snd",ResourceName="PistolEquip")
     MHEType=EMHE_Small
     m_pawnTakeoutAnimation="OH_AB_takeout"
     m_pawnStowAnimation="oh_ab_putaway"
     m_pawnProneTakeoutAnimation="OH_Pr_takeout"
     m_pawnProneStowAnimation="OH_Pr_Putaway"
     MaxRange=3000.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
