@tool
extends PanelContainer

@export var project_index : int = 0

@onready var option_button: OptionButton = $OptionButton

var last_index

func _ready() -> void:
	option_button.select(project_index)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if project_index != last_index:
			option_button.select(project_index)

func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			get_tree().change_scene_to_file("res://home.tscn")
		1:
			get_tree().change_scene_to_file("res://Song metadata helper/song_metadata_helper.tscn")
