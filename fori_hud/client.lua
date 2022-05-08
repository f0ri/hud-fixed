ESX = nil
local directions = { [0] = 'N', [45] = 'NW', [90] = 'W', [135] = 'SW', [180] = 'S', [225] = 'SE', [270] = 'E', [315] = 'NE', [360] = 'N', } 

CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)

Citizen.CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, true)
	SetRadarZoom(1200)
    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
		SetRadarBigmapEnabled(false, true)
		SetRadarZoom(1200)
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

CreateThread(function()
    while true do
        Wait(400)
        local state = NetworkIsPlayerTalking(PlayerId())
        local mode = Player(GetPlayerServerId(PlayerId())).state.proximity.mode
        SendNUIMessage({
            type = 'UPDATE_VOICE',
            isTalking = state,
            mode = mode
        })
    end
end)



local hash1, hash2;
CreateThread(function() 
    while true do
        Wait(500)
        local ped, direction = PlayerPedId(), nil
        for k, v in pairs(directions) do
            direction = GetEntityHeading(ped)
            if math.abs(direction - k) < 22.5 then
                direction = v
                break
            end
        end
        local coords = GetEntityCoords(ped, true)
        local zone = GetNameOfZone(coords.x, coords.y, coords.z)
        local zoneLabel = GetLabelText(zone)
        local var1, var2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
        hash1 = GetStreetNameFromHashKey(var1);
		hash2 = GetStreetNameFromHashKey(var2);
        local street2;
        if (hash2 == '') then
			street2 = zoneLabel;
		else
			street2 = hash2..', '..zoneLabel;
		end
		--[[local blip = GetFirstBlipInfoId(8)
        local distance = 0
		local ghahahah = 0
        if (blip ~= 0) then
			local coord = GetBlipCoords(blip)
			ghahahah = CalculateTravelDistanceBetweenPoints(GetEntityCoords(Citizen.InvokeNative(0x43A66C31C68491C0,-1)), coord)
                    
			if blip ~= 0 then
				if ghahahah ~= 0 then
					distance = ghahahah
				else
					distance = 0
				end
			end
		end]]
        SendNUIMessage({
            street = street2,
			direction = (direction or 'N'),
			direction2 = direction .. ' | ' .. street2,
			--waypoint = distance,
        })   
    end    
end)

CreateThread(function()
    while true do
        Wait(1000)
        TriggerEvent('esx_status:getStatus', 'hunger', function(status)
            hunger = status.getPercent()
        end)
        TriggerEvent('esx_status:getStatus', 'thirst', function(status)
            thirst = status.getPercent()
        end)
        local armor = GetPedArmour(PlayerPedId())
        local hp = GetEntityHealth(PlayerPedId()) - 100
		local nurkowanie = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
		--local inwater = IsPedSwimmingUnderWater(PlayerPedId()),
        SendNUIMessage({
            type = 'UPDATE_HUD',
			hunger = hunger,
			thirst = thirst,
            armor = armor,
            nurkowanie = nurkowanie,
            --inwater = inwater,
            zycie = hp,
            isdead = hp <= 0
        })
    end
end)

CreateThread(function() 
    while true do
        Wait(180000)
        TriggerEvent('esx_status:getStatus', 'hunger', function(status)
            hunger = status.getPercent()
        end)
        TriggerEvent('esx_status:getStatus', 'thirst', function(status)
            thirst = status.getPercent()
        end)
        if hunger < 20 and thirst < 20 then
            ESX.ShowNotification("~r~Zostało Ci poniżej 20% jedzenia i picia!")
        elseif hunger < 20 then
            ESX.ShowNotification("~r~Zostało Ci poniżej 20% jedzenia!")
        elseif thirst < 20 then
            ESX.ShowNotification("~r~Zostało Ci poniżej 20% picia!")
        end    
    end    
end)



CreateThread(function()
    while true do 
        Wait(5000)
        local idpedala = GetPlayerServerId(PlayerId())
        SendNUIMessage({
            type = 'UPDATE_ID',
			id = idpedala
        })
    end
end)

RegisterNetEvent("hud:Speedo", function(b) 
    SendNUIMessage({
        type = "HIDE_SPEDDO",
        bool = b
    })
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	for k,v in pairs(ESX.PlayerData.slots) do
		local found = false
		
		for k2,v2 in pairs(ESX.PlayerData.loadout) do	
			if k == v2.id then
				found = true
				if v.slot then
					count = v.count and 'x' .. v.count
			
					SendNUIMessage({
						action = 'updateSlot',
						item = v.name,
						count = count,
						slot = v.slot
					})
				end						
			end
		end
		for k3,v3 in pairs(ESX.PlayerData.inventory) do	
			if v3.count > 0 then
				if k == v3.name then
					found = true
					if v.slot then
						count = v.count and 'x' .. v.count
				
						SendNUIMessage({
							action = 'updateSlot',
							item = v.name,
							count = count,
							slot = v.slot
						})
					end							
				end
			end
		end

		if not found then
			ESX.SetSlot(k, nil, true)
		end
    end
end)
	
RegisterNetEvent('hud:updateSlot')
AddEventHandler('hud:updateSlot', function(slot, count, item)
    count = count and 'x' .. count
    
    SendNUIMessage({
        action = 'updateSlot',
        item = item,
        count = count,
        slot = slot
    })
end)
    
function ToggleSlots()
    if not ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
        SendNUIMessage({action = 'toggleslots'})
    end
end

RegisterCommand("+toggleslots", ToggleSlots)
RegisterKeyMapping("+toggleslots", "Przełączanie widoczności slotów", "keyboard", "TAB") 

RegisterCommand("off", function(source, args, raw)
	ESX.DisplaySlots(false)
end)



RegisterCommand("hud", function(source, args, raw)
	SendNUIMessage({ action = 'show_hud' })
	SetNuiFocus(true, true)
end)

RegisterNUICallback("stopedit", function()
	SetNuiFocus(false, false)

end)








CreateThread(function()
    while true do
        Wait(0)
        if IsPedInAnyVehicle(PlayerPedId()) and not IsPauseMenuActive() then
            Wait(75)
            local PedCar = GetVehiclePedIsUsing(PlayerPedId(), false)
            carSpeed = math.floor(GetEntitySpeed(PedCar) * 2.2369)
            carMaxSpeed = math.ceil(GetVehicleEstimatedMaxSpeed(PedCar) * 2.2369 + 0.5)
            carSpeedPercent = carSpeed / carMaxSpeed * 100
            rpm = GetVehicleCurrentRpm(PedCar) * 100

            local eHealth = GetVehicleEngineHealth(PedCar)
            SendNUIMessage({
                speedometer = true,
                speed = carSpeed,
                percent = carSpeedPercent,
                tachometer = true,
                rpmx = rpm,
                eHealth = eHealth
            })
        else
            Citizen.Wait(500)
        end 
    end
end)

CreateThread(function()
    while true do
            Wait(450)
            if IsPedInAnyVehicle(PlayerPedId()) and not IsPauseMenuActive() then
                local PedCar = GetVehiclePedIsUsing(PlayerPedId(), false)
                local coords = GetEntityCoords(PlayerPedId())

                local _,b,c = GetVehicleLightsState(PedCar)

                SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0) -- Level 0
                SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0) -- Level 1
                SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0) -- Level 2
                SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0) -- Level 3
                SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0) -- Level 4

                --  Show hud
                SendNUIMessage({
                    showhud = true,
                    stylex = 'classic',
                    showCompass = 'on',
                    lights = 1+b+c,
			 seatbelt = exports['bc_pasy']:seatbeltState()
                })
            else
                SendNUIMessage({
                    showhud = false
                })
                Wait(2000)
            end   
    end
end)











local table_elements = {
    HUD_VEHICLE_NAME = { id = 6, hidden = true },
    HUD_AREA_NAME = { id = 7, hidden = true },
    HUD_VEHICLE_CLASS = { id = 8, hidden = true },
    HUD_STREET_NAME = { id = 9, hidden = true }
}

function round(num, dec)
    local mult = 10^(dec or 0)
    return math.floor(num * mult + 0.5) / mult
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		for k, v in pairs(table_elements) do
			HideHudComponentThisFrame(v.id)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		local Ped = GetPlayerPed(-1)

		if(IsPedInAnyVehicle(Ped)) then
			local vehicle = GetVehiclePedIsIn(Ped, false)
			local playerCar = GetVehiclePedIsIn(playerPed, false)
			if vehicle then
				local speed = (GetEntitySpeed(vehicle))
				local speed_show = math.ceil(speed * 3.6)
				local rpm_show = GetVehicleCurrentRpm(vehicle)
				if rpm_show > 0.99 then
					rpm_show = rpm_show*100
					rpm_show = rpm_show+math.random(-2,2)
					rpm_show = rpm_show/100
				end
				if rpm_show < 0.25 then
					rpm_show = rpm_show*100
					rpm_show = rpm_show+math.random(-1,1)
					rpm_show = rpm_show/100
				end

				if IsVehicleEngineOn(vehicle) then
					if rpm_show*10000 > 1000 then
						rpm_show = (rpm_show*10000)-1000
					end
				end

				rpm_bar = rpm_show/51.5

				local pos = GetEntityCoords(PlayerPedId())
				local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
				local current_zone = GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z))

				for k,v in pairs(directions)do
					direction = GetEntityHeading(PlayerPedId())
					if(math.abs(direction - k) < 22.5)then
						direction = v
						break
					end
				end

				if GetStreetNameFromHashKey(var2) ~= '' then
					streetlabeltosend = GetStreetNameFromHashKey(var1)..', '..GetStreetNameFromHashKey(var2)
				else
					streetlabeltosend = GetStreetNameFromHashKey(var1)
				end

				local blip = GetFirstBlipInfoId(8)
                local distance = 0
				local ghahahah = 0
                if (blip ~= 0) then
                    local coord = GetBlipCoords(blip)
                    ghahahah = CalculateTravelDistanceBetweenPoints(GetEntityCoords(Citizen.InvokeNative(0x43A66C31C68491C0,-1)), coord)
                    
                    if blip ~= 0 then
                        if ghahahah ~= 0 then
                            distance = ghahahah
                        else
                            distance = 0
                        end
                    end
                end

				if (IsPedInAnyVehicle(Ped)) then
					SendNUIMessage({
						typeSH = 'ui',
						status = true,
						type = 'speedometer_send',
						speed = speed_show,
						rpm = round(rpm_show, 0),
						rpmBar = round(rpm_bar, 1),
						waypoint = distance,
						dirtext = direction,
						zonecur = current_zone,
						streetlabel = streetlabeltosend,
						x = direction .. ' | ' .. streetlabeltosend,
						belts = exports['bc_pasy']:seatbeltState(),
					})
				else
					SendNUIMessage({action = "toggle", show = false})
				end
			else
				SendNUIMessage({
					typeSH = 'ui',
					status = false
				})
			end
		else
			SendNUIMessage({
				typeSH = 'ui',
				status = false
			})
		end

		Citizen.Wait(200)
	end
end)

RegisterNetEvent('gg_cluster:toggleHud')
AddEventHandler('gg_cluster:toggleHud', function(toggle)
	hudShow = toggle
	if toggle then
		forceDisable = false
		--SendNUIMessage({action = "toggle", show = true})
	else
		forceDisable = true
		--SendNUIMessage({action = "toggle", show = false})
	end
end)








RegisterCommand("fixcursor", function(src,args,raw) 
    SetNuiFocus(false, false)
end)

RegisterNUICallback("NUIFocusOff", function(data,cb) 
    SetNuiFocus(false, false)
    cb({})
end)
