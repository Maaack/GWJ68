@tool
extends VBoxContainer

const COUNT_LABEL_TEXT = "x%d"

@export var piece_count : MetalPieceCount

@onready var polygon_2d : Polygon2D = %Polygon2D
@onready var count_label : Label = %CountLabel

func update():
	polygon_2d.polygon = piece_count.metal_piece.polygon
	polygon_2d.color = piece_count.metal_piece.color
	count_label.text = COUNT_LABEL_TEXT % piece_count.count

func _ready():
	update()
