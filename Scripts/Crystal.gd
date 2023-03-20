extends Area3D

@export var functionname = "activatefiresword"

func _on_Crystal_area_entered(area):
	if area.is_in_group("player"):
		area.get_parent().call(functionname)
