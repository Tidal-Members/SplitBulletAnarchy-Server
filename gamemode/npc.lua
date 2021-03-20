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

--version of base gamemode npc.lua with proper printnames

-- Add Network Strings we use
util.AddNetworkString( "PlayerKilledNPC" )
util.AddNetworkString( "NPCKilledNPC" )

--[[---------------------------------------------------------
   Name: gamemode:OnNPCKilled( entity, attacker, inflictor )
   Desc: The NPC has died
-----------------------------------------------------------]]
function GM:OnNPCKilled( ent, attacker, inflictor )

	-- Don't spam the killfeed with scripted stuff
	if ( ent:GetClass() == "npc_bullseye" || ent:GetClass() == "npc_launcher" ) then return end

	if ( IsValid( attacker ) && attacker:GetClass() == "trigger_hurt" ) then attacker = ent end
	
	if ( IsValid( attacker ) && attacker:IsVehicle() && IsValid( attacker:GetDriver() ) ) then
		attacker = attacker:GetDriver()
	end

	if ( !IsValid( inflictor ) && IsValid( attacker ) ) then
		inflictor = attacker
	end
	
	-- Convert the inflictor to the weapon that they're holding if we can.
	if ( IsValid( inflictor ) && attacker == inflictor && ( inflictor:IsPlayer() || inflictor:IsNPC() ) ) then
	
		inflictor = inflictor:GetActiveWeapon()
		if ( !IsValid( attacker ) ) then inflictor = attacker end
	
	end
	
	local InflictorClass = "worldspawn"
	local AttackerClass = "worldspawn"
	
	if ( IsValid( inflictor ) ) then InflictorClass = inflictor:GetClass() end
	if ( IsValid( attacker ) ) then

		AttackerClass = attacker:GetClass()
	
		if ( attacker:IsPlayer() ) then

			net.Start( "PlayerKilledNPC" )
				local name = ent.PrintName
				if name == nil then
					name = ent:GetClass()
				end
				net.WriteString( name )
				net.WriteString( InflictorClass )
				net.WriteEntity( attacker )
		
			net.Broadcast()

			return
		end

	end

	if ( ent:GetClass() == "npc_turret_floor" ) then AttackerClass = ent:GetClass() end

	net.Start( "NPCKilledNPC" )
		local name = ent.PrintName
		if name == nil then
			name = ent:GetClass()
		end
		net.WriteString( name )
		net.WriteString( InflictorClass )
		net.WriteString( AttackerClass )
	
	net.Broadcast()

end

--[[---------------------------------------------------------
   Name: gamemode:ScaleNPCDamage( ply, hitgroup, dmginfo )
   Desc: Scale the damage based on being shot in a hitbox
-----------------------------------------------------------]]
function GM:ScaleNPCDamage( npc, hitgroup, dmginfo )

	-- More damage if we're shot in the head
	if ( hitgroup == HITGROUP_HEAD ) then
	
		dmginfo:ScaleDamage( 2 )
	
	end
	
	-- Less damage if we're shot in the arms or legs
	if ( hitgroup == HITGROUP_LEFTARM ||
		 hitgroup == HITGROUP_RIGHTARM ||
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_RIGHTLEG ||
		 hitgroup == HITGROUP_GEAR ) then
	
		dmginfo:ScaleDamage( 0.25 )
	
	end

end
