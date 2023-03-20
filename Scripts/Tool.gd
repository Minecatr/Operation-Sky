extends TextureButton
func press():
	button_pressed = !button_pressed
	_pressed()
func _pressed():
	if button_pressed == false:
		get_parent().get_parent().get_parent().get_parent().Equip("")
	else:
		get_parent().get_parent().get_parent().get_parent().Equip(name)
	for child in get_parent().get_children():
		if child != self:
			child.button_pressed = false
