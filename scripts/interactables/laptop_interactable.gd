class_name Laptop
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
@export_category("Settings")

@export_category("Nodes")
@export var UI_title : Control
@export var UI_laptop : Control

# local variables
var _flag_interacted = false

################################################################################
##                                  Functions                                 ##
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
