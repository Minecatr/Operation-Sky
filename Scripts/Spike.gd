extends Area3D

var upgrades = load("res://Assets/Resources/Upgrades.tres")

func _on_Hitbox_area_entered(area):
	if area.is_in_group("hitbox"):
		area.get_parent().damage(upgrades.value["Damage Multi"]+1)
		$CollisionShape3D.disabled = true
		$"../Timer".start()

func _on_Timer_timeout():
	$CollisionShape3D.disabled = false
