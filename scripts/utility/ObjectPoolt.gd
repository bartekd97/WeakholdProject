extends Reference

class_name ObjectPool

var available = {}
var busy = {}

func get_next(obj: Resource) -> Node:
	if not available.has(obj):
		available[obj] = []
	
	var instance
	if available[obj].size() > 0:
		instance = available[obj][0]
		available[obj].remove(0)
	else:
		instance = obj.instance()
		
	busy[instance] = available[obj]
	return instance

func make_free(obj: Node, unparent: bool = true):
	if busy.has(obj):
		busy[obj].append(obj)
		busy.erase(obj)
		if (unparent):
			obj.get_parent().remove_child(obj)
			
func invert_queue():
	for key in available.keys():
		available[key].invert()

func consume(obj: Node):
	if busy.has(obj):
		busy.erase(obj)
