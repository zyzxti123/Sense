-- services
local runService = game:GetService("RunService");
local players = game:GetService("Players");
local workspace = game:GetService("Workspace");

-- variables
local localPlayer = players.LocalPlayer;
local camera = workspace.CurrentCamera;
local viewportSize = camera.ViewportSize;
local container = Instance.new("Folder", gethui and gethui() or game:GetService("CoreGui"));

-- locals
local floor = math.floor;
local round = math.round;
local sin = math.sin;
local cos = math.cos;
local clear = table.clear;
local unpack = table.unpack;
local find = table.find;
local create = table.create;
local fromMatrix = CFrame.fromMatrix;

-- methods
local wtvp = camera.WorldToViewportPoint;
local isA = workspace.IsA;
local getPivot = workspace.GetPivot;
local findFirstChild = workspace.FindFirstChild;
local findFirstChildOfClass = workspace.FindFirstChildOfClass;
local getChildren = workspace.GetChildren;
local pointToObjectSpace = CFrame.identity.PointToObjectSpace;
local lerpColor = Color3.new().Lerp;
local min2 = Vector2.zero.Min;
local max2 = Vector2.zero.Max;
local lerp2 = Vector2.zero.Lerp;
local min3 = Vector3.zero.Min;
local max3 = Vector3.zero.Max;

-- constants
local HEALTH_BAR_OFFSET = Vector2.new(5, 0);
local HEALTH_TEXT_OFFSET = Vector2.new(3, 0);
local HEALTH_BAR_OUTLINE_OFFSET = Vector2.new(0, 1);
local NAME_OFFSET = Vector2.new(0, 2);
local DISTANCE_OFFSET = Vector2.new(0, 2);
local VERTICES = {
	Vector3.new(-1, -1, -1), Vector3.new(-1, 1, -1), Vector3.new(-1, 1, 1), Vector3.new(-1, -1, 1),
	Vector3.new(1, -1, -1), Vector3.new(1, 1, -1), Vector3.new(1, 1, 1), Vector3.new(1, -1, 1)
};

-- interface
local EspInterface = {
	_hasLoaded = false,
	_objectCache = {},
	_heartbeatConnection = nil,
	whitelist = {},
	sharedSettings = {
		textSize = 13,
		textFont = 2,
		limitDistance = false,
		maxDistance = 150,
		useTeamColor = false
	},
	teamSettings = {
		enemy = {
			enabled = true, box = false, boxColor = { Color3.new(1,0,0), 1 }, boxOutline = true, boxOutlineColor = { Color3.new(), 1 },
			boxFill = false, boxFillColor = { Color3.new(1,0,0), 0.5 }, healthBar = false, healthyColor = Color3.new(0,1,0),
			dyingColor = Color3.new(1,0,0), healthBarOutline = true, healthBarOutlineColor = { Color3.new(), 0.5 },
			healthText = false, healthTextColor = { Color3.new(1,1,1), 1 }, healthTextOutline = true, healthTextOutlineColor = Color3.new(),
			box3d = false, box3dColor = { Color3.new(1,0,0), 1 }, name = false, nameColor = { Color3.new(1,1,1), 1 },
			nameOutline = true, nameOutlineColor = Color3.new(), weapon = false, weaponColor = { Color3.new(1,1,1), 1 },
			weaponOutline = true, weaponOutlineColor = Color3.new(), distance = false, distanceColor = { Color3.new(1,1,1), 1 },
			distanceOutline = true, distanceOutlineColor = Color3.new(), tracer = false, tracerOrigin = "Bottom",
			tracerColor = { Color3.new(1,0,0), 1 }, tracerOutline = true, tracerOutlineColor = { Color3.new(), 1 },
			offScreenArrow = false, offScreenArrowColor = { Color3.new(1,1,1), 1 }, offScreenArrowSize = 15, offScreenArrowRadius = 150,
			offScreenArrowOutline = true, offScreenArrowOutlineColor = { Color3.new(), 1 }, chams = false, chamsVisibleOnly = false,
			chamsFillColor = { Color3.new(0.2, 0.2, 0.2), 0.5 }, chamsOutlineColor = { Color3.new(1,0,0), 0 },
		},
		friendly = {
			enabled = true, box = false, boxColor = { Color3.new(0,1,0), 1 }, boxOutline = true, boxOutlineColor = { Color3.new(), 1 },
			boxFill = false, boxFillColor = { Color3.new(0,1,0), 0.5 }, healthBar = false, healthyColor = Color3.new(0,1,0),
			dyingColor = Color3.new(1,0,0), healthBarOutline = true, healthBarOutlineColor = { Color3.new(), 0.5 },
			healthText = false, healthTextColor = { Color3.new(1,1,1), 1 }, healthTextOutline = true, healthTextOutlineColor = Color3.new(),
			box3d = false, box3dColor = { Color3.new(0,1,0), 1 }, name = false, nameColor = { Color3.new(1,1,1), 1 },
			nameOutline = true, nameOutlineColor = Color3.new(), weapon = false, weaponColor = { Color3.new(1,1,1), 1 },
			weaponOutline = true, weaponOutlineColor = Color3.new(), distance = false, distanceColor = { Color3.new(1,1,1), 1 },
			distanceOutline = true, distanceOutlineColor = Color3.new(), tracer = false, tracerOrigin = "Bottom",
			tracerColor = { Color3.new(0,1,0), 1 }, tracerOutline = true, tracerOutlineColor = { Color3.new(), 1 },
			offScreenArrow = false, offScreenArrowColor = { Color3.new(1,1,1), 1 }, offScreenArrowSize = 15, offScreenArrowRadius = 150,
			offScreenArrowOutline = true, offScreenArrowOutlineColor = { Color3.new(), 1 }, chams = false, chamsVisibleOnly = false,
			chamsFillColor = { Color3.new(0.2, 0.2, 0.2), 0.5 }, chamsOutlineColor = { Color3.new(0,1,0), 0 }
		}
	},
    instanceSettings = {
        enabled = true, text = "{name}", textColor = { Color3.new(1,1,1), 1 }, textOutline = true, textOutlineColor = Color3.new(0,0,0),
		textSize = 13, textFont = 2, box = false, boxColor = { Color3.new(1,1,1), 1 }, boxOutline = false, boxOutlineColor = { Color3.new(0,0,0), 1 },
		boxFill = false, boxFillColor = { Color3.new(1,1,1), 0.5 }, box3d = false, box3dColor = { Color3.new(1,1,1), 1 },
		tracer = false, tracerOrigin = "Bottom", tracerColor = { Color3.new(1,1,1), 1 }, tracerOutline = false, tracerOutlineColor = { Color3.new(0,0,0), 1 },
		offScreenArrow = false, offScreenArrowColor = { Color3.new(1,1,1), 1 }, offScreenArrowSize = 15, offScreenArrowRadius = 150,
		offScreenArrowOutline = false, offScreenArrowOutlineColor = { Color3.new(0,0,0), 1 }, limitDistance = false, maxDistance = 150
    }
};

-- helpers
local function rotateVector(vector, radians)
	local x, y = vector.X, vector.Y;
	local c, s = cos(radians), sin(radians);
	return Vector2.new(x*c - y*s, x*s + y*c);
end

local function worldToScreen(world)
	local screen, inBounds = wtvp(camera, world);
	return Vector2.new(screen.X, screen.Y), inBounds, screen.Z;
end

local function calculateCorners(cframe, size)
	local corners = create(#VERTICES);
	for i = 1, #VERTICES do
		corners[i] = worldToScreen((cframe * CFrame.new(size * 0.5 * VERTICES[i])).Position);
	end
	local min = min2(viewportSize, unpack(corners));
	local max = max2(Vector2.zero, unpack(corners));
	return {
		corners = corners,
		topLeft = Vector2.new(floor(min.X), floor(min.Y)),
		topRight = Vector2.new(floor(max.X), floor(min.Y)),
		bottomLeft = Vector2.new(floor(min.X), floor(max.Y)),
		bottomRight = Vector2.new(floor(max.X), floor(max.Y))
	};
end

local function parseColor(self, color, isOutline)
	if color == "Team Color" or (self.interface.sharedSettings.useTeamColor and not isOutline) then
		return self.interface.getTeamColor(self.player) or Color3.new(1,1,1);
	end
	return color;
end

-- esp object
local EspObject = {};
EspObject.__index = EspObject;

function EspObject.new(player, interface)
	local self = setmetatable({
		player = player,
		interface = interface,
		bin = {},
		charCache = {},
		childCount = 0,
		options = interface.teamSettings.enemy
	}, EspObject);
	self:Construct();
	return self;
end

function EspObject:_create(class, properties)
	local drawing = Drawing.new(class);
	for property, value in next, properties do
		pcall(function() drawing[property] = value; end);
	end
	self.bin[#self.bin + 1] = drawing;
	return drawing;
end

function EspObject:Construct()
	self.drawings = {
		box3d = {
			{self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1})},
			{self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1})},
			{self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1})},
			{self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1})}
		},
		visible = {
			tracerOutline = self:_create("Line", { Thickness = 3, Visible = false }),
			tracer = self:_create("Line", { Thickness = 1, Visible = false }),
			boxFill = self:_create("Square", { Filled = true, Visible = false }),
			boxOutline = self:_create("Square", { Thickness = 3, Visible = false }),
			box = self:_create("Square", { Thickness = 1, Visible = false }),
			healthBarOutline = self:_create("Line", { Thickness = 3, Visible = false }),
			healthBar = self:_create("Line", { Thickness = 1, Visible = false }),
			healthText = self:_create("Text", { Center = true, Visible = false }),
			name = self:_create("Text", { Text = self.player.DisplayName, Center = true, Visible = false }),
			distance = self:_create("Text", { Center = true, Visible = false }),
			weapon = self:_create("Text", { Center = true, Visible = false }),
		},
		hidden = {
			arrowOutline = self:_create("Triangle", { Thickness = 3, Visible = false }),
			arrow = self:_create("Triangle", { Filled = true, Visible = false })
		}
	};
end

function EspObject:Update()
	local interface = self.interface;
	self.options = interface.teamSettings[interface.isFriendly(self.player) and "friendly" or "enemy"];
	self.character = interface.getCharacter(self.player);
	self.health, self.maxHealth = interface.getHealth(self.player);
	self.weapon = interface.getWeapon(self.player);
	self.enabled = self.options.enabled and self.character and not (#interface.whitelist > 0 and not find(interface.whitelist, self.player.UserId));

	local head = self.enabled and findFirstChild(self.character, "Head");
	if not head then self.onScreen = false; return; end

	local _, onScreen, depth = worldToScreen(head.Position);
	self.onScreen = onScreen;
	self.distance = depth;

	if interface.sharedSettings.limitDistance and depth > interface.sharedSettings.maxDistance then
		self.onScreen = false;
	end

	if self.onScreen then
		local cache = self.charCache;
		local children = getChildren(self.character);
		if not cache[1] or self.childCount ~= #children then
			clear(cache);
			for _, part in next, children do
				if isA(part, "BasePart") and (part.Name == "Head" or part.Name:find("Torso") or part.Name:find("Leg") or part.Name:find("Arm")) then
					cache[#cache + 1] = part;
				end
			end
			self.childCount = #children;
		end
		
		local min, max;
		for i = 1, #cache do
			local part = cache[i];
			local c, s = part.CFrame, part.Size;
			min = min3(min or c.Position, (c - s*0.5).Position);
			max = max3(max or c.Position, (c + s*0.5).Position);
		end
		self.corners = calculateCorners(CFrame.new((min+max)*0.5, Vector3.new((min+max).X*0.5, (min+max).Y*0.5, max.Z)), max-min);
	elseif self.options.offScreenArrow then
		local cframe = camera.CFrame;
		local flat = fromMatrix(cframe.Position, cframe.RightVector, Vector3.yAxis);
		local objectSpace = pointToObjectSpace(flat, head.Position);
		self.direction = Vector2.new(objectSpace.X, objectSpace.Z).Unit;
	end
end

function EspObject:Render()
	local onScreen, enabled = self.onScreen or false, self.enabled or false;
	local visible, hidden, box3d = self.drawings.visible, self.drawings.hidden, self.drawings.box3d;
	local options, interface, corners = self.options, self.interface, self.corners;

	visible.box.Visible = enabled and onScreen and options.box;
	visible.boxOutline.Visible = visible.box.Visible and options.boxOutline;
	if visible.box.Visible then
		visible.box.Position = corners.topLeft;
		visible.box.Size = corners.bottomRight - corners.topLeft;
		visible.box.Color = parseColor(self, options.boxColor[1]);
		visible.box.Transparency = options.boxColor[2];
		visible.boxOutline.Position = corners.topLeft;
		visible.boxOutline.Size = visible.box.Size;
		visible.boxOutline.Color = parseColor(self, options.boxOutlineColor[1], true);
		visible.boxOutline.Transparency = options.boxOutlineColor[2];
	end

	visible.boxFill.Visible = enabled and onScreen and options.boxFill;
	if visible.boxFill.Visible then
		visible.boxFill.Position = corners.topLeft;
		visible.boxFill.Size = corners.bottomRight - corners.topLeft;
		visible.boxFill.Color = parseColor(self, options.boxFillColor[1]);
		visible.boxFill.Transparency = options.boxFillColor[2];
	end

	visible.healthBar.Visible = enabled and onScreen and options.healthBar;
	visible.healthBarOutline.Visible = visible.healthBar.Visible and options.healthBarOutline;
	if visible.healthBar.Visible then
		local barFrom, barTo = corners.topLeft - HEALTH_BAR_OFFSET, corners.bottomLeft - HEALTH_BAR_OFFSET;
		visible.healthBar.To = barTo;
		visible.healthBar.From = lerp2(barTo, barFrom, self.health/self.maxHealth);
		visible.healthBar.Color = lerpColor(options.dyingColor, options.healthyColor, self.health/self.maxHealth);
		visible.healthBarOutline.To = barTo + HEALTH_BAR_OUTLINE_OFFSET;
		visible.healthBarOutline.From = barFrom - HEALTH_BAR_OUTLINE_OFFSET;
		visible.healthBarOutline.Color = parseColor(self, options.healthBarOutlineColor[1], true);
		visible.healthBarOutline.Transparency = options.healthBarOutlineColor[2];
	end

	visible.name.Visible = enabled and onScreen and options.name;
	if visible.name.Visible then
		visible.name.Size = interface.sharedSettings.textSize;
		visible.name.Font = interface.sharedSettings.textFont;
		visible.name.Color = parseColor(self, options.nameColor[1]);
		visible.name.Outline = options.nameOutline;
		visible.name.Position = (corners.topLeft + corners.topRight)*0.5 - Vector2.yAxis*visible.name.TextBounds.Y - NAME_OFFSET;
	end

	hidden.arrow.Visible = enabled and (not onScreen) and options.offScreenArrow;
	hidden.arrowOutline.Visible = hidden.arrow.Visible and options.offScreenArrowOutline;
	if hidden.arrow.Visible and self.direction then
		local arrow = hidden.arrow;
		arrow.PointA = min2(max2(viewportSize*0.5 + self.direction*options.offScreenArrowRadius, Vector2.one*25), viewportSize - Vector2.one*25);
		arrow.PointB = arrow.PointA - rotateVector(self.direction, 0.45)*options.offScreenArrowSize;
		arrow.PointC = arrow.PointA - rotateVector(self.direction, -0.45)*options.offScreenArrowSize;
		arrow.Color = parseColor(self, options.offScreenArrowColor[1]);
		arrow.Transparency = options.offScreenArrowColor[2];
		hidden.arrowOutline.PointA, hidden.arrowOutline.PointB, hidden.arrowOutline.PointC = arrow.PointA, arrow.PointB, arrow.PointC;
		hidden.arrowOutline.Color = parseColor(self, options.offScreenArrowOutlineColor[1], true);
		hidden.arrowOutline.Transparency = options.offScreenArrowOutlineColor[2];
	end

	visible.tracer.Visible = enabled and onScreen and options.tracer;
	if visible.tracer.Visible then
		visible.tracer.To = (corners.bottomLeft + corners.bottomRight)*0.5;
		visible.tracer.From = options.tracerOrigin == "Middle" and viewportSize*0.5 or options.tracerOrigin == "Top" and viewportSize*Vector2.new(0.5, 0) or viewportSize*Vector2.new(0.5, 1);
		visible.tracer.Color = parseColor(self, options.tracerColor[1]);
	end

	local box3dEnabled = enabled and onScreen and options.box3d;
	for i = 1, #box3d do
		local face = box3d[i];
		for j = 1, #face do face[j].Visible = box3dEnabled; face[j].Color = parseColor(self, options.box3dColor[1]); end
		if box3dEnabled then
			face[1].From, face[1].To = corners.corners[i], corners.corners[i == 4 and 1 or i+1];
			face[2].From, face[2].To = corners.corners[i == 4 and 1 or i+1], corners.corners[i == 4 and 5 or i+5];
			face[3].From, face[3].To = corners.corners[i == 4 and 5 or i+5], corners.corners[i == 4 and 8 or i+4];
		end
	end
end

function EspObject:Destruct()
	for i = 1, #self.bin do self.bin[i]:Remove(); end
	clear(self);
end

-- cham object
local ChamObject = {};
ChamObject.__index = ChamObject;

function ChamObject.new(player, interface)
	local self = setmetatable({player = player, interface = interface}, ChamObject);
	self.highlight = Instance.new("Highlight", container);
	return self;
end

function ChamObject:Update()
	local interface = self.interface;
	local character = interface.getCharacter(self.player);
	local options = interface.teamSettings[interface.isFriendly(self.player) and "friendly" or "enemy"];
	local enabled = options.enabled and character and not (#interface.whitelist > 0 and not find(interface.whitelist, self.player.UserId));

	self.highlight.Enabled = enabled and options.chams;
	if self.highlight.Enabled then
		self.highlight.Adornee = character;
		self.highlight.FillColor = parseColor(self, options.chamsFillColor[1]);
		self.highlight.FillTransparency = options.chamsFillColor[2];
		self.highlight.OutlineColor = parseColor(self, options.chamsOutlineColor[1], true);
		self.highlight.OutlineTransparency = options.chamsOutlineColor[2];
		self.highlight.DepthMode = options.chamsVisibleOnly and "Occluded" or "AlwaysOnTop";
	end
end

function ChamObject:Destruct()
	self.highlight:Destroy();
	clear(self);
end

-- instance object
local InstanceObject = {};
InstanceObject.__index = InstanceObject;

function InstanceObject.new(instance, options)
	local self = setmetatable({
		instance = instance,
		options = options,
		bin = {}
	}, InstanceObject);
	self:Construct();
	return self;
end

function InstanceObject:_create(class, properties)
	local drawing = Drawing.new(class);
	for property, value in next, properties do
		pcall(function() drawing[property] = value; end);
	end
	self.bin[#self.bin + 1] = drawing;
	return drawing;
end

function InstanceObject:Construct()
	self.drawings = {
		box3d = {
			{self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1})},
			{self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1})},
			{self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1})},
			{self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1}), self:_create("Line", {Thickness=1})}
		},
		visible = {
			tracerOutline = self:_create("Line", { Thickness = 3, Visible = false }),
			tracer = self:_create("Line", { Thickness = 1, Visible = false }),
			boxFill = self:_create("Square", { Filled = true, Visible = false }),
			boxOutline = self:_create("Square", { Thickness = 3, Visible = false }),
			box = self:_create("Square", { Thickness = 1, Visible = false }),
			name = self:_create("Text", { Center = true, Visible = false }),
		},
		hidden = {
			arrowOutline = self:_create("Triangle", { Thickness = 3, Visible = false }),
			arrow = self:_create("Triangle", { Filled = true, Visible = false })
		}
	};
end

function InstanceObject:Update()
	local options = self.options;
	local cf, size;
	if isA(self.instance, "Model") then cf, size = self.instance:GetBoundingBox();
	elseif isA(self.instance, "BasePart") then cf, size = self.instance.CFrame, self.instance.Size;
	else cf, size = getPivot(self.instance), Vector3.new(2,2,2); end

	local _, onScreen, depth = worldToScreen(cf.Position);
	self.onScreen = onScreen;
	self.distance = depth;

	if options.limitDistance and depth > options.maxDistance then self.onScreen = false; end

	if self.onScreen then
		self.corners = calculateCorners(cf, size);
	elseif options.offScreenArrow then
		local cameraCf = camera.CFrame;
		local flat = fromMatrix(cameraCf.Position, cameraCf.RightVector, Vector3.yAxis);
		local objectSpace = pointToObjectSpace(flat, cf.Position);
		self.direction = Vector2.new(objectSpace.X, objectSpace.Z).Unit;
	end
end

function InstanceObject:Render()
	local onScreen, options = self.onScreen or false, self.options;
	local enabled = options.enabled;
	local visible, hidden, corners = self.drawings.visible, self.drawings.hidden, self.corners;

	visible.box.Visible = enabled and onScreen and options.box;
	if visible.box.Visible then
		visible.box.Position = corners.topLeft;
		visible.box.Size = corners.bottomRight - corners.topLeft;
		visible.box.Color = options.boxColor[1];
		visible.box.Transparency = options.boxColor[2];
	end

	visible.name.Visible = enabled and onScreen and options.text ~= "";
	if visible.name.Visible then
		visible.name.Text = options.text:gsub("{name}", self.instance.Name):gsub("{distance}", round(self.distance or 0));
		visible.name.Size = options.textSize;
		visible.name.Color = options.textColor[1];
		visible.name.Outline = options.textOutline;
		visible.name.Position = (corners.topLeft + corners.topRight)*0.5 - Vector2.yAxis*visible.name.TextBounds.Y - NAME_OFFSET;
	end

	hidden.arrow.Visible = enabled and (not onScreen) and options.offScreenArrow;
	hidden.arrowOutline.Visible = hidden.arrow.Visible and options.offScreenArrowOutline;
	if hidden.arrow.Visible and self.direction then
		local arrow = hidden.arrow;
		arrow.PointA = min2(max2(viewportSize*0.5 + self.direction*options.offScreenArrowRadius, Vector2.one*25), viewportSize - Vector2.one*25);
		arrow.PointB = arrow.PointA - rotateVector(self.direction, 0.45)*options.offScreenArrowSize;
		arrow.PointC = arrow.PointA - rotateVector(self.direction, -0.45)*options.offScreenArrowSize;
		arrow.Color = options.offScreenArrowColor[1];
		arrow.Transparency = options.offScreenArrowColor[2];
		hidden.arrowOutline.PointA, hidden.arrowOutline.PointB, hidden.arrowOutline.PointC = arrow.PointA, arrow.PointB, arrow.PointC;
		hidden.arrowOutline.Color = options.offScreenArrowOutlineColor[1];
		hidden.arrowOutline.Transparency = options.offScreenArrowOutlineColor[2];
	end
	
	visible.tracer.Visible = enabled and onScreen and options.tracer;
	if visible.tracer.Visible then
		visible.tracer.To = (corners.bottomLeft + corners.bottomRight)*0.5;
		visible.tracer.From = options.tracerOrigin == "Bottom" and viewportSize*Vector2.new(0.5, 1) or viewportSize*0.5;
		visible.tracer.Color = options.tracerColor[1];
	end
end

function InstanceObject:Destruct()
	for i = 1, #self.bin do self.bin[i]:Remove(); end
	clear(self);
end

-- interface functions
function EspInterface.AddInstance(instance, options)
    local finalOptions = {};
    for i, v in next, EspInterface.instanceSettings do finalOptions[i] = v; end
    if options then for i, v in next, options do finalOptions[i] = v; end end

	local obj = InstanceObject.new(instance, finalOptions);
	EspInterface._objectCache[instance] = { obj };
	return obj;
end

function EspInterface.Load()
	assert(not EspInterface._hasLoaded, "Esp has already been loaded.");

	local function createObject(player)
		if player == localPlayer then return end
		EspInterface._objectCache[player] = {
			EspObject.new(player, EspInterface),
			ChamObject.new(player, EspInterface)
		};
	end

	for _, p in next, players:GetPlayers() do 
		createObject(p);
	end

	EspInterface.playerAdded = players.PlayerAdded:Connect(createObject);
	EspInterface.playerRemoving = players.PlayerRemoving:Connect(function(player)
		local objects = EspInterface._objectCache[player];
		if objects then
			for _, obj in next, objects do 
				obj:Destruct(); 
			end
			EspInterface._objectCache[player] = nil;
		end
	end);

	EspInterface._heartbeatConnection = runService.Heartbeat:Connect(function()
		viewportSize = camera.ViewportSize;
		for _, objects in next, EspInterface._objectCache do
			for i = 1, #objects do
				local obj = objects[i];
				if obj.Update then 
					obj:Update(); 
				end

				if obj.Render then 
					obj:Render(); 
				end
			end
		end
	end);

	EspInterface._hasLoaded = true;
end

function EspInterface.Unload()
	if EspInterface._heartbeatConnection then EspInterface._heartbeatConnection:Disconnect(); end
	if EspInterface.playerAdded then EspInterface.playerAdded:Disconnect(); end
	if EspInterface.playerRemoving then EspInterface.playerRemoving:Disconnect(); end
	
	for _, objects in next, EspInterface._objectCache do
		for _, obj in next, objects do obj:Destruct(); end
	end

	clear(EspInterface._objectCache);
	EspInterface._hasLoaded = false;
end

function EspInterface.getWeapon(player) 
	return "None" 
end

function EspInterface.isFriendly(player) 
	return player.Team == localPlayer.Team 
end

function EspInterface.getTeamColor(player) 
	return player.TeamColor.Color 
end

function EspInterface.getCharacter(player) 
	return player.Character 
end

function EspInterface.getHealth(player)
	local hum = player.Character and findFirstChildOfClass(player.Character, "Humanoid");
	return hum and hum.Health or 100, hum and hum.MaxHealth or 100;
end

return EspInterface;
