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

--hello from kiwi-pc

AddCSLuaFile( "cl_deathnotice.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

-- CLASSES --
AddCSLuaFile( "player_class/player_uno.lua" )
AddCSLuaFile( "player_class/player_dos.lua" )

include( "shared.lua" )
include( "npc.lua" )
include( "player.lua" )

--resource.AddWorkshop("2387941394")
--resource.AddFile( "materials/splitbullet/weapons/bucketicons/glock.vmt" ) -- bucket icon for pistol

hook.Add("PlayerSpawn", "SplitBullet.Server.PlayerSpawn", function(player, transition)
    local class = player:GetNWString("SplitClass", "player_uno")
    player_manager.SetPlayerClass(player, class)
    if player.SplitPos ~= nil then
        player:SetPos(player.SplitPos)
        player:SetVelocity(player.SplitVelocity)
        player.SplitVelocity = nil
        player.SplitPos = nil
        timer.Simple(0.01, function()
            player:SetHealth(player.SplitHealth)
        end)
    end
    timer.Simple(0.1, function()
        player:SetBloodColor(DONT_BLEED)
        player:SetColor(math.random(0,255), math.random(0,255), math.random(0,255), 255)
        timer.Create("BlinkTimer_"..player:UserID(), 6, 0, function()
            local skin = player:GetSkin()
            player:SetSkin(skin+2)
            timer.Simple(0.15, function()
                player:SetSkin(skin)
            end)
        end)
    end)
    player:SetEyeAngles( Angle( 0, 90, 0 ) )
    player:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end)
    
hook.Add("PlayerDeath", "SplitBullet.Server.PlayerDeath", function(victim, inflictor, attacker)
    timer.Remove("BlinkTimer_"..victim:UserID())
end)

function split(ply)
    local health = ply:Health()
    if health > 0 then
        ply.SplitTimeout = os.time()
        local personality = ply:GetNWString("SplitClass", "player_uno")
        if personality == "player_uno" then
            ply:SetNWString("SplitClass", "player_dos")
        else
            ply:SetNWString("SplitClass", "player_uno")
        end
        ply.SplitPos = ply:GetPos()
        ply.SplitVelocity = ply:GetVelocity()
        ply.SplitHealth = health
        ply:Spawn()
    end
end

concommand.Add("splitbullet_freeme", function(ply)
    if !ply:GetNWBool("Freed",false) then
        ply:ChatPrint("You have been freed.")
        ply:SetNWBool("Freed",true)
    else
        ply:ChatPrint("You have been stuck.")
        ply:SetNWBool("Freed",false)
    end
end, nil, "FREE ME!", FCVAR_CHEAT)

hook.Add( "PlayerNoClip", "SplitBullet.Server.PlayerNoClip", function( ply, desiredNoClipState )
	return true
end )

util.AddNetworkString( "SplitBullet.Network.Split" )

net.Receive("SplitBullet.Network.Split", function( len, ply )
    if ply.SplitTimeout ~= nil then
        if ply.SplitTimeout - os.time() < -1 then
            split(ply)
        --else
            --ply:ChatPrint("Can't split yet! "..((ply.SplitTimeout - os.time())*-1).."/50")
        end
    else
        split(ply)
    end
end)

hook.Add( "PhysgunPickup", "SplitBullet.Server.PhysgunPickup", function( ply, ent )
	return true
end )

hook.Add( "EntityTakeDamage", "SplitBullet.Server.EntityTakeDamage", function( target, dmginfo )
    return target:IsPlayer() and dmginfo:GetAttacker():IsPlayer() and target ~= dmginfo:GetAttacker()
end )

-- DEBUG SPAWNER --

util.AddNetworkString( "SplitBullet.Network.Spawn" )

net.Receive("SplitBullet.Network.Spawn", function( len, ply )
    if ply.SplitTimeout ~= nil then
        if ply.SplitTimeout - os.time() < -5 then
            local ent = ents.Create(net.ReadString())
            local vector = net.ReadVector()
            if vector ~= nil then
                ent:SetPos(vector)
                ent:SetCollisionGroup(COLLISION_GROUP_NPC)
                ent:Spawn()
            end
        end
    else
        local ent = ents.Create(net.ReadString())
        local vector = net.ReadVector()
        if vector ~= nil then
            ent:SetPos(vector)
            ent:SetCollisionGroup(COLLISION_GROUP_NPC)
            ent:Spawn()
        end
    end
end)

hook.Add( "Move", "SplitBullet.Server.Move", function( ply, mv )
    if !ply:GetNWBool("Freed",false) then
        local pos = mv:GetOrigin()
        local axis = ply:GetNWString("PlayerAxis", 0)
        mv:SetOrigin( Vector(pos.x, axis, pos.z) ) --we don't want the player to move out of bounds
    end
    return false
end)

hook.Add( "PlayerHurt", "SplitBullet.Server.PlayerHurt", function( ply )
	ply:ScreenFade( SCREENFADE.IN, Color( 255, 0, 0, 24 ), 0.3, 0 )
end )
