local SCREEN_SIZEX, SCREEN_SIZEY = utility.get_screen_size()
local WORKSPACE = game.workspace
local NATION_FOLDER = WORKSPACE:find_first_child("nation_folder")
local EMPIRE_FOLDER = WORKSPACE:find_first_child("empire_folder")
local SERVER_FOLDER = WORKSPACE:find_first_child("serverStuff")
local GAME_SETUP = SERVER_FOLDER:find_first_child("game_setup")

local dreadObject = nil
local dreadPlayer = nil
local dreadTeam = nil
local dreadTorso = nil
local shockNamesCache = {}
local shockTeamsCache = {}
local shockClassCache = {}
local shockObjectCache = {}
local dreadUpdate = 0
local shockUpdate = 0
local updateInterval = 1

menu.add_tab("It Just Works: Grave/Digger", "V")
menu.add_group("It Just Works: Grave/Digger", "General")

menu.add_checkbox("It Just Works: Grave/Digger", "General", "dread_ESP", "Dreadnought ESP", false)
menu.add_checkbox("It Just Works: Grave/Digger", "General", "dread_ESP_relative", "Dreadnought Relative Colors", false, {parent = "dread_ESP"})
menu.add_checkbox("It Just Works: Grave/Digger", "General", "dread_boss_bar", "Dreadnought Boss Bar", false, {parent = "dread_ESP"})
menu.add_checkbox("It Just Works: Grave/Digger", "General", "shock_ESP", "Shock Tooper ESP", false)
menu.add_checkbox("It Just Works: Grave/Digger", "General", "shock_kit_esp", "Shock Kit ESP", false)

local function dreadnoughtCacher()
    dreadObject = nil
    dreadPlayer = nil
    dreadTeam = nil
    dreadTorso = nil

    local players = entity.get_players()
    for _, player in ipairs(players) do
        if player.max_health > 500 then
            dreadObject = player
            dreadPlayer = player.name
            dreadTeam = player.team
            break
        end
    end

    if dreadPlayer then
        local teamFolder = nil
        if dreadTeam == "Royal Nation" then
            teamFolder = NATION_FOLDER
        elseif dreadTeam == "Golden Empire" then
            teamFolder = EMPIRE_FOLDER
        end
        if not teamFolder then return end
        local dreadModel = teamFolder:find_first_child(dreadPlayer)
        if not dreadModel then return end
        local torso = dreadModel:find_first_child("Torso")
        if not torso then return end
        dreadTorso = torso
    end
end

local function shockCacher()
    shockNamesCache = {}
    shockClassCache = {}
    shockTeamsCache = {}
    shockObjectCache = {}
    local players = entity.get_players()
    for _, player in ipairs(players) do
        if player.max_health == 300 or player.health == 300 then
            table.insert(shockNamesCache, player.name)
            table.insert(shockTeamsCache, player.team)
            table.insert(shockObjectCache, player)
        end
    end

    for i = 1, #shockNamesCache do
        local teamFolder = nil
        if shockTeamsCache[i] == "Royal Nation" then
            teamFolder = NATION_FOLDER
        elseif shockTeamsCache[i] == "Golden Empire" then
            teamFolder = EMPIRE_FOLDER
        end
        if not teamFolder then return end

        if shockModel:find_first_child("soldat_elitetorso") then
            table.insert(shockClassCache, "soldat")
        elseif shockModel:find_first_child("rook_elitetorso") then
            table.insert(shockClassCache, "rook")
        elseif shockModel:find_first_child("mortician_elitetorso") then
            table.insert(shockClassCache, "mortician")
        elseif shockModel:find_first_child("officer_elitetorso") then
            table.insert(shockClassCache, "officer")
        elseif shockModel:find_first_child("jaeger_elitetorso") then
            table.insert(shockClassCache, "jaeger")
        elseif shockModel:find_first_child("lancer_elitetorso") then
            table.insert(shockClassCache, "lancer")
        elseif shockModel:find_first_child("vanguard_elitetorso") then
            table.insert(shockClassCache, "vanguard")
        end
    end
end

local function dreadnoughtESP()
    if not dreadTorso then return end
    local dreadPos = dreadTorso.position
    if not dreadPos then return end
    local dreadScreenPosX, dreadScreenPosY = utility.world_to_screen(dreadPos)
    if not dreadScreenPosX and dreadScreenPosY then return end
    if dreadScreenPosX <= 0 then return end
    if not menu.get("dread_ESP_relative") then
        draw.rect_filled(dreadScreenPosX - 15, dreadScreenPosY - 15, 30, 30, {1, 0, 0, 1})
    elseif menu.get("dread_ESP_relative") then
        if dreadTeam == "Royal Nation" then
            draw.rect_filled(dreadScreenPosX - 15, dreadScreenPosY - 15, 30, 30, {0.725, 0.16, 0.941, 1})
        elseif dreadTeam == "Golden Empire" then
            draw.rect_filled(dreadScreenPosX - 15, dreadScreenPosY - 15, 30, 30, {0.945, 0.831, 0.16, 0.784})
        end
    end
end

local function dreadnoughtBossBar()
    if not dreadObject then return end
    local dreadCurHealth = dreadObject.health
    if not dreadCurHealth then return end
    draw.rect_filled(40, 95, 1000, 25, {0, 0, 0, 1})
    draw.rect(40, 95, 1000, 25, {0.364, 0, 0, 1}, 0, 2)


    local maxBarWidth = SCREEN_SIZEX - 80
    local healthRatio = dreadCurHealth/11000
    local healthBarWidth = healthRatio * (SCREEN_SIZEX - 10)
    local healthBarOffset = (maxBarWidth - healthBarWidth) / 10

    local minX = 540 - (healthBarWidth / 2)
    local maxX = 540 + (healthBarWidth / 2)
    draw.rect_filled(minX, 95, healthBarWidth, 25, {0.784, 0, 0, 1})

    draw.rect(40, 95, 1000, 25, {0.364, 0.364, 0.364, 1})
    draw.text((SCREEN_SIZEX / 2) - 75, 120, "Dreadnaught", {1, 1, 1, 1}, 25.0)
end

local function shockTrooperESP()
    for i = 1, #shockNamesCache do
        local shockObject = shockObjectCache[i]
        if not shockObject then return end
        local shockTorsoScreenPosX, shockTorsoScreenPosY, onScreen = shockObject:get_bone_screen("Torso")
        if not shockTorsoScreenPosX then return end
        if onScreen then
            if shockObject.team == "Royal Nation" then
                draw.rect_filled(shockTorsoScreenPosX - 10, shockTorsoScreenPosY - 10, 20, 20, {0.725, 0.16, 0.941, 1}, 0, 0)
            elseif shockObject.team == "Golden Empire" then
                draw.rect_filled(shockTorsoScreenPosX - 10, shockTorsoScreenPosY - 10, 20, 20, {0.945, 0.831, 0.16, 0.784}, 0, 0)
            end

            if shockClassCache[i] == "soldat" then
                draw.text(shockTorsoScreenPosX, shockTorsoScreenPosY, "ST", {1, 1, 1, 1}, 15.0)
            elseif shockClassCache[i] == "rook" then
                draw.text(shockTorsoScreenPosX, shockTorsoScreenPosY, "AT", {1, 1, 1, 1}, 15.0)
            elseif shockClassCache[i] == "mortician" then
                draw.text(shockTorsoScreenPosX, shockTorsoScreenPosY, "FT", {1, 1, 1, 1}, 15.0)
            elseif shockClassCache[i] == "officer" then
                draw.text(shockTorsoScreenPosX, shockTorsoScreenPosY, "RT", {1, 1, 1, 1}, 15.0)
            elseif shockClassCache[i] == "jaeger" then
                draw.text(shockTorsoScreenPosX, shockTorsoScreenPosY, "GT", {1, 1, 1, 1}, 15.0)
            elseif shockClassCache[i] == "lancer" then
                draw.text(shockTorsoScreenPosX, shockTorsoScreenPosY, "TT", {1, 1, 1, 1}, 15.0)
            elseif shockClassCache[i] == "vanguard" then
                draw.text(shockTorsoScreenPosX, shockTorsoScreenPosY, "BT", {1, 1, 1, 1}, 15.0)
            end
        end 
    end
end

local function shockKitESP()
    if GAME_SETUP:find_first_child("elite_kit1") then
        local kitOne = GAME_SETUP:find_first_child("elite_kit1")
        if kitOne and not kitOne:find_first_child("used") then
            local clickOne = kitOne:find_first_child("click")
            if clickOne then
                local pos = clickOne.position
                local screenX, screenY, onScreen = utility.world_to_screen(pos)
                
                if onScreen then
                    draw.text(screenX, screenY, "KIT 1", {1, 1, 1, 1}, 20.0)
                end
            end
        end

        local kitTwo = GAME_SETUP:find_first_child("elite_kit2")
        if kitTwo and not kitTwo:find_first_child("used") then
            local clickTwo = kitTwo:find_first_child("click")
            if clickTwo then
                local pos = clickTwo.position
                local screenX, screenY, onScreen = utility.world_to_screen(pos)
                
                if onScreen then
                    draw.text(screenX, screenY, "KIT 2", {1, 1, 1, 1}, 20.0)
                end
            end
        end
    else
        for _, model in ipairs(GAME_SETUP:get_children()) do
            if model.class_name == "Model" and model.name == "elitecrate" then
                local crateClick = model:find_first_child("click")
                if not crateClick then return end
                local clickPos = crateClick.position
                if not clickPos then return end
                local clickScreenPosX, clickScreenPosY, click_on_screen = utility.world_to_screen(clickPos)
                if not clickScreenPosX then return end
                if not model:find_first_child("used") then
                    if click_on_screen then
                        draw.text(clickScreenPosX, clickScreenPosY, "KIT", 20.0)
                    end
                end
            end
        end
    end
end

local function tpControlKit(kit)
    local player = entity.get_local_player()
    if not player then return end
    local character = player.character
    if not character then return end
    local HRP = character:find_first_child("HumanoidRootPart")
    if not HRP then return end

    if kit == 1 then
        local kitOne = GAME_SETUP:find_first_child("elite_kit1")
        if kitOne and not kitOne:find_first_child("used") then
            local clickOne = kitOne:find_first_child("click")
            if clickOne then
                local pos = clickOne.position
                HRP.position = pos
            end
        end
    end
    if kit == 2 then
        local kitTwo = GAME_SETUP:find_first_child("elite_kit2")
        if kitTwo and not kitTwo:find_first_child("used") then
            local clickTwo = kitTwo:find_first_child("click")
            if clickTwo then
                local pos = clickTwo.position
                HRP.position = pos
            end
        end
    end
end

local function tpControlPoint(point)
    local objectivesFolder = SERVER_FOLDER:find_first_child("objectives")
    local pointToTeleport = nil
    if point == 0 then pointToTeleport = objectivesFolder:find_first_child("objectiveA") end
    if point == 1 then pointToTeleport = objectivesFolder:find_first_child("objectiveB") end
    if point == 2 then pointToTeleport = objectivesFolder:find_first_child("objectiveC") end
    if point == 3 then pointToTeleport = objectivesFolder:find_first_child("objectiveD") end
    if point == 4 then pointToTeleport = objectivesFolder:find_first_child("objectiveE") end

    local objectiveCapture = pointToTeleport:find_first_child("capture")
    if not objectiveCapture then return end
    local capturePos = objectiveCapture.position
    if not capturePos then return end

    local player = entity.get_local_player()
    if not player then return end
    local character = player.character
    if not character then return end
    local HRP = character:find_first_child("HumanoidRootPart")
    if not HRP then return end

    HRP.position = capturePos
end

menu.add_button("It Just Works: Grave/Digger", "General", "kit_one_TP", "TP to Control Kit One", function()
    tpControlKit(1)
end)
menu.add_button("It Just Works: Grave/Digger", "General", "kit_two_TP", "TP to Control Kit Two", function()
    tpControlKit(2)
end)
menu.add_combo("It Just Works: Grave/Digger", "General", "point_tp_selector", "Select Point to TP to", {"Point Able", "Point Baker", "Point Charlie", "Point Duff", "Point Edward"}, 0)
menu.add_button("It Just Works: Grave/Digger", "General", "point_tp_button", "TP To Selected Point", function()
    tpControlPoint(menu.get("point_tp_selector"))
end)

local cacher_thread = thread.create(function()
    if menu.get("dread_ESP") then
        dreadnoughtCacher()
    end
    if menu.get("shock_ESP") then
        shockCacher()
    end
end, 1000)

function on_frame()
    if menu.get("dread_ESP") then
        dreadnoughtESP()
    end
    if menu.get("dread_boss_bar") then
        dreadnoughtBossBar()
    end
    if menu.get("shock_ESP") then
        shockTrooperESP()
    end
    if menu.get("shock_kit_esp") then
        shockKitESP()
    end
end
