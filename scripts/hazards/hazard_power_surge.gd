extends Node2D
class_name HazPowerSurge

################################################################################
##                                  Constants                                 ##
################################################################################

################################################################################
##                                  Variables                                 ##
################################################################################
@export_category("Hazard Settings")
@export var time_till_kills_max = 45.0
@export var time_till_kills_min = 15.0
var surge_speed_min = 100.0 / time_till_kills_max
var surge_speed_max = 100.0 / time_till_kills_min
var surge_speed = 0.0 

@export_category("Hazard Nodes")
@export var surge_1 : SurgeLine
@export var surge_2 : SurgeLine
@export var surge_3 : SurgeLine
@export var surge_4 : SurgeLine
@export var game_controller : GameController

# local variables
var surge_lines = [surge_1, surge_2, surge_3, surge_4]
var rng = RandomNumberGenerator.new()

################################################################################
##                                  Functions                                 ##
################################################################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	surge_speed_min = 100.0 / time_till_kills_max
	surge_speed_max = 100.0 / time_till_kills_min
	rng.set_seed(Time.get_ticks_usec())
	surge_lines = [surge_1, surge_2, surge_3, surge_4]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_surge():
	print("create surge")
	var random = rng.randi_range(0, 3)
	surge_lines[random].surging = true
	print(random)

func haz_tick(storm_intensity):
	
	surge_speed = game_controller.map(storm_intensity,0,10, surge_speed_min, surge_speed_max)
	
	#debug prints
	print("Surging")
	print(surge_speed)
	print(time_till_kills_max)
	print(time_till_kills_min)
	print(surge_speed_min)
	print(surge_speed_max)
	
	for surge_line : SurgeLine in surge_lines:
		if(surge_line.surging):
			print("surgerbf")
			print(surge_line.surge_range)
			surge_line.surge_range = surge_speed + surge_line.surge_range
			print(surge_line.surge_range)

func fix_surge(index : int):
	surge_lines[index].surging = false
	surge_lines[index].surge_range = 0

func surged():
	game_controller.lose_game(game_controller.LOSE_SURGE)
