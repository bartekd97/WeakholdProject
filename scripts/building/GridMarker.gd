extends MeshInstance

class_name GridMarker

export(Material) var active_material: Material

func activate():
	material_override = active_material
	
func deactivate():
	material_override = null
