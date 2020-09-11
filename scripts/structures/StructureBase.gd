extends Spatial

class_name StructureBase

#warning-ignore:unused_signal

signal build
signal mark_preview_availability(availability)

onready var detection_area = $DetectionArea
onready var collision_body = $CollisionBody

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("build", self, "_on_build")
	call_deferred("remove_child", collision_body)

func _on_build():
	call_deferred("remove_child", detection_area)
	call_deferred("add_child", collision_body)
	
	PathfindingService.query_update_gridpart_connectivity(
		translation,
		2
	)

	
func can_be_build() -> bool:
	return (detection_area as Area).get_overlapping_bodies().size() == 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
