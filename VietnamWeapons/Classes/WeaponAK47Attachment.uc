// Weapon specific ThirdPersonEffects
class WeaponAK47Attachment extends VietnamWeaponAttachment;

defaultproperties
{
     MuzzleClass=MF_Generic
     MuzzleOffset=(X=85.000000,Z=10.000000)
     MuzzleRotationOffset=(Yaw=16383)
     StaticMeshName="low_poly_weapons_stat.ak47_low_poly_stat"
     ShellEjectMeshName="weapons_stat.shells.sks_shell_stat"
     DrawType=DT_StaticMesh
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
