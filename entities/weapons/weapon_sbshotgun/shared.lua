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
SWEP.PrintName = "Shotgun"
SWEP.Instructions = "MOUSE1 to shoot, MOUSE2 for double shot"
SWEP.ViewModel = "models/weapons/v_shotgun.mdl" --default hl2 shotgun
SWEP.WorldModel = "models/splitbullet/weapons/w_sbshotgun.mdl"

SWEP.CSMuzzleFlashes = false
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Cone = 0.3
SWEP.Primary.Delay = 0.065
SWEP.Primary.Burst = 4

SWEP.Secondary.ClipSize		= 3
SWEP.Secondary.DefaultClip	= 1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "Buckshot"

SWEP.Slot = 1
SWEP.SlotPos = 1

function SWEP:PrimaryAttack()
	-- Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end

	-- Play shoot sound
	self:EmitSound("Weapon_Pistol.Single")
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:GetOwner():MuzzleFlash()
	-- Shoot 5 bullets, 1 aimcone

	self:ShootBullet( 5, 30, 0.05 )
end

function SWEP:SecondaryAttack()

	-- Play shoot sound
	self:EmitSound("Weapon_Shotgun.Single")
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:GetOwner():MuzzleFlash()
	-- Shoot 5 bullets, 1 aimcone

	self:ShootBullet( 10, 30, 0.2 )
end
