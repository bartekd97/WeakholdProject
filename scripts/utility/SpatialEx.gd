extends Spatial

class_name SpatialEx

signal enabled
signal disabled

var _is_enabled = true
func is_enabled() -> bool:
	return _is_enabled

func set_enabled(enabled: bool = true):
	if enabled == _is_enabled:
		return
	
	_is_enabled = enabled
	emit_signal("enabled" if _is_enabled else "disabled")
	visible = _is_enabled
	set_physics_process(_is_enabled)
	set_process(_is_enabled)
	set_process_input(_is_enabled)
	set_process_unhandled_input(_is_enabled)
	set_process_unhandled_key_input(_is_enabled)
	
