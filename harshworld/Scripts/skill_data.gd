# res://Scripts/skill_data.gd
extends Resource
class_name SkillData  # <- This makes it appear in the "New Resource" menu

@export var skill_name: String = "Unnamed Skill"
@export var base_power: float = 1.0
@export var proficiency: float = 0.0
@export var proficiency_max: float = 100.0

var proficiency_xp: float = 0.0
const XP_PER_LEVEL: float = 10.0

func gain_proficiency_xp(amount: float) -> void:
	proficiency_xp += amount
	while proficiency_xp >= XP_PER_LEVEL and proficiency < proficiency_max:
		proficiency += 1
		proficiency_xp -= XP_PER_LEVEL
