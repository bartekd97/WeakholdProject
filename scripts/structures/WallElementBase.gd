extends "res://scripts/structures/StructureBase.gd"

#warning-ignore:unused_signal

signal build_wall(monitor)


export(PoolVector3Array) var connector_positions : PoolVector3Array


func _init():
	connect("build_wall", self, "_on_build_wall")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_build_wall(monitor: WallMonitor):
	monitor.add_wall_build(global_transform.origin, global_transform.xform(connector_positions))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
