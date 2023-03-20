extends CSGCombiner3D

@export var storage = false

@onready var stats = $Stats.stats
@onready var health = $Stats.health

var upgrades = load("res://Assets/Resources/Upgrades.tres")
var placed = false

func _ready():
	$HealthBar3D/SubViewport/Health.max_value = health

func place():
	placed = true
	$Hitbox.add_to_group("hurtbox_structure")
	if storage:
		$Hitbox.add_to_group("storage")

func take_damage(amount, player):
	$HealthBar3D/Timer.start()
	$HealthBar3D.visible = true
	if health > 0:
		health -= amount
	$HealthBar3D/SubViewport/Health.value = health
	if health <= 0:
		player.collect_stat(stats)
		queue_free()
