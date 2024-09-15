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
@export var max_power = 500
@export var power_drain = 25
@export var power_charge = 8
var current_power = 500


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
@export var power : BreakerBox
@export var battery : Control
@export var batt_material : Sprite2D
@onready var keyboard_fx = $CanvasLayer/TitleCard/Keyboard

# local variables
var _flag_interacted = false
var _buffer_signal = true
var animating = false

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

func haz_tick():
	if(power.power_status != power.ON):
		current_power = clamp(current_power - power_drain, 0,max_power)
	else:
		current_power = clamp(power_charge + current_power, 0,max_power)
	
	batt_material.material.set_shader_parameter("health", game_controller.map(current_power as float, 0.0, max_power as float, 0.0, 1.0))
	
	if(current_power < max_power):
		battery.visible = true
	elif(current_power == max_power):
		battery.visible = false
	
	if(current_power <= 0):
		game_controller.lose_game(game_controller.LOSE_BATTERY)
	

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
	if(!animating):
		$CanvasLayer/Button.visible = false
		animating = true
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
	if(!animating):
		keyboard_fx.stop()
		animating = true
		player.play("title_fade_to_start")

func done_animation():
	animating = false

func music_call():
	game_controller.audio_manager.start_ph2()

func start_game():
	animating = false
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
