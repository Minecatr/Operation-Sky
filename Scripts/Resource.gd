extends Area3D

@onready var stats = $Stats.stats
@onready var health = $Stats.health

var upgrades = load("res://Assets/Resources/Upgrades.tres")
var onfire = false

func _ready():
	$HealthBar3D/SubViewport/Health.max_value = health

func take_damage(amount, player):
	$HealthBar3D/Timer.start()
	$HealthBar3D.visible = true
	if health > 0:
		health -= amount
	$HealthBar3D/SubViewport/Health.value = health
	if health <= 0:
		player.collect_stat_resource(stats)
		queue_free()
