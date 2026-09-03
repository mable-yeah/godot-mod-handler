extends Control

#within the mod folder
#shared/testing is testing/
const path = "res://shared/testing/test_image.png"
#though other directories work too they wont automatically change
#to a shorter directory


func _ready() -> void:
	#also gets called on the first verify_asset incase it wasnt initialized
	AssetManager.init_mod_list()
	%list.active_tab_rearranged.connect(on_tab_re_order)
	
	for mod in AssetManager.mod_list: %list.add_tab(mod.id)
	re_init()
	print(AssetManager.get_files_at('res://',AssetManager.open_type.FILES_PATH))


func on_tab_re_order(_i) -> void:
	var mods_by_id:Dictionary[String,mod_loader.mod_package]
	for mod in AssetManager.mod_list: mods_by_id[mod.id] = mod
	var reordered_mods:Array[mod_loader.mod_package] = []
	var last_mod:mod_loader.mod_package
	for i in %list.tab_count:
		var mod_id:String = %list.get_tab_title(i)
		if !mods_by_id.has(mod_id): continue
		last_mod = mods_by_id[mod_id] ; reordered_mods.append(last_mod)
	AssetManager.mod_list = reordered_mods
	re_init()

func re_init():
	get_highest_mod_info()
	
	#when loading any asset instead of using load() or ResourceLoader.load()
	#use a pattern similar to this
	var container = AssetManager.verify_asset(path,false)
	if container.asset == null || !(container.asset is Texture): return
	%texrect.texture = container.asset

func get_highest_mod_info():
	var highest_mod = AssetManager.mod_list.back()
	%name.text = 'name: %s' % highest_mod.name
	%id.text = 'id: %s' % highest_mod.id
	%desc.text = 'description: %s' % highest_mod.description
