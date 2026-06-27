local Players         = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local BUY_INTERVAL = 0.1

local existing = PlayerGui:FindFirstChild("DefenseHub")
if existing then existing:Destroy() end

local BuyEvent = ReplicatedStorage:WaitForChild("Events")
    :WaitForChild("Functions"):WaitForChild("BuyDefense")

local TeleportEvent = ReplicatedStorage:WaitForChild("Events")
    :WaitForChild("Remotes"):WaitForChild("Teleport")

local JoinCommunityRaidEvent = ReplicatedStorage:WaitForChild("Events")
    :WaitForChild("Remotes"):WaitForChild("JoinCommunityRaid")

local JoinRaftRaidEvent = ReplicatedStorage:WaitForChild("Events")
    :WaitForChild("Remotes"):WaitForChild("JoinRaftRaid")

local JoinEventRaidEvent = ReplicatedStorage:WaitForChild("Events")
    :WaitForChild("Remotes"):WaitForChild("JoinEventRaid")

local categories = {
    {
        name = "Basic",
        color = Color3.fromRGB(80, 140, 255),
        items = {
            { name = "Wall",          icon = "🧱" },
            { name = "Cannon",        icon = "💣" },
            { name = "Archer Tower",  icon = "🏹" },
            { name = "Mortar",        icon = "💥" },
            { name = "Crossbow",      icon = "🎯" },
            { name = "Bomb Tower",    icon = "💣" },
        }
    },
    {
        name = "Advanced",
        color = Color3.fromRGB(160, 80, 255),
        items = {
            { name = "Wizard Tower",       icon = "🔮" },
            { name = "Double Cannon",      icon = "⚙️" },
            { name = "Tesla",              icon = "⚡" },
            { name = "Mega Crossbow",      icon = "🏹" },
            { name = "Minigun",            icon = "🔫" },
            { name = "Railgun",            icon = "🎯" },
            { name = "Hidden Tesla",       icon = "⚡" },
            { name = "Triple Mortar",      icon = "💣" },
        }
    },
    {
        name = "Fire & Magma",
        color = Color3.fromRGB(255, 100, 40),
        items = {
            { name = "Flamethrower",       icon = "🔥" },
            { name = "Flamespitter",       icon = "🔥" },
            { name = "Magma Cannon",       icon = "🌋" },
            { name = "Double Magma Cannon",icon = "🌋" },
            { name = "Inferno Beam",       icon = "🌋" },
            { name = "Volcanic Artillery", icon = "🌋" },
        }
    },
    {
        name = "Mega & Elite",
        color = Color3.fromRGB(255, 200, 40),
        items = {
            { name = "Mega Mortar",        icon = "💣" },
            { name = "Mega Tesla",         icon = "⚡" },
            { name = "Mega Cannon",        icon = "🔴" },
            { name = "Mystic Artillery",   icon = "🔮" },
            { name = "Rocket Artillery",   icon = "🚀" },
            { name = "The Crusher",        icon = "💪" },
            { name = "The Shocker",        icon = "⚡" },
            { name = "Rage Inducer",       icon = "😤" },
        }
    },
}

local states      = {}
local connections = {}

local C = {
    bg        = Color3.fromRGB(10, 10, 16),
    panel     = Color3.fromRGB(16, 16, 26),
    card      = Color3.fromRGB(22, 22, 36),
    cardHover = Color3.fromRGB(30, 30, 48),
    border    = Color3.fromRGB(45, 45, 70),
    text      = Color3.fromRGB(210, 215, 235),
    subtext   = Color3.fromRGB(130, 135, 160),
    accent    = Color3.fromRGB(100, 160, 255),
    green     = Color3.fromRGB(50, 200, 110),
    greenGlow = Color3.fromRGB(70, 240, 140),
    red       = Color3.fromRGB(200, 70, 70),
    blue      = Color3.fromRGB(70, 120, 230),
    blueHover = Color3.fromRGB(90, 145, 255),
    orange    = Color3.fromRGB(255, 140, 40),
    orangeGlow= Color3.fromRGB(255, 170, 80),
}

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or C.border
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function label(parent, text, size, font, color, xAlign)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = size or 13
    l.Font = font or Enum.Font.GothamSemibold
    l.TextColor3 = color or C.text
    l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DefenseHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 10
ScreenGui.Parent = PlayerGui

local WIN_W = 280
local WIN_H = 500

local Win = Instance.new("Frame")
Win.Name = "Window"
Win.Size = UDim2.new(0, WIN_W, 0, WIN_H)
Win.Position = UDim2.new(0, 24, 0.5, -WIN_H / 2)
Win.BackgroundColor3 = C.bg
Win.BorderSizePixel = 0
Win.Active = true
Win.Draggable = true
Win.ClipsDescendants = true
Win.Parent = ScreenGui
corner(Win, 14)
stroke(Win, Color3.fromRGB(60, 60, 100), 1.5)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 3)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = C.accent
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 5
TopBar.Parent = Win

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.Position = UDim2.new(0, 0, 0, 3)
TitleBar.BackgroundColor3 = C.panel
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Win

local TitleIcon = label(TitleBar, "⚔️", 18, Enum.Font.GothamBold, C.text, Enum.TextXAlignment.Center)
TitleIcon.Size = UDim2.new(0, 36, 1, 0)
TitleIcon.Position = UDim2.new(0, 8, 0, 0)

local TitleText = label(TitleBar, "Defense Hub", 15, Enum.Font.GothamBold, C.text, Enum.TextXAlignment.Left)
TitleText.Size = UDim2.new(1, -100, 1, 0)
TitleText.Position = UDim2.new(0, 44, 0, 0)

local SubText = label(TitleBar, "auto buy & teleport", 10, Enum.Font.Gotham, C.subtext, Enum.TextXAlignment.Left)
SubText.Size = UDim2.new(1, -100, 0, 14)
SubText.Position = UDim2.new(0, 44, 1, -16)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -36, 0.5, -14)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
MinBtn.TextColor3 = C.subtext
MinBtn.Text = "–"
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.AutoButtonColor = false
MinBtn.Parent = TitleBar
corner(MinBtn, 7)

local minimized = false
local ContentHolder -- defined later

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        tween(Win, { Size = UDim2.new(0, WIN_W, 0, 47) }, 0.2)
        MinBtn.Text = "+"
    else
        tween(Win, { Size = UDim2.new(0, WIN_W, 0, WIN_H) }, 0.2)
        MinBtn.Text = "–"
    end
end)

local TITLE_TOTAL = 47
local TAB_H = 36

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, TAB_H)
TabBar.Position = UDim2.new(0, 0, 0, TITLE_TOTAL)
TabBar.BackgroundColor3 = C.panel
TabBar.BorderSizePixel = 0
TabBar.Parent = Win

local Div1 = Instance.new("Frame")
Div1.Size = UDim2.new(1, 0, 0, 1)
Div1.Position = UDim2.new(0, 0, 0, 0)
Div1.BackgroundColor3 = C.border
Div1.BorderSizePixel = 0
Div1.Parent = TabBar

local TAB_PAD = 4
local TAB_BTN_W = math.floor((WIN_W - TAB_PAD * 5) / 4)

local function makeTabBtn(text, xOffset)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, TAB_BTN_W, 0, TAB_H - TAB_PAD * 2)
    btn.Position = UDim2.new(0, xOffset, 0, TAB_PAD)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
    btn.TextColor3 = C.subtext
    btn.Text = text
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = TabBar
    corner(btn, 6)
    return btn
end

local BuyTab    = makeTabBtn("🛡 Buy",     TAB_PAD)
local TpTab     = makeTabBtn("🌀 TP",      TAB_PAD * 2 + TAB_BTN_W)
local RaidTab   = makeTabBtn("⚓ Raids",   TAB_PAD * 3 + TAB_BTN_W * 2)
local PotionTab = makeTabBtn("🧪 Potions", TAB_PAD * 4 + TAB_BTN_W * 3)

local TabIndicator = Instance.new("Frame")
TabIndicator.Size = UDim2.new(0, TAB_BTN_W - 8, 0, 2)
TabIndicator.Position = UDim2.new(0, TAB_PAD + 4, 1, -2)
TabIndicator.BackgroundColor3 = C.accent
TabIndicator.BorderSizePixel = 0
TabIndicator.Parent = TabBar
corner(TabIndicator, 2)

local CONTENT_Y = TITLE_TOTAL + TAB_H

ContentHolder = Instance.new("Frame")
ContentHolder.Name = "Content"
ContentHolder.Size = UDim2.new(1, 0, 1, -CONTENT_Y)
ContentHolder.Position = UDim2.new(0, 0, 0, CONTENT_Y)
ContentHolder.BackgroundTransparency = 1
ContentHolder.ClipsDescendants = true
ContentHolder.Parent = Win

local BuyPanel = Instance.new("Frame")
BuyPanel.Size = UDim2.new(1, 0, 1, 0)
BuyPanel.BackgroundTransparency = 1
BuyPanel.Visible = true
BuyPanel.Parent = ContentHolder

local BuyScroll = Instance.new("ScrollingFrame")
BuyScroll.Size = UDim2.new(1, 0, 1, 0)
BuyScroll.BackgroundTransparency = 1
BuyScroll.BorderSizePixel = 0
BuyScroll.ScrollBarThickness = 3
BuyScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 130)
BuyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
BuyScroll.Parent = BuyPanel

local BuyLayout = Instance.new("UIListLayout")
BuyLayout.SortOrder = Enum.SortOrder.LayoutOrder
BuyLayout.Padding = UDim.new(0, 0)
BuyLayout.Parent = BuyScroll

local BuyPad = Instance.new("UIPadding")
BuyPad.PaddingTop = UDim.new(0, 8)
BuyPad.PaddingBottom = UDim.new(0, 8)
BuyPad.PaddingLeft = UDim.new(0, 10)
BuyPad.PaddingRight = UDim.new(0, 10)
BuyPad.Parent = BuyScroll

local SelectBar = Instance.new("Frame")
SelectBar.Size = UDim2.new(1, 0, 0, 30)
SelectBar.BackgroundTransparency = 1
SelectBar.LayoutOrder = 0
SelectBar.Parent = BuyScroll

local SelAll = Instance.new("TextButton")
SelAll.Size = UDim2.new(0.5, -4, 1, 0)
SelAll.Position = UDim2.new(0, 0, 0, 0)
SelAll.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
SelAll.TextColor3 = C.green
SelAll.Text = "✓ Enable All"
SelAll.TextSize = 11
SelAll.Font = Enum.Font.GothamBold
SelAll.AutoButtonColor = false
SelAll.Parent = SelectBar
corner(SelAll, 6)
stroke(SelAll, Color3.fromRGB(40, 100, 40))

local SelNone = Instance.new("TextButton")
SelNone.Size = UDim2.new(0.5, -4, 1, 0)
SelNone.Position = UDim2.new(0.5, 4, 0, 0)
SelNone.BackgroundColor3 = Color3.fromRGB(50, 25, 25)
SelNone.TextColor3 = Color3.fromRGB(220, 100, 100)
SelNone.Text = "✕ Disable All"
SelNone.TextSize = 11
SelNone.Font = Enum.Font.GothamBold
SelNone.AutoButtonColor = false
SelNone.Parent = SelectBar
corner(SelNone, 6)
stroke(SelNone, Color3.fromRGB(100, 40, 40))

local allToggleFns = {}

SelAll.MouseButton1Click:Connect(function()
    for _, fn in ipairs(allToggleFns) do fn(true) end
end)
SelNone.MouseButton1Click:Connect(function()
    for _, fn in ipairs(allToggleFns) do fn(false) end
end)

local layoutOrder = 1

local function createCategorySection(cat)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 28)
    Header.BackgroundTransparency = 1
    Header.LayoutOrder = layoutOrder
    layoutOrder += 1
    Header.Parent = BuyScroll

    local CatLine = Instance.new("Frame")
    CatLine.Size = UDim2.new(1, 0, 0, 1)
    CatLine.Position = UDim2.new(0, 0, 0.5, 0)
    CatLine.BackgroundColor3 = cat.color
    CatLine.BackgroundTransparency = 0.7
    CatLine.BorderSizePixel = 0
    CatLine.Parent = Header

    local CatLabel = Instance.new("TextLabel")
    CatLabel.Size = UDim2.new(0, 120, 1, 0)
    CatLabel.Position = UDim2.new(0, 0, 0, 0)
    CatLabel.BackgroundColor3 = C.bg
    CatLabel.BorderSizePixel = 0
    CatLabel.Text = "  " .. cat.name:upper() .. "  "
    CatLabel.TextColor3 = cat.color
    CatLabel.TextSize = 10
    CatLabel.Font = Enum.Font.GothamBold
    CatLabel.TextXAlignment = Enum.TextXAlignment.Left
    CatLabel.Parent = Header

    for _, item in ipairs(cat.items) do
        local defKey = item.name

        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 36)
        Row.BackgroundColor3 = C.card
        Row.BorderSizePixel = 0
        Row.LayoutOrder = layoutOrder
        layoutOrder += 1
        Row.Parent = BuyScroll
        corner(Row, 8)
        local rowStroke = stroke(Row, C.border, 1)

        local Accent = Instance.new("Frame")
        Accent.Size = UDim2.new(0, 3, 0.6, 0)
        Accent.Position = UDim2.new(0, 0, 0.2, 0)
        Accent.BackgroundColor3 = cat.color
        Accent.BorderSizePixel = 0
        Accent.BackgroundTransparency = 1
        Accent.Parent = Row
        corner(Accent, 2)

        local IconLbl = label(Row, item.icon, 14, Enum.Font.GothamBold, C.text, Enum.TextXAlignment.Center)
        IconLbl.Size = UDim2.new(0, 28, 1, 0)
        IconLbl.Position = UDim2.new(0, 8, 0, 0)

        local NameLbl = label(Row, item.name, 12, Enum.Font.GothamSemibold, C.text, Enum.TextXAlignment.Left)
        NameLbl.Size = UDim2.new(1, -100, 1, 0)
        NameLbl.Position = UDim2.new(0, 40, 0, 0)
        NameLbl.TextTruncate = Enum.TextTruncate.AtEnd

        local Pill = Instance.new("TextButton")
        Pill.Size = UDim2.new(0, 46, 0, 22)
        Pill.Position = UDim2.new(1, -54, 0.5, -11)
        Pill.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        Pill.TextColor3 = C.subtext
        Pill.Text = "OFF"
        Pill.TextSize = 11
        Pill.Font = Enum.Font.GothamBold
        Pill.AutoButtonColor = false
        Pill.Parent = Row
        corner(Pill, 11)
        local pillStroke = stroke(Pill, C.border, 1)

        local function setOn(val)
            states[defKey] = val
            if val then
                tween(Row, { BackgroundColor3 = Color3.fromRGB(18, 28, 22) })
                tween(Pill, { BackgroundColor3 = C.green })
                tween(Accent, { BackgroundTransparency = 0 })
                Pill.TextColor3 = Color3.fromRGB(10, 10, 10)
                Pill.Text = "ON"
                pillStroke.Color = C.greenGlow
                rowStroke.Color = Color3.fromRGB(40, 120, 70)
                NameLbl.TextColor3 = C.greenGlow

                if not connections[defKey] then
                    local last = 0
                    connections[defKey] = RunService.Heartbeat:Connect(function()
                        local now = tick()
                        if now - last >= BUY_INTERVAL then
                            last = now
                            pcall(function() BuyEvent:InvokeServer(defKey, 1) end)
                        end
                    end)
                end
            else
                tween(Row, { BackgroundColor3 = C.card })
                tween(Pill, { BackgroundColor3 = Color3.fromRGB(35, 35, 55) })
                tween(Accent, { BackgroundTransparency = 1 })
                Pill.TextColor3 = C.subtext
                Pill.Text = "OFF"
                pillStroke.Color = C.border
                rowStroke.Color = C.border
                NameLbl.TextColor3 = C.text

                if connections[defKey] then
                    connections[defKey]:Disconnect()
                    connections[defKey] = nil
                end
            end
        end

        states[defKey] = false
        table.insert(allToggleFns, setOn)

        Pill.MouseButton1Click:Connect(function() setOn(not states[defKey]) end)
        Row.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                setOn(not states[defKey])
            end
        end)

        Row.MouseEnter:Connect(function()
            if not states[defKey] then
                tween(Row, { BackgroundColor3 = C.cardHover })
            end
        end)
        Row.MouseLeave:Connect(function()
            if not states[defKey] then
                tween(Row, { BackgroundColor3 = C.card })
            end
        end)

        local Spacer = Instance.new("Frame")
        Spacer.Size = UDim2.new(1, 0, 0, 4)
        Spacer.BackgroundTransparency = 1
        Spacer.LayoutOrder = layoutOrder
        layoutOrder += 1
        Spacer.Parent = BuyScroll
    end
end

for _, cat in ipairs(categories) do
    createCategorySection(cat)
end

BuyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    BuyScroll.CanvasSize = UDim2.new(0, 0, 0, BuyLayout.AbsoluteContentSize.Y + 16)
end)

local TpPanel = Instance.new("Frame")
TpPanel.Size = UDim2.new(1, 0, 1, 0)
TpPanel.BackgroundTransparency = 1
TpPanel.Visible = false
TpPanel.Parent = ContentHolder

local TpScroll = Instance.new("ScrollingFrame")
TpScroll.Size = UDim2.new(1, 0, 1, 0)
TpScroll.BackgroundTransparency = 1
TpScroll.BorderSizePixel = 0
TpScroll.ScrollBarThickness = 3
TpScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 130)
TpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TpScroll.Parent = TpPanel

local TpLayout = Instance.new("UIListLayout")
TpLayout.SortOrder = Enum.SortOrder.LayoutOrder
TpLayout.Padding = UDim.new(0, 6)
TpLayout.Parent = TpScroll

local TpPad = Instance.new("UIPadding")
TpPad.PaddingTop = UDim.new(0, 10)
TpPad.PaddingBottom = UDim.new(0, 10)
TpPad.PaddingLeft = UDim.new(0, 10)
TpPad.PaddingRight = UDim.new(0, 10)
TpPad.Parent = TpScroll

local function tpSectionHeader(text, order)
    local hdr = Instance.new("Frame")
    hdr.Size = UDim2.new(1, 0, 0, 20)
    hdr.BackgroundTransparency = 1
    hdr.LayoutOrder = order
    hdr.Parent = TpScroll

    local lbl = label(hdr, text, 9, Enum.Font.GothamBold, C.subtext, Enum.TextXAlignment.Left)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    return hdr
end

local function getPlotForPlayer(player)
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local stats = plot:FindFirstChild("Stats")
        if stats then
            local ownerVal = stats:FindFirstChild("Owner")
            if ownerVal and ownerVal.Value == player then
                return plot.Name
            end
        end
    end
    return nil
end

local function createTpRow(player, plotName, isSelf, order)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 48)
    Row.BackgroundColor3 = C.card
    Row.BorderSizePixel = 0
    Row.LayoutOrder = order
    Row.Name = "TPRow_" .. player.Name
    Row.Parent = TpScroll
    corner(Row, 10)
    local rs = stroke(Row, isSelf and Color3.fromRGB(60, 100, 200) or C.border, 1)

    local Avatar = Instance.new("Frame")
    Avatar.Size = UDim2.new(0, 32, 0, 32)
    Avatar.Position = UDim2.new(0, 10, 0.5, -16)
    Avatar.BackgroundColor3 = isSelf and Color3.fromRGB(40, 70, 160) or Color3.fromRGB(35, 35, 55)
    Avatar.BorderSizePixel = 0
    Avatar.Parent = Row
    corner(Avatar, 16)

    local AvatarLbl = label(Avatar, isSelf and "★" or "👤", 14, Enum.Font.GothamBold, C.text, Enum.TextXAlignment.Center)
    AvatarLbl.Size = UDim2.new(1, 0, 1, 0)

    local selfTag = isSelf and "  (You)" or ""
    local NameLbl = label(Row, player.Name .. selfTag, 12, Enum.Font.GothamBold,
        isSelf and C.accent or C.text, Enum.TextXAlignment.Left)
    NameLbl.Size = UDim2.new(1, -130, 0, 16)
    NameLbl.Position = UDim2.new(0, 50, 0, 9)
    NameLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local PlotBadge = Instance.new("Frame")
    PlotBadge.Size = UDim2.new(0, 60, 0, 14)
    PlotBadge.Position = UDim2.new(0, 50, 0, 27)
    PlotBadge.BackgroundColor3 = plotName and Color3.fromRGB(20, 40, 80) or Color3.fromRGB(40, 20, 20)
    PlotBadge.BorderSizePixel = 0
    PlotBadge.Parent = Row
    corner(PlotBadge, 4)

    local PlotLbl = label(PlotBadge, plotName and ("📍 " .. plotName) or "No plot", 9, Enum.Font.GothamBold,
        plotName and C.accent or C.red, Enum.TextXAlignment.Center)
    PlotLbl.Size = UDim2.new(1, 0, 1, 0)

    local TpBtn = Instance.new("TextButton")
    TpBtn.Size = UDim2.new(0, 72, 0, 30)
    TpBtn.Position = UDim2.new(1, -82, 0.5, -15)
    TpBtn.BackgroundColor3 = plotName and C.blue or Color3.fromRGB(50, 30, 30)
    TpBtn.TextColor3 = plotName and Color3.fromRGB(220, 230, 255) or Color3.fromRGB(180, 100, 100)
    TpBtn.Text = "🌀 Go"
    TpBtn.TextSize = 12
    TpBtn.Font = Enum.Font.GothamBold
    TpBtn.AutoButtonColor = false
    TpBtn.Parent = Row
    corner(TpBtn, 8)
    stroke(TpBtn, plotName and Color3.fromRGB(60, 100, 200) or Color3.fromRGB(100, 40, 40))

    if plotName then
        TpBtn.MouseEnter:Connect(function() tween(TpBtn, { BackgroundColor3 = C.blueHover }) end)
        TpBtn.MouseLeave:Connect(function() tween(TpBtn, { BackgroundColor3 = C.blue }) end)

        TpBtn.MouseButton1Click:Connect(function()
            pcall(function() TeleportEvent:FireServer(plotName) end)
            tween(TpBtn, { BackgroundColor3 = C.green })
            TpBtn.Text = "✓ Done"
            TpBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
            task.delay(1.2, function()
                if TpBtn and TpBtn.Parent then
                    tween(TpBtn, { BackgroundColor3 = C.blue })
                    TpBtn.Text = "🌀 Go"
                    TpBtn.TextColor3 = Color3.fromRGB(220, 230, 255)
                end
            end)
        end)
    else
        TpBtn.Active = false
    end

    return Row
end

local function refreshTpList()
    for _, child in ipairs(TpScroll:GetChildren()) do
        if child:IsA("Frame") and child.Name:sub(1, 6) == "TPRow_" then
            child:Destroy()
        end
        if child:IsA("Frame") and child.Name == "TpHdr" then
            child:Destroy()
        end
    end

    local order = 1

    tpSectionHeader("YOUR PLOT", order).Name = "TpHdr"; order += 1
    local myPlot = getPlotForPlayer(LocalPlayer)
    createTpRow(LocalPlayer, myPlot, true, order); order += 1

    local others = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(others, p) end
    end

    if #others > 0 then
        local hdr = tpSectionHeader("OTHER PLAYERS", order)
        hdr.Name = "TpHdr"
        order += 1
        for _, p in ipairs(others) do
            local plot = getPlotForPlayer(p)
            createTpRow(p, plot, false, order)
            order += 1
        end
    end

    TpLayout:ApplyLayout()
    TpScroll.CanvasSize = UDim2.new(0, 0, 0, TpLayout.AbsoluteContentSize.Y + 20)
end

Players.PlayerAdded:Connect(function() task.wait(0.5); if TpPanel.Visible then refreshTpList() end end)
Players.PlayerRemoving:Connect(function() task.wait(0.1); if TpPanel.Visible then refreshTpList() end end)

local RaidPanel = Instance.new("Frame")
RaidPanel.Size = UDim2.new(1, 0, 1, 0)
RaidPanel.BackgroundTransparency = 1
RaidPanel.Visible = false
RaidPanel.Parent = ContentHolder

local RaidScroll = Instance.new("ScrollingFrame")
RaidScroll.Size = UDim2.new(1, 0, 1, 0)
RaidScroll.BackgroundTransparency = 1
RaidScroll.BorderSizePixel = 0
RaidScroll.ScrollBarThickness = 3
RaidScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 130)
RaidScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
RaidScroll.Parent = RaidPanel

local RaidLayout = Instance.new("UIListLayout")
RaidLayout.SortOrder = Enum.SortOrder.LayoutOrder
RaidLayout.Padding = UDim.new(0, 8)
RaidLayout.Parent = RaidScroll

local RaidPad = Instance.new("UIPadding")
RaidPad.PaddingTop = UDim.new(0, 12)
RaidPad.PaddingBottom = UDim.new(0, 12)
RaidPad.PaddingLeft = UDim.new(0, 10)
RaidPad.PaddingRight = UDim.new(0, 10)
RaidPad.Parent = RaidScroll

local RaftSectionHdr = Instance.new("Frame")
RaftSectionHdr.Size = UDim2.new(1, 0, 0, 28)
RaftSectionHdr.BackgroundTransparency = 1
RaftSectionHdr.LayoutOrder = 1
RaftSectionHdr.Parent = RaidScroll

local RaftSectionLine = Instance.new("Frame")
RaftSectionLine.Size = UDim2.new(1, 0, 0, 1)
RaftSectionLine.Position = UDim2.new(0, 0, 0.5, 0)
RaftSectionLine.BackgroundColor3 = C.orange
RaftSectionLine.BackgroundTransparency = 0.7
RaftSectionLine.BorderSizePixel = 0
RaftSectionLine.Parent = RaftSectionHdr

local RaftSectionLabel = Instance.new("TextLabel")
RaftSectionLabel.Size = UDim2.new(0, 130, 1, 0)
RaftSectionLabel.BackgroundColor3 = C.bg
RaftSectionLabel.BorderSizePixel = 0
RaftSectionLabel.Text = "  RAFT RAID  "
RaftSectionLabel.TextColor3 = C.orange
RaftSectionLabel.TextSize = 10
RaftSectionLabel.Font = Enum.Font.GothamBold
RaftSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
RaftSectionLabel.Parent = RaftSectionHdr

local RaftCard = Instance.new("Frame")
RaftCard.Size = UDim2.new(1, 0, 0, 80)
RaftCard.BackgroundColor3 = C.card
RaftCard.BorderSizePixel = 0
RaftCard.LayoutOrder = 2
RaftCard.Parent = RaidScroll
corner(RaftCard, 10)
local raftCardStroke = stroke(RaftCard, C.border, 1)

local RaftAccent = Instance.new("Frame")
RaftAccent.Size = UDim2.new(0, 3, 0.6, 0)
RaftAccent.Position = UDim2.new(0, 0, 0.2, 0)
RaftAccent.BackgroundColor3 = C.orange
RaftAccent.BorderSizePixel = 0
RaftAccent.BackgroundTransparency = 1
RaftAccent.Parent = RaftCard
corner(RaftAccent, 2)

local RaftIcon = label(RaftCard, "⚓", 22, Enum.Font.GothamBold, C.text, Enum.TextXAlignment.Center)
RaftIcon.Size = UDim2.new(0, 36, 0, 36)
RaftIcon.Position = UDim2.new(0, 12, 0, 10)

local RaftTitle = label(RaftCard, "Auto Join Raft Raid", 13, Enum.Font.GothamBold, C.text, Enum.TextXAlignment.Left)
RaftTitle.Size = UDim2.new(1, -110, 0, 18)
RaftTitle.Position = UDim2.new(0, 56, 0, 12)

local RaftDesc = label(RaftCard, "Detects & joins when\nraft raid prompt opens", 10, Enum.Font.Gotham, C.subtext, Enum.TextXAlignment.Left)
RaftDesc.Size = UDim2.new(1, -110, 0, 30)
RaftDesc.Position = UDim2.new(0, 56, 0, 32)
RaftDesc.TextWrapped = true

local RaftStatusBadge = Instance.new("Frame")
RaftStatusBadge.Size = UDim2.new(0, 70, 0, 16)
RaftStatusBadge.Position = UDim2.new(0, 56, 0, 56)
RaftStatusBadge.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
RaftStatusBadge.BorderSizePixel = 0
RaftStatusBadge.Parent = RaftCard
corner(RaftStatusBadge, 5)

local RaftStatusLbl = label(RaftStatusBadge, "● Watching", 9, Enum.Font.GothamBold, C.subtext, Enum.TextXAlignment.Center)
RaftStatusLbl.Size = UDim2.new(1, 0, 1, 0)

local RaftPill = Instance.new("TextButton")
RaftPill.Size = UDim2.new(0, 52, 0, 26)
RaftPill.Position = UDim2.new(1, -62, 0.5, -13)
RaftPill.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
RaftPill.TextColor3 = C.subtext
RaftPill.Text = "OFF"
RaftPill.TextSize = 11
RaftPill.Font = Enum.Font.GothamBold
RaftPill.AutoButtonColor = false
RaftPill.Parent = RaftCard
corner(RaftPill, 13)
local raftPillStroke = stroke(RaftPill, C.border, 1)

local autoJoinRaftRaid = false
local raftRaidConnection = nil
local raftHasJoined = false

local function setRaftRaidActive(val)
    autoJoinRaftRaid = val
    if val then
        tween(RaftCard, { BackgroundColor3 = Color3.fromRGB(28, 18, 10) })
        tween(RaftPill, { BackgroundColor3 = C.orange })
        tween(RaftAccent, { BackgroundTransparency = 0 })
        RaftPill.TextColor3 = Color3.fromRGB(10, 10, 10)
        RaftPill.Text = "ON"
        raftPillStroke.Color = C.orangeGlow
        raftCardStroke.Color = Color3.fromRGB(180, 90, 20)
        RaftTitle.TextColor3 = C.orangeGlow
        RaftStatusBadge.BackgroundColor3 = Color3.fromRGB(40, 20, 5)
        RaftStatusLbl.TextColor3 = C.orange
        RaftStatusLbl.Text = "● Watching"
        raftHasJoined = false

        if not raftRaidConnection then
            raftRaidConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local framework = PlayerGui:FindFirstChild("Framework")
                    if not framework then return end
                    local prompt = framework:FindFirstChild("RaftRaidPrompt")
                    if not prompt then return end
                    local openVal = prompt:FindFirstChild("Open")
                    if not openVal or not openVal:IsA("BoolValue") then return end

                    if openVal.Value == true then
                        if not raftHasJoined then
                            raftHasJoined = true
                            RaftStatusLbl.Text = "⚡ Joining!"
                            RaftStatusLbl.TextColor3 = C.greenGlow
                            JoinRaftRaidEvent:FireServer()
                        end
                    else
                        raftHasJoined = false
                        if RaftStatusLbl.Text ~= "● Watching" then
                            RaftStatusLbl.Text = "● Watching"
                            RaftStatusLbl.TextColor3 = C.orange
                        end
                    end
                end)
            end)
        end
    else
        tween(RaftCard, { BackgroundColor3 = C.card })
        tween(RaftPill, { BackgroundColor3 = Color3.fromRGB(35, 35, 55) })
        tween(RaftAccent, { BackgroundTransparency = 1 })
        RaftPill.TextColor3 = C.subtext
        RaftPill.Text = "OFF"
        raftPillStroke.Color = C.border
        raftCardStroke.Color = C.border
        RaftTitle.TextColor3 = C.text
        RaftStatusBadge.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        RaftStatusLbl.TextColor3 = C.subtext
        RaftStatusLbl.Text = "● Watching"
        raftHasJoined = false

        if raftRaidConnection then
            raftRaidConnection:Disconnect()
            raftRaidConnection = nil
        end
    end
end

RaftPill.MouseButton1Click:Connect(function()
    setRaftRaidActive(not autoJoinRaftRaid)
end)
RaftCard.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        setRaftRaidActive(not autoJoinRaftRaid)
    end
end)

RaftCard.MouseEnter:Connect(function()
    if not autoJoinRaftRaid then
        tween(RaftCard, { BackgroundColor3 = C.cardHover })
    end
end)
RaftCard.MouseLeave:Connect(function()
    if not autoJoinRaftRaid then
        tween(RaftCard, { BackgroundColor3 = C.card })
    end
end)

local MegaSectionHdr = Instance.new("Frame")
MegaSectionHdr.Size = UDim2.new(1, 0, 0, 28)
MegaSectionHdr.BackgroundTransparency = 1
MegaSectionHdr.LayoutOrder = 3
MegaSectionHdr.Parent = RaidScroll

local MegaSectionLine = Instance.new("Frame")
MegaSectionLine.Size = UDim2.new(1, 0, 0, 1)
MegaSectionLine.Position = UDim2.new(0, 0, 0.5, 0)
MegaSectionLine.BackgroundColor3 = Color3.fromRGB(180, 80, 255)
MegaSectionLine.BackgroundTransparency = 0.7
MegaSectionLine.BorderSizePixel = 0
MegaSectionLine.Parent = MegaSectionHdr

local MegaSectionLabel = Instance.new("TextLabel")
MegaSectionLabel.Size = UDim2.new(0, 130, 1, 0)
MegaSectionLabel.BackgroundColor3 = C.bg
MegaSectionLabel.BorderSizePixel = 0
MegaSectionLabel.Text = "  MEGA RAID  "
MegaSectionLabel.TextColor3 = Color3.fromRGB(180, 80, 255)
MegaSectionLabel.TextSize = 10
MegaSectionLabel.Font = Enum.Font.GothamBold
MegaSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
MegaSectionLabel.Parent = MegaSectionHdr

local MegaCard = Instance.new("Frame")
MegaCard.Size = UDim2.new(1, 0, 0, 80)
MegaCard.BackgroundColor3 = C.card
MegaCard.BorderSizePixel = 0
MegaCard.LayoutOrder = 4
MegaCard.Parent = RaidScroll
corner(MegaCard, 10)
local megaCardStroke = stroke(MegaCard, C.border, 1)

local MegaAccent = Instance.new("Frame")
MegaAccent.Size = UDim2.new(0, 3, 0.6, 0)
MegaAccent.Position = UDim2.new(0, 0, 0.2, 0)
MegaAccent.BackgroundColor3 = Color3.fromRGB(180, 80, 255)
MegaAccent.BorderSizePixel = 0
MegaAccent.BackgroundTransparency = 1
MegaAccent.Parent = MegaCard
corner(MegaAccent, 2)

local MegaIcon = label(MegaCard, "💥", 22, Enum.Font.GothamBold, C.text, Enum.TextXAlignment.Center)
MegaIcon.Size = UDim2.new(0, 36, 0, 36)
MegaIcon.Position = UDim2.new(0, 12, 0, 10)

local MegaTitle = label(MegaCard, "Auto Join Mega Raid", 13, Enum.Font.GothamBold, C.text, Enum.TextXAlignment.Left)
MegaTitle.Size = UDim2.new(1, -110, 0, 18)
MegaTitle.Position = UDim2.new(0, 56, 0, 12)

local MegaDesc = label(MegaCard, "Detects & joins when\nmega raid prompt opens", 10, Enum.Font.Gotham, C.subtext, Enum.TextXAlignment.Left)
MegaDesc.Size = UDim2.new(1, -110, 0, 30)
MegaDesc.Position = UDim2.new(0, 56, 0, 32)
MegaDesc.TextWrapped = true

local MegaStatusBadge = Instance.new("Frame")
MegaStatusBadge.Size = UDim2.new(0, 70, 0, 16)
MegaStatusBadge.Position = UDim2.new(0, 56, 0, 56)
MegaStatusBadge.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
MegaStatusBadge.BorderSizePixel = 0
MegaStatusBadge.Parent = MegaCard
corner(MegaStatusBadge, 5)

local MegaStatusLbl = label(MegaStatusBadge, "● Watching", 9, Enum.Font.GothamBold, C.subtext, Enum.TextXAlignment.Center)
MegaStatusLbl.Size = UDim2.new(1, 0, 1, 0)

local MegaPill = Instance.new("TextButton")
MegaPill.Size = UDim2.new(0, 52, 0, 26)
MegaPill.Position = UDim2.new(1, -62, 0.5, -13)
MegaPill.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
MegaPill.TextColor3 = C.subtext
MegaPill.Text = "OFF"
MegaPill.TextSize = 11
MegaPill.Font = Enum.Font.GothamBold
MegaPill.AutoButtonColor = false
MegaPill.Parent = MegaCard
corner(MegaPill, 13)
local megaPillStroke = stroke(MegaPill, C.border, 1)

local autoJoinMegaRaid = false
local megaRaidConnection = nil
local megaHasJoined = false

local MEGA_PURPLE      = Color3.fromRGB(180, 80, 255)
local MEGA_PURPLE_GLOW = Color3.fromRGB(210, 120, 255)

local function setMegaRaidActive(val)
    autoJoinMegaRaid = val
    if val then
        tween(MegaCard, { BackgroundColor3 = Color3.fromRGB(20, 10, 30) })
        tween(MegaPill, { BackgroundColor3 = MEGA_PURPLE })
        tween(MegaAccent, { BackgroundTransparency = 0 })
        MegaPill.TextColor3 = Color3.fromRGB(10, 10, 10)
        MegaPill.Text = "ON"
        megaPillStroke.Color = MEGA_PURPLE_GLOW
        megaCardStroke.Color = Color3.fromRGB(120, 40, 200)
        MegaTitle.TextColor3 = MEGA_PURPLE_GLOW
        MegaStatusBadge.BackgroundColor3 = Color3.fromRGB(30, 10, 50)
        MegaStatusLbl.TextColor3 = MEGA_PURPLE
        MegaStatusLbl.Text = "● Watching"
        megaHasJoined = false

        if not megaRaidConnection then
            megaRaidConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local framework = PlayerGui:FindFirstChild("Framework")
                    if not framework then return end
                    local prompt = framework:FindFirstChild("CommunityRaidPrompt")
                    if not prompt then return end
                    local openVal = prompt:FindFirstChild("Open")
                    if not openVal or not openVal:IsA("BoolValue") then return end

                    if openVal.Value == true then
                        if not megaHasJoined then
                            megaHasJoined = true
                            MegaStatusLbl.Text = "⚡ Joining!"
                            MegaStatusLbl.TextColor3 = C.greenGlow
                            JoinCommunityRaidEvent:FireServer()
                        end
                    else
                        megaHasJoined = false
                        if MegaStatusLbl.Text ~= "● Watching" then
                            MegaStatusLbl.Text = "● Watching"
                            MegaStatusLbl.TextColor3 = MEGA_PURPLE
                        end
                    end
                end)
            end)
        end
    else
        tween(MegaCard, { BackgroundColor3 = C.card })
        tween(MegaPill, { BackgroundColor3 = Color3.fromRGB(35, 35, 55) })
        tween(MegaAccent, { BackgroundTransparency = 1 })
        MegaPill.TextColor3 = C.subtext
        MegaPill.Text = "OFF"
        megaPillStroke.Color = C.border
        megaCardStroke.Color = C.border
        MegaTitle.TextColor3 = C.text
        MegaStatusBadge.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        MegaStatusLbl.TextColor3 = C.subtext
        MegaStatusLbl.Text = "● Watching"
        megaHasJoined = false

        if megaRaidConnection then
            megaRaidConnection:Disconnect()
            megaRaidConnection = nil
        end
    end
end

MegaPill.MouseButton1Click:Connect(function()
    setMegaRaidActive(not autoJoinMegaRaid)
end)
MegaCard.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        setMegaRaidActive(not autoJoinMegaRaid)
    end
end)

MegaCard.MouseEnter:Connect(function()
    if not autoJoinMegaRaid then
        tween(MegaCard, { BackgroundColor3 = C.cardHover })
    end
end)
MegaCard.MouseLeave:Connect(function()
    if not autoJoinMegaRaid then
        tween(MegaCard, { BackgroundColor3 = C.card })
    end
end)

local IslandSectionHdr = Instance.new("Frame")
IslandSectionHdr.Size = UDim2.new(1, 0, 0, 28)
IslandSectionHdr.BackgroundTransparency = 1
IslandSectionHdr.LayoutOrder = 5
IslandSectionHdr.Parent = RaidScroll

local IslandSectionLine = Instance.new("Frame")
IslandSectionLine.Size = UDim2.new(1, 0, 0, 1)
IslandSectionLine.Position = UDim2.new(0, 0, 0.5, 0)
IslandSectionLine.BackgroundColor3 = Color3.fromRGB(40, 190, 140)
IslandSectionLine.BackgroundTransparency = 0.7
IslandSectionLine.BorderSizePixel = 0
IslandSectionLine.Parent = IslandSectionHdr

local IslandSectionLabel = Instance.new("TextLabel")
IslandSectionLabel.Size = UDim2.new(0, 130, 1, 0)
IslandSectionLabel.BackgroundColor3 = C.bg
IslandSectionLabel.BorderSizePixel = 0
IslandSectionLabel.Text = "  ISLAND RAID  "
IslandSectionLabel.TextColor3 = Color3.fromRGB(40, 190, 140)
IslandSectionLabel.TextSize = 10
IslandSectionLabel.Font = Enum.Font.GothamBold
IslandSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
IslandSectionLabel.Parent = IslandSectionHdr

local IslandCard = Instance.new("Frame")
IslandCard.Size = UDim2.new(1, 0, 0, 80)
IslandCard.BackgroundColor3 = C.card
IslandCard.BorderSizePixel = 0
IslandCard.LayoutOrder = 6
IslandCard.Parent = RaidScroll
corner(IslandCard, 10)
local islandCardStroke = stroke(IslandCard, C.border, 1)

local IslandAccent = Instance.new("Frame")
IslandAccent.Size = UDim2.new(0, 3, 0.6, 0)
IslandAccent.Position = UDim2.new(0, 0, 0.2, 0)
IslandAccent.BackgroundColor3 = Color3.fromRGB(40, 190, 140)
IslandAccent.BorderSizePixel = 0
IslandAccent.BackgroundTransparency = 1
IslandAccent.Parent = IslandCard
corner(IslandAccent, 2)

local IslandIcon = label(IslandCard, "🏝️", 22, Enum.Font.GothamBold, C.text, Enum.TextXAlignment.Center)
IslandIcon.Size = UDim2.new(0, 36, 0, 36)
IslandIcon.Position = UDim2.new(0, 12, 0, 10)

local IslandTitle = label(IslandCard, "Auto Join Island Raid", 13, Enum.Font.GothamBold, C.text, Enum.TextXAlignment.Left)
IslandTitle.Size = UDim2.new(1, -110, 0, 18)
IslandTitle.Position = UDim2.new(0, 56, 0, 12)

local IslandDesc = label(IslandCard, "Detects & joins when\nisland raid prompt opens", 10, Enum.Font.Gotham, C.subtext, Enum.TextXAlignment.Left)
IslandDesc.Size = UDim2.new(1, -110, 0, 30)
IslandDesc.Position = UDim2.new(0, 56, 0, 32)
IslandDesc.TextWrapped = true

local IslandStatusBadge = Instance.new("Frame")
IslandStatusBadge.Size = UDim2.new(0, 70, 0, 16)
IslandStatusBadge.Position = UDim2.new(0, 56, 0, 56)
IslandStatusBadge.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
IslandStatusBadge.BorderSizePixel = 0
IslandStatusBadge.Parent = IslandCard
corner(IslandStatusBadge, 5)

local IslandStatusLbl = label(IslandStatusBadge, "● Watching", 9, Enum.Font.GothamBold, C.subtext, Enum.TextXAlignment.Center)
IslandStatusLbl.Size = UDim2.new(1, 0, 1, 0)

local IslandPill = Instance.new("TextButton")
IslandPill.Size = UDim2.new(0, 52, 0, 26)
IslandPill.Position = UDim2.new(1, -62, 0.5, -13)
IslandPill.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
IslandPill.TextColor3 = C.subtext
IslandPill.Text = "OFF"
IslandPill.TextSize = 11
IslandPill.Font = Enum.Font.GothamBold
IslandPill.AutoButtonColor = false
IslandPill.Parent = IslandCard
corner(IslandPill, 13)
local islandPillStroke = stroke(IslandPill, C.border, 1)

local autoJoinIslandRaid = false
local islandRaidConnection = nil
local islandHasJoined = false

local ISLAND_TEAL      = Color3.fromRGB(40, 190, 140)
local ISLAND_TEAL_GLOW = Color3.fromRGB(70, 230, 170)

local function setIslandRaidActive(val)
    autoJoinIslandRaid = val
    if val then
        tween(IslandCard, { BackgroundColor3 = Color3.fromRGB(8, 24, 18) })
        tween(IslandPill, { BackgroundColor3 = ISLAND_TEAL })
        tween(IslandAccent, { BackgroundTransparency = 0 })
        IslandPill.TextColor3 = Color3.fromRGB(10, 10, 10)
        IslandPill.Text = "ON"
        islandPillStroke.Color = ISLAND_TEAL_GLOW
        islandCardStroke.Color = Color3.fromRGB(20, 130, 90)
        IslandTitle.TextColor3 = ISLAND_TEAL_GLOW
        IslandStatusBadge.BackgroundColor3 = Color3.fromRGB(8, 30, 22)
        IslandStatusLbl.TextColor3 = ISLAND_TEAL
        IslandStatusLbl.Text = "● Watching"
        islandHasJoined = false

        if not islandRaidConnection then
            islandRaidConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local framework = PlayerGui:FindFirstChild("Framework")
                    if not framework then return end
                    local prompt = framework:FindFirstChild("EventRaidPrompt")
                    if not prompt then return end
                    local openVal = prompt:FindFirstChild("Open")
                    if not openVal or not openVal:IsA("BoolValue") then return end

                    if openVal.Value == true then
                        if not islandHasJoined then
                            islandHasJoined = true
                            IslandStatusLbl.Text = "⚡ Joining!"
                            IslandStatusLbl.TextColor3 = C.greenGlow
                            JoinEventRaidEvent:FireServer()
                        end
                    else
                        islandHasJoined = false
                        if IslandStatusLbl.Text ~= "● Watching" then
                            IslandStatusLbl.Text = "● Watching"
                            IslandStatusLbl.TextColor3 = ISLAND_TEAL
                        end
                    end
                end)
            end)
        end
    else
        tween(IslandCard, { BackgroundColor3 = C.card })
        tween(IslandPill, { BackgroundColor3 = Color3.fromRGB(35, 35, 55) })
        tween(IslandAccent, { BackgroundTransparency = 1 })
        IslandPill.TextColor3 = C.subtext
        IslandPill.Text = "OFF"
        islandPillStroke.Color = C.border
        islandCardStroke.Color = C.border
        IslandTitle.TextColor3 = C.text
        IslandStatusBadge.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        IslandStatusLbl.TextColor3 = C.subtext
        IslandStatusLbl.Text = "● Watching"
        islandHasJoined = false

        if islandRaidConnection then
            islandRaidConnection:Disconnect()
            islandRaidConnection = nil
        end
    end
end

IslandPill.MouseButton1Click:Connect(function()
    setIslandRaidActive(not autoJoinIslandRaid)
end)
IslandCard.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        setIslandRaidActive(not autoJoinIslandRaid)
    end
end)

IslandCard.MouseEnter:Connect(function()
    if not autoJoinIslandRaid then
        tween(IslandCard, { BackgroundColor3 = C.cardHover })
    end
end)
IslandCard.MouseLeave:Connect(function()
    if not autoJoinIslandRaid then
        tween(IslandCard, { BackgroundColor3 = C.card })
    end
end)

RaidLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    RaidScroll.CanvasSize = UDim2.new(0, 0, 0, RaidLayout.AbsoluteContentSize.Y + 20)
end)

local PotionEvent = ReplicatedStorage:WaitForChild("Events")
    :WaitForChild("Functions"):WaitForChild("UsePotion")

local POTION_COLOR      = Color3.fromRGB(100, 220, 180)
local POTION_COLOR_GLOW = Color3.fromRGB(130, 255, 210)

local PotionPanel = Instance.new("Frame")
PotionPanel.Size = UDim2.new(1, 0, 1, 0)
PotionPanel.BackgroundTransparency = 1
PotionPanel.Visible = false
PotionPanel.Parent = ContentHolder

local PotionScroll = Instance.new("ScrollingFrame")
PotionScroll.Size = UDim2.new(1, 0, 1, 0)
PotionScroll.BackgroundTransparency = 1
PotionScroll.BorderSizePixel = 0
PotionScroll.ScrollBarThickness = 3
PotionScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 130)
PotionScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PotionScroll.Parent = PotionPanel

local PotionLayout = Instance.new("UIListLayout")
PotionLayout.SortOrder = Enum.SortOrder.LayoutOrder
PotionLayout.Padding = UDim.new(0, 8)
PotionLayout.Parent = PotionScroll

local PotionPad = Instance.new("UIPadding")
PotionPad.PaddingTop    = UDim.new(0, 12)
PotionPad.PaddingBottom = UDim.new(0, 12)
PotionPad.PaddingLeft   = UDim.new(0, 10)
PotionPad.PaddingRight  = UDim.new(0, 10)
PotionPad.Parent = PotionScroll

local PotionSectionHdr = Instance.new("Frame")
PotionSectionHdr.Size = UDim2.new(1, 0, 0, 28)
PotionSectionHdr.BackgroundTransparency = 1
PotionSectionHdr.LayoutOrder = 1
PotionSectionHdr.Parent = PotionScroll

local PotionSectionLine = Instance.new("Frame")
PotionSectionLine.Size = UDim2.new(1, 0, 0, 1)
PotionSectionLine.Position = UDim2.new(0, 0, 0.5, 0)
PotionSectionLine.BackgroundColor3 = POTION_COLOR
PotionSectionLine.BackgroundTransparency = 0.7
PotionSectionLine.BorderSizePixel = 0
PotionSectionLine.Parent = PotionSectionHdr

local PotionSectionLbl = Instance.new("TextLabel")
PotionSectionLbl.Size = UDim2.new(0, 210, 1, 0)
PotionSectionLbl.BackgroundColor3 = C.bg
PotionSectionLbl.BorderSizePixel = 0
PotionSectionLbl.Text = "  AUTO DRINK SELECTED POTIONS  "
PotionSectionLbl.TextColor3 = POTION_COLOR
PotionSectionLbl.TextSize = 10
PotionSectionLbl.Font = Enum.Font.GothamBold
PotionSectionLbl.TextXAlignment = Enum.TextXAlignment.Left
PotionSectionLbl.Parent = PotionSectionHdr

local PotionCtrlCard = Instance.new("Frame")
PotionCtrlCard.Size = UDim2.new(1, 0, 0, 52)
PotionCtrlCard.BackgroundColor3 = C.card
PotionCtrlCard.BorderSizePixel = 0
PotionCtrlCard.LayoutOrder = 2
PotionCtrlCard.Parent = PotionScroll
corner(PotionCtrlCard, 10)
local potionCtrlStroke = stroke(PotionCtrlCard, C.border, 1)

local PotionCtrlAccent = Instance.new("Frame")
PotionCtrlAccent.Size = UDim2.new(0, 3, 0.6, 0)
PotionCtrlAccent.Position = UDim2.new(0, 0, 0.2, 0)
PotionCtrlAccent.BackgroundColor3 = POTION_COLOR
PotionCtrlAccent.BorderSizePixel = 0
PotionCtrlAccent.BackgroundTransparency = 1
PotionCtrlAccent.Parent = PotionCtrlCard
corner(PotionCtrlAccent, 2)

local PotionCtrlIcon = label(PotionCtrlCard, "🧪", 18, Enum.Font.GothamBold, C.text, Enum.TextXAlignment.Center)
PotionCtrlIcon.Size = UDim2.new(0, 32, 1, 0)
PotionCtrlIcon.Position = UDim2.new(0, 10, 0, 0)

local PotionCtrlTitle = label(PotionCtrlCard, "Auto Drink Selected Potions", 12, Enum.Font.GothamBold, C.text, Enum.TextXAlignment.Left)
PotionCtrlTitle.Size = UDim2.new(1, -120, 0, 18)
PotionCtrlTitle.Position = UDim2.new(0, 48, 0, 10)

local PotionCtrlSub = label(PotionCtrlCard, "Select potions below", 10, Enum.Font.Gotham, C.subtext, Enum.TextXAlignment.Left)
PotionCtrlSub.Size = UDim2.new(1, -120, 0, 14)
PotionCtrlSub.Position = UDim2.new(0, 48, 0, 28)

local PotionTogglePill = Instance.new("TextButton")
PotionTogglePill.Size = UDim2.new(0, 52, 0, 26)
PotionTogglePill.Position = UDim2.new(1, -62, 0.5, -13)
PotionTogglePill.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
PotionTogglePill.TextColor3 = C.subtext
PotionTogglePill.Text = "OFF"
PotionTogglePill.TextSize = 11
PotionTogglePill.Font = Enum.Font.GothamBold
PotionTogglePill.AutoButtonColor = false
PotionTogglePill.Parent = PotionCtrlCard
corner(PotionTogglePill, 13)
local potionToggleStroke = stroke(PotionTogglePill, C.border, 1)

local PotionListHdr = Instance.new("Frame")
PotionListHdr.Size = UDim2.new(1, 0, 0, 28)
PotionListHdr.BackgroundTransparency = 1
PotionListHdr.LayoutOrder = 3
PotionListHdr.Parent = PotionScroll

local PotionListLine = Instance.new("Frame")
PotionListLine.Size = UDim2.new(1, 0, 0, 1)
PotionListLine.Position = UDim2.new(0, 0, 0.5, 0)
PotionListLine.BackgroundColor3 = C.border
PotionListLine.BackgroundTransparency = 0.5
PotionListLine.BorderSizePixel = 0
PotionListLine.Parent = PotionListHdr

local PotionListLbl = Instance.new("TextLabel")
PotionListLbl.Size = UDim2.new(0, 140, 1, 0)
PotionListLbl.BackgroundColor3 = C.bg
PotionListLbl.BorderSizePixel = 0
PotionListLbl.Text = "  YOUR POTIONS  "
PotionListLbl.TextColor3 = C.subtext
PotionListLbl.TextSize = 10
PotionListLbl.Font = Enum.Font.GothamBold
PotionListLbl.TextXAlignment = Enum.TextXAlignment.Left
PotionListLbl.Parent = PotionListHdr

local PotionRefreshBtn = Instance.new("TextButton")
PotionRefreshBtn.Size = UDim2.new(0, 22, 0, 22)
PotionRefreshBtn.Position = UDim2.new(1, -22, 0.5, -11)
PotionRefreshBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
PotionRefreshBtn.TextColor3 = C.subtext
PotionRefreshBtn.Text = "↺"
PotionRefreshBtn.TextSize = 14
PotionRefreshBtn.Font = Enum.Font.GothamBold
PotionRefreshBtn.AutoButtonColor = false
PotionRefreshBtn.Parent = PotionListHdr
corner(PotionRefreshBtn, 6)

local PotionRowsFrame = Instance.new("Frame")
PotionRowsFrame.Size = UDim2.new(1, 0, 0, 0) -- height set dynamically
PotionRowsFrame.BackgroundTransparency = 1
PotionRowsFrame.LayoutOrder = 4
PotionRowsFrame.ClipsDescendants = false
PotionRowsFrame.Parent = PotionScroll

local PotionRowsLayout = Instance.new("UIListLayout")
PotionRowsLayout.SortOrder = Enum.SortOrder.LayoutOrder
PotionRowsLayout.Padding = UDim.new(0, 5)
PotionRowsLayout.Parent = PotionRowsFrame

local autoDrinkActive   = false
local selectedPotions   = {} -- [potionName] = true/false
local autoDrinkConn     = nil
local DRINK_INTERVAL    = 0.5 -- seconds between use attempts

local function parsePotionName(fullName)
    local baseName, tier = fullName:match("^(.-)%s+(%d+)$")
    if baseName and tier then
        return baseName, tonumber(tier)
    end
    return fullName, 1
end

local function buildPotionRows()
    for _, child in ipairs(PotionRowsFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local potionContent = nil
    pcall(function()
        potionContent = PlayerGui
            :WaitForChild("Framework", 2)
            :WaitForChild("Frames", 2)
            :WaitForChild("Inventory", 2)
            :WaitForChild("Frame", 2)
            :WaitForChild("Content", 2)
            :WaitForChild("Menus", 2)
            :WaitForChild("Potions", 2)
            :WaitForChild("Content", 2)
    end)

    local found = {}
    if potionContent then
        for _, child in ipairs(potionContent:GetChildren()) do
            local potionName = child.Name
            if potionName and potionName ~= "" and not found[potionName] then
                found[potionName] = true
                table.insert(found, potionName)
            end
        end
    end

    local rowOrder = 1
    local anyFound = false

    for _, potionName in ipairs(found) do
        anyFound = true
        local isSelected = selectedPotions[potionName] or false

        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 38)
        Row.BackgroundColor3 = isSelected and Color3.fromRGB(10, 28, 22) or C.card
        Row.BorderSizePixel = 0
        Row.LayoutOrder = rowOrder
        rowOrder += 1
        Row.Parent = PotionRowsFrame
        corner(Row, 8)
        local rowStroke = stroke(Row, isSelected and Color3.fromRGB(30, 140, 90) or C.border, 1)

        local RowAccent = Instance.new("Frame")
        RowAccent.Size = UDim2.new(0, 3, 0.6, 0)
        RowAccent.Position = UDim2.new(0, 0, 0.2, 0)
        RowAccent.BackgroundColor3 = POTION_COLOR
        RowAccent.BorderSizePixel = 0
        RowAccent.BackgroundTransparency = isSelected and 0 or 1
        RowAccent.Parent = Row
        corner(RowAccent, 2)

        local RowIcon = label(Row, "🧪", 14, Enum.Font.GothamBold, C.text, Enum.TextXAlignment.Center)
        RowIcon.Size = UDim2.new(0, 28, 1, 0)
        RowIcon.Position = UDim2.new(0, 8, 0, 0)

        local RowName = label(Row, potionName, 11, Enum.Font.GothamSemibold,
            isSelected and POTION_COLOR_GLOW or C.text, Enum.TextXAlignment.Left)
        RowName.Size = UDim2.new(1, -100, 1, 0)
        RowName.Position = UDim2.new(0, 40, 0, 0)
        RowName.TextTruncate = Enum.TextTruncate.AtEnd

        local CheckBtn = Instance.new("TextButton")
        CheckBtn.Size = UDim2.new(0, 52, 0, 22)
        CheckBtn.Position = UDim2.new(1, -60, 0.5, -11)
        CheckBtn.BackgroundColor3 = isSelected and POTION_COLOR or Color3.fromRGB(35, 35, 55)
        CheckBtn.TextColor3 = isSelected and Color3.fromRGB(10, 10, 10) or C.subtext
        CheckBtn.Text = isSelected and "✓ ON" or "OFF"
        CheckBtn.TextSize = 10
        CheckBtn.Font = Enum.Font.GothamBold
        CheckBtn.AutoButtonColor = false
        CheckBtn.Parent = Row
        corner(CheckBtn, 11)
        local checkStroke = stroke(CheckBtn, isSelected and POTION_COLOR_GLOW or C.border, 1)

        local function toggleRow()
            local sel = not selectedPotions[potionName]
            selectedPotions[potionName] = sel
            if sel then
                tween(Row, { BackgroundColor3 = Color3.fromRGB(10, 28, 22) })
                tween(CheckBtn, { BackgroundColor3 = POTION_COLOR })
                tween(RowAccent, { BackgroundTransparency = 0 })
                CheckBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
                CheckBtn.Text = "✓ ON"
                checkStroke.Color = POTION_COLOR_GLOW
                rowStroke.Color = Color3.fromRGB(30, 140, 90)
                RowName.TextColor3 = POTION_COLOR_GLOW
            else
                tween(Row, { BackgroundColor3 = C.card })
                tween(CheckBtn, { BackgroundColor3 = Color3.fromRGB(35, 35, 55) })
                tween(RowAccent, { BackgroundTransparency = 1 })
                CheckBtn.TextColor3 = C.subtext
                CheckBtn.Text = "OFF"
                checkStroke.Color = C.border
                rowStroke.Color = C.border
                RowName.TextColor3 = C.text
            end
        end

        CheckBtn.MouseButton1Click:Connect(toggleRow)
        Row.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                toggleRow()
            end
        end)
        Row.MouseEnter:Connect(function()
            if not selectedPotions[potionName] then
                tween(Row, { BackgroundColor3 = C.cardHover })
            end
        end)
        Row.MouseLeave:Connect(function()
            if not selectedPotions[potionName] then
                tween(Row, { BackgroundColor3 = C.card })
            end
        end)
    end

    if not anyFound then
        local EmptyLbl = Instance.new("TextLabel")
        EmptyLbl.Size = UDim2.new(1, 0, 0, 50)
        EmptyLbl.BackgroundTransparency = 1
        EmptyLbl.Text = "No potions found.\nOpen your inventory first, then refresh ↺"
        EmptyLbl.TextColor3 = C.subtext
        EmptyLbl.TextSize = 11
        EmptyLbl.Font = Enum.Font.Gotham
        EmptyLbl.TextWrapped = true
        EmptyLbl.TextXAlignment = Enum.TextXAlignment.Center
        EmptyLbl.LayoutOrder = 1
        EmptyLbl.Parent = PotionRowsFrame
    end

    PotionRowsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        PotionRowsFrame.Size = UDim2.new(1, 0, 0, PotionRowsLayout.AbsoluteContentSize.Y)
    end)
    PotionRowsFrame.Size = UDim2.new(1, 0, 0, PotionRowsLayout.AbsoluteContentSize.Y)
end

local function setAutoDrink(val)
    autoDrinkActive = val
    if val then
        tween(PotionCtrlCard, { BackgroundColor3 = Color3.fromRGB(8, 24, 20) })
        tween(PotionTogglePill, { BackgroundColor3 = POTION_COLOR })
        tween(PotionCtrlAccent, { BackgroundTransparency = 0 })
        PotionTogglePill.TextColor3 = Color3.fromRGB(10, 10, 10)
        PotionTogglePill.Text = "ON"
        potionToggleStroke.Color = POTION_COLOR_GLOW
        potionCtrlStroke.Color = Color3.fromRGB(30, 160, 110)
        PotionCtrlTitle.TextColor3 = POTION_COLOR_GLOW
        PotionCtrlSub.Text = "Drinking selected potions..."

        if not autoDrinkConn then
            local lastDrink = 0
            autoDrinkConn = RunService.Heartbeat:Connect(function()
                local now = tick()
                if now - lastDrink < DRINK_INTERVAL then return end
                lastDrink = now
                for potionName, sel in pairs(selectedPotions) do
                    if sel then
                        local baseName, tier = parsePotionName(potionName)
                        pcall(function()
                            PotionEvent:InvokeServer(baseName, tier)
                        end)
                    end
                end
            end)
        end
    else
        tween(PotionCtrlCard, { BackgroundColor3 = C.card })
        tween(PotionTogglePill, { BackgroundColor3 = Color3.fromRGB(35, 35, 55) })
        tween(PotionCtrlAccent, { BackgroundTransparency = 1 })
        PotionTogglePill.TextColor3 = C.subtext
        PotionTogglePill.Text = "OFF"
        potionToggleStroke.Color = C.border
        potionCtrlStroke.Color = C.border
        PotionCtrlTitle.TextColor3 = C.text
        PotionCtrlSub.Text = "Select potions below"

        if autoDrinkConn then
            autoDrinkConn:Disconnect()
            autoDrinkConn = nil
        end
    end
end

PotionTogglePill.MouseButton1Click:Connect(function()
    setAutoDrink(not autoDrinkActive)
end)
PotionCtrlCard.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        setAutoDrink(not autoDrinkActive)
    end
end)
PotionCtrlCard.MouseEnter:Connect(function()
    if not autoDrinkActive then tween(PotionCtrlCard, { BackgroundColor3 = C.cardHover }) end
end)
PotionCtrlCard.MouseLeave:Connect(function()
    if not autoDrinkActive then tween(PotionCtrlCard, { BackgroundColor3 = C.card }) end
end)

PotionRefreshBtn.MouseButton1Click:Connect(function()
    tween(PotionRefreshBtn, { BackgroundColor3 = Color3.fromRGB(20, 60, 40) })
    PotionRefreshBtn.TextColor3 = POTION_COLOR
    buildPotionRows()
    task.delay(0.5, function()
        tween(PotionRefreshBtn, { BackgroundColor3 = Color3.fromRGB(30, 30, 50) })
        PotionRefreshBtn.TextColor3 = C.subtext
    end)
end)

PotionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PotionScroll.CanvasSize = UDim2.new(0, 0, 0, PotionLayout.AbsoluteContentSize.Y + 20)
end)

local function setTab(tab)
    BuyPanel.Visible    = false
    TpPanel.Visible     = false
    RaidPanel.Visible   = false
    PotionPanel.Visible = false

    for _, btn in ipairs({ BuyTab, TpTab, RaidTab, PotionTab }) do
        btn.TextColor3 = C.subtext
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    end

    if tab == "buy" then
        BuyPanel.Visible = true
        tween(TabIndicator, { Position = UDim2.new(0, TAB_PAD + 4, 1, -2) })
        tween(TabIndicator, { BackgroundColor3 = C.accent })
        BuyTab.TextColor3 = C.text
        BuyTab.BackgroundColor3 = Color3.fromRGB(35, 35, 60)

    elseif tab == "teleport" then
        TpPanel.Visible = true
        refreshTpList()
        tween(TabIndicator, { Position = UDim2.new(0, TAB_PAD * 2 + TAB_BTN_W + 4, 1, -2) })
        tween(TabIndicator, { BackgroundColor3 = Color3.fromRGB(120, 80, 255) })
        TpTab.TextColor3 = C.text
        TpTab.BackgroundColor3 = Color3.fromRGB(35, 35, 60)

    elseif tab == "raids" then
        RaidPanel.Visible = true
        tween(TabIndicator, { Position = UDim2.new(0, TAB_PAD * 3 + TAB_BTN_W * 2 + 4, 1, -2) })
        tween(TabIndicator, { BackgroundColor3 = C.orange })
        RaidTab.TextColor3 = C.text
        RaidTab.BackgroundColor3 = Color3.fromRGB(35, 35, 60)

    elseif tab == "potions" then
        PotionPanel.Visible = true
        buildPotionRows()
        tween(TabIndicator, { Position = UDim2.new(0, TAB_PAD * 4 + TAB_BTN_W * 3 + 4, 1, -2) })
        tween(TabIndicator, { BackgroundColor3 = POTION_COLOR })
        PotionTab.TextColor3 = C.text
        PotionTab.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
    end
end

BuyTab.MouseButton1Click:Connect(function()    setTab("buy") end)
TpTab.MouseButton1Click:Connect(function()     setTab("teleport") end)
RaidTab.MouseButton1Click:Connect(function()   setTab("raids") end)
PotionTab.MouseButton1Click:Connect(function() setTab("potions") end)

for _, btn in ipairs({ BuyTab, TpTab, RaidTab, PotionTab }) do
    btn.MouseEnter:Connect(function()
        if btn.TextColor3 == C.subtext then
            tween(btn, { BackgroundColor3 = Color3.fromRGB(30, 30, 50) })
        end
    end)
    btn.MouseLeave:Connect(function()
        if btn.TextColor3 == C.subtext then
            tween(btn, { BackgroundColor3 = Color3.fromRGB(25, 25, 40) })
        end
    end)
end

setTab("buy")
