extends CharacterBody2D
class_name Player

@export var speed = 50.0
@export var push_force = 5
@export var can_move = false:
	set(value): can_move = value
	get: return can_move

var _interactable : Interactable # The instance of the interactable within interaction range

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var _unused = delta # remove unused var warning
	if(!can_move): return
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("player_left", "player_right", "player_up", "player_down")
	
	if direction:
		if direction.x > 0:
			sprite.play('move_horizontal')
			sprite.flip_h = 0
		elif direction.x < 0:
			sprite.play('move_horizontal')
			sprite.flip_h = 1
		elif direction.y > 0:
			sprite.play('move_down')
		elif direction.y < 0:
			sprite.play('move_up')
		
		velocity = direction * speed
	else:
		match sprite.animation:
			'move_horizontal':
				sprite.play('idle_horizontal')
			'move_down':
				sprite.play('idle_down')
			'move_up':
				sprite.play('idle_up')
		
		velocity = Vector2.ZERO
	
	# This code handles the pushing of the bucket
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collision_bucket = collision.get_collider()
		
		if collision_bucket.is_in_group("Bucket"):
			collision_bucket.apply_central_impulse(-collision.get_normal() * push_force)
			
	move_and_slide()		
	

func _process(delta: float) -> void:
	var _unused = delta # remove unused var warning
	if (Input.is_action_just_pressed("player_interact")):
		if (_interactable != null):
			if(_interactable.can_interact):
				_interactable.interact()
			else:
				print("cant do that yet")
	return

###############################################################	
##                        Mutators                           ##
###############################################################
# Get and Set the interactable
func get_interactable() -> Interactable: return _interactable
func set_interactable(interactee:Interactable): _interactable = interactee
