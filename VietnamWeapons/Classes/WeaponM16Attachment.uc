// Weapon specific ThirdPersonEffects
class WeaponM16Attachment extends VietnamWeaponAttachment;

defaultproperties
{
     MuzzleClass=MF_M16
     MuzzleOffset=(X=110.000000,Y=-7.000000,Z=15.000000)
     MuzzleRotationOffset=(Yaw=16383)
     StaticMeshName="low_poly_weapons_stat.m16_A1_low_poly_stat"
     ShellEjectMeshName="weapons_stat.shells.shell_556_stat"
     DrawType=DT_StaticMesh
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
