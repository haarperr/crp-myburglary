local QBCore = nil
local LastRobs = {}

TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

RegisterServerEvent('myBurglary:setLast')
AddEventHandler('myBurglary:setLast', function(missionIndex)
    local currentTime = os.time()
    LastRobs[missionIndex] = currentTime
end)

QBCore.Functions.CreateCallback('myBurglary:checkLast', function(source, cb, index)
    local currentTime = os.time()
    --print('get from ' .. index)

    if LastRobs[index] ~= nil then
        local diff = os.difftime(currentTime, LastRobs[index])
        local minutes = diff / 60
        --print(minutes)

        if minutes >= Config.Missions[index].delay then
            cb(0)
        else
            cb(Config.Missions[index].delay - minutes)
        end
    else
        cb(0)
    end
end)

QBCore.Functions.CreateCallback('myBurglary:checkItem', function(source, cb, item)
    local User = QBCore.Functions.GetPlayer(source)
    if User.Functions.GetItemByName(item).amount >= 1 then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('myBurglary:checkCops', function(source, cb)
    local Players = QBCore.Functions.GetPlayers()
	local cops = 0
	for i = 1, #Players, 1 do
        local User = QBCore.Functions.GetPlayer(Players[i])
        if User.PlayerData.job.name == 'police' then
            cops = cops + 1
		end
    end
    cb(cops)
end)

RegisterServerEvent('myBurglary:addItem')
AddEventHandler('myBurglary:addItem', function(item, amount)
    local User = QBCore.Functions.GetPlayer(source)
    --print('add item:' .. item .. amount)
    User.Functions.AddItem(item, amount)
end)

RegisterServerEvent('myBurglary:removeLockpick')
AddEventHandler('myBurglary:removeLockpick', function()
    local User = QBCore.Functions.GetPlayer(source)
    --print('add item:' .. item .. amount)
    User.Functions.RemoveItem(Config.LockpickItem, 1)
end)

RegisterServerEvent('myBurglary:addMoney')
AddEventHandler('myBurglary:addMoney', function(amount)
    local User = QBCore.Functions.GetPlayer(source)
    -- ADD BLACK MONEY
    --print('add money:' .. amount)

    if Config.useBlackMoney then
        --User.addAccountMoney(Config.BlackMoneyName, amount)
    else
        User.Functions.AddMoney("cash", amount)
    end
end)

RegisterServerEvent('myBurglary:callCops')
AddEventHandler('myBurglary:callCops', function(location)
    TriggerClientEvent('myBurglary:callPolice', -1, location)
end)

RegisterServerEvent('myBurglary:sellItems')
AddEventHandler('myBurglary:sellItems', function(item, amount, price)
    local src = source
    local User = QBCore.Functions.GetPlayer(src)
    local itemCount = User.Functions.GetItemByName(item).amount

    if itemCount >= amount then
        User.Functions.RemoveItem(item, amount)
        if Config.useBlackMoney then
            --User.addAccountMoney(Config.BlackMoneyName, amount * price)
        else
            User.Functions.AddMoney("cash", amount * price)
        end
        TriggerClientEvent('myBurglary:msg', src, Translation[Config.Locale]['items_sold_for'] .. price * amount .. '$')
    else
        TriggerClientEvent('myBurglary:msg', src, Translation[Config.Locale]['you_only_have_items'] .. itemCount .. Translation[Config.Locale]['you_only_have_items2'])
    end
end)