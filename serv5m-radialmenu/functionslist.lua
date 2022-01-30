ESX = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(5)
  end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

RegisterNetEvent('adam:tasimak')
AddEventHandler('adam:tasimak', function()
 ExecuteCommand('drag')
end)

RegisterNetEvent('st:setroom')
AddEventHandler('st:setroom', function()
 ExecuteCommand('setroommate')
end)

RegisterNetEvent('st:raidh')
AddEventHandler('st:raidh', function()
 ExecuteCommand('raidhouse')
end)

RegisterNetEvent('st:policeac')
AddEventHandler('st:policeac', function()
 ExecuteCommand('plist')
end)

RegisterNetEvent('st:bugreport')
AddEventHandler('st:bugreport', function()
 ExecuteCommand('report')
end)

RegisterNetEvent('odenmemis:fatura')
AddEventHandler('odenmemis:fatura', function(job)
    OpenUnpaidBillsMenu()
end)

function OpenUnpaidBillsMenu(player)
	local elements = {}

	ESX.TriggerServerCallback('esx_billing:getTargetBills', function(bills)
		for k,bill in ipairs(bills) do
			table.insert(elements, {
				label = ('%s - <span style="color:red;">%s</span>'):format(bill.label, _U('armory_item', ESX.Math.GroupDigits(bill.amount))),
				billId = bill.id
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'billing', {
			title    = _U('unpaid_bills'),
			align    = 'top-left',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

function specialMenu(menuname,callback)
	local players = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 3.0)
	local elements = {}
	local serverIds = {}
	for i = 1, #players, 1 do
		if players[i] ~= PlayerId() then
			table.insert(serverIds, GetPlayerServerId(players[i]))
		end
	end
	ESX.TriggerServerCallback("esx_policejob:getMeNames",function(identities)
		for k,v in pairs(identities) do
			table.insert(elements, {
				player = k,
				label = v
			})
		end		
		ESX.UI.Menu.CloseAll()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'special_cop_menu',
		{
			title = menuname,
			align = 'top-left',
			elements = elements,
		},
		function(data, menu)
			menu.close()
			print(data.current.player)
			callback(data.current.player)
		end,
		function(data, menu)
			menu.close()
		end)
	end,serverIds)		
end
--Fonksiyonlar--

--[[---------------------------------------------------------------------------------
||                                                                                  ||
||                          SPEEDCAMERA SCRIPT - GTA5 - FiveM                       ||
||                                   Author = Shedow                                ||
||                            Created for N3MTV community                           ||
||                                                                                  ||
----------------------------------------------------------------------------------]]--
 
local maxSpeed = 0
-- local minSpeed = 0
local info = ""
local isRadarPlaced = false -- bolean to get radar status
local Radar -- entity object
local RadarBlip -- blip
local RadarPos = {} -- pos
local RadarAng = 0 -- angle
local LastPlate = ""
local LastVehDesc = ""
local LastSpeed = 0
local LastInfo = ""
 
local function GetPlayers2()
    local players = {}
    for i = 0, 59 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end
    return players
end
 
local function GetClosestDrivingPlayerFromPos(radius, pos)
    local players = GetPlayers2()
    local closestDistance = radius or -1
    local closestPlayer = -1
    local closestVeh = -1
    for _ ,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local ped = GetPlayerPed(value)
            if GetVehiclePedIsUsing(ped) ~= 0 then
                local targetCoords = GetEntityCoords(ped, 0)
                local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"], pos["x"], pos["y"], pos["z"], true)
                if(closestDistance == -1 or closestDistance > distance) then
                    closestVeh = GetVehiclePedIsUsing(ped)
                    closestPlayer = value
                    closestDistance = distance
                end
            end
        end
    end
    return closestPlayer, closestVeh, closestDistance
end
 
 
function radarSetSpeed(defaultText)
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", defaultText or "", "", "", "", 5)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0);
        Wait(0);
    end
    if (GetOnscreenKeyboardResult()) then
        local gettxt = tonumber(GetOnscreenKeyboardResult())
        if gettxt ~= nil then
            return gettxt
        else
            ClearPrints()
            SetTextEntry_2("STRING")
            AddTextComponentString("~r~Please enter a correct number !")
            DrawSubtitleTimed(3000, 1)
            return
        end
    end
    return
end
 
 
local function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end
 
function POLICE_radar()
    if isRadarPlaced then -- remove the previous radar if it exists, only one radar per cop
       
        if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), RadarPos.x, RadarPos.y, RadarPos.z, true) < 0.9 then -- if the player is close to his radar
       
            RequestAnimDict("anim@apt_trans@garage")
            while not HasAnimDictLoaded("anim@apt_trans@garage") do
               Wait(1)
            end
            TaskPlayAnim(GetPlayerPed(-1), "anim@apt_trans@garage", "gar_open_1_left", 1.0, -1.0, 5000, 0, 1, true, true, true) -- animation
       
            Citizen.Wait(2000) -- prevent spam radar + synchro spawn with animation time
       
            SetEntityAsMissionEntity(Radar, false, false)
           
            DeleteObject(Radar) -- remove the radar pole (otherwise it leaves from inside the ground)
            DeleteEntity(Radar) -- remove the radar pole (otherwise it leaves from inside the ground)
            Radar = nil
            RadarPos = {}
            RadarAng = 0
            isRadarPlaced = false
           
            RemoveBlip(RadarBlip)
            RadarBlip = nil
            LastPlate = ""
            LastVehDesc = ""
            LastSpeed = 0
            LastInfo = ""
           
        else
           
            ClearPrints()
            SetTextEntry_2("STRING")
            AddTextComponentString("~r~You are not next to your Radar !")
            DrawSubtitleTimed(3000, 1)
           
            Citizen.Wait(1500) -- prevent spam radar
       
        end
   
    else -- or place a new one
        maxSpeed = radarSetSpeed("50")
       
        Citizen.Wait(200) -- wait if the player was in moving
        RadarPos = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0, 1.5, 0)
        RadarAng = GetEntityRotation(GetPlayerPed(-1))
       
        if maxSpeed ~= nil then -- maxSpeed = nil only if the player hasn't entered a valid number
       
            RequestAnimDict("anim@apt_trans@garage")
            while not HasAnimDictLoaded("anim@apt_trans@garage") do
               Wait(1)
            end
            TaskPlayAnim(GetPlayerPed(-1), "anim@apt_trans@garage", "gar_open_1_left", 1.0, -1.0, 5000, 0, 1, true, true, true) -- animation
           
            Citizen.Wait(1500) -- prevent spam radar placement + synchro spawn with animation time
           
            RequestModel("prop_cctv_pole_01a")
            while not HasModelLoaded("prop_cctv_pole_01a") do
               Wait(1)
            end
           
            Radar = CreateObject(1927491455, RadarPos.x, RadarPos.y, RadarPos.z - 7, true, true, true) -- http://gtan.codeshock.hu/objects/index.php?page=1&search=prop_cctv_pole_01a
            SetEntityRotation(Radar, RadarAng.x, RadarAng.y, RadarAng.z - 115)
            -- SetEntityInvincible(Radar, true) -- doesn't work, radar still destroyable
            -- PlaceObjectOnGroundProperly(Radar) -- useless
            SetEntityAsMissionEntity(Radar, true, true)
           
            FreezeEntityPosition(Radar, true) -- set the radar invincible (yeah, SetEntityInvincible just not works, okay FiveM.)
 
            isRadarPlaced = true
           
            RadarBlip = AddBlipForCoord(RadarPos.x, RadarPos.y, RadarPos.z)
            SetBlipSprite(RadarBlip, 380) -- 184 = cam
            SetBlipColour(RadarBlip, 1) -- https://github.com/Konijima/WikiFive/wiki/Blip-Colors
            SetBlipAsShortRange(RadarBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Radar")
            EndTextCommandSetBlipName(RadarBlip)
       
        end
       
    end
end

function OpenBodySearchMenu(player)

	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)

		local elements = {}

		for i=1, #data.accounts, 1 do

			if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then

				table.insert(elements, {
					label    = _U('confiscate_dirty', ESX.Math.Round(data.accounts[i].money)),
					value    = 'black_money',
					itemType = 'item_account',
					amount   = data.accounts[i].money
				})

				break
			end

		end

		table.insert(elements, {label = _U('guns_label'), value = nil})

		for i=1, #data.weapons, 1 do
			table.insert(elements, {
				label    = _U('confiscate_weapon', ESX.GetWeaponLabel(data.weapons[i].name), data.weapons[i].ammo),
				value    = data.weapons[i].name,
				itemType = 'item_weapon',
				amount   = data.weapons[i].ammo
			})
		end

		table.insert(elements, {label = _U('inventory_label'), value = nil})

		for i=1, #data.inventory, 1 do
			if data.inventory[i].count > 0 then
				table.insert(elements, {
					label    = _U('confiscate_inv', data.inventory[i].count, data.inventory[i].label),
					value    = data.inventory[i].name,
					itemType = 'item_standard',
					amount   = data.inventory[i].count
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search',
		{
			title    = _U('search'),
			align    = 'right',
			elements = elements,
		},
		function(data, menu)

			local itemType = data.current.itemType
			local itemName = data.current.value
			local amount   = data.current.amount

			if data.current.value ~= nil then
				TriggerServerEvent('esx_policejob:confiscatePlayerItem', GetPlayerServerId(player), itemType, itemName, amount)
				OpenBodySearchMenu(player)
			end

		end, function(data, menu)
			menu.close()
		end)

	end, GetPlayerServerId(player))

end
 
Citizen.CreateThread(function()
    while true do
        Wait(0)
 
        if isRadarPlaced then
       
            if HasObjectBeenBroken(Radar) then -- check is the radar is still there
               
                SetEntityAsMissionEntity(Radar, false, false)
                SetEntityVisible(Radar, false)
                DeleteObject(Radar) -- remove the radar pole (otherwise it leaves from inside the ground)
                DeleteEntity(Radar) -- remove the radar pole (otherwise it leaves from inside the ground)
               
                Radar = nil
                RadarPos = {}
                RadarAng = 0
                isRadarPlaced = false
               
                RemoveBlip(RadarBlip)
                RadarBlip = nil
               
                LastPlate = ""
                LastVehDesc = ""
                LastSpeed = 0
                LastInfo = ""
               
            end
           
            if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), RadarPos.x, RadarPos.y, RadarPos.z, true) > 100 then -- if the player is too far from his radar
           
                SetEntityAsMissionEntity(Radar, false, false)
                SetEntityVisible(Radar, false)
                DeleteObject(Radar) -- remove the radar pole (otherwise it leaves from inside the ground)
                DeleteEntity(Radar) -- remove the radar pole (otherwise it leaves from inside the ground)
               
                Radar = nil
                RadarPos = {}
                RadarAng = 0
                isRadarPlaced = false
               
                RemoveBlip(RadarBlip)
                RadarBlip = nil
               
                LastPlate = ""
                LastVehDesc = ""
                LastSpeed = 0
                LastInfo = ""
               
                ClearPrints()
                SetTextEntry_2("STRING")
                AddTextComponentString("~r~You've gone too far from your Radar !")
                DrawSubtitleTimed(3000, 1)
               
            end
           
        end
       
        if isRadarPlaced then
 
            local viewAngle = GetOffsetFromEntityInWorldCoords(Radar, -8.0, -4.4, 0.0) -- forwarding the camera angle, to increase or reduce the distance, just make a cross product like this one :  ( X * 11.0 ) / 20.0 = Y   gives  (Radar, X, Y, 0.0)
            local ply, veh, dist = GetClosestDrivingPlayerFromPos(20, viewAngle) -- viewAngle
 
            -- local debuginfo = string.format("%s ~n~%s ~n~%s ~n~", ply, veh, dist)
            -- drawTxt(0.27, 0.1, 0.185, 0.206, 0.40, debuginfo, 255, 255, 255, 255)
 
            if veh ~= nil then
           
                local vehPlate = GetVehicleNumberPlateText(veh) or ""
                local vehSpeedKm = GetEntitySpeed(veh)*3.6
                local vehDesc = GetDisplayNameFromVehicleModel(GetEntityModel(veh))--.." "..GetVehicleColor(veh)
                if vehDesc == "CARNOTFOUND" then vehDesc = "" end
               
                -- local vehSpeedMph= GetEntitySpeed(veh)*2.236936
                -- if vehSpeedKm > minSpeed then            
                     
                if vehSpeedKm < maxSpeed then
                    info = string.format("~b~Vehicle  ~w~ %s ~n~~b~Plate    ~w~ %s ~n~~y~Km/h        ~g~%s", vehDesc, vehPlate, math.ceil(vehSpeedKm))
                else
                    info = string.format("~b~Vehicle  ~w~ %s ~n~~b~Plate    ~w~ %s ~n~~y~Km/h        ~r~%s", vehDesc, vehPlate, math.ceil(vehSpeedKm))
                    if LastPlate ~= vehPlate then
                        LastSpeed = vehSpeedKm
                        LastVehDesc = vehDesc
                        LastPlate = vehPlate
                    elseif LastSpeed < vehSpeedKm and LastPlate == vehPlate then
                            LastSpeed = vehSpeedKm
                    end
                    LastInfo = string.format("~b~Vehicle  ~w~ %s ~n~~b~Plate    ~w~ %s ~n~~y~Km/h        ~r~%s", LastVehDesc, LastPlate, math.ceil(LastSpeed))
                end
                   
				DrawRect(0.76, 0, 0.185, 0.38, 204, 204, 204, 210)   
				   
                DrawRect(0.76, 0.0455, 0.18, 0.09, 255, 255, 255, 180)
                drawTxt(0.77, 0.1, 0.185, 0.206, 0.40, info, 255, 255, 255, 255)
               
                DrawRect(0.76, 0.140, 0.18, 0.09, 255, 255, 255, 180)
                drawTxt(0.77, 0.20, 0.185, 0.206, 0.40, LastInfo, 255, 255, 255, 255)
                 
                -- end
               
            end
           
        end
           
    end  
end)

RegisterNetEvent('st:policeradarr')
AddEventHandler('st:policeradarr', function()
    POLICE_radar()
end)

RegisterNetEvent('st:carrymenu')
AddEventHandler('st:carrymenu', function()
    TriggerEvent("rtx_carry:Carry")
end)

RegisterNetEvent('st:mechanicobject')
AddEventHandler('st:mechanicobject', function()
       local playerPed = PlayerPedId()

		if IsPedSittingInAnyVehicle(playerPed) then
			exports['dlrp-notify']:sendnotify("You Cant Use When You In Car")
			return
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_mechanic_actions_spawn', {
			title    = ('Objects'),
			align    = 'top-left',
			elements = {
				{label = ('Road Cone'), value = 'prop_roadcone02a'},
				{label = ('Tool Box'),  value = 'prop_toolchest_01'}
			}
		}, function(data2, menu2)
			local model   = data2.current.value
			local coords  = GetEntityCoords(playerPed)
			local forward = GetEntityForwardVector(playerPed)
			local x, y, z = table.unpack(coords + forward * 1.0)

			if model == 'prop_roadcone02a' then
				z = z - 2.0
			elseif model == 'prop_toolchest_01' then
				z = z - 2.0
			end

			ESX.Game.SpawnObject(model, {
				x = x,
				y = y,
				z = z
			}, function(obj)
				SetEntityHeading(obj, GetEntityHeading(playerPed))
				PlaceObjectOnGroundProperly(obj)
			end)

		end, function(data2, menu2)
			menu2.close()
		end)
end)


RegisterNetEvent('st:mechanicbil')
AddEventHandler('st:mechanicbil', function()
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
				title = ('Invoice Amount')
			}, function(data, menu)
				local amount = tonumber(data.value)

				if amount == nil or amount < 0 then
					exports['dlrp-notify']:sendnotify("Amount Invalid")
				else
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						exports['dlrp-notify']:sendnotify("No Player Near You")
					else
						menu.close()
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_mechanic', 'mechanic', amount)
					end
				end
			end, function(data, menu)
				menu.close()
			end)
end)

RegisterNetEvent('st:taxibil')
AddEventHandler('st:taxibil', function()
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
				title = ('Invoice Amount')
			}, function(data, menu)
				local amount = tonumber(data.value)

				if amount == nil or amount < 0 then
					exports['dlrp-notify']:sendnotify("Amount Invalid")
				else
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						exports['dlrp-notify']:sendnotify("No Player Near You")
					else
						menu.close()
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_taxi', 'taxi', amount)
					end
				end
			end, function(data, menu)
				menu.close()
			end)
end)

RegisterNetEvent('st:policebil')
AddEventHandler('st:policebil', function()
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
				title = ('Invoice Amount')
			}, function(data, menu)
				local amount = tonumber(data.value)

				if amount == nil or amount < 0 then
					exports['dlrp-notify']:sendnotify("Amount Invalid")
				else
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						exports['dlrp-notify']:sendnotify("No Player Near You")
					else
						menu.close()
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_police', 'police', amount)
					end
				end
			end, function(data, menu)
				menu.close()
			end)
end)

RegisterNetEvent('st:addLicense')
AddEventHandler('st:addLicense', function(target)
	local _source = source
    local distance = ESX.Game.GetClosestPlayer()
    local target, distance = ESX.Game.GetClosestPlayer()
    playerheading = GetEntityHeading(PlayerPedId())
    playerlocation = GetEntityForwardVector(PlayerPedId())
    playerCoords = GetEntityCoords(PlayerPedId())
    local target_id = GetPlayerServerId(target)
    print(distance)
    if distance <= 2.0 then
        if distance == -1 then
            exports['mythic_notify']:DoHudText('error', 'There no one near you to give license', 4000)
        else
            TriggerServerEvent('esx_policejob:addLicense', target_id, playerheading, playerCoords, playerlocation)
        end
    else
        exports['mythic_notify']:DoHudText('error', 'There no one near you to give license', 4000)
    end
end)

RegisterNetEvent('st:removeLicense')
AddEventHandler('st:removeLicense', function(target)
	local _source = source
    local distance = ESX.Game.GetClosestPlayer()
    local target, distance = ESX.Game.GetClosestPlayer()
    playerheading = GetEntityHeading(PlayerPedId())
    playerlocation = GetEntityForwardVector(PlayerPedId())
    playerCoords = GetEntityCoords(PlayerPedId())
    local target_id = GetPlayerServerId(target)
    print(distance)
    if distance <= 2.0 then
        if distance == -1 then
            exports['mythic_notify']:DoHudText('error', 'There no one near you to remove license', 4000)
        else
            TriggerServerEvent('esx_policejob:removeLicense', target_id, playerheading, playerCoords, playerlocation)
        end
    else
        exports['mythic_notify']:DoHudText('error', 'There no one near you to remove license', 4000)
    end
end)

RegisterNetEvent('st:removeLicense2')
AddEventHandler('st:removeLicense2', function(target)
	local _source = source
    local distance = ESX.Game.GetClosestPlayer()
    local target, distance = ESX.Game.GetClosestPlayer()
    playerheading = GetEntityHeading(PlayerPedId())
    playerlocation = GetEntityForwardVector(PlayerPedId())
    playerCoords = GetEntityCoords(PlayerPedId())
    local target_id = GetPlayerServerId(target)
    print(distance)
    if distance <= 2.0 then
        if distance == -1 then
            exports['mythic_notify']:DoHudText('error', 'There no one near you to remove license', 4000)
        else
            TriggerServerEvent('esx_policejob:removeLicense2', target_id, playerheading, playerCoords, playerlocation)
        end
    else
        exports['mythic_notify']:DoHudText('error', 'There no one near you to remove license', 4000)
    end
end)

RegisterNetEvent('st:handcuff');
AddEventHandler('st:handcuff', function()
    local target, distance = ESX.Game.GetClosestPlayer()
    playerheading = GetEntityHeading(PlayerPedId())
    playerlocation = GetEntityForwardVector(PlayerPedId())
    playerCoords = GetEntityCoords(PlayerPedId())
    local target_id = GetPlayerServerId(target)
    print(distance)
    if distance <= 2.0 then
        if distance == -1 then
            exports['mythic_notify']:DoHudText('error', 'There no one near you to handcuff', 4000)
        else
            TriggerServerEvent('esx_policejob:requestarrest', target_id, playerheading, playerCoords, playerlocation)
        end
    else
        exports['mythic_notify']:DoHudText('error', 'There no one near you to handcuff', 4000)
    end
end)
RegisterNetEvent('st:checkGSR');
AddEventHandler('st:checkGSR', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    local closestPlayerPed = GetPlayerPed(closestPlayer)
    if closestDistance <= 2.0 then
        TriggerServerEvent('GSR:Status2', GetPlayerServerId(closestPlayer))
    end
end)

RegisterNetEvent('zar:at');
AddEventHandler('zar:at', function(source, args, rawCommand) 
    local number = 0
    number = math.random(1,12)
     

    loadAnimDict("anim@mp_player_intcelebrationmale@wank")
    TaskPlayAnim(PlayerPedId(), "anim@mp_player_intcelebrationmale@wank", "wank", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
    Citizen.Wait(1500)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent('3dme:shareDisplay', 'Dice Rolled: ' .. number)
end)

RegisterNetEvent('polis:tablet');
AddEventHandler('polis:tablet', function(one,two,three)
	ESX.TriggerServerCallback("jsfour-mdc:getName",function(n,s)
		if n == "not police" then return end
		open = true
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = "open",
			firstname = n,
			lastname = s
		})
	end)
end,false)

RegisterNetEvent('st:aramayap')
AddEventHandler('st:aramayap', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	if closestPlayer ~= -1 and closestDistance <= 3.0 then
		TriggerServerEvent('esx_policejob:message', GetPlayerServerId(closestPlayer), 'Looking for superior!')
		TriggerEvent("m3:inventoryhud:client:openPlayerInventory", GetPlayerServerId(closestPlayer), "police")
    else
        exports['mythic_notify']:SendAlert('error', 'No players nearby!')
    end
end)

RegisterNetEvent('anim:iptal');
AddEventHandler('anim:iptal', function()
	ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('yavuz:hastane');
AddEventHandler('yavuz:hastane', function()
	SetNewWaypoint(296.23, -583.84, 43.14)
	PlaySoundFrontend(-1, "WAYPOINT_SET", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0)
end)
RegisterNetEvent('yavuz:karakol');
AddEventHandler('yavuz:karakol', function()
	SetNewWaypoint(408.18, -986.66, 29.27)
	PlaySoundFrontend(-1, "WAYPOINT_SET", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0)
end)
RegisterNetEvent('yavuz:galeri');
AddEventHandler('yavuz:galeri', function()
	SetNewWaypoint(-53.71, -1111.87, 26.44)
	PlaySoundFrontend(-1, "WAYPOINT_SET", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0)
end)
RegisterNetEvent('yavuz:ehliyet');
AddEventHandler('yavuz:ehliyet', function()
	SetNewWaypoint(219.15, -1412.64, 29.29)
	PlaySoundFrontend(-1, "WAYPOINT_SET", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0)
end)
RegisterNetEvent('yavuz:iskur');
AddEventHandler('yavuz:iskur', function()
	SetNewWaypoint(-234.72, -986.03, 29.18)
	PlaySoundFrontend(-1, "WAYPOINT_SET", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0)
end)
RegisterNetEvent('yavuz:motel');
AddEventHandler('yavuz:motel', function()
	SetNewWaypoint(314.68, -246.51, 53.98)
	PlaySoundFrontend(-1, "WAYPOINT_SET", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0)
end)

RegisterNetEvent('st:uncuff');
AddEventHandler('st:uncuff', function()
    local target, distance = ESX.Game.GetClosestPlayer()
    playerheading = GetEntityHeading(PlayerPedId())
    playerlocation = GetEntityForwardVector(PlayerPedId())
    playerCoords = GetEntityCoords(PlayerPedId())
    local target_id = GetPlayerServerId(target)
    print(distance)
    if distance <= 2.0 then
        if distance == -1 then
            exports['mythic_notify']:DoHudText('error', 'There no one near you to handcuff', 4000)
        else
            TriggerServerEvent('esx_policejob:requestrelease', target_id, playerheading, playerCoords, playerlocation)
        end
    else
        exports['mythic_notify']:DoHudText('error', 'There no one near you to handcuff', 4000)
    end
end)

RegisterNetEvent('idcard:open')
AddEventHandler('idcard:open', function( data, type )

    TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
end)

-- RegisterNetEvent('idcard:ver')
-- AddEventHandler('idcard:ver', function( data, type )
--  local player, distance = ESX.Game.GetClosestPlayer()
--  if distance ~= -1 and distance <= 3.0 then
--     if showID ~= nil then
--     TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player))
--     end
--     else
--     ESX.ShowNotification('No Players Nearby!')
--     end
-- end, false)

RegisterNetEvent('ehliyet:gor')
AddEventHandler('ehliyet:gor', function( data, type )
    TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
end)

RegisterNetEvent('ehliyet:ver')
AddEventHandler('ehliyet:ver', function( data, type )
  local player, distance = ESX.Game.GetClosestPlayer()
  if distance ~= -1 and distance <= 3.0 then
    if showDriver ~= nil then
    TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player), 'driver')
    end
    else
    ESX.ShowNotification('No Players Nearby!')
    end
end, false)


RegisterNetEvent('st:escort');
AddEventHandler('st:escort', function()
    ExecuteCommand('drag')
end)
RegisterNetEvent('st:putinvehicle');
AddEventHandler('st:putinvehicle', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    local closestPlayerPed = GetPlayerPed(closestPlayer)
    if closestDistance <= 2.0 then
        TriggerServerEvent('esx_policejob:putInVehicle', GetPlayerServerId(closestPlayer))
    end
end)
RegisterNetEvent('st:spawnstr');
AddEventHandler('st:spawnstr', function()
    TriggerEvent("vrp_for_medic:stretcher:spawn", player)
end)
RegisterNetEvent('st:removestr');
AddEventHandler('st:removestr', function()
    TriggerEvent("vrp_for_medic:stretcher:delete", player)
end)
RegisterNetEvent('st:spawnwheel');
AddEventHandler('st:spawnwheel', function()
    TriggerEvent("vrp_for_medic:wheelchair:spawn",player)
end)
RegisterNetEvent('st:removewheel');
AddEventHandler('st:removewheel', function()
    TriggerEvent("vrp_for_medic:wheelchair:delete",player)
end)
RegisterNetEvent('st:takeoutvehicle');
AddEventHandler('st:takeoutvehicle', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    local closestPlayerPed = GetPlayerPed(closestPlayer)
    if closestDistance <= 2.0 then
        TriggerServerEvent('esx_policejob:OutVehicle', GetPlayerServerId(closestPlayer))
    end
end)
RegisterNetEvent('st:putv');
AddEventHandler('st:putv', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    local closestPlayerPed = GetPlayerPed(closestPlayer)
    if closestDistance <= 2.0 then
        TriggerServerEvent('disc-ambulancejob:putInVehicle', GetPlayerServerId(closestPlayer))
    end
end)
RegisterNetEvent('st:outv');
AddEventHandler('st:outv', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    local closestPlayerPed = GetPlayerPed(closestPlayer)
    if closestDistance <= 2.0 then
        TriggerServerEvent('esx_policejob:OutVehicle', GetPlayerServerId(closestPlayer))
    end
end)
RegisterNetEvent('st:pdrevive');
AddEventHandler('st:pdrevive', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    local closestPlayerPed = GetPlayerPed(closestPlayer)
    local health = GetEntityHealth(closestPlayerPed)
    if health == 0 then
        local playerPed = PlayerPedId()
        Citizen.CreateThread(function()
        TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
        Wait(5000)
        ClearPedTasks(playerPed)
            if GetEntityHealth(closestPlayerPed) == 0 then
                TriggerServerEvent('disc-ambulancejob:revive', GetPlayerServerId(closestPlayer))--('esx_policejob:revive')
            else
          --      exports['mythic_notify']:DoHudText('error', 'Yakında ölü biri yok', 4000)
            end
        end)
    end
end)
RegisterNetEvent('st:getid');
AddEventHandler('st:getid', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    local closestPlayerPed = GetPlayerPed(closestPlayer)
    if closestDistance <= 2.0 then
        OpenIdentityCardMenu(closestPlayer)
    end
end)
RegisterNetEvent('st:menuimpound');
AddEventHandler('st:menuimpound', function()
    local playerPed = PlayerPedId()

			if IsPedSittingInAnyVehicle(playerPed) then
				local vehicle = GetVehiclePedIsIn(playerPed, false)

				if GetPedInVehicleSeat(vehicle, -1) == playerPed then
					--ESX.ShowNotification(_U('vehicle_impounded'))
					exports['mythic_notify']:SendAlert('inform', 'Vehicle impounded')
					ESX.Game.DeleteVehicle(vehicle)
					--TriggerServerEvent('cylex:AddInLog', "mechanic", "del_vehicle", GetPlayerName(PlayerId()))
				else
					--ESX.ShowNotification(_U('must_seat_driver'))
					exports['mythic_notify']:SendAlert('error', 'You must be in the driver seat to do this')
				end
			else
				local vehicle = ESX.Game.GetVehicleInDirection()

				if DoesEntityExist(vehicle) then
					--ESX.ShowNotification(_U('vehicle_impounded'))
					exports['mythic_notify']:SendAlert('inform', 'Vehicle impounded')
					ESX.Game.DeleteVehicle(vehicle)
					--TriggerServerEvent('cylex:AddInLog', "mechanic", "del_vehicle", GetPlayerName(PlayerId()))
				else
					--ESX.ShowNotification(_U('must_near'))
					exports['mythic_notify']:SendAlert('error', 'You need to be near the vehicle')
				end
			end
end)
RegisterNetEvent('st:open');
AddEventHandler('st:open', function()
    local playerPed = PlayerPedId()
    local coords  = GetEntityCoords(playerPed)
    local vehicle = ESX.Game.GetVehicleInDirection()
    if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)
        exports['mythic_progbar']:Progress({
            name = "mpaçma",
            duration = 10000,
            label = 'Vehicle Opens...',
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            },
        }, function(cancelled)
            if not cancelled then
                DeleteObject(prop)
                prop = nil
                IsAnimated = false
            end
        end)
        Citizen.Wait(10000)
        ClearPedTasksImmediately(playerPed)

        SetVehicleDoorsLocked(vehicle, 1)
        SetVehicleDoorsLockedForAllPlayers(vehicle, false)
        PlayVehicleDoorOpenSound(vehicle, 0)
        SetVehicleLights(vehicle, 2)
        Citizen.Wait(150)
        SetVehicleLights(vehicle, 0)
        exports['mythic_notify']:DoHudText('inform', 'You unlocked the vehicle', 4000)
    else
        exports['mythic_notify']:DoHudText('error', 'no cars nearby', 4000)
    end
end)
RegisterNetEvent('st:mechrepair');
AddEventHandler('st:mechrepair', function()
    local playerPed = PlayerPedId()
    local coords  = GetEntityCoords(playerPed)
    local vehicle = ESX.Game.GetVehicleInDirection()
    if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
        TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
        exports['mythic_progbar']:Progress({
            name = "mechrep",
            duration = 10000,
            label = 'You Are Repairing...',
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            },
        }, function(cancelled)
            if not cancelled then
                DeleteObject(prop)
                prop = nil
                IsAnimated = false
            end
        end)
        Citizen.Wait(10000)
        ClearPedTasksImmediately(playerPed)

        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true)
        exports['mythic_notify']:DoHudText('inform', 'You Repaired the Vehicle', 4000)
    else
        exports['mythic_notify']:DoHudText('error', 'no cars nearby', 4000)
    end
end)
RegisterNetEvent('st:mechclean');
AddEventHandler('st:mechclean', function()
    local playerPed = PlayerPedId()
    local coords  = GetEntityCoords(playerPed)
    local vehicle = ESX.Game.GetVehicleInDirection()
    if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
        TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
        exports['mythic_progbar']:Progress({
            name = "temizleme",
            duration = 10000,
            label = 'Cleaning up...',
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            },
        }, function(cancelled)
            if not cancelled then
                DeleteObject(prop)
                prop = nil
                IsAnimated = false
            end
        end)
        Citizen.Wait(10000)
        ClearPedTasksImmediately(playerPed)

        WashDecalsFromVehicle(vehicle, 1.0)
        SetVehicleDirtLevel(vehicle)
        exports['mythic_notify']:DoHudText('inform', 'You cleaned the vehicle', 4000)
    else
        exports['mythic_notify']:DoHudText('error', 'no cars nearby', 4000)
    end
end)
RegisterNetEvent('st:kamu');
AddEventHandler('st:kamu', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    local closestPlayerPed = GetPlayerPed(closestPlayer)
    if closestDistance <= 2.0 then
        SendToCommunityService(GetPlayerServerId(closestPlayer))
    end
end)

RegisterNetEvent('st:gps');
AddEventHandler('st:gps', function()
        gpsAcmaEkrani(GetPlayerServerId)
end)


RegisterNetEvent('st:rehinal');
AddEventHandler('st:rehinal', function()
    ExecuteCommand('rehinal')
end)

RegisterNetEvent('belge:menu');
AddEventHandler('belge:menu', function()
    OpenMainMenu()
end)

RegisterNetEvent('st:ceza');
AddEventHandler('st:ceza', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    local closestPlayerPed = GetPlayerPed(closestPlayer)
    if closestDistance <= 2.0 then
        OpenFineMenu(closestPlayer)
    end
end)


RegisterNetEvent('st:bag');
AddEventHandler('st:bag', function()
    local target, distance = ESX.Game.GetClosestPlayer()
    local target_id = GetPlayerServerId(target)
    if distance <= 2.0 then
        TriggerServerEvent('st:bag2', target_id)
    end
end)
RegisterNetEvent('st:bag3');
AddEventHandler('st:bag3', function(targetid)
    exports['mythic_notify']:DoHudText('inform', 'Bag Opened', 4000)
    owner = targetid
    TriggerEvent('disc-inventoryhud:openInventory', {
        type = 'canta',
        owner = owner,
        slots = 80,
    })
end)
function OpenFineMenu(player)

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine',
	{
		title    = 'Punishment',
		align    = 'top-left',
		elements = {
			{label = 'Traffic Fines', value = 0},
			{label = 'Small Warning',   value = 1},
			{label = 'Average Warning', value = 2},
			{label = 'Important Warning',   value = 3}
		}
	}, function(data, menu)
		OpenFineCategoryMenu(player, data.current.value)
	end, function(data, menu)
		menu.close()
	end)

end

function OpenFineCategoryMenu(player, category)

	ESX.TriggerServerCallback('esx_policejob:getFineList', function(fines)

		local elements = {}

		for i=1, #fines, 1 do
			table.insert(elements, {
				label     = fines[i].label .. ' <span style="color: green;"> $' .. fines[i].amount .. '</span>',
				value     = fines[i].id,
				amount    = fines[i].amount,
				fineLabel = fines[i].label
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine_category',
		{
			title    = 'Punishment',
			align    = 'top-left',
			elements = elements,
		}, function(data, menu)

			local label  = data.current.fineLabel
			local amount = data.current.amount

			menu.close()

            TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_police', label, amount)

			ESX.SetTimeout(300, function()
				OpenFineCategoryMenu(player, category)
			end)

		end, function(data, menu)
			menu.close()
		end)

	end, category)

end

function OpenMainMenu()
    ClearMenu()
    Menu.addButton(_U('public_documents'), "OpenNewPublicFormMenu", nil)
    Menu.addButton(_U('job_documents'), "OpenNewJobFormMenu", nil)
    Menu.addButton(_U('saved_documents'), "OpenMyDocumentsMenu", nil)
    Menu.addButton(_U('close_bt'), "CloseMenu", nil)
    Menu.hidden = false
end

function SendToCommunityService(player)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'Community Service Menu', {
		title = "Community Service Menu",
	}, function (data2, menu)
		local community_services_count = tonumber(data2.value)
		
		if community_services_count == nil then
			ESX.ShowNotification('Invalid services count.')
		else
			TriggerServerEvent("esx_communityservice:sendToCommunityService", player, community_services_count)
			menu.close()
		end
	end, function (data2, menu)
		menu.close()
	end)
end

function gpsAcmaEkrani(player)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'Community Service Menu', {
        title = "Community Service Menu",
    }, function (data2, menu)
        local community_services_count = tonumber(data2.value)
        
        if community_services_count == nil then
            ESX.ShowNotification('Invalid services count.')
        else
            TriggerServerEvent("esx_communityservice:sendToCommunityService", player, community_services_count)
            menu.close()
        end
    end, function (data2, menu)
        menu.close()
    end)
end

function gpsAcmaEkrani()
    ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'jail_choose_time_menu',
        {
            title = "Enter your radio code:"
        },
    function(data2, menu2)
        TriggerServerEvent('esx_policejob:telsizKodu',data2.value)
        menu2.close()
    end, function(data2, menu2)
        menu2.close()
    end)
end

function takeHostage()
	ClearPedSecondaryTask(PlayerPedId())
	DetachEntity(PlayerPedId(), true, false)
	for i=1, #hostageAllowedWeapons do
		if HasPedGotWeapon(PlayerPedId(), GetHashKey(hostageAllowedWeapons[i]), false) then
			if GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(hostageAllowedWeapons[i])) > 0 then
				canTakeHostage = true 
				foundWeapon = GetHashKey(hostageAllowedWeapons[i])
				break
			end 					
		end
	end

	if not canTakeHostage then 
		drawNativeNotification("You're not going to take hostage by beating? :)")
		exports['mythic_notify']:DoHudText('type', 'Youre not going to take hostage by beating? :)')
	end

	if not holdingHostageInProgress and canTakeHostage then		
		local player = PlayerPedId()	
		--lib = 'misssagrab_inoffice'
		--anim1 = 'hostage_loop'
		--lib2 = 'misssagrab_inoffice'
		--anim2 = 'hostage_loop_mrk'
		lib = 'anim@gangops@hostage@'
		anim1 = 'perp_idle'
		lib2 = 'anim@gangops@hostage@'
		anim2 = 'victim_idle'
		distans = 0.11 --Higher = closer to camera
		distans2 = -0.24 --higher = left
		height = 0.0
		spin = 0.0		
		length = 100000
		controlFlagMe = 49
		controlFlagTarget = 49
		animFlagTarget = 50
		attachFlag = true 
		local closestPlayer = GetClosestPlayer(2)
		target = GetPlayerServerId(closestPlayer)
		if closestPlayer ~= nil then
			SetCurrentPedWeapon(PlayerPedId(), foundWeapon, true)
			holdingHostageInProgress = true
			holdingHostage = true 
			--print("triggering cmg3_animations:sync")
			TriggerServerEvent('cmg3_animations:sync', closestPlayer, lib,lib2, anim1, anim2, distans, distans2, height,target,length,spin,controlFlagMe,controlFlagTarget,animFlagTarget,attachFlag)
		else
			--print("[CMG Anim] No player nearby")
			drawNativeNotification("No one nearby to take as hostage!")
			exports['mythic_notify']:DoHudText('type', 'No one to be held hostage!')
		end 
	end
	canTakeHostage = false 
end  

function ustArama()
    ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'jail_choose_time_menu',
        {
            title = "Enter your radio code:"
        },
    function(data2, menu2)
        TriggerServerEvent('esx_policejob:telsizKodu',data2.value)
        menu2.close()
    end, function(data2, menu2)
        menu2.close()
    end)
end


function OpenIdentityCardMenu(player)

	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)

		local elements    = {}
		local nameLabel   = 'FirstName: ' .. data.name
		local jobLabel    = nil
		local sexLabel    = nil
		local dobLabel    = nil
		local heightLabel = nil
		local idLabel     = nil
	
		if data.job.grade_label ~= nil and  data.job.grade_label ~= '' then
			jobLabel = 'Job: ' .. data.job.label .. ' - ' .. data.job.grade_label
		else
			jobLabel = 'Job: ' .. data.job.label
		end
	
			nameLabel = 'FirstName: ' .. data.firstname .. ' ' .. data.lastname
	
			if data.sex ~= nil then
				if string.lower(data.sex) == 'm' then
					sexLabel = 'Male'
				else
					sexLabel = 'Woman'
				end
			else
				sexLabel = 'Unknown'
			end
	
			if data.dob ~= nil then
				dobLabel = 'Date of birth: ' .. data.dob
			else
				dobLabel = 'Date of birth: Unknown'
			end
	
			if data.height ~= nil then
				heightLabel = 'Height: ' .. data.height
			else
				heightLabel = 'Height: Unknown'
			end
	
			if data.name ~= nil then
				idLabel = 'ID: ' .. data.name
			else
				idLabel = 'ID: Unknown'
			end
	
		local elements = {
			{label = nameLabel, value = nil},
			{label = jobLabel,  value = nil},
		}
	
			table.insert(elements, {label = sexLabel, value = nil})
			table.insert(elements, {label = dobLabel, value = nil})
			table.insert(elements, {label = heightLabel, value = nil})
			table.insert(elements, {label = idLabel, value = nil})
	
		if data.drunk ~= nil then
			table.insert(elements, {label = _U('bac', data.drunk), value = nil})
		end
	
		if data.licenses ~= nil then
	
			table.insert(elements, {label = 'License Name:', value = nil})
	
			for i=1, #data.licenses, 1 do
				table.insert(elements, {label = data.licenses[i].label, value = nil})
			end
	
		end
	
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction',
		{
			title    = 'Citizen Interaction',
			align    = 'top-left',
			elements = elements,
		}, function(data, menu)
	
		end, function(data, menu)
			menu.close()
		end)
	
	end, GetPlayerServerId(player))

end
------------- BLİP --------------

RegisterNetEvent("yg_blip:rest")
AddEventHandler("yg_blip:rest", function()
	TriggerEvent("turn:blip", 6)
end)

RegisterNetEvent("yg_blip:gas")
AddEventHandler("yg_blip:gas", function()
	TriggerEvent("turn:blip", 12)
end)

RegisterNetEvent("yg_blip:hotel")
AddEventHandler("yg_blip:hotel", function()
	TriggerEvent("turn:blip", 13)
end)

RegisterNetEvent("yg_blip:tatto")
AddEventHandler("yg_blip:tatto", function()
	TriggerEvent("turn:blip", 4)
end)

RegisterNetEvent("yg_blip:bank")
AddEventHandler("yg_blip:bank", function()
	TriggerEvent("turn:blip", 11)
end)

RegisterNetEvent("yg_blip:company")
AddEventHandler("yg_blip:company", function()
	TriggerEvent("turn:blip", 9)
end)

RegisterNetEvent("yg_blip:mechanic")
AddEventHandler("yg_blip:mechanic", function()
	TriggerEvent("turn:blip", 10)
end)

RegisterNetEvent("yg_blip:jobs")
AddEventHandler("yg_blip:jobs", function()
	TriggerEvent("turn:blip", 7)
end)

RegisterNetEvent("yg_blip:gas")
AddEventHandler("yg_blip:gas", function()
	TriggerEvent("turn:blip", 6)
end)

RegisterNetEvent("yg_blip:market")
AddEventHandler("yg_blip:market", function()
	TriggerEvent("turn:blip", 1)
end)

RegisterNetEvent("yg_blip:garages")
AddEventHandler("yg_blip:garages", function()
	TriggerEvent("turn:blip", 2)
end)

RegisterNetEvent("yg_blip:kiyafet")
AddEventHandler("yg_blip:kiyafet", function()
	TriggerEvent("turn:blip", 5)
end)

RegisterNetEvent("yg_blip:barbershop")
AddEventHandler("yg_blip:barbershop", function()
	TriggerEvent("turn:blip", 3)
end)

RegisterNetEvent('carcontrol:open')
AddEventHandler('carcontrol:open', function()
    local ped = PlayerPedId()    
    local inVeh = IsPedInAnyVehicle(ped,false)    
    if inVeh then       
        local veh = GetVehiclePedIsIn(ped)      
        if lastVeh and lastData and veh == lastVeh then        
            ctrl.display(lastData)      
        else       
            lastData = nil       
            ctrl.display()     
        end     
        lastVeh = veh   
    end 
end) 

--DOKTOR--
RegisterNetEvent('st:emsRevive');
AddEventHandler('st:emsRevive', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer == -1 or closestDistance > 1.0 then
        exports['mythic_notify']:SendAlert('error', 'No players nearby', 4000)
    else
        ESX.TriggerServerCallback('disc-ambulancejob:getItemAmount', function(quantity)
            if quantity > 0 then
                local closestPlayerPed = GetPlayerPed(closestPlayer)

                if GetEntityHealth(playerPed) <= 0 then
                    local playerPed = PlayerPedId()


                    local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'

                    for i=1, 15, 1 do
                        Citizen.Wait(900)
                
                        ESX.Streaming.RequestAnimDict(lib, function()
                            TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
                        end)
                    end

                    TriggerServerEvent('disc-ambulancejob:removeItem', 'medikit')
                    TriggerServerEvent('disc-ambulancejob:revive', GetPlayerServerId(closestPlayer))
                else
                    exports['mythic_notify']:SendAlert('error', 'Person has no critical condition', 4000)
                end
            else
                exports['mythic_notify']:SendAlert('error', 'You dont have a first aid kit', 4000)
            end

        end, 'medikit')
    end
end)
RegisterNetEvent('st:emssmallheal');
AddEventHandler('st:emssmallheal', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer == -1 or closestDistance > 1.0 then
        exports['mythic_notify']:DoHudText('error', 'No players nearby', 4000)
    else
        ESX.TriggerServerCallback('disc-ambulancejob:getItemAmount', function(quantity)
            if quantity > 0 then
                local closestPlayerPed = GetPlayerPed(closestPlayer)
                local health = GetEntityHealth(closestPlayerPed)

                if health > 0 then
                    local playerPed = PlayerPedId()

                    TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                    Citizen.Wait(10000)
                    ClearPedTasks(playerPed)

                    TriggerServerEvent('disc-ambulancejob:removeItem', 'bandage')
                    TriggerServerEvent('disc-ambulancejob:heal', GetPlayerServerId(closestPlayer), 'small')
                else
                    exports['mythic_notify']:DoHudText('error', 'The person has no plight', 4000)
                end
            else
                exports['mythic_notify']:DoHudText('error', 'You dont have a bandage', 4000)
            end
        end, 'bandage')
    end
end)
RegisterNetEvent('st:emsbigheal');
AddEventHandler('st:emsbigheal', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer == -1 or closestDistance > 1.0 then
        exports['mythic_notify']:DoHudText('error', 'No players nearby', 4000)
    else
        ESX.TriggerServerCallback('disc-ambulancejob:getItemAmount', function(quantity)
            if quantity > 0 then
                local closestPlayerPed = GetPlayerPed(closestPlayer)
                local health = GetEntityHealth(closestPlayerPed)

                if health > 0 then
                    local playerPed = PlayerPedId()

                    IsBusy = true
                    TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                    Citizen.Wait(10000)
                    ClearPedTasks(playerPed)

                    TriggerServerEvent('disc-ambulancejob:removeItem', 'medikit')
                    TriggerServerEvent('disc-ambulancejob:heal', GetPlayerServerId(closestPlayer), 'big')
                    IsBusy = false
                else
                    exports['mythic_notify']:DoHudText('error', 'The person has no plight', 4000)
                end
            else
                exports['mythic_notify']:DoHudText('error', 'You dont have a medit', 4000)
            end
        end, 'medikit')
    end
end)



RegisterNetEvent('ls-radio:use')
AddEventHandler('ls-radio:use', function()
    --Polis Telsiz Menusu
end)

RegisterNetEvent('polis:doctor')
AddEventHandler('polis:doctor', function()
    local closestPlayerPed = GetPlayerPed(closestPlayer)
    TriggerServerEvent('disc-ambulancejob:revive', GetPlayerServerId(closestPlayer))
end)



--[[
RegisterServerEvent('telsiz:kodu')
AddEventHandler('telsiz:kodu', function( data, type )
    function TelsizKoduSor()
    ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'jail_choose_time_menu',
        {
            title = "Telsiz kodunuzu belirtiniz:"
        },
    function(data2, menu2)
        TriggerServerEvent('esx_policejob:telsizKodu',data2.value)
        menu2.close()
    end, function(data2, menu2)
        menu2.close()
    end)
end
    -- body
end)   ]]