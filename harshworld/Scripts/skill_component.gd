# skill_component.gd
extends Node

class_name SkillComponent

@export var chopping: SkillData
@export var mining: SkillData
@export var attack: SkillData

var stat_component: StatComponent

func _ready():
	stat_component = get_parent().get_node("StatComponent")

## Utility: Calculates chopping effectiveness
func get_chopping_power() -> float:
	return chopping.base_power + \
		(stat_component.strength * 0.5) + \
		(stat_component.intelligence * 0.2) + \
		(chopping.proficiency * 1.0)

## Utility: Calculates mining effectiveness
func get_mining_power() -> float:
	return mining.base_power + \
		(stat_component.strength * 0.4) + \
		(stat_component.intelligence * 0.3) + \
		(mining.proficiency * 1.0)

## Utility: Calculates attack damage
func get_attack_damage() -> float:
	return attack.base_power + \
		(stat_component.strength * 0.6) + \
		(stat_component.intelligence * 0.2) + \
		(attack.proficiency * 1.5)

## Gain XP toward a skill
func use_skill(skill_name: String, xp_gain: float) -> void:
	match skill_name:
		"chopping":
			chopping.gain_proficiency_xp(xp_gain)
		"mining":
			mining.gain_proficiency_xp(xp_gain)
		"attack":
			attack.gain_proficiency_xp(xp_gain)
		_:
			push_warning("Unknown skill: %s" % skill_name)
