extends Area3D

@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer
@onready var stats = $Stats.stats
@onready var health = $Stats.health

var upgrades = load("res://Assets/Resources/Upgrades.tres")
var onfire = true

func take_damage(amount, player):
	if health > 0:
		health -= amount
		animation_player.play("hit")
	if health <= 0:
		timer.wait_time = 10.0/(float(upgrades.value["Speed"])+2.0)
		timer.start()
		player.collect_stat(stats)

func _on_Timer_timeout():
	if health != 1:
		stats["Points"] = (upgrades.value["Multi"]+1)*(upgrades.value["Multi2"]+1)*(upgrades.value["Rebirth"]+1)
		animation_player.play_backwards("hit")
		health = 1
