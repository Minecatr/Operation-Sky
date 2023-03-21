extends CharacterBody3D

@onready var stats = $"../Storage/Has".stats
var upgrades = load("res://Assets/Resources/Upgrades.tres")
var target

func _on_area_3d_area_entered(area):
	if $"..".placed:
		if area.is_in_group("hurtbox"):
			if area.health > 0:
				area.take_damage(1+upgrades.value["Damage Multi"],self)

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
						if global_position.distance_to(resource.position) < global_position.distance_to(target):
							target = resource.position
					else:
						target = resource.position

func _physics_process(_ddelta):
	if $"..".placed and target:
		look_at(target)
		velocity = Vector3(1,0,0).rotated(Vector3.UP, rotation.y)
		#velocity = velocity.rotated(Vector3.BACK, rotation.x)
		move_and_slide()
