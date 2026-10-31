--Remote spy
local G2L = {};

getgenv().Code = ""

-- Every connection the spy makes, so closing it can undo all of them
local spyConnections = {}
local function track(conn)
	table.insert(spyConnections, conn)
	return conn
end

local activityFilter = {
    ["RE/SyncProfile"] = true,
    ["RE/BrainrotCatchFish"] = true,
	["RE/GiantBrainrotCatchFish"] = true,
}

local function isFiltered(remote)
    return activityFilter[remote.Name] == true
end

-- StarterGui.Remote Spy
G2L["1"] = Instance.new("ScreenGui", game.CoreGui);
G2L["1"]["Name"] = [[Remote Spy]];
G2L["1"]["ResetOnSpawn"] = false
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;

local UserInputService = game:GetService("UserInputService")

local guiVisible = true
local holdingShift = false

track(UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		holdingShift = true
	end

	if holdingShift and input.KeyCode == Enum.KeyCode.H then
		guiVisible = not guiVisible
		G2L["1"].Enabled = guiVisible
	end
end))

track(UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		holdingShift = false
	end
end))

-- StarterGui.Remote Spy.Frame
G2L["2"] = Instance.new("Frame", G2L["1"]);
G2L["2"]["BorderSizePixel"] = 0;
G2L["2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["2"]["Size"] = UDim2.new(0, 750, 0, 500);
G2L["2"]["Position"] = UDim2.new(0.02067, 0, 0.17804, 0);
G2L["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = G2L["2"]

-- StarterGui.Remote Spy.Frame.TopBar
G2L["3"] = Instance.new("Frame", G2L["2"]);
G2L["3"]["BorderSizePixel"] = 0;
G2L["3"]["BackgroundColor3"] = Color3.fromRGB(38, 36, 39);
G2L["3"]["Size"] = UDim2.new(1, 0, 0, 28);
G2L["3"]["Position"] = UDim2.new(0, 0, 0, 0);
G2L["3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3"]["Name"] = [[TopBar]];
G2L["3"].Active = true

-- StarterGui.Remote Spy.Frame.TopBar.Name
G2L["4"] = Instance.new("TextLabel", G2L["3"]);
G2L["4"]["BorderSizePixel"] = 0;
G2L["4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4"]["TextSize"] = 14;
G2L["4"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["4"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4"]["BackgroundTransparency"] = 1;
G2L["4"]["Size"] = UDim2.new(0, 58, 0, 28);
G2L["4"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4"]["Text"] = [[Remote Spy]];
G2L["4"]["Name"] = [[Name]];
G2L["4"]["Position"] = UDim2.new(0.020, 0, 0.07, 0);

-- StarterGui.Remote Spy.Frame.TopBar.X
G2L["5"] = Instance.new("TextButton", G2L["3"]);
G2L["5"]["BorderSizePixel"] = 0;
G2L["5"]["TextStrokeColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5"]["TextSize"] = 21;
G2L["5"]["TextColor3"] = Color3.fromRGB(205, 205, 205);
G2L["5"]["BackgroundColor3"] = Color3.fromRGB(38, 36, 39);
G2L["5"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["5"]["RichText"] = true;
G2L["5"]["Size"] = UDim2.new(0, 24, 0, 28);
G2L["5"]["Name"] = [[X]];
G2L["5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5"]["Text"] = [[X]];
G2L["5"]["Position"] = UDim2.new(1, -25, 0, 0);

-- StarterGui.Remote Spy.Frame.Buttons
G2L["6"] = Instance.new("Frame", G2L["2"]);
G2L["6"]["BorderSizePixel"] = 0;
G2L["6"]["BackgroundColor3"] = Color3.fromRGB(75, 75, 75);
G2L["6"]["Size"] = UDim2.new(1, -220, 0, 36);
G2L["6"]["Position"] = UDim2.new(0, 220, 1, -36);
G2L["6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["6"]["Name"] = [[Buttons]];

local btnLayout = Instance.new("UIListLayout", G2L["6"])
btnLayout.FillDirection = Enum.FillDirection.Horizontal
btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
btnLayout.Padding = UDim.new(0, 12)

-- StarterGui.Remote Spy.Frame.Buttons.CopyR
G2L["7"] = Instance.new("TextButton", G2L["6"]);
G2L["7"]["TextSize"] = 14;
G2L["7"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["7"]["BackgroundColor3"] = Color3.fromRGB(27, 27, 29);
G2L["7"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["7"]["Size"] = UDim2.new(0, 93, 0, 22);
G2L["7"]["Name"] = [[CopyR]];
G2L["7"]["BorderColor3"] = Color3.fromRGB(139, 139, 139);
G2L["7"]["Text"] = [[Copy Remote]];
G2L["7"]["Position"] = UDim2.new(0.32967, 0, 0.08491, 0);

-- StarterGui.Remote Spy.Frame.Buttons.CopyR.Border
G2L["8"] = Instance.new("TextLabel", G2L["7"]);
G2L["8"]["BorderSizePixel"] = 0;
G2L["8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["8"]["TextSize"] = 14;
G2L["8"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["8"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["8"]["Size"] = UDim2.new(0, 8, 0, 22);
G2L["8"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["8"]["Text"] = [[]];
G2L["8"]["Name"] = [[Border]];

-- StarterGui.Remote Spy.Frame.Buttons.CopyC
G2L["9"] = Instance.new("TextButton", G2L["6"]);
G2L["9"]["TextSize"] = 14;
G2L["9"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["9"]["BackgroundColor3"] = Color3.fromRGB(27, 27, 29);
G2L["9"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["9"]["Size"] = UDim2.new(0, 83, 0, 22);
G2L["9"]["Name"] = [[CopyC]];
G2L["9"]["BorderColor3"] = Color3.fromRGB(139, 139, 139);
G2L["9"]["Text"] = [[Copy Code]];
G2L["9"]["Position"] = UDim2.new(0, 0, 0.08491, 0);

G2L["9"].MouseButton1Click:Connect(function()


	if setclipboard then

	setclipboard(getgenv().Code)

	else
		print("Your executer doesn't support clipboard")
	end
end)

-- StarterGui.Remote Spy.Frame.Buttons.CopyC.Border
G2L["a"] = Instance.new("TextLabel", G2L["9"]);
G2L["a"]["BorderSizePixel"] = 0;
G2L["a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a"]["TextSize"] = 14;
G2L["a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["a"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["a"]["Size"] = UDim2.new(0, 8, 0, 22);
G2L["a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["a"]["Text"] = [[]];
G2L["a"]["Name"] = [[Border]];

-- StarterGui.Remote Spy.Frame.Buttons.Run
G2L["b"] = Instance.new("TextButton", G2L["6"]);
G2L["b"]["TextSize"] = 14;
G2L["b"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["b"]["BackgroundColor3"] = Color3.fromRGB(27, 27, 29);
G2L["b"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["b"]["Size"] = UDim2.new(0, 81, 0, 22);
G2L["b"]["Name"] = [[Run]];
G2L["b"]["BorderColor3"] = Color3.fromRGB(139, 139, 139);
G2L["b"]["Text"] = [[Run Code]];
G2L["b"]["Position"] = UDim2.new(0.7033, 0, 0.08491, 0);

-- StarterGui.Remote Spy.Frame.Buttons.Run.Border
G2L["c"] = Instance.new("TextLabel", G2L["b"]);
G2L["c"]["BorderSizePixel"] = 0;
G2L["c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["c"]["TextSize"] = 14;
G2L["c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["c"]["Size"] = UDim2.new(0, 8, 0, 22);
G2L["c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["c"]["Text"] = [[]];
G2L["c"]["Name"] = [[Border]];

G2L["d2"] = Instance.new("TextButton", G2L["6"]);
G2L["d2"]["TextSize"] = 14;
G2L["d2"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["d2"]["BackgroundColor3"] = Color3.fromRGB(27, 27, 29);
G2L["d2"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["d2"]["Size"] = UDim2.new(0, 83, 0, 22);
G2L["d2"]["Name"] = [[Clear]];
G2L["d2"]["BorderColor3"] = Color3.fromRGB(139, 139, 139);
G2L["d2"]["Text"] = [[Clear Output]];
G2L["d2"]["Position"] = UDim2.new(0, 0, 0.33962, 0);

G2L["e2"] = Instance.new("TextLabel", G2L["d2"]);
G2L["e2"]["BorderSizePixel"] = 0;
G2L["e2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["e2"]["TextSize"] = 14;
G2L["e2"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["e2"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["e2"]["Size"] = UDim2.new(0, 8, 0, 22);
G2L["e2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["e2"]["Text"] = [[]];
G2L["e2"]["Name"] = [[Border]];

-- StarterGui.Remote Spy.Frame.Remotes
G2L["d"] = Instance.new("ScrollingFrame", G2L["2"]);
G2L["d"]["Active"] = true;
G2L["d"]["BorderSizePixel"] = 0;
G2L["d"]["CanvasSize"] = UDim2.new(9999, 9999, 9999, 9999);
G2L["d"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 56);
G2L["d"]["Name"] = [[Remotes]];
G2L["d"]["ScrollBarImageTransparency"] = 1;
G2L["d"]["Size"] = UDim2.new(0, 220, 1, -28);
G2L["d"]["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0);
G2L["d"]["Position"] = UDim2.new(0, 0, 0, 28);
G2L["d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["d"]["ScrollBarThickness"] = 0;
G2L["d"]["LayoutOrder"] = 1;

-- StarterGui.Remote Spy.Frame.Remotes.RemoteExample
G2L["e"] = Instance.new("TextButton", G2L["d"]);
G2L["e"]["BorderSizePixel"] = 3;
G2L["e"]["TextSize"] = 14;
G2L["e"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
G2L["e"]["Size"] = UDim2.new(0, 152, 0, 22);
G2L["e"]["BackgroundTransparency"] = 0.8;
G2L["e"]["Name"] = [[RemoteExample]];
G2L["e"]["BorderColor3"] = Color3.fromRGB(93, 96, 102);
G2L["e"]["Text"] = [[RemoteName]];

-- StarterGui.Remote Spy.Frame.Remotes.RemoteExample.border
G2L["f"] = Instance.new("TextLabel", G2L["e"]);
G2L["f"]["BorderSizePixel"] = 0;
G2L["f"]["BackgroundColor3"] = Color3.fromRGB(253, 242, 81);
G2L["f"]["TextSize"] = 14;
G2L["f"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["f"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["f"]["Size"] = UDim2.new(0, 10, 0, 22);
G2L["f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["f"]["Text"] = [[]];
G2L["f"]["Name"] = [[border]];

-- StarterGui.Remote Spy.Frame.Remotes.UIListLayout
G2L["10"] = Instance.new("UIListLayout", G2L["d"]);
G2L["10"]["Padding"] = UDim.new(0, 7);
G2L["10"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

-- StarterGui.Remote Spy.Frame.CodeSample
G2L["11"] = Instance.new("TextBox", G2L["2"]);
G2L["11"]["CursorPosition"] = -1;
G2L["11"]["Interactable"] = false;
G2L["11"]["TextColor3"] = Color3.fromRGB(235, 235, 235);
G2L["11"]["BorderSizePixel"] = 0;
G2L["11"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["11"]["TextWrapped"] = true;
G2L["11"]["TextSize"] = 15;
G2L["11"]["Name"] = [[CodeSample]];

-- Add inner padding to CodeSample
local codePadding = Instance.new("UIPadding")
codePadding.PaddingLeft = UDim.new(0, 10) -- adjust (8–14 feels good)
codePadding.PaddingTop = UDim.new(0, 6)
codePadding.Parent = G2L["11"]

G2L["11"]["TextYAlignment"] = Enum.TextYAlignment.Top;
G2L["11"]["BackgroundColor3"] = Color3.fromRGB(42, 45, 54);
G2L["11"]["FontFace"] = Font.new([[rbxasset://fonts/families/Balthazar.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["11"]["MultiLine"] = true;
G2L["11"]["ClearTextOnFocus"] = false;
G2L["11"]["Size"] = UDim2.new(1, -220, 1, -64);
G2L["11"]["Position"] = UDim2.new(0, 220, 0, 28);
G2L["11"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["11"]["Text"] = [[]];

print("Made by Danechka")
print("Modified by Chr0nicxHack3r")
print("https://rscripts.net/@danechka")

-- StarterGui.Remote Spy.Frame.Drag
G2L["12"] = Instance.new("LocalScript", G2L["2"]);
G2L["12"]["Name"] = [[Drag]];

-- StarterGui.Remote Spy.Frame.Main
G2L["13"] = Instance.new("LocalScript", G2L["2"]);
G2L["13"]["Name"] = [[Main]];

-- Detached copy of the list-entry template, so "Clear Output" can remove the
-- placeholder entry without breaking the clones made for later events.
local entryTemplate = G2L["e"]:Clone()

local selectedRemotePath = nil
local hookedCallbacks = {} -- [RemoteFunction] = { original = fn, wrapper = fn }
local spyClosed = false

local function shutdownSpy()
	if spyClosed then
		return
	end
	spyClosed = true
	for _, conn in ipairs(spyConnections) do
		conn:Disconnect()
	end
	table.clear(spyConnections)
	-- Hand each RemoteFunction back to the game's own handler, unless the game
	-- has assigned a newer one since we hooked it.
	for remote, hook in pairs(hookedCallbacks) do
		pcall(function()
			if getcallbackvalue(remote, "OnClientInvoke") == hook.wrapper then
				remote.OnClientInvoke = hook.original
			end
		end)
	end
	table.clear(hookedCallbacks)
	G2L["1"]:Destroy()
end

-- StarterGui.Remote Spy.Frame.Drag
local function C_12()
local script = G2L["12"];
	local frame = script.Parent
	local dragArea = frame.TopBar
	local UserInputService = game:GetService("UserInputService")

	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	track(dragArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			-- One listener per drag, released when the drag ends
			local endConn
			endConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					endConn:Disconnect()
				end
			end)
		end
	end))

	track(dragArea.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end))

	track(UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end))

end;
task.spawn(C_12);
-- StarterGui.Remote Spy.Frame.Main
local function C_13()
local script = G2L["13"];
	local TweenService = game:GetService("TweenService")

	local MainFrame = script.Parent
	local TopBar = MainFrame.TopBar

	local function SetupButtons()

		TopBar.X.MouseEnter:Connect(function()
			TweenService:Create(TopBar.X, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(170, 0, 0)}):Play()
		end)

		TopBar.X.MouseLeave:Connect(function()
			TweenService:Create(TopBar.X, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(37, 35, 38)}):Play()
		end)

		TopBar.X.MouseButton1Click:Connect(shutdownSpy)

		MainFrame.Buttons.Clear.MouseButton1Click:Connect(function()

			for _,v in pairs(MainFrame.Remotes:GetChildren()) do
				if v:IsA("TextButton") then
					v:Destroy()
				end
			end

		end)

		MainFrame.Buttons.CopyR.MouseButton1Click:Connect(function()
			if not selectedRemotePath then
				print("[Remote Spy] Select a remote first")
				return
			end
			if setclipboard then
				setclipboard(selectedRemotePath)
			else
				print("Your executer doesn't support clipboard")
			end
		end)

		MainFrame.Buttons.Run.MouseButton1Click:Connect(function()
			local code = getgenv().Code
			if code == "" then
				print("[Remote Spy] Select a remote first")
				return
			end
			local chunk, compileErr = loadstring(code)
			if not chunk then
				warn("[Remote Spy] Code failed to compile:", compileErr)
				return
			end
			local ok, runErr = pcall(chunk)
			if not ok then
				warn("[Remote Spy] Code errored:", runErr)
			end
		end)

	end

	SetupButtons()
end;
task.spawn(C_13);

-- ── Code generation ──────────────────────────────────────────────
local LUA_KEYWORDS = {
	["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true, ["elseif"] = true,
	["end"] = true, ["false"] = true, ["for"] = true, ["function"] = true, ["if"] = true,
	["in"] = true, ["local"] = true, ["nil"] = true, ["not"] = true, ["or"] = true,
	["repeat"] = true, ["return"] = true, ["then"] = true, ["true"] = true, ["until"] = true,
	["while"] = true, ["continue"] = true,
}

local function isIdentifier(name)
	return type(name) == "string" and name:match("^[%a_][%w_]*$") ~= nil and not LUA_KEYWORDS[name]
end

-- Runnable path: game:GetService("ReplicatedStorage").Remotes["Some Remote"]
local function instancePath(instance)
	local segments = {}
	local current = instance
	while current and current ~= game do
		local parent = current.Parent
		if parent == game then
			table.insert(segments, 1, string.format("game:GetService(%q)", current.ClassName))
			return table.concat(segments)
		end
		local name = current.Name
		table.insert(segments, 1, isIdentifier(name) and ("." .. name) or string.format("[%q]", name))
		current = parent
	end
	if current == game then
		return "game" .. table.concat(segments)
	end
	return string.format("nil --[[ %s is not in the game tree ]]", instance:GetFullName())
end

local MAX_DEPTH = 6

local function serialize(value, depth, seen)
	local kind = typeof(value)
	if kind == "string" then
		return string.format("%q", value)
	elseif kind == "number" then
		if value ~= value then
			return "0/0"
		elseif value == math.huge then
			return "math.huge"
		elseif value == -math.huge then
			return "-math.huge"
		end
		return tostring(value)
	elseif kind == "boolean" or kind == "nil" then
		return tostring(value)
	elseif kind == "Instance" then
		return instancePath(value)
	elseif kind == "EnumItem" then
		return tostring(value)
	elseif kind == "Vector3" then
		return string.format("Vector3.new(%s, %s, %s)", value.X, value.Y, value.Z)
	elseif kind == "Vector2" then
		return string.format("Vector2.new(%s, %s)", value.X, value.Y)
	elseif kind == "CFrame" then
		return "CFrame.new(" .. table.concat({ value:GetComponents() }, ", ") .. ")"
	elseif kind == "Color3" then
		return string.format("Color3.new(%s, %s, %s)", value.R, value.G, value.B)
	elseif kind == "UDim2" then
		return string.format("UDim2.new(%s, %s, %s, %s)", value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset)
	elseif kind == "table" then
		seen = seen or {}
		depth = depth or 0
		if seen[value] then
			return '"<cycle>"'
		end
		if depth >= MAX_DEPTH then
			return '"<max depth>"'
		end
		seen[value] = true
		local parts = {}
		local n = #value
		for i = 1, n do
			parts[#parts + 1] = serialize(value[i], depth + 1, seen)
		end
		for k, v in pairs(value) do
			local isArrayIndex = type(k) == "number" and k >= 1 and k <= n and k % 1 == 0
			if not isArrayIndex then
				local key = isIdentifier(k) and k or ("[" .. serialize(k, depth + 1, seen) .. "]")
				parts[#parts + 1] = key .. " = " .. serialize(v, depth + 1, seen)
			end
		end
		seen[value] = nil
		return "{" .. table.concat(parts, ", ") .. "}"
	end
	-- Anything without a constructor form is emitted as a readable string
	return string.format("%q", tostring(value))
end

local function buildCode(args, path, method)
	local lines = {}
	for i = 1, args.n do
		lines[i] = string.format("[%d] = %s", i, serialize(args[i]))
	end
	return string.format(
		"local args = {\n    %s\n}\n%s:%s(table.unpack(args, 1, %d))",
		table.concat(lines, ",\n    "),
		path,
		method,
		args.n
	)
end

local function addEntry(remote, code, path)
	if spyClosed then
		return
	end
	local entry = entryTemplate:Clone()
	entry.Name = remote.Name
	entry.Text = remote.Name
	entry.Parent = G2L["d"]
	entry.MouseButton1Click:Connect(function()
		getgenv().Code = code
		selectedRemotePath = path
		G2L["11"].Text = code
	end)
end

-- ── Hooks ────────────────────────────────────────────────────────
local hooked = {}
local notifiedNoCallbackApi = false

local function handleRemote(remote)
	if hooked[remote] or isFiltered(remote) then
		return
	end
	hooked[remote] = true

	if remote:IsA("RemoteEvent") then
		track(remote.OnClientEvent:Connect(function(...)
			local path = instancePath(remote)
			addEntry(remote, buildCode(table.pack(...), path, "FireServer"), path)
		end))
	elseif remote:IsA("RemoteFunction") then
		-- Assigning OnClientInvoke replaces the game's own handler, so only hook
		-- when the executor can read that handler back for us to chain to.
		if type(getcallbackvalue) ~= "function" then
			if not notifiedNoCallbackApi then
				notifiedNoCallbackApi = true
				print("[Remote Spy] RemoteFunction logging needs getcallbackvalue; skipped so the game's handlers keep working")
			end
			return
		end
		local ok, original = pcall(getcallbackvalue, remote, "OnClientInvoke")
		if not ok or type(original) ~= "function" then
			return -- no client handler to observe
		end
		local function wrapper(...)
			local path = instancePath(remote)
			addEntry(remote, buildCode(table.pack(...), path, "InvokeServer"), path)
			return original(...)
		end
		hookedCallbacks[remote] = { original = original, wrapper = wrapper }
		remote.OnClientInvoke = wrapper
	end
end

local function isRemote(obj)
	return obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")
end

local function wrapRemotes(folder)
	for _, obj in ipairs(folder:GetDescendants()) do
		if isRemote(obj) then
			handleRemote(obj)
		end
	end
	track(folder.DescendantAdded:Connect(function(descendant)
		if isRemote(descendant) then
			handleRemote(descendant)
		end
	end))
end

local folders = {
	game:GetService("ReplicatedStorage"),
	game:GetService("StarterGui"),
	game:GetService("StarterPack"),
	game:GetService("StarterPlayer"),
}

for _, folder in ipairs(folders) do
	wrapRemotes(folder)
end

return G2L["1"], require;
