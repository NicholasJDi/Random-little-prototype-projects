extends Control

@onready var output: CodeEdit = $ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer/Output/ScrollContainer/VSplitContainer/Output/VBoxContainer/Output
@onready var data_edit: CodeEdit = $ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer/Output/ScrollContainer/VSplitContainer/Input/VBoxContainer/Data
@onready var search: LineEdit = $ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer/Output/ScrollContainer/VSplitContainer/Input/VBoxContainer/HBoxContainer/Search
@onready var sort_type: OptionButton = $"ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer/Output/ScrollContainer/VSplitContainer/Input/VBoxContainer/HBoxContainer2/Sort Type"

@onready var sort_scheme_edit: CodeEdit = $"ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer/Settings/VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/Sort Scheme"
@onready var search_scheme_edit: CodeEdit = $"ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer/Settings/VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/Search Scheme"

@onready var help_menu: PanelContainer = $"ColorRect/MarginContainer/VBoxContainer/VSplitContainer/Help Menu"
@onready var label: Label = $ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer/Settings/VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/Label
@onready var label_2: Label = $ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer/Settings/VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/Label2
@onready var label_3: Label = $ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer/Output/ScrollContainer/VSplitContainer/Input/VBoxContainer/Label2

func _on_update_ui_pressed() -> void:
	var json = JSON.new()
	var error = json.parse(sort_scheme_edit.text)
	if error == OK:
		var data_received : Dictionary = json.data
		for i in sort_type.item_count:
			sort_type.clear()
		sort_type.add_item("None (Search Only)",0)
		var i = 0
		for key in data_received.keys():
			i += 1
			sort_type.add_item(key.strip_edges().strip_escapes().to_snake_case().capitalize(), i)
	else:
		label.text = "Error: at line " + str(json.get_error_line() + 1) + " (" + json.get_error_message() + ")"
		await get_tree().create_timer(1).timeout
		label.text = "Sort Scheme:"

func _on_button_pressed() -> void:
	var json = JSON.new()
	var error = json.parse(search_scheme_edit.text)
	if error == OK:
		var data_received = json.data
		json = JSON.new()
		error = json.parse(data_edit.text)
		if error == OK:
			var data_received2 = json.data
			var data_to_send = []
			data_to_send = sort_data_by_search(data_received2,data_received,search.text, true)
			if sort_type.get_selected_id() != 0:
				json = JSON.new()
				error = json.parse(sort_scheme_edit.text)
				if error == OK:
					var data_received3 = json.data
					data_to_send = sort_data_by_scheme_mode(data_to_send,data_received3,data_received3.keys()[sort_type.get_selected_id() - 1])
				else:
					label.text = "Error: at line " + str(json.get_error_line() + 1) + " (" + json.get_error_message() + ")"
					await get_tree().create_timer(1).timeout
					label.text = "Sort Scheme:"
			output.text = JSON.stringify(data_to_send, "\t",false)
		else:
			label_3.text = "Error: at line " + str(json.get_error_line() + 1) + " (" + json.get_error_message() + ")"
			await get_tree().create_timer(1).timeout
			label_3.text = "Data:"
	else:
		label_2.text = "Error: at line " + str(json.get_error_line() + 1) + " (" + json.get_error_message() + ")"
		await get_tree().create_timer(1).timeout
		label_2.text = "Search Scheme:"

func sort_data_by_search(data : Array, search_scheme : Dictionary, input_text : String = "", include_weight : bool = false) -> Array:
	if input_text == "":
		return data
	else:
		data.reverse()
		var outData = []
		var index = []
		for i in data.size():
			index.append(0)
		var input_tokens = input_text.to_lower().split(" ",false)
		var i = 0
		for key in search_scheme.keys():
			i = 0
			var search_item = search_scheme[key]
			for item in data:
				if item.has(key):
					var value = item[key]
					if typeof(value) == TYPE_ARRAY:
						value = " ".join(value)
					value = value.to_lower().split(" ",false)
					var success = false
					var token_weight = 0
					if search_item.has("token_weight"):
						token_weight = float(search_item.token_weight)
					var weight = 1
					if search_item.has("weight"):
						weight = float(search_item.weight)
					var position_weight = 0
					if search_item.has("position_weight"):
						position_weight = float(search_item.position_weight)
					var total_weight = 0
					match search_item.type:
						"contains":
							for token : String in input_tokens:
								for search_token : String in value:
									if search_token.contains(token):
										success = true
										total_weight += token_weight
										total_weight += position_weight * (input_tokens.size() - input_tokens.find(token))
						"exact":
							for token : String in input_tokens:
								if value.has(token):
									success = true
									total_weight += token_weight
									total_weight += position_weight * (input_tokens.size() - input_tokens.find(token))
						"range":
							pass # to do
					if success:
						total_weight += weight
					index[i] += total_weight
				i += 1
		i = 0
		var sort_array = []
		for item in index:
			if item != 0:
				sort_array.append([item,i])
			i += 1
		sort_array.sort()
		sort_array.reverse()
		for item in sort_array:
			outData.append(data[item[1]])
			if include_weight:
				outData.back().weight = item[0]
		return outData

func sort_data_by_scheme_mode(data : Array, sort_scheme : Dictionary, sort_mode : String = "default") -> Array:
	var mode = sort_scheme[sort_mode]
	while typeof(mode) == TYPE_STRING:
		if sort_scheme.has(mode):
			mode = sort_scheme[mode]
	return sort_data(data,mode)

func sort_data(data : Array, sort_mode : Dictionary) -> Array:
	var groups = [data]
	for rule_key in sort_mode.keys():
		var rule = sort_mode[rule_key]
		var new_groups = []
		var group_map = {}
		var i = 0
		for group in groups:
			match rule.type:
				"sort":
					var g = group.duplicate()
					g.sort_custom(func(a, b):
						if rule.get("reverse", false):
							return a.get(rule_key) > b.get(rule_key)
						else:
							return a.get(rule_key) < b.get(rule_key)
					)
					new_groups.append(g)
				"order":
					var buckets = {}
					for bucket in rule.order:
						buckets[bucket] = []
					buckets[null] = []
					for item in group:
						var key = item.get(rule_key,null)
						if buckets.has(key):
							buckets[key].append(item)
						else:
							buckets[null].append(item)
					for bucket in buckets.keys():
						if buckets[bucket].size() > 0:
							new_groups.append(buckets[bucket])
				"group":
					var items = []
					for item in group:
						var value = item.get(rule_key)
						if value != null:
							if items.size() > 0:
								var g = []
								for itm in items:
									g.append(itm)
								new_groups.append(g)
								i += 1
								items.clear()
							if group_map.has(value):
								new_groups[group_map[value]].append(item)
							else:
								group_map[value] = i
								i += 1
								new_groups.append([item])
						else:
							items.append(item)
					if items.size() > 0:
						var g = []
						for item in items:
							g.append(item)
						new_groups.append(g)
						i += 1
		if rule.type == "group" and rule.get("reverse",false):
			for item in group_map:
				new_groups[group_map[item]].reverse()
		if rule.get("reverse_after",false):
			new_groups.reverse()
		groups = new_groups
	return flatten(groups)

func flatten(array: Array) -> Array:
	var out = []
	for item in array:
		if typeof(item) == TYPE_ARRAY:
			out += flatten(item)
		else:
			out.append(item)
	return out

func _on_help_pressed() -> void:
	help_menu.show()

func _on_exit_pressed() -> void:
	help_menu.hide()
