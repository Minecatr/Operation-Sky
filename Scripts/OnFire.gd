extends Node3D

var player = self

func _on_Looper_timeout():
	get_parent().take_damage(1,player)

func _on_Time_timeout():
	get_parent().onfire = false
	queue_free()
