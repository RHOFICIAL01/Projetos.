local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variável para controlar se a GUI está minimizada
local isMinimized = false
local originalSize = UDim2.new(0, 500, 0, 400)
local minimizedSize = UDim2.new(0, 200, 0, 50)

-- Detectar se é mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- Criar a ScreenGui principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BeautifulGUI"
screenGui.Parent = playerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Efeito de blur background
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 8
blurEffect.Parent = game:GetService("Lighting")

-- Frame principal - POSICIONADO NO CANTO SUPERIOR ESQUERDO
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0, 20, 0, 20) -- Canto superior esquerdo
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Cantos arredondados
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

-- Borda luminosa
local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2
mainStroke.Color = Color3.fromRGB(100, 100, 255)
mainStroke.Transparency = 0.3
mainStroke.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, isMobile and 60 or 50)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 15)
headerCorner.Parent = header

-- Título
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "SISTEMA VIP"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = isMobile and 20 or 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Botão minimizar (maior no mobile)
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, isMobile and 40 or 30, 0, isMobile and 40 or 30)
minimizeButton.Position = UDim2.new(1, isMobile and -90 or -70, 0, (header.Size.Y.Offset - (isMobile and 40 or 30)) / 2)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = isMobile and 18 or 16
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = header

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 6)
minimizeCorner.Parent = minimizeButton

-- Botão fechar (maior no mobile)
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, isMobile and 40 or 30, 0, isMobile and 40 or 30)
closeButton.Position = UDim2.new(1, isMobile and -40 or -35, 0, (header.Size.Y.Offset - (isMobile and 40 or 30)) / 2)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = isMobile and 18 or 16
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- Container de Tabs
local tabsContainer = Instance.new("Frame")
tabsContainer.Name = "TabsContainer"
tabsContainer.Size = UDim2.new(0, isMobile and 140 or 120, 1, -header.Size.Y.Offset)
tabsContainer.Position = UDim2.new(0, 0, 0, header.Size.Y.Offset)
tabsContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
tabsContainer.BorderSizePixel = 0
tabsContainer.Parent = mainFrame

-- Container de Conteúdo
local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, -tabsContainer.Size.X.Offset, 1, -header.Size.Y.Offset)
contentContainer.Position = UDim2.new(0, tabsContainer.Size.X.Offset, 0, header.Size.Y.Offset)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- ScrollingFrame para conteúdo
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "ScrollingFrame"
scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = isMobile and 6 or 3
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.Parent = contentContainer

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, isMobile and 15 or 10)
layout.Parent = scrollingFrame

-- Partículas de fundo
local particlesFrame = Instance.new("Frame")
particlesFrame.Name = "Particles"
particlesFrame.Size = UDim2.new(1, 0, 1, 0)
particlesFrame.BackgroundTransparency = 1
particlesFrame.Parent = mainFrame

-- Criar partículas
for i = 1, 12 do
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, math.random(3, 6), 0, math.random(3, 6))
    particle.Position = UDim2.new(0, math.random(0, 450), 0, math.random(50, 350))
    particle.BackgroundColor3 = Color3.fromRGB(
        math.random(80, 150),
        math.random(80, 150),
        math.random(180, 255)
    )
    particle.BackgroundTransparency = 0.8
    particle.BorderSizePixel = 0
    particle.Parent = particlesFrame
    
    local particleCorner = Instance.new("UICorner")
    particleCorner.CornerRadius = UDim.new(1, 0)
    particleCorner.Parent = particle
end

-- Efeito de onda pulsante
local pulseRing = Instance.new("Frame")
pulseRing.Name = "PulseRing"
pulseRing.Size = UDim2.new(0, 80, 0, 80)
pulseRing.Position = UDim2.new(0.5, 0, 0.5, 0)
pulseRing.AnchorPoint = Vector2.new(0.5, 0.5)
pulseRing.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
pulseRing.BackgroundTransparency = 0.9
pulseRing.BorderSizePixel = 0
pulseRing.Parent = mainFrame

local pulseCorner = Instance.new("UICorner")
pulseCorner.CornerRadius = UDim.new(1, 0)
pulseCorner.Parent = pulseRing

-- Sistema de Tabs
local Tabs = {}
local CurrentTab = nil

-- Função para minimizar/maximizar
local function ToggleMinimize()
    if isMinimized then
        -- Maximizar
        local maximizeTween = TweenService:Create(
            mainFrame,
            TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                Size = originalSize,
                BackgroundTransparency = 0.1
            }
        )
        maximizeTween:Play()
        
        -- Mostrar conteúdo
        tabsContainer.Visible = true
        contentContainer.Visible = true
        
        -- Mudar texto do botão para "-"
        minimizeButton.Text = "-"
        
        isMinimized = false
    else
        -- Minimizar
        local minimizeTween = TweenService:Create(
            mainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {
                Size = minimizedSize,
                BackgroundTransparency = 0.05
            }
        )
        minimizeTween:Play()
        
        -- Esconder conteúdo
        tabsContainer.Visible = false
        contentContainer.Visible = false
        
        -- Mudar texto do botão para "+"
        minimizeButton.Text = "+"
        
        isMinimized = true
    end
end

local function CreateTab(tabName)
    local tab = {
        Name = tabName,
        Container = nil,
        Button = nil
    }
    
    -- Botão da Tab (maior no mobile)
    local tabHeight = isMobile and 45 or 35
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1, -10, 0, tabHeight)
    tabButton.Position = UDim2.new(0, 5, 0, 5 + (#Tabs * (tabHeight + 5)))
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.TextSize = isMobile and 16 or 14
    tabButton.Font = Enum.Font.Gotham
    tabButton.Parent = tabsContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton
    
    -- Container da Tab
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = tabName .. "Container"
    tabContainer.Size = UDim2.new(1, 0, 0, 0)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Visible = false
    tabContainer.Parent = scrollingFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, isMobile and 15 or 10)
    tabLayout.Parent = tabContainer
    
    tab.Container = tabContainer
    tab.Button = tabButton
    
    -- Evento de clique
    tabButton.MouseButton1Click:Connect(function()
        -- Deselecionar todas as tabs
        for _, otherTab in pairs(Tabs) do
            otherTab.Container.Visible = false
            otherTab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            otherTab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        
        -- Selecionar esta tab
        tab.Container.Visible = true
        tab.Button.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
        tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = tab
    end)
    
    table.insert(Tabs, tab)
    
    -- Selecionar primeira tab
    if #Tabs == 1 then
        tabButton.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabContainer.Visible = true
        CurrentTab = tab
    end
    
    return tab
end

-- Função para criar Section
local function CreateSection(sectionName, parentTab)
    local tab = parentTab or CurrentTab
    if not tab then return end
    
    local section = Instance.new("Frame")
    section.Name = sectionName .. "Section"
    section.Size = UDim2.new(1, -20, 0, isMobile and 40 or 30)
    section.BackgroundTransparency = 1
    section.Parent = tab.Container
    
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Name = "Label"
    sectionLabel.Size = UDim2.new(1, 0, 1, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = "│ " .. sectionName:upper()
    sectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sectionLabel.TextSize = isMobile and 18 or 16
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = section
    
    return section
end

-- Função para criar Button (maior no mobile)
local function CreateButton(buttonConfig, parentTab)
    local tab = parentTab or CurrentTab
    if not tab then return end
    
    local buttonHeight = isMobile and 45 or 35
    local button = Instance.new("TextButton")
    button.Name = buttonConfig.Name .. "Button"
    button.Size = UDim2.new(1, -20, 0, buttonHeight)
    button.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
    button.BorderSizePixel = 0
    button.Text = buttonConfig.Text or buttonConfig.Name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = isMobile and 16 or 14
    button.Font = Enum.Font.Gotham
    button.Parent = tab.Container
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    -- Efeito hover (apenas no PC)
    if not isMobile then
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(80, 120, 255)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 100, 255)
            }):Play()
        end)
    end
    
    -- Callback
    if buttonConfig.Callback then
        button.MouseButton1Click:Connect(buttonConfig.Callback)
    end
    
    return button
end

-- Função para criar Toggle (maior no mobile)
local function CreateToggle(toggleConfig, parentTab)
    local tab = parentTab or CurrentTab
    if not tab then return end
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = toggleConfig.Name .. "Toggle"
    toggleFrame.Size = UDim2.new(1, -20, 0, isMobile and 40 or 30)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = tab.Container
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = toggleConfig.Text or toggleConfig.Name
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextSize = isMobile and 16 or 14
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0, isMobile and 60 or 50, 0, isMobile and 30 or 25)
    toggleButton.Position = UDim2.new(1, isMobile and -60 or -50, 0, isMobile and 5 or 2)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleButton
    
    local toggleDot = Instance.new("Frame")
    toggleDot.Name = "Dot"
    toggleDot.Size = UDim2.new(0, isMobile and 26 or 21, 0, isMobile and 26 or 21)
    toggleDot.Position = UDim2.new(0, 2, 0, 2)
    toggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleDot.BorderSizePixel = 0
    toggleDot.Parent = toggleButton
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = toggleDot
    
    local state = toggleConfig.Default or false
    
    local function updateToggle()
        if state then
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 180, 100)
            }):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                Position = UDim2.new(0, isMobile and 32 or 27, 0, 2)
            }):Play()
        else
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            }):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0, 2)
            }):Play()
        end
    end
    
    updateToggle()
    
    -- Evento
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        if toggleConfig.Callback then
            toggleConfig.Callback(state)
        end
    end)
    
    return {
        Set = function(newState)
            state = newState
            updateToggle()
        end,
        Get = function()
            return state
        end
    }
end

-- ANIMAÇÕES
-- Animação de entrada
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundTransparency = 1

local entranceTween = TweenService:Create(
    mainFrame,
    TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Size = originalSize, BackgroundTransparency = 0.1}
)
entranceTween:Play()

-- Animação de pulso
local pulseTween = TweenService:Create(
    pulseRing,
    TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true),
    {Size = UDim2.new(0, 160, 0, 160), BackgroundTransparency = 1}
)
pulseTween:Play()

-- Animação das partículas
local function animateParticles()
    for _, particle in pairs(particlesFrame:GetChildren()) do
        if particle:IsA("Frame") then
            local randomX = math.random(-50, 500)
            local randomY = math.random(50, 400)
            local randomTime = math.random(4, 10)
            
            local tween = TweenService:Create(
                particle,
                TweenInfo.new(randomTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true),
                {Position = UDim2.new(0, randomX, 0, randomY)}
            )
            tween:Play()
        end
    end
end
animateParticles()

-- Efeitos de hover nos botões (apenas no PC)
if not isMobile then
    -- Botão minimizar
    minimizeButton.MouseEnter:Connect(function()
        TweenService:Create(
            minimizeButton,
            TweenInfo.new(0.2),
            {BackgroundColor3 = Color3.fromRGB(255, 200, 80), Size = UDim2.new(0, 32, 0, 32)}
        ):Play()
    end)

    minimizeButton.MouseLeave:Connect(function()
        TweenService:Create(
            minimizeButton,
            TweenInfo.new(0.2),
            {BackgroundColor3 = Color3.fromRGB(255, 180, 60), Size = UDim2.new(0, 30, 0, 30)}
        ):Play()
    end)

    -- Botão fechar
    closeButton.MouseEnter:Connect(function()
        TweenService:Create(
            closeButton,
            TweenInfo.new(0.2),
            {BackgroundColor3 = Color3.fromRGB(255, 100, 100), Size = UDim2.new(0, 32, 0, 32)}
        ):Play()
    end)

    closeButton.MouseLeave:Connect(function()
        TweenService:Create(
            closeButton,
            TweenInfo.new(0.2),
            {BackgroundColor3 = Color3.fromRGB(255, 80, 80), Size = UDim2.new(0, 30, 0, 30)}
        ):Play()
    end)
end

-- Evento do botão minimizar
minimizeButton.MouseButton1Click:Connect(ToggleMinimize)

-- Função fechar
closeButton.MouseButton1Click:Connect(function()
    local exitTween = TweenService:Create(
        mainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}
    )
    
    exitTween:Play()
    exitTween.Completed:Connect(function()
        screenGui:Destroy()
        blurEffect.Enabled = false
    end)
end)

-- Atualizar canvas size
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)

-- REMOVIDO: Sistema de drag (agora a GUI é fixa)

print("🎮 BeautifulGUI Carregada!")
print("📟 Plataforma: " .. (isMobile and "📱 MOBILE" or "🖥️ PC"))
print("📍 Posição: Canto superior esquerdo")
print("📌 Use o botão '-' para minimizar/expandir")

-- EXPORTAR FUNÇÕES
return {
    CreateTab = CreateTab,
    CreateSection = CreateSection,
    CreateButton = CreateButton,
    CreateToggle = CreateToggle,
    ToggleMinimize = ToggleMinimize
}