@tool
class_name ForgeController
extends Node

@export var forge_area_2ds : Array[ForgeArea2D]
@export var enabled : bool = true :
	set(value):
		enabled = value
		if is_inside_tree() or Engine.is_editor_hint():
			for forge_area_2d in forge_area_2ds:
				forge_area_2d.enabled = enabled

