extends Node

@export var health : int
# Stats
@export var stats = {
	"Points" : -1,
	"Food" : 0,
	"Wood" : 0,
	"Stone" : 0,
	"Gold" : 0,
	"Cactus" : 0,
	"Sand" : 0,
	"Dirt" : 0,
	"Glass" : 0,
	"Coal" : 0,
}

@export var colors = {
	"Points" : Color(1,1,1),
	"Food" : Color(1,0.13,0.5),
	"Wood" : Color(0.67,0.33,0.13),
	"Stone" : Color(0.5,0.5,0.5),
	"Gold" : Color(1,0.75,0.25),
	"Cactus" : Color(0.25,0.5,0.19),
	"Sand" : Color(1,0.88,0.63),
	"Dirt" : Color(0.64,0.41,0.32),
	"Glass" : Color(0.75,1,1),
	"Coal" : Color(0.25,0.25,0.25),
}
