//////////////////////////////////////////////////////////////////////////////
//	File:	VietnamMedicBot.uc
//
//	Description	:	
//----------------------------------------------------------------------------
class USMC_Marine_Medic_Bot extends VietnamMedicBot;

var VietnamAmmo m_pMedicPatientAmmo;
var float m_medicPreviousRefillingTime;

var int m_RefillingCount;

function RefillPawnAmmo(VietnamPawn pVPawn)
{
	local VietnamAmmo NamAmmo;
	local VietnamWeapon NamWeapon;
	/*if (pVPawn? &&
		!m_pMedicPatient ||
		(PlayerController(pVPawn.Controller)? &&
		 !PlayerController(m_pMedicPatient.Controller)))
	{*/

	if (pVPawn != None && m_pMedicPatient == None)
	{
		Comment("Acquired new patient"@pvPawn);
		m_pMedicPatient = pVPawn;
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

		SwitchState('RefillingAmmo',,true);

		/*if(
			m_pMedicPatientAmmo != None &&
			(
				m_pMedicPatientAmmo.IsA('Ammo762NATO') ||
				m_pMedicPatientAmmo.IsA('AmmoM21') ||
				m_pMedicPatientAmmo.IsA('AmmoM67') ||
				m_pMedicPatientAmmo.IsA('Ammo45Cal') ||
				m_pMedicPatientAmmo.IsA('Ammo50Cal') ||
				m_pMedicPatientAmmo.IsA('Ammo556NATO') ||
				m_pMedicPatientAmmo.IsA('AmmoM79TearGas') ||
				m_pMedicPatientAmmo.IsA('AmmoM79Buckshot') ||
				m_pMedicPatientAmmo.IsA('AmmoM79Flare') ||
				m_pMedicPatientAmmo.IsA('AmmoM79FragGrenade') ||
				m_pMedicPatientAmmo.IsA('AmmoM79SmokeGrenade') ||
				m_pMedicPatientAmmo.IsA('AmmoFragGrenade')
			)
		)
		{
			SwitchState('RefillingAmmo',,true);
		}*/

		//Level.Game.Broadcast(Self, "Refill Ammo used by "$pVPawn.GetHumanReadableName(), 'Say');
	}
}

// entry point for healing new patient
// - called from normal ai checks, and also from player "use"
// - player can usurp ai acquired patient
function MedicCheckPatient(VietnamPawn pVPawn)
{
	local VietnamAmmo NamAmmo;
	local VietnamWeapon NamWeapon;

	if (pVPawn != None && m_pMedicPatient == None)
	{
		Comment("Acquired new patient"@pvPawn);
		m_pMedicPatient = pVPawn;

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
			SwitchState('MedicHealingPlayer',,true);
		}*/
		SwitchState('MedicHealingPlayer',,true);

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

state MedicHealingPlayer
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
				m_pMedicPatient.RemainingBleedingDamage -= 2;
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
	StopAnimation(Pawn.HPMOTIONCHANNEL,true);
	EvaluateSituation();
	Stop;
}

state RefillingAmmo
{
	function EndState()
	{
		StopAnimation(Pawn.HPMOTIONCHANNEL,true);
	}
	
Begin:
	MarkLabel('Begin');

	//Pawn.LoopAnim( 'Medic_Helping', 1.0, 0.0, VietnamPawn( Pawn ).HPMOTIONCHANNEL);
	Pawn.LoopAnim( 'TH_AB_reloadtap_act', 1.0, 0.0, VietnamPawn( Pawn ).HPMOTIONCHANNEL);
	Pawn.AnimBlendParams( VietnamPawn( Pawn ).HPMOTIONCHANNEL, 1.0, 0.0, 0.0);
	m_medicPreviousRefillingTime = Level.TimeSeconds;

Refilling:
	MarkLabel('Refilling');

	// Keep Refilling until MaxAmmo
	if ( m_pMedicPatientAmmo != None && DistanceSq( m_pMedicPatient, Pawn ) < 350000 )
	{
		if (m_pMedicPatientAmmo.AmmoAmount * 2 < m_pMedicPatientAmmo.MaxAmmo)
		{
			m_pMedicPatientAmmo.AmmoAmount *= 2;
		}

		//m_pMedicPatientAmmo.AmmoAmount += m_pMedicPatientAmmo.PickupAmmo;
		//m_pMedicPatientAmmo.AmmoAmount = Clamp(m_pMedicPatientAmmo.AmmoAmount+10*(Level.TimeSeconds-m_medicPreviousRefillingTime),0,m_pMedicPatientAmmo.MaxAmmo);

		if (m_pMedicPatientAmmo.AmmoAmount >= m_pMedicPatientAmmo.MaxAmmo)
		{
			Goto('Finished');
		}
		else
		{
			m_medicPreviousRefillingTime = Level.TimeSeconds;
		}
	}
	else
	{
		Goto('Finished');
	}
	Sleep(0.15f);
	Goto('Refilling');

Finished:
	MarkLabel('Finished');
	m_pMedicPatient = None;
	m_pMedicPatientAmmo = None;
	EvaluateSituation();
	Stop;
}

defaultproperties
{
	m_RefillingCount=5

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
