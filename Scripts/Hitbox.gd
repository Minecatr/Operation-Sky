extends Area3D
var health = 1
var onfire = false
func take_damage(amount,_source):
	get_parent().damage(amount)
