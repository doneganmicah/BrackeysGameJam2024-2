extends CharacterBody2D
class_name Player

@export var speed = 50.0
@export var push_force = 5

var _interactable : Interactable # The instance of the interactable within interaction range

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("player_left", "player_right", "player_up", "player_down")
	
	if direction:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	
	# This code handles the pushing of the bucket
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collision_bucket = collision.get_collider()
		
		if collision_bucket.is_in_group("Bucket"):
			collision_bucket.apply_central_impulse(-collision.get_normal() * push_force)
			
	move_and_slide()		
	

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("player_interact")):
		if (_interactable != null):
			print("Interacting with ")
			_interactable.interact()
	return

###############################################################	
##                        Mutators                           ##
###############################################################
# Get and Set the interactable
func get_interactable() -> Interactable: return _interactable
func set_interactable(interactee:Interactable): _interactable = interactee
