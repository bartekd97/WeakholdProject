extends Spatial


export(float) var move_speed = 35.0
export(int) var pixel_margin = 1
export(Vector2) var scale_range = Vector2(0.4,2)
export(float) var scale_zoom_step = 0.2
export(float) var scale_zoom_speed = 1.0
export(float) var rotate_speed = 0.05

onready var viewport = get_viewport()
onready var target_scale = scale.x

var rotating_by_mouse = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var mouse = viewport.get_mouse_position()
	var move_vector = Vector3.ZERO
	
	# left-right movement
	if mouse.x <= pixel_margin or Input.is_action_pressed("camera_move_left"):
		move_vector -= transform.basis.x
		move_vector.y = 0
	elif mouse.x >= viewport.size.x - pixel_margin or Input.is_action_pressed("camera_move_right"):
		move_vector += transform.basis.x
		move_vector.y = 0
		
	# up-down movement
	if mouse.y <= pixel_margin or Input.is_action_pressed("camera_move_up"):
		move_vector -= transform.basis.z
		move_vector.y = 0
	elif mouse.y >= viewport.size.y - pixel_margin or Input.is_action_pressed("camera_move_down"):
		move_vector += transform.basis.z
		move_vector.y = 0
		
	# zoom
	if Input.is_action_just_released("camera_zoom_in") and target_scale > scale_range.x:
		target_scale -= scale_zoom_step
	elif Input.is_action_just_released("camera_zoom_out") and target_scale < scale_range.y:
		target_scale += scale_zoom_step
		
	var scale_diff = scale.x - target_scale
	if abs(scale_diff) > 0.01:
		var zoom_scalar = sqrt(abs(scale_diff)) * sign(scale_diff)
		scale -= Vector3.ONE * (zoom_scalar * scale_zoom_speed * delta)
#		zoom_vector = -transform.basis.z * sqrt(abs(height_diff)) * sign(height_diff)

	translation += (move_vector.normalized() * move_speed) * delta


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_MIDDLE:
			rotating_by_mouse = event.pressed
	if event is InputEventMouseMotion and rotating_by_mouse:
		rotate(Vector3.UP, -event.relative.x * rotate_speed)
