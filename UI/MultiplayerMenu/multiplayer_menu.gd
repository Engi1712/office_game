extends Control

enum lobby_type {
	HOST,
	GUEST,
}

@onready var main_screen = $MarginContainer/VBoxContainer/Main
@onready var error_screen = $MarginContainer/VBoxContainer/Error

@onready var lobby = $MarginContainer/VBoxContainer/Main/Lobby
@onready var host_label = $MarginContainer/VBoxContainer/Main/Lobby/Players/Host
@onready var guest_label = $MarginContainer/VBoxContainer/Main/Lobby/Players/Guest
@onready var host_avatar = $MarginContainer/VBoxContainer/Main/Lobby/Players/HostAvatar
@onready var guest_avatar = $MarginContainer/VBoxContainer/Main/Lobby/Players/GuestAvatar
@onready var guest_empty_icon = $MarginContainer/VBoxContainer/Main/Lobby/Players/GuestEmptyIcon
@onready var guest_online_icon = $MarginContainer/VBoxContainer/Main/Lobby/Players/GuestOnlineIcon
@onready var host_option = $MarginContainer/VBoxContainer/Main/Lobby/Buttons/OptionButton
@onready var host_button = $MarginContainer/VBoxContainer/Main/Lobby/Buttons/HostButton
@onready var leave_button = $MarginContainer/VBoxContainer/Main/Lobby/Buttons/LeaveButton

@onready var tabs = $MarginContainer/VBoxContainer/Main/Search
@onready var lobbies_list = $MarginContainer/VBoxContainer/Main/Search/All/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var lobbies_refresh_button = $MarginContainer/VBoxContainer/Main/Search/All/MarginContainer/VBoxContainer/RefreshButton
@onready var lobbies_join_button = $MarginContainer/VBoxContainer/Main/Search/All/MarginContainer/VBoxContainer/JoinButton
@onready var invites_list = $MarginContainer/VBoxContainer/Main/Search/Invites/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var invites_join_button = $MarginContainer/VBoxContainer/Main/Search/Invites/MarginContainer/VBoxContainer/JoinButton
@onready var friends_list = $MarginContainer/VBoxContainer/Main/Search/Friends/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var friends_invite_button = $MarginContainer/VBoxContainer/Main/Search/Friends/MarginContainer/VBoxContainer/InviteButton

@onready var ready_button = $MarginContainer/VBoxContainer/Buttons/ReadyButton

const template_label = preload("res://UI/MultiplayerMenu/interactive_label.tscn")
const avatar_placeholder = preload("res://Art/Office Pack/HUD/MainMenu/avatar_placeholder.png")

var default_font = load(Glob.default_font)

var friends_tab = 0
var lobbies_tab = 1
var invites_tab = 2

var in_lobby: bool = false
var is_host: bool
var cur_label: InteractiveLabel = null

func _ready():
	var mode = MenuSwitcher.get_param("mode")
	
	SteamInterface.lobby_created.connect(_on_lobby_created)
	SteamInterface.player_joined.connect(_on_player_joined)
	SteamInterface.player_left.connect(_on_player_left)
	
	SteamInterface.lobbies_list_loaded.connect(_on_lobbies_list_loaded)
	SteamInterface.lobby_joined.connect(_on_lobby_joined)
	SteamInterface.lobby_left.connect(_on_lobby_left)
	
	SteamInterface.avatar_loaded.connect(_on_avatar_loaded)
	SteamInterface.persona_name_loaded.connect(_on_persona_name_loaded)
	if SteamInterface.connected:
		main_screen.show()
		error_screen.hide()
	else:
		main_screen.hide()
		error_screen.show()
		return
	if mode == "join":
		is_host = false
		ready_button.text = "Ready"
		host_option.hide()
		host_button.hide()
		lobby.hide()
		tabs.set_tab_hidden(friends_tab, true)
		tabs.set_tab_hidden(lobbies_tab, false)
		tabs.set_tab_hidden(invites_tab, false)
		tabs.current_tab = lobbies_tab
		SteamInterface.load_lobbies_list()
		update_invites_list()
		set_guest_icon()
	else:
		is_host = true
		ready_button.text = "Start"
		host_option.get_popup().transparent_bg = true
		host_option.get_popup().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		leave_button.text = "Kick"
		leave_button.hide()
		lobby.show()
		tabs.set_tab_hidden(friends_tab, false)
		tabs.set_tab_hidden(lobbies_tab, true)			#Debug
		tabs.set_tab_hidden(invites_tab, true)
		tabs.current_tab = friends_tab
		#SteamInterface.load_lobbies_list()			#Debug
		SteamInterface.get_friends_list()
		update_friends_list()
		reset_guest_icon()
	reset_lobby_host()
	reset_lobby_guest()
	SteamInterface.start()

func reset_lobby_host():
	host_label.text = "???"
	host_avatar.set_texture(avatar_placeholder)

func reset_lobby_guest():
	guest_label.text = "???"
	guest_avatar.set_texture(avatar_placeholder)

func set_guest_icon():
	guest_empty_icon.visible = false
	guest_online_icon.visible = true

func reset_guest_icon():
	guest_empty_icon.visible = true
	guest_online_icon.visible = false

func create_label(text: String):
	var label: RichTextLabel
	label = RichTextLabel.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.bbcode_enabled = true
	label.scroll_active = false
	label.custom_minimum_size.y = 12.0
	return label

func bind_label(new_label: InteractiveLabel):
	new_label.gui_input.connect(_on_label_click.bind(new_label))
	new_label.mouse_entered.connect(_on_label_mouse_entered.bind(new_label))
	new_label.mouse_exited.connect(_on_label_mouse_exited.bind(new_label))

func update_friends_list():
	for i in friends_list.get_children():
		i.queue_free()
	friends_list.add_child(create_label("---- In Game ----"))
	for i in SteamInterface.in_game_friends_list:
		var new_label = template_label.instantiate()
		new_label.setup(Emoji.parse(i["name"], default_font), ColourPalette.green, i["id"])
		friends_list.add_child(new_label)
		bind_label(new_label)
	friends_list.add_child(create_label("---- Online ----"))
	for i in SteamInterface.online_friends_list:
		var new_label = template_label.instantiate()
		new_label.setup(Emoji.parse(i["name"], default_font), ColourPalette.white, i["id"])
		friends_list.add_child(new_label)
		bind_label(new_label)
	friends_list.add_child(create_label("---- Offline ----"))
	for i in SteamInterface.offline_friends_list:
		var new_label = template_label.instantiate()
		new_label.setup(Emoji.parse(i["name"], default_font), ColourPalette.grey, i["id"])
		friends_list.add_child(new_label)
		bind_label(new_label)

func update_lobbies_list():
	for i in lobbies_list.get_children():
		i.queue_free()
	lobbies_list.add_child(create_label("---- Friends ----"))
	for i in SteamInterface.friends_lobbies_list:
		var new_label = template_label.instantiate()
		new_label.setup(Emoji.parse(i["owner_name"], default_font), ColourPalette.white, i["id"])
		lobbies_list.add_child(new_label)
		bind_label(new_label)
	lobbies_list.add_child(create_label("---- Global ----"))
	for i in SteamInterface.global_lobbies_list:
		var new_label = template_label.instantiate()
		new_label.setup(Emoji.parse(i["owner_name"], default_font), ColourPalette.white, i["id"])
		lobbies_list.add_child(new_label)
		bind_label(new_label)

func update_invites_list():
	for i in invites_list.get_children():
		i.queue_free()
	for i in SteamInterface.invites_list:
		var new_label = template_label.instantiate()
		new_label.setup(Emoji.parse(i["owner_name"], default_font), ColourPalette.white, i["id"])
		invites_list.add_child(new_label)
		bind_label(new_label)

# Host lobby callbacks
func _on_lobby_created():
	in_lobby = true
	host_button.text = "Cancel"
	host_button.disabled = false

func _on_player_joined():
	set_guest_icon()
	leave_button.show()

func _on_player_left():
	reset_lobby_guest()
	reset_guest_icon()
	leave_button.hide()

# Guest lobby callbacks
func _on_lobbies_list_loaded():
	update_lobbies_list()
	lobbies_refresh_button.disabled = false

func _on_lobby_joined():
	if !is_host:
		lobby.show()

func _on_lobby_left():
	if !is_host:
		reset_lobby_host()
		lobby.hide()

# General callbacks
func _on_avatar_loaded(player: SteamInterface.side):
	var avatar: TextureRect
	if (player == SteamInterface.side.LOCAL) == is_host:
		avatar = host_avatar
	else:
		avatar = guest_avatar
	avatar.texture = SteamInterface.lobby_avatar[player]

func _on_persona_name_loaded(player: SteamInterface.side):
	var label: RichTextLabel
	if (player == SteamInterface.side.LOCAL) == is_host:
		label = host_label
	else:
		label = guest_label
	label.text = SteamInterface.lobby_persona_name[player]

# User interaction callbacks
func _on_back_button_pressed():
	SteamInterface.leave_lobby()
	MenuSwitcher.switch("main_menu", {"submenu": "remote"})

func _on_ready_button_pressed():
	pass

func _on_host_button_pressed():
	if !in_lobby:
		SteamInterface.create_lobby(host_option.get_selected_id())
		host_button.disabled = true
	else:
		pass

func _on_label_click(event: InputEvent, label: InteractiveLabel):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if cur_label:
				cur_label.deselect()
				match tabs.current_tab:
					friends_tab:
						friends_invite_button.disabled = true
					lobbies_tab:
						lobbies_join_button.disabled = true
					invites_tab:
						invites_join_button.disabled = true
			if cur_label != label:
				cur_label = label
				cur_label.select()
				match tabs.current_tab:
					friends_tab:
						friends_invite_button.disabled = false
					lobbies_tab:
						lobbies_join_button.disabled = false
					invites_tab:
						invites_join_button.disabled = false

func _on_label_mouse_entered(label: InteractiveLabel):
	label.hover()

func _on_label_mouse_exited(label: InteractiveLabel):
	label.dehover()

func _on_friends_refresh_button_pressed():
	SteamInterface.get_friends_list()
	update_friends_list()

func _on_lobbies_refresh_button_pressed():
	lobbies_refresh_button.disabled = true
	SteamInterface.load_lobbies_list()

func _on_invites_refresh_button_pressed():
	update_invites_list()

func _on_invite_button_pressed():
	if !in_lobby:
		pass	#TODO Create lobby
	DisplayServer.clipboard_set(str(cur_label.steam_id))
	SteamInterface.invite_player(cur_label.steam_id)

func _on_lobbies_join_button_pressed():
	if in_lobby:
		pass	#TODO Leave lobby
	SteamInterface.join_lobby(cur_label.steam_id)

func _on_invites_join_button_pressed():
	if in_lobby:
		pass	#TODO Leave lobby
	SteamInterface.join_lobby(cur_label.steam_id)

func _on_option_button_item_selected(_index: int):
	host_button.disabled = false

func _on_kick_button_pressed():
	pass # Replace with function body.
