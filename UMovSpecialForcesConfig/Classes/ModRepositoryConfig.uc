class ModRepositoryConfig extends VietnamMedicBot
	config (UMovSpecialForcesConfig);

var (SpecialForcesMod) config int m_GameDifficulty;

var (SpecialForcesMod) config string m_ControllerClassName;

var (SpecialForcesMod) config float m_GroundSpeedMultiplier;

var (SpecialForcesMod) config bool m_OverrideAIParams;

var (SpecialForcesMod) config bool m_SpawnNewWeaponAtStart;
var (SpecialForcesMod) config string m_NewWeaponName;
var (SpecialForcesMod) config bool m_SpawnSniperRifleAtStart;
var (SpecialForcesMod) config string m_SniperRifleName;

var (SpecialForcesMod) config int m_RefillingCount; // max of requests
var (SpecialForcesMod) config int m_ReserveAmmo;
var (SpecialForcesMod) config int m_DroppedAmount;

var (SpecialForcesMod) config bool m_bDoAI  "Process AI?";
var (SpecialForcesMod) config bool m_bGodMode 		"Start in god mode?";
var (SpecialForcesMod) config bool m_bDemiGodMode 	"Take damage, but don't die";
var (SpecialForcesMod) config float m_fDamageScale 	"Scales all damage taken by bot";
var (SpecialForcesMod) config bool m_bKillableFriendly "Makes friendlies killable/unkillable";
var (SpecialForcesMod) config bool m_bSearchableCorpse "When the bot is dead he can be searched by friendlies";
var (SpecialForcesMod) config bool m_bWoundedBehaviors "false to disable wounded behaviors for friendlies";
var (SpecialForcesMod) config bool m_bCorpseSearch 	"false to disable corpse searching for this bot";
var (SpecialForcesMod) config name m_nForcedStance 	"Don't use this anymore, use ForcedStance instead";
var (SpecialForcesMod) config Pawn.EMoveType ForcedStance 	"Forced movement type";

var (SpecialForcesMod) config class<SoundSet> SoundSetClass 	"Voice to use";
var (SpecialForcesMod) config class<AnimSet> AnimSetClass 	"Anim set to use, overrides default";
var (SpecialForcesMod) config class<AnimSubSet> AnimSubSetClass "Sub set of animations to override in AnimSet";

var (SpecialForcesMod) config class<AIBehaviorIdle>	IdleBehavior;
var (SpecialForcesMod) config class<AIBehaviorCombat> CombatBehavior;
var (SpecialForcesMod) config class<AIBehaviorCurious> CuriousBehavior;
var (SpecialForcesMod) config class<AIBehaviorRetreat> RetreatBehavior;
var (SpecialForcesMod) config array<class<AIBehavior> > OtherBehaviors;

var (SpecialForcesMod) config bool bDesiredEnableEnemy "Able to acquire enemies?";
var (SpecialForcesMod) config float MinEnemyDistance "Min distance allowed to enemy";
var (SpecialForcesMod) config float MaxEnemyDistance "Max distance allowed to enemy";
var (SpecialForcesMod) config int 	ThreatBias 		"Modified threat value, -1 to be ignored";
var (SpecialForcesMod) config float Threat;
var (SpecialForcesMod) config float ThreatRadius;
var (SpecialForcesMod) config float FireWhileMovingPct "Chance to attack while moving";
var (SpecialForcesMod) config int 	PawnHealth 		"Starting health";
var (SpecialForcesMod) config array<Route>	Routes;

var (SpecialForcesMod) config bool bAlwaysAlert 	"Never allowed to transition back to idle";
var (SpecialForcesMod) config bool bStartInCombat 	"Automatically pick nearest enemy when spawned";
var (SpecialForcesMod) config bool bHiddenTillCombat "AI is undetectable until in combat";
var (SpecialForcesMod) config bool bTakeBleedingDamage;
var (SpecialForcesMod) config bool     	 	bSuppressAvailable          "Unit can go int suppressed state";
var (SpecialForcesMod) config bool            bUnderFireAvailable "Unit can go into underfire state" ;
var (SpecialForcesMod) config bool            bGrenadeAware 	"Bot will respond to grenades if true";
var (SpecialForcesMod) config bool bMofoVision 		"Give the bot motha-fokka vision, (thy shalt mofo with care)";
var (SpecialForcesMod) config bool bDisableFakeFire "Disables normal fake firing for this bot";

var (SpecialForcesMod) config bool 	bForceFavoriteCover "use favorite cover only, or as a mild suggestion?";
var (SpecialForcesMod) config bool  bManeuverCover              "Force linear cp progression";
var (SpecialForcesMod) config bool  bBreakBehavior     "AI will follow cp progression to the end without breaking due to enemy engagement"	;
var (SpecialForcesMod) config float fManeuverDelay              "If no animation is defined, then this is the length that the bot will spend at a node";
var (SpecialForcesMod) config float fPatrolDelay                "If no animation is defined, then this is the length that the bot will spend at a node";
var (SpecialForcesMod) config float fStopAtNodeVariance         "Allows bots to bypass some nodes on route" ;
var (SpecialForcesMod) config Pawn.EMoveType	PatrolMoveType              "Move type used during this patrol route";
var (SpecialForcesMod) config bool 	bForcePatrol 	"Force adherence to a patrol route";
var (SpecialForcesMod) config bool 	bBreakonEndNode             "If you reach the end node - patrol route behavior ends";
var (SpecialForcesMod) config float MaxCoverLeaderDistance		"Max distance for cover to be valid when following leader";
var (SpecialForcesMod) config bool 	bPreventProne     "Prevent AI from going into Prone";

var (SpecialForcesMod) config bool bHiding  "Am I hiding?";
var (SpecialForcesMod) config float Hearing  "Max hearing distance";
var (SpecialForcesMod) config float FOV		  		"Field of vision, assumed to be in degrees";
var (SpecialForcesMod) config float Sight  "Max sight distance";
var (SpecialForcesMod) config bool bEnablePain 		"Respond to pain?";
var (SpecialForcesMod) config bool  bEnableBumping 	"Respond to bumps?";
var (SpecialForcesMod) config float ChanceToNoticeModifier		"Amt to scale the chance to notice a stimulus";
var (SpecialForcesMod) config float MaxNoticeTime;
var (SpecialForcesMod) config float m_fPlayerSightLevel;
var (SpecialForcesMod) config name m_FavoriteEnemyTag "The AI will prefer to attack the specified target";
var (SpecialForcesMod) config float m_fMaxNoticeTimeScale		"The time at which an Enemy will be noticed by";

// Friendly Properties
var (SpecialForcesMod) config Name m_nLeaderTag 	"Name of pawn to follow, none for player";
var (SpecialForcesMod) config float MinLeaderDistance;
var (SpecialForcesMod) config float MaxLeaderDistance "Follow the leader if he/she/it gets this far away or further";
var (SpecialForcesMod) config float WaitDistance 	"ONPOINT min player distance before moving on";
var (SpecialForcesMod) config string PlayerName;
var (SpecialForcesMod) config bool bAcceptsOrders 	"Do I accept orders?";
var (SpecialForcesMod) config bool  bCanSearch 		"Can I search corpses?";
var (SpecialForcesMod) config bool  bLookInLeaderDir  "When idle, look in leader's facing direction?";
var (SpecialForcesMod) config bool bSneakyBastard 	"You underestimate the sneakiness";

// Weapon control/handling
var (SpecialForcesMod) config float m_fAccuracyMultiplier		"Modifies BaseAccuracy";
var (SpecialForcesMod) config float MinAccuracyMultiplier		"set this higher to force inaccuracy regardless of aimtime";
var (SpecialForcesMod) config byte m_bChanceToHit 	"The percent chance to actually shoot your weapon and not fake fire (0 - 255 == 0% - 100%)";
var (SpecialForcesMod) config float ReloadPct 		"Percent of clip to have left before reloading";
var (SpecialForcesMod) config bool bHasGrenades;
var (SpecialForcesMod) config float GrenThrowPct 	"Chance to throw a grenade if appropriate, 0-1";
var (SpecialForcesMod) config bool bOnlyFireTracers "True - Weapon only fire tracers (ignores RoundsBulletsPerTracer)";
// efd
var (SpecialForcesMod) config bool bUseSemiAutoFire "Fire automatic weapons in semi-auto mode";
// end efd

var (SpecialForcesMod) config bool bInSquad;
var (SpecialForcesMod) config bool bSquadLeader;
var (SpecialForcesMod) config Name SquadName;
var (SpecialForcesMod) config float fStayBehindLeaderBias		"0.0 to 1.0, higher values make bots stay behind the leader more";
var (SpecialForcesMod) config float fStayCloseLeaderBias		"0.0 to 1.0, higher values make bots stay near the leader more";
var (SpecialForcesMod) config float fCombatAdvanceBias "0.0 to 1.0, higher values make bots advance towards enemies more";
var (SpecialForcesMod) config float fAggressiveFireBias		"0.0 to 1.0, higher values mean longer fire bursts and shorter delays";

defaultproperties
{
	m_GameDifficulty=3
	m_GroundSpeedMultiplier=1.0

	m_ControllerClassName="UMovSpecialForcesMod.USMC_Marine_Support_Bot"

	m_OverrideAIParams=true

	m_SpawnSniperRifleAtStart=true
	m_SniperRifleName="VietnamWeapons.PickupM21"

	m_SpawnNewWeaponAtStart=true
	m_NewWeaponName="VietnamWeapons.PickupM60"

	m_DroppedAmount=3
	m_RefillingCount=10
	m_ReserveAmmo=999

     m_bDoAI=True
     m_fDamageScale=1.000000
     m_bSearchableCorpse=True
     m_bWoundedBehaviors=True
     m_bCorpseSearch=True
     bDesiredEnableEnemy=True
     MinEnemyDistance=256.000000
     MaxEnemyDistance=4096.000000
     Threat=1.000000
     ThreatRadius=2048.000000
     FireWhileMovingPct=0.950000
     PawnHealth=100
     bSuppressAvailable=True
     bGrenadeAware=True
 //    Suppression=(IncrementAmt=0.100000,DecrementAmt=0.100000,DecayRate=0.800000,Threshold=0.100000,MinSuppressTime=0.100000)
     bForceFavoriteCover=True
     fPatrolDelay=5.000000
     fStopAtNodeVariance=1.000000
     MaxCoverLeaderDistance=2000.000000
     Hearing=4096.000000
     FOV=90.000000
     Sight=7500.000000
     bEnablePain=True
     bEnableBumping=True
     MaxNoticeTime=2.000000
     m_fMaxNoticeTimeScale=1.000000
     MinLeaderDistance=250.000000
     MaxLeaderDistance=1500.000000
     WaitDistance=256.000000
     bLookInLeaderDir=True
     m_fAccuracyMultiplier=1.000000
     MinAccuracyMultiplier=0.100000
     m_bChanceToHit=255
     ReloadPct=0.300000
     GrenThrowPct=0.350000
     // Ranges(0)=(Range=4096.000000,RangeVary=512.000000,AimTime=1.750000,AimTimeVary=0.500000,BurstClipPct=0.250000,BurstVaryPct=0.500000,FireClipPct=0.100000)
     // Ranges(1)=(Type=AR_Medium,Range=2048.000000,RangeVary=512.000000,AimTime=1.250000,AimTimeVary=0.350000,BurstClipPct=0.250000,BurstVaryPct=0.500000,FireClipPct=0.200000)
     // Ranges(2)=(Type=AR_Short,Range=1024.000000,RangeVary=256.000000,AimTime=0.500000,AimTimeVary=0.100000,BurstClipPct=0.300000,BurstVaryPct=0.500000,FireClipPct=0.500000)
     // Ranges(3)=(Type=AR_Melee,Range=150.000000,AimTimeVary=0.001000,BurstClipPct=0.500000,BurstVaryPct=0.500000,FireClipPct=0.800000)
     SquadName="USMC"
     fStayBehindLeaderBias=0.250000
     //m_fAIAccuracyMultiplier=1.000000
}
