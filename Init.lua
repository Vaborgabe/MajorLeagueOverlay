if not MO then MO = {} end

MO = {
    serverUrl = "https://webhook.site/e8db9459-7416-46b0-add8-39b2c122e8f2"
}

MO.UTILS = {
    send_json = nil,
    send_json_event = nil,
    print_table_shallow = nil,
    get_vouchers = nil
}

-- Sends a Lua table as JSON to the given URL
function MO.UTILS.send_json(url, data_table)
    local json = require("json")
    local json_data = json.encode(data_table)
    local threadCode = [[
    local url, json_data = ...
        local http = require("socket.http")
        local ltn12 = require("ltn12")
        local response_body = {}

        local res, status_code, response_headers = http.request{
            url = url,
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json",
                ["Content-Length"] = tostring(#json_data)
            },
            source = ltn12.source.string(json_data),
            sink = ltn12.sink.table(response_body)
        }
    ]]
    
    local thread = love.thread.newThread(threadCode)
    thread:start(url, json_data)
    return
    -- return {
    --     success = res ~= nil,
    --     status = status_code,
    --     response = table.concat(response_body),
    --     headers = response_headers
    -- }
end

function MO.UTILS.send_json_event(url, data_table)
    G.E_MANAGER:add_event(Event{
        func = function()
            MO.UTILS.send_json(url, data_table)
            return true
        end,
        blocking = false,
        trigger = "immediate"
    })
end

function MO.UTILS.print_table_shallow(tbl, name)
    name = name or "Table"
    sendDebugMessage(name .. " = {")
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            local sub_items = {}
            for sub_k, sub_v in pairs(v) do
                table.insert(sub_items, tostring(sub_k) .. " = " .. tostring(sub_v))
            end
            sendDebugMessage("  " .. tostring(k) .. " = {" .. table.concat(sub_items, ", ") .. "}")
        else
            sendDebugMessage("  " .. tostring(k) .. " = " .. tostring(v))
        end
    end
    sendDebugMessage("}")
end

function MO.UTILS.get_vouchers()
    local voucher_keys = ""
        if G.GAME.used_vouchers then
            local keys = {}
            for k, v in pairs(G.GAME.used_vouchers) do
                if v == true then
                    table.insert(keys, k)
                end
            end
            voucher_keys = table.concat(keys, "-")
        end
    return voucher_keys
end