ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)
RegisterServerEvent("st:bag2")
AddEventHandler("st:bag2", function(target_id)
    local _source = source
    local targetid = GetPlayerIdentifier(target_id)
    local xPlayer2 = ESX.GetPlayerFromId(target_id)
    local esya = xPlayer2.getInventoryItem('bag').count
    if esya >= 1 then
        TriggerClientEvent('st:bag3', _source, targetid)
    else
        TriggerClientEvent('skavronskyynotify:client:SendAlert', _source, { type = 'error', text = 'No one has a bag', lenght = 8000 })
    end
end)


RegisterServerEvent("para:ekle")
AddEventHandler("para:ekle", function(target_id)
            local _source = source
            local xPlayer = ESX.GetPlayerFromId(_source)
            xPlayer.addMoney(25)
            TriggerClientEvent('skavronskyynotify:client:SendAlert', source, { type = 'inform', text = 'The vehicle has been towed. you won $25.' })
end)


-- if player then
--     if reward then
--         if reward == "money" then
--             local rewardAmount = math.random(Config.RandomCashReward[1], Config.RandomCashReward[2])
--             local _source = source
--             local xPlayer = ESX.GetPlayerFromId(_source)			
--             --xPlayer.addAccountMoney('black_money',math.random(Config.RandomCashReward[1],Config.RandomCashReward[2]))
--             xPlayer.addMoney(2500)

--             TriggerClientEvent("esx:showNotification", source, "Alınan para $ 2500 ")
--         else
--             player.addInventoryItem("champagne", 1)
            
--             TriggerClientEvent("esx:showNotification", source, "Şişe aldın.")