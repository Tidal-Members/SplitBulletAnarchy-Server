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

ENT.AutomaticFrameAdvance = true -- Must be set on client

killicon.Add("npc_bolter", "HUD/killicons/splitbullet_bolter", Color( 255, 80, 0, 255 ) )

function ENT:Think()
	local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		local pos = self:GetPos()
		pos.y = pos.y + -5
		pos.z = pos.z + 5
		dlight.pos = pos
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 2
		dlight.Decay = 1000
		dlight.Size = 128
		dlight.DieTime = CurTime() + 1
	end
	self:NextThink( CurTime() ) -- Set the next think to run as soon as possible, i.e. the next frame.
	return true -- Apply NextThink call
end

