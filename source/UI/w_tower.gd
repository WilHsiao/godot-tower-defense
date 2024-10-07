extends MarginContainer
class_name W_Tower

var P_TOWER : PackedScene = preload("res://source/actor/tower.tscn")
@onready var label_cost: Label = %label_cost
@onready var node_2d: Node2D = $MarginContainer/SubViewportContainer/SubViewport/Node2D

signal released

func _ready() -> void:
	gui_input.connect(
		func(event : InputEvent) -> void:
			if event is InputEventMouseButton and event.is_released():
				if event.button_index == MOUSE_BUTTON_LEFT:
					released.emit()
	)
	node_2d.get_child(0).queue_free()
	node_2d.remove_child(node_2d.get_child(0))
	var tower = P_TOWER.instantiate()
	node_2d.add_child(tower)
	label_cost.text = str(tower.cost)

## 更新花费字体显示
func update_cost_display(coin: int) -> void:
	label_cost.modulate = Color.RED if not can_place_tower(coin) else Color.WHITE

## 能否摆放当前tower
func can_place_tower(coin: int) -> bool:
	var tower = node_2d.get_child(0)
	return tower.can_place_tower(coin)
