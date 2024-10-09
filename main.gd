extends Node2D

const TILE_SOURCE_ID_PLACEMENT : int = 1
const TILE_CELL_FOR_PLACEMENT : Vector2i = Vector2i(15, 0)

@onready var path_2d: Path2D = $TileMap/Path2D
@onready var timer_spawn_enemy: Timer = $TimerSpawnEnemy
@onready var game_form: Control = $CanvasLayer/GameForm
@onready var tile_map: TileMap = $TileMap

@export var enemies : Array[PackedScene]
var _perview_tower : Tower :
	set(value) :
		if _perview_tower and value:
			_perview_tower.queue_free()
			tile_map.remove_child(_perview_tower)
		_perview_tower = value

@export var start_coin : int = 100
## 游戏过程中的金币数量
@onready var coin : int = start_coin :
	set(value):
		coin = value
		game_form.update_coin_display(coin)

@export var max_health : float = 100
@onready var current_health : float = max_health :
	set(value):
		current_health = value
		game_form.update_health_display(current_health, max_health)
		if current_health <= 0:
			_game_over()

@export var _towers : Array[PackedScene]

func _ready() -> void:
	randomize()
	game_form.w_tower_released.connect(
		func(w_tower : W_Tower) -> void:
			if not w_tower.can_place_tower(coin) : return
			_perview_tower = w_tower.P_TOWER.instantiate()
			tile_map.add_child(_perview_tower)
	)
	game_form.replay_pressed.connect(_replay)
	timer_spawn_enemy.wait_time = randf_range(1, 3)
	timer_spawn_enemy.timeout.connect(
		func() -> void:
			_spawn_enemy()
			timer_spawn_enemy.wait_time = randf_range(1, 3)
			timer_spawn_enemy.start()
	)
	timer_spawn_enemy.start()
	game_form.update_coin_display(coin)
	game_form.update_health_display(current_health, max_health)
	game_form.initialize(_towers)

func _process(_delta: float) -> void:
	perview_tower()

func _unhandled_input(event: InputEvent) -> void:
	if not _perview_tower : return
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			## 判断能否在鼠标位置放置tower
			place_tower_at_mouse_position()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			## 取消当前防御塔的预览效果
			disperview_tower()

## 重新开始游戏
func _replay() -> void:
	current_health = max_health
	for actor in get_tree().get_nodes_in_group("actor"):
		actor.queue_free()
	coin = start_coin
	current_health = max_health
	get_tree().paused = false
	game_form.update_coin_display(coin)
	game_form.update_health_display(current_health, max_health)
	game_form.initialize(_towers)

## 预览防御塔
func perview_tower() -> void:
	if not _perview_tower : return
	var cell : Vector2i = tile_map.local_to_map(tile_map.get_local_mouse_position())
	_perview_tower.position = tile_map.map_to_local(cell)
	_perview_tower.modulate = Color.RED if not can_place_tower(cell) else Color.WHITE

## 取消预览防御塔
func disperview_tower() -> void:
	if not _perview_tower : return
	_perview_tower.queue_free()
	tile_map.remove_child(_perview_tower)

## 在鼠标位置放置防御塔
func place_tower_at_mouse_position() -> void:
	var cell : Vector2i = tile_map.local_to_map(tile_map.get_local_mouse_position())
	if can_place_tower(cell):
		#_perview_tower.queue_free()
		_perview_tower.initialize()
		coin -= _perview_tower.cost
		_perview_tower = null
		$AudioFootStep.play()
		tile_map.set_cell(1, cell)
		#tile_map.set_cell(1, cell, 2, Vector2i.ZERO, 1)

## 能否放置防御塔
func can_place_tower(cell : Vector2i) -> bool:
	var tile_source_id : int = tile_map.get_cell_source_id(1, cell)
	var tile_cell : Vector2i = tile_map.get_cell_atlas_coords(1, cell)
	return tile_source_id == TILE_SOURCE_ID_PLACEMENT and tile_cell == TILE_CELL_FOR_PLACEMENT

## 生成敌人
func _spawn_enemy() -> void:
	var enemy_index : int = randi_range(0, enemies.size() - 1)
	var enemy : Enemy = enemies[enemy_index].instantiate()
	enemy.died.connect(_on_enemy_died.bind(enemy))
	enemy.damaged.connect(
		func(attack : float) -> void:
			current_health -= attack
	)
	path_2d.add_child(enemy)

## 游戏结束
func _game_over() -> void:
	#print("GameOver!")
	game_form.show_game_over()
	get_tree().paused = true
	
func _on_enemy_died(enemy : Enemy) -> void:
	coin += enemy.loot_coin
