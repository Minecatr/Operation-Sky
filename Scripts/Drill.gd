extends CSGBox3D

@onready var stats = $"../Storage/Has".stats
var upgrades = load("res://Assets/Resources/Upgrades.tres")

func _ready():
	$AnimationPlayer.play("Rotate")

func _on_Area_area_entered(area):
	if $"..".placed:
		if area.is_in_group("hurtbox"):
			if area.health > 0:
				area.take_damage(1+upgrades.value["Damage Multi"],self)
	#elif area.is_in_group("hurtbox_structure"):
		#if area.get_parent().health > 0:
			#area.get_parent().take_damage(1+upgrades.value["Damage Multi"],self)

func collect_stat(statss):
	for stat in statss:
		stats[stat] += statss[stat]
		statss[stat] = 0

func collect_stat_resource(statss):
	for stat in statss:
		stats[stat] += statss[stat]*(upgrades.value["Rebirth"]+1)
		statss[stat] = 0

func _on_AnimationPlayer_animation_finished(_anim_name):
	$AnimationPlayer.play("Rotate")
