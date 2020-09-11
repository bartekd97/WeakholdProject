extends Spatial


class AStarGrid:
	var astar := AStar.new()
	var grid = {}
	var physics_layer = 0b1000000 # building
	var physics_state : PhysicsDirectSpaceState
	var raycast_shape : SphereShape
	
	func _init():
		raycast_shape = SphereShape.new()
		raycast_shape.radius = 0.2
	
	func add_point(position: Vector3):
		var id = astar.get_available_point_id()
		astar.add_point(id, position)
		grid[position] = {"id": id, "neightbours": []}
		
	func make_connection(a: Vector3, b: Vector3, bidirectional: bool = true):
		if not grid.has(a) or not grid.has(b):
			return
			
		var ida = grid[a].id
		var idb = grid[b].id
		
		astar.connect_points(ida, idb, false)
		grid[a].neightbours.append(b)
		
		if bidirectional:
			astar.connect_points(idb, ida, false)
			grid[b].neightbours.append(a)
	
	func get_point(position: Vector3):
		return grid.get(position)
		
	func update_raycast_point_disability(position: Vector3):
		var point = get_point(position)
		if point:
			var raycast = PhysicsShapeQueryParameters.new()
			raycast.set_shape(raycast_shape)
			raycast.set_collision_mask(physics_layer)
			raycast.set_transform(Transform(Basis.IDENTITY, position))
			var hit = physics_state.intersect_shape(raycast, 1)
			astar.set_point_disabled(point.id, hit.size() > 0)
			

var _astar := AStarGrid.new()
var _debug_mesh_renderer : MeshInstance
var _need_update_debug_renderer := true
var _raycast_update_tasks = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var before = OS.get_ticks_msec()
	initialize_grid(50)
	print("initialize_grid time ", OS.get_ticks_msec() - before)
	
	before = OS.get_ticks_msec()
	_debug_mesh_renderer = MeshInstance.new()
	_debug_mesh_renderer.translation = Vector3(0, 0.25, 0)
	get_tree().get_root().call_deferred("add_child", _debug_mesh_renderer)
	update_debug_mesh()
	print("update_debug_mesh time ", OS.get_ticks_msec() - before)
	


func _physics_process(delta):
	_astar.physics_state = get_world().direct_space_state
	if _raycast_update_tasks.size() > 0:
		var co = _raycast_update_tasks[0]
		while co is GDScriptFunctionState and co.is_valid():
			co = co.resume()
			_raycast_update_tasks[0] = co
			
		_raycast_update_tasks.remove(0)
	else:
		if _need_update_debug_renderer:
			update_debug_mesh()
			_need_update_debug_renderer = false


func initialize_grid(size: int):
	_astar = AStarGrid.new()
	_astar.astar.reserve_space(size*size*2)
	
	for x in range(-size,size+1):
		for y in range(-size,size+1):
			_astar.add_point(Vector3(x,0,y))
			
	for x in range(-size,size+1):
		for y in range(-size,size+1):
			var vec = Vector3(x,0,y)
			_astar.make_connection(vec, Vector3(x+1,0,y))
			_astar.make_connection(vec, Vector3(x-1,0,y))
			_astar.make_connection(vec, Vector3(x,0,y+1))
			_astar.make_connection(vec, Vector3(x,0,y-1))
			_astar.make_connection(vec, Vector3(x+1,0,y+1))
			_astar.make_connection(vec, Vector3(x+1,0,y-1))
			_astar.make_connection(vec, Vector3(x-1,0,y-1))
			_astar.make_connection(vec, Vector3(x-1,0,y+1))
	

func update_debug_mesh():
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	
	var points = _astar.astar.get_points()
	for point in points:
		if _astar.astar.is_point_disabled(point):
			continue
		var position = _astar.astar.get_point_position(point)
		var nbs = _astar.astar.get_point_connections(point)
		for nb in nbs:
			if _astar.astar.is_point_disabled(nb):
				continue
			st.add_vertex(position)
			st.add_vertex(_astar.astar.get_point_position(nb))
			
#	for position in _astar.grid.keys():
#		var nbs = _astar.grid[position].neightbours
#		for nb in nbs:
#			st.add_vertex(position)
#			st.add_vertex(nb)
			
	var material := SpatialMaterial.new()
	material.flags_unshaded = true
	var mesh = st.commit()
	mesh.surface_set_material(0, material)
	_debug_mesh_renderer.mesh = mesh
	

func query_update_gridpart_connectivity(position: Vector3, size: int):
	yield(get_tree(), "idle_frame")
	_raycast_update_tasks.append(_task_update_gridpart_connectivity(position, size))
	
func _task_update_gridpart_connectivity(position: Vector3, size: int):
	yield()
	for x in range(-size,size+1):
		for y in range(-size,size+1):
			_astar.update_raycast_point_disability((position + Vector3(x,0,y)).round())
			yield()
	
	_need_update_debug_renderer = true
