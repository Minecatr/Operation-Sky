extends CharacterBody3D

@onready var stats = $"../Storage/Has".stats
var upgrades = load("res://Assets/Resources/Upgrades.tres")
var target

func _on_area_3d_area_entered(area):
	if $"..".placed:
		if area.is_in_group("hurtbox"):
			if area.health > 0:
				area.take_damage(1+upgrades.value["Damage Multi"],self)
				target = null
				$Area3D/CollisionShape3D2.set_deferred("disabled", true)
				$Breaktimer.start()

func collect_stat(statss):
	for stat in statss:
		stats[stat] += statss[stat]
		statss[stat] = 0

func collect_stat_resource(statss):
	for stat in statss:
		stats[stat] += statss[stat]*(upgrades.value["Rebirth"]+1)
		statss[stat] = 0

func _on_timer_timeout():
	if $"..".placed:
		for island in get_parent().get_parent().get_parent().get_node("Islands").get_children():
			for resourcetype in island.get_node("Resources").get_children():
				for resource in resourcetype.get_children():
					if target:
						if get_parent().global_position.distance_to(resource.global_position) < get_parent().global_position.distance_to(target):
							target = resource.global_position
					elif get_parent().global_position.distance_to(resource.global_position) < 20:
						target = resource.global_position

func _physics_process(_ddelta):
	if $"..".placed and target:
		look_at(target)
		velocity = -global_transform.basis.z
		#velocity = Vector3(0,1,0).rotated(Vector3.UP, rotation.y)
		#velocity = velocity.rotated(Vector3.BACK, rotation.x)
		move_and_slide()


func _on_breaktimer_timeout():
	$Area3D/CollisionShape3D2.set_deferred("disabled", false)
