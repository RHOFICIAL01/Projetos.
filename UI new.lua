local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Criar a ScreenGui principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BeautifulGUI"
screenGui.Parent = playerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Efeito de blur background
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 8
blurEffect.Parent = game:GetService("Lighting")

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 550, 0, 450)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
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

-- Header com imagem de perfil
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 80)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 15)
headerCorner.Parent = header

-- Imagem de perfil (estilo Redz)
local profileImage = Instance.new("ImageLabel")
profileImage.Name = "ProfileImage"
profileImage.Size = UDim2.new(0, 50, 0, 50)
profileImage.Position = UDim2.new(0, 20, 0, 15)
profileImage.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
profileImage.BorderSizePixel = 0
profileImage.Image = "rbxassetid://9922529657" -- Imagem padrão de avatar
profileImage.Parent = header

local profileCorner = Instance.new("UICorner")
profileCorner.CornerRadius = UDim.new(1, 0)
profileCorner.Parent = profileImage

-- Borda na imagem de perfil
local profileStroke = Instance.new("UIStroke")
profileStroke.Thickness = 2
profileStroke.Color = Color3.fromRGB(100, 100, 255)
profileStroke.Parent = profileImage

-- Informações do usuário
local userInfo = Instance.new("Frame")
userInfo.Name = "UserInfo"
userInfo.Size = UDim2.new(0, 200, 0, 50)
userInfo.Position = UDim2.new(0, 85, 0, 15)
userInfo.BackgroundTransparency = 1
userInfo.Parent = header

local userName = Instance.new("TextLabel")
userName.Name = "UserName"
userName.Size = UDim2.new(1, 0, 0, 25)
userName.Position = UDim2.new(0, 0, 0, 0)
userName.BackgroundTransparency = 1
userName.Text = player.Name
userName.TextColor3 = Color3.fromRGB(255, 255, 255)
userName.TextSize = 16
userName.Font = Enum.Font.GothamBold
userName.TextXAlignment = Enum.TextXAlignment.Left
userName.Parent = userInfo

local userStatus = Instance.new("TextLabel")
userStatus.Name = "UserStatus"
userStatus.Size = UDim2.new(1, 0, 0, 20)
userStatus.Position = UDim2.new(0, 0, 0, 25)
userStatus.BackgroundTransparency = 1
userStatus.Text = "Status: Premium"
userStatus.TextColor3 = Color3.fromRGB(100, 200, 255)
userStatus.TextSize = 12
userStatus.Font = Enum.Font.Gotham
userStatus.TextXAlignment = Enum.TextXAlignment.Left
userStatus.Parent = userInfo

-- Botão fechar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 20)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

-- Container de Tabs
local tabsContainer = Instance.new("Frame")
tabsContainer.Name = "TabsContainer"
tabsContainer.Size = UDim2.new(0, 140, 1, -80)
tabsContainer.Position = UDim2.new(0, 0, 0, 80)
tabsContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
tabsContainer.BorderSizePixel = 0
tabsContainer.Parent = mainFrame

-- Container de Conteúdo
local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, -140, 1, -80)
contentContainer.Position = UDim2.new(0, 140, 0, 80)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- ScrollingFrame para conteúdo
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "ScrollingFrame"
scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 3
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.Parent = contentContainer

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
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
    particle.Position = UDim2.new(0, math.random(0, 500), 0, math.random(80, 400))
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

local function CreateTab(tabConfig)
    local tabName = tabConfig.Name
    local tabIcon = tabConfig.Icon or "rbxassetid://10723359658" -- Ícone padrão
    
    local tab = {
        Name = tabName,
        Container = nil,
        Button = nil
    }
    
    -- Botão da Tab com ícone
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1, -10, 0, 45)
    tabButton.Position = UDim2.new(0, 5, 0, 5 + (#Tabs * 50))
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tabButton.BorderSizePixel = 0
    tabButton.Text = ""
    tabButton.Parent = tabsContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabButton
    
    -- Ícone da Tab
    local tabIconImage = Instance.new("ImageLabel")
    tabIconImage.Name = "Icon"
    tabIconImage.Size = UDim2.new(0, 25, 0, 25)
    tabIconImage.Position = UDim2.new(0, 15, 0, 10)
    tabIconImage.BackgroundTransparency = 1
    tabIconImage.Image = tabIcon
    tabIconImage.ImageColor3 = Color3.fromRGB(200, 200, 200)
    tabIconImage.Parent = tabButton
    
    -- Nome da Tab
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Name = "Label"
    tabLabel.Size = UDim2.new(0, 80, 1, 0)
    tabLabel.Position = UDim2.new(0, 50, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = tabName
    tabLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabLabel.TextSize = 14
    tabLabel.Font = Enum.Font.Gotham
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.Parent = tabButton
    
    -- Container da Tab
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = tabName .. "Container"
    tabContainer.Size = UDim2.new(1, 0, 0, 0)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Visible = false
    tabContainer.Parent = scrollingFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 10)
    tabLayout.Parent = tabContainer
    
    tab.Container = tabContainer
    tab.Button = tabButton
    
    -- Evento de clique
    tabButton.MouseButton1Click:Connect(function()
        -- Deselecionar todas as tabs
        for _, otherTab in pairs(Tabs) do
            otherTab.Container.Visible = false
            otherTab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            otherTab.Button:FindFirstChild("Label").TextColor3 = Color3.fromRGB(200, 200, 200)
            otherTab.Button:FindFirstChild("Icon").ImageColor3 = Color3.fromRGB(200, 200, 200)
        end
        
        -- Selecionar esta tab
        tab.Container.Visible = true
        tab.Button.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
        tab.Button:FindFirstChild("Label").TextColor3 = Color3.fromRGB(255, 255, 255)
        tab.Button:FindFirstChild("Icon").ImageColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = tab
    end)
    
    table.insert(Tabs, tab)
    
    -- Selecionar primeira tab
    if #Tabs == 1 then
        tabButton.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
        tabButton:FindFirstChild("Label").TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton:FindFirstChild("Icon").ImageColor3 = Color3.fromRGB(255, 255, 255)
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
    section.Size = UDim2.new(1, -20, 0, 35)
    section.BackgroundTransparency = 1
    section.Parent = tab.Container
    
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Name = "Label"
    sectionLabel.Size = UDim2.new(1, 0, 1, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = "▸ " .. sectionName:upper()
    sectionLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    sectionLabel.TextSize = 14
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = section
    
    return section
end

-- Função para criar Button com ícone
local function CreateButton(buttonConfig, parentTab)
    local tab = parentTab or CurrentTab
    if not tab then return end
    
    local button = Instance.new("TextButton")
    button.Name = buttonConfig.Name .. "Button"
    button.Size = UDim2.new(1, -20, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = tab.Container
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    -- Ícone do botão (se fornecido)
    if buttonConfig.Icon then
        local buttonIcon = Instance.new("ImageLabel")
        buttonIcon.Name = "Icon"
        buttonIcon.Size = UDim2.new(0, 20, 0, 20)
        buttonIcon.Position = UDim2.new(0, 15, 0, 10)
        buttonIcon.BackgroundTransparency = 1
        buttonIcon.Image = buttonConfig.Icon
        buttonIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        buttonIcon.Parent = button
    end
    
    -- Texto do botão
    local buttonText = Instance.new("TextLabel")
    buttonText.Name = "Text"
    buttonText.Size = UDim2.new(1, -50, 1, 0)
    buttonText.Position = UDim2.new(0, buttonConfig.Icon and 45 or 15, 0, 0)
    buttonText.BackgroundTransparency = 1
    buttonText.Text = buttonConfig.Text or buttonConfig.Name
    buttonText.TextColor3 = Color3.fromRGB(255, 255, 255)
    buttonText.TextSize = 14
    buttonText.Font = Enum.Font.Gotham
    buttonText.TextXAlignment = Enum.TextXAlignment.Left
    buttonText.Parent = button
    
    -- Efeito hover
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
    
    -- Callback
    if buttonConfig.Callback then
        button.MouseButton1Click:Connect(buttonConfig.Callback)
    end
    
    return button
end

-- Função para criar Toggle com ícone
local function CreateToggle(toggleConfig, parentTab)
    local tab = parentTab or CurrentTab
    if not tab then return end
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = toggleConfig.Name .. "Toggle"
    toggleFrame.Size = UDim2.new(1, -20, 0, 35)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = tab.Container
    
    -- Ícone do toggle (se fornecido)
    if toggleConfig.Icon then
        local toggleIcon = Instance.new("ImageLabel")
        toggleIcon.Name = "Icon"
        toggleIcon.Size = UDim2.new(0, 20, 0, 20)
        toggleIcon.Position = UDim2.new(0, 0, 0, 7)
        toggleIcon.BackgroundTransparency = 1
        toggleIcon.Image = toggleConfig.Icon
        toggleIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        toggleIcon.Parent = toggleFrame
    end
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    toggleLabel.Position = UDim2.new(0, toggleConfig.Icon and 30 or 0, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = toggleConfig.Text or toggleConfig.Name
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextSize = 14
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0, 50, 0, 25)
    toggleButton.Position = UDim2.new(1, -50, 0, 5)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleButton
    
    local toggleDot = Instance.new("Frame")
    toggleDot.Name = "Dot"
    toggleDot.Size = UDim2.new(0, 21, 0, 21)
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
                Position = UDim2.new(0, 27, 0, 2)
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

-- Função para criar Card com imagem (estilo Redz)
local function CreateCard(cardConfig, parentTab)
    local tab = parentTab or CurrentTab
    if not tab then return end
    
    local card = Instance.new("Frame")
    card.Name = cardConfig.Name .. "Card"
    card.Size = UDim2.new(1, -20, 0, 80)
    card.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    card.BorderSizePixel = 0
    card.Parent = tab.Container
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card
    
    -- Imagem do card
    local cardImage = Instance.new("ImageLabel")
    cardImage.Name = "Image"
    cardImage.Size = UDim2.new(0, 60, 0, 60)
    cardImage.Position = UDim2.new(0, 10, 0, 10)
    cardImage.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    cardImage.BorderSizePixel = 0
    cardImage.Image = cardConfig.Image or "rbxassetid://10723359658"
    cardImage.Parent = card
    
    local imageCorner = Instance.new("UICorner")
    imageCorner.CornerRadius = UDim.new(0, 8)
    imageCorner.Parent = cardImage
    
    -- Título do card
    local cardTitle = Instance.new("TextLabel")
    cardTitle.Name = "Title"
    cardTitle.Size = UDim2.new(0, 200, 0, 25)
    cardTitle.Position = UDim2.new(0, 80, 0, 15)
    cardTitle.BackgroundTransparency = 1
    cardTitle.Text = cardConfig.Title or cardConfig.Name
    cardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    cardTitle.TextSize = 16
    cardTitle.Font = Enum.Font.GothamBold
    cardTitle.TextXAlignment = Enum.TextXAlignment.Left
    cardTitle.Parent = card
    
    -- Descrição do card
    local cardDesc = Instance.new("TextLabel")
    cardDesc.Name = "Description"
    cardDesc.Size = UDim2.new(0, 200, 0, 20)
    cardDesc.Position = UDim2.new(0, 80, 0, 40)
    cardDesc.BackgroundTransparency = 1
    cardDesc.Text = cardConfig.Description or ""
    cardDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
    cardDesc.TextSize = 12
    cardDesc.Font = Enum.Font.Gotham
    cardDesc.TextXAlignment = Enum.TextXAlignment.Left
    cardDesc.Parent = card
    
    -- Botão de ação
    if cardConfig.ButtonText then
        local cardButton = Instance.new("TextButton")
        cardButton.Name = "ActionButton"
        cardButton.Size = UDim2.new(0, 80, 0, 25)
        cardButton.Position = UDim2.new(1, -90, 0, 27)
        cardButton.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
        cardButton.BorderSizePixel = 0
        cardButton.Text = cardConfig.ButtonText
        cardButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        cardButton.TextSize = 12
        cardButton.Font = Enum.Font.Gotham
        cardButton.Parent = card
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = cardButton
        
        -- Efeito hover
        cardButton.MouseEnter:Connect(function()
            TweenService:Create(cardButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(80, 120, 255)
            }):Play()
        end)
        
        cardButton.MouseLeave:Connect(function()
            TweenService:Create(cardButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 100, 255)
            }):Play()
        end)
        
        -- Callback
        if cardConfig.Callback then
            cardButton.MouseButton1Click:Connect(cardConfig.Callback)
        end
    end
    
    return card
end

-- ANIMAÇÕES
-- Animação de entrada
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundTransparency = 1

local entranceTween = TweenService:Create(
    mainFrame,
    TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Size = UDim2.new(0, 550, 0, 450), BackgroundTransparency = 0.1}
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
            local randomX = math.random(-50, 550)
            local randomY = math.random(80, 450)
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

-- Efeitos de hover no botão fechar
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

-- Sistema de drag
local dragging = false
local dragInput, dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- EXPORTAR FUNÇÕES
return {
    CreateTab = CreateTab,
    CreateSection = CreateSection,
    CreateButton = CreateButton,
    CreateToggle = CreateToggle,
    CreateCard = CreateCard,
    
    -- Funções extras para personalização
    SetProfileImage = function(imageId)
        profileImage.Image = imageId
    end,
    
    SetUserName = function(name)
        userName.Text = name
    end,
    
    SetUserStatus = function(status)
        userStatus.Text = status
    end
}