extends Control

const W_TOWER = preload("res://source/UI/w_tower.tscn")
#@onready var w_tower: W_Tower = $VBoxContainer/MarginContainer2/HBoxContainer/w_tower
@onready var lab_coin: Label = %lab_coin
@onready var pb_health: ProgressBar = %pb_health
@onready var lab_health: Label = %lab_health
@onready var h_box_container: HBoxContainer = $VBoxContainer/MarginContainer2/HBoxContainer
@onready var w_game_over: MarginContainer = $w_game_over

signal w_tower_released
signal replay_pressed

func _ready() -> void:
	w_game_over.btn_replay_pressed.connect(
		func() -> void:
			replay_pressed.emit()
			w_game_over.hide()
	)
	w_game_over.hide()

func initialize(towers : Array[PackedScene]) -> void:
	for w_tower in h_box_container.get_children():
		w_tower.queue_free()
	for P_TOWER : PackedScene in towers:
		var w_tower = W_TOWER.instantiate()
		w_tower.P_TOWER = P_TOWER
		h_box_container.add_child(w_tower)
		w_tower.released.connect(
			func() -> void:
				w_tower_released.emit(w_tower)
		)

func update_coin_display(coin : int) -> void:
	lab_coin.text = "金币：" + str(coin)
	for w_tower : W_Tower in h_box_container.get_children():
		w_tower.update_cost_display(coin)

func update_health_display(current_health : float, max_health : float) -> void:
	pb_health.value = current_health
	pb_health.max_value = max_health
	lab_health.text = str(current_health) + "/" + str(max_health)

func show_game_over() -> void:
	w_game_over.show()
