TardisScreenButton = {}

function TardisScreenButton:new(parent)
	local sb = {}

	sb.visible = false
	sb.transparency = 0
	sb.outside = false
	sb.parent = parent

	sb.icon = vgui.Create("DImageButton", parent)
	sb.label = vgui.Create("DLabel", parent)
	sb.label:SetColor(Color(255,255,255,0))

	sb.is_toggle = false
	sb.icon_off = "materials/vgui/tardis-desktops/default/default_off.png"
	sb.icon_on = "materials/vgui/tardis-desktops/default/default_on.png"

	sb.icon:SetImage(sb.icon_off)
	sb.pos = {0, 0}
	sb.size = {10, 10}

	sb.moving = {}
	sb.moving.now = false

	sb.toggle_images = false

	sb.Think = function() end
	sb.DoClick = function() end

	sb.SetVisibleCustom = function(vis)
		if vis
		then
			sb.transparency = 255
		else
			sb.transparency = 0
		end
	end

	sb.ThinkInternal = function()
		sb.transparency = math.min(sb.transparency, 255)
		sb.transparency = math.max(sb.transparency, 0)
		if not sb.is_toggle and sb.on
			and CurTime() > sb.click_end_time
		then
			sb.icon:SetImage(sb.icon_off)
			sb.on = false
		end
		if sb.moving.now and CurTime() > sb.moving.last + 0.01
		then
			sb.moving.move()
			sb.icon:SetColor(Color(255,255,255, sb.transparency))
		end

		local realpos = { math.min(math.max(sb.pos[1], 0), sb.parent:GetWide() - sb.size[1]),
						  math.min(math.max(sb.pos[2], 0), sb.parent:GetTall() - sb.size[2]) }
		sb.icon:SetPos(realpos[1], realpos[2])
		sb.label:SetPos(sb.pos[1], sb.pos[2])
		sb.icon:SetSize(sb.size[1], sb.size[2])
		sb.label:SetSize(sb.size[1], sb.size[2])
		if not sb.moving.now
		then
			sb.outside = (sb.pos[1] < 0) or (sb.pos[2] < 0)
				or (sb.pos[1] + sb.size[1] > sb.parent:GetWide())
				or (sb.pos[2] + sb.size[2] > sb.parent:GetTall())
			sb.SetVisibleCustom(not sb.outside)
		end
		if not sb.visible
		then
			sb.SetVisibleCustom(false)
		end
		sb.Think()
	end

	sb.icon.Think = function()
		sb.ThinkInternal()
	end
	sb.label.Think = function()
		sb.ThinkInternal()
	end
	sb.ThinkInternal()

	sb.icon.DoClick = function()
		sb.DoClick()
		if sb.is_toggle
		then
			sb.on = not sb.on
			if sb.toggle_images
			then
				if sb.on then
					sb.icon:SetImage(sb.icon_on)
				else
					sb.icon:SetImage(sb.icon_off)
				end
			end
		else
			sb.on = true
			sb.icon:SetImage(sb.icon_on)
			sb.click_end_time = CurTime() + 1
		end
	end
	sb.label.DoClick = sb.icon.DoClick

	setmetatable(sb,self)
	self.__index = self
	return sb
end

function TardisScreenButton:Think()
	self.ThinkInternal()
end

function TardisScreenButton:SetSize(sizeX, sizeY)
	self.size = {sizeX, sizeY}
	self.ThinkInternal()
end

function TardisScreenButton:SetPos(posX, posY)
	self.pos = {posX, posY}
	self.ThinkInternal()
end

function TardisScreenButton:SlowMove(x, y, relative, speed)
	local moving = {}
	moving.now = true
	moving.parent = self
	moving.last = CurTime()
	moving.speed = speed or 100

	if relative
	then
		moving.aim = { self.pos[1] + x, self.pos[2] + y }
		moving.step = { x, y }
	else
		moving.aim = { x, y }
		moving.step = { x - self.pos[1], y - self.pos[2] }
	end

	moving.now_outside = (self.pos[1] < 0) or (self.pos[2] < 0)
		or (self.pos[1] + self.size[1] > self.parent:GetWide())
		or (self.pos[2] + self.size[2] > self.parent:GetTall())

	moving.aim_outside = (moving.aim[1] < 0) or (moving.aim[2] < 0)
		or (moving.aim[1] + self.size[1] > self.parent:GetWide())
		or (moving.aim[2] + self.size[2] > self.parent:GetTall())


	moving.step = { moving.step[1] * moving.speed / 1000, moving.step[2] * moving.speed / 1000 }
	moving.transp_step = 0
	if moving.now_outside and moving.aim_outside
	then
		self.transparency = 0
		moving.transp_step = 0
	elseif moving.now_outside
	then
		self.transparency = 0
		moving.transp_step = 255 * speed / 1000;
	elseif moving.aim_outside
	then
		self.transparency = 255
		moving.transp_step = - 255 * speed / 1000;
	end

	moving.move = function()
		local sb = moving.parent
		sb.pos = { sb.pos[1] + moving.step[1], sb.pos[2] + moving.step[2] }
		moving.last = CurTime()
		sb.transparency = sb.transparency + moving.transp_step

		local distance = math.Distance(sb.pos[1], sb.pos[2], moving.aim[1], moving.aim[2])
		if distance <= 1
		then
			sb.pos = moving.aim
			moving.now = false
		end
	end
	self.moving = moving
end

function TardisScreenButton:GetPosX()
	return self.pos[1]
end
function TardisScreenButton:GetPosY()
	return self.pos[2]
end
function TardisScreenButton:GetWide()
	return self.size[1]
end
function TardisScreenButton:GetTall()
	return self.size[2]
end

function TardisScreenButton:SetImages(off, on)
	self.icon_off = off
	self.icon_on = on or off
	self.icon:SetImage(self.icon_off)
end

function TardisScreenButton:SetIsToggle(is_toggle)
	self.is_toggle=is_toggle
end

function TardisScreenButton:SetPressed(on)
	self.on = on
	if on then
		self.icon:SetImage(self.icon_on)
	else
		self.icon:SetImage(self.icon_off)
	end
end

function TardisScreenButton:SetVisible(visible)
	self.visible = visible
	self.ThinkInternal()
end

function TardisScreenButton:GetVisible()
	return self.visible
end

function TardisScreenButton:SetTransparency(x)
	self.icon:SetColor(Color(255,255,255,x));
end

function TardisScreenButton:SetControl(control)
	self.DoClick = function()
		TARDIS:Control(control)
	end
end
function TardisScreenButton:SetPressedStateData(ext, data1, data2)
	if data2 == nil
	then
		self.Think = function()
			self:SetPressed(ext:GetData(data1))
		end
	else
		self.Think = function()
			self:SetPressed(ext:GetData(data1) or ext:GetData(data2))
		end
	end
end
