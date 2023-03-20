extends Sprite3D

@export var autodisappear = true

func _ready():
	texture = $SubViewport.get_texture()
	if !autodisappear:
		$Timer.queue_free()
		visible = true

func _on_Timer_timeout():
	visible = false
