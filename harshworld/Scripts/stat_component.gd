# stat_component.gd
extends Node

class_name StatComponent

## Player base stats
var strength: int = 5
var intelligence: int = 5
var available_points: int = 0

## Allocate points to stats
func allocate_point(stat: String) -> void:
	match stat:
		"strength":
			strength += 1
		"intelligence":
			intelligence += 1
		_:
			push_warning("Unknown stat: %s" % stat)
	
	available_points = max(available_points - 1, 0)

## Add stat points on level-up
func gain_stat_points(amount: int) -> void:
	available_points += amount
