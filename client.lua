QBCore = nil
isLoggedIn = false
local myJob = {}

Citizen.CreateThread(function()
	while QBCore == nil do
		TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
	isLoggedIn = true
	myJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    isLoggedIn = true
    myJob = JobInfo
end)

local isRightTime = false
local isNearHouse = false
local isAtHouse = false
local currentMission
local isInRobbery = false
local currentObject
local isNearObject = false
local isAtObject = false
local isAtExit = false
local codeLocation
local isAtCode = false
local isAlarmActive = false
local isAtAlarm = false
local count = 0
local isNearSeller = false
local isAtSeller = false
local isSellerLoaded = false
local npc
local currentMissionIndex 
local _menuPool

if Config.useSeller then
    _menuPool = NativeUI.CreatePool()
end

Citizen.CreateThread(function()
    if Config.showSellerBlip and Config.useSeller then
        local blip = AddBlipForCoord(Config.SellerLocation.x, Config.SellerLocation.y)
        SetBlipSprite(blip, 605)
        SetBlipDisplay(blip, 6)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 6)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING");
        AddTextComponentString(Translation[Config.Locale]['seller_title'])
        EndTextCommandSetBlipName(blip)
    end

    if Config.showMissionBlips then
        for k, v in pairs(Config.Missions) do
            local blip = AddBlipForCoord(v.loc.x, v.loc.y)
            SetBlipSprite(blip, 374)
            SetBlipDisplay(blip, 6)
            SetBlipScale(blip, 1.0)
            SetBlipColour(blip, 6)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING");
            AddTextComponentString(Translation[Config.Locale]['house_robbery'])
            EndTextCommandSetBlipName(blip)
        end
    end

    while true do
        local hour = GetClockHours()
        local minute = GetClockMinutes()

        isRightTime = false
        isNearHouse = false
        isAtHouse = false
        isAtSeller = false
        isNearSeller = false
		isNearObject = false
		isAtObject = false
		isAtExit = false
		isAtCode = false
		isAtAlarm = false

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if Config.useSeller then
            local distanceToSeller = Vdist(playerCoords, Config.SellerLocation.x, Config.SellerLocation.y, Config.SellerLocation.z)

            if distanceToSeller <= 2.0 then
                isAtSeller = true
                isNearSeller = true
            elseif distanceToSeller <= 20.0 then
                isNearSeller = true
                if not isSellerLoaded then
                    RequestModel(GetHashKey(Config.SellerPedModel))
                    while not HasModelLoaded(GetHashKey(Config.SellerPedModel)) do
                        Wait(1)
                    end
                    npc = CreatePed(4, GetHashKey(Config.SellerPedModel), Config.SellerLocation.x, Config.SellerLocation.y, Config.SellerLocation.z - 1.0, Config.SellerLocation.rot, false, true)
                    FreezeEntityPosition(npc, true)	
                    SetEntityHeading(npc, Config.SellerLocation.rot)
                    SetEntityInvincible(npc, true)
                    SetBlockingOfNonTemporaryEvents(npc, true)  

                    isSellerLoaded = true
                end
            end

            if (isSellerLoaded and not isNearSeller) then
                DeleteEntity(npc)
                SetModelAsNoLongerNeeded(GetHashKey(ped))
                isSellerLoaded = false
            end
        end

        if hour >= Config.BurglaryTime.start and hour < Config.BurglaryTime.endtime then
            isRightTime = true
        elseif Config.BurglaryTime.start > Config.BurglaryTime.endtime then
            -- tagübergreifend
            if hour <= 24 then
                isRightTime = true
            elseif hour < Config.BurglaryTime.endtime then
                isRightTime = true
            end

        elseif isInRobbery then
            endRobbery()
            ShowNotification(Translation[Config.Locale]['too_late_rob_aborted'])
        end

        if isRightTime then
            for k, v in pairs(Config.Missions) do
                local distance = Vdist(playerCoords, v.loc.x, v.loc.y, v.loc.z)

                if distance < 1.0 then
                    isAtHouse = true
                    isNearHouse = true
                    currentMission = v
                    currentMissionIndex = k
                elseif distance < 30.0 then
                    isNearHouse = true
                    currentMission = v
                    currentMissionIndex = k
                end
            end
        end

        if isInRobbery then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local closestDistance = 10000

            if currentMission.inside ~= nil then
                local distanceExit = Vdist(playerCoords, currentMission.inside.x, currentMission.inside.y, currentMission.inside.z)

                if distanceExit < 1.0 then
                    isAtExit = true
                end
            end

            local distanceCode = Vdist(playerCoords, codeLocation.x, codeLocation.y, codeLocation.z)
            if distanceCode < 2.0 then
                isAtCode = true
            end

            local distanceAlarm = Vdist(playerCoords, currentMission.alarmLocation.x, currentMission.alarmLocation.y, currentMission.alarmLocation.z)
            if distanceAlarm < 1.2 then
                isAtAlarm = true
            end

            for k, v in pairs(currentMission.objects) do
                if v.found == nil or v.found == false then
                    local distance = Vdist(playerCoords, v.loc.x, v.loc.y, v.loc.z)
                    if distance < closestDistance then
                        currentObject = v
                        closestDistance = distance
                    end

                    --print(distance)

                    if distance < 3.5 then
                        isNearObject = true
                    end

                    if distance < 1.5 then
                        isAtObject = true
                    end
                end
            end
        end

        Citizen.Wait(350)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if Config.useSeller then
            if _menuPool:IsAnyMenuOpen() then
                _menuPool:ProcessMenus()
            end
        end

        if isAtSeller then
            showInfobar(Translation[Config.Locale]['infobar_seller'])
            if IsControlJustReleased(0, Config.InteractKey) then
                generateSellMenu()
            end
        end

        if isInRobbery and isAlarmActive then
            if currentMission.alarmTimeBeforeDispatch - count > 0 then
                text2(Translation[Config.Locale]['screen_deactivatealarm'])
                text(Translation[Config.Locale]['screen_alarmtime'] .. currentMission.alarmTimeBeforeDispatch - count .. Translation[Config.Locale]['screen_alarmtime2'])
            else
                text(Translation[Config.Locale]['screen_police'])
                text2(currentMission.customScreenMessage)
            end
        elseif isInRobbery then
            text(Translation[Config.Locale]['screen_alarmdisabled'])
            text2(currentMission.customScreenMessage)
        end

        if isNearHouse then
            DrawMarker(1, currentMission.loc.x, currentMission.loc.y, currentMission.loc.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0*0.8, 1.0*0.8, 1.0, 136, 0, 0, 75, false, false, 2, false, false, false, false)
        end

        if isNearObject then
            --DrawMarker(27, currentObject.loc.x, currentObject.loc.y, currentObject.loc.z - 0.5 , 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0*0.3, 1.0*0.3, 1.0, 136, 0, 0, 75, false, false, 2, false, false, false, false)
        end

        if isInRobbery then
            -- print('check')
            -- if IsPedSprinting(GetPlayerPed(-1)) then
            --     print('true')
            --     text('~r~You are too loud!')
            -- end
            
            if isAlarmActive then
                DrawMarker(21, currentMission.alarmLocation.x, currentMission.alarmLocation.y, currentMission.alarmLocation.z , 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 136, 0, 0, 75, false, false, 2, false, false, false, false)
            else
                DrawMarker(21, currentMission.alarmLocation.x, currentMission.alarmLocation.y, currentMission.alarmLocation.z , 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 136, 254, 0, 75, false, false, 2, false, false, false, false)
            end

            if currentMission.inside ~= nil then
                DrawMarker(1, currentMission.inside.x, currentMission.inside.y, currentMission.inside.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0*0.8, 1.0*0.8, 1.0, 136, 0, 0, 75, false, false, 2, false, false, false, false)
            end

            if isAtAlarm then
                if isAlarmActive then
                    showInfobar(Translation[Config.Locale]['infobar_code'])
                    if IsControlJustReleased(0, Config.CodeKey) then
                        local codeInput = CreateDialog(Translation[Config.Locale]['insert_deactivation'])
                        if codeInput ~= nil then
                            local animDict = "anim@heists@keypad@"
                            local animLib = "idle_a"

                            RequestAnimDict(animDict)
                            while not HasAnimDictLoaded(animDict) do
                                Citizen.Wait(50)
                            end

                            SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"),true)
                            Citizen.Wait(500)

                            TaskPlayAnim(PlayerPedId(), animDict, animLib, 2.0, -2.0, -1, 1, 0, 0, 0, 0 )
                            Citizen.Wait(6500)

                            if tonumber(codeInput) == currentMission.code then
                                isAlarmActive = false
                                ShowNotification(Translation[Config.Locale]['alarm_deactivated'])
                                ClearPedTasks(PlayerPedId())
                            else
                                ShowNotification(Translation[Config.Locale]['wrong_code'])
                                ClearPedTasks(PlayerPedId())
                            end
                        end
                    end
                end
            end
        end

        if isAtHouse then
            if isInRobbery then
                showInfobar(Translation[Config.Locale]['infobar_leave'])
                if IsControlJustReleased(0, Config.InteractKey) then
                    endRobbery()
                    SetNewWaypoint(Config.SellerLocation.x, Config.SellerLocation.y)
                    ShowNotification(Translation[Config.Locale]['end_robbery_seller'])
                    -- hint message seller
                end
            else
                showInfobar(Translation[Config.Locale]['infobar_enter'])
                if IsControlJustReleased(0, Config.InteractKey) then
                    if Config.requiresItem then
                        QBCore.Functions.TriggerCallback('myBurglary:checkItem', function(hasLockpick)
                            if hasLockpick then
                                QBCore.Functions.TriggerCallback('myBurglary:checkLast', function(timeLeft)
                                    if timeLeft == 0 then
                                        QBCore.Functions.TriggerCallback('myBurglary:checkCops', function(cops)
                                            if cops >= currentMission.requiredCops then
                                                startRobbery()
                                                TriggerServerEvent('myBurglary:removeLockpick')
                                            else
                                                ShowNotification(Translation[Config.Locale]['not_enough_cops'])
                                            end
                                        end)
                                    else
                                        ShowNotification(Translation[Config.Locale]['already_robbed'] .. math.floor(timeLeft) .. Translation[Config.Locale]['already_robbed2'])
                                    end
                                end, currentMissionIndex)
                            else
                                ShowNotification(Translation[Config.Locale]['no_lockpick'])
                            end
                        end, Config.LockpickItem)
                    else
                        QBCore.Functions.TriggerCallback('myBurglary:checkLast', function(timeLeft)
                            if timeLeft == 0 then
                                QBCore.Functions.TriggerCallback('myBurglary:checkCops', function(cops)
                                    if cops >= currentMission.requiredCops then
                                        startRobbery()
                                    else
                                        ShowNotification(Translation[Config.Locale]['not_enough_cops'])
                                    end
                                end)
                            else
                                ShowNotification(Translation[Config.Locale]['already_robbed'] .. math.floor(timeLeft) .. Translation[Config.Locale]['already_robbed2'])
                            end
                        end, currentMissionIndex)
                    end
                end
            end
        end

        if isAtExit then
            showInfobar(Translation[Config.Locale]['infobar_leave'])
            if IsControlJustReleased(0, Config.InteractKey) then
				endRobbery()
                SetNewWaypoint(Config.SellerLocation.x, Config.SellerLocation.y)
                DoScreenFadeOut(1000)
                Citizen.Wait(1000)
                SetEntityCoords(PlayerPedId(), currentMission.loc.x, currentMission.loc.y, currentMission.loc.z)
                Citizen.Wait(1000)
                DoScreenFadeIn(1000)
				ShowNotification(Translation[Config.Locale]['end_robbery_seller'])
            end
        end

        if isAtObject then
            showInfobar(Translation[Config.Locale]['collect_items'])
            if IsControlJustReleased(0, Config.InteractKey) then

                RequestAnimDict("mp_common")
                while not HasAnimDictLoaded("mp_common") do
                    Citizen.Wait(0)
                end

                attachObject(currentObject.objectData)
                TaskPlayAnim(PlayerPedId(), "mp_common", "givetake1_a" ,8.0, -8.0, -1, 0, 0, false, false, false )
                Wait(2600)

                DeleteObject(currentObject.objectData)
                currentObject.found = true
                if currentObject.giveItems ~= nil or #currentObject.giveItems > 0 then
                    for j, val in pairs(currentObject.giveItems) do
                        --print(val.amount)
                        TriggerServerEvent('myBurglary:addItem', val.item, val.amount)
                    end
                end

                if currentObject.giveMoney ~= nil or currentObject.giveMoney > 0 then
                    TriggerServerEvent('myBurglary:addMoney', currentObject.giveMoney)
                end
            end
        end

        if isAtCode then
            --ShowNotification('You have found the ~r~alarm ~s~code: ~y~' .. currentMission.code)
            Draw3DText(codeLocation.x, codeLocation.y, codeLocation.z-1.0, Translation[Config.Locale]['3D_alarmtext'] .. currentMission.code)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if isInRobbery and isAlarmActive then
            count = count + 1
            PlaySoundFromCoord(-1, "scanner_alarm_os", currentMission.alarmLocation.x, currentMission.alarmLocation.y, currentMission.alarmLocation.z, "dlc_xm_iaa_player_facility_sounds", 1, 50, 0)
            if count == currentMission.alarmTimeBeforeDispatch then
                TriggerServerEvent('myBurglary:callCops', currentMission.loc)
            end
        end

        Citizen.Wait(1000)
    end 
end)

function startRobbery()
    isInRobbery = true
    isAlarmActive = true

    -- calculate call cops percentage
    local randomCops = math.random(1, 100)
    if randomCops <= currentMission.callCopPercentageAnyways then
        TriggerServerEvent('myBurglary:callCops', currentMission.loc)
    end

    TriggerServerEvent('myBurglary:setLast', currentMissionIndex)

    count = 0
    currentMission.code = math.random(1111,9999)
    local remTime = math.random(currentMission.alarmTimeBeforeDispatch.randomA, currentMission.alarmTimeBeforeDispatch.randomB)
    currentMission.alarmTimeBeforeDispatch = remTime
    print(currentMission.alarmTimeBeforeDispatch)
    loadObjects()
    if currentMission.inside ~= nil then
        DoScreenFadeOut(1000)
        Citizen.Wait(1000)
        SetEntityCoords(PlayerPedId(), currentMission.inside.x, currentMission.inside.y, currentMission.inside.z)
        Citizen.Wait(1000)
        DoScreenFadeIn(1000)
    end
end

function loadObjects()
    local randomCodeLoc = math.random(1, #currentMission.randomCodeLocations)
    codeObject = CreateObject(GetHashKey("p_notepad_01_s"), currentMission.randomCodeLocations[randomCodeLoc].x,  currentMission.randomCodeLocations[randomCodeLoc].y,  currentMission.randomCodeLocations[randomCodeLoc].z, false, true, true)
    PlaceObjectOnGroundProperly(codeObject)
    codeLocation = {x = currentMission.randomCodeLocations[randomCodeLoc].x,  y = currentMission.randomCodeLocations[randomCodeLoc].y,  z = currentMission.randomCodeLocations[randomCodeLoc].z}

    for k, v in pairs(currentMission.objects) do
        local object = CreateObject(GetHashKey(v.objectHash), v.loc.x, v.loc.y, v.loc.z, false, true, true)
        PlaceObjectOnGroundProperly(object)
        SetEntityHeading(object, v.loc.rot)
        v.objectData = object
    end
end

if Config.useSeller then
    function generateSellMenu()
        _menuPool:Remove()
        collectgarbage()

        local sellMenu = NativeUI.CreateMenu(Translation[Config.Locale]['seller_title'], nil)
        _menuPool:Add(sellMenu)

        for k, v in pairs(Config.SellItems) do
            local sell = NativeUI.CreateItem(v.label, '~b~')
            sell:RightLabel(v.priceBuy .. '$')
            sellMenu:AddItem(sell)

            sell.Activated = function(sender, index)
                local res_amount = CreateDialog(Translation[Config.Locale]['input_howmuch'])
                if tonumber(res_amount) then
                    local quantity = tonumber(res_amount)
                    TriggerServerEvent('myBurglary:sellItems', v.sqlitem, quantity, v.priceBuy)
                end
            end
        end

        sellMenu:Visible(not sellMenu:Visible())
        _menuPool:RefreshIndex()
        _menuPool:MouseEdgeEnabled (false)
    end
end

RegisterNetEvent('myBurglary:callPolice')
AddEventHandler('myBurglary:callPolice', function(location)
    if myJob ~= nil and myJob.name == 'police' then
        local s1, s2 = Citizen.InvokeNative( 0x2EB41072B4C1E4C0, location.x, location.y, location.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
        local street1 = GetStreetNameFromHashKey(s1)

        showPictureNotification("CHAR_MP_MERRYWEATHER", Translation[Config.Locale]['house_alarm_msg'] .. street1, Translation[Config.Locale]['house_alarm'], nil)

        local Blip = AddBlipForCoord(location.x, location.y, location.z)
        local transT = 2500

        SetBlipSprite(Blip, 10)
        SetBlipColour(Blip, 6)
        SetBlipAlpha(Blip, transT)
        SetBlipAsShortRange(Blip, 1)

        while transT ~= 0 do
            Wait(25 * 4)
            transT = transT - 1
            SetBlipAlpha(Blip, transT)
            if transT == 0 then
                SetBlipSprite(Blip, 2)
                return
            end
        end
    end
end)

RegisterNetEvent('myBurglary:msg')
AddEventHandler('myBurglary:msg', function(message)
    QBCore.Functions.Notify(message)
end)

function endRobbery()
    isInRobbery = false
    isAlarmActive = false
    count = 0

    DeleteObject(codeObject)
    for k, v in pairs(currentMission.objects) do
        DeleteObject(v.objectData)
    end

    --currentMission = nil
end

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = #(vector3(p.x, p.y, p.z) - vector3(x, y, z))
    local scale = (1 / distance) * 0.4
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        SetTextScale(0.0, scale, 0.35, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

function CreateDialog(OnScreenDisplayTitle_shopmenu) --general OnScreenDisplay for KeyboardInput
	AddTextEntry(OnScreenDisplayTitle_shopmenu, OnScreenDisplayTitle_shopmenu)
	DisplayOnscreenKeyboard(1, OnScreenDisplayTitle_shopmenu, "", "", "", "", "", 32)
	while (UpdateOnscreenKeyboard() == 0) do
		DisableAllControlActions(0)
		Wait(0)
	end
	if (GetOnscreenKeyboardResult()) then
		local displayResult = GetOnscreenKeyboardResult()
		return displayResult
	end
end

function showInfobar(msg)
	CurrentActionMsg = msg
	SetTextComponentFormat('STRING')
	AddTextComponentString(CurrentActionMsg)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function text(content) 
    SetTextFont(1)
    SetTextProportional(0)
    SetTextScale(0.65,0.65)
    SetTextEntry("STRING")
    AddTextComponentString(content)
    DrawText(0.74,0.9)
end

function text2(content) 
    SetTextFont(1)
    SetTextProportional(0)
    SetTextScale(0.75,0.75)
    SetTextEntry("STRING")
    AddTextComponentString(content)
    DrawText(0.74,0.85)
end

function ShowNotification(text)
	SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
	DrawNotification(false, true)
end

function showPictureNotification(icon, msg, title, subtitle)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    SetNotificationMessage(icon, icon, true, 1, title, subtitle)
    DrawNotification(false, true)
end

function attachObject(object)
	AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.17, 0, 0, 0, 190.0, 60.0, true, true, false, true, 1, true) -- object is attached to right hand    
end