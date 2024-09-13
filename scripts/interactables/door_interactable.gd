class_name BackDoor
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
const NUMBER_FRAMES = 6

################################################################################
##                                  Variables                                 ##
################################################################################
@export_category("Hazard Settings")
@export var time_till_puddle_kills = 20
@export var time_till_puddle_recesses = 25
@export var puddle_target = 500

@export_category("Hazard Nodes")
@export var door_sprite : AnimatedSprite2D
@export var door_puddle : AnimatedSprite2D
@export var game_controller : GameController
@export var breaker_box : BreakerBox

# local variables
var _flag_interacted = false
var puddle_grow_speed   = puddle_target / time_till_puddle_kills
var puddle_shrink_speed = puddle_target / time_till_puddle_recesses
var puddle_progression = 0
var door_open = false


################################################################################
##                                  Functions                                 ##
################################################################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	can_interact = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _flag_interacted:
		swing_close()
		_flag_interacted = false

# Tick to spread door puddle
func haz_tick():
	
	if(door_open):
		puddle_progression = clamp(puddle_progression + puddle_grow_speed, 0, puddle_target)
	else:
		puddle_progression = clamp(puddle_progression - puddle_shrink_speed, 0, puddle_target)
	
	var puddle_size = game_controller.map(puddle_progression, 0, puddle_target, 0, NUMBER_FRAMES - 2)
	
	#print("Puddle Tick")
	#print("{pp}/{pt}".format({"pp": puddle_progression, "pt": puddle_target}))
	#print(puddle_size)
	
	if(puddle_progression >= puddle_target):
		door_puddle.set_frame(NUMBER_FRAMES - 1)
		breaker_box.break_power()
	else:
		door_puddle.set_frame(puddle_size)
		
# Door swing open event
func swing_open():
	if(door_open): return
	door_sprite.play("SwingOpen")
	await door_sprite.animation_finished
	door_sprite.play("open")
	door_open = true
	can_interact = true

# Door swing close event
func swing_close():
	door_sprite.play("SwingClose")
	await door_sprite.animation_finished
	door_sprite.play("closed")
	door_open = false
	can_interact = false

################################################################################
##                                  Callbacks                                 ##
################################################################################
