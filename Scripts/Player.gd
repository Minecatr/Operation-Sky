extends CharacterBody3D

@export var speed := 5.0
@export var jump_strength := 15.0
@export var gravity := 50.0
@export var TRANSITION_SPEED_AIR = 1.5
@export var TRANSITION_SPEED_GROUND = 15.0

# var _velocity := Vector3.ZERO
var _snap_vector := Vector3.DOWN
var jumping := false

@onready var _spring_arm: SpringArm3D = $SpringArm3D
@onready var _model: Node3D = $Character

const SAVE_PATH = "user://save_config_file.ini"

signal health_updated(health)
signal killed()

@export var max_health: int = 100

@onready var health = max_health# setget _set_health
@onready var invulnerability_timer = $InvulnerabilityTimer
# onready var effects_animation = $EffectsAnimation

@onready var animation_player = $Character/Armature/Skeleton3D/AnimationPlayer
@onready var character = $Character
#onready var arms = $Arms/Arms
# onready var ui = $CanvasLayer/UI
@onready var structuresfolder = $"../Structures"
@onready var statsui = $CanvasLayer/UI/TabContainer/Stats/VBoxContainer
@onready var upgradesui = $CanvasLayer/UI/TabContainer/Upgrades/VBoxContainer
@onready var furnaceui = $CanvasLayer/UI/MiddleTabs/Furnace
@onready var structuresui = $CanvasLayer/UI/SideTabs/Build/GridContainer
@onready var quickbar = $CanvasLayer/UI/Quickbar/HBoxContainer
@onready var settings = $CanvasLayer/UI/TabContainer/Settings/VBoxContainer
@onready var stats = $Stats.stats
@onready var statcolors = $Stats.colors
@onready var hammerui = $CanvasLayer/UI/Hammer
# onready var health = $Stats.health
@onready var healthbar = $CanvasLayer/UI/Quickbar/HBoxContainer/Health
@onready var nametag = $Nametag

@onready var animplayer = $CanvasLayer/UI/AnimationPlayer
@onready var bgm = $CanvasLayer/UI/AudioStreamPlayer

# var velocity = Vector2.ZERO
var actiondown = false
var equippeditem = ""
var anim = ""
var animstop = false
var animalternate = false
var canclick = true

var firesword = false
var speedsword = false
var jumpsword = false

var world = "world"
var save_path = "user://"+world+".oss"

#var spawn = Vector2(0,1.5)

var suffixes = ["", "k", "M", "G", "T", "P", "E", "Z", "Y"]
var rebirths = 0

var template = preload("res://Scenes/TemplateStat.tscn")
var template2 = preload("res://Scenes/TemplateStat2.tscn")
var template3 = preload("res://Scenes/TemplateUpgrade.tscn")
var template4 = preload("res://Scenes/TemplateStructure.tscn")
var template5 = preload("res://Scenes/TemplateStat4.tscn")
var template6 = preload("res://Scenes/TemplateRecipe.tscn")

var upgrades = load("res://Assets/Resources/Upgrades.tres")
var furnaceRecipes = load("res://Assets/Resources/Furnace.tres")

var selectedstructure = ""
var hammer_selected_structure = ""
var structures = [
	"Bridge",
	"Wall",
	"Stone-Wall",
	"Wedge",
	"Collector",
	"Drill",
	"Display",
	"Spike",
	"Dropper",
	"Furnace",
	"Laser"
]
func _unhandled_input(_event):
	if Input.is_action_just_pressed("swing"):
		if equippeditem == "Build" and selectedstructure != "": # make sure everything is ready to place a structure
				var structure = load("res://Scenes/Builds/"+selectedstructure+".tscn").instantiate()
				var canplace = true
				for stat in structure.get_node("Stats").stats.keys(): # see if player has enough resources
					if stats[stat] < structure.get_node("Stats").stats[stat] or position.y > 50:
						canplace = false
						$BuildOutline.material_override = load("res://Assets/Resources/build-failed.tres")
						$Failtimer.start()
				if canplace == true: # if it does place it
					for stat in structure.get_node("Stats").stats.keys():
						stats[stat] -= structure.get_node("Stats").stats[stat]
					updstats()
					structure.position = position
					structure.position.y += 0.55
					structure.rotation = rotation + $BuildOutline.rotation
					structuresfolder.add_child(structure)
					structure.place()
		if equippeditem == "Food" and health < max_health and stats["Food"] > 0:
			stats["Food"] -= 1
			_set_health(health+25)
			updstats()
		if equippeditem == "Sword":
			animstop = true
			animation_player.play("idle")
			animation_player.play("swing")
			$Hit/Sword.disabled = true
		elif equippeditem == "" or "Hammer":
			var mouse_pos = get_viewport().get_mouse_position()
			var ray_length = 100
			var from = _spring_arm.get_node("Camera3D").project_ray_origin(mouse_pos)
			var to = from + _spring_arm.get_node("Camera3D").project_ray_normal(mouse_pos) * ray_length
			var space = get_world_3d().direct_space_state
			var ray_query = PhysicsRayQueryParameters3D.new()
			ray_query.from = from
			ray_query.to = to
			ray_query.collide_with_bodies = false
			ray_query.collide_with_areas = true
			var raycast_result = space.intersect_ray(ray_query)
			if equippeditem == "" and raycast_result and raycast_result["position"].distance_to(position) < 5:
				if raycast_result["collider"].is_in_group("source"):
					raycast_result["collider"].take_damage(1,self)
				if raycast_result["collider"].is_in_group("hurtbox_structure") and raycast_result["collider"].get_parent().name == "Furnace":
					$CanvasLayer/UI/MiddleTabs.visible = true
				if raycast_result["collider"].is_in_group("storage"):
					collect_stat(raycast_result["collider"].get_parent().get_node("Storage").stats)
			elif equippeditem == "Hammer" and raycast_result:
				if raycast_result["collider"].is_in_group("hurtbox_structure") and !hammer_selected_structure:
					hammer_select(raycast_result["collider"])
	if Input.is_action_just_released("swing"):
		pass
func get_input():
	if Input.is_action_just_pressed("ui_cancel"):
		$CanvasLayer/UI/MiddleTabs.visible = false
		hammer_deselect()
	if Input.is_action_just_pressed("rotate"):
		$BuildOutline.rotation_degrees.x += 90
	for n in range(1,9): # Hotbar
		if Input.is_action_just_pressed(str(n)) and n <= $CanvasLayer/UI/HBoxContainer2.get_child_count():
			$CanvasLayer/UI/HBoxContainer2.get_child(n-1).press()
	if Input.is_action_just_pressed("salvage"):
		_on_salvage_pressed()
	if Input.is_action_just_pressed("upgrade"):
		_on_upgrade_pressed()
	if Input.is_action_pressed("kill"): # Self harm testing only
		damage(5)
	if Input.is_action_pressed("cheat"): # cheating testing only
		stats["Points"] += 234534
		activatefiresword()
		activateshovelsword()
		activatespeedsword()
		activatejumpsword()
		
		var item = load("res://Scenes/Item.tscn").instantiate()
		var itemstats = item.get_node("Stats").stats
		itemstats[load("res://Scenes/Stats.tscn").instantiate().stats.keys()[randi() % load("res://Scenes/Stats.tscn").instantiate().stats.keys().size()]] = 100
		item.position = position + Vector3(0,0,1.5).rotated(Vector3.UP, rotation.y)
		get_parent().add_child(item)
		updstats()

func Drop(item):
	if stats[item] > 0:
		var itemtemplate = load("res://Scenes/Item.tscn").instantiate()
		var itemstats = itemtemplate.get_node("Stats").stats
		stats[item] -= 1
		itemstats[item] = 1
		itemtemplate.position = position + Vector3(0,0.5,1.5).rotated(Vector3.UP, rotation.y)
		itemtemplate.apply_impulse(Vector3.ZERO, Vector3(0,2,2).rotated(Vector3.UP, rotation.y))
		get_parent().get_node("Objects").add_child(itemtemplate)
		updstats()
func animate(type,player): # all animations
	var new_anim = anim
	new_anim = type
	if new_anim != anim:
		anim = new_anim
		if player == 0:
			animation_player.play(anim)
		elif player == 1:
			animation_player.play(anim)
			$Hit/Sword.disabled = true
		elif player == 2:
			animation_player.play_backwards(anim)
			$Hit/Sword.disabled = true
	anim = ""
func _process(_delta: float) -> void:
	_spring_arm.position = position + Vector3(0,1,0) # first person and camera
	if _spring_arm.spring_length == 0:
		_model.visible = false
	else:
		_model.visible = true
	if upgrades.value["Rebirth"] != rebirths: # rebirth check
		#for stat in stats:
			#stats[stat] = 0
		pass
	updupgrades()
func _physics_process(delta: float) -> void:
	if position.y < -100:
		kill()
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left")
	move_direction.z = Input.get_action_raw_strength("backward") - Input.get_action_raw_strength("forward")
	if animstop:
		pass
#	elif _velocity.y > 0:
#		animate("jump",1)
#	elif is_on_floor() and _snap_vector == Vector3.ZERO:
#		animate("land",1)
#	elif not is_on_floor() and _velocity.y < -7:
#		print(_velocity.y)
#		animate("fall",1)
	elif move_direction.x > 0:
		animate("right_strafe",1)
	elif move_direction.x < 0:
		animate("left_strafe",1)
	elif move_direction.z > 0:
		animate("walk",2)
	elif move_direction.z < 0:
		animate("walk",1)
	else:
		animate("idle",1)
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
	
	var transition_speed = TRANSITION_SPEED_GROUND if is_on_floor() else TRANSITION_SPEED_AIR
	if move_direction:
		velocity.x = velocity.x * (1 - delta * transition_speed) + ((move_direction.x * speed) * (delta * transition_speed))
		velocity.z = velocity.z * (1 - delta * transition_speed) + ((move_direction.z * speed) * (delta * transition_speed))
	else:
		velocity.x = velocity.x * (1 - delta * transition_speed) + ((move_direction.x * speed) * (delta * transition_speed))
		velocity.z = velocity.z * (1 - delta * transition_speed) + ((move_direction.z * speed) * (delta * transition_speed))
	
	#velocity.x = move_direction.x * speed
	#velocity.z = move_direction.z * speed
	velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump"):
		jumping = true
	elif Input.is_action_just_released("jump"):
		jumping = false
	
	var just_landed := is_on_floor() and _snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and jumping 
	
	if is_jumping:
		velocity.y = jump_strength
		_snap_vector = Vector3.ZERO
	elif just_landed:
		_snap_vector = Vector3.DOWN
	#if _velocity.length() > 0.2 and _velocity.z != 0 or _velocity.x != 0:
		#var look_direction = Vector2(_velocity.z, _velocity.x)
		#rotation.y = look_direction.angle()
	move_and_slide()
	rotation_degrees.y = $SpringArm3D.rotation_degrees.y + 180
	get_input()

func _ready():
	var config = ConfigFile.new() # goes in client controller
	config.load(SAVE_PATH) # goes in client controller
	name = config.get_value("User","name", "Player") # goes in client controller
	nametag.text = name # goes in client controller
	stats.merge(load("res://Scenes/Stats.tscn").instantiate().stats, false)
	#$CanvasLayer/UI/Tab.size = DisplayServer.window_get_size()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(0.25))
	# stat making
	for stat in load("res://Scenes/Stats.tscn").instantiate().stats.keys():
		var tc = template.instantiate()
		tc.name = stat
		tc.self_modulate = statcolors[stat]
		statsui.add_child(tc)
		var tc2 = template2.instantiate()
		tc2.visible = false
		tc2.name = stat
		tc2.self_modulate = statcolors[stat]
		quickbar.add_child(tc2)
		var tc5 = template5.instantiate()
		tc5.name = stat
		tc5.self_modulate = statcolors[stat]
		$CanvasLayer/UI/HBoxContainer.add_child(tc5)
	updstats()
	# upgrade making
	for upgrade in upgrades.value.keys():
		var tc3 = template3.instantiate()
		tc3.name = upgrade
		upgradesui.add_child(tc3)
	updupgrades()
	# structure menu making
	for structure in structures:
		var tc4 = template4.instantiate()
		tc4.name = structure
		tc4.get_node("Label").text = structure
		structuresui.add_child(tc4)
	for recipe in furnaceRecipes.input.keys():
		var tc6 = template6.instantiate()
		tc6.name = recipe
		tc6.get_node("Input").self_modulate = statcolors[furnaceRecipes.input[recipe]]
		tc6.get_node("Input/Label").text = str(furnaceRecipes.inputamount[recipe])
		tc6.get_node("Output").self_modulate = statcolors[recipe]
		tc6.get_node("TextureRect/Label").text = str(furnaceRecipes.coalamount[recipe])
		furnaceui.add_child(tc6)

func updstats():
	for container in statsui.get_children():
		container.get_node("Label").text = container.name+": "+str(stats[container.name])
	for container in quickbar.get_children():
		if container.name != "Health":
			var amount = stats[container.name]
			container.visible = amount > 0
			@warning_ignore("integer_division")
			var exponent = str(round(amount/10)).length()/3
			if exponent > 0:
				amount = str(round(amount/pow(1000,exponent)))+suffixes[exponent]
			else:
				amount = str(amount)
			container.get_node("Label").text = amount

func updupgrades():
	for container in upgradesui.get_children():
		var amount = upgrades.cost[container.name]
		@warning_ignore("integer_division")
		var exponent = str(round(amount/10)).length()/3
		if exponent > 0:
			amount = str(round(amount/pow(1000,exponent)))+suffixes[exponent]
		else:
			amount = str(amount)
		container.text = str(upgrades.value[container.name])+" - Upgrade "+container.name+" "+amount+" "+upgrades.type[container.name]

func _on_Hit_area_entered(area):
	if area.is_in_group("hurtbox"):
		if area.health > 0:
			if equippeditem == "Sword":
				area.take_damage(1+upgrades.value["Damage Multi"],self)
				if firesword and !area.onfire:
					var onfireclone = load("res://Scenes/OnFire.tscn").instantiate()
					onfireclone.player = self
					area.add_child(onfireclone)
					area.onfire = true
	elif area.is_in_group("storage"):
		collect_stat(area.get_parent().get_node("Storage").stats)

func collect_stat(statss):
	for stat in statss:
		stats[stat] += statss[stat]
		statss[stat] = 0
	updstats()
func collect_stat_resource(statss):
	for stat in statss:
		stats[stat] += statss[stat]*(upgrades.value["Rebirth"]+1)
		statss[stat] = 0
	updstats()
# Settings

func _on_character_color_color_changed(color):
	$Character/Armature/Skeleton3D/Beta_Surface.get_surface_override_material(0).albedo_color = color

func _on_arms_color_color_changed(color):
	$Character/Armature/Skeleton3D/Beta_Joints.get_surface_override_material(0).albedo_color = color

# Health System

func damage(amount):
	if invulnerability_timer.is_stopped():
		invulnerability_timer.start()
		_set_health(health-amount)
		pass#effects_animation.play("damage")
		pass#effects_animation.queue("flash")
func kill():
	$Hit/Sword.shape.size = Vector3(0.05,0.5,0.1)
	$Hit/Sword/Model.scale.x = 0.25
	$Hit/Sword/Model.set_surface_override_material(0, load("res://Assets/Resources/chrome.tres"))
	firesword = false
	speedsword = false
	$Hit/Sword/Speed.visible = false
	speed = 5.0
	jumpsword = false
	$Hit/Sword/Jump.visible = false
	gravity = 50
	position = Vector3(0,1.5,0)
	_set_health(100)
	
func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health == 0:
			kill()
			emit_signal("killed")
	healthbar.value = health
	$HealthBar3D/Timer.start()
	$HealthBar3D/SubViewport/Health.value = health
	healthbar.get_node("Label").text = "Health: "+str(health)
	$Stats.health = health

func _on_InvulnerabilityTimer_timeout():
	pass#effects_animation.play("rest")

# UI

func Craft(recipe):
	if stats[furnaceRecipes.input[recipe]] >= furnaceRecipes.inputamount[recipe] and stats["Coal"] >= furnaceRecipes.coalamount[recipe]:
		stats["Coal"] -= furnaceRecipes.coalamount[recipe]
		stats[furnaceRecipes.input[recipe]] -= furnaceRecipes.inputamount[recipe]
		stats[recipe] += 1
		updstats()
func Upgrade(upgrade):
	if upgrades.cost[upgrade] <= stats[upgrades.type[upgrade]]:
		stats[upgrades.type[upgrade]] -= upgrades.cost[upgrade]
		upgrades.value[upgrade] += 1
		upgrades.cost[upgrade] = ceil(upgrades.cost[upgrade]*1.3)
	updupgrades()
	updstats()
func DeleteStructureOutline():
	for child in $BuildOutline.get_children():
		child.queue_free()
func Equip(item):
	equippeditem = item
	$Hit/Sword/Model.visible = item == "Sword"
	$Hit/Sword/Food.visible = item == "Food"
	$CanvasLayer/UI/SideTabs.visible = item == "Build"
	$CanvasLayer/UI/HBoxContainer.visible = item == "Build"
	hammer_deselect()
	if item == "Sword":
		if speedsword == true:
			speed = 10.0
			$Hit/Sword/Speed.visible = true
		if jumpsword == true:
			gravity = 15
			$Hit/Sword/Jump.visible = true
	else:
		$Hit/Sword/Speed.visible = false
		$Hit/Sword/Jump.visible = false
		speed = 5.0
		gravity = 50
	if item == "Build":
		DeleteStructureOutline()
		if selectedstructure != "":
			var structure = load("res://Scenes/Builds/"+selectedstructure+".tscn").instantiate()
			$BuildOutline.add_child(structure)
	else:
		DeleteStructureOutline()

func Select(structure):
	selectedstructure = structure
	for thing in $CanvasLayer/UI/HBoxContainer.get_children():
		thing.visible = false
	if equippeditem == "Build":
		DeleteStructureOutline()
		if structure != "":
			var structurec = load("res://Scenes/Builds/"+structure+".tscn").instantiate()
			$BuildOutline.add_child(structurec)
			for stat in structurec.stats.keys():
				if structurec.stats[stat] > 0:
					get_node("CanvasLayer/UI/HBoxContainer/"+stat+"/Label").text = str(structurec.stats[stat])
					get_node("CanvasLayer/UI/HBoxContainer/"+stat).visible = true

func _on_close_toggled(button_pressed):
	if button_pressed == true:
		animplayer.play("Close1")
	else:
		animplayer.play_backwards("Close1")

func _on_master_volume_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value/100))

func _on_Failtimer_timeout():
	$BuildOutline.material_override = load("res://Assets/Resources/build.tres")

func _on_Collection_area_entered(area): #  :(
	if area.is_in_group("item"):
		area.get_parent().collect(self)

func activateshovelsword():
	$Hit/Sword.shape.size = Vector3(0.05,1,0.15)
	$Hit/Sword/Model.scale.x = 0.5
func activatefiresword():
	$Hit/Sword/Model.set_surface_override_material(0, load("res://Assets/Resources/firesteel.tres"))
	firesword = true
func activatespeedsword():
	speedsword = true
	if equippeditem == "Sword":
		speed = 10.0
		$Hit/Sword/Speed.visible = true
func activatejumpsword():
	jumpsword = true
	if equippeditem == "Sword":
		gravity = 15
		$Hit/Sword/Jump.visible = true

func _on_middle_tabs_tab_changed(tab):
	if tab == 1:
		$CanvasLayer/UI/MiddleTabs.visible = false
		$CanvasLayer/UI/MiddleTabs.current_tab = 0

func _on_save_pressed():
	print("saving ", world)
	var file = ConfigFile.new()
	file.set_value("World", "generated", true)
	file.set_value("World", "structures", structuresfolder.get_child_count())
	for index in structuresfolder.get_child_count():
		file.set_value("StructuresID", str(index), structuresfolder.get_child(index).scene_file_path)
		file.set_value("StructuresPosition", str(index), structuresfolder.get_child(index).position)
		file.set_value("StructuresRotation", str(index), structuresfolder.get_child(index).rotation)
		file.set_value("StructuresHasStorage", str(index), structuresfolder.get_child(index).storage)
		if structuresfolder.get_child(index).storage:
			file.set_value("StructuresStorage", str(index), structuresfolder.get_child(index).get_node("Storage").stats)
	for upgrade in upgrades.cost.keys():
		file.set_value("UpgradeCost",upgrade,upgrades.cost[upgrade])
		file.set_value("UpgradeValue",upgrade,upgrades.value[upgrade])
	for child in $"../Islands".get_children():
		file.set_value("Islands", child.name, child.position)
	file.set_value("PlayerStats", name, stats)
	file.set_value("PlayerExists", name, true)
	file.save("user://"+world+".oss")
func _on_load_pressed():
	print ("loading ", world)
	var file = ConfigFile.new()
	file.load("user://"+world+".oss")
	if file.get_value("World", "generated", false):
		for child in structuresfolder.get_children():
			child.queue_free()
		for index in file.get_value("World", "structures", 0):
			var structure = load(file.get_value("StructuresID", str(index))).instantiate()
			structure.position = file.get_value("StructuresPosition", str(index))
			structure.rotation = file.get_value("StructuresRotation", str(index))
			structure.place()
			structuresfolder.add_child(structure)
			if file.get_value("StructuresHasStorage", str(index), false):
				structure.get_node("Storage").stats = file.get_value("StructuresStorage", str(index))
		for upgrade in upgrades.cost.keys():
			upgrades.cost[upgrade] = file.get_value("UpgradeCost",upgrade,1)
			upgrades.value[upgrade] = file.get_value("UpgradeValue",upgrade,0)
		for child in $"../Islands".get_children():
			child.position = file.get_value("Islands", child.name, Vector3(0,0,0))
		if file.get_value("PlayerExists", name, false):
			stats = file.get_value("PlayerStats", name, load("res://Scenes/Stats.tscn").instantiate().stats)
			updstats()
func _on_world_text_submitted(new_text):
	# This is world would be named
	if new_text.is_valid_filename():
		world = new_text
	else:
		$CanvasLayer/UI/TabContainer/Settings/VBoxContainer/World.text = world
	$CanvasLayer/UI/TabContainer/Settings/VBoxContainer/World.focus_mode = Control.FOCUS_NONE
	$CanvasLayer/UI/TabContainer/Settings/VBoxContainer/World.focus_mode = Control.FOCUS_ALL

func _on_quit_pressed():
	get_tree().change_scene_to_file("res://Scenes/Title.tscn")

#Hammer

func hammer_select(structure):
	structure.get_parent().material_overlay = load("res://Assets/Resources/outline.tres")
	hammer_selected_structure = structure
	hammerui.visible = true

func hammer_deselect():
	if hammer_selected_structure:
		hammer_selected_structure.get_parent().material_overlay = null
	hammer_selected_structure = null
	hammerui.visible = false

func _on_salvage_pressed():
	if hammer_selected_structure:
		hammer_selected_structure.get_parent().take_damage(hammer_selected_structure.get_parent().health,self)
		hammer_deselect()

func _on_upgrade_pressed():
	if hammer_selected_structure:
		hammer_deselect()

func _on_cancel_pressed():
	if hammer_selected_structure:
		hammer_deselect()

