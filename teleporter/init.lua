---
--Teleporter 1.06
--Copyright (C) 2012 Bad_Command
--
--This library is free software; you can redistribute it and/or
--modify it under the terms of the GNU Lesser General Public
--License as published by the Free Software Foundation; either
--version 2.1 of the License, or (at your option) any later version.
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

-- Teleporter mod configuration options
teleport_perms_to_build = false
teleport_perms_to_configure = false
teleport_requires_pairing = true
teleport_default_coordinates = {x=0, y=0, z=0, desc="Spawn"}
teleport_pairing_check_radius = 2
teleport_tile_image = "teleporter_teleporter_pad_16.png"
-- Higer resolution pads:
--teleport_tile_image = "teleporter_teleporter_pad.png"

minetest.register_craft({
	output = 'teleporter:teleporter_pad',
	recipe = {
                {'moreores:copper_ingot', 'default:glass', 'moreores:copper_ingot'},
                {'moreores:copper_ingot', 'moreores:gold_block', 'moreores:copper_ingot'},
                {'moreores:copper_ingot', 'mesecons_powerplant:power_plant', 'moreores:copper_ingot'},
        }
})

minetest.register_craft({
	output = 'teleporter:teleporter_pad',
	recipe = {
                {'default:wood', 'default:glass', 'default:wood'},
                {'default:wood', 'default:mese', 'default:wood'},
                {'default:wood', 'default:wood', 'default:wood'},
        }
})

minetest.register_node("teleporter:teleporter_pad", {
	tile_images = {teleport_tile_image},
	drawtype = "signlike",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	description="Teleporter Pad",
	inventory_image = teleport_tile_image,
	metadata_name = "sign",
	--sounds = default.node_sound_defaults(),
	groups = {choppy=2,dig_immediate=2},
	selection_box = {
		type = "wallmounted",
	},
        on_construct = function(pos)
                local meta = minetest.env:get_meta(pos)
                meta:set_string("formspec", "hack:sign_text_input")
                meta:set_string("infotext", "\"Teleport to "..teleport_default_coordinates.desc.."\"")
		meta:set_string("text", teleport_default_coordinates.x..","..teleport_default_coordinates.y..","..teleport_default_coordinates.z..","..teleport_default_coordinates.desc)
		meta:set_float("enabled", -1)
		meta:set_float("x", teleport_default_coordinates.x)
		meta:set_float("y", teleport_default_coordinates.y)
		meta:set_float("z", teleport_default_coordinates.z)
        end,
	after_place_node = function(pos, placer)
		local meta = minetest.env:get_meta(pos)
		local name = placer:get_player_name()
		meta:set_string("owner", name)
		
		if teleport_perms_to_build and not minetest.get_player_privs(name)["teleport"] then
			minetest.chat_send_player(name, 'Teleporter:  Teleport privileges are required to build teleporters.')
			minetest.env:remove_node(pos)
			minetest.env:add_item(pos, 'teleporter:teleporter_pad')
		else
			meta:set_float("enabled", 1)
		end

	end,
        on_receive_fields = function(pos, formname, fields, sender)
		local coords = teleporter_coordinates(fields.text)
                local meta = minetest.env:get_meta(pos)
		local name = sender:get_player_name()
		local privs = minetest.get_player_privs(name)

		if name ~= meta:get_string("owner") and not privs["server"] then
			minetest.chat_send_player(name, 'Teleporter:  This is not your teleporter, it belongs to '..meta:get_string("owner"))
			return false
		else if privs["server"] then
			minetest.chat_send_player(name, 'Teleporter:  This teleporter belongs to '..meta:get_string("owner"))
		end

		if teleport_perms_to_configure and not privs["teleport"] then
			minetest.chat_send_player(name, 'Teleporter:  You need teleport privileges to configure a teleporter')
			return
		end

		local infotext = ""
		if coords~=nil then	
			meta:set_float("x", coords.x)
			meta:set_float("y", coords.y)
			meta:set_float("z", coords.z)
			if teleport_requires_pairing and not is_teleport_paired(coords) and not privs["server"] then
				minetest.chat_send_player(name, 'Teleporter:  There is no recently-used teleporter pad at the destination!')
		                meta:set_string("text", fields.text)
				infotext="Teleporter is Disabled"
				meta:set_float("enabled", -1)
			else
				meta:set_float("enabled", 1)
				if coords.desc~=nil then
					infotext="Teleport to "..coords.desc
				else
					infotext="Teleport to "..coords.x..","..coords.y..","..coords.z..""
				end
			end
		else
			minetest.chat_send_player(name, 'Teleporter:  Incorrect coordinates.  Enter them as \'X,Y,Z,Description\'')
			meta:set_float("enabled", -1)
			infotext="Teleporter Offline"
		end

                print((sender:get_player_name() or "").." entered \""..fields.text..
                                "\" to teleporter at "..minetest.pos_to_string(pos))
                meta:set_string("text", fields.text)
                meta:set_string("infotext", '"'..infotext..'"')
        	end
	end,
	can_dig = function(pos,player)
		local meta = minetest.env:get_meta(pos)
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		if name == meta:get_string("owner") or privs["server"] then
			return true
		end
		return false
	end
})

function is_teleport_paired(coords) 
	for dx=-teleport_pairing_check_radius,teleport_pairing_check_radius do
		for dy=-teleport_pairing_check_radius,teleport_pairing_check_radius do
			for dz=-teleport_pairing_check_radius,teleport_pairing_check_radius do
				local node = minetest.env:get_node({x=coords.x + dx, y=coords.y + dy, z=coords.z + dz})
				if node.name == 'teleporter:teleporter_pad' then
					return true
				end
			end
		end
	end
	return false
end

function teleporter_coordinates(str) 
	local x,y,z,desc = string.match(str, "^(-?%d+),(-?%d+),(-?%d+),?(.*)$")
	
	if desc=="" then
		desc = nil
	end

	if x==nil or y==nil or z==nil or 
		string.len(x) > 6 or string.len(y) > 6 or string.len(z) > 6 then
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

