class_name PowerStrip
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

################################################################################
##                                  Variables                                 ##
################################################################################
@export var haz_controller: HazPowerSurge
@export var animation : AnimationPlayer
@export var animation_name : String
@export var index : int

# local variables
var _flag_interacted = false

################################################################################
##                                  Functions                                 ##
################################################################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	can_interact = true
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var _unused = delta
	if(_flag_interacted):
		print("fix Surge")
		haz_controller.fix_surge(index)
		_flag_interacted = false
