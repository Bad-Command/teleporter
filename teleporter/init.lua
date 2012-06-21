----
--Teleporter 1.0
--Copyright (C) 2012 Corey Edmunds (corey.edmunds@gmail.com)
--
--This program is free software; you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation; either version 2 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License along
--with this program; if not, write to the Free Software Foundation, Inc.,
--51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
----

minetest.register_craft({
	output = 'teleporter:teleporter_pad',
	recipe = {
                {'moreores:copper_ingot', 'default:glass', 'moreores:copper_ingot'},
                {'moreores:copper_ingot', 'moreores:gold_block', 'moreores:copper_ingot'},
                {'moreores:copper_ingot', 'mesecons_powerplant:power_plant', 'moreores:copper_ingot'},
        }
})


minetest.register_node("teleporter:teleporter_pad", {
	--tile_images = {"teleporter_teleporter_pad.png","default_steel_block.png", "default_steel_block.png", "default_steel_block.png","default_steel_block.png","default_steel_block.png"},
	tile_images = {"teleporter_teleporter_pad.png"},
	drawtype = "signlike",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	description="Teleporter Pad",
	metadata_name = "sign",
	sounds = default.node_sound_defaults(),
	groups = {choppy=2,dig_immediate=2},
	selection_box = {
		type = "wallmounted",
		--wall_top = <default>
		--wall_bottom = <default>
		--wall_side = <default>
	},
        on_construct = function(pos)
                --local n = minetest.env:get_node(pos)
                local meta = minetest.env:get_meta(pos)
                meta:set_string("formspec", "hack:sign_text_input")
                meta:set_string("infotext", "\"Teleport to Spawn\"")
		meta:set_string("text", "0,0,0,Spawn")
		meta:set_float("enabled", 1)
		meta:set_float("x", 0)
		meta:set_float("y", 0)
		meta:set_float("z", 0)
        end,
	after_place_node = function(pos, placer)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("owner", placer:get_player_name())
	end,
        on_receive_fields = function(pos, formname, fields, sender)
                --print("Sign at "..minetest.pos_to_string(pos).." got "..dump(fields))
		local coords = teleporter_coordinates(fields.text)
                local meta = minetest.env:get_meta(pos)

		if not has_teleporter_privilege(meta,sender) then
			return
		end

		local infotext = ""
		if coords~=nil then
			meta:set_float("x", coords.x)
			meta:set_float("y", coords.y)
			meta:set_float("z", coords.z)
			meta:set_float("enabled", 1)
			if coords.desc~=nil then
				infotext="Teleport to "..coords.desc
			else
				infotext="Teleport to "..coords.x..","..coords.y..","..coords.z..""
			end
		else
			meta:set_float("enabled", -1)
			infotext="Teleporter Offline"
		end

                print((sender:get_player_name() or "").." wrote \""..fields.text..
                                "\" to sign at "..minetest.pos_to_string(pos))
                meta:set_string("text", fields.text)
                meta:set_string("infotext", '"'..infotext..'"')
        end,
	can_dig = function(pos,player)
		local meta = minetest.env:get_meta(pos)
		if player:get_player_name() == meta:get_string("owner") or privs["server"] then
			return true
		end
		return false
	end
})

function has_teleporter_privilege(meta, player) 
	local privs = minetest.get_player_privs(player:get_player_name())

	if player:get_player_name() ~= meta:get_string("owner") and not privs["server"] then
		return false
	end
	return privs["teleport"]
end

function teleporter_coordinates(str) 
	local x,y,z,desc = string.match(str, "(-?%d*),(-?%d*),(-?%d*),?(.*)")
	
	if desc=="" then
		desc = nil
	end

	if x==nil or y==nil or z==nil then
		return nil
	end
	x = x + 0.0
	y = y + 0.0
	z = z + 0.0

	if x > 32765 or x < -32765 or y > 32765 or y < -32765 or z > 32765 or z < -32765 then
		return nil
	end

	return {x=x, y=y, z=z, desc=desc}
end


minetest.register_abm(
	{nodenames = {"teleporter:teleporter_pad"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		for k, player in pairs(objs) do
			if player:get_player_name()~=nil then 
				local meta = minetest.env:get_meta(pos)
				if meta:get_float("enabled") > 0 then
					local target_coords={x=meta:get_float("x"), y=meta:get_float("y"), z=meta:get_float("z")}
					minetest.sound_play("teleporter_teleport", {pos = pos, gain = 1.0, max_hear_distance = 10,})
					player:moveto(target_coords, false)
					minetest.sound_play("teleporter_teleport", {pos = target_coords, gain = 1.0, max_hear_distance = 10,})
				end
			end
		end
	end	
})

