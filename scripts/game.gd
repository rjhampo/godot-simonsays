extends Control

signal start_round
signal end_round
signal no_life

@export_file var start_scene_path
var start_scene

var DARKENING_CONST : float = 0.5
var SEQ_DELAY : float = 0.4
var ROUND_DELAY : float = 1.0
var LISTEN_DELAY : float = 0.75
var START_MSG : String = 'Listen!'
var CORRECT_MSG : String = 'Nice!'
var WRONG_MSG : String = 'Try again...'
var GAME_OVER : String = 'Game Over'

var is_start : bool = false
var status_msg : String = ''
var current_num_buttons  : int
var current_buttons : Array
var lives_group : Array
var game_level : int = 2
var current_button_sequence : Array[int] = []
var round_cursor : int = 0
var time_difficulty : float = 20.0
var life : int = 3
var internal_timer : Variant



func create_level(level_length : int, num_buttons : int):
	var button_sequence : Array[int] = []
	for i in range(level_length):
		button_sequence.append(randi_range(0, num_buttons - 1))
	return button_sequence

func ready_sprites():
	current_buttons = get_tree().get_nodes_in_group('game_buttons')
	current_num_buttons = len(current_buttons)
	for i in range(current_num_buttons):
		current_buttons[i].return_pressed.connect(_on_return_pressed)
		current_buttons[i].id = i
	lives_group = get_tree().get_nodes_in_group('lives')



func _ready():
	start_scene = load(start_scene_path)
	ready_sprites()
	get_tree().call_group('game_buttons', 'disable_buttons')

func _process(_delta):
	if not is_start:
		$StatusLabel.text = str(int($GameStartTimer.time_left + 1))
	else:
		$StatusLabel.text = status_msg
	$ScoreLabel.text = 'Level: ' + str(game_level - 1)
	$TimerBar.set_scale(Vector2($DuringRoundTimer.time_left / time_difficulty, 1))



func _on_game_start_timer_timeout():
	is_start = true
	start_round.emit()

func _on_start_round():
	status_msg = START_MSG
	await get_tree().create_timer(LISTEN_DELAY).timeout
	current_button_sequence = create_level(game_level, current_num_buttons)
	for i in current_button_sequence:
		var button_color = current_buttons[i].get_modulate()
		current_buttons[i].play_button_sound()
		current_buttons[i].set_modulate(button_color.darkened(DARKENING_CONST))
		await get_tree().create_timer(SEQ_DELAY).timeout
		current_buttons[i].set_modulate(button_color)
		await get_tree().create_timer(SEQ_DELAY).timeout
	get_tree().call_group('game_buttons', 'enable_buttons')
	status_msg = ''
	$DuringRoundTimer.start(time_difficulty)
	

func _on_return_pressed(id : int):
	if current_button_sequence[round_cursor] == id:
		round_cursor += 1
		if round_cursor > (game_level - 1):
			end_round.emit(true)
	else:
		end_round.emit(false)


func _on_end_round(win : bool):
	$DuringRoundTimer.set_paused(true)
	get_tree().call_group('game_buttons', 'disable_buttons')
	if win:
		status_msg = CORRECT_MSG
		game_level += 1
	else:
		life -= 1
		lives_group[life].queue_free()
		if not life:
			status_msg = GAME_OVER
			no_life.emit()
		else:
			status_msg = WRONG_MSG
	await get_tree().create_timer(ROUND_DELAY).timeout
	$DuringRoundTimer.set_paused(false)
	$DuringRoundTimer.stop()
	status_msg = ''
	round_cursor = 0
	await get_tree().create_timer(ROUND_DELAY).timeout
	start_round.emit()


func _on_during_round_timer_timeout():
	end_round.emit(false)


func _on_no_life():
	await get_tree().create_timer(ROUND_DELAY).timeout
	get_tree().change_scene_to_packed(start_scene)
