extends Spatial

var n
var wov = Vector3(0, 0, 0)
var old_n

var inst_5
var inst_7
var inst_8
var inst_8_mesh
var mode_change = 0
var vw = Vector3(0, 0, 0)
var SPEED = 5
var velocity = Vector3(0, 0, 0)
onready var c = get_node("Player/Sphere")
onready var d = get_node("Player")
onready var f = get_node("Player/loc")
var mouse_sensitivity = 0.002

var inst_4_head
var inst_4_body

var box_map = []

func vector_mag(var v):
	return sqrt(v.x * v.x + v.y * v.y + v.z * v.z)

var r_y = 0
var r_x = 0
var z = 0
	
func return_vector(var v):
	return Vector3(v.x, v.y, v.z)

var inst_4
var move_vector = Vector3(0, 0, 0)
var BOX_SIZE = 21
var MFY = 8

onready var tree = preload("res://tree_1.tscn")
onready var ground = preload("res://ground_1.tscn")
onready var water = preload("res://water.tscn")
onready var stone = preload("res://stone_2.tscn")
onready var worker = preload("res://worker_1.tscn")
onready var wall = preload("res://wall_s1.tscn")

var graph_count
var box =[]
var a =[]
var b =[]
var length = []
var vertex = []
var previous = []

func add_node( var loc, var displacement, var cost):
	if box[loc + displacement] == 0:
		a.append(loc)
		b.append(loc + displacement)
		length.append(cost)
		graph_count += 1
		
func is_graph_empty(var vertice_count, var end):
	for i in range(0, vertice_count):
		if i == end:
			continue
		if vertex[i] != 0:
			return 0
	return 0

func dijkstra(var graph_length, var vertice_count, var source, var end):
	var count_end = 0
	var dist = []
	var end_friend = []
	for i in range(0, vertice_count):
		dist.append(1000000)
		previous.append(-1)
		end_friend.append(-1)
	for i in range(0, graph_length):
		if b[i] == end:
			end_friend[count_end] = a[i]
			count_end += 1
	var count = count_end
	dist[source] = 0
	while(is_graph_empty(vertice_count, end) == 0):
		var u
		var alt
		var v
		var index = 0
		var minimum = 100000
		while true:
			if vertex[index] != 0 and index != end:
				if dist[index] < minimum:
					minimum = dist[index]
					u = index
			index += 1
			if (index < vertice_count) == false:
				break
		for i in range(0, count_end):
			if end_friend[i] == u:
				count -= 1
				break
		if count == 0:
			var tmp_index = graph_length
			for i in range(0, graph_length):
				if a[i] == u and b[i] == end:
					tmp_index = i
					break
			alt = dist[u] + length[tmp_index]
			if alt < dist[end]:
				dist[end] = alt
				previous[end] = u
			return
		vertex[u] = 0
		for i in range(0, graph_length):
			if a[i] == u and vertex[b[i]] != 0:
				v = b[i]
				alt = dist[u] + length[i]
				if alt < dist[v]:
					dist[v] = alt
					previous[v] = u
	return

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	for i in range(0, BOX_SIZE * BOX_SIZE):
		box.append(0)
	var index_2 =0
	for i in range(0, BOX_SIZE):
		box[i] = 1
	for i in range(BOX_SIZE*BOX_SIZE-BOX_SIZE, BOX_SIZE*BOX_SIZE):
		box[i] = 1
	while index_2 < BOX_SIZE*BOX_SIZE:
		box[index_2] = 1
		index_2 += BOX_SIZE
	index_2 = BOX_SIZE-1
	while index_2<BOX_SIZE*BOX_SIZE:
		box[index_2] =1
		index_2 += BOX_SIZE
	for i in range(0, BOX_SIZE * BOX_SIZE):
		if box[i] == 0:
			vertex.append(1)
		else:
			vertex.append(0)
	graph_count = 0
	for i in range(0, BOX_SIZE * BOX_SIZE):
		if box[i] == 0:
			add_node(i, -BOX_SIZE, 100)
			add_node(i, -1, 100)
			add_node(i, +1, 100)
			add_node(i, +BOX_SIZE, 100)
			add_node(i, -BOX_SIZE-1, 141)
			add_node(i, -BOX_SIZE+1, 141)
			add_node(i, +BOX_SIZE-1, 141)
			add_node(i, +BOX_SIZE+1, 141)
	dijkstra(graph_count, BOX_SIZE * BOX_SIZE, BOX_SIZE + 1, BOX_SIZE * BOX_SIZE - BOX_SIZE - 2)
	for i in range(-(BOX_SIZE - 1)/2, (BOX_SIZE - 1)/2 + 1):
		for j in range(-(BOX_SIZE - 1)/2, (BOX_SIZE - 1)/2 + 1):
			box_map.append(Vector3(MFY*i, 0, MFY*j))
	n = BOX_SIZE * BOX_SIZE - BOX_SIZE - 2
	for i in range(-(BOX_SIZE - 1)/2, (BOX_SIZE - 1)/2 + 1):
		for j in range(-(BOX_SIZE - 1)/2, (BOX_SIZE - 1)/2 + 1):
			if i > 1 and i < 6 and j > 1 and j < 6:
				pass
			else:
				var inst_2 = ground.instance()
				inst_2.set_translation(Vector3(MFY*i, 0, MFY*j))
				add_child(inst_2)
	for i in range(2, 6):
		for j in range(2, 6):
			var inst_2 = water.instance()
			inst_2.set_translation(Vector3(MFY*i, 0, MFY*j))
			add_child(inst_2)
	var inst_3 = stone.instance()
	inst_3.set_translation(Vector3(-3, 2, -3))
	add_child(inst_3)
	inst_4 = worker.instance()
	inst_4_head = inst_4.get_node("Head")
	inst_4_body = inst_4.get_node("Body")
	inst_4.set_translation(box_map[BOX_SIZE * BOX_SIZE - BOX_SIZE - 2] + Vector3(0, 1, 0))
	add_child(inst_4)
	var inst_1 = tree.instance()
	inst_1.set_translation(Vector3(0, 0.25, 0))
	add_child(inst_1)
	inst_5 = wall.instance()
	inst_5.get_node("Body").set_mode(1)
	inst_5.set_translation(Vector3(-9, 2, -9))
	add_child(inst_5)
	inst_8 = RigidBody.new()
	inst_8.transform.origin = Vector3(0, 15, 5)
	self.add_child(inst_8)
	var coll = CollisionShape.new()
	coll.shape = BoxShape.new()
	inst_8.add_child(coll)
	inst_8_mesh = MeshInstance.new()
	inst_8_mesh.mesh = CubeMesh.new()
	var inst_8_spatial = SpatialMaterial.new()
	inst_8_spatial.albedo_color = Color(1, 0, 0)
	inst_8_mesh.set_surface_material(0, inst_8_spatial)
	inst_8.add_child(inst_8_mesh)
	inst_8.contact_monitor = true
	inst_8.contacts_reported = 1
	inst_8.connect("body_entered", self, "attack")
	old_n = n
	n = previous[n]
	
func attack(body):
	inst_8.remove_child(inst_8_mesh)
	var inst_8_mesh_2 = MeshInstance.new()
	inst_8_mesh_2.mesh = CubeMesh.new()
	var inst_8_spatial_2 = SpatialMaterial.new()
	inst_8_spatial_2.albedo_color = Color(0, 0, 0)
	inst_8_mesh_2.set_surface_material(0, inst_8_spatial_2)
	inst_8.add_child(inst_8_mesh_2)

var velocity_2 = Vector3(0, 0, 0)

func _input(event):
	if event is InputEventKey and event.scancode == KEY_Z:
		z = 1
	elif event is InputEventKey and event.scancode == KEY_X:
		z = -1
	if event is InputEventMouseMotion: 	
		r_y += -event.relative.x * mouse_sensitivity
		r_x += -event.relative.y * mouse_sensitivity
		if r_x > 1.5:
			r_x = 1.5
		elif r_x < -1.5:
			r_x = -1.5
		d.rotation.y = r_y
		d.rotation.x = r_x

func _process(delta):
	vw = -return_vector(c.global_transform.origin) + return_vector(d.global_transform.origin)
	if vector_mag(vw) < 1 and z==0:
		if mode_change == 1:
			remove_child(inst_5)
			var inst_6 = wall.instance()
			inst_6.set_translation(Vector3(-9, 2, -9))
			add_child(inst_6)
			mode_change = 0
		remove_child(c)
		d.add_child(c)
		c.global_transform.origin.x = f.global_transform.origin.x
		c.global_transform.origin.y = f.global_transform.origin.y
		c.global_transform.origin.z = f.global_transform.origin.z
		vw = Vector3(0, 0, 0)

var lock = 0

func _physics_process(delta):
	var tmp_3 = box_map[n] - Vector3(inst_4_head.global_transform.origin.x, 0, inst_4_head.global_transform.origin.z)
	wov = box_map[n] - box_map[old_n]
	if tmp_3.length() < 0.5 and lock == 0:
		old_n = n
		n = previous[n]
		if n == -1:
			lock = 1
	if lock != 0:
		wov = Vector3(0, 0, 0)
	inst_4_head.move_and_slide(wov)
	inst_4_body.move_and_slide(wov)
	if  Input.is_action_just_released("ui_up") or  Input.is_action_just_released("ui_down") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		velocity.x = 0
		velocity.y = 0
		velocity.z = 0
	elif Input.is_action_pressed("ui_up"):
		velocity.x = -sin(d.rotation.y) * SPEED
		velocity.y = 0
		velocity.z = -cos(d.rotation.y) * SPEED
	elif Input.is_action_pressed("ui_down"):
		velocity.x = sin(d.rotation.y) * SPEED
		velocity.y = 0
		velocity.z = cos(d.rotation.y) * SPEED
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -cos(d.rotation.y) * SPEED
		velocity.y = 0
		velocity.z = sin(d.rotation.y) * SPEED
	elif Input.is_action_pressed("ui_right"):
		velocity.x = cos(d.rotation.y) * SPEED
		velocity.y = 0
		velocity.z = -sin(d.rotation.y) * SPEED
	if z == 1:
		vw = return_vector(c.global_transform.origin) - return_vector(d.global_transform.origin)
		var xc = c.global_transform.origin.x
		var yc = c.global_transform.origin.y
		var zc = c.global_transform.origin.z
		d.remove_child(c)
		self.add_child(c)
		c.global_transform.origin.x = xc
		c.global_transform.origin.y = yc
		c.global_transform.origin.z = zc
	elif z == -1:
		vw = -return_vector(c.global_transform.origin) + return_vector(d.global_transform.origin)
		z = 0
	var collision = c.move_and_collide(vw * 2 * delta)
	c.move_and_slide(vw * 2)
	if collision:
		if str(collision.collider) == str(inst_5.get_node("Body")):
			mode_change = 1
	d.move_and_slide(velocity)

