extends Node2D

@onready var ui = $UI


func _ready():
	Events.level_completed.connect(on_level_completed)
	Events.game_over.connect(on_game_over)


func on_level_completed():
	get_node("UI/LevelCompleted").show()
	get_tree().paused = true
	get_node("UI/Label").visible = false


func on_game_over():
	get_node("UI/GameOver").show()
	get_tree().paused = true
	get_node("UI/Label").visible = false
