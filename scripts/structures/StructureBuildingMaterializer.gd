extends MeshInstance

export(Material) var green_material : Material
export(Material) var red_material : Material

func _ready():
	(get_parent() as StructureBase).connect("build", self, "_on__build")
	(get_parent() as StructureBase).connect("ma", self, "_on_mark_preview_availability")
	material_override = green_material


func _on__build():
	material_override = null


func _on_mark_preview_availability(availability: bool):
	if material_override:
		material_override = green_material if availability else red_material
