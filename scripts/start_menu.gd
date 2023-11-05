extends Control
@export var game_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_start_game_pressed():
	$ButtonSound.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_packed(game_scene)


func _on_exit_game_pressed():
	$ButtonSound.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()
