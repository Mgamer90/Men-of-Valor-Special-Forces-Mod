// Weapon specific ThirdPersonEffects
class WeaponM60Attachment extends VietnamWeaponAttachment;

defaultproperties
{
     MuzzleClass=MF_M60
     MuzzleOffset=(X=108.000000,Z=11.000000)
     MuzzleRotationOffset=(Yaw=16383)
     StaticMeshName="low_poly_weapons_stat.m60_low_poly_stat"
     ShellEjectMeshName="weapons_stat.shells.shell_556_stat"
     DrawType=DT_StaticMesh
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
