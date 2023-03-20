extends Node3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Rotate")
	$"../Structures/Drill".place()
	$"../Structures/Dropper".place()


func _on_AnimationPlayer_animation_finished(_anim_name):
	$AnimationPlayer.play("Rotate")
