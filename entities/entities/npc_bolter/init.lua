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



function ENT:Initialize()
    self:SetBloodColor(DONT_BLEED)
	self:SetModel( "models/splitbullet/bolter.mdl" )
    self:SetMaxHealth(50)
    self:SetHealth( self:GetMaxHealth() )
    self:StopSound("ambient/levels/canals/generator_ambience_loop1.wav")
    if self.Range == nil then
		self.Range = 150
	end
	if self.StartBurrowed == nil then
    	self.StartBurrowed = false
	end
	if self.Dead == nil then
    	self.Dead = false
	end
end

function ENT:KeyValue(key, value)
	if key == "range" then
		self.Range = value
	elseif key == "burrowed" then
		if value > 0 then
			self.StartBurrowed = true
		else
			self.StartBurrowed = false
		end
	elseif key == "dead" then
		if value > 0 then
			self.Dead = true
		else
			self.Dead = false
		end
	end
end
function ENT:OnKilled( dmginfo )
    local pos = self:GetPos()
    local ang = self:GetAngles()
    local diffp = pos.z
    local diffc = 255
    self.Dead = true
    self:StopSound("ambient/levels/canals/generator_ambience_loop1.wav")
	hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
    self:SetMoveType(MOVETYPE_NONE)
    self:PhysicsInit(SOLID_NONE)
    self:SetModelScale(0, 0.5)
	local explosion = ents.Create("env_explosion")
	explosion:SetPos(self:GetPos())
	explosion:SetKeyValue("spawnflags", 1)
	explosion:Spawn()
	explosion:Input("Explode")
	self:EmitSound("npc/roller/mine/rmine_explode_shock1.wav")
    timer.Create(self:EntIndex().."_bolterdeath", 0.1, 5, function()
        diffc = diffc - 128
        diffp = diffp+math.random(5, 7)
        self:SetAngles(Angle(math.random(-90, 90)), ang.y, ang.r)
        self:SetPos(Vector(pos.x, pos.y, diffp))
        self:SetColor(Color(diffc, diffc, diffc, 255))
    end)
    timer.Simple(1, function()
        self:StopSound("ambient/levels/canals/generator_ambience_loop1.wav")
        self:Remove()
    end)
end


----------------------------------------------------
-- ENT:Get/SetEnemy()
-- Simple functions used in keeping our enemy saved
----------------------------------------------------
function ENT:SetEnemy(ent)
	self.Enemy = ent
end
function ENT:GetEnemy()
    return playersinrange(self:GetPos(), self.Range)
	--return self.Enemy
end
function ENT:SetAttackedEnemy(ent)
	self.AttackedEnemy = ent
end
function ENT:GetAttackedEnemy()
	return self.AttackedEnemy
end

----------------------------------------------------
-- ENT:HaveEnemy()
-- Returns true if we have a enemy
----------------------------------------------------
function ENT:HaveEnemy()
    return self:GetEnemy() ~= nil
end

----------------------------------------------------
-- ENT:RunBehaviour()
-- This is where the meat of our AI is
----------------------------------------------------
function ENT:RunBehaviour()
    self:StartActivity(ACT_IDLE)
	-- This function is called when the entity is first spawned. It acts as a giant loop that will run as long as the NPC exists
	while ( true ) do
        local mypos = self:GetPos()
        self:SetPos(Vector(mypos.x, 0, mypos.z))
		if (self.StartBurrowed) then
			self:Burrow()
		end
		self.StartBurrowed = false
		-- Lets use the above mentioned functions to see if we have/can find a enemy
		if ( self:HaveEnemy() and !self.Dead ) then
			-- Now that we have an enemy, the code in this block will run
			self.loco:FaceTowards(self:GetEnemy():GetPos())	-- Face our enemy
			self.loco:SetDesiredSpeed( 450 )		-- Set the speed that we will be moving at. Don't worry, the animation will speed up/slow down to match
			self.loco:SetAcceleration(900)			-- We are going to run at the enemy quickly, so we want to accelerate really fast
			self:ChaseEnemy() 						-- The new function like MoveToPos.
            self.loco:SetAcceleration(400)			-- Set this back to its default since we are done chasing the enemy
            self:Burrow()
			-- Now once the above function is finished doing what it needs to do, the code will loop back to the start
			-- unless you put stuff after the if statement. Then that will be run before it loops
        elseif !self.Dead then
			-- Since we can't find an enemy, lets burrow
			self:Burrow()
		end
        
		-- At this point in the code the bot has stopped chasing the player or finished walking to a random spot
		-- Using this next function we are going to wait 2 seconds until we go ahead and repeat it 
		coroutine.yield(0.25)
	end

end	

function playersinrange(pos, range)
    for k, v in ipairs(ents.FindInSphere( pos, range )) do
        if v:IsValid() and v:IsPlayer() and v:Alive() then
            return v
        end
    end
    return nil
end

function ENT:Burrow()
    self:StopSound("ambient/levels/canals/generator_ambience_loop1.wav")
    local vec = self:GetPos()
    local ang = self:GetAngles()
	if ang.y  < 0 then
		ang.y = 0
	else
		ang.y = 180
	end
    local physobj = self:GetPhysicsObject()
    local diff = vec.z
    local goal = diff-20
	while playersinrange(vec, 150) and !self.Dead do
        if diff >= goal then
            diff = diff - 5
        end
        self:SetAngles(Angle(math.random(-23.5, 23.5), ang.y, ang.r))
        self:SetPos(Vector(vec.x, vec.y, diff))
    	coroutine.yield()
	end
    self:EmitSound("ambient/levels/canals/generator_ambience_loop1.wav", 80, 110, 0.25)
    while diff <= vec.z and !self.Dead do
        diff = diff + 5
        self:SetAngles(Angle(math.random(-23.5, 23.5), ang.y, ang.r))
        self:SetPos(Vector(vec.x, vec.y, diff))
        coroutine.yield()
    end
    self:SetAngles(Angle(0, ang.y, ang.r))
    --self:SetEnemy(self:GetAttackedEnemy())
	return "ok"
end

----------------------------------------------------
-- ENT:ChaseEnemy()
-- Works similarly to Garry's MoveToPos function
--  except it will constantly follow the
--  position of the enemy until there no longer
--  is one.
----------------------------------------------------

function ENT:ChaseEnemy( options )
	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, self:GetEnemy():GetPos() )		-- Compute the path towards the enemies position

	if ( !path:IsValid() ) then return "failed" end
    self:EmitSound("ambient/levels/canals/generator_ambience_loop1.wav", 80, 130, 1)
	while ( path:IsValid() and self:HaveEnemy() ) and !self.Dead do
	
		if ( path:GetAge() > 0.1 ) then					-- Since we are following the player we have to constantly remake the path
			path:Compute(self, self:GetEnemy():GetPos())-- Compute the path towards the enemy's position again
		end
		path:Update( self )								-- This function moves the bot along the path
		if ( options.draw ) then path:Draw() end
		-- If we're stuck, then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

        local dist = self:GetPos():Distance(self:GetEnemy():GetPos())
        if dist <= 40 and !self.Dead then
            self:GetEnemy():EmitSound("physics/flesh/flesh_impact_bullet"..math.random(1,5)..".wav")
            self:GetEnemy():TakeDamage( 15, self, self )
            self:EmitSound("physics/flesh/fist_hit_01.wav")
            --self:SetAttackedEnemy(self:GetEnemy())
            --self:SetEnemy(nil)
            self.Hidden = true
            self:StopSound("ambient/levels/canals/generator_ambience_loop1.wav")
            return "ok"
        end
		coroutine.yield()
	end
	return "ok"

end
