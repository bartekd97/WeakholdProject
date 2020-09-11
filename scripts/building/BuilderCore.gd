extends SpatialEx

class_name BuilderCore

export(int, LAYERS_3D_PHYSICS) var raycast_mask
export(PoolStringArray) var available_marker_visualisers

onready var marker = $Marker
onready var viewport = get_viewport()
onready var camera = viewport.get_camera()

var marker_visualisers = {}
var current_marker_visualiser : MarkerVisualiser = null

var grid_snap := 1.0
var force_unavailable_build := false

var current_hit_pos := Vector3.ZERO
var object_pool := preload("res://scripts/utility/ObjectPoolt.gd").new()
var preview_objects = []
var preview_unavailability_counter := 0


func is_build_available():
	return preview_unavailability_counter == 0 and not force_unavailable_build

# virtual functions

func _hit_pos_changed(new_pos: Vector3):
	pass
	
func _update_preview():
	pass
	
func _object_built(obj: Spatial):
	pass
	

# Called when the node enters the scene tree for the first time.
func _ready():
	for visualiser_name in available_marker_visualisers:
		marker_visualisers[visualiser_name] = get_node(visualiser_name)
		(marker_visualisers[visualiser_name] as MarkerVisualiser).visible = false

func _physics_process(delta):
	var mouse_position = viewport.get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_normal = camera.project_ray_normal(mouse_position)
	
	var hit = get_world().direct_space_state.intersect_ray(ray_origin, ray_origin + ray_normal * 100.0, [], raycast_mask)
	if hit:
		var hit_pos := (hit.position as Vector3)
		hit_pos.x = round(hit_pos.x / grid_snap) * grid_snap
		hit_pos.y = round(hit_pos.y / grid_snap) * grid_snap
		hit_pos.z = round(hit_pos.z / grid_snap) * grid_snap
		
		if not current_hit_pos.is_equal_approx(hit_pos):
			call_deferred("new_hit_pos", hit_pos)
	

func _process(delta):
	var prev_availability = is_build_available()
	var force_availability_update = preview_unavailability_counter == -1
	
	preview_unavailability_counter = 0
	for obj in preview_objects:
		if not (obj as StructureBase).can_be_build():
			preview_unavailability_counter += 1
	
	var availability = is_build_available()		
	
	if prev_availability != availability or force_availability_update:
		for obj in preview_objects:
			(obj as StructureBase).emit_signal("mark_preview_availability", availability)


func new_hit_pos(hit_pos: Vector3):
	# update hit pos
	marker.translation = hit_pos
	current_hit_pos = hit_pos
	if current_marker_visualiser:
		current_marker_visualiser.select_marker(current_hit_pos)
	_hit_pos_changed(current_hit_pos)
	
	# update preview
#	preview_objects.invert()
	for obj in preview_objects:
		object_pool.make_free(obj, false)
	object_pool.invert_queue()
	var to_unparent = preview_objects.duplicate()
	preview_objects.clear()
	preview_unavailability_counter = -1
	_update_preview()
	for obj in to_unparent:
		if not preview_objects.has(obj):
			obj.translation = Vector3(0, -100, 0)
#			obj.get_parent().remove_child(obj)



func add_preview_object(obj: Resource, position: Vector3, rotation: float):
	var spawned: StructureBase = object_pool.get_next(obj)
	spawned.translation = position
	spawned.rotation.y = rotation
	spawned.emit_signal("mark_preview_availability", is_build_available())
	if not spawned.get_parent():
		get_tree().get_root().add_child(spawned)
	preview_objects.append(spawned)

func build_from_preview():
	for obj in preview_objects:
		if is_build_available():
			object_pool.consume(obj)
			(obj as Node).emit_signal("build")
			_object_built(obj)
		else:
			object_pool.make_free(obj, false)
			obj.translation = Vector3(0, -100, 0)
	preview_objects.clear()

func set_current_marker_visualiser(name: String = ""):
	if current_marker_visualiser:
		current_marker_visualiser.visible = false
	current_marker_visualiser = marker_visualisers.get(name)
	if current_marker_visualiser:
		current_marker_visualiser.visible = true
		current_marker_visualiser.select_marker(current_hit_pos)
		
