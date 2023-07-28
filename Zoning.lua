-- In these lists, players will be stored depending on their team
local redforPlayers = {}
local blueforPlayers = {}

-- Function to assign a player to a side and update the lists
local function assignPlayerToSide(player)
    local playerName = player:getPlayerName()
    local playerSide = player:getCoalition()

    if playerSide == coalition.side.RED then
        table.insert(redforPlayers, playerName)
    elseif playerSide == coalition.side.BLUE then
        table.insert(blueforPlayers, playerName)
    end
end

-- Function to remove a player from the lists when they disconnect or switch sides
local function removePlayerFromLists(playerName)
    for i, name in ipairs(redforPlayers) do
        if name == playerName then
            table.remove(redforPlayers, i)
            break
        end
    end

    for i, name in ipairs(blueforPlayers) do
        if name == playerName then
            table.remove(blueforPlayers, i)
            break
        end
    end
end

-- Function to handle player side changes
local function onPlayerChangeSlot(playerID)
    local player = net.get_player_info(playerID)
    removePlayerFromLists(player:getPlayerName())
    assignPlayerToSide(player)
    displayLists()
end

-- Function to display the updated lists to all players
local function displayLists()
    local message = "Player Assignment:\n\nRed Side:\n"
    for _, playerName in ipairs(redforPlayers) do
        message = message .. playerName .. "\n"
    end

    message = message .. "\nBlue Side:\n"
    for _, playerName in ipairs(blueforPlayers) do
        message = message .. playerName .. "\n"
    end

    trigger.action.outText(message, 10) -- Display the message to all players

    -- Additional debug info (output to DCS.log)
    DCS.log("Displaying message to all players: " .. message)
end

-- Event handler to trigger player assignment and list display when the mission starts
local function onMissionStart()
    redforPlayers = {}
    blueforPlayers = {}

    local players = net.get_player_list()
    for _, playerID in pairs(players) do
        local player = net.get_player_info(playerID)
        assignPlayerToSide(player)
    end

    displayLists()
end

-- Event handler to register a player when they join the server
local function onPlayerConnect(playerID)
    local player = net.get_player_info(playerID)
    assignPlayerToSide(player)
    displayLists()
end

-- Event handler to remove a player from the lists when they disconnect
local function onPlayerDisconnect(playerID)
    local player = net.get_player_info(playerID)
    removePlayerFromLists(player:getPlayerName())
    displayLists()
end

-- Register the event handlers
if DCS then
    DCS.setUserCallbacks({
        onMissionStart = onMissionStart,
        onPlayerConnect = onPlayerConnect,
        onPlayerDisconnect = onPlayerDisconnect,
        onPlayerChangeSlot = onPlayerChangeSlot,
    })
else
    env.setErrorMessageBoxEnabled(true)
    env.error("DCS object is not available. This script should be used in a DCS multiplayer mission environment.")
end
