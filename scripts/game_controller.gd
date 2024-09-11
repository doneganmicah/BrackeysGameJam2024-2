extends Node
class_name GameController
################################################################################
##                                  Constants                                 ##
################################################################################
const UPLOAD_MAX_SPEED = 5 # Maximum value that the upload speed can be set to
const MAX_GAME_TIME  = 600 # The maximum amount of time a round should last (10min)

################################################################################
##                                  Variables                                 ##
################################################################################
@export_category("Game Parameters")
@export_group("Upload bar")
@export var upload_progression : int: # The total progression achieved by the upload
	get: return upload_progression
	set(value): upload_progression = clamp(value, 0, upload_target)
@export var upload_target = 900: # The target which the upload progression is trying to reach
	get: return upload_target 
@export_range(0, UPLOAD_MAX_SPEED) var upload_speed = 5: # Current speed Units/Sec of the upload
	get: return upload_speed
	set(value): upload_speed = clamp(value, 0, UPLOAD_MAX_SPEED)
@export var upload_booster = 0: # Any special boosters to increase the upload speed beyond max
	get: return upload_booster  # Can be use in debugging to speed up the progression
	set(value): upload_booster = abs(value)

@export_group("Game time")
@export_range(120, MAX_GAME_TIME) var end_time = 270: # The time when the game round ends set to 270 (4m30s)
	get: return end_time
@export_range(0, MAX_GAME_TIME) var current_time = 0: # The current time of the round
	get: return current_time # Read-Only
@export var _time_multiplier = 1 # Speed the game up for debugging purposes, this also multiplies upload speed
@export_group("Hazards")

@export_category("Control Nodes")
@export var _player : Player        # Instance of the player
@export var _interval_timer : Timer # This is the instance of the Timer node which triggers every seccond

# Local variables
var _timer_flag : bool # Raises to signify the timer has expired

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(_timer_flag):
		update_progress()
		_timer_flag = false

# This function is used to start the game round
func start_game() -> void:
	print("starting game")
	_interval_timer.start() # Start the timer

# This function is used to stop the game and cleanup
func stop_game() -> void:
	print("ending the game")
	_interval_timer.stop() # Stop the timer
	# probably pass whatever parameters to the end screen needed 
	# or start some animation ui to show completion
	
# Updates the game progressions called every timer expiration (1 sec)
func update_progress():
	# Tick up the progression and timer
	upload_progression += (upload_speed + upload_booster) * abs(_time_multiplier) # can also be affected by the time multiplier
	current_time += 1 * abs(_time_multiplier)
	
	# Upload finished before time expired
	if(upload_progression >= upload_target):
		win_game()
	# Time expired before upload finished
	if(current_time >= end_time):
		lose_game()
		
	# DEBUG PRINTS
	print("Upload Progress:")
	print("{up}/{ut}".format({"up": upload_progression, "ut": upload_target}))
	var percent = map(upload_progression, 0, upload_target, 0, 100)
	print("{perc}%".format({"perc": percent }))
	print("Game Time:")
	print(current_time)
	print(get_clock_time())
# A game winning condition has been met.
func win_game():
	print("The game has been won")
	stop_game()

# A game losing condition has been met.
func lose_game():
	print("The game has been lost")
	stop_game()
	
# Return the current time of the game as a string interpolated between 11:50pm and 12:00am
func get_clock_time() -> String:
	var seconds = int(map(current_time, 0, end_time, 50, 60))
	if(seconds < 60):
		return "11:{time} pm".format({"time": seconds})
	else:
		return "12:00 am"

# A form of interpolation that maps one range of values onto another range and returns the mapping of a given value
# Example map(5, 0, 10, 0, 100) returns 50 as it maps 0-10 onto 0-100
func map(value, in_min, in_max, out_min, out_max) -> float:
	return ((value - in_min) * (out_max - out_min)) / (in_max - in_min) + out_min

################################################################################
##                                  Callbacks                                 ##
################################################################################
# Gets called when the timer reaches 1 second
func _on_timer_timeout() -> void:
	# I'm choosing to raise a flag here because from what im reading signals
	# are not threaded and basically raise an interupt on the Timer. I could
	# check this but I fear drifting can happen if given time. (probably microseconds)
	# To mitigate this I'm using a flag to quickly return out of the interupt.
	# Doing as little as possible in ISRs is the goal.
	_timer_flag = true
