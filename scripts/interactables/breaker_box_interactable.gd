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
@export var temp_bolt : Polygon2D

@export var btn_left : CheckButton
@export var btn_right : CheckButton
@export var btn_center : CheckButton
@export var temp_control : Control
@export var main_light   : PointLight2D

@export var animation : AnimationPlayer
@export var popup : Sprite2D

# local variables
var switches = []
var _flag_interacted = false
var draw_lightning = false:  # a flag to initiate the drawing of lightning
	set(value): draw_lightning = value
	get: return draw_lightning
var flicker_lights = false:
	set(value): flicker_lights = value
	get: return flicker_lights
var rng = RandomNumberGenerator.new() # not really bothering to seed this since it just bakes the animations

################################################################################
##                                  Functions                                 ##
################################################################################
func _ready() -> void:
	switches = [btn_left, btn_center, btn_right]
	rng.set_seed(Time.get_ticks_usec())
	power_status = ON
	for btn : CheckButton in switches:
		btn.button_pressed = true
	can_interact = true

# This is code I wrote to simulate flickering lights/lightning with LEDS
# I had to modify it a little
var flicked = false
var flicker = 0
var flick_speed = 2
var flick_count = 0
var length_counter = 0
func _physics_process(delta: float) -> void:
	var _unused = delta # remove unused var warning
	if(flicker_lights and power_status == ON):
		if(!flicked):
			# Light off
			main_light.enabled = true
			if(rng.randi_range(0,100) < 10): flicked = true
		else:
			# Light on
			main_light.enabled = false
			flick_count += 1
			if(flick_count > flick_speed):
				flick_count = 0
				flick_speed *= 1.5
				flicked = false
				
		length_counter += 1
		if(length_counter > 120):
			flicked = false
			flicker = 0
			flick_speed = 2
			flick_count = 0
			length_counter = 0
			main_light.enabled = false
			flicker_lights = false


func _process(delta: float) -> void:
	var _unused = delta # remove unused var warning
	# Enable interaction when power goes off
	if(power_status == ON):    
		can_interact = false
		if(!flicker_lights): 
			main_light.enabled = true
	elif(power_status == OFF): 
		can_interact = true
		main_light.enabled = false
	else:                      
		can_interact = false
		main_light.enabled = false
	
	if _flag_interacted:
		run_switch()
		_flag_interacted = false


func break_power():
	if(power_status != ON): return
	# TODO: Power Break noise
	var index = rng.randi_range(0,2) 
	switches[index].button_pressed = false
	can_interact = true
	power_status = OFF
	popup.visible = true
	animation.play("popup")
	print("Power Outage")
	
# Run switch UI
func run_switch():
	# for now just turn the lights on
	temp_control.visible = true
	can_interact = false
	_player.can_move = false
	pass


func _on_breaker_switched(extra_arg_0: int) -> void:
	var good = 0
	print(extra_arg_0)
	for btn : CheckButton in switches:
		if btn.button_pressed: good += 1
	if(good == 3): 
		print("Power Restored")
		animation.stop()
		popup.visible = false
		_player.can_move = true
		temp_control.visible = false
		power_status = ON
