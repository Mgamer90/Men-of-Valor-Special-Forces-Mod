//////////////////////////////////////////////////////////////////////////////
//	File:	USMC_Marine_Support_Bot.uc
//
//	Description	: Heal and resuply the player
//----------------------------------------------------------------------------
class USMC_Marine_Support_Bot extends VietnamMedicBot;

var VietnamAmmo m_pMedicPatientAmmo;
var float m_medicPreviousRefillingTime;

var int m_RefillingCount; // max of requests
var int m_ReserveAmmo;
var int m_DroppedAmount;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	m_RefillingCount = class'ModRepositoryConfig'.default.m_RefillingCount;
	m_ReserveAmmo = class'ModRepositoryConfig'.default.m_ReserveAmmo;
	m_DroppedAmount = class'ModRepositoryConfig'.default.m_DroppedAmount;

	//Level.Game.Broadcast(Self, "m_RefillingCount "$m_RefillingCount, 'Say');
	//Level.Game.Broadcast(Self, "m_ReserveAmmo "$m_ReserveAmmo, 'Say');
	//Level.Game.Broadcast(Self, "m_DroppedAmount "$m_DroppedAmount, 'Say');
}

// entry point for healing new patient
// - called from normal ai checks, and also from player "use"
// - player can usurp ai acquired patient
function MedicCheckPatient(VietnamPawn pVPawn)
{
	local VietnamAmmo NamAmmo;
	local VietnamWeapon NamWeapon;
	local VietnamWeaponPickup NamWeaponPickup;
	local PickupHealth NamCanteenPickup;
	local PickupHealth NamHealthPickup;
	local PickupAmmo NamPickupAmmo;
	local PickupAmmo NamPickupAmmoHandgun;
	local int NamDroppedAmount;

	/*if (
		VietnamMedicBot(Controller).IsInState('MedicHealingPlayer') ||
		VietnamMedicBot(Controller).IsInState('MedicMoveToPatient') ||
		VietnamMedicBot(Controller).IsInState('MedicHealingPatient') ||
		VietnamMedicBot(Controller).IsInState('AttendWounded') ||
		VietnamMedicBot(Controller).IsInState('HealAtCover')
	)
		return;*/

	if (pVPawn != None && m_pMedicPatient == None)
	{
		Comment("Acquired new patient"@pvPawn);
		m_pMedicPatient = pVPawn;

		if (m_pMedicPatient.Health < 100)
		{
			if ( SoundSet? ) NoThrottleBattleChatter(SoundSet.ConsolingInjured, 0 );
			//SwitchState('DropItemToPlayer',,true);

			if (m_pMedicPatient.Health > 75)
			{
				NamCanteenPickup = Spawn(class'Canteen',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
			}
			else
			{
				NamCanteenPickup = Spawn(class'MedicKit',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
				NamHealthPickup = Spawn(class'MedicKit',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
			}

			Level.Game.Broadcast(Self, "Medic Kit requested by "$pVPawn.GetHumanReadableName(), 'Say');
			//Level.Game.Broadcast(Self, "Medic used by "$pVPawn.GetHumanReadableName(), 'Say');
		}
		else if(m_ReserveAmmo <= 0)
		{
			if ( SoundSet? ) NoThrottleBattleChatter(SoundSet.Orders_Rejected, 0 );

			Level.Game.Broadcast(Self, "I don't have extra ammo!", 'Say');
		}
		else if (m_ReserveAmmo > 0)
		{
			NamWeapon = VietnamWeapon(m_pMedicPatient.Weapon);

			if(NamWeapon != None)
			{
				m_pMedicPatientAmmo = VietnamAmmo(NamWeapon.AmmoType);

				if( NamWeapon.IsA('WeaponBaseGrenade') )
				{
					//NamWeaponPickup = Spawn(class'PickupFragGrenade',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
					NamPickupAmmo = None;
					if ( SoundSet? ) NoThrottleBattleChatter(SoundSet.Orders_Rejected, 0 );

					Level.Game.Broadcast(Self, "I can't help you!", 'Say');

				} else 
				if( m_pMedicPatientAmmo != None && m_pMedicPatientAmmo.AmmoAmount < m_pMedicPatientAmmo.MaxAmmo )
				{
					if( m_pMedicPatientAmmo.IsA('Ammo45Cal') )
					{
						NamPickupAmmo = Spawn(class'PickupAmmo45Cal',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
						NamDroppedAmount = class'PickupAmmo45Cal'.default.AmmoAmount;
						//NamPickupAmmoHandgun = Spawn(class'PickupAmmo45Cal',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
					}
					else if( m_pMedicPatientAmmo.IsA('Ammo556NATO') )
					{
						NamPickupAmmo = Spawn(class'PickupAmmo556NATO',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
						NamDroppedAmount = class'PickupAmmo556NATO'.default.AmmoAmount;
						//NamPickupAmmoHandgun = Spawn(class'PickupAmmo45Cal',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
					}
					else if( m_pMedicPatientAmmo.IsA('Ammo762NATO') )
					{
						NamPickupAmmo = Spawn(class'PickupAmmo762NATO',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
						NamDroppedAmount = class'PickupAmmo762NATO'.default.AmmoAmount;
						//NamPickupAmmoHandgun = Spawn(class'PickupAmmo45Cal',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
					}
					else if( m_pMedicPatientAmmo.IsA('Ammo762NATOBeltFed') )
					{
						NamPickupAmmo = Spawn(class'PickupAmmo762NATOBeltFed',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
						NamDroppedAmount = class'PickupAmmo762NATOBeltFed'.default.AmmoAmount;
						//NamPickupAmmoHandgun = Spawn(class'PickupAmmo45Cal',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
					}
					else if( m_pMedicPatientAmmo.IsA('AmmoM21') )
					{
						NamPickupAmmo = Spawn(class'PickupAmmoM21',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
						NamDroppedAmount = class'PickupAmmoM21'.default.AmmoAmount;
						//NamPickupAmmoHandgun = Spawn(class'PickupAmmoM21',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
					}
					else if( m_pMedicPatientAmmo.IsA('AmmoM67') )
					{
						NamPickupAmmo = Spawn(class'PickupAmmoM67',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
						NamDroppedAmount = class'PickupAmmoM67'.default.AmmoAmount;
					}
					else if( m_pMedicPatientAmmo.IsA('AmmoM79Buckshot') )
					{
						NamPickupAmmo = Spawn(class'PickupAmmoM79Buckshot',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
						NamDroppedAmount = class'PickupAmmoM79Buckshot'.default.AmmoAmount;
					}
					else if( m_pMedicPatientAmmo.IsA('AmmoM79FragGrenade') )
					{
						NamPickupAmmo = Spawn(class'PickupAmmoM79Frag',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
						NamDroppedAmount = class'PickupAmmoM79Frag'.default.AmmoAmount;
					}
					else if( m_pMedicPatientAmmo.IsA('AmmoM79Flare') )
					{
						NamPickupAmmo = Spawn(class'PickupAmmoM79Flare',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
						NamDroppedAmount = class'PickupAmmoM79Flare'.default.AmmoAmount;
					}
					else if( m_pMedicPatientAmmo.IsA('AmmoM79TearGas') )
					{
						NamPickupAmmo = Spawn(class'PickupAmmoM79TearGas',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
						NamDroppedAmount = class'PickupAmmoM79TearGas'.default.AmmoAmount;
					}
					else if( Pawn.IsA('VC_Army') && m_pMedicPatientAmmo.IsA('Ammo762WP') )
					{
						NamPickupAmmo = Spawn(class'PickupAmmo762WP',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
						NamDroppedAmount = class'PickupAmmo762WP'.default.AmmoAmount;
					}
					else if( Pawn.IsA('VC_Army') && m_pMedicPatientAmmo.IsA('AmmoRPG7') )
					{
						NamPickupAmmo = Spawn(class'PickupAmmoRPG7',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);
						NamDroppedAmount = class'PickupAmmoRPG7'.default.AmmoAmount;
					}
					else
					{
						if ( SoundSet? ) NoThrottleBattleChatter(SoundSet.Orders_Rejected, 0 );

						Level.Game.Broadcast(Self, "I don't have enemy ammo!", 'Say');

						m_pMedicPatient = None;
						m_pMedicPatientAmmo = None;

						return;
					}


						if ( SoundSet? ) NoThrottleBattleChatter(SoundSet.Orders_Accepted, 0 );
						//SwitchState('DropItemToPlayer',,true);

						m_ReserveAmmo = (m_ReserveAmmo - NamDroppedAmount);

						Level.Game.Broadcast(Self, m_pMedicPatientAmmo.GetHumanReadableName()$ " requested by "$pVPawn.GetHumanReadableName(), 'Say');

				}
				else
				{
					if ( SoundSet? ) NoThrottleBattleChatter(SoundSet.PissedAtPlayer, 0 );

					Level.Game.Broadcast(Self, "You can't carry more ammo!", 'Say');
				}
			}
			else
			{
				if ( SoundSet? ) NoThrottleBattleChatter(SoundSet.Laughing, 0 );
				
				//Level.Game.Broadcast(Self, "You can't carry more ammo!", 'Say');
			}
		}
	}

	m_pMedicPatient = None;
	m_pMedicPatientAmmo = None;

	if(m_ReserveAmmo < 0)
		m_ReserveAmmo = 0;
}

function MedicCheckPatient_alt(VietnamPawn pVPawn)
{
	local VietnamAmmo NamAmmo;
	local VietnamWeapon NamWeapon;
	local PickupHealth NamHealthPickup;

	if (pVPawn != None && m_pMedicPatient == None)
	{
		Comment("Acquired new patient"@pvPawn);
		m_pMedicPatient = pVPawn;

		//NamHealthPickup = Spawn(class'MedicKit',Pawn,'',Pawn.GetBoneCoords('bip_LFoot').origin);

		NamWeapon = VietnamWeapon(m_pMedicPatient.Weapon);

		if(
			NamWeapon != None &&
			(
				NamWeapon.IsA('WeaponM1') ||
				NamWeapon.IsA('WeaponM14') ||
				NamWeapon.IsA('WeaponM16') ||
				NamWeapon.IsA('WeaponCAR15') ||
				NamWeapon.IsA('WeaponM21') ||
				NamWeapon.IsA('WeaponM60') ||
				NamWeapon.IsA('WeaponM79') ||
				NamWeapon.IsA('WeaponM67') ||
				NamWeapon.IsA('WeaponM7') ||
				NamWeapon.IsA('WeaponM1911') ||
				NamWeapon.IsA('WeaponM1911S') ||
				NamWeapon.IsA('WeaponM1Commander') ||
				NamWeapon.IsA('WeaponCAR15Jamie')
			)
		)
		{
			m_pMedicPatientAmmo = VietnamAmmo(NamWeapon.AmmoType);
		}
		else
		{
			m_pMedicPatientAmmo = None;
		}

		/*if ( m_pMedicPatient != none && DistanceSq( m_pMedicPatient, Pawn ) > 350000 )
		{
			SwitchState('MedicMoveToPlayer',,true);
		}
		else
		{
			SwitchState('MedicHelpingPlayer',,true);
		}
			Level.PlayBattleChatter( aPawn, SoundSet.Killed, 0 );*/
		
		if ( SoundSet? ) NoThrottleBattleChatter(SoundSet.ConsolingInjured, 0 );
		SwitchState('MedicHelpingPlayer',,true);
		

		//Level.Game.Broadcast(Self, "Medic used by "$pVPawn.GetHumanReadableName(), 'Say');
	}
}

// clears existing behaviors, assign new ones based upon AIParams
function SetupBehaviors()
{
	local class<AIBehavior> medicBehavior;

	log("Extending SetupBehaviors()");
	Super.SetupBehaviors();

	ClearBehaviorClass(class'AIBehaviorMedic');

	/*log("Adding VietnamAI.AIBehaviorMedic");
	medicBehavior = class<AIBehavior>(DynamicLoadObject("VietnamAI.AIBehaviorMedic",class'class'));
	ApplyBehavior( medicBehavior );*/
}

state MedicMoveToPatient
{

Begin:
	// if (!m_pMedicPatient)
	if (m_pMedicPatient == None)
	{
		Comment("No patient to heal in"@GetStateName(),CMT_WARN);
		Sleep();
	}

MoveToPatient:
	// check to see if we're close enough to our load patient
		// traverse if necessary
		SetMoveType(EMT_Run);
		SetTraversalInfo(TraversalConstructor(m_pMedicPatient,,3.0));
		ApplyTask(TaskConstructor('PatientTraverse','Traversing','None',true,'MedicMoveToPatient','StartHealing',false));

StartHealing:
	// face direction goal point is pointing
	SetFocus(m_pMedicPatient,,);

	//Pawn.LoopAnim( 'Medic_Helping', 1.0, 0.0, VietnamPawn( Pawn ).HPMOTIONCHANNEL);
	Pawn.LoopAnim( 'TH_AB_reloadtap_act', 1.0, 0.0, VietnamPawn( Pawn ).HPMOTIONCHANNEL);
	Pawn.AnimBlendParams( VietnamPawn( Pawn ).HPMOTIONCHANNEL, 1.0, 0.0, 0.0);
	m_medicPreviousHealingTime = Level.TimeSeconds;

	SwitchState('MedicHealingPatient',,true);
}

state MedicHealingPatient
{
	function EndState()
	{
		StopAnimation(Pawn.HPMOTIONCHANNEL,true);
	}

Begin:
	MarkLabel('Begin');

Healing:
	MarkLabel('Healing');
	// Keep healing until health is 100% or patient moves away
	if ( DistanceSq( m_pMedicPatient, Pawn ) < 350000 )
	{
		if (m_pMedicPatient.RemainingBleedingDamage?)
		{
			// heal bleeding damage first
			m_pMedicPatient.RemainingBleedingDamage -= 2;
			m_medicPreviousHealingTime = Level.TimeSeconds;
		}
		else
		{
			m_pMedicPatient.Health = Clamp(m_pMedicPatient.Health+10*(Level.TimeSeconds-m_medicPreviousHealingTime),0,100);
			if (m_pMedicPatient.Health >= 100)
			{
				Goto('Finished');
			}
			else
			{
				m_medicPreviousHealingTime = Level.TimeSeconds;
			}			
		}
	}
	else
	{
		Goto('Finished');
	}
	Sleep(0.15f);
	Goto('Healing');

Finished:
	MarkLabel('Finished');
	m_pMedicPatient = None;
	EvaluateSituation();
	Stop;
}

state MedicMoveToPlayer
{

Begin:
	// if (!m_pMedicPatient)
	if (m_pMedicPatient == None)
	{
		Comment("No patient to heal in"@GetStateName(),CMT_WARN);
		Sleep();
	}

MoveToPatient:
	// check to see if we're close enough to our load patient
		// traverse if necessary
		SetMoveType(EMT_Run);
		SetTraversalInfo(TraversalConstructor(m_pMedicPatient,,3.0));
		ApplyTask(TaskConstructor('PatientTraverse','Traversing','None',true,'MedicMoveToPatient','StartHealing',false));

StartHealing:
	// face direction goal point is pointing
	SetFocus(m_pMedicPatient,,);

	//Pawn.LoopAnim( 'Medic_Helping', 1.0, 0.0, VietnamPawn( Pawn ).HPMOTIONCHANNEL);
	/*Pawn.LoopAnim( 'TH_AB_reloadtap_act', 1.0, 0.0, VietnamPawn( Pawn ).HPMOTIONCHANNEL);
	Pawn.AnimBlendParams( VietnamPawn( Pawn ).HPMOTIONCHANNEL, 1.0, 0.0, 0.0);
	m_medicPreviousHealingTime = Level.TimeSeconds;*/

	SwitchState('MedicHealingPlayer',,true);
}

state MedicHelpingPlayer
{
	function EndState()
	{
		StopAnimation(Pawn.HPMOTIONCHANNEL,true);
	}

Begin:
	MarkLabel('Begin');

	//Pawn.LoopAnim( 'TH_Bo_guard', 1.0, 0.0, VietnamPawn( Pawn ).HPMOTIONCHANNEL);
	Pawn.LoopAnim( 'Gr_Ab_throw_underhand', 1.0, 0.0, VietnamPawn( Pawn ).HPMOTIONCHANNEL);
	//Pawn.LoopAnim( 'TH_Cr_toss_satchel', 1.0, 0.0, VietnamPawn( Pawn ).HPMOTIONCHANNEL);
	Pawn.AnimBlendParams( VietnamPawn( Pawn ).HPMOTIONCHANNEL, 1.0, 0.0, 0.0);
	m_medicPreviousHealingTime = Level.TimeSeconds;

Healing:
	MarkLabel('Healing');

	if ( m_pMedicPatient != none && DistanceSq( m_pMedicPatient, Pawn ) < 350000 )
	{
		// Keep healing until health is 100% or patient moves away
		if (m_pMedicPatient.Health < 100)
		{
			if (m_pMedicPatient.RemainingBleedingDamage?)
			{
				// heal bleeding damage first
				// m_pMedicPatient.RemainingBleedingDamage -= 2;
				m_pMedicPatient.RemainingBleedingDamage = 0;
				m_medicPreviousHealingTime = Level.TimeSeconds;

				Sleep(0.15f);
				Goto('Healing');
			}
			else
			{
				m_pMedicPatient.Health = Clamp(m_pMedicPatient.Health+10*(Level.TimeSeconds-m_medicPreviousHealingTime),0,100);

				if (m_pMedicPatient.Health >= 100)
				{
					Level.Game.Broadcast(Self, "Medic used by "$m_pMedicPatient.GetHumanReadableName(), 'Say');
					Goto('Finished');
				}
				else
				{
					m_medicPreviousHealingTime = Level.TimeSeconds;
					Sleep(0.15f);
					Goto('Healing');
				}
			}
		}
		// Keep Refilling until MaxAmmo
		else if ( /*m_RefillingCount > 0 &&*/ m_pMedicPatientAmmo != None && m_pMedicPatientAmmo.AmmoAmount < m_pMedicPatientAmmo.MaxAmmo )
		{
			if ( DistanceSq( m_pMedicPatient, Pawn ) < 350000 )
			{
				if (m_pMedicPatientAmmo.AmmoAmount + 10 >= m_pMedicPatientAmmo.MaxAmmo)
				{
					m_pMedicPatientAmmo.AmmoAmount = m_pMedicPatientAmmo.MaxAmmo;
				}
				else
				{
					m_pMedicPatientAmmo.AmmoAmount += 10;
				}

				//m_pMedicPatientAmmo.AmmoAmount += m_pMedicPatientAmmo.PickupAmmo;
				//m_pMedicPatientAmmo.AmmoAmount = Clamp(m_pMedicPatientAmmo.AmmoAmount+10*(Level.TimeSeconds-m_medicPreviousRefillingTime),0,m_pMedicPatientAmmo.MaxAmmo);

				if (m_pMedicPatientAmmo.AmmoAmount >= m_pMedicPatientAmmo.MaxAmmo)
				{
					Level.Game.Broadcast(Self, "Refill Ammo used by "$m_pMedicPatient.GetHumanReadableName(), 'Say');

					if ( m_RefillingCount > 0 )
						m_RefillingCount--;

					Goto('Finished');
				}
				else
				{
					m_medicPreviousHealingTime = Level.TimeSeconds;
					Sleep(0.15f);
					Goto('Healing');
				}
			}
		}
	}

Finished:
	MarkLabel('Finished');
	m_pMedicPatient = None;
	m_pMedicPatientAmmo = None;
	StopAnimation(Pawn.HPMOTIONCHANNEL,true);
	EvaluateSituation();
	Stop;
}

state DropItemToPlayer
{
	function EndState()
	{
		StopAnimation(Pawn.HPMOTIONCHANNEL,true);
	}

Begin:
	MarkLabel('Begin');

	//Pawn.LoopAnim( 'TH_Bo_guard', 1.0, 0.0, VietnamPawn( Pawn ).HPMOTIONCHANNEL);
	Pawn.LoopAnim( 'Gr_Ab_throw_underhand', 1.0, 0.0, VietnamPawn( Pawn ).HPMOTIONCHANNEL);
	//Pawn.LoopAnim( 'TH_Cr_toss_satchel', 1.0, 0.0, VietnamPawn( Pawn ).HPMOTIONCHANNEL);
	Pawn.AnimBlendParams( VietnamPawn( Pawn ).HPMOTIONCHANNEL, 1.0, 0.0, 0.0);
	m_medicPreviousHealingTime = Level.TimeSeconds;

	Sleep(0.15f);

Finished:
	MarkLabel('Finished');
	m_pMedicPatient = None;
	m_pMedicPatientAmmo = None;
	StopAnimation(Pawn.HPMOTIONCHANNEL,true);
	EvaluateSituation();
	Stop;
}

defaultproperties
{
	m_DroppedAmount=3
	m_RefillingCount=10
	m_ReserveAmmo=999

     CommandBehaviors(1)="VietnamAI.AIBehaviorCmdTakeCover"
     CommandBehaviors(2)="VietnamAI.AIBehaviorCmdOpenFire"
     CommandBehaviors(3)="VietnamAI.AIBehaviorCmdCoverMe"
     CommandBehaviors(4)="VietnamAI.AIBehaviorCmdRally"
     CommandBehaviors(5)="VietnamAI.AIBehaviorCmdAdvance"
     CommandBehaviors(6)="VietnamAI.AIBehaviorCmdAdvance"
     CommandBehaviors(7)="VietnamAI.AIBehaviorCmdAdvance"
     CommandBehaviors(8)="VietnamAI.AIBehaviorCmdFallback"
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
