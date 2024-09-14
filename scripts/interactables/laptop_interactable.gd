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
	if(UI_laptop.is_visible_in_tree() == true):
		_player.can_move = true
		UI_laptop.visible = false
	else:
		_player.can_move = false
		UI_laptop.visible = true
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
@export var rect_start : Control
@export var rect_tutorial: Control
@export var rect_credits : Control
@export var UI_start : Control
@export var UI_laptop : Control
@export var panel : Panel
@export var player : AnimationPlayer
@export var emitter : CPUParticles2D

@export var game_controller : GameController

# local variables
var _flag_interacted = false
var _buffer_signal = true

################################################################################
##                                  Functions                                 ##
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	can_interact = true
	UI_title.visible = true
	UI_start.visible = false
	panel.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(_buffer_signal):
		if(Input.is_action_just_pressed("player_special")):
			_buffer_signal = false
			boost_progress()
			await get_tree().create_timer(0.2).timeout
			_buffer_signal = true
	var _unused = delta

func boost_progress():
	emitter.emitting = true
	game_controller.upload_progression += 1

func _on_tutorial_button_down() -> void:
	print("tutorial")
	rect_start.visible = false
	rect_tutorial.visible = true
	pass # Replace with function body.

func _on_send_mail_down() -> void:
	# Start the game!
	player.play("start_to_game")
	#UI_start.visible = false
	#panel.visible = false
	#game_controller.start_game()

func _on_credit_button_down() -> void:
	print("credit")
	rect_start.visible = false
	rect_credits.visible = true

func _on_tutorial_back_down() -> void:
	rect_start.visible = true
	rect_tutorial.visible = false
	
func _on_credits_back_down() -> void:
	rect_start.visible = true
	rect_credits.visible = false
	
func _on_start_button_down() -> void:
	player.play("title_fade_to_start")

func start_game():
	UI_start.visible = false
	panel.visible = false
	game_controller.start_game()
	

func _on_buff_button_down() -> void:
	if(_buffer_signal):
		_buffer_signal = false
		boost_progress()
		await get_tree().create_timer(0.2).timeout
		_buffer_signal = true
	else:
		pass
