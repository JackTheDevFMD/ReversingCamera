-- Variables
local vehicles = json.decode(LoadResourceFile(GetCurrentResourceName(), "configs/client/vehData.json")) -- DONT TOUCH
local runCheck = false
local allowed = false
local setState = "HUD_DISABLED"
local vehData = {}

-- Threads
Citizen.CreateThread(function()
    local waitDelay = 1000
    while true do
        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            local currVeh = GetVehiclePedIsIn(ped, false) 
            if GetVehicleClass(currVeh) == 18 then 
                if not runCheck then 
                    vehData, allowed = inAllowedVeh(currVeh) 
                end

                if runCheck and allowed then 
                    waitDelay = 0 
                    local currGear = GetVehicleCurrentGear(currVeh)
                    local vehStopped = IsVehicleStopped(currVeh) 

                    SetVehicleAutoRepairDisabled(currVeh, true)

                    if currGear == 0 and not vehStopped then 
                        if setState == "HUD_DISABLED" then 
                            setState = "PROCESSING" 
                            if IsVehicleExtraTurnedOn(currVeh, vehData.revHudExtra) then 
                                SetVehicleExtra(currVeh, vehData.revHudExtra, true)
                                setState = "HUD_ENABLED" 
                            end
                        end
                    else
                        if setState == "HUD_ENABLED" then 
                            if not IsVehicleExtraTurnedOn(currVeh, vehData.revHudExtra) then 
                                setState = "REMOVING" 
                                SetVehicleExtra(currVeh, vehData.revHudExtra, false) 
                                setState = "HUD_DISABLED" 
                            end
                        end
                    end
                end
            else 
                if runCheck then
                    runCheck = false
                    allowed = false
                    vehData = {}
                end

                if waitDelay < 1000 then
                    waitDelay = 1000
                end
            end
        else 
            if runCheck then
                runCheck = false
                allowed = false
                vehData = {}
            end

            if waitDelay < 1000 then
                waitDelay = 1000
            end
        end
        
        Wait(waitDelay)
    end
end)

function inAllowedVeh(vehEntity)
    for index, data in pairs(vehicles) do
        if GetHashKey(data.model) == GetEntityModel(vehEntity) then
            runCheck = true
            return data, true
        end
    end

    runCheck = true
    
    return false
end