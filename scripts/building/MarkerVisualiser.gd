extends Spatial

class_name MarkerVisualiser

export(Resource) var marker_resource

var object_pool := preload("res://scripts/utility/ObjectPoolt.gd").new()
var markers = {}
var current_marker : GridMarker = null
var current_marker_position : Vector3 = Vector3.ZERO

func register_marker(position: Vector3):
	if not markers.has(position):
		var obj: GridMarker = object_pool.get_next(marker_resource)
		add_child(obj)
		obj.translation = position
		if current_marker_position == position:
			current_marker = obj
			obj.activate()
		markers[position] = obj

func unregister_marker(position: Vector3):
	var obj: GridMarker = markers.get(position)
	if obj:
		object_pool.make_free(obj)
		markers.erase(position)

func select_marker(position: Vector3):
	if current_marker:
		current_marker.deactivate()
	current_marker = markers.get(position)
	current_marker_position = position
	if current_marker:
		current_marker.activate()
