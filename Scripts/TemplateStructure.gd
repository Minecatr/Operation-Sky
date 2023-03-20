extends TextureButton

func _ready():
	$SubViewport.add_child(load("res://Scenes/Builds/"+name+".tscn").instantiate())
	texture_normal = $SubViewport.get_texture()
	texture_hover = $SubViewport.get_texture()
	texture_pressed = $SubViewport.get_texture()
	texture_click_mask = $SubViewport.get_texture()
func _pressed():
	if button_pressed == false:
		get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().Select("")
	else:
		get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().Select(name)
	for child in get_parent().get_children():
		if child != self:
			child.button_pressed = false


