class_name Router
#region Interactable boiler plate
extends Interactable

# Is called when interacted with
# to get the instance of the player use _player from parent.
func interact() -> void:
	# Raise a flag since this will block the player _process() until the code path finishes
	# tho probably not a terrible thing since nothing else will be happening on that thread
	# ¯\_(ツ)_/¯
	# if interact available
	print("Interacting Router")
	_flag_interacted = true
#endregion
################################################################################
##                                  Constants                                 ##
################################################################################
const SIGNAL_MAX = 500   # Used in calculations the maximum signal integrity
const SIGNAL_BEGIN_FAIL = SIGNAL_MAX - 100
const DIAL_MIN_DEG = -45 # -| 
const DIAL_MAX_DEG = 135 #  |
const LRG_MIN_DEG  = 116 #  |- Positions in rotations for the dials
const LRG_MAX_DEG  = 244 #  |
const SM_MIN_DEG   = -60 #  |
const SM_MAX_DEG   = 60  # _|
const LEFT  = -1
const RIGHT = 1

################################################################################
##                                  Variables                                 ##
################################################################################
@export_category("Hazard Settings")
@export var signal_integrity = SIGNAL_MAX
@export var degrade_time_max = 30
@export var degrade_time_min = 15
@export var dial_speed_sec : float  = 225.0 # Speed of the dial in deg/sec
var dial_speed : float = dial_speed_sec / 60.0 # Converted to deg per physim emulation per seconds

@export var current_degradation = SIGNAL_MAX / degrade_time_max

@export_category("Hazard Nodes")
@export var game_controller : GameController
@export var dial_area : Area2D
@export var lrg_gr_area : Area2D
@export var sm_gr_area : Area2D
@export var dial       : Sprite2D
@export var dial_range : Sprite2D
@export var dial_ui : Control
@export var placeholde_light : Polygon2D # TODO Replace with animated sprite and frames and animation

# local variables
var _flag_interacted  = false
var playing_dial      = false
var dial_direction    = RIGHT
var button_flag = false
var already_interacted = false
var storm_intensity = 0
var kick_flag = false
var rng = RandomNumberGenerator.new()

################################################################################
##                                  Functions                                 ##
################################################################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.set_seed(Time.get_ticks_usec())
	can_interact = false

# Called every phys sim frame fixed to 60 sim calls from the engine per second
func _physics_process(delta: float) -> void:
	var _unused = delta
	# If the game is open we will play the dial animation
	if(playing_dial):
		# Lets space also work
		if(Input.is_action_just_pressed("player_special") or button_flag):
			playing_dial = false
			# Evaluate game state
			kick()
			
		# Flip direction of dial
		if(dial.rotation_degrees >= DIAL_MAX_DEG): dial_direction = LEFT
		elif(dial.rotation_degrees <= DIAL_MIN_DEG): dial_direction = RIGHT

		# Update dial position
		dial.rotation_degrees = clamp(dial.rotation_degrees + (dial_speed * dial_direction), DIAL_MIN_DEG, DIAL_MAX_DEG)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var _unused = delta
	if(_flag_interacted):
		open_ui()
		_flag_interacted = false

# Called to tick hazard events
func haz_tick(storm_intensity):
	self.storm_intensity = storm_intensity
	# recalculate degradation speed based on storm intensity 
	current_degradation = SIGNAL_MAX / game_controller.map(storm_intensity, 0, 10, degrade_time_max, degrade_time_min)
	
	# Signal degrade
	signal_integrity = clamp(signal_integrity - current_degradation, 0, SIGNAL_MAX)
	
	if(signal_integrity < SIGNAL_BEGIN_FAIL):
		if(!already_interacted): can_interact = true
		# TODO This is where youll need to call to change the router colors
		placeholde_light.color = Color(game_controller.map(signal_integrity, SIGNAL_BEGIN_FAIL, 0, 0.833, 1),game_controller.map(signal_integrity, SIGNAL_BEGIN_FAIL, 0, 0.833, 0) ,0)
	else:
		can_interact = false
		placeholde_light.color = Color(0,0.663,0)
		
	if(signal_integrity > 0):
		game_controller.upload_speed = clamp(game_controller.map(signal_integrity, 0, SIGNAL_BEGIN_FAIL, 1, game_controller.UPLOAD_MAX_SPEED), 1, game_controller.UPLOAD_MAX_SPEED)
		game_controller.upload_interupted = false
	else:
		game_controller.upload_speed = 0
		game_controller.upload_interupted = true

# Open the dial kicker
func open_ui():
	# set the color wheel
	var size_roll = rng.randi_range(0, 100)
	var position_roll = rng.randi_range(0,100)
	
	if(size_roll > game_controller.map(storm_intensity, 0,10, 10, 60)):
		dial_range.rotation_degrees = game_controller.map(position_roll,0,100,LRG_MIN_DEG, LRG_MAX_DEG)
	else:
		dial_range.rotation_degrees = game_controller.map(position_roll,0,100,SM_MIN_DEG, SM_MAX_DEG)
	dial.rotation_degrees = DIAL_MIN_DEG
	
	
	# open the ui
	playing_dial = true
	_player.can_move = false
	can_interact = false
	already_interacted = true
	dial_ui.visible = true

func close_ui():
	_player.can_move = true
	already_interacted = false
	can_interact = false # wait until the router falls below the first speed reduction
	dial_ui.visible = false
	
# Kick the router, Evaluate and score
func kick():
	print("Kicking")
	playing_dial = false
	var qte_hit = false
	if dial_area.has_overlapping_areas():
		for area : Area2D in dial_area.get_overlapping_areas():
			if(area.is_in_group("dial_green")):
				
				qte_hit = true
				signal_integrity = SIGNAL_MAX
	if(qte_hit):
		print("You Hit Green!")
		await get_tree().create_timer(0.75).timeout
		close_ui()	
	else:
		print("You Hit Red")
		await get_tree().create_timer(0.75).timeout
		playing_dial = true


################################################################################
##                                  Callbacks                                 ##
################################################################################
func _on_button_pressed() -> void:
	if(playing_dial): kick()
