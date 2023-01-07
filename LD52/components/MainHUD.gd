extends PanelContainer

export var title: String = "World Map"
export var show_mother_ship_text: bool = true

func _ready():
	$TopBar/MaginContainer/HBox/WorldMapLabel.text = title
	$BottomBar/MaginContainer/HBox/MarginContainer2.visible = show_mother_ship_text
	$BottomBar/MaginContainer/HBox/WorldMapLabel.visible = show_mother_ship_text
