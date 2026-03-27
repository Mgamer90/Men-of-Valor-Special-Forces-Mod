//////////////////////////////////////////////////////////////////////////////
//	File:	Autoturret and all variables is still here so REALLY OLD maps don't break
//			It is a deprecated class though
//
//	Description	:	This is the class for non-usable turrets
//----------------------------------------------------------------------------
class AutoTurret extends Actor;

var class<DamageType>	TurretDamageType;	// Damage class that the turret causes
var(AutoTurret) float	Damage;				// Damage that the turret causes per shot
var(AutoTurret) sound	FireSound;			// Sound played when weapon is fired
var float		BaseAccuracy;		// Base accuracy of the weapon		
var float		Recoil;				// Accuracy added per shot
var float		CurrentRecoil;		// Current amount of recoil
var float		RecoilDampeningRate;// Accuracy improvement over time
var float		MaxRange;			// Maximum range for projectile trace
var float		MaxReticuleSize;	// Max size of reticule
var(AutoTurret) float	AccuracyMultiplier;	// LD adjustable accuracy setting

var(TurretRotation) bool		m_bLimitRotation;	// Is there any limit to how far this turret can swing around?
// These rotation values were previously in Unreal units, now LD's specify in degrees
var(TurretRotation) float		fMinYaw;			// Limits relative to BaselineRotation of turret
var(TurretRotation) float		fMaxYaw;
var(TurretRotation) float		fMinPitch;
var(TurretRotation) float		fMaxPitch;

var rotator				BaselineRotation;	// Stores original rotation

// Variables to deal with turret firing at a specified actor (which is probably on a matinee)
var(AutoTurret) bool bFollowActor;
var(AutoTurret) Actor TargetActor;

var(AutoTurret) int iBurstAmount;			// Amount to fire in one burst
var(AutoTurret) int iBurstVariance;			// Amount to vary burstamount
var(AutoTurret) float fRateOfFire;			// Time between shots
var(AutoTurret) float fPauseBetweenBursts;	// Time between bursts
var(AutoTurret) float fPauseVariance;		// Amount to vary the pause time
var(AutoTurret) int iRoundsPerTracer;		// Fire a tracer every iRoundsPerTracer rounds
var(AutoTurret) bool bFiresTracerRounds;	// Fire tracers or not
var(AutoTurret) float Penetration;			// Amount to penetrate through when hitting a soft material

var int iBurstShotsLeft;				// If we're still bursting, this is the amount of shots remaining
var float fTimeTillNextShot;			// How long to wait till we fire again
var int iRoundsBeforeNextTracer;		// Rounds left to fire until we fire a tracer

var VietnamWeaponAttachment.MuzzleFlashVariant MFClass;
var MuzzleFlashAttachment                      MF;

var(AutoTurret) int TeamIndex;			// What team the turret thinks it's on
var(TurretRotation) int TurnRate;		// How fast the turret can rotate in units/sec

var bool bCanSeeTarget;					// Can we see what we're after or is he hiding?
										// This variable is updated in UpdateThreat

var float fTimeSinceTargetLastSighted;	// How long has it been since we saw the guy we're firing at?
var(AutoTurret) float fTimeTillGiveUp;	// Keep shooting at a hidden target until this time elapses

var float fTimeTillTargetCheck;			// How long to wait until we make sure the guy is still there

var(AutoTurret) int iMinDistance, iMaxDistance;	// Min and max distance where turret will engage targets

var int RecursionCnt;

var(AutoTurret) string FireSoundName;
var(AutoTurret) string MeshName;

defaultproperties
{
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
