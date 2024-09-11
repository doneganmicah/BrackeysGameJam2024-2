extends Node2D
class_name HazWaterLeak
################################################################################
##                                  Constants                                 ##
################################################################################

################################################################################
##                                 Enumerators                                ##
################################################################################
enum {PUDDLE_TR, PUDDLE_BR, PUDDLE_TL, PUDDLE_BL} 

################################################################################
##                                  Variables                                 ##
################################################################################
@export_category("Hazard Settings")

@export_category("Hazard Nodes")
@export var _puddle_tr : Area2D # The puddle in the top    right of the rug
@export var _puddle_br : Area2D # The puggle in the bottom right of the rug
@export var _puddle_tl : Area2D # The puddle in the top    left  of the rug
@export var _puddle_bl : Area2D # The puddle in the bottom left  of the rug
@export var game_controller : int# instance of the game controller

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func puddle_overflowed(puddle_id):
	pass

# An instance of a puddle
class puddle:
	@export_category("Hazard Settings")
	@export_group("Puddles")
	@export var time_till_puddle_kills    = 15 # The time in seconds for a puddle to KILL (from start)
	@export var time_till_puddle_recesses = 30 # The time in seconds for a puddle to shrink (from full)
	@export var puddle_size = 0
	@export var puddle_max_size = 5
	@export var puddle_progression = 0
	@export var puddle_target = 500
	
	var puddle_id = 0
	var puddle_grow_speed   = puddle_target / time_till_puddle_kills
	var puddle_shrink_speed = puddle_target / time_till_puddle_recesses
	var bucketed = false
	var hazard : HazWaterLeak
	
	func _init(puddle_id, hazard : HazWaterLeak) -> void:
		self.puddle_id = puddle_id
		self.hazard = hazard
	
	func tick():
		if(bucketed): # Start recessing
			puddle_progression = clamp(puddle_progression - puddle_shrink_speed, 0, puddle_target)
		else:         # Start growing
			puddle_progression = clamp(puddle_progression + puddle_grow_speed, 0, puddle_target)
			# Has the puddle maxxed and overflowed
			if(puddle_progression >= puddle_target):
				hazard.puddle_overflowed(puddle_id)
	
	
	
