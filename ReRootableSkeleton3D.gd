@tool
class_name ReRootableSkeleton3D
extends Skeleton3D
@export var hips_bone : String = "Hips"
@export_tool_button("Add Root") var _add_root = add_root
@export_tool_button("Remove Root") var _remove_root = remove_root
func add_root():
	var id = add_bone("Root")
	if id < 0:
		print_debug("FAIL")
		return
	set_bone_pose_position(id, Vector3.ZERO)
	var hid = find_bone(hips_bone)
	set_bone_enabled(id)
	if hid < 0:
		print_debug("FAIL")
		return
	set_bone_parent(hid, id)
	
func remove_root():
	var old_bones = []
	for i in get_bone_count():
		if get_bone_name(i) != "Root":
			old_bones.append(
				{
					"name": get_bone_name(i),
					"parent": get_bone_parent(i), 
					"global_pose": get_bone_global_pose(i), 
					"pose": get_bone_pose(i), 
					"enabled": is_bone_enabled(i), 
					"rest" : get_bone_rest(i),
					"id": i
				}
			)
	clear_bones()
	for data in old_bones:
		var id = add_bone(data["name"])
		set_bone_pose(id, data["pose"])
		set_bone_rest(id, data["rest"])
		set_bone_global_pose(id, data["pose"])
		set_bone_enabled(id, data["enabled"])
	for i in get_bone_count():
		set_bone_parent(i, old_bones[i]["parent"])
	for c in get_children():
		if c is MeshInstance3D:
			c.mesh = c.bake_mesh_from_current_skeleton_pose(c.mesh)
			if c.mesh != null:
				print_debug("Successful mesh rerouting on: ", c.name)
