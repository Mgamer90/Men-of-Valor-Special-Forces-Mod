//Viet Cong Army

class VC_Prisoner extends VietnamPawn;

//#exec OBJ LOAD FILE=..\animations\ModelHuman_Enemy_Basic.ukx PACKAGE=ModelHuman_Enemy_Basic

defaultproperties
{
     Begin Object Class=AIParams Name=AIParams46
         m_bDoAI=False
         m_fDamageScale=0.000000
         m_bSearchableCorpse=False
         m_bWoundedBehaviors=False
         m_bCorpseSearch=False
         bDesiredEnableEnemy=False
         MinEnemyDistance=0.000000
         MaxEnemyDistance=0.000000
         Threat=0.000000
         ThreatRadius=0.000000
         FireWhileMovingPct=0.000000
         PawnHealth=0
         bSuppressAvailable=False
         bGrenadeAware=False
         Suppression=(IncrementAmt=0.000000,DecrementAmt=0.000000,DecayRate=0.000000,Threshold=0.000000,MinSuppressTime=0.000000)
         bForceFavoriteCover=False
         fPatrolDelay=0.000000
         fStopAtNodeVariance=0.000000
         MaxCoverLeaderDistance=0.000000
         Hearing=0.000000
         FOV=0.000000
         Sight=0.000000
         bEnablePain=False
         bEnableBumping=False
         MaxNoticeTime=0.000000
         m_fMaxNoticeTimeScale=0.000000
         MinLeaderDistance=0.000000
         MaxLeaderDistance=0.000000
         WaitDistance=0.000000
         bLookInLeaderDir=False
         m_fAccuracyMultiplier=0.000000
         MinAccuracyMultiplier=0.000000
         m_bChanceToHit=0
         ReloadPct=0.000000
         GrenThrowPct=0.000000
         Ranges(0)=(Range=0.000000,RangeVary=0.000000,AimTime=0.000000,AimTimeVary=0.000000,BurstClipPct=0.000000,BurstVaryPct=0.000000,FireClipPct=0.000000)
         Ranges(1)=(Type=AR_Long,Range=0.000000,RangeVary=0.000000,AimTime=0.000000,AimTimeVary=0.000000,BurstClipPct=0.000000,BurstVaryPct=0.000000,FireClipPct=0.000000)
         Ranges(2)=(Type=AR_Long,Range=0.000000,RangeVary=0.000000,AimTime=0.000000,AimTimeVary=0.000000,BurstClipPct=0.000000,BurstVaryPct=0.000000,FireClipPct=0.000000)
         Ranges(3)=(Type=AR_Long,Range=0.000000,AimTimeVary=0.000000,BurstClipPct=0.000000,BurstVaryPct=0.000000,FireClipPct=0.000000)
         SquadName="None"
         fStayBehindLeaderBias=0.000000
         m_fAIAccuracyMultiplier=0.000000
         Name="AIParams46"
     End Object
     AI=AIParams'VietnamCharacters.AIParams46'
     MyNationality=N_VIETNAMESE
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     m_arrEventStates(2)="Idle"
     m_arrEventStates(3)="Curious"
     m_arrEventStates(4)="Attack"
     m_arrEventStates(5)="Combat"
     m_arrEventStates(6)="Suppressed"
     m_arrEventStates(7)="Pain"
     m_arrEventStates(8)="Killed"
     m_arrEventStates(9)="GotFootball"
     m_arrEventStates(10)="GotPreciseAimedFootball"
     m_arrEventStates(11)="Destroyed"
     AssetName="ModelHuman_Enemy_Basic.Enemy_Basic"
}
