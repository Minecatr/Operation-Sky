extends CSGBox3D

@onready var stats = $Has.stats

func _ready():
	stats.merge(load("res://Scenes/Stats.tscn").instantiate().stats, false)

func insert(statss): #INSERT
	for stat in statss:
		stats[stat] += statss[stat]
		statss[stat] -= statss[stat]
