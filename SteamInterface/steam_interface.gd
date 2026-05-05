extends Node

enum side {
	LOCAL,
	REMOTE,
}

# Host
signal lobby_created
signal player_joined
signal player_left

# Guest
signal lobbies_list_loaded
signal lobby_joined
signal lobby_left

# General
signal avatar_loaded(player: side)
signal persona_name_loaded(player: side)


var app_id = 480
var cur_lobby_id: int
var connected: bool = false
var host: bool = true

var lobby_user_id: Dictionary = {side.LOCAL: 0, side.REMOTE: 0}
var lobby_persona_name: Dictionary = {side.LOCAL: "", side.REMOTE: ""}
var lobby_avatar: Dictionary = {side.LOCAL: null, side.REMOTE: null}

var friends_lobbies_list: Array
var global_lobbies_list: Array

var in_game_friends_list: Array
var online_friends_list: Array
var offline_friends_list: Array

var invites_list: Array

func _ready():
	OS.set_environment("SteamAppId", str(app_id))
	OS.set_environment("SteamGameId", str(app_id))
	connected = Steam.steamInit()
	
	Steam.avatar_image_loaded.connect(_on_avatar_image_loaded)
	Steam.avatar_loaded.connect(_on_avatar_loaded)
	Steam.persona_state_change.connect(_on_persona_state_changed)
	
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_match_list.connect(_on_lobbies_list_loaded)
	Steam.lobby_invite.connect(_on_lobby_invited)

func start():
	lobby_user_id[side.LOCAL] = Steam.getSteamID()
	lobby_persona_name[side.LOCAL] = Steam.getFriendPersonaName(lobby_user_id[side.LOCAL])
	persona_name_loaded.emit(side.LOCAL)
	load_avatar(side.LOCAL)

func _process(_delta: float):
	Steam.run_callbacks()

func create_lobby(lobby_option: int):
	match lobby_option:
		0:
			Steam.createLobby(Steam.LOBBY_TYPE_PRIVATE, 2)
		1:
			Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 2)
		2:
			Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, 2)

func join_lobby(lobby_id: int):
	Steam.joinLobby(lobby_id)

func leave_lobby():
	Steam.leaveLobby(cur_lobby_id)
	cur_lobby_id = 0
	lobby_left.emit()

func load_avatar(player: side):
	var user_id = lobby_user_id[player]
	if user_id == 0:
		return
	
	var avatar_index = Steam.getSmallFriendAvatar(user_id)
	if avatar_index == 0:
		return
	var avatar_buffer = Steam.getImageRGBA(avatar_index).buffer
	var avatar_size = Steam.getImageSize(avatar_index)
	lobby_avatar[player] = get_image(avatar_size.width, avatar_size.height, avatar_buffer)
	avatar_loaded.emit(player)

func get_image(width: int, height: int, data: PackedByteArray):
	return ImageTexture.create_from_image(Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, data))

func load_lobbies_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListFilterSlotsAvailable(1)
	#Steam.addRequestLobbyListStringFilter("game_code", "DEADBEEF", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()

func get_friends_list():
	in_game_friends_list.clear()
	online_friends_list.clear()
	offline_friends_list.clear()
	for i in range(Steam.getFriendCount(Steam.FRIEND_FLAG_IMMEDIATE)):
		var friend_id = Steam.getFriendByIndex(i, Steam.FRIEND_FLAG_IMMEDIATE)
		var new_friend = { \
				"id": friend_id, \
				"name": Steam.getFriendPersonaName(friend_id) \
				}
		match Steam.getFriendPersonaState(friend_id):
			Steam.PERSONA_STATE_ONLINE, \
			Steam.PERSONA_STATE_BUSY, \
			Steam.PERSONA_STATE_LOOKING_TO_TRADE, \
			Steam.PERSONA_STATE_LOOKING_TO_PLAY:
				var cur_game = Steam.getFriendGamePlayed(new_friend["id"])
				if cur_game and cur_game["id"] == app_id:
					in_game_friends_list.append(new_friend)
				else:
					online_friends_list.append(new_friend)
			_:
				offline_friends_list.append(new_friend)

func invite_player(player_id: int):
	if cur_lobby_id:
		Steam.inviteUserToLobby(cur_lobby_id, player_id)

func _on_lobby_created(_connect: int, lobby_id: int):
	cur_lobby_id = lobby_id
	Steam.setLobbyData(cur_lobby_id, "owner_name", lobby_persona_name[side.LOCAL])
	Steam.setLobbyData(cur_lobby_id, "owner_id", str(lobby_user_id[side.LOCAL]))
	Steam.setLobbyData(cur_lobby_id, "app_id", "DEADBEEF")
	lobby_created.emit()

func _on_persona_state_changed(steam_id: int, _flags: int):
	var player: int
	if lobby_user_id[side.LOCAL] == steam_id:
		player = side.LOCAL
	elif lobby_user_id[side.REMOTE] == steam_id:
		player = side.REMOTE
	else:
		return
	
	lobby_persona_name[player] = Steam.getFriendPersonaName(steam_id)
	persona_name_loaded.emit(player)
	load_avatar(player)

func _on_avatar_image_loaded(avatar_id: int, avatar_index: int, width: int, height: int):
	var player: int
	if lobby_user_id[side.LOCAL] == avatar_id:
		player = side.LOCAL
	elif lobby_user_id[side.REMOTE] == avatar_id:
		player = side.REMOTE
	else:
		return
	
	lobby_avatar[player] = get_image(width, height, Steam.getImageRGBA(avatar_index).buffer)
	avatar_loaded.emit(player)

func _on_avatar_loaded(user_id: int, avatar_size: int, avatar_buffer: PackedByteArray):
	var player: int
	if lobby_user_id[side.LOCAL] == user_id:
		player = side.LOCAL
	elif lobby_user_id[side.REMOTE] == user_id:
		player = side.REMOTE
	else:
		return
	
	lobby_avatar[player] = get_image(avatar_size, avatar_size, avatar_buffer)
	avatar_loaded.emit(player)

func _on_lobbies_list_loaded(these_lobbies: Array):
	friends_lobbies_list.clear()
	global_lobbies_list.clear()
	for i in these_lobbies:
		if Steam.getLobbyData(i, "game_code") != "DEADBEEF":
			continue
		var owner_id = int(Steam.getLobbyData(i, "owner_id"))
		var owner_name = int(Steam.getLobbyData(i, "owner_name"))
		var new_lobby = { \
				"id": i, \
				"owner_id": owner_id, \
				"owner_name": owner_name \
				}
		if Steam.getFriendRelationship(owner_id) == Steam.FRIEND_RELATION_FRIEND:
			friends_lobbies_list.append(new_lobby)
		else:
			global_lobbies_list.append(new_lobby)
	lobbies_list_loaded.emit()

func _on_lobby_chat_update(_p_lobby_id: int, change_id: int, _making_change_id: int, chat_state: int):
	match chat_state:
		Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
			lobby_user_id[side.REMOTE] = change_id
			player_joined.emit()
			if !Steam.requestUserInformation(lobby_user_id[side.REMOTE], false):
				lobby_persona_name[side.REMOTE] = Steam.getFriendPersonaName(lobby_user_id[side.REMOTE])
				persona_name_loaded.emit(side.REMOTE)
				load_avatar(side.REMOTE)
		Steam.CHAT_MEMBER_STATE_CHANGE_LEFT, \
		Steam.CHAT_MEMBER_STATE_CHANGE_KICKED, \
		Steam.CHAT_MEMBER_STATE_CHANGE_BANNED:
			lobby_user_id[side.REMOTE] = 0
			lobby_persona_name[side.REMOTE] = ""
			lobby_avatar[side.REMOTE] = null
			player_left.emit()

func _on_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int):
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		cur_lobby_id = lobby_id
		lobby_joined.emit()
	else:
		pass

func _on_lobby_invited(_inviter: int, lobby: int, _game: int):
	if Steam.getLobbyData(lobby, "app_id") != "DEADBEEF":
		print(Steam.getLobbyData(lobby, "owner_name"))
		return
	var owner_id = int(Steam.getLobbyData(lobby, "owner_id"))
	var new_invite = { \
			"id": lobby, \
			"owner_id": owner_id, \
			"owner_name": Steam.getFriendPersonaName(owner_id) \
			}
	invites_list.append(new_invite)

func _on_lobby_join_requested(_p_lobby_id: int, friend_id: int):
	var owner_name: String = Steam.getFriendPersonaName(friend_id)
	print("Joining %s's lobby..." % owner_name)
	pass
