/*
	Copyright (c) 2021 Team Tidal

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/

include( "shared.lua" )

local oldorigin

local oldfov

local disabledHuds = {
    "CHudHealth",
    "CHudBattery",
    "CHudAmmo",
    "CHudCrosshair"
}

local buffer = 0

local debounce = false

local reversed = false

local controller = {
    Enabled = false
}



local zoom = false

local sensitivity = 0.25

local mouseCursor = {
    texture = surface.GetTextureID( "sprites/hud/v_crosshair1" ),
    color   = Color( 255, 255, 255, 255 ),
    x 	= ScrW()/2,
    y 	= ScrH()/2,
    w 	= 48,
    h 	= 48
}

hook.Add( "HUDPaint", "SplitBullet.Client.HUDPaint", function()
    local ply = LocalPlayer()
    if !ply:Alive() or ply:Health() <= 0 then
        return draw.DrawText("you are dead", "DermaDefault", 25, 25)
    end
    ply:DrawViewModel(zoom)
    local wep = ply:GetActiveWeapon() 
    local ammotext = ""
    if IsValid(wep) then
        if !string.find(wep:GetHoldType(),"melee") then
            local clip = wep:Clip1()
            local maxclip = wep:GetMaxClip1()
            local count = ply:GetAmmoCount(wep:GetPrimaryAmmoType())
            if clip < 0 then
                clip = 0
            end
            if clip == 0 and maxclip <= -1 and count > 0 then
                clip = 1
            end
            ammotext = "\nammo: "..clip.."/"..count
        end
    end

    draw.DrawText("health: "..ply:Health().."/"..ply:GetMaxHealth().."\narmor: "..ply:Armor().."/"..ply:GetMaxArmor()..ammotext, "DermaDefault", 25, 25)

    local mouseShadow = table.Copy(mouseCursor)
    mouseShadow.color = Color(0,0,0,128)
    mouseShadow.x = mouseCursor.x+2
    mouseShadow.y = mouseCursor.y+2
    if !zoom then --and !controller then
        draw.TexturedQuad( mouseShadow )
        draw.TexturedQuad( mouseCursor )
    end
end )

hook.Add("PreDrawEffects", "SplitBullet.Client.PreDrawEffects", function()
    local ply = LocalPlayer()
    if !ply:Alive() or ply:Health() <= 0 then
        return
    end
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) then --and !zoom then
        if !string.find(wep:GetHoldType(),"melee") then
            local aim = ply:GetEyeTrace().HitPos --gui.ScreenToVector(mouseCursor.x, mouseCursor.y) -- ply:GetEyeTrace().HitPos
            local bone = wep:LookupAttachment("muzzle")
            if wep:GetAttachment(bone) ~= nil and !string.find(wep:GetHoldType(),"physgun") then
                local start = wep:GetAttachment(bone).Pos
                if start == ply:GetPos() then
                    start = ply:GetBoneMatrix(bone):GetTranslation()
                end
                --start.z = start.z+25  
                --render.DrawLine(start, aim, Color(0, 255, 255), false)
                render.SetMaterial(Material("sprites/light_ignorez"))
                render.DrawSprite( aim, 16, 16, Color(0, 255, 255))
            end
        end
    end
end)

hook.Add("RenderScene", "SplitBullet.Client.RenderScene", function()
    if !zoom then
        RenderSuperDoF( oldorigin, Angle( 0, 90, 0 ), oldfov)
    end
end)

hook.Add("CalcView", "SplitBullet.Client.CalcView", function(player, origin, angles, fov)
    if zoom then return end
    oldfov = fov

    local plyview = {}
    local trace = {}
    local orgpos = player:GetPos()
    local startpos = player:GetPos()+player:OBBCenter()
    local endpos = player:GetPos()+player:OBBCenter()

    endpos.y = endpos.y-350
    startpos.y = startpos.y-100

    trace.start = startpos
    trace.mask = MASK_SOLID_BRUSHONLY
    trace.endpos = endpos

    local result = util.TraceLine(trace)
    local back = result.HitPos.y
    local neworigin 
    if !zoom then
        neworigin = orgpos+Vector( 0, back, 50 )
    else
        neworigin = origin
    end

    if !player:Alive() and IsValid(player:GetRagdollEntity()) then
        neworigin = player:GetRagdollEntity():GetPos()+Vector( 0, back/2, 0 )
    end

    if oldorigin == nil then
        oldorigin = neworigin
    end

    oldorigin = LerpVector(FrameTime() * 5, oldorigin, neworigin)

    plyview.origin = oldorigin
    plyview.fov = 75
    if zoom then
        plyview.angles = angles
    else
        plyview.angles = Angle( 0, 90, 0 )

        if !player:Alive() then return plyview end
        local start = orgpos + player:OBBCenter()
        --start.z = start.z+25
        local aa = start:ToScreen()
        
        local angle = math.atan2(aa.y - mouseCursor.y, aa.x - mouseCursor.x) * (360 / math.pi)
        local pitch = 0
        if angle <= 180 and angle >= -180 then
            pitch = 180
            angle = angle*-1
            reversed = true
        else
            reversed = false
        end
        player:SetEyeAngles(Angle(angle,pitch,0))
    end
	return plyview
end)

hook.Add("StartCommand", "SplitBullet.Client.StartCommand", function(ply, cmd)
    if !ply:Alive() then return end
    if !zoom then
        --cmd:ClearButtons()
        local side = cmd:GetSideMove()
        if side ~= 0 then
            if reversed then
                side = side*-1
            end
            cmd:SetForwardMove(side)
            cmd:SetSideMove(0)
        end
        --if controller.Enabled then
            --look(input.GetAnalogValue(ANALOG_JOY_X), input.GetAnalogValue(ANALOG_JOY_Y))
        --else
            look(cmd:GetMouseX(), cmd:GetMouseY())
        --end
    end
end)

hook.Add("PreDrawHalos", "SplitBullet.Client.PreDrawHalos", function()
    local halotable = {}
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    if ply:IsValid() then
        if ply:Alive() then
            table.insert(halotable, ply)
            if wep:IsValid() then
                table.insert(halotable, wep)
            end
        end
    else
        halotable = {}
    end
    local pcolor = ply:GetPlayerColor()
    local actualpcolor = Color(0, 0, 0)
    actualpcolor.r = pcolor.x * 255
    actualpcolor.g = pcolor.y * 255
    actualpcolor.b = pcolor.z * 255
    halo.Add(halotable, actualpcolor)
end)

hook.Add("ShouldDrawLocalPlayer", "SplitBullet.Client.ShouldDrawLocalPlayer", function()
    return !zoom
end)

hook.Add("HUDShouldDraw", "SplitBullet.Client.HUDShouldDraw", function(name)
    return !table.HasValue(disabledHuds, name)
end)

local debounce = false

hook.Add("OnSpawnMenuOpen", "SplitBullet.Client.OnSpawnMenuOpen", function()
    LocalPlayer():ChatPrint("Splitting is currently disabled.")
    --net.Start("SplitBullet.Network.Split")
    --net.SendToServer()
end)

hook.Add("Think", "SplitBullet.Client.Think", function()
    controller.Enabled = GetConVar("joystick"):GetBool()
end)

concommand.Add("splitbullet_firstperson", function()
    zoom = fl
end, nil, "Enables firstperson", FCVAR_CHEAT)

concommand.Add("splitbullet_thirdperson", function()
    zoom = false
end, nil, "Enables thirdperson", FCVAR_CHEAT)

concommand.Add("splitbullet_toggleperson", function()
    zoom = !zoom
end, nil, "Toggles thirdperson/firstperson.", FCVAR_CHEAT)

hook.Add( "PlayerBindPress", "SplitBullet.Client.PlayerBindPress", function( ply, bind )
    if !debounce then
        if bind == "gmod_undo" then
            --zoom = !zoom
            --ply:SelectWeapon("gmod_hands")
        elseif bind == "gm_showhelp" then
            net.Start("SplitBullet.Network.Spawn")
            net.WriteString("npc_bolter")
            net.WriteVector(ply:GetEyeTrace().HitPos)
            net.SendToServer()
            debounce = true
            return true
        end
    else
        debounce = false
    end
    --[[if bind == "+lookup" then
        keeplooking(0, -10, "Up", false)
    elseif bind == "+lookdown" then
        keeplooking(0, 10, "Down", false)
    elseif bind == "+left" then
        keeplooking(-10, 0, "Left", false)
    elseif bind == "+right" then
        keeplooking(10, 0, "Right", false)
    elseif bind == "-lookup" then
        keeplooking(0, -10, "Up", true)
    elseif bind == "-lookdown" then
        keeplooking(0, 10, "Down", true)
    elseif bind == "-left" then
        keeplooking(-10, 0, "Left", true)
    elseif bind == "-right" then
        keeplooking(10, 0, "Right", true)
    end]]
end )

function keeplooking(x, y, id, stop)
    if !stop then
        if !timer.Exists("SplitBullet.Timer.Look."..id) then
            timer.Create("SplitBullet.Timer.Look."..id, 0.01, 0, function()
                look(x,y)
            end)
        end
    else
        timer.Destroy("SplitBullet.Timer.Look."..id)
    end
end

function look(x, y)
    local x = mouseCursor.x + x*sensitivity
    local y = mouseCursor.y + y*sensitivity
    if x > 0 and x < ScrW() then
        mouseCursor.x = x
    end
    if y > 0 and y < ScrH() then
        mouseCursor.y = y
    end
end


