-- Legacy Interior - Physics Lock

local PART = {}
PART.ID = "legacy_physbrake"
PART.Name = "Legacy Physics Lock"
PART.Model = "models/drmatt/tardis/handbrake.mdl"
PART.AutoSetup = true
PART.Collision = true
PART.Animate = true
PART.Sound = "tardis/control_handbrake.wav"

if SERVER then
	function PART:Use(ply)
		self.exterior:TogglePhyslock()
		ply:ChatPrint("Physics Lock ".. (self.exterior:GetData("physlock") and "engaged" or "disengaged"))
	end
end

TARDIS:AddPart(PART)
