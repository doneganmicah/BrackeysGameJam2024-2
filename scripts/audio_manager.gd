extends Node2D
class_name AudioManager

@onready var ap_ph1 = $AudioStreamPlayer2D
@onready var ap_ph2 = $AudioStreamPlayer2D2
@onready var ap_ph3 = $AudioStreamPlayer2D3
@onready var ap_ph4 = $AudioStreamPlayer2D4
@onready var ap_ph5 = $AudioStreamPlayer2D5
@export var animation : AnimationPlayer

var phase = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	phase = 1
	ap_ph2.volume_db = -80
	ap_ph3.volume_db = -80
	ap_ph4.volume_db = -80
	ap_ph5.volume_db = -80
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func start_ph2():
	
	if(phase == 2): return
	print("1 to 2")
	animation.play("fade_1_to_2")
	phase = 2

func start_ph3():
	if(phase == 3): return
	print("2 to 3")
	animation.play("fade_2_to_3")
	phase = 3
	
func start_ph4():
	if(phase == 4): return
	print("3 to 4")
	animation.play("fade_3_to_4")
	phase = 4
	
func start_ph5():
	if(phase == 5): return
	print("4 to 5")
	animation.play("fade_4_to_5")
	phase = 5
