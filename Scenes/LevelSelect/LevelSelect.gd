@tool
extends Control

@export var level_count : int
@export var level_button_base : Button
@export_file("*.tscn") var game_scene : String


var level_number : int = 0

func _clear_level_buttons():
	var container_node = get_node_or_null("%GridContainer")
	if container_node == null:
		return
	for child in container_node.get_children():
		child.queue_free()

func _load_level_buttons():
	var container_node = get_node_or_null("%GridContainer")
	if container_node == null:
		return
	_clear_level_buttons()
	var level_list : Array = range(level_count)
	for index in level_list:
		var level_button_instance = level_button_base.duplicate()
		level_button_instance.pressed.connect(_level_button_pressed.bind(index))
		level_button_instance.text = "Level %d" % (index + 1)
		level_button_instance.show()

		if level_number < index:
			level_button_instance.disabled = true
		container_node.add_child(level_button_instance)


func _level_button_pressed(index : int):
	GameLevelLog.set_current_level(index)
	SceneLoader.load_scene(game_scene)

func _ready():
	level_number = GameLevelLog.get_max_level_reached()
	_load_level_buttons()
	%GridContainer.get_child(0).grab_focus()


