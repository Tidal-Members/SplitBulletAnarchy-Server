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

SWEP.Base = "weapon_splitbulletbase"
SWEP.PrintName = "Sniper"
SWEP.Instructions = "MOUSE1 to shoot, MOUSE2 to scope in."
SWEP.ViewModel = "models/weapons/v_crossbow.mdl" --default hl2 crossbow sniper thing
SWEP.WorldModel = "models/splitbullet/weapons/w_sbsniper.mdl"

SWEP.CSMuzzleFlashes = false
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Cone = 0.3
SWEP.Primary.Delay = 0.065
SWEP.Primary.Burst = 4

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Slot = 1
SWEP.SlotPos = 2

function SWEP:PrimaryAttack()
	-- Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end

	-- Play shoot sound
	self:EmitSound("Weapon_Pistol.Single")
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:GetOwner():MuzzleFlash()
	-- Shoot 1 bullet, 0 aimcone

	self:ShootBullet( 1, 150, 0 )
end

function SWEP:SecondaryAttack()
end
