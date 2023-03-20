extends RigidBody3D

@onready var stats = $Stats.stats

var upgrades = load("res://Assets/Resources/Upgrades.tres")

func _ready():
	stats.merge(load("res://Scenes/Stats.tscn").instantiate().stats, false)
	var material = StandardMaterial3D.new()
	var color = Color(0,0,0)
	var divider = 0
	for stat in stats.keys():
		divider += stats[stat]
		color += $Stats.colors[stat]*stats[stat]
	color /= divider
	material.albedo_color = color
	$CSGSphere3D.material = material

func collect(player):
	player.collect_stat(stats)
	queue_free()
	$CSGSphere3D.material = StandardMaterial3D

func _physics_process(_delta):
	if position.y < -100:
		queue_free()
