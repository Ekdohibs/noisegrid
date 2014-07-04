--[[minetest.register_node("noisegrid:grass", {
	description = "Grass",
	tiles = {"default_grass.png", "default_dirt.png", "default_grass.png"},
	is_ground_content = false,
	groups = {crumbly=3,soil=1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.25},
	}),
})]]
minetest.register_alias("noisegrid:grass", "default:dirt_with_grass")

minetest.register_node("noisegrid:dirt", {
	description = "Dirt",
	tiles = {"default_dirt.png"},
	is_ground_content = false,
	groups = {crumbly=3,soil=1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("noisegrid:path", {
	description = "Dirt Path",
	tiles = {"noisegrid_path.png"},
	is_ground_content = false,
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("noisegrid:stone", {
	description = "Stone",
	tiles = {"default_stone.png"},
	is_ground_content = false,
	groups = {cracky=3},
	drop = "default:cobble",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("noisegrid:roadblack", {
	description = "Road Black",
	tiles = {"noisegrid_roadblack.png"},
	is_ground_content = false,
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("noisegrid:roadwhite", {
	description = "Road White",
	tiles = {"noisegrid_roadwhite.png"},
	is_ground_content = false,
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("noisegrid:slab", {
	description = "Paving Slab",
	tiles = {"noisegrid_concrete.png", "noisegrid_concrete.png", "noisegrid_slabside.png"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	buildable_to = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("noisegrid:appleleaf", {
	description = "Appletree Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_leaves.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3, flammable=2},
	drop = {
		max_items = 1,
		items = {
			{items = {"noisegrid:appling"},rarity = 20},
			{items = {"noisegrid:appleleaf"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("noisegrid:appling", {
	description = "Appletree Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_sapling.png"},
	inventory_image = "default_sapling.png",
	wield_image = "default_sapling.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("noisegrid:lightoff", {
	description = "Light",
	tiles = {"noisegrid_light.png"},
	light_source = 14,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("noisegrid:lighton", {
	description = "Light",
	tiles = {"noisegrid_light.png"},
	light_source = 14,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("noisegrid:concrete", {
	description = "Sandy Concrete",
	tiles = {"noisegrid_concrete.png"},
	is_ground_content = false,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("noisegrid:luxoff", {
	description = "Dark Lux Ore",
	tiles = {"noisegrid_luxore.png"},
	light_source = 14,
	groups = {immortal=1},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("noisegrid:luxore", {
	description = "Lux Ore",
	tiles = {"noisegrid_luxore.png"},
	light_source = 14,
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults(),
})

-- Crafting.

minetest.register_craft({
    output = "noisegrid:lighton 8",
    recipe = {
        {"default:glass", "default:glass", "default:glass"},
        {"default:glass", "noisegrid:luxore", "default:glass"},
        {"default:glass", "default:glass", "default:glass"},
    },
})
