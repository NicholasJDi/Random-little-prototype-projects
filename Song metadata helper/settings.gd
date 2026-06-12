extends PanelContainer
class_name SongMetadataHelperSettings

@onready var Preset: OptionButton = $"VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/Preset Options/HBoxContainer/Preset"
@onready var Filename_Type: OptionButton = $"VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/Preset Options/Custom/VBoxContainer/HBoxContainer/Filename Type"
@onready var Title_Type: OptionButton = $"VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/Preset Options/Custom/VBoxContainer/HBoxContainer2/Title Type"
@onready var Artist_Type: OptionButton = $"VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/Preset Options/Custom/VBoxContainer/HBoxContainer3/Artist Type"

@onready var Track_Type: OptionButton = $"VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/Track Type"
@onready var Album_Type: OptionButton = $"VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer9/Album Type"

@onready var Title: LineEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer2/Title
@onready var Artist: LineEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer3/Artist
@onready var Contributors: LineEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer4/Contributors
@onready var Original_Artist: LineEdit = $"VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer5/Original Artist"
@onready var Original_Contributors: LineEdit = $"VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer6/Original Contributors"
@onready var Album: LineEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer7/Album

@onready var Contributor_Style: OptionButton = $"VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer12/Contributor Style"
@onready var Put_Brackets_Around_Contributors: CheckButton = $"VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer11/Put Brackets Around Contributors"
@onready var Keep_Spaces_In_Filename: CheckButton = $"VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer8/Keep Spaces In Filename"

@onready var Original_Artist_box: HBoxContainer = $"VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer5"
@onready var Original_Contributors_box: HBoxContainer = $"VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer6"
@onready var Album_box: HBoxContainer = $"VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer7"

@onready var code_edit: CodeEdit = $"../Output/ScrollContainer/VBoxContainer/CodeEdit"
@onready var label: Label = $"../Output/ScrollContainer/VBoxContainer/HBoxContainer/Label"



var filename_type = 1
var title_type = 1
var artist_type = 1

var track_type = 1
var album_type = 0

var title = ""
var artist = ""
var contributors = ""
var original_artist = ""
var original_contributors = ""
var album = ""

var contributor_style = 0

var put_brackets_around_contributors = true
var keep_spaces_in_filename = true


func _on_preset_item_selected(index: int) -> void:
	match index:
		0:
			Filename_Type.select(0)
			filename_type = 0
			Title_Type.select(0)
			title_type = 0
			Artist_Type.select(0)
			artist_type = 0
		1:
			Filename_Type.select(1)
			filename_type = 1
			Title_Type.select(1)
			title_type = 1
			Artist_Type.select(1)
			artist_type = 1
		2:
			Filename_Type.select(1)
			filename_type = 1
			if track_type == 2:
				Title_Type.select(1)
				title_type = 1
			else:
				Title_Type.select(0)
				title_type = 0
			Artist_Type.select(2)
			artist_type = 2

func _on_filename_type_item_selected(index: int) -> void:
	filename_type = index
	check_preset()

func _on_title_type_item_selected(index: int) -> void:
	title_type = index
	check_preset()

func _on_artist_type_item_selected(index: int) -> void:
	artist_type = index
	check_preset()

func _on_track_type_item_selected(index: int) -> void:
	track_type = index
	check_preset()
	match index:
		0:
			Album_box.hide()
			Original_Artist_box.hide()
			Original_Contributors_box.hide()
			Album_Type.get_parent().show()
			Album_Type.set_item_text(0,"Title")
			Album_Type.set_item_text(1,"Single")
		1:
			Album_box.show()
			Original_Artist_box.hide()
			Original_Contributors_box.hide()
			Album_Type.get_parent().show()
			Album_Type.set_item_text(0,"Normal")
			Album_Type.set_item_text(1,"Extended Play (EP)")
		2:
			Album_box.hide()
			Original_Artist_box.show()
			Original_Contributors_box.show()
			Album_Type.get_parent().hide()
	if index == 2:
		Filename_Type.set_item_text(0,"Compact [original artist1 - title [artist1 Remix]]")
		Filename_Type.set_item_text(1,"Normal [original artist - title [artist Remix (with contributors)]]")
		Filename_Type.set_item_text(2,"Extended: [original artist (with original contributors) - title [artist Remix (with contributors)]]")
		Title_Type.set_item_text(0,"Compact [title [artist1 Remix]]")
		Title_Type.set_item_text(1,"Normal [original artist - title [artist Remix (with contributors)]]")
		Title_Type.set_item_text(2,"Extended: [original artist (with original contributors) - title [artist Remix (with contributors)]")
	else:
		Filename_Type.set_item_text(0,"Compact [artist1 - title]")
		Filename_Type.set_item_text(1,"Normal [artist - title (with contributors)]")
		Filename_Type.set_item_text(2,"Extended [artist - album - title (with contributors)]")
		Title_Type.set_item_text(0,"Compact [title]")
		Title_Type.set_item_text(1,"Normal [title (with contributors)]")
		Title_Type.set_item_text(2,"Extended [artist - title (with contributors)]")

func _on_title_text_changed(new_text: String) -> void:
	title = new_text

func _on_artist_text_changed(new_text: String) -> void:
	artist = new_text

func _on_contributors_text_changed(new_text: String) -> void:
	contributors = new_text

func _on_original_artist_text_changed(new_text: String) -> void:
	original_artist = new_text

func _on_original_contributors_text_changed(new_text: String) -> void:
	original_contributors = new_text

func _on_album_text_changed(new_text: String) -> void:
	album = new_text

func _on_keep_spaces_in_filename_toggled(toggled_on: bool) -> void:
	keep_spaces_in_filename = toggled_on

func _on_album_type_item_selected(index: int) -> void:
	album_type = index

func check_preset():
	if filename_type == 0 and title_type == 0 and artist_type == 0:
		Preset.select(0)
	elif filename_type == 1 and title_type == 1 and artist_type == 1:
		Preset.select(1)
	elif track_type == 2 and filename_type == 1 and title_type == 1 and artist_type == 2:
		Preset.select(2)
	elif track_type != 2 and filename_type == 1 and title_type == 0 and artist_type == 2:
		Preset.select(2)
	else:
		Preset.select(3)

func _on_export_pressed() -> void:
	export()

func export() -> void:
	var data_to_send = {}
	data_to_send.types = {}
	# filename type
	match filename_type:
		0:
			data_to_send.types.filename = "Compact"
		1:
			data_to_send.types.filename = "Normal"
		2:
			data_to_send.types.filename = "Extended"
	# title type
	match title_type:
		0:
			data_to_send.types.title = "Compact"
		1:
			data_to_send.types.title = "Normal"
		2:
			data_to_send.types.title = "Extended"
	# artist type
	match artist_type:
		0:
			data_to_send.types.artist = "Single"
		1:
			data_to_send.types.artist = "Multiple"
		2:
			data_to_send.types.artist = "All"
	# track type
	match track_type:
		0:
			data_to_send.types.track = "Single"
		1:
			data_to_send.types.track = "Normal"
		2:
			data_to_send.types.track = "Remix"
	# album type
	if track_type != 2:
		if track_type == 1:
			match album_type:
				0:
					data_to_send.types.album = "Normal"
				1:
					data_to_send.types.album = "EP"
		else:
			match album_type:
				0:
					data_to_send.types.album = "Title"
				1:
					data_to_send.types.album = "Single"
	# title
	if !title.strip_edges().is_empty():
		data_to_send.title = title.strip_edges()
	# album
	if track_type == 1:
		if !album.strip_edges().is_empty():
			data_to_send.album = album.strip_edges()
	# artist array
	if !artist.strip_edges().is_empty():
		var array = []
		for item in artist.split(","):
			item = item.strip_edges()
			if !item.is_empty():
				array.append(item)
		data_to_send.artist = array
	# contributors array
	if !contributors.strip_edges().is_empty():
		var array = []
		for item in contributors.split(","):
			item = item.strip_edges()
			if !item.is_empty():
				array.append(item)
		data_to_send.contributors = array
	if track_type == 2:
		# original artist array
		if !original_artist.strip_edges().is_empty():
			var array = []
			for item in original_artist.split(","):
				item = item.strip_edges()
				if !item.is_empty():
					array.append(item)
			data_to_send.original_artist = array
		# original contributors array
		if !original_contributors.strip_edges().is_empty():
			var array = []
			for item in original_contributors.split(","):
				item = item.strip_edges()
				if !item.is_empty():
					array.append(item)
			data_to_send.original_contributors = array
	match contributor_style:
		0:
			data_to_send.contributor_style = "with"
		1:
			data_to_send.contributor_style = "ft"
		2:
			data_to_send.contributor_style = "feat"
		3:
			data_to_send.contributor_style = "x"
		4:
			data_to_send.contributor_style = ","
	data_to_send.brackets_around_contributors = put_brackets_around_contributors
	data_to_send.spaces_in_filename = keep_spaces_in_filename
	code_edit.text = JSON.stringify(data_to_send, "\t",false)

func _on_import_pressed() -> void:
	var json = JSON.new()
	var error = json.parse(code_edit.text)
	if error == OK:
		var data_received : Dictionary = json.data
		
		# filename type
		if "types" in data_received and typeof(data_received.types) ==TYPE_DICTIONARY and "filename" in data_received.types and typeof(data_received.types.filename) == TYPE_STRING:
			match data_received.types.filename:
				"Compact":
					Filename_Type.select(0)
					filename_type = 0
				"Normal":
					Filename_Type.select(1)
					filename_type = 1
				"Extended":
					Filename_Type.select(2)
					filename_type = 2
		
		# title type
		if "types" in data_received and typeof(data_received.types) ==TYPE_DICTIONARY and "title" in data_received.types and typeof(data_received.types.title) == TYPE_STRING:
			match data_received.types.title:
				"Compact":
					Title_Type.select(0)
					title_type =10
				"Normal":
					Title_Type.select(1)
					title_type = 1
				"Extended":
					Title_Type.select(2)
					title_type = 2
		
		# artist type
		if "types" in data_received and typeof(data_received.types) ==TYPE_DICTIONARY and "artist" in data_received.types and typeof(data_received.types.artist) == TYPE_STRING:
			match data_received.types.artist:
				"Single":
					Artist_Type.select(0)
					artist_type = 0
				"Multiple":
					Artist_Type.select(1)
					artist_type = 1
				"All":
					Artist_Type.select(2)
					artist_type = 2
		
		# track type
		if "types" in data_received and typeof(data_received.types) ==TYPE_DICTIONARY and "track" in data_received.types and typeof(data_received.types.track) == TYPE_STRING:
			match data_received.types.track:
				"Single":
					Track_Type.select(0)
					track_type = 0
				"Normal":
					Track_Type.select(1)
					track_type = 1
				"Remix":
					Track_Type.select(2)
					track_type = 2
		
		# album type
		if "types" in data_received and typeof(data_received.types) ==TYPE_DICTIONARY and "album" in data_received.types and typeof(data_received.types.album) == TYPE_STRING:
			match data_received.types.album:
				"Normal":
					Album_Type.select(0)
					album_type = 0
				"EP":
					Album_Type.select(1)
					album_type = 1
				"Title":
					Album_Type.select(0)
					album_type = 0
				"Single":
					Album_Type.select(1)
					album_type = 1
		
		# title
		if "title" in data_received and typeof(data_received.title)  == TYPE_STRING:
			title = data_received.title.strip_edges()
			Title.text = title
		
		var array = []
		# artist array
		if "artist" in data_received and typeof(data_received.artist) == TYPE_ARRAY:
			for item in data_received.artist:
				if typeof(item) == TYPE_STRING:
					item = item.strip_edges()
					array.append(item)
			artist = ", ".join(array)
			Artist.text = artist
		array = []
		# contributors array
		if "contributors" in data_received and typeof(data_received.contributors) == TYPE_ARRAY:
			for item in data_received.contributors:
				if typeof(item) == TYPE_STRING:
					item = item.strip_edges()
					array.append(item)
			contributors = ", ".join(array)
			Contributors.text = contributors
		array = []
		# original artist array
		if "original_artist" in data_received and typeof(data_received.original_artist) == TYPE_ARRAY:
			for item in data_received.original_artist:
				if typeof(item) == TYPE_STRING:
					item = item.strip_edges()
					array.append(item)
			original_artist = ", ".join(array)
			Original_Artist.text = original_artist
		array = []
		# original contributors array
		if "original_contributors" in data_received and typeof(data_received.original_contributors) == TYPE_ARRAY:
			for item in data_received.original_contributors:
				if typeof(item) == TYPE_STRING:
					item = item.strip_edges()
					array.append(item)
			original_contributors = ", ".join(array)
			Original_Contributors.text = original_contributors
		
		# album
		if "album" in data_received and typeof(data_received.album) == TYPE_STRING:
			album = data_received.album.strip_edges()
			Album.text = album
		
		# contributor style
		if "contributor_style" in data_received and typeof(data_received.contributor_style) == TYPE_STRING:
			match data_received.contributor_style:
				"with":
					Contributor_Style.select(0)
					contributor_style = 0
				"ft":
					Contributor_Style.select(1)
					contributor_style = 1
				"feat":
					Contributor_Style.select(2)
					contributor_style = 2
				"x":
					Contributor_Style.select(3)
					contributor_style = 3
				",":
					Contributor_Style.select(4)
					contributor_style = 4
		
		# contributor brackets
		if "brackets_around_contributors" in data_received and typeof(data_received.brackets_around_contributors) == TYPE_BOOL:
			Put_Brackets_Around_Contributors.button_pressed = data_received.brackets_around_contributors
		
		# keep spaces
		if "spaces_in_filename" in data_received and typeof(data_received.spaces_in_filename) == TYPE_BOOL:
			Keep_Spaces_In_Filename.button_pressed = data_received.spaces_in_filename
		
		check_preset()
	else:
		label.text = "Error: at line " + str(json.get_error_line() + 1) + " (" + json.get_error_message() + ")"
		await get_tree().create_timer(1).timeout
		label.text = "Import/Export"

func _on_put_brackets_around_contributors_toggled(toggled_on: bool) -> void:
	put_brackets_around_contributors = toggled_on

func _on_contributor_style_item_selected(index: int) -> void:
	contributor_style = index
