extends Node2D

@onready var interactable : Interactable = $interactable

func _ready() -> void:
	interactable.on_interact.connect(m_print_message)



func m_print_message(n_owner : Variant) -> void:
	print("I was interacted by ", n_owner.name)
