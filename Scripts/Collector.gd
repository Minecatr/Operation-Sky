extends CSGBox3D

func _ready():
	$"../Timer".play("Collect")

func _on_Area_area_entered(area):
	if $"..".placed:
		if area.is_in_group("item"):
			$"../Storage".insert(area.get_parent().stats)
			area.get_parent().queue_free()
		if area.is_in_group("storage") and area != $"../Hitbox":
			$"../Storage".insert(area.get_parent().get_node("Storage").stats)

func _on_Timer_animation_finished(_anim_name):
	$"../Timer".play("Collect")
