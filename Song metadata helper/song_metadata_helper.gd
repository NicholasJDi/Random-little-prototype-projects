extends Control

@onready var Filename: LineEdit = $ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer/Output/ScrollContainer/VBoxContainer/filename/container/field
@onready var Title: LineEdit = $ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer/Output/ScrollContainer/VBoxContainer/title/container/field
@onready var Artist: LineEdit = $ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer/Output/ScrollContainer/VBoxContainer/artist/container/field
@onready var Album: LineEdit = $ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer/Output/ScrollContainer/VBoxContainer/album/container/field
@onready var Settings: SongMetadataHelperSettings = $ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer/Settings

@onready var h_split_container: HSplitContainer = $ColorRect/MarginContainer/VBoxContainer/VSplitContainer/HSplitContainer
@onready var help_menu: PanelContainer = $"ColorRect/MarginContainer/VBoxContainer/VSplitContainer/Help Menu"

var filename_text : String = "%artist% - %title text%"
var title_text : String	= "%title text%"
var artist_text : String = "%artist%"
var album_text : String = "%album text%"


func set_field_values():
	Title.text = title_text
	Artist.text = artist_text
	Album.text = album_text
	var filenameout = ""
	var characters = "abcdefghijklmnopqrstuvwxyz123456789-.,_ ()[]{}<>~".split("")
	var id = 0
	for character in filename_text:
		if characters.has(character.to_lower()):
			if id == 0 and ["-",".","_",",","~"," "].has(character):
				continue
			id += 1
			filenameout += character
	Filename.text = filenameout

func _on_button_pressed() -> void:
	format()

func format() -> void:
	var array = []
	var modifier = "with"
	match Settings.contributor_style:
		0: modifier = "with"
		1: modifier = "ft"
		2: modifier = "feat"
		3: modifier = "x"
		4: modifier = ","
	# album
	var tempalbum = Settings.album.strip_edges()
	match Settings.track_type:
		0: if Settings.album_type == 0:
			tempalbum = Settings.title.strip_edges()
		else: tempalbum = "Single"
		1: if Settings.album_type == 1:
			tempalbum += " (EP)"
		2: tempalbum = "Remix"
	album_text = tempalbum
	# filename
	var tempfilename = ""
	match Settings.filename_type:
		0: # Compact
			if Settings.track_type == 2:
				tempfilename = Settings.original_artist.split(",")[0].strip_edges() + " - " + Settings.title.strip_edges() + " [" + Settings.artist.split(",")[0].strip_edges() + " Remix]"
			else: tempfilename = Settings.artist.split(",")[0].strip_edges() + " - " + Settings.title.strip_edges()
		1: # Normal
			if Settings.track_type == 2:
				tempfilename = combine_with_modifier(Settings.original_artist.split(","),false,"x") + " - " + Settings.title.strip_edges() + " [" + combine_with_modifier(Settings.artist.split(","),false,"x") + " " + ("Remix " + combine_with_modifier(Settings.contributors.split(","),Settings.put_brackets_around_contributors,modifier)).strip_edges() + "]"
			else: tempfilename = (combine_with_modifier(Settings.artist.split(","),false,"x") + " - " + Settings.title.strip_edges() + " " + combine_with_modifier(Settings.contributors.split(","),Settings.put_brackets_around_contributors,modifier)).strip_edges()
		2: # Extended
			if Settings.track_type == 2:
				tempfilename = (combine_with_modifier(Settings.original_artist.split(","),false,"x") + " " + combine_with_modifier(Settings.original_contributors.split(","),Settings.put_brackets_around_contributors,modifier)).strip_edges() + " - " + Settings.title.strip_edges() + " [" + combine_with_modifier(Settings.artist.split(","),false,"x") + " " + ("Remix " + combine_with_modifier(Settings.contributors.split(","),Settings.put_brackets_around_contributors,modifier)).strip_edges() + "]"
			else: tempfilename = (combine_with_modifier(Settings.artist.split(","),false,"x") + " - " + tempalbum + " - " + Settings.title.strip_edges() + " " + combine_with_modifier(Settings.contributors.split(","),Settings.put_brackets_around_contributors,modifier)).strip_edges()
	# title
	match Settings.title_type:
		0: # Compact
			if Settings.track_type == 2:
				title_text = Settings.title.strip_edges() + " [" + Settings.artist.split(",")[0].strip_edges() + " Remix]"
			else: title_text = Settings.title.strip_edges()
		1: # Normal
			if Settings.track_type == 2:
				title_text = combine_with_modifier(Settings.original_artist.split(","),false,"x") + " - " + Settings.title.strip_edges() + " [" + combine_with_modifier(Settings.artist.split(","),false,"x") + " " + ("Remix " + combine_with_modifier(Settings.contributors.split(","),Settings.put_brackets_around_contributors,modifier)).strip_edges() + "]"
			else:
				if Settings.artist_type == 0:
					array.append_array(Settings.artist.split(","))
					array.remove_at(0)
				array.append_array(Settings.contributors.split(","))
				title_text = (Settings.title.strip_edges() + " " + combine_with_modifier(array,Settings.put_brackets_around_contributors,modifier)).strip_edges()
		2: # Extended
			if Settings.track_type == 2:
				title_text = (combine_with_modifier(Settings.original_artist.split(","),false,"x") + " " + combine_with_modifier(Settings.original_contributors.split(","),Settings.put_brackets_around_contributors,modifier)).strip_edges() + " - " + Settings.title.strip_edges() + " [" + combine_with_modifier(Settings.artist.split(","),false,"x") + " " + ("Remix " + combine_with_modifier(Settings.contributors.split(","),Settings.put_brackets_around_contributors,modifier)).strip_edges() + "]"
			else: title_text = (combine_with_modifier(Settings.artist.split(","),false,"x") + " - " + Settings.title.strip_edges() + " " + combine_with_modifier(Settings.contributors.split(","),Settings.put_brackets_around_contributors,modifier)).strip_edges()
	# artist
	array = []
	match Settings.artist_type:
		0: array.append(Settings.artist.split(",")[0].strip_edges())
		1: array.append_array(Settings.artist.split(","))
		2: 
			array.append_array(Settings.artist.split(","))
			array.append_array(Settings.contributors.split(","))
	artist_text = combine_with_modifier(array,false,",")
	if not Settings.keep_spaces_in_filename:
		tempfilename = tempfilename.replace(" - ","--").replace(" x ","_x_").replace(" ","_")
	filename_text = tempfilename
	set_field_values()

func combine_with_modifier(strings : Array, brackets : bool = true, modifier : String = "with") -> String:
	var combined = combine_strings(strings)
	var stringout = ""
	if !combined.is_empty():
		if brackets: stringout += "("
		match modifier:
			"with": stringout += "with " + combined
			"x": stringout += combine_strings(strings, " x ", " x ")
			"ft": stringout += "ft. " + combined
			"feat": stringout += "feat. " + combined
			",": stringout += combine_strings(strings, ", ", ", ")
		if brackets: stringout += ")"
	return stringout

func combine_strings(string_array: Array, normal : String = ", ", final : String = " and ") -> String:
	var stringout = ""
	var array = []
	var id = 0
	for string in string_array:
		string = string.strip_edges()
		if !string.is_empty():
			array.append(string)
	id = 0
	for string in array:
		id += 1
		if id == 1:
			stringout += string
		elif id== array.size():
			stringout += final + string
		else:
			stringout += normal + string
	return stringout

func _on_exit_pressed() -> void:
	help_menu.hide()

func _on_help_pressed() -> void:
	help_menu.show()
