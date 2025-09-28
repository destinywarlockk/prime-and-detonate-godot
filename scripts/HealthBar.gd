extends ProgressBar

@export var actor_path: NodePath
var actor: Actor

func _ready():
    actor = get_node(actor_path) as Actor
    value = actor.hp
    max_value = actor.max_hp
    actor.hp_changed.connect(_on_hp_changed)

func _on_hp_changed(curr, maxv):
    max_value = maxv
    value = curr
