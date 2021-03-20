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

DEFINE_BASECLASS( "player_default" )
 
local PLAYER = {} 

PLAYER.DisplayName			= "Uno"

PLAYER.WalkSpeed			= 450		-- How fast to move when not running
PLAYER.RunSpeed				= 450		-- How fast to move when running
PLAYER.CrouchedWalkSpeed	= 0.3 		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.JumpPower			= 250		-- How powerful our jump should be
PLAYER.CanUseFlashlight		= false		-- Can we use the flashlight
PLAYER.MaxHealth			= 100		-- Max health we can have
PLAYER.MaxArmor				= 100		-- Max armor we can have
PLAYER.StartHealth			= 100		-- How much health we start with
PLAYER.StartArmor			= 0			-- How much armour we start with
PLAYER.DropWeaponOnDie		= false		-- Do we drop our weapon when we die
PLAYER.TeammateNoCollide	= true		-- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers			= true		-- Automatically swerves around other players
PLAYER.UseVMHands			= false		-- Uses viewmodel hands


function PLAYER:Loadout()
    self.Player:RemoveAllItems()
    self.Player:RemoveAllAmmo()
    self.Player:GiveAmmo( 256,	"Pistol", 		true )
    self.Player:Give( "weapon_glock" )
    --[[self.Player:RemoveAllAmmo()
    self.Player:GiveAmmo( 256,	"Pistol", 		true )
    self.Player:Give( "weapon_pistol" )
    self.Player:Give( "weapon_crowbar" )
    self.Player:Give( "weapon_physgun" )
    self.Player:Give( "weapon_rpg" )
    self.Player:Give( "weapon_physcannon" )
    self.Player:Give( "weapon_fists" )]]--
end

function PLAYER:SetModel()
	local modelname = "models/splitbullet/player.mdl"
	util.PrecacheModel( modelname )
	self.Player:SetModel( modelname )
    self.Player:SetSkin(0)
end
 
player_manager.RegisterClass( "player_uno", PLAYER, "player_default")
