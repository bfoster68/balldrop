extends Control

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(800, 600),
	Vector2i(1024, 768),
	Vector2i(1280, 720),
	Vector2i(1280, 800),
	Vector2i(1366, 768),
	Vector2i(1440, 900),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
]

@onready var res_option: OptionButton = $center/vbox/ResolutionRow/ResOption

var _selected_size: Vector2i = Vector2i.ZERO
var _selected_fullscreen: bool = false

func _ready() -> void:
	var screen_size := DisplayServer.screen_get_size()
	var win_size := DisplayServer.window_get_size()
	var mode := DisplayServer.window_get_mode()
	var is_fullscreen := mode == DisplayServer.WINDOW_MODE_FULLSCREEN \
		or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

	_selected_fullscreen = is_fullscreen
	if not is_fullscreen:
		_selected_size = Vector2i(win_size)

	var current_index := 0
	for res in RESOLUTIONS:
		if res.x <= screen_size.x and res.y <= screen_size.y:
			res_option.add_item("%d \u00d7 %d" % [res.x, res.y])
			var idx := res_option.item_count - 1
			res_option.set_item_metadata(idx, res)
			if not is_fullscreen and Vector2i(win_size) == res:
				current_index = idx

	res_option.add_item("Fullscreen")
	var fs_idx := res_option.item_count - 1
	res_option.set_item_metadata(fs_idx, Vector2i(-1, -1))
	if is_fullscreen:
		current_index = fs_idx

	res_option.selected = current_index
	res_option.item_selected.connect(_on_res_option_item_selected)
	$center/vbox/PlayButton.pressed.connect(_on_play_pressed)

func _apply_resolution() -> void:
	if _selected_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(_selected_size)
		var screen_size := DisplayServer.screen_get_size()
		DisplayServer.window_set_position((screen_size - _selected_size) / 2)

func _on_res_option_item_selected(index: int) -> void:
	var meta: Variant = res_option.get_item_metadata(index)
	if meta is Vector2i and meta == Vector2i(-1, -1):
		_selected_fullscreen = true
	elif meta is Vector2i:
		_selected_fullscreen = false
		_selected_size = meta
	_apply_resolution()

func _on_play_pressed() -> void:
	# Re-apply to ensure the resolution is set, then wait for it to take effect
	_apply_resolution()
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://main.tscn")
