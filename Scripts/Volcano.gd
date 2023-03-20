extends CSGBox3D

var lava = preload("res://Scenes/LavaChunk.tscn")

func _on_Timer_timeout():
	var lava2 = lava.instantiate()
	var impulse = Vector3(0,randf_range(5,10),randf_range(1,5)).rotated(Vector3.UP, deg_to_rad(randf_range(0,360)))
	lava2.position = Vector3(0,7,0)
	lava2.apply_impulse(impulse, Vector3.ZERO)
	lava2.rotation = impulse
	add_child(lava2)
