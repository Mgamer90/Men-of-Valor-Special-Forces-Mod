// Weapon specific ThirdPersonEffects
class WeaponPUAttachment extends VietnamWeaponAttachment;

defaultproperties
{
     MuzzleClass=MF_Generic
     MuzzleOffset=(X=120.000000,Y=-3.000000,Z=18.000000)
     MuzzleRotationOffset=(Yaw=16383)
     StaticMeshName="low_poly_weapons_stat.mosnag_low_poly_stat"
     ShellEjectMeshName="weapons_stat.shells.shell_556_stat"
     DrawType=DT_StaticMesh
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
