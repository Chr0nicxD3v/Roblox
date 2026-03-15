--[[
╔═══════════════════════════════════════════════════════════════════╗
║              Chr0nicxFramework  ·  v4.0.0                        ║
║              Author : Chr0nicxHack3r                             ║
║              Built on KavoUI  (xHeptc/Kavo-UI-Library)          ║
╠═══════════════════════════════════════════════════════════════════╣
║  QUICK START                                                     ║
║    local UI = loadstring(...)()                                  ║
║    local Tabs = UI:CreateLib("My Script", "Default")            ║
║    local Main = Tabs:NewTab("Main")                             ║
║    local Sec  = Main:NewSection("Settings")                     ║
║    Sec:NewButton("Click Me", "Does a thing", function() end)    ║
╠═══════════════════════════════════════════════════════════════════╣
║  TOP-LEVEL API                                                   ║
║    .ConfigEnabled          bool   (set BEFORE CreateLib)        ║
║    .OnGuiDestroyed         fn(gui)                              ║
║    .OnUnload               fn()                                 ║
║    .OnConfigChanged        fn(key, value, fullTable)            ║
║                                                                  ║
║    :CreateLib(name, theme) → Tabs                               ║
║    :SetTheme(name)                                              ║
║    :ChangeColor(prop, Color3)                                   ║
║    :GetThemes()            → {string}                           ║
║    :AddCustomTheme(name, tbl)                                   ║
║    :ToggleUI()                                                  ║
║    :Notify(title, msg, duration, type)                          ║
║    :SaveConfig(immediate)                                       ║
║    :_Shutdown()                                                  ║
╠═══════════════════════════════════════════════════════════════════╣
║  TAB / SECTION / ELEMENT API                                    ║
║    Tabs:NewTab(name)            → Sections                      ║
║    Sections:NewSection(name, hidden) → Elements                 ║
║                                                                  ║
║    Elements:NewButton(name, tip, cb)       → {UpdateButton}     ║
║    Elements:NewToggle(name, tip, def, cb)  → {UpdateToggle,     ║
║                                               ApplySavedState}  ║
║    Elements:NewSlider(name,tip,max,min,val,cb) → {SetValue}     ║
║    Elements:NewTextBox(name,tip,default,cb)                     ║
║    Elements:NewDropdown(name,tip,list,cb)  → {Refresh,Select}   ║
║    Elements:NewKeybind(name,tip,key,cb)    → {GetKey,SetKey}    ║
║    Elements:NewColorPicker(name,tip,col,cb)→ {SetColor,GetColor}║
║    Elements:NewLabel(text)                 → {UpdateLabel}      ║
║    Elements:NewDivider()                                        ║
╚═══════════════════════════════════════════════════════════════════╝
]]

-- ─────────────────────────────────────────────────────────────────
--  SERVICES
-- ─────────────────────────────────────────────────────────────────
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local MakeTweenInfo = TweenInfo.new

-- ─────────────────────────────────────────────────────────────────
--  MODULE
-- ─────────────────────────────────────────────────────────────────
local Chr0nicxHack3r = {}
Chr0nicxHack3r.ConfigEnabled = false
Chr0nicxHack3r.OnGuiDestroyed = nil
Chr0nicxHack3r.OnUnload = nil
Chr0nicxHack3r.OnConfigChanged = nil
Chr0nicxHack3r._ScreenGui = nil
Chr0nicxHack3r._LibName = nil

-- ─────────────────────────────────────────────────────────────────
--  INTERNAL STATE
-- ─────────────────────────────────────────────────────────────────
local ALIVE = true
local CONFIG_VER = 4
local CONFIG_FILE = "Chr0nicxFramework_v4.json"
local SAVE_DEBOUNCE = 0.3

local Connections = {}
local ThemeListeners = {}
local SettingsT = {}
local pendingSave = false

local activeTheme = {}
local derived = {}

-- ─────────────────────────────────────────────────────────────────
--  THEME DEFINITIONS  (10 built-in themes)
-- ─────────────────────────────────────────────────────────────────
local themeStyles = {
	Default = {
		SchemeColor = Color3.fromRGB(98, 114, 164),
		Background = Color3.fromRGB(30, 31, 38),
		Header = Color3.fromRGB(22, 23, 28),
		TextColor = Color3.fromRGB(220, 221, 228),
		ElementColor = Color3.fromRGB(38, 39, 48),
	},
	DarkTheme = {
		SchemeColor = Color3.fromRGB(64, 64, 64),
		Background = Color3.fromRGB(0, 0, 0),
		Header = Color3.fromRGB(0, 0, 0),
		TextColor = Color3.fromRGB(255, 255, 255),
		ElementColor = Color3.fromRGB(20, 20, 20),
	},
	LightTheme = {
		SchemeColor = Color3.fromRGB(150, 150, 150),
		Background = Color3.fromRGB(255, 255, 255),
		Header = Color3.fromRGB(200, 200, 200),
		TextColor = Color3.fromRGB(0, 0, 0),
		ElementColor = Color3.fromRGB(224, 224, 224),
	},
	BloodTheme = {
		SchemeColor = Color3.fromRGB(227, 27, 27),
		Background = Color3.fromRGB(10, 10, 10),
		Header = Color3.fromRGB(5, 5, 5),
		TextColor = Color3.fromRGB(255, 255, 255),
		ElementColor = Color3.fromRGB(20, 20, 20),
	},
	GrapeTheme = {
		SchemeColor = Color3.fromRGB(166, 71, 214),
		Background = Color3.fromRGB(64, 50, 71),
		Header = Color3.fromRGB(36, 28, 41),
		TextColor = Color3.fromRGB(255, 255, 255),
		ElementColor = Color3.fromRGB(74, 58, 84),
	},
	Ocean = {
		SchemeColor = Color3.fromRGB(86, 76, 251),
		Background = Color3.fromRGB(26, 32, 58),
		Header = Color3.fromRGB(38, 45, 71),
		TextColor = Color3.fromRGB(200, 200, 200),
		ElementColor = Color3.fromRGB(38, 45, 71),
	},
	Midnight = {
		SchemeColor = Color3.fromRGB(26, 189, 158),
		Background = Color3.fromRGB(44, 62, 82),
		Header = Color3.fromRGB(57, 81, 105),
		TextColor = Color3.fromRGB(255, 255, 255),
		ElementColor = Color3.fromRGB(52, 74, 95),
	},
	Sentinel = {
		SchemeColor = Color3.fromRGB(230, 35, 69),
		Background = Color3.fromRGB(32, 32, 32),
		Header = Color3.fromRGB(24, 24, 24),
		TextColor = Color3.fromRGB(119, 209, 138),
		ElementColor = Color3.fromRGB(24, 24, 24),
	},
	Synapse = {
		SchemeColor = Color3.fromRGB(46, 48, 43),
		Background = Color3.fromRGB(13, 15, 12),
		Header = Color3.fromRGB(36, 38, 35),
		TextColor = Color3.fromRGB(152, 99, 53),
		ElementColor = Color3.fromRGB(24, 24, 24),
	},
	Serpent = {
		SchemeColor = Color3.fromRGB(0, 166, 58),
		Background = Color3.fromRGB(31, 41, 43),
		Header = Color3.fromRGB(22, 29, 31),
		TextColor = Color3.fromRGB(255, 255, 255),
		ElementColor = Color3.fromRGB(22, 29, 31),
	},
}

-- ─────────────────────────────────────────────────────────────────
--  COLOR UTILITIES
-- ─────────────────────────────────────────────────────────────────
local function clamp255(v)
	return math.clamp(v, 0, 255)
end

local function colorOffset(c, dr, dg, db)
	return Color3.fromRGB(
		clamp255(math.round(c.R * 255 + dr)),
		clamp255(math.round(c.G * 255 + dg)),
		clamp255(math.round(c.B * 255 + db))
	)
end

local function rebuildDerived(t)
	derived.ElementHover = colorOffset(t.ElementColor, 10, 11, 14)
	derived.ElementPressed = colorOffset(t.ElementColor, -8, -8, -9)
	derived.TooltipBg = colorOffset(t.SchemeColor, -18, -21, -16)
	derived.PlaceholderText = colorOffset(t.TextColor, -80, -80, -80)
	derived.SliderTrack = colorOffset(t.ElementColor, 7, 7, 7)
	derived.OptionTextDim = colorOffset(t.TextColor, -40, -40, -40)
	derived.Scrollbar = colorOffset(t.SchemeColor, -20, -18, -32)
	derived.SectionHead = colorOffset(t.SchemeColor, -10, -12, -10)
	derived.InputBg = colorOffset(t.ElementColor, -5, -5, -6)
	derived.DividerColor = colorOffset(t.ElementColor, 15, 15, 18)
	derived.NotifInfo = Color3.fromRGB(70, 130, 240)
	derived.NotifSuccess = Color3.fromRGB(60, 190, 100)
	derived.NotifWarn = Color3.fromRGB(230, 165, 50)
	derived.NotifError = Color3.fromRGB(210, 55, 55)
end

local function applyNamedTheme(name)
	local preset = themeStyles[name]
	if not preset then
		return false
	end
	activeTheme = {}
	for k, v in pairs(preset) do
		activeTheme[k] = v
	end
	rebuildDerived(activeTheme)
	return true
end

-- Returns a contrasting text colour for the scheme, or nil if not needed
local function schemeContrast()
	local lum = activeTheme.SchemeColor.R * 0.299
		+ activeTheme.SchemeColor.G * 0.587
		+ activeTheme.SchemeColor.B * 0.114
	if lum > 0.72 then
		return Color3.fromRGB(20, 20, 20)
	elseif lum < 0.12 then
		return Color3.fromRGB(235, 235, 235)
	end
end

applyNamedTheme("Default")

-- ─────────────────────────────────────────────────────────────────
--  CONNECTION TRACKING
-- ─────────────────────────────────────────────────────────────────
local function Track(conn)
	if conn then
		table.insert(Connections, conn)
	end
	return conn
end

-- ─────────────────────────────────────────────────────────────────
--  THEME LISTENER SYSTEM
-- ─────────────────────────────────────────────────────────────────
local function fireThemeListeners()
	for fn in pairs(ThemeListeners) do
		local ok, err = pcall(fn)
		if not ok then
			ThemeListeners[fn] = nil
			warn("[Chr0nicxFramework] Theme listener error (removed):", err)
		end
	end
end

function Chr0nicxHack3r.OnThemeChange(self, fn)
	if type(self) == "function" then
		self, fn = Chr0nicxHack3r, self
	end
	assert(type(fn) == "function", "[Chr0nicxFramework] OnThemeChange requires a function")
	ThemeListeners[fn] = true
	task.defer(fn)
end

-- ─────────────────────────────────────────────────────────────────
--  PUBLIC THEME API
-- ─────────────────────────────────────────────────────────────────
function Chr0nicxHack3r.SetTheme(self, name)
	if type(self) == "string" then
		self, name = Chr0nicxHack3r, self
	end
	if not applyNamedTheme(name) then
		warn("[Chr0nicxFramework] Unknown theme:", name)
		return
	end
	fireThemeListeners()
	if Chr0nicxHack3r.ConfigEnabled then
		SettingsT.SelectedTheme = name
		Chr0nicxHack3r.SaveConfig(Chr0nicxHack3r, false)
	end
end

function Chr0nicxHack3r.GetThemes(self)
	-- Works as  :GetThemes()  or  .GetThemes()  (self is ignored)
	local names = {}
	for k in pairs(themeStyles) do
		table.insert(names, k)
	end
	table.sort(names)
	return names
end

function Chr0nicxHack3r.AddCustomTheme(self, name, tbl)
	if type(self) == "string" then
		self, name, tbl = Chr0nicxHack3r, self, name
	end
	assert(
		type(name) == "string" and type(tbl) == "table",
		"[Chr0nicxFramework] AddCustomTheme requires (string, table)"
	)
	for _, k in ipairs({ "SchemeColor", "Background", "Header", "TextColor", "ElementColor" }) do
		assert(tbl[k], "[Chr0nicxFramework] AddCustomTheme: missing field '" .. k .. "'")
	end
	themeStyles[name] = tbl
end

function Chr0nicxHack3r.ChangeColor(self, prop, color)
	if type(self) == "string" then
		self, prop, color = Chr0nicxHack3r, self, prop
	end
	local valid = { Background = 1, SchemeColor = 1, Header = 1, TextColor = 1, ElementColor = 1 }
	if not valid[prop] then
		warn("[Chr0nicxFramework] ChangeColor: unknown property:", prop)
		return
	end
	assert(typeof(color) == "Color3", "[Chr0nicxFramework] ChangeColor: expected Color3")
	activeTheme[prop] = color
	rebuildDerived(activeTheme)
	fireThemeListeners()
end

-- ─────────────────────────────────────────────────────────────────
--  CONFIG PERSISTENCE
-- ─────────────────────────────────────────────────────────────────
local function configWrite()
	if not Chr0nicxHack3r.ConfigEnabled then
		return
	end
	pcall(function()
		SettingsT.__version = CONFIG_VER
		writefile(CONFIG_FILE, HttpService:JSONEncode(SettingsT))
	end)
end

local function configWriteDebounced()
	if not Chr0nicxHack3r.ConfigEnabled or pendingSave then
		return
	end
	pendingSave = true
	task.delay(SAVE_DEBOUNCE, function()
		pendingSave = false
		configWrite()
	end)
end

function Chr0nicxHack3r.SaveConfig(self, immediate)
	if type(self) == "boolean" then
		self, immediate = Chr0nicxHack3r, self
	end
	if immediate then
		configWrite()
	else
		configWriteDebounced()
	end
end

-- Load config on require
if Chr0nicxHack3r.ConfigEnabled then
	pcall(function()
		local raw = readfile(CONFIG_FILE)
		if not raw or raw == "" then
			return
		end
		local ok, t = pcall(HttpService.JSONDecode, HttpService, raw)
		if ok and type(t) == "table" and t.__version == CONFIG_VER then
			SettingsT = t
		end
	end)
end
if SettingsT.SelectedTheme then
	applyNamedTheme(SettingsT.SelectedTheme)
end

-- ─────────────────────────────────────────────────────────────────
--  CORE UTILITIES
-- ─────────────────────────────────────────────────────────────────
local function Tween(obj, props, t, style, dir)
	TweenService
		:Create(obj, MakeTweenInfo(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
		:Play()
end

local function New(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		pcall(function()
			inst[k] = v
		end)
	end
	return inst
end

local function Ripple(button, template, mx, my)
	if not button or not template then
		return
	end
	local c = template:Clone()
	c.Parent = button
	c.Position = UDim2.fromOffset(mx - c.AbsolutePosition.X, my - c.AbsolutePosition.Y)
	local sz = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
	c:TweenSizeAndPosition(UDim2.fromOffset(sz, sz), UDim2.new(0.5, -sz / 2, 0.5, -sz / 2), "Out", "Quad", 0.35, true)
	Tween(c, { ImageTransparency = 1 }, 0.35)
	task.delay(0.36, function()
		if c then
			c:Destroy()
		end
	end)
end

local function BindHover(button, onEnter, onLeave, focusingRef)
	Track(button.MouseEnter:Connect(function()
		if focusingRef and focusingRef() then
			return
		end
		onEnter()
	end))
	Track(button.MouseLeave:Connect(function()
		if focusingRef and focusingRef() then
			return
		end
		onLeave()
	end))
end

-- ─────────────────────────────────────────────────────────────────
--  DRAGGING
-- ─────────────────────────────────────────────────────────────────
function Chr0nicxHack3r.DraggingEnabled(self, handle, target)
	if typeof(self) == "Instance" then
		self, handle, target = Chr0nicxHack3r, self, handle
	end
	target = target or handle
	local dragging, dragInput, startMouse, startPos

	Track(handle.InputBegan:Connect(function(inp)
		if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		dragging = true
		startMouse = inp.Position
		startPos = target.Position
		Track(inp.Changed:Connect(function()
			if inp.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end))
	end))

	Track(handle.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = inp
		end
	end))

	Track(UserInputService.InputChanged:Connect(function(inp)
		if inp ~= dragInput or not dragging or not startMouse then
			return
		end
		local d = inp.Position - startMouse
		target.Position =
			UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end))
end

-- ─────────────────────────────────────────────────────────────────
--  SHUTDOWN / TOGGLE
-- ─────────────────────────────────────────────────────────────────
function Chr0nicxHack3r._Shutdown(self)
	self = (type(self) == "table" and self) or Chr0nicxHack3r
	if not ALIVE then
		return
	end
	ALIVE = false
	for _, c in ipairs(Connections) do
		pcall(function()
			c:Disconnect()
		end)
	end
	table.clear(Connections)
	table.clear(ThemeListeners)
	if self._ScreenGui then
		local gui = self._ScreenGui
		self._ScreenGui = nil
		pcall(function()
			gui:Destroy()
		end)
		if self.OnGuiDestroyed then
			pcall(self.OnGuiDestroyed, gui)
		end
	end
	self._LibName = nil
end

function Chr0nicxHack3r.ToggleUI(self)
	self = (type(self) == "table" and self) or Chr0nicxHack3r
	if self._ScreenGui then
		self._ScreenGui.Enabled = not self._ScreenGui.Enabled
	end
end

local LibName = "Chr0nicx_" .. HttpService:GenerateGUID(false):sub(1, 8)
Chr0nicxHack3r._LibName = LibName

-- ═════════════════════════════════════════════════════════════════
--  CREATE LIB
-- ═════════════════════════════════════════════════════════════════
function Chr0nicxHack3r.CreateLib(self, libName, themeArg)
	-- Normalize: accept both  UI:CreateLib(name, theme)  and  UI.CreateLib(name, theme)
	if type(self) == "string" then
		self, libName, themeArg = Chr0nicxHack3r, self, libName
	end
	assert(ALIVE, "[Chr0nicxFramework] Cannot call CreateLib after _Shutdown()")
	if themeArg and themeStyles[themeArg] then
		applyNamedTheme(themeArg)
	end
	libName = tostring(libName or "Chr0nicxFramework")

	-- ── Root ──────────────────────────────────────────────────────
	local ScreenGui = New("ScreenGui", {
		Name = LibName,
		Parent = CoreGui,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		DisplayOrder = 100,
	})
	Chr0nicxHack3r._ScreenGui = ScreenGui

	-- ── Main window ───────────────────────────────────────────────
	local Main = New("Frame", {
		Name = "Main",
		Parent = ScreenGui,
		BackgroundColor3 = activeTheme.Background,
		ClipsDescendants = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(560, 340),
	})
	New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Main })
	New("UIStroke", {
		Parent = Main,
		Color = colorOffset(activeTheme.Header, 20, 20, 25),
		Thickness = 1.2,
		Transparency = 0.55,
	})

	-- ── Header ────────────────────────────────────────────────────
	local Header = New("Frame", {
		Name = "Header",
		Parent = Main,
		BackgroundColor3 = activeTheme.Header,
		Size = UDim2.fromOffset(560, 32),
		ZIndex = 2,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Header })
	local HeaderCover = New("Frame", {
		Parent = Header,
		BackgroundColor3 = activeTheme.Header,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -7),
		Size = UDim2.fromOffset(560, 7),
	})

	local TitleLabel = New("TextLabel", {
		Parent = Header,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -70, 1, 0),
		Font = Enum.Font.GothamBold,
		RichText = true,
		Text = libName,
		TextColor3 = activeTheme.TextColor,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
	})

	local CloseBtn = New("ImageButton", {
		Parent = Header,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -28, 0.5, -10),
		Size = UDim2.fromOffset(20, 20),
		Image = "rbxassetid://3926305904",
		ImageRectOffset = Vector2.new(284, 4),
		ImageRectSize = Vector2.new(24, 24),
		ImageColor3 = activeTheme.TextColor,
		ZIndex = 5,
	})
	local MinBtn = New("ImageButton", {
		Parent = Header,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -52, 0.5, -10),
		Size = UDim2.fromOffset(20, 20),
		Image = "rbxassetid://3926305904",
		ImageRectOffset = Vector2.new(284, 124),
		ImageRectSize = Vector2.new(24, 24),
		ImageColor3 = activeTheme.TextColor,
		ZIndex = 5,
	})

	-- ── Sidebar ───────────────────────────────────────────────────
	local Sidebar = New("Frame", {
		Name = "Sidebar",
		Parent = Main,
		BackgroundColor3 = activeTheme.Header,
		Position = UDim2.new(0, 0, 0, 32),
		Size = UDim2.fromOffset(158, 308),
	})
	New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Sidebar })
	local SidebarCover = New("Frame", {
		Parent = Sidebar,
		BackgroundColor3 = activeTheme.Header,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -8, 0, 0),
		Size = UDim2.fromOffset(8, 308),
	})

	local TabContainer = New("Frame", {
		Parent = Sidebar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 8),
		Size = UDim2.fromOffset(142, 292),
		ClipsDescendants = true,
	})
	New("UIListLayout", {
		Parent = TabContainer,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
	})

	-- ── Content area ──────────────────────────────────────────────
	local ContentArea = New("Frame", {
		Parent = Main,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 166, 0, 38),
		Size = UDim2.fromOffset(386, 296),
	})
	local PagesFolder = New("Folder", { Name = "Pages", Parent = ContentArea })

	local BlurOverlay = New("Frame", {
		Parent = ContentArea,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 50,
	})

	-- Tooltip bar docked to the bottom of the window
	local TooltipBar = New("Frame", {
		Parent = Main,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 166, 1, -38),
		Size = UDim2.fromOffset(386, 38),
		ClipsDescendants = true,
		ZIndex = 60,
	})

	-- ── Dragging ──────────────────────────────────────────────────
	Chr0nicxHack3r:DraggingEnabled(Header, Main)

	-- ── Minimize ──────────────────────────────────────────────────
	local minimized = false
	Track(MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		Tween(
			Main,
			{ Size = minimized and UDim2.fromOffset(560, 32) or UDim2.fromOffset(560, 340) },
			0.22,
			Enum.EasingStyle.Quad
		)
	end))

	-- ── Close ─────────────────────────────────────────────────────
	Track(CloseBtn.MouseButton1Click:Connect(function()
		if Chr0nicxHack3r.OnUnload then
			pcall(Chr0nicxHack3r.OnUnload)
		end
		Tween(CloseBtn, { ImageTransparency = 1 }, 0.1)
		task.wait(0.1)
		Tween(Main, {
			Size = UDim2.fromOffset(0, 0),
			Position = UDim2.fromOffset(
				Main.AbsolutePosition.X + Main.AbsoluteSize.X / 2,
				Main.AbsolutePosition.Y + Main.AbsoluteSize.Y / 2
			),
		}, 0.18)
		task.wait(0.3)
		Chr0nicxHack3r:_Shutdown()
	end))

	-- ── Theme wiring (top-level) ───────────────────────────────────
	Chr0nicxHack3r:OnThemeChange(function()
		if not Main.Parent then
			return
		end
		Main.BackgroundColor3 = activeTheme.Background
		Header.BackgroundColor3 = activeTheme.Header
		HeaderCover.BackgroundColor3 = activeTheme.Header
		Sidebar.BackgroundColor3 = activeTheme.Header
		SidebarCover.BackgroundColor3 = activeTheme.Header
		TitleLabel.TextColor3 = activeTheme.TextColor
		CloseBtn.ImageColor3 = activeTheme.TextColor
		MinBtn.ImageColor3 = activeTheme.TextColor
		for _, s in ipairs(Main:GetChildren()) do
			if s:IsA("UIStroke") then
				s.Color = colorOffset(activeTheme.Header, 20, 20, 25)
			end
		end
	end)

	-- ═════════════════════════════════════════════════════════════
	--  TABS
	-- ═════════════════════════════════════════════════════════════
	local Tabs = {}
	local firstTab = true
	local activeBtn = nil

	function Tabs:NewTab(tabName)
		tabName = tostring(tabName or "Tab")

		local TabBtn = New("TextButton", {
			Parent = TabContainer,
			BackgroundColor3 = activeTheme.SchemeColor,
			BackgroundTransparency = firstTab and 0 or 1,
			Size = UDim2.fromOffset(142, 30),
			AutoButtonColor = false,
			Font = Enum.Font.Gotham,
			Text = tabName,
			TextColor3 = activeTheme.TextColor,
			TextSize = 13,
			ClipsDescendants = true,
		})
		New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = TabBtn })

		local Page = New("ScrollingFrame", {
			Parent = PagesFolder,
			Active = true,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = derived.Scrollbar,
			Visible = firstTab,
			CanvasSize = UDim2.new(0, 0, 0, 0),
		})
		local PageLayout = New("UIListLayout", {
			Parent = Page,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		})
		New("UIPadding", {
			Parent = Page,
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 8),
		})

		local function refreshCanvas()
			local cs = PageLayout.AbsoluteContentSize
			Page.CanvasSize = UDim2.new(0, cs.X, 0, cs.Y)
		end
		Track(PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshCanvas))
		refreshCanvas()

		if firstTab then
			activeBtn = TabBtn
		end
		firstTab = false

		Track(TabBtn.MouseButton1Click:Connect(function()
			for _, p in ipairs(PagesFolder:GetChildren()) do
				if p:IsA("ScrollingFrame") then
					p.Visible = false
				end
			end
			for _, b in ipairs(TabContainer:GetChildren()) do
				if b:IsA("TextButton") then
					Tween(b, { BackgroundTransparency = 1 }, 0.15)
				end
			end
			Page.Visible = true
			Tween(TabBtn, { BackgroundTransparency = 0 }, 0.15)
			activeBtn = TabBtn
		end))

		BindHover(TabBtn, function()
			if TabBtn ~= activeBtn then
				Tween(TabBtn, { BackgroundTransparency = 0.7 }, 0.1)
			end
		end, function()
			if TabBtn ~= activeBtn then
				Tween(TabBtn, { BackgroundTransparency = 1 }, 0.1)
			end
		end)

		Chr0nicxHack3r:OnThemeChange(function()
			if not Page.Parent then
				return
			end
			Page.ScrollBarImageColor3 = derived.Scrollbar
			TabBtn.TextColor3 = activeTheme.TextColor
			TabBtn.BackgroundColor3 = activeTheme.SchemeColor
		end)

		-- ═════════════════════════════════════════════════════════
		--  SECTIONS
		-- ═════════════════════════════════════════════════════════
		local Sections = {}

		function Sections:NewSection(secName, hidden)
			secName = tostring(secName or "Section")
			hidden = hidden == true

			local SecFrame = New("Frame", {
				Parent = Page,
				BackgroundColor3 = activeTheme.Background,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(378, 36),
			})
			local SecLayout = New("UIListLayout", {
				Parent = SecFrame,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
			})

			local SecHead = New("Frame", {
				Parent = SecFrame,
				BackgroundColor3 = derived.SectionHead,
				Size = UDim2.fromOffset(378, 30),
				Visible = not hidden,
				ClipsDescendants = true,
			})
			New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = SecHead })
			New("UIStroke", {
				Parent = SecHead,
				Color = colorOffset(activeTheme.SchemeColor, -5, -5, -5),
				Thickness = 1,
				Transparency = 0.7,
			})
			-- Left accent bar
			local SecAccent = New("Frame", {
				Parent = SecHead,
				BackgroundColor3 = activeTheme.SchemeColor,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 3, 1, 0),
			})

			local SecNameLbl = New("TextLabel", {
				Parent = SecHead,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -16, 1, 0),
				Font = Enum.Font.GothamSemibold,
				RichText = true,
				Text = secName,
				TextColor3 = activeTheme.TextColor,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local InnerFrame = New("Frame", {
				Parent = SecFrame,
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(378, 0),
			})
			local InnerLayout = New("UIListLayout", {
				Parent = InnerFrame,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 3),
			})

			local function resizeSection()
				InnerFrame.Size = UDim2.new(1, 0, 0, InnerLayout.AbsoluteContentSize.Y)
				SecFrame.Size = UDim2.new(0, 378, 0, SecLayout.AbsoluteContentSize.Y)
				refreshCanvas()
			end
			Track(InnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeSection))
			resizeSection()

			Chr0nicxHack3r:OnThemeChange(function()
				if not SecFrame.Parent then
					return
				end
				SecFrame.BackgroundColor3 = activeTheme.Background
				SecHead.BackgroundColor3 = derived.SectionHead
				SecNameLbl.TextColor3 = activeTheme.TextColor
				SecAccent.BackgroundColor3 = activeTheme.SchemeColor
				for _, s in ipairs(SecHead:GetChildren()) do
					if s:IsA("UIStroke") then
						s.Color = colorOffset(activeTheme.SchemeColor, -5, -5, -5)
					end
				end
			end)

			-- ── Tooltip system ────────────────────────────────────
			local focusing = false
			local tipCooldown = false

			local function showTooltip(tt)
				if tipCooldown then
					return
				end
				tipCooldown = true
				focusing = true
				for _, v in ipairs(TooltipBar:GetChildren()) do
					Tween(v, { Position = UDim2.new(0, 0, 2, 0) }, 0.18)
				end
				Tween(tt, { Position = UDim2.new(0, 0, 0, 0) }, 0.18)
				Tween(BlurOverlay, { BackgroundTransparency = 0.45 }, 0.18)
				task.wait(2)
				focusing = false
				Tween(tt, { Position = UDim2.new(0, 0, 2, 0) }, 0.18)
				Tween(BlurOverlay, { BackgroundTransparency = 1 }, 0.18)
				task.wait(0.2)
				tipCooldown = false
			end

			local function dismissTooltip()
				focusing = false
				tipCooldown = false
				for _, v in ipairs(TooltipBar:GetChildren()) do
					Tween(v, { Position = UDim2.new(0, 0, 2, 0) }, 0.18)
				end
				Tween(BlurOverlay, { BackgroundTransparency = 1 }, 0.18)
			end

			-- ── Shared builders ───────────────────────────────────
			local function makeTooltip(tip)
				local tt = New("TextLabel", {
					Parent = TooltipBar,
					BackgroundColor3 = derived.TooltipBg,
					Position = UDim2.new(0, 0, 2, 0),
					Size = UDim2.fromOffset(386, 32),
					ZIndex = 65,
					Font = Enum.Font.GothamSemibold,
					RichText = true,
					Text = "  ⓘ  " .. tip,
					TextColor3 = activeTheme.TextColor,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = tt })
				local ov = schemeContrast()
				if ov then
					tt.TextColor3 = ov
				end
				Chr0nicxHack3r:OnThemeChange(function()
					if not tt.Parent then
						return
					end
					tt.BackgroundColor3 = derived.TooltipBg
					tt.TextColor3 = activeTheme.TextColor
					local o = schemeContrast()
					if o then
						tt.TextColor3 = o
					end
				end)
				return tt
			end

			local function makeRipple(parent)
				return New("ImageLabel", {
					Parent = parent,
					BackgroundTransparency = 1,
					Image = "rbxassetid://4560909609",
					ImageColor3 = activeTheme.SchemeColor,
					ImageTransparency = 0.55,
				})
			end

			local function makeInfoBtn(parent)
				local b = New("ImageButton", {
					Parent = parent,
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -28, 0.5, -11),
					Size = UDim2.fromOffset(22, 22),
					ZIndex = 10,
					Image = "rbxassetid://3926305904",
					ImageRectOffset = Vector2.new(764, 764),
					ImageRectSize = Vector2.new(36, 36),
					ImageColor3 = activeTheme.SchemeColor,
				})
				Chr0nicxHack3r:OnThemeChange(function()
					if b.Parent then
						b.ImageColor3 = activeTheme.SchemeColor
					end
				end)
				return b
			end

			-- Standard 34px row
			local function makeRow(iconRectOffset)
				local row = New("TextButton", {
					Parent = InnerFrame,
					BackgroundColor3 = activeTheme.ElementColor,
					ClipsDescendants = true,
					Size = UDim2.fromOffset(378, 34),
					AutoButtonColor = false,
					Font = Enum.Font.SourceSans,
					Text = "",
					TextSize = 14,
				})
				New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = row })
				local icon = New("ImageLabel", {
					Name = "Icon",
					Parent = row,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0.5, -10),
					Size = UDim2.fromOffset(20, 20),
					Image = "rbxassetid://3926305904",
					ImageColor3 = activeTheme.SchemeColor,
					ImageRectOffset = iconRectOffset or Vector2.new(84, 204),
					ImageRectSize = Vector2.new(36, 36),
				})
				return row, icon
			end

			local function makeTextLabel(parent, text, xpos, width)
				return New("TextLabel", {
					Parent = parent,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, xpos or 38, 0.5, -8),
					Size = UDim2.fromOffset(width or 200, 16),
					Font = Enum.Font.GothamSemibold,
					RichText = true,
					Text = tostring(text),
					TextColor3 = activeTheme.TextColor,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
			end

			-- ─────────────────────────────────────────────────────
			--  ELEMENTS
			-- ─────────────────────────────────────────────────────
			local Elements = {}

			-- ── BUTTON ───────────────────────────────────────────
			function Elements:NewButton(bName, tip, callback)
				bName = tostring(bName or "Button")
				tip = tostring(tip or "Click to perform an action")
				callback = type(callback) == "function" and callback or function() end

				local BtnFn = {}
				local hover = false
				local Row, Icon = makeRow(Vector2.new(84, 204))
				local Lbl = makeTextLabel(Row, bName)
				local InfoBtn = makeInfoBtn(Row)
				local Rip = makeRipple(Row)
				local Tooltip = makeTooltip(tip)

				Chr0nicxHack3r:OnThemeChange(function()
					if not Row.Parent then
						return
					end
					Row.BackgroundColor3 = hover and derived.ElementHover or activeTheme.ElementColor
					Icon.ImageColor3 = activeTheme.SchemeColor
					Lbl.TextColor3 = activeTheme.TextColor
					Rip.ImageColor3 = activeTheme.SchemeColor
				end)

				BindHover(Row, function()
					hover = true
					Tween(Row, { BackgroundColor3 = derived.ElementHover }, 0.12)
				end, function()
					hover = false
					Tween(Row, { BackgroundColor3 = activeTheme.ElementColor }, 0.12)
				end, function()
					return focusing
				end)

				Track(Row.MouseButton1Down:Connect(function()
					Tween(Row, { BackgroundColor3 = derived.ElementPressed }, 0.06)
				end))
				Track(Row.MouseButton1Click:Connect(function()
					if focusing then
						dismissTooltip()
						return
					end
					Tween(Row, { BackgroundColor3 = hover and derived.ElementHover or activeTheme.ElementColor }, 0.12)
					Ripple(Row, Rip, Mouse.X, Mouse.Y)
					task.spawn(pcall, callback)
				end))
				Track(InfoBtn.MouseButton1Click:Connect(function()
					task.spawn(showTooltip, Tooltip)
				end))

				function BtnFn:UpdateButton(n)
					Lbl.Text = tostring(n or "")
				end

				resizeSection()
				return BtnFn
			end

			-- ── TOGGLE ───────────────────────────────────────────
			function Elements:NewToggle(tName, tip, default, callback)
				-- Allow 3-arg form: NewToggle(name, tip, callback)
				if type(default) == "function" and callback == nil then
					callback = default
					default = false
				end
				tName = tostring(tName or "Toggle")
				tip = tostring(tip or "Toggle this on or off")
				callback = type(callback) == "function" and callback or function() end

				local TogFn = {}
				local toggled = (Chr0nicxHack3r.ConfigEnabled and SettingsT[tName] ~= nil) and SettingsT[tName]
					or (default == true)
				local hover = false

				local Row, Icon = makeRow(Vector2.new(628, 420))
				-- No left-side icon for toggles — hide it so text fills the row cleanly
				Icon.Visible = false
				local Lbl = makeTextLabel(Row, tName, 14)
				local InfoBtn = makeInfoBtn(Row)
				local Rip = makeRipple(Row)
				local Tooltip = makeTooltip(tip)

				-- Pill indicator (right side only)
				local Pill = New("Frame", {
					Parent = Row,
					BackgroundColor3 = toggled and activeTheme.SchemeColor or derived.SliderTrack,
					Position = UDim2.new(1, -58, 0.5, -8),
					Size = UDim2.fromOffset(36, 16),
				})
				New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Pill })
				local Dot = New("Frame", {
					Parent = Pill,
					BackgroundColor3 = activeTheme.TextColor,
					Position = toggled and UDim2.new(1, -18, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
					Size = UDim2.fromOffset(12, 12),
				})
				New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Dot })

				local function syncVisual(state, animate)
					local t = animate ~= false and 0.15 or 0
					Tween(Pill, { BackgroundColor3 = state and activeTheme.SchemeColor or derived.SliderTrack }, t)
					Tween(Dot, { Position = state and UDim2.new(1, -18, 0.5, -6) or UDim2.new(0, 2, 0.5, -6) }, t)
				end

				Chr0nicxHack3r:OnThemeChange(function()
					if not Row.Parent then
						return
					end
					Row.BackgroundColor3 = hover and derived.ElementHover or activeTheme.ElementColor
					Lbl.TextColor3 = activeTheme.TextColor
					Pill.BackgroundColor3 = toggled and activeTheme.SchemeColor or derived.SliderTrack
					Dot.BackgroundColor3 = activeTheme.TextColor
					Rip.ImageColor3 = activeTheme.SchemeColor
				end)

				BindHover(Row, function()
					hover = true
					Tween(Row, { BackgroundColor3 = derived.ElementHover }, 0.12)
				end, function()
					hover = false
					Tween(Row, { BackgroundColor3 = activeTheme.ElementColor }, 0.12)
				end, function()
					return focusing
				end)

				Track(Row.MouseButton1Click:Connect(function()
					if focusing then
						dismissTooltip()
						return
					end
					toggled = not toggled
					syncVisual(toggled)
					Ripple(Row, Rip, Mouse.X, Mouse.Y)
					SettingsT[tName] = toggled
					if Chr0nicxHack3r.OnConfigChanged then
						pcall(Chr0nicxHack3r.OnConfigChanged, tName, toggled, SettingsT)
					end
					if Chr0nicxHack3r.ConfigEnabled then
						configWriteDebounced()
					end
					task.spawn(pcall, callback, toggled)
				end))
				Track(InfoBtn.MouseButton1Click:Connect(function()
					task.spawn(showTooltip, Tooltip)
				end))

				function TogFn:ApplySavedState()
					syncVisual(toggled, false)
					task.spawn(pcall, callback, toggled)
				end
				function TogFn:UpdateToggle(newName, state)
					if newName ~= nil then
						Lbl.Text = tostring(newName)
					end
					if state ~= nil then
						toggled = state == true
						syncVisual(toggled)
						task.spawn(pcall, callback, toggled)
					end
				end

				resizeSection()
				return TogFn
			end

			-- ── SLIDER ───────────────────────────────────────────
			function Elements:NewSlider(sName, tip, maxVal, minVal, startVal, callback)
				sName = tostring(sName or "Slider")
				tip = tostring(tip or "Drag to adjust")
				maxVal = tonumber(maxVal) or 100
				minVal = tonumber(minVal) or 0
				startVal = math.clamp(tonumber(startVal) or minVal, minVal, maxVal)
				callback = type(callback) == "function" and callback or function() end

				local SliderFn = {}
				local hover = false
				local dragging = false
				local curVal = startVal

				local Row, Icon = makeRow(Vector2.new(404, 164))
				local Lbl = makeTextLabel(Row, sName, 38, 130)
				local ValLbl = makeTextLabel(Row, tostring(curVal), 176, 56)
				ValLbl.TextXAlignment = Enum.TextXAlignment.Right
				ValLbl.TextColor3 = derived.OptionTextDim
				local InfoBtn = makeInfoBtn(Row)
				local Rip = makeRipple(Row)
				local Tooltip = makeTooltip(tip)

				local TrackBg = New("Frame", {
					Parent = Row,
					BackgroundColor3 = derived.SliderTrack,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 240, 0.5, -3),
					Size = UDim2.fromOffset(100, 6),
				})
				New("UICorner", { Parent = TrackBg })
				local Fill = New("Frame", {
					Parent = TrackBg,
					BackgroundColor3 = activeTheme.SchemeColor,
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(0, 6),
				})
				New("UICorner", { Parent = Fill })
				local Thumb = New("Frame", {
					Parent = TrackBg,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = activeTheme.TextColor,
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.fromOffset(10, 10),
					ZIndex = 5,
				})
				New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Thumb })
				New("UIStroke", {
					Parent = Thumb,
					Color = activeTheme.SchemeColor,
					Thickness = 1.5,
					Transparency = 0,
				})

				local function setVal(v, fire)
					v = math.clamp(math.round(v), minVal, maxVal)
					curVal = v
					local pct = (v - minVal) / math.max(1, maxVal - minVal)
					local tw = TrackBg.AbsoluteSize.X
					Fill.Size = UDim2.fromOffset(math.floor(tw * pct), 6)
					Thumb.Position = UDim2.new(0, math.floor(tw * pct), 0.5, 0)
					ValLbl.Text = tostring(v)
					if fire then
						task.spawn(pcall, callback, v)
					end
				end
				task.defer(function()
					setVal(startVal, true)
				end)

				Chr0nicxHack3r:OnThemeChange(function()
					if not Row.Parent then
						return
					end
					Row.BackgroundColor3 = hover and derived.ElementHover or activeTheme.ElementColor
					Icon.ImageColor3 = activeTheme.SchemeColor
					Fill.BackgroundColor3 = activeTheme.SchemeColor
					TrackBg.BackgroundColor3 = derived.SliderTrack
					Lbl.TextColor3 = activeTheme.TextColor
					Thumb.BackgroundColor3 = activeTheme.TextColor
					for _, s in ipairs(Thumb:GetChildren()) do
						if s:IsA("UIStroke") then
							s.Color = activeTheme.SchemeColor
						end
					end
					Rip.ImageColor3 = activeTheme.SchemeColor
				end)

				BindHover(Row, function()
					hover = true
					Tween(Row, { BackgroundColor3 = derived.ElementHover }, 0.12)
				end, function()
					hover = false
					Tween(Row, { BackgroundColor3 = activeTheme.ElementColor }, 0.12)
				end, function()
					return focusing
				end)

				Track(Row.MouseButton1Down:Connect(function()
					if focusing then
						return
					end
					dragging = true
					Tween(Thumb, { Size = UDim2.fromOffset(13, 13) }, 0.1)
					Ripple(Row, Rip, Mouse.X, Mouse.Y)
					setVal(
						minVal
							+ (maxVal - minVal)
								* math.clamp(
									(Mouse.X - TrackBg.AbsolutePosition.X) / math.max(1, TrackBg.AbsoluteSize.X),
									0,
									1
								),
						true
					)
				end))
				Track(Mouse.Move:Connect(function()
					if not dragging then
						return
					end
					setVal(
						minVal
							+ (maxVal - minVal)
								* math.clamp(
									(Mouse.X - TrackBg.AbsolutePosition.X) / math.max(1, TrackBg.AbsoluteSize.X),
									0,
									1
								),
						true
					)
				end))
				Track(UserInputService.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
						dragging = false
						Tween(Thumb, { Size = UDim2.fromOffset(10, 10) }, 0.1)
					end
				end))
				Track(InfoBtn.MouseButton1Click:Connect(function()
					task.spawn(showTooltip, Tooltip)
				end))

				function SliderFn:SetValue(v)
					setVal(v, true)
				end

				resizeSection()
				return SliderFn
			end

			-- ── TEXTBOX ──────────────────────────────────────────
			function Elements:NewTextBox(tbName, tip, default, callback)
				tbName = tostring(tbName or "TextBox")
				tip = tostring(tip or "Type and press Enter")
				default = default ~= nil and tostring(default) or ""
				callback = type(callback) == "function" and callback or function() end

				local hover = false
				local Row, Icon = makeRow(Vector2.new(324, 604))
				local Lbl = makeTextLabel(Row, tbName, 38, 152)
				local InfoBtn = makeInfoBtn(Row)
				local Tooltip = makeTooltip(tip)

				local TB = New("TextBox", {
					Parent = Row,
					BackgroundColor3 = derived.InputBg,
					BorderSizePixel = 0,
					ClipsDescendants = true,
					Position = UDim2.new(0, 200, 0.5, -10),
					Size = UDim2.fromOffset(144, 20),
					ZIndex = 5,
					ClearTextOnFocus = false,
					Font = Enum.Font.Gotham,
					PlaceholderColor3 = derived.PlaceholderText,
					PlaceholderText = "Enter value…",
					Text = default,
					TextColor3 = activeTheme.TextColor,
					TextSize = 12,
				})
				New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TB })
				New("UIPadding", { Parent = TB, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })

				Chr0nicxHack3r:OnThemeChange(function()
					if not Row.Parent then
						return
					end
					Row.BackgroundColor3 = hover and derived.ElementHover or activeTheme.ElementColor
					Icon.ImageColor3 = activeTheme.SchemeColor
					Lbl.TextColor3 = activeTheme.TextColor
					TB.BackgroundColor3 = derived.InputBg
					TB.TextColor3 = activeTheme.TextColor
					TB.PlaceholderColor3 = derived.PlaceholderText
				end)

				BindHover(Row, function()
					hover = true
					Tween(Row, { BackgroundColor3 = derived.ElementHover }, 0.12)
				end, function()
					hover = false
					Tween(Row, { BackgroundColor3 = activeTheme.ElementColor }, 0.12)
				end, function()
					return focusing
				end)

				Track(Row.MouseButton1Click:Connect(function()
					if focusing then
						dismissTooltip()
						return
					end
					TB:CaptureFocus()
				end))
				Track(TB.FocusLost:Connect(function(entered)
					if focusing then
						dismissTooltip()
					end
					if entered then
						task.spawn(pcall, callback, TB.Text)
					end
				end))
				Track(InfoBtn.MouseButton1Click:Connect(function()
					task.spawn(showTooltip, Tooltip)
				end))

				resizeSection()
			end

			-- ── DROPDOWN ─────────────────────────────────────────
			function Elements:NewDropdown(ddName, tip, list, callback)
				ddName = tostring(ddName or "Dropdown")
				tip = tostring(tip or "Select an option")
				list = type(list) == "table" and list or {}
				callback = type(callback) == "function" and callback or function() end

				local DropFn = {}
				local opened = false
				local hover = false

				local DDCont = New("Frame", {
					Parent = InnerFrame,
					BackgroundColor3 = activeTheme.Background,
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(378, 34),
					ClipsDescendants = true,
				})
				local DDLayout = New("UIListLayout", {
					Parent = DDCont,
					SortOrder = Enum.SortOrder.LayoutOrder,
				})

				local DDBtn = New("TextButton", {
					Parent = DDCont,
					BackgroundColor3 = activeTheme.ElementColor,
					Size = UDim2.fromOffset(378, 34),
					AutoButtonColor = false,
					ClipsDescendants = true,
					Font = Enum.Font.SourceSans,
					Text = "",
					TextSize = 14,
				})
				New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = DDBtn })
				New("ImageLabel", {
					Parent = DDBtn,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0.5, -10),
					Size = UDim2.fromOffset(20, 20),
					Image = "rbxassetid://3926305904",
					ImageColor3 = activeTheme.SchemeColor,
					ImageRectOffset = Vector2.new(644, 364),
					ImageRectSize = Vector2.new(36, 36),
				})
				local DDLbl = makeTextLabel(DDBtn, ddName, 38, 190)

				local SelLbl = New("TextLabel", {
					Parent = DDBtn,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 236, 0.5, -8),
					Size = UDim2.fromOffset(110, 16),
					Font = Enum.Font.GothamSemibold,
					Text = "Select…",
					TextColor3 = derived.OptionTextDim,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right,
				})
				local Chevron = New("ImageLabel", {
					Parent = DDBtn,
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -26, 0.5, -8),
					Size = UDim2.fromOffset(16, 16),
					Image = "rbxassetid://3926305904",
					ImageRectOffset = Vector2.new(964, 164),
					ImageRectSize = Vector2.new(36, 36),
					ImageColor3 = activeTheme.SchemeColor,
				})
				local InfoBtn = makeInfoBtn(DDBtn)
				local Rip = makeRipple(DDBtn)
				local Tooltip = makeTooltip(tip)

				Chr0nicxHack3r:OnThemeChange(function()
					if not DDCont.Parent then
						return
					end
					DDCont.BackgroundColor3 = activeTheme.Background
					DDBtn.BackgroundColor3 = hover and derived.ElementHover or activeTheme.ElementColor
					DDLbl.TextColor3 = activeTheme.TextColor
					SelLbl.TextColor3 = derived.OptionTextDim
					Chevron.ImageColor3 = activeTheme.SchemeColor
					for _, c in ipairs(DDBtn:GetChildren()) do
						if c:IsA("ImageLabel") then
							c.ImageColor3 = activeTheme.SchemeColor
						end
					end
				end)

				BindHover(DDBtn, function()
					hover = true
					Tween(DDBtn, { BackgroundColor3 = derived.ElementHover }, 0.12)
				end, function()
					hover = false
					Tween(DDBtn, { BackgroundColor3 = activeTheme.ElementColor }, 0.12)
				end, function()
					return focusing
				end)

				local function setOpen(state)
					opened = state
					local h = state and DDLayout.AbsoluteContentSize.Y or 34
					DDCont:TweenSize(UDim2.fromOffset(378, h), "Out", "Quad", 0.2, true)
					Tween(Chevron, { Rotation = state and 180 or 0 }, 0.2)
					task.wait(0.22)
					resizeSection()
				end

				Track(DDBtn.MouseButton1Click:Connect(function()
					if focusing then
						dismissTooltip()
						return
					end
					setOpen(not opened)
					Ripple(DDBtn, Rip, Mouse.X, Mouse.Y)
				end))
				Track(InfoBtn.MouseButton1Click:Connect(function()
					task.spawn(showTooltip, Tooltip)
				end))

				local function buildOption(v)
					local oh = false
					local Opt = New("TextButton", {
						Name = "Opt__" .. tostring(v),
						Parent = DDCont,
						BackgroundColor3 = activeTheme.ElementColor,
						Size = UDim2.fromOffset(378, 30),
						AutoButtonColor = false,
						ClipsDescendants = true,
						Font = Enum.Font.GothamSemibold,
						Text = "    " .. tostring(v),
						TextColor3 = derived.OptionTextDim,
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Left,
					})
					New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Opt })
					local OR = makeRipple(Opt)

					local ao = true
					Chr0nicxHack3r:OnThemeChange(function()
						if not ao or not Opt.Parent then
							ao = false
							return
						end
						Opt.BackgroundColor3 = oh and derived.ElementHover or activeTheme.ElementColor
						Opt.TextColor3 = derived.OptionTextDim
						OR.ImageColor3 = activeTheme.SchemeColor
					end)
					BindHover(Opt, function()
						oh = true
						Tween(Opt, { BackgroundColor3 = derived.ElementHover }, 0.1)
					end, function()
						oh = false
						Tween(Opt, { BackgroundColor3 = activeTheme.ElementColor }, 0.1)
					end, function()
						return focusing
					end)
					Track(Opt.MouseButton1Click:Connect(function()
						if focusing then
							dismissTooltip()
							return
						end
						SelLbl.Text = tostring(v)
						Ripple(Opt, OR, Mouse.X, Mouse.Y)
						task.spawn(pcall, callback, v)
						setOpen(false)
					end))
				end

				for _, v in ipairs(list) do
					buildOption(v)
				end
				resizeSection()

				function DropFn:Refresh(newList)
					newList = type(newList) == "table" and newList or {}
					for _, c in ipairs(DDCont:GetChildren()) do
						if tostring(c.Name):sub(1, 5) == "Opt__" then
							c:Destroy()
						end
					end
					for _, v in ipairs(newList) do
						buildOption(v)
					end
					DDCont:TweenSize(
						UDim2.fromOffset(378, opened and DDLayout.AbsoluteContentSize.Y or 34),
						"Out",
						"Quad",
						0.2,
						true
					)
					task.wait(0.22)
					resizeSection()
				end

				function DropFn:Select(value)
					SelLbl.Text = tostring(value)
					task.spawn(pcall, callback, value)
				end

				return DropFn
			end

			-- ── KEYBIND ──────────────────────────────────────────
			function Elements:NewKeybind(kbName, tip, defaultKey, callback)
				kbName = tostring(kbName or "Keybind")
				tip = tostring(tip or "Click to rebind")
				callback = type(callback) == "function" and callback or function() end
				if typeof(defaultKey) ~= "EnumItem" then
					defaultKey = Enum.KeyCode.F
				end

				local KeyFn = {}
				local curKey = defaultKey
				local waiting = false
				local hover = false

				local Row, Icon = makeRow(Vector2.new(364, 284))
				local Lbl = makeTextLabel(Row, kbName, 38, 192)
				local InfoBtn = makeInfoBtn(Row)
				local Rip = makeRipple(Row)
				local Tooltip = makeTooltip(tip)

				local KeyTag = New("TextLabel", {
					Parent = Row,
					BackgroundColor3 = derived.SectionHead,
					Position = UDim2.new(1, -92, 0.5, -9),
					Size = UDim2.fromOffset(62, 18),
					Font = Enum.Font.GothamSemibold,
					Text = curKey.Name,
					TextColor3 = activeTheme.SchemeColor,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 3,
				})
				New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = KeyTag })
				New("UIStroke", {
					Parent = KeyTag,
					Color = activeTheme.SchemeColor,
					Thickness = 1,
					Transparency = 0.6,
				})

				Chr0nicxHack3r:OnThemeChange(function()
					if not Row.Parent then
						return
					end
					Row.BackgroundColor3 = hover and derived.ElementHover or activeTheme.ElementColor
					Icon.ImageColor3 = activeTheme.SchemeColor
					Lbl.TextColor3 = activeTheme.TextColor
					KeyTag.BackgroundColor3 = derived.SectionHead
					KeyTag.TextColor3 = activeTheme.SchemeColor
					Rip.ImageColor3 = activeTheme.SchemeColor
					for _, s in ipairs(KeyTag:GetChildren()) do
						if s:IsA("UIStroke") then
							s.Color = activeTheme.SchemeColor
						end
					end
				end)

				BindHover(Row, function()
					hover = true
					Tween(Row, { BackgroundColor3 = derived.ElementHover }, 0.12)
				end, function()
					hover = false
					Tween(Row, { BackgroundColor3 = activeTheme.ElementColor }, 0.12)
				end, function()
					return focusing
				end)

				Track(Row.MouseButton1Click:Connect(function()
					if focusing then
						dismissTooltip()
						return
					end
					if waiting then
						return
					end
					waiting = true
					KeyTag.Text = ". . ."
					Ripple(Row, Rip, Mouse.X, Mouse.Y)
					local conn
					conn = Track(UserInputService.InputBegan:Connect(function(inp)
						if not waiting then
							return
						end
						if inp.KeyCode ~= Enum.KeyCode.Unknown and inp.KeyCode.Name ~= "Unknown" then
							curKey = inp.KeyCode
							KeyTag.Text = curKey.Name
							waiting = false
							conn:Disconnect()
						end
					end))
				end))
				Track(UserInputService.InputBegan:Connect(function(inp, gpe)
					if gpe then
						return
					end
					if inp.KeyCode == curKey then
						task.spawn(pcall, callback)
					end
				end))
				Track(InfoBtn.MouseButton1Click:Connect(function()
					task.spawn(showTooltip, Tooltip)
				end))

				function KeyFn:GetKey()
					return curKey
				end
				function KeyFn:SetKey(k)
					assert(typeof(k) == "EnumItem", "SetKey expects Enum.KeyCode")
					curKey = k
					KeyTag.Text = k.Name
				end

				resizeSection()
				return KeyFn
			end

			-- ── COLOR PICKER ─────────────────────────────────────
			function Elements:NewColorPicker(cpName, tip, defColor, callback)
				cpName = tostring(cpName or "ColorPicker")
				tip = tostring(tip or "Choose a color")
				defColor = typeof(defColor) == "Color3" and defColor or Color3.fromRGB(255, 80, 80)
				callback = type(callback) == "function" and callback or function() end

				local ColFn = {}
				local h0, s0, v0 = Color3.toHSV(defColor)
				local cs = { h0, s0, v0 }
				local expanded = false
				local rainbow = false
				local rbwT = 0
				local hover = false
				local cpDrag = false
				local dkDrag = false

				local CPRoot = New("Frame", {
					Parent = InnerFrame,
					BackgroundColor3 = activeTheme.Background,
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(378, 34),
					ClipsDescendants = true,
				})
				New("UIListLayout", { Parent = CPRoot, SortOrder = Enum.SortOrder.LayoutOrder })

				local CPHdr = New("TextButton", {
					Parent = CPRoot,
					BackgroundColor3 = activeTheme.ElementColor,
					Size = UDim2.fromOffset(378, 34),
					AutoButtonColor = false,
					ClipsDescendants = true,
					Font = Enum.Font.SourceSans,
					Text = "",
					TextSize = 14,
				})
				New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = CPHdr })
				New("ImageLabel", {
					Parent = CPHdr,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0.5, -10),
					Size = UDim2.fromOffset(20, 20),
					Image = "rbxassetid://3926305904",
					ImageColor3 = activeTheme.SchemeColor,
					ImageRectOffset = Vector2.new(44, 964),
					ImageRectSize = Vector2.new(36, 36),
				})
				makeTextLabel(CPHdr, cpName, 38, 210)
				local InfoBtn = makeInfoBtn(CPHdr)
				local Rip = makeRipple(CPHdr)
				local Tooltip = makeTooltip(tip)

				local Swatch = New("Frame", {
					Parent = CPHdr,
					BackgroundColor3 = defColor,
					Position = UDim2.new(1, -90, 0.5, -9),
					Size = UDim2.fromOffset(40, 18),
					ZIndex = 3,
				})
				New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Swatch })
				New(
					"UIStroke",
					{ Parent = Swatch, Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 0.7 }
				)

				local Panel = New("Frame", {
					Parent = CPRoot,
					BackgroundColor3 = activeTheme.ElementColor,
					Size = UDim2.fromOffset(378, 112),
					ClipsDescendants = false,
				})
				New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = Panel })

				local Picker = New("ImageButton", {
					Parent = Panel,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 8, 0.5, -44),
					Size = UDim2.fromOffset(222, 88),
					Image = "rbxassetid://6523286724",
					ZIndex = 4,
				})
				New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Picker })
				local PCur = New("ImageLabel", {
					Parent = Picker,
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(14, 14),
					Image = "rbxassetid://3926309567",
					ImageColor3 = Color3.fromRGB(0, 0, 0),
					ImageRectOffset = Vector2.new(628, 420),
					ImageRectSize = Vector2.new(48, 48),
					ZIndex = 5,
				})

				local DkBar = New("ImageButton", {
					Parent = Panel,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 238, 0.5, -44),
					Size = UDim2.fromOffset(20, 88),
					Image = "rbxassetid://6523291212",
					ZIndex = 4,
				})
				New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = DkBar })
				local DkCur = New("ImageLabel", {
					Parent = DkBar,
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(14, 14),
					Image = "rbxassetid://3926309567",
					ImageColor3 = Color3.fromRGB(0, 0, 0),
					ImageRectOffset = Vector2.new(628, 420),
					ImageRectSize = Vector2.new(48, 48),
					ZIndex = 5,
				})

				New("ImageLabel", {
					Parent = Panel,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 268, 0.5, -26),
					Size = UDim2.fromOffset(20, 20),
					Image = "rbxassetid://3926309567",
					ImageColor3 = activeTheme.SchemeColor,
					ImageRectOffset = Vector2.new(628, 420),
					ImageRectSize = Vector2.new(48, 48),
					ZIndex = 4,
				})
				local RbwOn = New("ImageLabel", {
					Parent = Panel,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 268, 0.5, -26),
					Size = UDim2.fromOffset(20, 20),
					Image = "rbxassetid://3926309567",
					ImageColor3 = activeTheme.SchemeColor,
					ImageRectOffset = Vector2.new(784, 420),
					ImageRectSize = Vector2.new(48, 48),
					ImageTransparency = 1,
					ZIndex = 5,
				})
				New("TextLabel", {
					Parent = Panel,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 262, 0.5, -4),
					Size = UDim2.fromOffset(60, 14),
					Font = Enum.Font.Gotham,
					Text = "Rainbow",
					TextColor3 = activeTheme.TextColor,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 4,
				})
				local RbwBtn = New("TextButton", {
					Parent = Panel,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 258, 0.5, -30),
					Size = UDim2.fromOffset(116, 50),
					Text = "",
					ZIndex = 6,
				})
				local HexLbl = New("TextLabel", {
					Parent = Panel,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 262, 0.5, 14),
					Size = UDim2.fromOffset(112, 14),
					Font = Enum.Font.GothamSemibold,
					Text = "#FFFFFF",
					TextColor3 = derived.OptionTextDim,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 4,
				})

				Chr0nicxHack3r:OnThemeChange(function()
					if not CPRoot.Parent then
						return
					end
					CPRoot.BackgroundColor3 = activeTheme.Background
					CPHdr.BackgroundColor3 = hover and derived.ElementHover or activeTheme.ElementColor
					Panel.BackgroundColor3 = activeTheme.ElementColor
					HexLbl.TextColor3 = derived.OptionTextDim
					for _, c in ipairs(CPHdr:GetChildren()) do
						if c:IsA("TextLabel") then
							c.TextColor3 = activeTheme.TextColor
						end
						if c:IsA("ImageLabel") then
							c.ImageColor3 = activeTheme.SchemeColor
						end
					end
					for _, c in ipairs(Panel:GetChildren()) do
						if c:IsA("TextLabel") then
							c.TextColor3 = activeTheme.TextColor
						end
						if c:IsA("ImageLabel") then
							c.ImageColor3 = activeTheme.SchemeColor
						end
					end
				end)

				BindHover(CPHdr, function()
					hover = true
					Tween(CPHdr, { BackgroundColor3 = derived.ElementHover }, 0.12)
				end, function()
					hover = false
					Tween(CPHdr, { BackgroundColor3 = activeTheme.ElementColor }, 0.12)
				end, function()
					return focusing
				end)

				Track(CPHdr.MouseButton1Click:Connect(function()
					if focusing then
						dismissTooltip()
						return
					end
					expanded = not expanded
					CPRoot:TweenSize(UDim2.fromOffset(378, expanded and 146 or 34), "Out", "Quad", 0.2, true)
					Ripple(CPHdr, Rip, Mouse.X, Mouse.Y)
					task.wait(0.22)
					resizeSection()
				end))
				Track(InfoBtn.MouseButton1Click:Connect(function()
					task.spawn(showTooltip, Tooltip)
				end))

				local function zigzag(x)
					return math.acos(math.cos(x * math.pi)) / math.pi
				end
				local function toHex(c)
					return string.format(
						"#%02X%02X%02X",
						math.round(c.R * 255),
						math.round(c.G * 255),
						math.round(c.B * 255)
					)
				end
				local function applyColor()
					local col = Color3.fromHSV(cs[1], cs[2], cs[3])
					Swatch.BackgroundColor3 = col
					HexLbl.Text = toHex(col)
					task.spawn(pcall, callback, col)
				end
				local function syncCur()
					local cx, cy = PCur.AbsoluteSize.X / 2, PCur.AbsoluteSize.Y / 2
					PCur.Position = UDim2.new(1 - cs[1], -cx, 1 - cs[2], -cy)
					DkCur.Position = UDim2.new(0.5, 0, 1 - cs[3], -DkCur.AbsoluteSize.Y / 2)
				end
				local function samplePicker()
					if not cpDrag then
						return
					end
					local x = math.clamp(Mouse.X - Picker.AbsolutePosition.X, 0, Picker.AbsoluteSize.X)
					local y = math.clamp(Mouse.Y - Picker.AbsolutePosition.Y, 0, Picker.AbsoluteSize.Y)
					cs[1] = 1 - x / math.max(1, Picker.AbsoluteSize.X)
					cs[2] = 1 - y / math.max(1, Picker.AbsoluteSize.Y)
					PCur.Position = UDim2.new(0, x - PCur.AbsoluteSize.X / 2, 0, y - PCur.AbsoluteSize.Y / 2)
					applyColor()
				end
				local function sampleDark()
					if not dkDrag then
						return
					end
					local y = math.clamp(Mouse.Y - DkBar.AbsolutePosition.Y, 0, DkBar.AbsoluteSize.Y)
					local p = y / math.max(1, DkBar.AbsoluteSize.Y)
					cs[3] = 1 - p
					DkCur.Position = UDim2.new(0.5, 0, 0, y - DkCur.AbsoluteSize.Y / 2)
					DkCur.ImageColor3 = Color3.fromHSV(0, 0, p)
					applyColor()
				end

				Track(Mouse.Move:Connect(function()
					samplePicker()
					sampleDark()
				end))
				Track(Picker.MouseButton1Down:Connect(function()
					cpDrag = true
				end))
				Track(DkBar.MouseButton1Down:Connect(function()
					dkDrag = true
				end))
				Track(UserInputService.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then
						cpDrag = false
						dkDrag = false
					end
				end))
				Track(RbwBtn.MouseButton1Click:Connect(function()
					rainbow = not rainbow
					Tween(RbwOn, { ImageTransparency = rainbow and 0 or 1 }, 0.12, Enum.EasingStyle.Linear)
				end))
				Track(RunService.RenderStepped:Connect(function(dt)
					if not rainbow or not CPRoot.Parent then
						return
					end
					rbwT = rbwT + dt * 0.5
					cs[1] = zigzag(rbwT)
					cs[2] = 1
					syncCur()
					applyColor()
				end))
				task.defer(function()
					syncCur()
					applyColor()
				end)
				resizeSection()

				function ColFn:SetColor(c3)
					assert(typeof(c3) == "Color3", "SetColor expects Color3")
					local h, s, v = Color3.toHSV(c3)
					cs = { h, s, v }
					syncCur()
					applyColor()
				end
				function ColFn:GetColor()
					return Color3.fromHSV(cs[1], cs[2], cs[3])
				end
				return ColFn
			end

			-- ── LABEL ────────────────────────────────────────────
			function Elements:NewLabel(text)
				text = tostring(text or "")
				local LblFn = {}
				local Lbl = New("TextLabel", {
					Parent = InnerFrame,
					BackgroundColor3 = activeTheme.SchemeColor,
					BorderSizePixel = 0,
					ClipsDescendants = true,
					Size = UDim2.fromOffset(378, 28),
					Font = Enum.Font.GothamSemibold,
					RichText = true,
					Text = "  " .. text,
					TextColor3 = activeTheme.TextColor,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = Lbl })
				local ov = schemeContrast()
				if ov then
					Lbl.TextColor3 = ov
				end
				Chr0nicxHack3r:OnThemeChange(function()
					if not Lbl.Parent then
						return
					end
					Lbl.BackgroundColor3 = activeTheme.SchemeColor
					Lbl.TextColor3 = activeTheme.TextColor
					local o = schemeContrast()
					if o then
						Lbl.TextColor3 = o
					end
				end)
				function LblFn:UpdateLabel(t)
					Lbl.Text = "  " .. tostring(t or "")
				end
				resizeSection()
				return LblFn
			end

			-- ── DIVIDER ──────────────────────────────────────────
			function Elements:NewDivider()
				local Div = New("Frame", {
					Parent = InnerFrame,
					BackgroundColor3 = derived.DividerColor,
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(378, 1),
				})
				New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Div })
				Chr0nicxHack3r:OnThemeChange(function()
					if Div.Parent then
						Div.BackgroundColor3 = derived.DividerColor
					end
				end)
				resizeSection()
			end

			return Elements
		end -- NewSection
		return Sections
	end -- NewTab

	-- ═════════════════════════════════════════════════════════════
	--  NOTIFICATION SYSTEM
	-- ═════════════════════════════════════════════════════════════
	local NOTIF_W = 330
	local NOTIF_PAD = 10
	local MAX_NOTIFS = 6

	local NotifHolder = New("Frame", {
		Name = "NotifHolder",
		Parent = ScreenGui,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -12, 1, -12),
		Size = UDim2.new(0, NOTIF_W, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 500,
	})
	New("UIListLayout", {
		Parent = NotifHolder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 6),
	})

	--[[
        Notify(title, message, duration, type)
        type: "default" | "info" | "success" | "warning" | "error"
    ]]
	function Chr0nicxHack3r.Notify(self, titleText, messageText, duration, notifType)
		-- Accept both  :Notify(...)  and  .Notify(...)
		if type(self) == "string" then
			self, titleText, messageText, duration, notifType = Chr0nicxHack3r, self, titleText, messageText, duration
		end
		if not ALIVE then
			return
		end

		-- Prune oldest if at cap
		local list = {}
		for _, c in ipairs(NotifHolder:GetChildren()) do
			if c:IsA("Frame") then
				table.insert(list, c)
			end
		end
		if #list >= MAX_NOTIFS then
			table.sort(list, function(a, b)
				return a.AbsolutePosition.Y < b.AbsolutePosition.Y
			end)
			list[1]:Destroy()
		end

		titleText = tostring(titleText or "Notification")
		messageText = tostring(messageText or "")
		duration = math.max(0.5, tonumber(duration) or 4)
		notifType = tostring(notifType or "default")

		local accent = activeTheme.SchemeColor
		if notifType == "info" then
			accent = derived.NotifInfo
		end
		if notifType == "success" then
			accent = derived.NotifSuccess
		end
		if notifType == "warning" then
			accent = derived.NotifWarn
		end
		if notifType == "error" then
			accent = derived.NotifError
		end

		-- Measure text
		local msr = New("TextLabel", {
			Parent = ScreenGui,
			BackgroundTransparency = 1,
			TextWrapped = true,
			RichText = true,
			Size = UDim2.fromOffset(NOTIF_W - NOTIF_PAD * 2 - 6, 800),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			Text = titleText,
		})
		local tH = msr.TextBounds.Y
		msr.Font = Enum.Font.Gotham
		msr.TextSize = 12
		msr.Text = messageText
		local mH = messageText ~= "" and msr.TextBounds.Y or 0
		msr:Destroy()

		local totalH = tH + (mH > 0 and mH + 4 or 0) + NOTIF_PAD * 2

		local Notif = New("Frame", {
			Parent = NotifHolder,
			BackgroundColor3 = activeTheme.ElementColor,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			ZIndex = 501,
			Size = UDim2.fromOffset(NOTIF_W, totalH),
		})
		New("UICorner", { CornerRadius = UDim.new(0, 7), Parent = Notif })
		New("UIStroke", { Parent = Notif, Color = accent, Thickness = 1, Transparency = 0.6 })

		New("Frame", {
			Name = "Accent",
			Parent = Notif,
			BackgroundColor3 = accent,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 4, 1, 0),
			ZIndex = 502,
		})

		local ProgBg = New("Frame", {
			Parent = Notif,
			BackgroundColor3 = colorOffset(activeTheme.ElementColor, 10, 10, 12),
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 4, 1, 0),
			Size = UDim2.new(1, -4, 0, 3),
			ZIndex = 502,
		})
		local ProgFill = New("Frame", {
			Parent = ProgBg,
			BackgroundColor3 = accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 503,
		})

		local NTitle = New("TextLabel", {
			Parent = Notif,
			BackgroundTransparency = 1,
			TextWrapped = true,
			RichText = true,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = activeTheme.TextColor,
			Text = titleText,
			Position = UDim2.fromOffset(NOTIF_PAD + 4, NOTIF_PAD),
			Size = UDim2.fromOffset(NOTIF_W - NOTIF_PAD * 2 - 6, tH),
			ZIndex = 502,
		})
		local NMsg
		if mH > 0 then
			NMsg = New("TextLabel", {
				Parent = Notif,
				BackgroundTransparency = 1,
				TextWrapped = true,
				RichText = true,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextColor3 = derived.OptionTextDim,
				Text = messageText,
				Position = UDim2.fromOffset(NOTIF_PAD + 4, NOTIF_PAD + tH + 4),
				Size = UDim2.fromOffset(NOTIF_W - NOTIF_PAD * 2 - 6, mH),
				ZIndex = 502,
			})
		end

		-- Slide in
		Notif.Position = UDim2.fromOffset(NOTIF_W + 20, 0)
		Tween(Notif, { Position = UDim2.fromOffset(0, 0), BackgroundTransparency = 0 }, 0.22)

		-- Shrinking progress bar
		Tween(ProgFill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)

		local alive = true
		Chr0nicxHack3r:OnThemeChange(function()
			if not alive or not Notif.Parent then
				alive = false
				return
			end
			Notif.BackgroundColor3 = activeTheme.ElementColor
			Notif.Accent.BackgroundColor3 = accent
			NTitle.TextColor3 = activeTheme.TextColor
			if NMsg then
				NMsg.TextColor3 = derived.OptionTextDim
			end
		end)

		task.delay(duration, function()
			if not alive then
				return
			end
			alive = false
			if Notif and Notif.Parent then
				Tween(Notif, { Position = UDim2.fromOffset(NOTIF_W + 20, 0), BackgroundTransparency = 1 }, 0.22)
				task.wait(0.25)
				if Notif then
					Notif:Destroy()
				end
			end
		end)
	end

	-- ── Open animation ────────────────────────────────────────────
	Main.Size = UDim2.fromOffset(0, 0)
	Main.Position = UDim2.new(0.5, 0, 0.5, 0)
	Tween(Main, { Size = UDim2.fromOffset(560, 340) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	return Tabs
end -- CreateLib

return Chr0nicxHack3r