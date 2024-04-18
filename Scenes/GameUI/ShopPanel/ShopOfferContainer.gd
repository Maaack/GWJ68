@tool
class_name ShopOfferContainer
extends PanelContainer

signal pieces_bought(metal_pieces : Array[MetalPiece])
signal money_spent(money : int)

const BUY_COST_LABEL_TEXT = "$%d"

@export var shape_count_container_scene : PackedScene
@export var metal_piece_count_array : Array[MetalPieceCount] :
	set(value):
		metal_piece_count_array = value
		_update_shape_counts()
@export var buy_count : int :
	set(value):
		buy_count = value
		if is_inside_tree() or Engine.is_editor_hint():
			%BuyCountLabel.text = "%d" % buy_count
@export var buy_cost : int :
	set(value):
		buy_cost = value
		if is_inside_tree() or Engine.is_editor_hint():
			%BuyCostLabel.text = BUY_COST_LABEL_TEXT % buy_cost
@export var affordable : bool = false :
	set(value):
		affordable = value
		if is_inside_tree() or Engine.is_editor_hint():
			%BuyButton.disabled = !affordable
@onready var shape_counts_container : Container = %ShapeCountsContainer
@onready var buy_count_label : Label = %BuyCountLabel
@onready var buy_cost_label : Label = %BuyCostLabel


func _clear_shape_counts():
	for child in shape_counts_container.get_children():
		child.queue_free()

func _update_shape_counts():
	if not (is_inside_tree() or Engine.is_editor_hint()):
		return
	_clear_shape_counts()
	var total_piece_count : int = 0
	for metal_piece_count in metal_piece_count_array:
		if not metal_piece_count:
			continue
		total_piece_count += metal_piece_count.count
	for metal_piece_count in metal_piece_count_array:
		if not metal_piece_count:
			continue
		var shape_count_instance = shape_count_container_scene.instantiate()
		shape_count_instance.piece_count = metal_piece_count
		shape_count_instance.total_count = total_piece_count
		shape_counts_container.call_deferred("add_child", shape_count_instance)

func _ready():
	metal_piece_count_array = metal_piece_count_array

func _get_full_metal_piece_list() -> Array[MetalPiece]:
	var full_metal_piece_list : Array[MetalPiece] = []
	for metal_piece_count in metal_piece_count_array:
		for i in range(metal_piece_count.count):
			full_metal_piece_list.append(metal_piece_count.metal_piece)
	return full_metal_piece_list

func _on_buy_button_pressed():
	var bought_metal_pieces : Array[MetalPiece] = []
	var full_metal_piece_list := _get_full_metal_piece_list()
	full_metal_piece_list.shuffle()
	bought_metal_pieces = full_metal_piece_list.slice(-buy_count)
	money_spent.emit(buy_cost)
	pieces_bought.emit(bought_metal_pieces)
