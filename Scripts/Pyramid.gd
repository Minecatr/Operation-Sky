extends Area3D

func _on_Area_area_entered(area):
	if area.is_in_group("player"):
		$"../AnimationPlayer".play("open")
