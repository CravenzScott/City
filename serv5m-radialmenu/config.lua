ESX = nil
Citizen.CreateThread(function()
    while true do
        Wait(5)
        if ESX ~= nil then
       
        else
            ESX = nil
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        end
    end
end)

SX = {}
SX.Cloth = true -- 
SX.K9Enable = true -- 
SX.IDCard = true -- 

local isJudge = false
local isPolice = false
local isMedic = false
local isDoctor = false
local isNews = false
local isInstructorMode = false
local myJob = "unemployed"
local isHandcuffed = false
local isHandcuffedAndWalking = false
local hasOxygenTankOn = false
local gangNum = 0
local cuffStates = {}
 
rootMenuConfig =  {
    {
        id = "general",
        displayName = "General",
        icon = "#globe-europe",
        enableMenu = function()
         
            return not fuck
        end,
           --   subMenus = {"general:flipvehicle","general:checkoverself","general:checktargetstates","general:emotes","general:zarat","general:anahtar","general:tasi","belgeler:belgemenu"}
              subMenus = {"general:flipvehicle", "general:bugreport", "general:emotes", "general:anahtar", "general:atm", "general:scoreboard", "general:news", "general:stretcher", "general:plateremove", "general:platestick", "general:notepad", "general:calc", "serv5m:PersonMenu", "general:sexanim"}
    },
    {
        id = "rob",
        displayName = "Player Rob",
        icon = "#animation-shady",
        enableMenu = function()
         
            return not fuck
        end,
           --   subMenus = {"general:flipvehicle","general:checkoverself","general:checktargetstates","general:emotes","general:zarat","general:anahtar","general:tasi","belgeler:belgemenu"}
              subMenus = {"rob:cuff"}
    },
    {
        id = "house",
        displayName = "House",
        icon = "#otel",
        enableMenu = function()
         
            return not fuck
        end,
           --   subMenus = {"general:flipvehicle","general:checkoverself","general:checktargetstates","general:emotes","general:zarat","general:anahtar","general:tasi","belgeler:belgemenu"}
              subMenus = {"house:stashhouse", "house:houseclothes", "house:enter", "house:raid", "house:setroomate"}
    },
    --[[{
        id = "vehicle",
        displayName = "Tool Menu",
        icon = "#vehicle-options-vehicle",
        functionName = "vehicle:menu",
        enableMenu = function()
            return (not isDead and IsPedInAnyVehicle(PlayerPedId(), false))
        end
    },]]
    -- {
    --     id = "vehicle",
    --     displayName = "Vehicle",
    --     icon = "#vehicle-options-vehicle",
    --     functionName = "carcontrol:open",
    --     enableMenu = function()
         
    --         if not fuck and IsPedInAnyVehicle(PlayerPedId(), false) then
    --             return true
    --         end
    --     end,
    -- }, 
    {
        id = "animiptal",
        displayName = "Animation Cancel",
        icon = "#iptal",
        functionName = "anim:iptal",
        enableMenu = function()
        return not fuck
        end,
    },
    {
        id = "clothe",
        displayName = "Clothes",
        icon = "#giyim",
        enableMenu = function() return true end,
        functionName = 'kiyafet:menu'
    },	
    {
        id = "blips",
        displayName = "GPS",
        icon = "#blips",
        enableMenu = function()
            return not isDead
        end,
        subMenus = {"blips:barbershop","blips:hotel","blips:tattooshop","blips:market","blips:kiyafet","blips:jobs","blips:garages","blips:company","blips:bank","blips:gas", "blips:restaurnt", "blips:jobss", "blips:mechanic"}
    },
    {
        id = "isaret",
        displayName = "Mark",
        icon = "#isaret",
        enableMenu = function()
         
            return not fuck
        end,
        subMenus = {"isaret:karakol","isaret:hastane","isaret:ehliyet","isaret:iskur","isaret:motel","isaret:galeri"}
    },
    -- {
    --     id = "belgeler",
    --     displayName = "Belgeler",
    --     icon = "#belgeler",
    --     enableMenu = function()
         
    --         return not fuck
    --     end,
    --     subMenus = {"belgeler:kimlik","belgeler:kimlikver","belgeler:ehliyet","belgeler:ehliyetver","belgeler:belgemenu"}
    -- },
    {
        id = "police-action",
        displayName = "Police Actions",
        icon = "#police-action",
        enableMenu = function()
           local ped = PlayerPedId()
           PlayerData = ESX.GetPlayerData()
            
            if PlayerData.job.name == "police" or PlayerData.job.name == "sheriff" and not fuck then
                return true
            end
        end,
        subMenus = {"cuffs:cuff", "cuffs:uncuff", "police:escort", "police:putinvehicle", "police:unseatnearest", "police:active", "police:frisk",  "police:addlicense", "police:removelicense2", "police:policebil", "police:policeradarr", "police:removelicense","police:gsr", "police:impound","police:open","police:community","police:fine","police:ustarama","police:radar"}
    },
    {
        id = "taxi",
        displayName = "Taxi Actions",
        icon = "#police-action",
        enableMenu = function()
           local ped = PlayerPedId()
           PlayerData = ESX.GetPlayerData()
            
            if PlayerData.job.name == "taxi" and not fuck then
                return true
            end
        end,
        subMenus = {"taxi:billig", "taxi:startnpc", "taxi:taximeter"}
    },
    {
        id = "policeDead",
        displayName = "10-13",
        icon = "#police-dead",
        functionName = "st:panicTrigger",
        enableMenu = function()
        local ped = PlayerPedId()
           PlayerData = ESX.GetPlayerData()
            
            if PlayerData.job.name == "police" or PlayerData.job.name == "sheriff" and fuck then
                return true
            end
        end,
    },
    {
        id = "emsDead",
        displayName = "10-14",
        icon = "#ems-dead",
        functionName = "st:panicTriggerMedic",
        enableMenu = function()
        local ped = PlayerPedId()
           PlayerData = ESX.GetPlayerData()
            
            if PlayerData.job.name == "ambulance" and fuck then
                return true
            end
        end,
    },
    {
        id = "expressions",
        displayName = "Expressions",
        icon = "#expressions",
        enableMenu = function()
         
            return not fuck
        end,
        subMenus = { "expressions:normal", "expressions:drunk", "expressions:angry", "expressions:dumb", "expressions:electrocuted", "expressions:grumpy", "expressions:happy", "expressions:injured", "expressions:joyful", "expressions:mouthbreather", "expressions:oneeye", "expressions:shocked", "expressions:sleeping", "expressions:smug", "expressions:speculative", "expressions:stressed", "expressions:sulking", "expressions:weird", "expressions:weird2"}
    },
    {
        id = "judge-raid",
        displayName = "Judge Raid",
        icon = "#judge-raid",
        enableMenu = function()
            return (not isDead and isJudge)
        end,
        subMenus = { "judge-raid:checkowner", "judge-raid:seizeall", "judge-raid:takecash", "judge-raid:takedm"}
    },
    {
        id = "judge-licenses",
        displayName = "Judge Licenses",
        icon = "#judge-licenses",
        enableMenu = function()
            return (not isDead and isJudge)
        end,
        subMenus = { "police:checklicenses", "judge:grantDriver", "judge:grantBusiness", "judge:grantWeapon", "judge:grantHouse", "judge:grantBar", "judge:grantDA", "judge:removeDriver", "judge:removeBusiness", "judge:removeWeapon", "judge:removeHouse", "judge:removeBar", "judge:removeDA", "judge:denyWeapon", "judge:denyDriver", "judge:denyBusiness", "judge:denyHouse" }
    },
    {
        id = "k9",
        displayName = "K9 Dog",
        icon = "#k9",
        enableMenu = function()
        local ped = PlayerPedId()
           PlayerData = ESX.GetPlayerData()
           fuck = isDead
            if SX.K9Enable and PlayerData.job.name == "police" and not fuck then
                return true
            end
        end,
        subMenus = {"k9:spawn", "k9:follow", "k9:vehicle", "k9:sniffvehicle", "k9:sit", "k9:stand", "k9:sniff", "k9:lay" }
    },
--[[     {
        id = "judge-actions",
        displayName = "Judge Actions",
        icon = "#judge-actions",
        enableMenu = function()
            return (not isDead and isJudge)
        end,
        subMenus = { "police:cuff", "cuffs:uncuff", "general:escort", "police:frisk", "cuffs:checkinventory", "police:checkbank"}
    }, ]]
    {
        id = "judge-actions",
        displayName = "Mechanical Actions",
        icon = "#police-vehicle",
        enableMenu = function()
            local ped = PlayerPedId()
           PlayerData = ESX.GetPlayerData()
            
            if PlayerData.job.name == "mechanic" and not fuck then
                return true
            end
        end,
        subMenus = { "mechanic:hijack", "mechanic:repair", "mechanic:clean", "mechanic:impound", "mechanic:billing", "mechanic:object"}
    },
    {
        id = "medic",
        displayName = "Doctor",
        icon = "#medic",
        enableMenu = function()
        local ped = PlayerPedId()
           PlayerData = ESX.GetPlayerData()
            
            if PlayerData.job.name == "ambulance" and not fuck then
                return true
            end
        end,
        subMenus = {"medic:revive", "medic:heal", "medic:bigheal", "medic:out", "medic:put" , "medic:spawnstr", "medic:removestr", "medic:spawnwheel", "medic:removewheel"}
    },
    {
        id = "doctor",
        displayName = "Doctor",
        icon = "#doctor",
        enableMenu = function()
            return (not isDead and isDoctor)
        end,
        subMenus = { "general:escort", "medic:revive", "general:checktargetstates", "medic:heal"}
    },
    {
        id = "news",
        displayName = "News",
        icon = "#news",
        enableMenu = function()
        local ped = PlayerPedId()
           PlayerData = ESX.GetPlayerData()
            
            if PlayerData.job.name == "weazelnews" and fuck then
                return true
            end
        end,
        subMenus = { "news:setCamera", "news:setMicrophone", "news:setBoom" }
    },
     
    {
        id = "impound",
        displayName = "Impound Vehicle",
        icon = "#impound-vehicle",
        functionName = "impoundVehicle",
        enableMenu = function()
         
            if not fuck and myJob == "towtruck" and #(GetEntityCoords(PlayerPedId()) - vector3(549.47796630859, -55.197559356689, 71.069190979004)) < 10.599 then
                return true
            end
            return false
        end
    }, {
        id = "oxygentank",
        displayName = "Remove Oxygen Tank",
        icon = "#oxygen-mask",
        functionName = "RemoveOxyTank",
        enableMenu = function()
         
            return not fuck and hasOxygenTankOn
        end
    }, {
        id = "cocaine-status",
        displayName = "Request Status",
        icon = "#cocaine-status",
        functionName = "cocaine:currentStatusServer",
        enableMenu = function()
         
            if not fuck and gangNum == 2 and #(GetEntityCoords(PlayerPedId()) - vector3(1087.3937988281,-3194.2138671875,-38.993473052979)) < 0.5 then
                return true
            end
            return false
        end
    }, {
        id = "cocaine-crate",
        displayName = "Remove Crate",
        icon = "#cocaine-crate",
        functionName = "cocaine:methCrate",
        enableMenu = function()
         
            if not fuck and gangNum == 2 and #(GetEntityCoords(PlayerPedId()) - vector3(1087.3937988281,-3194.2138671875,-38.993473052979)) < 0.5 then
                return true
            end
            return false
        end
    }
}

newSubMenus = {
    ['general:emotes'] = {
        title = "Animation Menu",
        icon = "#general-emotes",
        functionName = "dp:RecieveMenu"
    },
    ['general:atm'] = {
        title = "ATM",
        icon = "#police-vehicle-plate",
        functionName = "yow_banking:ATMCheck"
    },
    ['general:scoreboard'] = {
        title = "Scoreboard",
        icon = "#iptal",
        functionName = "st:display"
    },
    ['general:news'] = {
        title = "News",
        icon = "#news",
        functionName = "NewsStandCheck"
    },
    ['general:stretcher'] = {
        title = "Stretcher Lay",
        icon = "#k9-lay",
        functionName = "st:stretcher"
    },
    ['general:plateremove'] = {
        title = "Plate Remove",
        icon = "#drivinginstructor-submittest",
        functionName = "st:plateremove"
    },
    ['general:platestick'] = {
        title = "Plate Stick",
        icon = "#belgekle",
        functionName = "st:platestick"
    },
    ['general:notepad'] = {
        title = "Notepad",
        icon = "#notepad",
        functionName = "Notepad:open"
    },
    ['house:stashhouse'] = {
        title = "Stash Hotel",
        icon = "#judge-licenses-grant-bar",
        functionName = "st:housestash"
    },
    ['house:houseclothes'] = {
        title = "Clothes Hotel",
        icon = "#giyim",
        functionName = "st:houseclothes"
    },
    ['house:enter'] = {
        title = "Enter House",
        icon = "#enterhouse",
        functionName = "st:enterhouse"
    },
    ['house:raid'] = {
        title = "Raid House",
        icon = "#judge-raid-seize-all",
        functionName = "st:raidh"
    },
    ['house:setroomate'] = {
        title = "Set Roommate",
        icon = "#setroom",
        functionName = "st:setroom"
    },
    ['general:calc'] = {
        title = "Calculator",
        icon = "#mdt",
        functionName = "st:calc"
    },
    ['general:sexanim'] = {
        title = "Sex Animation",
        icon = "#judge-raid-seize-all",
        functionName = "serv5m-erp:openMenu"
    },
    ['arac:kontrol'] = {
        title = "Vehicle Control",
        icon = "#ayarlar",
        functionName = "carcontrol:open"
    },
    ['general:animiptal'] = {
        title = "Animation Cancel",
        icon = "#iptal",
        functionName = "anim:iptal"
    },
    ['general:simmenu'] = {
        title = "Sim Menu",
        icon = "#sim",
        functionName = "esx_cartesim:OpenSim"
    },
    ['general:staminabilgi'] = {
        title = "Endurance Scholar",
        icon = "#bilgi",
        functionName = "stamina:goster"
    },
    ['general:bilgi'] = {
        title = "Information",
        icon = "#anahtar",
        functionName = "parana:bak"
    },
    ['taxi:billig'] = {
        title = "Billing",
        icon = "#billing",
        functionName = "st:taxibil"
    },
    ['taxi:startnpc'] = {
        title = "Start NPC",
        icon = "#blips-jobs",
        functionName = "st:taxinpc"
    },
    ['taxi:taximeter'] = {
        title = "Taxi Meter",
        icon = "#blips-jobs",
        functionName = "st:taximeter"
    },
    ['rob:cuff'] = {
        title = "Rob Player",
        icon = "#cuffs",
        functionName = "police:client:RobPlayer"
    },
    --[[['rob:liftup'] = {
        title = "Lift Up",
        icon = "#general-escort",
        functionName = "st:liftup"
    },]]
    ['rob:carrymenu'] = {
        title = "Carry Menu",
        icon = "#general-escort",
        functionName = "st:carrymenu"
    },
    ['giyim:ustcikart'] = {
        title = "Üstünü Çıkart",
        icon = "#giyim",
        functionName = "cikra:ust"
    },
    ['giyim:altcikart'] = {
        title = "Take Off Pants",
        icon = "#asagi",
        functionName = "cikra:alt"
    },
    ['giyim:ayakcikart'] = {
        title = "Take Off Shoes",
        icon = "#ayak",
        functionName = "cikra:ayak"
    },
    ['giyim:giyin'] = {
        title = "Get dressed",
        icon = "#giyin",
        functionName = "cikra:ma"
    },
    ['giyim:gozluk'] = {
        title = "Remove/Wear Glasses",
        icon = "#gozluk",
        functionName = "gozluk:giyin"
    },
    ['giyim:maske'] = {
        title = "Remove/Wear Mask",
        icon = "#maske",
        functionName = "maske:giyin"
    },
    ['giyim:sapka'] = {
        title = "Remove/Wear Hats",
        icon = "#sapka",
        functionName = "sapka:giyin"
    },
    ['blips:bank'] = {
        title = "Banks",
        icon = "#blips-bank",
        functionName = "yg_blip:bank"
    },
    ['blips:mechanic'] = {
        title = "Mechanic",
        icon = "#police-vehicle",
        functionName = "yg_blip:mechanic"
    },
    ['blips:barbershop'] = {
        title = "Barber",
        icon = "#blips-barbershop",
        functionName = "yg_blip:barbershop"
    },
    ['blips:restaurnt'] = {
        title = "Restaurants",
        icon = "#blips-rest",
        functionName = "yg_blip:rest"
    },
    ['blips:jobss'] = {
        title = "Jobs",
        icon = "#blips-jobs",
        functionName = "yg_blip:jobs"
    },
    ['blips:hotel'] = {
        title = "Hotel",
        icon = "#otel",
        functionName = "yg_blip:hotel"
    },
    ['blips:market'] = {
        title = "Market",
        icon = "#blips-market",
        functionName = "yg_blip:market"
    },
    ['blips:kiyafet'] = {
        title = "Clotheshop",
        icon = "#expressions",
        functionName = "yg_blip:kiyafet"
    },    		
    ['blips:tattooshop'] = {
        title = "Tattoo",
        icon = "#blips-tattooshop",
        functionName = "yg_blip:tatto"
    },
    ['blips:company'] = { 
        title = "Company",
        icon = "#blips-trainstations",
        functionName = "yg_blip:company"
    },
    ['blips:gas'] = { 
        title = "Gas Station",
        icon = "#benzin",
        functionName = "yg_blip:gas"
    },
    ['blips:bank'] = {
        title = "Banks",
        icon = "#blips-bank",
        functionName = "yg_blip:bank"
    },
    ['isaret:hastane'] = {
        title = "Mark Hospital",
        icon = "#hastane",
        functionName = "yavuz:hastane"
    },
    ['isaret:karakol'] = {
        title = "Mark Outpost",
        icon = "#police-action",
        functionName = "yavuz:karakol"
    },
    ['isaret:galeri'] = {
        title = "Mark Gallery",
        icon = "#car",
        functionName = "yavuz:galeri"
    },
    ['isaret:motel'] = {
        title = "Mark Motel",
        icon = "#otel",
        functionName = "yavuz:motel"
    },
    
    ['general:bag'] = {
        title = "Tablet",
        icon = "#judge-licenses-grant-business",
        functionName = "yordi:tablet"
    }, 

    ['belgeler:kimlik'] = {
        title = "See ID",
        icon = "#kimlik",
        functionName = "idcard:open"
    },
    ['belgeler:kimlikver'] = {
        title = "Give ID",
        icon = "#kimlik",
        functionName = "idcard:ver"
    }, 
    ['general:mario'] = {
        title = "Mario Head Quiz",
        icon = "#kimlik",
        functionName = "mario:kafa"
    }, 
    ['belgeler:ehliyet'] = {
        title = "See Driver License",
        icon = "#ehliyet",
        functionName = "ehliyet:gor" 
    }, 
    ['belgeler:ehliyetver'] = {
        title = "Give Driver License",
        icon = "#ehliyet",
        functionName = "ehliyet:ver"
    }, 
    ['belgeler:kaldir'] = {
        title = "Remove Man",
        icon = "#ehliyet",
        functionName = "adam:kaldir"
    },
    ['serv5m:PersonMenu'] = {
        title = "Move",
        icon = "#general-escort",
        functionName = "serv5m:PersonMenu"
    },
    ['general:ustarama'] = {
        title = "Top Search",
        icon = "#arama",
        functionName = "st:aramayap"
    },

    --jsfour-idcard:open
--[[     ['general:checkoverself'] = {
        title = "Examine Self",
        icon = "#general-check-over-self",
        functionName = "Evidence:CurrentDamageList"
    },
    ['general:checktargetstates'] = {
        title = "Examine Target",
        icon = "#general-check-over-target",
        functionName = "requestWounds"
    }, ]]
--[[     ['general:checkvehicle'] = {
        title = "Examine Vehicle",
        icon = "#general-check-vehicle",
        functionName = "towgarage:annoyedBouce"
    }, ]]
    ['general:putinvehicle'] = {
        title = "Seat Vehicle",
        icon = "#general-put-in-veh",
        functionName = "police:forceEnter"
    },
    ['general:unseatnearest'] = {
        title = "Unseat Nearest",
        icon = "#general-unseat-nearest",
        functionName = "unseatPlayer"
    },    
    ['general:flipvehicle'] = {
        title = "Flip Vehicle",
        icon = "#general-flip-vehicle",
        functionName = "st:rehinal"
    },
    --[[['general:statusboard'] = {
        title = "Status Board",
        icon = "#statusboard",
        functionName = "st:statusboard"
    },]]
    ['general:bugreport'] = {
        title = "Admin Report",
        icon = "#gavel",
        functionName = "st:bugreport"
    },
    ['general:zarat'] = {
        title = "roll the dice",
        icon = "#zarat",
        functionName = "zar:at"
    },
    ['animations:brave'] = {
        title = "Brave",
        icon = "#animation-brave",
        functionName = "AnimSet:Brave"
    },
    ['animations:hurry'] = {
        title = "Hurry",
        icon = "#animation-hurry",
        functionName = "AnimSet:Hurry"
    },
    ['animations:business'] = {
        title = "Business Man",
        icon = "#animation-business",
        functionName = "AnimSet:Business"
    },
    ['animations:tipsy'] = {
        title = "Tipsy",
        icon = "#animation-tipsy",
        functionName = "AnimSet:Tipsy"
    },
    ['animations:injured'] = {
        title = "Injured",
        icon = "#animation-injured",
        functionName = "AnimSet:Injured"
    },
    ['animations:tough'] = {
        title = "Tough",
        icon = "#animation-tough",
        functionName = "AnimSet:ToughGuy"
    },
    ['animations:sassy'] = {
        title = "Sassy",
        icon = "#animation-sassy",
        functionName = "AnimSet:Sassy"
    },
    ['animations:sad'] = {
        title = "Sad",
        icon = "#animation-sad",
        functionName = "AnimSet:Sad"
    },
    ['animations:posh'] = {
        title = "Luxury",
        icon = "#animation-posh",
        functionName = "AnimSet:Posh"
    },
    ['animations:alien'] = {
        title = "Alien",
        icon = "#animation-alien",
        functionName = "AnimSet:Alien"
    },
    ['animations:nonchalant'] =
    {
        title = "Coincidence",
        icon = "#animation-nonchalant",
        functionName = "AnimSet:NonChalant"
    },
    ['animations:hobo'] = {
        title = "Punk",
        icon = "#animation-hobo",
        functionName = "AnimSet:Hobo"
    },
    ['animations:money'] = {
        title = "Money",
        icon = "#animation-money",
        functionName = "AnimSet:Money"
    },
    ['animations:swagger'] = {
        title = "Feint",
        icon = "#animation-swagger",
        functionName = "AnimSet:Swagger"
    },
    ['animations:shady'] = {
        title = "Gangster",
        icon = "#animation-shady",
        functionName = "AnimSet:Shady"
    },
    ['animations:maneater'] = {
        title = "Curling",
        icon = "#animation-maneater",
        functionName = "AnimSet:ManEater"
    },
    ['animations:chichi'] = {
        title = "Showy",
        icon = "#animation-chichi",
        functionName = "AnimSet:ChiChi"
    },
    ['animations:default'] = {
        title = "Normal",
        icon = "#animation-default",
        functionName = "AnimSet:default"
    },
    ['mechanic:hijack'] = {
        title = "Open Tool",
        icon = "#tools",
        functionName = "st:open"
    },
    ['mechanic:repair'] = {
        title = "Fix it",
        icon = "#general-check-vehicle",
        functionName = "st:mechrepair"
    },
    ['mechanic:clean'] = {
        title = "Clean",
        icon = "#clean",
        functionName = "st:mechclean"
    },
    ['mechanic:impound'] = {
        title = "Impound",
        icon = "#police-vehicle",
        functionName = "st:menuimpound"
    },
    ['mechanic:billing'] = {
        title = "Billing",
        icon = "#billing",
        functionName = "st:mechanicbil"
    },
    ['mechanic:object'] = {
        title = "Object",
        icon = "#objects",
        functionName = "st:mechanicobject"
    },
    ['cuffs:cuff'] = {
        title = "HandCuff",
        icon = "#cuffs-cuff",
        functionName = "tp:handcuff"
    }, 
    ['cuffs:uncuff'] = {
        title = "Uncuff",
        icon = "#cuffs-uncuff",
        functionName = "tp:uncuff"
    },
    ['cuffs:unseat'] = {
        title = "Unseat",
        icon = "#cuffs-unseat-player",
        functionName = "disc-ambulancejob:pullOutVehicle"
    },
    ['cuffs:checkphone'] = {
        title = "Check Phone",
        icon = "#cuffs-check-phone",
        functionName = "police:checkPhone"
    },
    ['medic:revive'] = {
        title = "Revive",
        icon = "#medic-revive",
        functionName = "st:emsRevive"
    },
    ['medic:put'] = {
        title = "Put Car",
        icon = "#general-put-in-veh",
        functionName = "st:outv"
    },
    ['medic:spawnstr'] = {
        title = "Spawn Stretcher",
        icon = "#k9-lay",
        functionName = "st:spawnstr"
    },
    ['medic:removestr'] = {
        title = "Remove Stretcher",
        icon = "#asagi",
        functionName = "st:removestr"
    },
    ['medic:spawnwheel'] = {
        title = "Spawn Wheelchair",
        icon = "#k9-sit",
        functionName = "st:spawnwheel"
    },
    ['medic:removewheel'] = {
        title = "Remove Wheelchair",
        icon = "#asagi",
        functionName = "st:removewheel"
    },
    ['medic:out'] = {
        title = "Get Out Car",
        icon = "#general-unseat-nearest",
        functionName = "st:putv"
    },
    ['medic:heal'] = {
        title = "Heal",
        icon = "#medic-heal",
        functionName = "st:emssmallheal"
    },
    ['medic:bigheal'] = {
        title = "Treat Major Wounds",
        icon = "#medic-heal",
        functionName = "st:emsbigheal"
    },
    ['police:escort'] = {
        title = "Move",
        icon = "#general-escort",
        functionName = "tp:escort"
    },
    ['police:revive'] = {
        title = "Revive",
        icon = "#medic-revive",
        functionName = "st:emsRevive"
    },
    ['police:putinvehicle'] = {
        title = "Put Car",
        icon = "#general-put-in-veh",
        functionName = "st:putinvehicle"
    },
    ['police:radar'] = {
        title = "Prison Menu",
        icon = "#radar",
        functionName = "esx-qalle-jail:openJailMenu"
    },
    ['polis:faturabak'] = {
        title = "View Invoices",
        icon = "#belgeler",
        functionName = "odenmemis:fatura"
    },
    ['police:unseatnearest'] = {
        title = "Get Out Car",
        icon = "#general-unseat-nearest",
        functionName = "tp:takeoutvehicle"
    },
    ['police:impound'] = {
        title = "Impound Vehicle",
        icon = "#police-vehicle",
        functionName = "st:menuimpound"
    },
    ['police:open'] = {
        title = "Open Tool",
        icon = "#police-vehicle",
        functionName = "st:open"
    },
    ['police:community'] = {
        title = "Community Service",
        icon = "#animation-hobo",
        functionName = "st:kamu"
    },
    ['police:gps'] = {
        title = "GPS",
        icon = "#gps",
        functionName = "st:gps"
    },
    ['police:ustarama'] = {
        title = "Top Search",
        icon = "#arama",
        functionName = "st:aramayap"
    },
    ['police:fine'] = {
        title = "Fines",
        icon = "#animation-business",
        functionName = "st:ceza"
    },
    ['police:cuff'] = {
        title = "Cuff",
        icon = "#cuffs-cuff",
        functionName = "police:cuffFromMenu"
    },
    ['police:checkbank'] = {
        title = "Check Bank",
        icon = "#police-check-bank",
        functionName = "police:checkBank"
    },
    ['police:checklicenses'] = {
        title = "Check Licenses",
        icon = "#police-check-licenses",
        functionName = "police:checkLicenses"
    },
    ['police:addlicense'] = {
        title = "Check License",
        icon = "#judge-licenses-grant-drivers",
        functionName = "police:checkLicenses"
    },
    ['police:removelicense'] = {
        title = "Remove DMV License",
        icon = "#judge-licenses-remove-drivers",
        functionName = "st:removeLicense"
    }, 	
    ['police:removelicense2'] = {
        title = "Remove Weapon License",
        icon = "#judge-licenses-remove-weapon",
        functionName = "st:removeLicense2"
    },
    ['police:policebil'] = {
        title = "Billing",
        icon = "#billing",
        functionName = "st:policebil"
    },
    ['police:policeradarr'] = {
        title = "Radar",
        icon = "#billing",
        functionName = "st:policeradarr"
    },
    ['police:gsr'] = {
        title = "Powder Test",
        icon = "#police-action-gsr",
        functionName = "st:checkGSR"
    },
    ['police:getid'] = {
        title = "Credentials",
        icon = "#police-vehicle-plate",
        functionName = "st:getid"
    },
--[[     ['police:toggleradar'] = {
        title = "Toggle Radar",
        icon = "#police-vehicle-radar",
        functionName = "startSpeedo"
    }, ]]
    ['police:frisk'] = {
        title = "Frisk",
        icon = "#police-action-frisk",
        functionName = "qb-inventory:policesearch"
    },
    ['police:active'] = {
        title = "Active Pannel",
        icon = "#bookmark",
        functionName = "st:policeac"
    },
    ['k9:spawn'] = {
        title = "Spawn",
        icon = "#k9-spawn",
        functionName = "k9:summon"
    },
    ['k9:delete'] = {
        title = "Delete",
        icon = "#k9-dismiss",
        functionName = "k9:dismiss"
    },
    ['k9:follow'] = {
        title = "Follow",
        icon = "#k9-follow2",
        functionName = "K9:ToggleFollow"
    },
    ['k9:vehicle'] = {
        title = "Get in the Vehicle",
        icon = "#k9-vehicle",
        functionName = "k9:vehicletoggle"
    },
    ['k9:sit'] = {
        title = "Sit",
        icon = "#k9-sit",
        functionName = "k9:sit"
    },
    ['k9:lay'] = {
        title = "Lay",
        icon = "#k9-lay",
        functionName = "k9:lay"
    },
    ['k9:stand'] = {
        title = "Stand",
        icon = "#k9-stand",
        functionName = "k9:stand"
    },
    ['k9:sniff'] = {
        title = "Search Contact",
        icon = "#k9-sniff",
        functionName = "k9:searchplayer"
    },
    ['k9:sniffvehicle'] = {
        title = "Search Vehicle",
        icon = "#k9-sniff-vehicle",
        functionName = "k9:vehiclesearch"
    },
    ['k9:huntfind'] = {
        title = "Attack Nearby",
        icon = "#k9-huntfind",
        functionName = "k9:attack"
    },
    ['judge:grantDriver'] = {
        title = "Grant Drivers",
        icon = "#judge-licenses-grant-drivers",
        functionName = "police:grantDriver"
    }, 
    ['judge:grantBusiness'] = {
        title = "Grant Business",
        icon = "#judge-licenses-grant-business",
        functionName = "police:grantBusiness"
    },  
    ['judge:grantWeapon'] = {
        title = "Grant Weapon",
        icon = "#judge-licenses-grant-weapon",
        functionName = "police:grantWeapon"
    },
    ['judge:grantHouse'] = {
        title = "Grant House",
        icon = "#judge-licenses-grant-house",
        functionName = "police:grantHouse"
    },
    ['judge:grantBar'] = {
        title = "Grant BAR",
        icon = "#judge-licenses-grant-bar",
        functionName = "police:grantBar"
    },
    ['judge:grantDA'] = {
        title = "Grant DA",
        icon = "#judge-licenses-grant-da",
        functionName = "police:grantDA"
    },
    ['judge:removeDriver'] = {
        title = "Remove Drivers",
        icon = "#judge-licenses-remove-drivers",
        functionName = "police:removeDriver"
    },
    ['judge:removeBusiness'] = {
        title = "Remove Business",
        icon = "#judge-licenses-remove-business",
        functionName = "police:removeBusiness"
    },
    ['judge:removeWeapon'] = {
        title = "Remove Weapon",
        icon = "#judge-licenses-remove-weapon",
        functionName = "police:removeWeapon"
    },
    ['judge:removeHouse'] = {
        title = "Remove House",
        icon = "#judge-licenses-remove-house",
        functionName = "police:removeHouse"
    },
    ['judge:removeBar'] = {
        title = "Remove BAR",
        icon = "#judge-licenses-remove-bar",
        functionName = "police:removeBar"
    },
    ['judge:removeDA'] = {
        title = "Remove DA",
        icon = "#judge-licenses-remove-da",
        functionName = "police:removeDA"
    },
    ['judge:denyWeapon'] = {
        title = "Deny Weapon",
        icon = "#judge-licenses-deny-weapon",
        functionName = "police:denyWeapon"
    },
    ['judge:denyDriver'] = {
        title = "Deny Drivers",
        icon = "#judge-licenses-deny-drivers",
        functionName = "police:denyDriver"
    },
    ['judge:denyBusiness'] = {
        title = "Deny Business",
        icon = "#judge-licenses-deny-business",
        functionName = "police:denyBusiness"
    },
    ['judge:denyHouse'] = {
        title = "Deny House",
        icon = "#judge-licenses-deny-house",
        functionName = "police:denyHouse"
    },
    ['news:setCamera'] = {
        title = "Camera",
        icon = "#news-job-news-camera",
        functionName = "camera:setCamera"
    },
    ['news:setMicrophone'] = {
        title = "Microphone",
        icon = "#news-job-news-microphone",
        functionName = "camera:setMic"
    },
    ['news:setBoom'] = {
        title = "Microphone Boom",
        icon = "#news-job-news-boom",
        functionName = "camera:setBoom"
    },
    ['weed:currentStatusServer'] = {
        title = "Request Status",
        icon = "#weed-cultivation-request-status",
        functionName = "weed:currentStatusServer"
    },   
    ['weed:weedCrate'] = {
        title = "Remove A Crate",
        icon = "#weed-cultivation-remove-a-crate",
        functionName = "weed:weedCrate"
    },
    ['cocaine:currentStatusServer'] = {
        title = "Request Status",
        icon = "#meth-manufacturing-request-status",
        functionName = "cocaine:currentStatusServer"
    },
    ['cocaine:methCrate'] = {
        title = "Remove A Crate",
        icon = "#meth-manufacturing-remove-a-crate",
        functionName = "cocaine:methCrate"
    },
    ["expressions:angry"] = {
        title="Angry",
        icon="#expressions-angry",
        functionName = "expressions",
        functionParameters =  { "mood_angry_1" }
    },
    ["expressions:drunk"] = {
        title="Drunk",
        icon="#expressions-drunk",
        functionName = "expressions",
        functionParameters =  { "mood_drunk_1" }
    },
    ["expressions:dumb"] = {
        title="Stupid",
        icon="#expressions-dumb",
        functionName = "expressions",
        functionParameters =  { "pose_injured_1" }
    },
    ["expressions:electrocuted"] = {
        title="Electrified",
        icon="#expressions-electrocuted",
        functionName = "expressions",
        functionParameters =  { "electrocuted_1" }
    },
    ["expressions:grumpy"] = {
        title="Grumpy",
        icon="#expressions-grumpy",
        functionName = "expressions", 
        functionParameters =  { "mood_drivefast_1" }
    },
    ["expressions:happy"] = {
        title="Happy",
        icon="#expressions-happy",
        functionName = "expressions",
        functionParameters =  { "mood_happy_1" }
    },
    ["expressions:injured"] = {
        title="Injured",
        icon="#expressions-injured",
        functionName = "expressions",
        functionParameters =  { "mood_injured_1" }
    },
    ["expressions:joyful"] = {
        title="Funny",
        icon="#expressions-joyful",
        functionName = "expressions",
        functionParameters =  { "mood_dancing_low_1" }
    },
    ["expressions:mouthbreather"] = {
        title="Mouth Breathing",
        icon="#expressions-mouthbreather",
        functionName = "expressions",
        functionParameters = { "smoking_hold_1" }
    },
    ["expressions:normal"]  = {
        title="Normal",
        icon="#expressions-normal",
        functionName = "expressions:clear"
    },
    ["expressions:oneeye"]  = {
        title="One eye",
        icon="#expressions-oneeye",
        functionName = "expressions",
        functionParameters = { "pose_aiming_1" }
    },
    ["expressions:shocked"]  = {
        title="Shocked",
        icon="#expressions-shocked",
        functionName = "expressions",
        functionParameters = { "shocked_1" }
    },
    ["expressions:sleeping"]  = {
        title="Sleeping",
        icon="#expressions-sleeping",
        functionName = "expressions",
        functionParameters = { "dead_1" }
    },
    ["expressions:smug"]  = {
        title="Smug",
        icon="#expressions-smug",
        functionName = "expressions",
        functionParameters = { "mood_smug_1" }
    },
    ["expressions:speculative"]  = {
        title="Speculative",
        icon="#expressions-speculative",
        functionName = "expressions",
        functionParameters = { "mood_aiming_1" }
    },
    ["expressions:stressed"]  = {
        title="Stress",
        icon="#expressions-stressed",
        functionName = "expressions",
        functionParameters = { "mood_stressed_1" }
    },
    ["expressions:sulking"]  = {
        title="Sulking",
        icon="#expressions-sulking",
        functionName = "expressions",
        functionParameters = { "mood_sulk_1" },
    },
    ["expressions:weird"]  = {
        title="Weird",
        icon="#expressions-weird",
        functionName = "expressions",
        functionParameters = { "effort_2" }
    },
    ["expressions:weird2"]  = {
        title="Weird 2",
        icon="#expressions-weird2",
        functionName = "expressions",
        functionParameters = { "effort_3" }
    }
}

RegisterNetEvent("menu:setCuffState")
AddEventHandler("menu:setCuffState", function(pTargetId, pState)
    cuffStates[pTargetId] = pState
end)

RegisterNetEvent('kiyafet:menu')
AddEventHandler('kiyafet:menu', function()
    ExecuteCommand('km')
end)


RegisterNetEvent("isJudge")
AddEventHandler("isJudge", function()
    isJudge = true
end)

RegisterNetEvent("isJudgeOff")
AddEventHandler("isJudgeOff", function()
    isJudge = false
end)

RegisterNetEvent('pd:deathcheck')
AddEventHandler('pd:deathcheck', function()
    if not isDead then
        isDead = true
    else
        isDead = false
    end
end)

RegisterNetEvent("drivingInstructor:instructorToggle")
AddEventHandler("drivingInstructor:instructorToggle", function(mode)
    if myJob == "driving instructor" then
        isInstructorMode = mode
    end
end)

RegisterNetEvent("police:currentHandCuffedState")
AddEventHandler("police:currentHandCuffedState", function(pIsHandcuffed, pIsHandcuffedAndWalking)
    isHandcuffedAndWalking = pIsHandcuffedAndWalking
    isHandcuffed = pIsHandcuffed
end)

RegisterNetEvent("menu:hasOxygenTank")
AddEventHandler("menu:hasOxygenTank", function(pHasOxygenTank)
    hasOxygenTankOn = pHasOxygenTank
end)

RegisterNetEvent('enablegangmember')
AddEventHandler('enablegangmember', function(pGangNum)
    gangNum = pGangNum
end)

function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            players[#players+1]= i
        end
    end

    return players
end

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local closestPed = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        for index,value in ipairs(players) do
            local target = GetPlayerPed(value)
            if(target ~= ply) then
                local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
                local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
                if(closestDistance == -1 or closestDistance > distance) and not IsPedInAnyVehicle(target, false) then
                    closestPlayer = value
                    closestPed = target
                    closestDistance = distance
                end
            end
        end
        return closestPlayer, closestDistance, closestPed
    end
end
