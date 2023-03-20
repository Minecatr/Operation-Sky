extends CSGBox3D

func _ready():
	$"../Timer".play("Update")

func _on_Area_area_entered(area):
	if $"..".placed and area.is_in_group("storage"):
		var candrop = false
		var item = load("res://Scenes/Item.tscn").instantiate()
		var itemstats = item.get_node("Stats").stats
		for stat in area.get_parent().get_node("Storage").stats.keys():
			if area.get_parent().get_node("Storage").stats[stat] > 0:
				candrop = true
				itemstats[stat] = area.get_parent().get_node("Storage").stats[stat]
				area.get_parent().get_node("Storage").stats[stat] = 0
		if candrop:
			item.position = $"../Drop".global_position
			item.rotation = $"../Drop".global_rotation
			get_parent().get_parent().get_parent().get_node("Objects").add_child(item)

func _on_Timer_animation_finished(_anim_name):
	$"../Timer".play("Update")
