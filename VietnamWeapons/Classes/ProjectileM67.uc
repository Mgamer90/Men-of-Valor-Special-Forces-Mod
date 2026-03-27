//=============================================================================
// ProjectileM67.uc
//=============================================================================
class ProjectileM67 extends ProjectileRPG7;

defaultproperties
{
     ProjectileSoundNames(0)=(PackageName="weapon_snd",ResourceName="GrenadeExplodeClose")
     ProjectileSoundNames(1)=(PackageName="weapon_snd",ResourceName="BombInWater")
     ProjectileSoundNames(2)=(PackageName="weapon_snd",ResourceName="RPG7NP")
     Damage=220.000000
     m_arrEventStates(0)="Activated"
     m_arrEventStates(1)="DeActivated"
     AssetName="weapons_stat.shells.m67_shell_stat"
}
