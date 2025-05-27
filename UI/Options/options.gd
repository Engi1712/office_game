extends Control

@onready var video_button = $VideoButton
@onready var audio_button = $AudioButton
@onready var gameplay_button = $GameplayButton
@onready var bindings_button = $BindingsButton
@onready var video_tab = $LeftPage/VideoTab
@onready var audio_tab = $LeftPage/AudioTab
@onready var gameplay_tab = $LeftPage/GameplayTab
@onready var bindings_tab = $LeftPage/BindingsTab
@onready var discard_button = $LeftPage/MarginContainer/VBoxContainer/ButtonRow1/Discard
@onready var apply_button = $LeftPage/MarginContainer/VBoxContainer/ButtonRow1/Apply
@onready var reset_button = $LeftPage/MarginContainer/VBoxContainer/ButtonRow2/Reset

@onready var video_fullscreen_check_box = $LeftPage/VideoTab/Setting/VBoxContainer/Fullscreen/CheckBox
@onready var video_resolution_drop_down = $LeftPage/VideoTab/Setting/VBoxContainer/Resolution/DropDown
@onready var video_vsync_mode_label = $LeftPage/VideoTab/Setting/VBoxContainer/VSync/Mode
@onready var gameplay_language_drop_down = $LeftPage/GameplayTab/ScrollContainer/MarginContainer/VBoxContainer/Language/DropDown

@onready var desc_scroll = $RightPage
@onready var desc = $RightPage/VBoxContainer

class Settings:
	var video_vsync: int
	var video_fullscreen: bool
	var video_resolution: int
	var audio_master: int
	var audio_music: int
	var audio_sfx: int
	var gameplay_sensetivity: int
	var gameplay_language: int
	var gameplay_fps_counter: int

class VSyncMode:
	var label: String
	var code: String

class Resolution:
	var size: Vector2
	var name: String

class Locale:
	var name: String
	var code: String
	func _init(name, code):
		self.name = name
		self.code = code

var default_settings: Settings
var saved_settings: Settings
var current_settings: Settings

var video_vsync_mode_labels = ["OPTIONS_VIDEO_V_SYNC_OFF",
				"OPTIONS_VIDEO_V_SYNC_ON",
				"OPTIONS_VIDEO_V_SYNC_ADAPT",
				"OPTIONS_VIDEO_V_SYNC_FAST"]
var video_vsync_mode_names = ["Off", "On", "Adapt", "Fast"]
var video_resolutions = [Vector2(640, 360),
						Vector2(1280, 720),
						Vector2(1920,1080),
						Vector2(2560,1440),
						Vector2(3200,1800),
						Vector2(3840,2160),
						Vector2(4480,2520),
						Vector2(5120,2880),
						Vector2(5760,3240),
						Vector2(6400,3600),
						Vector2(7040,3960),
						Vector2(7680,4320)]
var gameplay_languages = [
		Locale.new("Deutsch", "de"),
		Locale.new("English", "en"),
		Locale.new("Español", "es"),
		Locale.new("Français", "fr"),
		Locale.new("Italiano", "it"),
		Locale.new("日本語", "ja"),
		Locale.new("한국어", "ko"),
		Locale.new("Polski", "pl"),
		Locale.new("Português", "pt"),
		Locale.new("Русский", "ru"),
		Locale.new("Türkçe", "tr"),
		Locale.new("中文", "zh"),
]

var group = preload("res://UI/Options/options_button_group.tres")

signal closed

func _ready():
	hide()
	video_tab.visible = false
	audio_tab.visible = false
	gameplay_tab.visible = false
	bindings_tab.visible = false
	video_button.toggled.connect(_on_toggle_tab.bind(video_tab))
	audio_button.toggled.connect(_on_toggle_tab.bind(audio_tab))
	gameplay_button.toggled.connect(_on_toggle_tab.bind(gameplay_tab))
	bindings_button.toggled.connect(_on_toggle_tab.bind(bindings_tab))
	video_button.set_pressed(true)
	
	var screen_size = DisplayServer.screen_get_size()
	for i in video_resolutions:
		if i.x <= screen_size.x and i.y <= screen_size.y:
			video_resolution_drop_down.add_item(str(i.x) + ":" + str(i.y))
		else:
			break
	video_resolution_drop_down.get_popup().transparent_bg = true
	for i in gameplay_languages:
		gameplay_language_drop_down.add_item(i.name)
	gameplay_language_drop_down.get_popup().transparent_bg = true
	
	for i in desc.get_children():
		i.visible = false
	desc.get_node("VSync/General").visible = true
	desc.get_node("VSync/Modes").visible = true
	update_video_vsync_desc_text()
	Glob.on_translation_updated.connect(update_video_vsync_desc_text)
	
	default_settings = Settings.new()
	saved_settings = Settings.new()
	current_settings = Settings.new()
	default_settings.video_vsync = 0
	default_settings.video_fullscreen = true
	default_settings.video_resolution = 5
	default_settings.gameplay_language = 1
	for i in gameplay_languages.size():
		if gameplay_languages[i].code == OS.get_locale().get_slice("_", 0):
			default_settings.gameplay_language = i
	copy_settings(saved_settings, default_settings)			#TODO replace with loading from .ini
	copy_settings(current_settings, saved_settings)
	
	apply_video_fullscreen()
	apply_video_resolution()
	apply_video_vsync()
	apply_gameplay_language()
	update_video_fullscreen()
	update_video_resolution()
	update_video_vsync()
	update_gameplay_language()

func _input(event: InputEvent):
	if event.is_action_pressed("menu"):
		deactivate()

func _on_toggle_tab(toggled_on: bool, tab: Control):
	if toggled_on == true:
		tab.visible = true
	else:
		tab.visible = false

func _on_discard_pressed():
	discard_changes()
	disable_buttons()

func _on_apply_pressed():
	apply_changes()
	disable_buttons()
	if check_for_changes(default_settings, saved_settings):
		reset_button.disabled = false
	else:
		reset_button.disabled = true

func _on_back_pressed():
	if check_for_changes(saved_settings, current_settings):
		discard_changes()
		disable_buttons()
	deactivate()

func _on_reset_pressed():
	reset_settings()
	reset_button.disabled = true

func _on_check_box_toggled(toggled_on):
	current_settings.video_fullscreen = toggled_on
	update_buttons()

func _on_drop_down_item_selected(index):
	current_settings.video_resolution = index
	update_buttons()

func _on_left_button_pressed():
	if current_settings.video_vsync == 0:
		current_settings.video_vsync = 3
	else:
		current_settings.video_vsync -= 1
	update_video_vsync()
	update_buttons()

func _on_right_button_pressed():
	if current_settings.video_vsync == 3:
		current_settings.video_vsync = 0
	else:
		current_settings.video_vsync += 1
	update_video_vsync()
	update_buttons()

func _on_v_sync_mouse_entered():
	desc.get_node("VSync").visible = true

func _on_v_sync_mouse_exited():
	desc.get_node("VSync").visible = false

func update_buttons():
	if check_for_changes(saved_settings, current_settings):
		enable_buttons()
	else:
		disable_buttons()

func enable_buttons():
	discard_button.disabled = false
	apply_button.disabled = false

func disable_buttons():
	discard_button.disabled = true
	apply_button.disabled = true

func check_for_changes(old_settings: Settings, new_settings: Settings):
	if old_settings.video_fullscreen != new_settings.video_fullscreen:
		return true
	if old_settings.video_resolution != new_settings.video_resolution:
		return true
	if old_settings.video_vsync != new_settings.video_vsync:
		return true
	return false

func reset_settings():
	if default_settings.video_fullscreen != current_settings.video_fullscreen:
		current_settings.video_fullscreen = default_settings.video_fullscreen
		update_video_fullscreen()
	if default_settings.video_fullscreen != saved_settings.video_fullscreen:
		saved_settings.video_fullscreen = default_settings.video_fullscreen
		apply_video_fullscreen()
	if default_settings.video_resolution != current_settings.video_resolution:
		current_settings.video_resolution = default_settings.video_resolution
		update_video_resolution()
	if default_settings.video_resolution != saved_settings.video_resolution:
		saved_settings.video_resolution = default_settings.video_resolution
		apply_video_resolution()
	if default_settings.video_vsync != current_settings.video_vsync:
		current_settings.video_vsync = default_settings.video_vsync
		update_video_vsync()
	if default_settings.video_vsync != saved_settings.video_vsync:
		saved_settings.video_vsync = default_settings.video_vsync
		apply_video_vsync()

func discard_changes():
	if  saved_settings.video_fullscreen != current_settings.video_fullscreen:
		current_settings.video_fullscreen = saved_settings.video_fullscreen
		update_video_fullscreen()
	if saved_settings.video_resolution != current_settings.video_resolution:
		current_settings.video_resolution = saved_settings.video_resolution
		update_video_resolution()
	if saved_settings.video_vsync != current_settings.video_vsync:
		current_settings.video_vsync = saved_settings.video_vsync
		update_video_vsync()

func apply_changes():
	if saved_settings.video_fullscreen != current_settings.video_fullscreen:
		saved_settings.video_fullscreen = current_settings.video_fullscreen
		apply_video_fullscreen()
	if saved_settings.video_resolution != current_settings.video_resolution:
		saved_settings.video_resolution = current_settings.video_resolution
		apply_video_resolution()
	if saved_settings.video_vsync != current_settings.video_vsync:
		saved_settings.video_vsync = current_settings.video_vsync
		apply_video_vsync()

func copy_settings(dst_settings: Settings, src_settings: Settings):
	dst_settings.video_fullscreen = src_settings.video_fullscreen
	dst_settings.video_resolution = src_settings.video_resolution
	dst_settings.video_vsync = src_settings.video_vsync
	dst_settings.gameplay_language = src_settings.gameplay_language

func apply_video_fullscreen():
	if saved_settings.video_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		get_window().borderless = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		get_window().borderless = false

func apply_video_resolution():
	var window_size = video_resolutions[saved_settings.video_resolution]
	var screen_size = DisplayServer.screen_get_size()
	var centered = Vector2(screen_size.x / 2 - window_size.x / 2, screen_size.y / 2 - window_size.y / 2)
	DisplayServer.window_set_size(window_size)
	DisplayServer.window_set_position(centered)
	Glob.current_scale = min(get_window().get_size_with_decorations().x / Glob.resolution.x,
			get_window().get_size_with_decorations().y / Glob.resolution.y)
	var arrow = load("res://Art/Office Pack/HUD/Cursors/cursor" + str(Glob.current_scale) + ".png")
	Input.set_custom_mouse_cursor(arrow)

func apply_video_vsync():
	match saved_settings.video_vsync:
		0:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		2:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		3:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)

func apply_gameplay_language():
	TranslationServer.set_locale(gameplay_languages[saved_settings.gameplay_language].code)
	Glob.on_translation_updated.emit()

func update_video_fullscreen():
	video_fullscreen_check_box.set_pressed_no_signal(current_settings.video_fullscreen)

func update_video_resolution():
	video_resolution_drop_down.selected = current_settings.video_resolution

func update_video_vsync():
	video_vsync_mode_label.text = video_vsync_mode_labels[current_settings.video_vsync]
	for i in desc.get_node("VSync/Modes").get_children():
		if i.name == video_vsync_mode_names[current_settings.video_vsync]:
			i.visible = true
		else:
			i.visible = false

func update_video_vsync_desc_text():
	desc.get_node("VSync/Modes/Off").bbcode_text = ("[color=cc2929]" + tr("OPTIONS_VIDEO_V_SYNC_OFF") + "[/color] — "
			+ tr("OPTIONS_VIDEO_V_SYNC_OFF_DESC"))
	desc.get_node("VSync/Modes/On").bbcode_text = ("[color=cc2929]" + tr("OPTIONS_VIDEO_V_SYNC_ON") + "[/color] — "
			+ tr("OPTIONS_VIDEO_V_SYNC_ON_DESC"))
	desc.get_node("VSync/Modes/Adapt").bbcode_text = ("[color=cc2929]" + tr("OPTIONS_VIDEO_V_SYNC_ADAPT") + "[/color] — "
			+ tr("OPTIONS_VIDEO_V_SYNC_ADAPT_DESC"))
	desc.get_node("VSync/Modes/Fast").bbcode_text = ("[color=cc2929]" + tr("OPTIONS_VIDEO_V_SYNC_FAST") + "[/color] — "
			+ tr("OPTIONS_VIDEO_V_SYNC_FAST_DESC"))

func update_gameplay_language():
	gameplay_language_drop_down.selected = current_settings.gameplay_language

func activate():
	show()

func deactivate():
	hide()
	closed.emit()

func _on_v_sync_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			desc_scroll.set_v_scroll(desc_scroll.get_v_scroll() - 10)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			desc_scroll.set_v_scroll(desc_scroll.get_v_scroll() + 10)
