local teleport_delay = 10
local teleporting_players = {}

local function create_teleport_form()
    local formspec = "size[7.5,3]" ..
                     "label[0,0;Select teleportation delay]" ..
                     "background[0,0;7.5,0.6;HL_bg.png]"
    for i = 1, 6 do
        local x = (i - 1) % 3 * 2.5
        local y = math.floor((i - 1) / 3) * 1.1 + 1

        formspec = formspec ..
                   "image_button_exit[" .. x .. "," .. y .. ";2.5,1;HL_bg.png;delay_" .. tostring(i * 10) .. "s;" .. tostring(i * 10) .. " seconds]"
    end

    return formspec
end

minetest.register_craftitem("hl_marker:marker", {
    description = "Teleport Marker",
    inventory_image = "hl_marker.png",

    on_use = function(itemstack, player, pointed_thing)
        local player_name = player:get_player_name()

        if teleporting_players[player_name] then
            minetest.chat_send_player(player_name, "You are still in the teleportation process!")
            return itemstack
        end

        local formspec = create_teleport_form()
        minetest.show_formspec(player_name, "hl_marker:teleport_form", formspec)
        return itemstack
    end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local player_name = player:get_player_name()

    if formname == "hl_marker:teleport_form" then
        for field, _ in pairs(fields) do
            if field:sub(1, 6) == "delay_" then
                local selected_delay = tonumber(field:sub(7, -2))
                if selected_delay then
                    teleport_delay = selected_delay
                    local player_pos = player:get_pos()
                    minetest.chat_send_player(player_name, "Position marked, delay time: " .. teleport_delay .. " seconds!")
                    teleporting_players[player_name] = true

                    local player_inventory = player:get_inventory()
                    local player_item = ItemStack("hl_marker:marker")
                    player_inventory:remove_item("main", player_item)

                    minetest.after(teleport_delay, function()
                        local player_object = minetest.get_player_by_name(player_name)
                        if player_object then
                            player_object:set_pos(player_pos)
                            minetest.chat_send_player(player_name, "Teleported to the marked position!")
                        end

                        teleporting_players[player_name] = nil
                    end)
                end
            end
        end
    end
end)