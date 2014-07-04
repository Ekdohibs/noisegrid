-- noisegrid 0.3.8 by paramat
-- For latest stable Minetest and back to 0.4.8
-- Depends default
-- License: code WTFPL

-- vary tree height, lower apples
-- luxore craftable to lights
-- 2 tunnel network plus fissures

-- Parameters

local YFLAT = 7 -- Flat area elevation y
local YSAND = 4 -- Top of beach y
local TERSCA = 192 -- Vertical terrain scale in nodes
local STODEP = 5 -- Stone depth below surface in nodes at sea level
local TGRID = 0.18 -- City grid area width
local TFLAT = 0.2 -- Flat coastal area width
local TCITY = 0.3 -- City size. 0.3 = 1/3 of coastal land area, 0 = 1/2 of coastal land area

local TFIS = 0.02 -- Fissure width
local LUXCHA = 1 / 7 ^ 3 -- Luxore chance per stone node.
local APPCHA = 1 / 4 ^ 2 -- Appletree maximum chance per grass node. 1 / n ^ 2 where n = minimum average distance between flora
local FLOCHA = 1 / 13 ^ 2 -- Flowers maximum chance per grass node
local GRACHA = 1 / 5 ^ 2 -- Grasses maximum chance per grass node

-- 2D noise for base terrain

local np_base = {
	offset = 0,
	scale = 1,
	spread = {x=2048, y=2048, z=2048},
	seed = -9111,
	octaves = 6,
	persist = 0.6
}

-- 2D noise for intercity roads

local np_road = {
	offset = 0,
	scale = 1,
	spread = {x=2048, y=2048, z=2048},
	seed = -9111, -- same seed as above for similar structre but smoother
	octaves = 4,
	persist = 0.5
}

-- 2D noise for alt roads and tunnels

local np_alt = {
	offset = 0,
	scale = 1,
	spread = {x=1024, y=1024, z=1024},
	seed = 11,
	octaves = 3,
	persist = 0.4
}

-- 2D noise for city areas

local np_city = {
	offset = 0,
	scale = 1,
	spread = {x=1024, y=1024, z=1024},
	seed = 3166616,
	octaves = 2,
	persist = 0.5
}

-- 2D noise for paths

local np_path = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	seed = 7000023,
	octaves = 4,
	persist = 0.4
}

local np_path2 = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	seed = -2315551,
	octaves = 4,
	persist = 0.4
}

-- 2D noise for trees

local np_tree = {
	offset = 0,
	scale = 1,
	spread = {x=256, y=256, z=256},
	seed = 133338,
	octaves = 3,
	persist = 0.5
}

-- 2D noise for grasses

local np_grass = {
	offset = 0,
	scale = 1,
	spread = {x=256, y=256, z=256},
	seed = 133,
	octaves = 2,
	persist = 0.5
}

-- 2D noise for flowers

local np_flower = {
	offset = 0,
	scale = 1,
	spread = {x=256, y=256, z=256},
	seed = -70008,
	octaves = 1,
	persist = 0.5
}


-- 3D noise for fissures

local np_fissure = {
	offset = 0,
	scale = 1,
	spread = {x=192, y=192, z=192},
	seed = 2001,
	octaves = 4,
	persist = 0.5
}

-- 3D noise for web a

local np_weba = {
	offset = 0,
	scale = 1,
	spread = {x=192, y=192, z=192},
	seed = 5900033,
	octaves = 3,
	persist = 0.5
}

-- 3D noise for web b

local np_webb = {
	offset = 0,
	scale = 1,
	spread = {x=191, y=191, z=191},
	seed = 33,
	octaves = 3,
	persist = 0.5
}

-- 3D noise for web c

local np_webc = {
	offset = 0,
	scale = 1,
	spread = {x=190, y=190, z=190},
	seed = -18000001,
	octaves = 3,
	persist = 0.5
}

-- Stuff

noisegrid = {}

dofile(minetest.get_modpath("noisegrid").."/functions.lua")
dofile(minetest.get_modpath("noisegrid").."/nodes.lua")

-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.y > 208 then
		return
	end

	local t1 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	
	print ("[noisegrid] chunk minp ("..x0.." "..y0.." "..z0..")")
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	
	local c_air = minetest.get_content_id("air")
	local c_grass = minetest.get_content_id("noisegrid:grass")
	local c_dirt = minetest.get_content_id("noisegrid:dirt")
	local c_stone = minetest.get_content_id("noisegrid:stone")
	local c_roadblack = minetest.get_content_id("noisegrid:roadblack")
	local c_roadwhite = minetest.get_content_id("noisegrid:roadwhite")
	local c_slab = minetest.get_content_id("noisegrid:slab")
	local c_path = minetest.get_content_id("noisegrid:path")
	local c_concrete = minetest.get_content_id("noisegrid:concrete")
	local c_light = minetest.get_content_id("noisegrid:lightoff")
	local c_luxore = minetest.get_content_id("noisegrid:luxoff")
	
	local c_water = minetest.get_content_id("default:water_source")
	local c_sand = minetest.get_content_id("default:sand")
	local c_wood = minetest.get_content_id("default:wood")
	local c_stodiam = minetest.get_content_id("default:stone_with_diamond")
	local c_stomese = minetest.get_content_id("default:stone_with_mese")
	local c_stogold = minetest.get_content_id("default:stone_with_gold")
	local c_stocopp = minetest.get_content_id("default:stone_with_copper")
	local c_stoiron = minetest.get_content_id("default:stone_with_iron")
	local c_stocoal = minetest.get_content_id("default:stone_with_coal")
	
	local sidelen = x1 - x0 + 1
	local chulensxyz = {x=sidelen+1, y=sidelen, z=sidelen+1}
	local minposxyz = {x=x0-1, y=y0, z=z0-1}
	local chulensxz = {x=sidelen+1, y=sidelen+1, z=sidelen} -- different because here x=x, y=z
	local minposxz = {x=x0-1, y=z0-1}
	
	local nvals_base = minetest.get_perlin_map(np_base, chulensxz):get2dMap_flat(minposxz)
	local nvals_road = minetest.get_perlin_map(np_road, chulensxz):get2dMap_flat(minposxz)
	local nvals_alt = minetest.get_perlin_map(np_alt, chulensxz):get2dMap_flat(minposxz)
	local nvals_city = minetest.get_perlin_map(np_city, chulensxz):get2dMap_flat(minposxz)
	local nvals_path = minetest.get_perlin_map(np_path, chulensxz):get2dMap_flat(minposxz)
	local nvals_path2 = minetest.get_perlin_map(np_path2, chulensxz):get2dMap_flat(minposxz)
	local nvals_tree = minetest.get_perlin_map(np_tree, chulensxz):get2dMap_flat(minposxz)
	local nvals_grass = minetest.get_perlin_map(np_grass, chulensxz):get2dMap_flat(minposxz)
	local nvals_flower = minetest.get_perlin_map(np_flower, chulensxz):get2dMap_flat(minposxz)
	
	local nvals_fissure = minetest.get_perlin_map(np_fissure, chulensxyz):get3dMap_flat(minposxyz)
	local nvals_weba = minetest.get_perlin_map(np_weba, chulensxyz):get3dMap_flat(minposxyz)
	local nvals_webb = minetest.get_perlin_map(np_webb, chulensxyz):get3dMap_flat(minposxyz)
	local nvals_webc = minetest.get_perlin_map(np_webc, chulensxyz):get3dMap_flat(minposxyz)
	
	local cross = math.abs(nvals_base[3281]) < TGRID and nvals_city[3281] > TCITY -- grid elements enabled per chunk
	local nroad = math.abs(nvals_base[6521]) < TGRID and nvals_city[6521] > TCITY
	local eroad = math.abs(nvals_base[3321]) < TGRID and nvals_city[3321] > TCITY
	local sroad = math.abs(nvals_base[122]) < TGRID and nvals_city[122] > TCITY
	local wroad = math.abs(nvals_base[3242]) < TGRID and nvals_city[3242] > TCITY
	
	local nixz = 1
	local nixyz = 1
	local stable = {}
	for z = z0-1, z1 do
		for x = x0-1, x1 do
			local si = x - x0 + 2 -- +2 because overgeneration
			stable[si] = 2
		end
		for y = y0, y1 do
			local vi = area:index(x0-1, y, z)
			local via = area:index(x0-1, y+1, z)
			local n_xprepath = false
			local n_xprepath2 = false
			local n_xpreroad = false
			local n_xprealt = false
			for x = x0-1, x1 do
				local nodid = data[vi]
				local xr = x - x0
				local zr = z - z0
				local si = xr + 2
				local chunk = (x >= x0 and z >= z0)
				
				local sea = false
				local flat = false
				local ysurf
				local n_base = nvals_base[nixz]
				local n_absbase = math.abs(n_base)
				if n_base > TFLAT then
					ysurf = YFLAT + math.floor((n_base - TFLAT) * TERSCA)
				elseif n_base < -TFLAT then
					ysurf = YFLAT - math.floor((-TFLAT - n_base) * TERSCA)
					sea = true
				else
					ysurf = YFLAT
					flat = true
				end
				
				local weba = math.abs(nvals_weba[nixyz]) < TFIS
				local webb = math.abs(nvals_webb[nixyz]) < TFIS
				local webc = math.abs(nvals_webc[nixyz]) < TFIS

				local n_fissure = nvals_fissure[nixyz]
				local n_absfissure = math.abs(n_fissure)
				local nofis = n_absfissure > TFIS and not (weba and webb) and not (weba and webc)
				local wood = n_absfissure < TFIS * 2 and not flat
				
				local n_city = nvals_city[nixz]
				local city = n_city > TCITY
				
				local n_tree = math.min(math.max(nvals_tree[nixz], 0), 1)
				local n_grass = math.min(math.max(nvals_grass[nixz], 0), 1)
				local n_flower = math.min(math.max(nvals_flower[nixz], 0), 1)
				
				local n_path = nvals_path[nixz]
				local n_abspath = math.abs(n_path)
				local n_zprepath = nvals_path[(nixz - 81)]
				
				local n_path2 = nvals_path2[nixz]
				local n_abspath2 = math.abs(n_path2)
				local n_zprepath2 = nvals_path2[(nixz - 81)]
				
				local n_road = nvals_road[nixz]
				local n_absroad = math.abs(n_road)
				local n_zpreroad = nvals_road[(nixz - 81)]
				
				local n_alt = nvals_alt[nixz]
				local n_absalt = math.abs(n_alt)
				local n_zprealt = nvals_alt[(nixz - 81)]
				
				local stodep = math.max(STODEP * (TERSCA - y) / TERSCA, 1)
				
				if chunk then
					if y == YFLAT and n_base > -TGRID -- tunnel road
					and (((n_alt >= 0 and n_xprealt < 0)
					or (n_alt < 0 and n_xprealt >= 0))
					or ((n_alt >= 0 and n_zprealt < 0)
					or (n_alt < 0 and n_zprealt >= 0))) then
						data[vi] = c_roadwhite
						for i = -3, 3 do
						for k = -3, 3 do
							if (math.abs(i)) ^ 2 + (math.abs(k)) ^ 2 <= 13 then
								local vi = area:index(x+i, y, z+k)
								local via = area:index(x+i, y+1, z+k)
								local nodid = data[vi]
								if nodid ~= c_roadwhite then
									data[vi] = c_roadblack
								end
								data[via] = c_air -- air above to remove pavements
							end
						end
						end
					elseif y <= ysurf and y >= YFLAT + 1 and y <= YFLAT + 4 and n_absalt < 0.025 then -- tunnel air
						data[vi] = c_air
						stable[si] = 0
					elseif y <= ysurf - 1 and y == YFLAT + 5 and n_absalt > 0.003 and n_absalt < 0.007 then -- tunnel lights
						data[vi] = c_light
						stable[si] = stable[si] + 1
					elseif y <= ysurf and y >= YFLAT and y <= YFLAT + 6 -- tunnel concrete
					and n_absalt < 0.035 and n_base > TFLAT and nodid ~= c_roadblack then
						data[vi] = c_concrete
						stable[si] = stable[si] + 1
					elseif y <= ysurf - stodep and nodid ~= c_roadblack
					and (nofis or ((flat or sea) and y >= ysurf - 16)) then
						if math.random() < LUXCHA and stable[si] >= 1 and y > y0 then -- only stable luxore to avoid droop
							data[vi] = c_luxore
						else
							data[vi] = c_stone -- stone
						end
						stable[si] = stable[si] + 1
					elseif y == ysurf and y > YSAND then -- surface layer
						if ((n_road >= 0 and n_xpreroad < 0) or (n_road < 0 and n_xpreroad >= 0)) -- intercity road
						or ((n_road >= 0 and n_zpreroad < 0) or (n_road < 0 and n_zpreroad >= 0)) then
							data[vi] = c_roadwhite
							for i = -3, 3 do
							for k = -3, 3 do
								if (math.abs(i)) ^ 2 + (math.abs(k)) ^ 2 <= 13 then
									local vi = area:index(x+i, y, z+k)
									local via = area:index(x+i, y+1, z+k)
									local nodid = data[vi]
									if nodid ~= c_roadwhite then
										data[vi] = c_roadblack
									end
									data[via] = c_air
								end
							end
							end
						elseif xr >= 36 and xr <= 42 and zr >= 36 and zr <= 42 -- city grid
						and (nroad or eroad or sroad or wroad) and cross and nodid ~= c_roadblack then -- junction
							if xr == 39 and zr == 39 then
								data[vi] = c_roadwhite
							else
								data[vi] = c_roadblack
							end
						elseif xr >= 33 and xr <= 45 and zr >= 43 -- north road
						and nroad and cross and nodid ~= c_roadblack then
							if xr == 39 then
								data[vi] = c_roadwhite
							elseif xr >= 36 and xr <= 42 then
								data[vi] = c_roadblack
							else
								data[vi] = c_dirt
								data[via] = c_slab
							end
						elseif xr >= 43 and zr >= 33 and zr <= 45 -- east road
						and eroad and cross and nodid ~= c_roadblack then
							if zr == 39 then
								data[vi] = c_roadwhite
							elseif zr >= 36 and zr <= 42 then
								data[vi] = c_roadblack
							else
								data[vi] = c_dirt
								data[via] = c_slab
							end
						elseif xr >= 33 and xr <= 45 and zr <= 35 -- south road
						and sroad and cross and nodid ~= c_roadblack then
							if xr == 39 then
								data[vi] = c_roadwhite
							elseif xr >= 36 and xr <= 42 then
								data[vi] = c_roadblack
							else
								data[vi] = c_dirt
								data[via] = c_slab
							end
						elseif xr <= 35 and zr >= 33 and zr <= 45 -- west road
						and wroad and cross and nodid ~= c_roadblack then
							if zr == 39 then
								data[vi] = c_roadwhite
							elseif zr >= 36 and zr <= 42 then
								data[vi] = c_roadblack
							else
								data[vi] = c_dirt
								data[via] = c_slab
							end
						elseif xr >= 33 and xr <= 45 and zr >= 33 and zr <= 45 -- pavement in junction gaps
						and (nroad or eroad or sroad or wroad) and cross and nodid ~= c_roadblack then
							data[vi] = c_dirt
							data[via] = c_slab
						elseif (n_absroad < 0.01 or n_absalt < 0.02) and flat and city and nodid ~= c_roadblack then
							data[vi] = c_dirt -- pavement of intercity road and tunnel road in city
							data[via] = c_slab
						elseif ((n_path >= 0 and n_xprepath < 0) or (n_path < 0 and n_xprepath >= 0)) -- path
						or ((n_path >= 0 and n_zprepath < 0) or (n_path < 0 and n_zprepath >= 0)) then
							if wood then
								local viu = area:index(x, y-1, z)
								local viuu = area:index(x, y-2, z)
								data[viu] = c_wood
								data[viuu] = c_wood
							end
							for i = -1, 1 do
							for k = -1, 1 do
								local vi = area:index(x+i, y, z+k)
								local nodid = data[vi]
								if nodid ~= c_roadwhite and nodid ~= c_roadblack then
									if wood then
										data[vi] = c_wood
									else
										data[vi] = c_path
									end
								end
							end
							end
						elseif ((n_path2 >= 0 and n_xprepath2 < 0) or (n_path2 < 0 and n_xprepath2 >= 0)) -- path 2
						or ((n_path2 >= 0 and n_zprepath2 < 0) or (n_path2 < 0 and n_zprepath2 >= 0)) then
							if wood then
								local viu = area:index(x, y-1, z)
								local viuu = area:index(x, y-2, z)
								data[viu] = c_wood
								data[viuu] = c_wood
							end
							for i = -1, 1 do
							for k = -1, 1 do
								local vi = area:index(x+i, y, z+k)
								local nodid = data[vi]
								if nodid ~= c_roadwhite and nodid ~= c_roadblack then
									if wood then
										data[vi] = c_wood
									else
										data[vi] = c_path
									end
								end
							end
							end
						elseif stable[si] >= 2 and nodid ~= c_roadblack and nodid ~= c_path then -- stable dirt with grass
							if math.random() < APPCHA * n_tree -- appletree
							and n_abspath > 0.015 and n_abspath2 > 0.015 and n_absroad > 0.02
							and (n_absalt > 0.04 or y > YFLAT) then
								noisegrid_appletree(x, y+1, z, area, data)
							else
								data[vi] = c_grass
								if math.random() < FLOCHA * n_flower and n_absroad > 0.015
								and n_absalt > 0.03 then -- flowers
									noisegrid_flower(data, via)
								elseif math.random() < GRACHA * n_grass and n_absroad > 0.015
								and n_absalt > 0.03 then -- grasses
									noisegrid_grass(data, via)
								end
							end
						end
					elseif y <= ysurf and y >= ysurf - 16 and y <= YSAND and sea and stable[si] >= 2 then -- stable sand
						data[vi] = c_sand
					elseif y < ysurf and y > ysurf - stodep and (nofis or flat) and stable[si] >= 2
					and nodid ~= c_roadblack then -- stable dirt
						data[vi] = c_dirt
					elseif y <= 1 and y > ysurf then -- water
						data[vi] = c_water
						stable[si] = 0
					else -- air
						stable[si] = 0
					end
				end
				n_xprepath = n_path
				n_xprepath2 = n_path2
				n_xpreroad = n_road
				n_xprealt = n_alt
				nixz = nixz + 1
				nixyz = nixyz + 1
				vi = vi + 1
				via = via + 1
			end
			nixz = nixz - 81
		end
		nixz = nixz + 81
	end
	
	for _, oredef in ipairs(minetest.registered_ores) do
		if oredef.wherein == "default:stone" then
			oredef.wherein = "noisegrid:stone"
		end
		
		local maxy = math.min(maxp.y, oredef.height_max or 31000)
		local miny = math.max(minp.y, oredef.height_min or -31000)
		local mmaxp = {x = maxp.x, y = maxy, z = maxp.z}
		local mminp = {x = minp.x, y = miny, z = minp.z}
		if maxy - miny >= oredef.clust_size then
			if oredef.ore_type == "scatter" then
				generate_ore_scatter(mminp, mmaxp, area, data, oredef)
			elseif oredef.ore_type == "sheet" then
				generate_ore_sheet(mminp, mmaxp, area, data, oredef)
			end
		end
	end
	
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
	local chugent = math.ceil((os.clock() - t1) * 1000)
	print ("[noisegrid] "..chugent.." ms")
end)

function generate_ore_scatter(minp, maxp, area, data, oredef)
	local volume = (maxp.x - minp.x + 1) * (maxp.y - minp.y + 1) * (maxp.z - minp.z + 1)
	local csize = oredef.clust_size
	local orechance = math.floor((csize ^ 3) / oredef.clust_num_ores)
	local nclusters = math.floor(volume / oredef.clust_scarcity)
	local ore = minetest.get_content_id(oredef.ore)
	local wherein = minetest.get_content_id(oredef.wherein)

	for i = 1, nclusters do
		local x0 = math.random(minp.x, maxp.x - csize + 1)
		local y0 = math.random(minp.y, maxp.y - csize + 1)
		local z0 = math.random(minp.z, maxp.z - csize + 1)

		for x1 = x0, x0 + csize - 1 do
		for y1 = y0, y0 + csize - 1 do
		for z1 = z0, z0 + csize - 1 do
			if math.random(orechance) == 1 then
				local i = area:index(x1, y1, z1)
				if data[i] == wherein then
					data[i] = ore
				end
			end
		end
		end
		end
	end
end

function generate_ore_sheet(minp, maxp, area, data, oredef)
	local csize = oredef.clust_size
	local np = oredef.noise_params
	local scale = np.scale
	local nthresh = oredef.noise_threshhold * scale
	local y_start = math.random(minp.y, maxp.y - csize)
	local ore = minetest.get_content_id(oredef.ore)
	local wherein = minetest.get_content_id(oredef.wherein)

	local noise = minetest.get_perlin_map(np,
				{x = maxp.x - minp.x + 1,
				 y = maxp.z - minp.z + 1,
				z = maxp.z - minp.z + 1}
		):get2dMap_flat({x = minp.x, y = minp.z})

	local index = 1
	for z = minp.z, maxp.z do
	for x = minp.x, maxp.x do
		local noiseval = noise[index]
		index = index + 1
		if noiseval >= nthresh then
			local height = math.floor(csize / math.random(3))
			local y0 = y_start + math.floor(noiseval)
			for y = y0, y0 + height - 1 do
				local i = area:index(x, y, z);
				if data[i] == wherein then
					data[i] = ore
				end
			end
		end
	end
	end
end