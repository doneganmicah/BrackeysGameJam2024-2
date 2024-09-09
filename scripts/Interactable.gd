extends Node2D

class_name Interactable

@export var collider : CollisionObject2D # Instance of collider used to detect the interactable
@export var sprite   : AnimatedSprite2D  # Instance of the sprite, 4y? idk yet?

var _player : Player:
	get: return _player

# The primary function to be overriden by the inheriting class
func interact() -> void:
	print("Interacted")

# The player has entered the range of interaction
func _on_body_entered(body: Node2D) -> void:
	if(body is Player):
		print("Entered range of interaction")
		_player = body as Player
		_player.set_interactable(self)

# The player has left the range of interaction
func _on_body_exited(body: Node2D) -> void:
	if(body is Player):
		print("Left range of interaction")
		_player = body as Player
		_player.set_interactable(null)
