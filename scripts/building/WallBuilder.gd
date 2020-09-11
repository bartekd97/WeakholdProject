extends BuilderCore

const PI_HALF = PI / 2.0
const PI_QUARTER = PI / 4.0

export(Resource) var straight_segment
export(Resource) var diagonal_segment
export(Resource) var straight_90
export(Resource) var diagonal_90
export(Resource) var left_45
export(Resource) var right_45
export(float) var size_in_grid = 2.0


var creating := false
var startup_pos := Vector3.ZERO
var target_pos := Vector3.ZERO
var startup_connections = []
var creating_direction := Vector3.FORWARD
var creating_angle := 0.0
var creating_connection_angle_deg := 0
var creating_count := 0
var creating_diagonal := false
var creating_forward_connection := Vector3.ZERO

onready var wall_monitor = $WallMonitor


# Called when the node enters the scene tree for the first time.
func _ready():
	grid_snap = 2.0
	set_current_marker_visualiser("Wall Connectors Visualiser")
	#set_enabled(false)
	
	
	
func _hit_pos_changed(new_pos: Vector3):
	if not creating:
		return
	
	target_pos = new_pos
	var delta = target_pos - startup_pos
	
	creating_angle = rad2deg(atan2(delta.x, delta.z))
	creating_angle = round(round(creating_angle / 45.0) * 45.0)
	
	if startup_connections:
		var con_delta = startup_pos - startup_connections[0]
		var con_angle = rad2deg(atan2(con_delta.x, con_delta.z))
		con_angle = round(round(con_angle / 45.0) * 45.0)
		creating_connection_angle_deg = con_angle - creating_angle
		if creating_connection_angle_deg > 180:
			creating_connection_angle_deg -= 360
		elif creating_connection_angle_deg < -180:
			creating_connection_angle_deg += 360
	else:
		creating_connection_angle_deg = 0
			
	force_unavailable_build = abs(creating_connection_angle_deg) > 90
	
	creating_angle = deg2rad(creating_angle)
	creating_direction = Vector3(
		round(sin(creating_angle)) * size_in_grid,
		delta.normalized().y * size_in_grid,
		round(cos(creating_angle)) * size_in_grid
	)
	if (delta == Vector3.ZERO):
		creating_count = 0
	else:
		creating_count = ceil(delta.length() / creating_direction.length())
	creating_diagonal = (abs(creating_direction.x) + abs(creating_direction.z)) > size_in_grid


func _update_preview():
	if not creating:
		return

	var object = straight_segment if not creating_diagonal else diagonal_segment
	var angle = creating_angle if not creating_diagonal else creating_angle - PI_QUARTER

	var position = startup_pos
	if startup_connections and creating_connection_angle_deg != 0:
		if abs(creating_connection_angle_deg) == 90:
			add_preview_object(
				diagonal_90 if creating_diagonal else straight_90,
				position,
				angle if creating_connection_angle_deg == 90 else angle + PI_HALF
			)
		elif creating_connection_angle_deg == 45:
			add_preview_object(
				right_45 if creating_diagonal else left_45,
				position,
				angle if creating_diagonal else angle + PI
			)
		elif creating_connection_angle_deg == -45:
			add_preview_object(
				left_45 if creating_diagonal else right_45,
				position,
				angle if creating_diagonal else angle + PI_HALF
			)
	else:
		add_preview_object(object, position, angle)
	
	for i in range(creating_count - 1):
		position += creating_direction
		add_preview_object(object, position, angle)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed and not creating:
				begin_creating()
			elif not event.pressed and creating:
				end_vreating()
				
				
func _object_built(obj: Spatial):
	obj.emit_signal("build_wall", wall_monitor)


func begin_creating():
	creating = true
	grid_snap = 1.0
	startup_pos = current_hit_pos
	startup_connections = wall_monitor.get_connections(startup_pos)
	_hit_pos_changed(startup_pos)
	
func end_vreating():
	creating = false
	grid_snap = 2.0
	build_from_preview()
	
