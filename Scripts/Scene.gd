extends Node3D

@onready var islands = $Islands
@onready var timer = $ResourceTimer
@onready var sprite = $"Islands/Main Island"

var upgrades = load("res://Assets/Resources/Upgrades.tres")
var original = load("res://Assets/Resources/UpgradeValue.tres")
var rebirths = 0
var maximumresource = {
	"Tree": upgrades.value["Max Tree"],
	"Rock": upgrades.value["Max Rock"],
	"Bush": upgrades.value["Max Bush"],
	"Cactus": 8,
	"Sand": 8,
	"Coal": 8,
	"Dirt": 8,
	"Gold": 2
}

func _ready():
	randomize()
	$Islands/Desert.position = Vector3(randf_range(-16,16)*4,-0.25,randf_range(-16,16)*4)
	$Islands/Volcano.position = Vector3(randf_range(-24,24)*4,-0.5,randf_range(-24,24)*4)
	$"Islands/Gravity City".position = Vector3(randf_range(-32,32)*4,50,randf_range(-32,32)*4)
	$"Islands/Laser Matrix".position = Vector3(randf_range(-32,32)*4,randf_range(-8,8)*4,randf_range(-32,32)*4)

func _on_ResourceTimer_timeout():
	timer.wait_time = 120.0/(float(upgrades.value["Material Spawnrate"])+2.0) #120
	maximumresource["Tree"] = upgrades.value["Max Tree"]
	maximumresource["Rock"] = upgrades.value["Max Rock"]
	maximumresource["Bush"] = upgrades.value["Max Bush"]
	for island in islands.get_children():
		for resource in island.get_node("Resources").get_children():
			if maximumresource[resource.name] > resource.get_child_count():
				var clone = load("res://Scenes/Resources/"+resource.name+".tscn").instantiate()
				clone.position = Vector3(((2*randf())-1)*(island.size.x*0.5),0.5,((2*randf())-1)*(island.size.z*0.5))
				if island.name == "Volcano" or island.name == "Desert":
					if 6-((abs(clone.position.x)+abs(clone.position.z))/2) > 0.5:
						clone.position = Vector3(clone.position.x, 6-((abs(clone.position.x)+abs(clone.position.z))/2), clone.position.z)
				resource.add_child(clone)
	timer.start()

func _process(_delta):
	if upgrades.value["Rebirth"] != rebirths:
		for resource in $"Islands/Main Island".get_node("Resources").get_children():
			for node in resource.get_children():
				node.queue_free()
		for upgrade in upgrades.value:
			if upgrade != "Rebirth":
				upgrades.value[upgrade] = 0
				upgrades.cost[upgrade] = original.cost[upgrade]
		rebirths = upgrades.value["Rebirth"]
	if upgrades.value["PSize"]*2+8 != sprite.size.x:
		sprite.size.x = upgrades.value["PSize"]*2+8
	if upgrades.value["PSize"]*2+8 != sprite.size.z:
		sprite.size.z = upgrades.value["PSize"]*2+8
