extends Control

@onready var main_vbox = $MarginContainer/VBoxContainer
@onready var top_players_container = main_vbox.get_node("TopPlayersContainer")
@onready var middle_area_container = main_vbox.get_node("MiddleAreaContainer")
@onready var bottom_container = main_vbox.get_node("BottomContainer")
@onready var log_display = middle_area_container.get_node("Log")
@onready var action_panel = bottom_container.get_node("ActionPanel")
@onready var player_container = bottom_container.get_node("PlayerContainer") 

const PLAYER_SCENE = preload("res://Player.tscn")
var player_ui_nodes = []
var selecting_target = false
var pending_action_name


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
	var current_player_data = GameData.get_current_player()
		
	for i in range (GameData.players.size()):
		player_ui_nodes[i].update_info(GameData.players[i], i)
	
	var is_waiting_for_action = GameData.current_game_state == GameData.GameState.WAITING_FOR_ACTION
	$ActionPanel.visible = is_waiting_for_action
	
	if is_waiting_for_action:
		$ActionPanel/GridContainer/Coup.disabled = current_player_data.coins < 7
		$ActionPanel/GridContainer/Asesinar.disable = current_player_data.coins <3

func start_target_selection(action_name: String):
	selecting_target = true
	pending_action_name = action_name
	$ActionPanel.visible = false
	append_to_log(GameData.get_current_player().name + " debe seleccionar un objetivo para: " + action_name)
	for node in player_ui_nodes:
		node.set_target_mode(true)
	

#///////////////////
#Manejo de la logica de turno
#///////////////////
func handle_action_request(player_index: int, options:Dictionary):
	if options.type == "LOSE_INFLUENCE":
		var card_to_lose = GameData.get_player(player_index).influence[0]
		GameData.process_influence_loss(player_index, card_to_lose)
	
	if options.type == "CHALLENGE_BLOCK":
		GameData.player_response(GameData.active_Action.blocker_index, "CHALLENGE_BLOCK_RESPONSE", "PASS")

#///////////////////////
#configuracion de botones
#//////////////////////

		
		
func _process(delta: float) -> void:
	pass


func _on_ingresos_pressed():
	GameData.announce_action("Ingresos")
	
# Replace with function body.
func _on_ayuda_externa_pressed():
	GameData.announce_Action("Ayuda Externa")

func _on_impuestos_pressed():
	GameData.announce_action("Impuestos")

func _on_intercambio_pressed():
	GameData.announce_Action("Intercambio")

func _on_asesinar_pressed():
	start_target_selection("Asesinar")

func _on_robar_pressed():
	var target_index = (GameData.current_player_index + 1) % GameData.players.size()
	GameData.announce_Action("Robar", target_index)

func _on_coup_pressed():
	var target_index = (GameData.current_player_index + 1) % GameData.players.size()
	GameData.announce_action("Coup", target_index)

func target_selected(target_index: int):
	selecting_target=false
	for node in player_ui_nodes:
		node.set_target_mode(false)
	GameData.announce_action(pending_action_name, target_index)
	pending_action_name = ""
	update_ui()

#////////
#logloglog
#////////

func append_to_log(message: String):
	var log = $Log
	log.text += message + "\n"
	log.scroll_vertical = log.get_v_scroll_bar().max_value
