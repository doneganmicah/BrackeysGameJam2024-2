class_name BreakerBox
#region Interactable boiler plate
extends Interactable

# Is called when interacted with
# to get the instance of the player use _player from parent.
func interact() -> void:
	# Raise a flag since this will block the player _process() until the code path finishes
	# tho probably not a terrible thing since nothing else will be happening on that thread
	# ¯\_(ツ)_/¯
	# if interact available
	_flag_interacted = true
#endregion

################################################################################
##                                  Constants                                 ##
################################################################################
const DESTROYED = 2 # When the electricla grid is permenantly ruined
const        ON = 1 # When the electrical grid is operating normally
const       OFF = 0 # When the electrical grid is disconnected

################################################################################
##                                  Variables                                 ##
################################################################################
@export_range(0, 2) var power_status = ON:
	get: return power_status
	set(value): power_status = value
@export var game_controller : GameController

# local variables
var _flag_interacted = false

################################################################################
##                                  Functions                                 ##
################################################################################
func _ready() -> void:
	power_status = OFF
	can_interact = true

func _process(delta: float) -> void:
	# Enable interaction when power goes off 
	if(power_status == ON):    can_interact = false
	elif(power_status == OFF): can_interact = true
	else:                      can_interact = false
	
	if _flag_interacted:
		run_switch()
		_flag_interacted = false
	pass

# lightning flash
func draw_lightning():
	pass
	
# Run switch UI
func run_switch():
	# for now just turn the lights on
	power_status = ON
	pass
