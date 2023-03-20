extends RayCast3D


var distance

func _process(_delta):
	if get_parent().placed:
		if get_collider():
			distance = transform.origin.distance_to(get_collision_point())
			$"../Scaler".scale.z = distance/2
			if get_collider().is_in_group("hitbox"):
				get_collider().get_parent().damage(5)
			if get_collider().is_in_group("hurtbox"):
				get_collider().take_damage(1, self)
			if get_collider().is_in_group("hurtbox_structure"):
				get_collider().get_parent().take_damage(1, self)
		else:
			$"../Scaler".scale.z = target_position.z

func collect_stat(stats):
	$"../Storage".insert(stats)

func collect_stat_resource(stats):
	$"../Storage".insert(stats)
