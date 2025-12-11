extends Control

const PLAYER_SCENE = preload("res://Player.tscn")
var player_ui_nodes = []


func _ready():
	GameData.connect("game_state_changed", Callable(self, "update_ui"))
	GameData.connect("log_message", Callable(self, "append_to_log"))
	GameData.connect("action_requested", Callable(self, "handle_action_request"))
	var names = ["Alice", "Bob", "Charlie"]
	GameData.init_game(names)
	
	for i in range(names.size()):
		var player_ui = PLAYER_SCENE.instance()
		$PlayerContainer.add_child(player_ui)
		player_ui_nodes.append(player_ui)
	
	update_ui()
	
func update_ui():
	var current_player = GameData.get_current_player()
		
	for i in range (GameData.players.size()):
		player_ui_nodes[i].update_info(GameData.players[i], i)
	
	var is_waiting_for_action = GameData.current_game_state == GameData.GameState.WAITING_FOR_ACTION
	$ActionPanel.visible = is_waiting_for_action
	
	if is_waiting_for_action:
		$ActionPanel/GridContainer/Coup.disabled = current_player_data.coins < 7
		$ActionPanel/GridContainer/Asesinar.disable = current_player_data.coins <3
	#BOTONES
	
	
	
		
func _process(delta: float) -> void:
	pass
