// Weapon specific ThirdPersonEffects
class WeaponM1911SAttachment extends VietnamWeaponAttachment;

defaultproperties
{
     MuzzleClass=MF_Pistol
     MuzzleOffset=(X=30.000000,Z=10.000000)
     MuzzleRotationOffset=(Yaw=16383)
     StaticMeshName="low_poly_weapons_stat.colt_1911_low_poly_stat"
     ShellEjectMeshName="weapons_stat.shells.shell_stat"
     DrawType=DT_StaticMesh
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
}
