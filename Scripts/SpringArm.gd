extends SpringArm3D

@export var mouse_sensitivity := 0.1


func _ready() -> void:
	set_as_top_level(true)
	
	
	
func _unhandled_input(event: InputEvent) -> void:
		
	if Input.is_action_just_pressed("lockcamera") or spring_length == 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$"../CanvasLayer/UI/Dot".visible = true
	elif Input.is_action_just_released("lockcamera") and spring_length != 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$"../CanvasLayer/UI/Dot".visible = false
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 90.0)
	
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
		
	if Input.is_action_just_pressed("zoomout"):
		spring_length += 0.5
	if Input.is_action_just_pressed("zoomin"):
		spring_length -= 0.5
	spring_length = clamp(spring_length, 0, 32)
