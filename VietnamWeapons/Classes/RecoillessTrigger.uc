// Can be placed by an LD or spawned into place in multiplayer
class RecoillessTrigger extends SpecialC4Trigger
	placeable;

function Detonate()
{
	// eliminate explosive damage
}

defaultproperties
{
     fTimer=0.000000
     ExplosionSoundName="Weapon_snd.MortarExplode"
     UseString="Press Use to load recoilless rifle"
     PlacedString="Recoilless rifle loaded."
     DisarmString=""
     m_arrEventStates(0)="NoClaymore"
     m_arrEventStates(1)="used"
     m_arrEventStates(2)="Detonated"
     m_arrEventStates(3)="Disarmed"
}
