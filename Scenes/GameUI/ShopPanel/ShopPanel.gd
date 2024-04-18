@tool
class_name ShopPanel
extends Panel

signal pieces_bought(metal_pieces : Array[MetalPiece])
signal money_spent(money : int)

@export var money_available : int :
	set(value):
		money_available = value
		if is_inside_tree() or Engine.is_editor_hint():
			for child in %OffersContainer.get_children():
				if child is ShopOfferContainer:
					child.affordable = money_available >= child.buy_cost

func _connect_shop_offer_container(node : Node):
	if node is ShopOfferContainer:
		node.money_spent.connect(func(money) : money_spent.emit(money))
		node.pieces_bought.connect(func(metal_pieces) : pieces_bought.emit(metal_pieces))

func _on_offers_container_child_entered_tree(node):
	_connect_shop_offer_container(node)
