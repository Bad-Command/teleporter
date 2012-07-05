---
--Teleporter Configuration
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
--You should have received a copy of the GNU Lesser General Public
--License along with this library; if not, write to the Free Software
--Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
---

-- When true, a player has to have the teleport permission to build a 
-- teleporter. When false, anyone can build a new teleporter:
teleporter.perms_to_build = false

-- When true, a player has to have the teleport permission to configure 
-- a teleporter. Players can still build teleporters without this, however
-- the teleporter will be locked to the default location:
teleporter.perms_to_configure = false

-- When true, a teleporter can only be configured to teleport to a location 
-- near an existing teleporter. This prevents players from pointing teleporters
-- in to unexplored terrain. 
teleporter.requires_pairing = true

-- The size of the volume to scan when looking for a paired teleporter. Do not 
-- set this to a large value; the number of nodes scanned increases by a power 
-- of 3.
teleporter.pairing_check_radius = 2

-- Default coordinates for new a teleporter. This is useful when players can 
-- build new teleporters, but can't configure them. 
teleporter.default_coordinates = {x=0, y=0, z=0, desc="Spawn"}

-- Lower resolution pads:
--teleporter.tile_image = "teleporter_teleporter_pad_16.png"

-- Higher resolution pads:
teleporter.tile_image = "teleporter_teleporter_pad.png"

