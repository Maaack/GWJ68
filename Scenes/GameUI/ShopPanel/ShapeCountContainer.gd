@tool
extends VBoxContainer

@export var piece_count : MetalPieceCount
@export var total_count : int :
	set(value):
		total_count = value
		if is_inside_tree() or Engine.is_editor_hint():
			if total_count > 0:
				%DivisionSeparator.show()
				%TotalLabel.show()
				%TotalLabel.text = "%d" % total_count
			else: 
				%DevisionSeparator.hide()
				%TotalLabel.hide()

@onready var polygon_2d : Polygon2D = %Polygon2D
@onready var count_label : Label = %CountLabel

func update():
	polygon_2d.polygon = piece_count.metal_piece.polygon
	polygon_2d.color = piece_count.metal_piece.color
	count_label.text = "%d" % piece_count.count
	total_count = total_count

func _ready():
	update()
