extends Control

const MONEY_LABEL_TEXT = "$ %d"
const RENT_LABEL_TEXT = "$ %d Due"
const DAY_COUNT_LABEL_TEXT = "Day %02d"

@export var win_scene : PackedScene
@onready var money_label : Label = %MoneyLabel
@onready var rent_label : Label = %RentLabel
@onready var night_time_control : Control = %NightTimeControl
@onready var night_panel_container : PanelContainer = %NightPanelContainer
@onready var game_world : GameWorld2D
@onready var shop_panel : ShopPanel = %ShopPanel
@onready var day_count_label : Label = %DayCountLabel

func start_day():
	game_world.start_day()
	rent_label.text = RENT_LABEL_TEXT % game_world.daily_rent_due

func _on_next_day_button_pressed():
	night_time_control.hide()
	start_day()

func _end_day():
	night_time_control.show()
	night_panel_container.cash_available = game_world.money
	night_panel_container.rent_due = game_world.daily_rent_due
	night_panel_container.money_goal = game_world.money_goal
	night_panel_container.update()
	pay_rent()

func _ready():
	InGameMenuController.scene_tree = get_tree()

func pay_rent():
	game_world.money -= game_world.daily_rent_due

func _on_world_day_ended():
	_end_day()

func _on_world_money_updated(new_value):
	shop_panel.money_available = new_value
	money_label.text = MONEY_LABEL_TEXT % new_value

func _on_world_day_progress_updated(new_value):
	%DayProgressBar.value = new_value

func _on_world_day_count_updated(new_value):
	day_count_label.text = DAY_COUNT_LABEL_TEXT % new_value


func _on_night_panel_container_next_day_pressed():
	night_time_control.hide()
	start_day()

func _on_shop_panel_pieces_bought(metal_pieces):
	for metal_piece in metal_pieces:
		game_world.spawn_metal_piece(metal_piece)

func _on_shop_panel_money_spent(money):
	game_world.money -= money

func _on_level_won():
	if $LevelLoader.is_last_level():
		InGameMenuController.open_menu(win_scene, get_viewport())
	else:
		%LevelStartEndControl.show()
		%LevelEndPanel.show()

func _on_level_loader_level_loaded():
	game_world = $LevelLoader.current_level
	if $LevelLoader.current_level.has_signal("level_won"):
		$LevelLoader.current_level.level_won.connect(_on_level_won)
	if $LevelLoader.current_level.has_signal("day_ended"):
		$LevelLoader.current_level.day_ended.connect(_on_world_day_ended)
	if $LevelLoader.current_level.has_signal("money_updated"):
		$LevelLoader.current_level.money_updated.connect(_on_world_money_updated)
	if $LevelLoader.current_level.has_signal("day_progress_updated"):
		$LevelLoader.current_level.day_progress_updated.connect(_on_world_day_progress_updated)
	if $LevelLoader.current_level.has_signal("day_count_updated"):
		$LevelLoader.current_level.day_count_updated.connect(_on_world_day_count_updated)
	await $LevelLoader.current_level.ready
	$LoadingScreen.close()
	%ShopControl.visible = game_world.has_shop
	%MoneyDayContainer.visible = game_world.has_money
	%DayProgressBar.visible = game_world.day_length > 0
	if game_world.start_text.is_empty():
		start_day()
	else:
		%LevelStartEndControl.show()
		%LevelStartPanel.show()
		%StartLevelLabel.text = game_world.start_text

func _on_level_loader_levels_finished():
	InGameMenuController.open_menu(win_scene, get_viewport())

func _on_level_loader_level_load_started():
	$LoadingScreen.reset()

func _on_next_level_button_pressed():
	%LevelStartEndControl.hide()
	%LevelEndPanel.hide()
	$LevelLoader.advance_and_load_level()

func _on_ok_button_pressed():
	%LevelStartEndControl.hide()
	%LevelStartPanel.hide()
	start_day()

func _on_night_panel_container_next_level_pressed():
	night_time_control.hide()
	$LevelLoader.advance_and_load_level()
