extends Node2D
class_name HazWaterLeak
################################################################################
##                                  Constants                                 ##
################################################################################

################################################################################
##                                 Enumerators                                ##
################################################################################
enum {PUDDLE_TR = 1, PUDDLE_BR = 2, PUDDLE_TL = 3, PUDDLE_BL = 4} 

################################################################################
##                                  Variables                                 ##
################################################################################
@export_category("Hazard Settings")
@export_group("Puddles")
@export var time_till_puddle_kills    = 15 # The time in seconds for a puddle to KILL (from start)
@export var time_till_puddle_recesses = 30 # The time in seconds for a puddle to shrink (from full)
@export var puddle_max_size = 4
@export var puddle_target = 500
@export var chance_no_drip = 10 # The percent chance that leaking stops and or doesnt start

@export_category("Hazard Nodes")
@export var puddle_tr : AnimatedSprite2D # The puddle in the top    right of the rug
@export var puddle_br : AnimatedSprite2D # The puggle in the bottom right of the rug
@export var puddle_tl : AnimatedSprite2D # The puddle in the top    left  of the rug
@export var puddle_bl : AnimatedSprite2D # The puddle in the bottom left  of the rug

var game_controller : GameController: # instance of the game controller
	set(value): game_controller = value
var puddles = [] # An array of puddles

var rng = RandomNumberGenerator.new()

# Called when the node is created
func _ready() -> void:
	rng.set_seed(Time.get_ticks_usec())
	puddles = [Puddle.new(PUDDLE_TR, self, puddle_tr), Puddle.new(PUDDLE_BR, self, puddle_br),Puddle.new(PUDDLE_TL, self, puddle_tl),Puddle.new(PUDDLE_BL, self, puddle_bl)]
	
# called to tick hazard events
func haz_tick():
	for puddle : Puddle in puddles:
		puddle.tick()

# Attempts to spawn a new hazard
func haz_attempt_spawn():
	var new_drip = rng.randi_range(1, 4)
	var no_drip = rng.randi_range(0,100)
	for puddle : Puddle in puddles:
		# If the puddle is chosen and there is a chance for a drip
		if(puddle.puddle_id == new_drip and no_drip > chance_no_drip):
			puddle.leaking = true
		else: # turn the drip off
			puddle.leaking = false

func puddle_overflowed(puddle_id):
	print("Bucket overflowed")
	# Run consequence
	pass
	
################################################################################
##                                  Callbacks                                 ##
################################################################################
# Gets called when the puddles area is entered by the bucket
# A puddle ID enum is passed to this signal to determine which puddle the bucket is on
# Area should be on layer 9 so only bucket can be detected
func _on_puddle_area_entered(area: Area2D, extra_arg_0: int) -> void:
	if area.is_in_group("Bucket"): # double check is bucket, you never know
		for puddle : Puddle in puddles:
			# If the puddle is the one that was entered set bucketed to true
			if(puddle.puddle_id == extra_arg_0):
				puddle.bucketed = true
			else: # we can make the assumption that the bucket isnt elsewhere
				puddle.bucketed = false

# similar to the on entered signal but is used to determin when the bucket has left
# A puddle ID enum is passed to this signal to determine which puddle the bucket is on
# Area should be on layer 9 so only bucket can be detected
func _on_puddle_area_exited(area: Area2D, extra_arg_0: int) -> void:
	if area.is_in_group("Bucket"): # double check is bucket, you never know
		for puddle : Puddle in puddles:
			# If the puddle is the one that was entered set bucketed to true
			if(puddle.puddle_id == extra_arg_0):
				puddle.bucketed = false

################################################################################
##                               Member Class                                 ##
################################################################################
# An instance of a puddle
class Puddle:
	var puddle_size = 0        # Size of the puddle in sprite indexes
	var puddle_progression = 0 # The size of the puddle in game code
	var puddle_id = 0          # What puddle am I
	var puddle_grow_speed      # grow speed calculated
	var puddle_shrink_speed    # shrink speed calculated
	var bucketed = false       # If the puddle has a bucket on it
	var leaking = false         # Am I leaking?
	var haz : HazWaterLeak     # Instance of the hazard
	var sprite : AnimatedSprite2D
	
	# Constructor
	func _init(puddle_id, hazard : HazWaterLeak, sprite : AnimatedSprite2D) -> void:
		self.puddle_id = puddle_id
		self.haz = hazard
		self.sprite = sprite
		puddle_grow_speed   = haz.puddle_target / haz.time_till_puddle_kills
		puddle_shrink_speed = haz.puddle_target / haz.time_till_puddle_recesses
	
	# Ticks called every second and checks if puddle overflows
	func tick():
		#debug print
		if(leaking):
			print("Puddle {id}".format({"id": puddle_id}))
			print("Bucket: {b}".format({"b": bucketed}))
			print("{pp}/{pt}".format({"pp": puddle_progression, "pt": haz.puddle_target}))
		
		# update the puddle progressions
		if(bucketed or !leaking): # Start recessing
			puddle_progression = clamp(puddle_progression - puddle_shrink_speed, 0, haz.puddle_target)
		elif(leaking and !bucketed):         # Start growing
			puddle_progression = clamp(puddle_progression + puddle_grow_speed, 0, haz.puddle_target)
			# Has the puddle maxxed and overflowed
			if(puddle_progression >= haz.puddle_target):
				haz.puddle_overflowed(puddle_id)
		
		# update the puddle sprite  # also this line is pain just let me create a util class and let me include that its not that hard i dont want to have to write the same funciton in every class or do weird object chaining or write global scene scripts have to load them and pull from that with children. I just want to include util.gd thats all.
		puddle_size = clamp(haz.game_controller.map(puddle_progression, 0, haz.puddle_target, 0, haz.puddle_max_size), 0, haz.puddle_max_size)
		sprite.set_frame(puddle_size)
