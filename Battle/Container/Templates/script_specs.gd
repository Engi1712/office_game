class_name ScriptSpecs extends Resource

@export var script_name: String
@export var copy_price: int
@export var delete_price: int
@export var run_price: int
@export var stop_price: int
@export var direction: BattleCommonCore.script_directions
@export var type: BattleCommonCore.script_types
@export var select: Array[ScriptSelect]
@export var temporary: int
@export var values: Array[ScriptValue]
@export var shop_price: int
@export var cpu_bound: bool
@export var auto_deleted: bool
