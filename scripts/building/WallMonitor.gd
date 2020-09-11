extends Spatial

class_name WallMonitor

signal add_wall_connection(position)
signal remove_wall_connection(position)

# key is Vec3 point, value is array of Vec3 possible connections (in world space)
var busy_cells = {}
# key is Vec3 connection point, value is array of it's master busy Vec3 points
var available_connections = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func add_wall_build(position: Vector3, neightbours: PoolVector3Array):
	position = position.round()
	busy_cells[position] = neightbours
	if available_connections.has(position):
		available_connections.erase(position)
		emit_signal("remove_wall_connection", position)
	for nb in neightbours:
		nb = nb.round()
		if not busy_cells.has(nb):
			if not available_connections.has(nb):
				available_connections[nb] = []
				emit_signal("add_wall_connection", nb)
			(available_connections[nb] as Array).append(position)
			
func get_connections(position: Vector3):
	return available_connections.get(position.round(), [])
	
