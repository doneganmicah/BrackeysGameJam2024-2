class_name SurgeLine
extends Path2D

@export var cable_line : Line2D
@export var surge_line : Line2D
@export var haz_controller : HazPowerSurge
@export var animation : AnimationPlayer
@export var popup : Sprite2D
@export var anim_name : String

@export_range(0,100) var surge_range : int:
	set(value): surge_range = clamp(value,0,100)
var surging = false:
	get: return surging
	set(value): surging = value 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cable_line.clear_points()
	for point in self.curve.get_baked_points():
		cable_line.add_point(point + self.position)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var _unused = delta
	surge_line.clear_points()
	
	if(surge_range >= 100):
		# Maxed surge line
		haz_controller.surged()
	
	if (surging):
		popup.visible = true
		if(!animation.is_playing()):
			animation.play(anim_name)
	else:
		if(animation.is_playing()):
			animation.stop()
		popup.visible = false
		
		animation.stop()
	
	var pointArray = self.curve.get_baked_points()
	var total_points = pointArray.size()
	var limit = map(surge_range, 0, 100, 0, total_points )
	for i in limit:
		surge_line.add_point(pointArray[i])


# A form of interpolation that maps one range of values onto another range and returns the mapping of a given value
# Example map(5, 0, 10, 0, 100) returns 50 as it maps 0-10 onto 0-100
func map(value, in_min, in_max, out_min, out_max) -> float:
	return ((value - in_min) * (out_max - out_min)) / (in_max - in_min) + out_min
