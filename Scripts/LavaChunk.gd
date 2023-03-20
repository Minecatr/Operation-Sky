extends RigidBody3D

func _ready():
	$CSGBox3D.material = $CSGBox3D.material.duplicate(true)
	$AnimationPlayer.play("Start")

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
