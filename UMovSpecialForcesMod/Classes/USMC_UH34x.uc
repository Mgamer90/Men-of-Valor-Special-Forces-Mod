//    usmc_uh34 Hi res

class USMC_UH34x extends BaseUH34;

defaultproperties
{
     fMaxSpeed=2000.000000
     SoundStates(1)=(bUseRPC=True,RPCName="Distance",SoundName="HueyExterior")
     SoundStates(2)=(bUseRPC=True,RPCName="RPM",SoundName="HueyFly")
     mCrew(0)=(tagString="None",LoadAnim="VEH_UH34_seat00_geton",IdleAnim="VEH_UH34_seat00_idle",UnloadAnim="VEH_UH34_seat00_getout")
     mCrew(1)=(tagString="None",LoadAnim="VEH_UH34_seat01_geton",IdleAnim="VEH_UH34_seat01_idle",UnloadAnim="VEH_UH34_seat01_getout")
     mCrew(2)=(tagString="None",LoadAnim="VEH_UH34_seat02_geton",IdleAnim="VEH_UH34_seat02_idle",UnloadAnim="VEH_UH34_seat02_getout")
     mCrew(3)=(tagString="None",LoadAnim="VEH_UH34_seat03_geton",IdleAnim="VEH_UH34_seat01_idle",UnloadAnim="VEH_UH34_seat03_getout")
     mCrew(4)=(tagString="None",LoadAnim="VEH_UH34_seat04_geton",IdleAnim="VEH_UH34_seat04_idle",UnloadAnim="VEH_UH34_seat04_getout")
     mCrew(5)=(tagString="None",LoadAnim="VEH_UH34_seat05_geton",IdleAnim="VEH_UH34_seat05_idle",UnloadAnim="VEH_UH34_seat05_getout")
     mCrew(6)=(tagString="None",LoadAnim="VEH_UH34_seat06_geton",IdleAnim="VEH_UH34_seat06_idle",UnloadAnim="VEH_UH34_seat06_getout")
     mCrew(7)=(tagString="None",LoadAnim="VEH_UH34_seat_gunner_geton",IdleAnim="VEH_UH34_seat_gunner_idle",UnloadAnim="VEH_UH34_seat_gunner_getout")
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     m_arrEventStates(2)="used"
     m_arrEventStates(3)="Mounted"
     m_arrEventStates(4)="Dismounted"
     m_arrEventStates(5)="Damage_0_Level"
     m_arrEventStates(6)="Damage_1_Level"
     m_arrEventStates(7)="PassengerLoaded"
     m_arrEventStates(8)="PassengerUnloaded"
     m_arrEventStates(9)="WeaponFired"
}
