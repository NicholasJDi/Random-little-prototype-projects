extends Control

@onready var output: CodeEdit = $ColorRect/MarginContainer/VBoxContainer/HSplitContainer/ScrollContainer/VSplitContainer/Output/VBoxContainer/CodeEdit

@onready var input: CodeEdit = $ColorRect/MarginContainer/VBoxContainer/HSplitContainer/ScrollContainer/VSplitContainer/Input/VBoxContainer/CodeEdit
@onready var current_position: LineEdit = $ColorRect/MarginContainer/VBoxContainer/HSplitContainer/ScrollContainer/VSplitContainer/Input/VBoxContainer/HBoxContainer/Position

@onready var timestamp_open: LineEdit = $"ColorRect/MarginContainer/VBoxContainer/HSplitContainer/Settings/VBoxContainer/HBoxContainer/Timestamp Open"
@onready var timestamp_close: LineEdit = $"ColorRect/MarginContainer/VBoxContainer/HSplitContainer/Settings/VBoxContainer/HBoxContainer2/Timestamp Close"
@onready var grab_neighboring_timestamps: CheckButton = $"ColorRect/MarginContainer/VBoxContainer/HSplitContainer/Settings/VBoxContainer/HBoxContainer4/Grab Neighboring Timestamps"
@onready var break_if_invalid_characters_in_timestamp: CheckButton = $"ColorRect/MarginContainer/VBoxContainer/HSplitContainer/Settings/VBoxContainer/HBoxContainer5/Break If Invalid Characters In Timestamp"

func _on_button_pressed() -> void:
	output.text = JSON.stringify(parse_timestamp_list(input.text, convert_from_timestamp(current_position.text),grab_neighboring_timestamps.button_pressed, break_if_invalid_characters_in_timestamp.button_pressed,timestamp_open.text,timestamp_close.text))

@warning_ignore("shadowed_variable")
func parse_timestamp_list(timestamp_list : String, current_time_seconds : float, include_next_last : bool = false, break_on_invalid_character : bool = false, timestamp_open : String = "[", timestamp_close : String = "]:") -> Dictionary:
	if is_nan(current_time_seconds):
		push_error("Invalid current time float (current_time_seconds is NAN)")
		return {"ERROR":"Current time is not a number"}
	var dict = {}
	for line in timestamp_list.split("\n"):
		if line.begins_with(timestamp_open):
			line = line.trim_prefix(timestamp_open)
			var close = line.find(timestamp_close)
			if close != -1:
				var timestamp = line.substr(0,close)
				var time = convert_from_timestamp(timestamp,break_on_invalid_character)
				if time != -INF:
					dict[time] = line.substr(close + timestamp_close.length())
	var data_to_return = {}
	var keyarray = dict.keys()
	keyarray.sort()
	var base = -1
	for key in keyarray:
		if current_time_seconds >= key:
			base = key
		else:
			break
	if base == -1:
		data_to_return.current = ["NULL",NAN]
	else:
		data_to_return.current = [dict[base],base]
	if include_next_last: # next/last processing
		var last = keyarray.find(base) -1
		var next = keyarray.find(base) + 1
		if last <= -1:
			data_to_return.last = ["NULL",-INF]
		else:
			data_to_return.last = [dict[keyarray[last]],keyarray[last]]
		if next >= keyarray.size():
			data_to_return.next = ["NULL",INF]
		else:
			data_to_return.next = [dict[keyarray[next]],keyarray[next]]
	return data_to_return

func convert_from_timestamp(timestamp : String, break_on_invalid_character : bool = false) -> float:
	var timestampout = ""
	var valid = false
	for character in timestamp:
		if "1234567890".split().has(character):
			timestampout += character
			valid = true
		elif character == ":" or character == ".":
			timestampout += character
		elif break_on_invalid_character:
			timestampout = ""
			break
	if timestampout.is_empty() or !valid:
		push_warning("Given Timestamp is not a valid value (timestamp is empty or invalid)")
		return -INF
	var array = timestampout.split(":")
	if array.size() > 3:
		push_error("Too many time signatures provided (more than two : in timestamp)")
		return NAN
	var timeout = 0.0
	var id = 0
	array.reverse()
	for string in array:
		id += 1
		var num = float(string)
		var multi = 1
		if id == 2:
			multi = 60
		elif id == 3:
			multi = 3600
		timeout += num * multi
	return timeout
