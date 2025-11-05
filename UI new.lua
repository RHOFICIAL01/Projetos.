-- BeautifulGUI Library
-- Versão: 2.0 - Compatível com PC e Mobile
-- Features: Botão de minimizar, Tabs, Buttons, Efeitos Visuais

local BeautifulGUI = {}
BeautifulGUI.__index = BeautifulGUI

-- Serviços
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Configuração padrão
local DefaultConfig = {
    Name = "BeautifulGUI",
    Theme = "Dark",
    Position = UDim2.new(0.5, -250, 0.5, -200),
    EnableBlur = false,
    EnableParticles = true,
    EnablePulse = true
}

-- Temas
local Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 30),
        Header = Color3.fromRGB(30, 30, 45),
        Tab = Color3.fromRGB(40, 40, 50),
        TabSelected = Color3.fromRGB(60, 100, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        Button = Color3.fromRGB(60, 100, 255),
        ButtonHover = Color3.fromRGB(80, 120, 255),
        CloseButton = Color3.fromRGB(255, 80, 80),
        CloseButtonHover = Color3.fromRGB(255, 100, 100),
        MinimizeButton = Color3.fromRGB(255, 180, 60),
        MinimizeButtonHover = Color3.fromRGB(255, 200, 80)
    }
}

function BeautifulGUI.new(config)
    local self = setmetatable({}, BeautifulGUI)
    
    self.Config = setmetatable(config or {}, {__index = DefaultConfig})
    self.Theme = Themes[self.Config.Theme] or Themes.Dark
    self.Tabs = {}
    self.CurrentTab = nil
    self.Connections = {}
    self.guiVisible = true
    self.isMinimized = false
    
    -- Detectar plataforma
    self.isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
    
    self:Initialize()
    return self
end

-- Função para detectar plataforma
function BeautifulGUI:IsMobile()
    return self.isMobile
end

-- Inicialização
function BeautifulGUI:Initialize()
    self.player = Players.LocalPlayer
    self.playerGui = self.player:WaitForChild("PlayerGui")
    
    self:CreateMainGUI()
    
    print("🎮 BeautifulGUI Carregada!")
    print("📟 Plataforma: " .. (self:IsMobile() and "📱 MOBILE" or "🖥️ PC"))
    print("✨ Efeitos visuais ativados!")
    print("📌 Use o botão '--' para minimizar/expandir")
end

-- =============================================
-- GUI PRINCIPAL COM EFEITOS
-- =============================================

function BeautifulGUI:CreateMainGUI()
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "MainGUI"
    self.screenGui.Parent = self.playerGui
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Enabled = true
    self.screenGui.ResetOnSpawn = false

    -- Blur effect (opcional)
    if self.Config.EnableBlur then
        self.blurEffect = Instance.new("BlurEffect")
        self.blurEffect.Size = 8
        self.blurEffect.Enabled = false
        self.blurEffect.Parent = game:GetService("Lighting")
    end

    -- Ajustar tamanho baseado na plataforma
    self.guiWidth = self:IsMobile() and 400 or 500
    self.guiHeight = self:IsMobile() and 500 or 400

    -- Frame principal
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, self.guiWidth, 0, self.guiHeight)
    self.mainFrame.Position = self.Config.Position
    self.mainFrame.BackgroundColor3 = self.Theme.Background
    self.mainFrame.BackgroundTransparency = 0.1
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.ClipsDescendants = true
    self.mainFrame.Parent = self.screenGui

    -- Cantos arredondados
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = self.mainFrame

    -- Borda luminosa com efeito
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Thickness = 2
    mainStroke.Color = Color3.fromRGB(100, 100, 255)
    mainStroke.Transparency = 0.3
    mainStroke.Parent = self.mainFrame

    -- Efeito de partículas de fundo
    if self.Config.EnableParticles then
        self.particlesFrame = Instance.new("Frame")
        self.particlesFrame.Name = "Particles"
        self.particlesFrame.Size = UDim2.new(1, 0, 1, 0)
        self.particlesFrame.BackgroundTransparency = 1
        self.particlesFrame.Parent = self.mainFrame

        -- Criar partículas
        for i = 1, 12 do
            local particle = Instance.new("Frame")
            particle.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
            particle.Position = UDim2.new(0, math.random(0, self.guiWidth), 0, math.random(0, self.guiHeight))
            particle.BackgroundColor3 = Color3.fromRGB(
                math.random(80, 150),
                math.random(80, 150),
                math.random(180, 255)
            )
            particle.BackgroundTransparency = 0.8
            particle.BorderSizePixel = 0
            particle.ZIndex = 0
            particle.Parent = self.particlesFrame
            
            local particleCorner = Instance.new("UICorner")
            particleCorner.CornerRadius = UDim.new(1, 0)
            particleCorner.Parent = particle
        end
    end

    -- Efeito de onda pulsante
    if self.Config.EnablePulse then
        self.pulseRing = Instance.new("Frame")
        self.pulseRing.Name = "PulseRing"
        self.pulseRing.Size = UDim2.new(0, 80, 0, 80)
        self.pulseRing.Position = UDim2.new(0.5, -40, 0.5, -40)
        self.pulseRing.AnchorPoint = Vector2.new(0.5, 0.5)
        self.pulseRing.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
        self.pulseRing.BackgroundTransparency = 0.9
        self.pulseRing.BorderSizePixel = 0
        self.pulseRing.ZIndex = 0
        self.pulseRing.Parent = self.mainFrame

        local pulseCorner = Instance.new("UICorner")
        pulseCorner.CornerRadius = UDim.new(1, 0)
        pulseCorner.Parent = self.pulseRing
    end

    -- Header
    self.headerHeight = self:IsMobile() and 60 or 50
    self.header = Instance.new("Frame")
    self.header.Name = "Header"
    self.header.Size = UDim2.new(1, 0, 0, self.headerHeight)
    self.header.Position = UDim2.new(0, 0, 0, 0)
    self.header.BackgroundColor3 = self.Theme.Header
    self.header.BackgroundTransparency = 0.1
    self.header.BorderSizePixel = 0
    self.header.ZIndex = 2
    self.header.Parent = self.mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = self.header

    -- Gradiente no header
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Theme.Header),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 60))
    })
    headerGradient.Rotation = 90
    headerGradient.Parent = self.header

    -- Título
    self.title = Instance.new("TextLabel")
    self.title.Name = "Title"
    self.title.Size = UDim2.new(0.6, 0, 1, 0)
    self.title.Position = UDim2.new(0, 20, 0, 0)
    self.title.BackgroundTransparency = 1
    self.title.Text = self.Config.Name
    self.title.TextColor3 = self.Theme.Text
    self.title.TextSize = self:IsMobile() and 20 or 18
    self.title.Font = Enum.Font.GothamBold
    self.title.TextXAlignment = Enum.TextXAlignment.Left
    self.title.ZIndex = 3
    self.title.Parent = self.header

    -- Sombra no texto do título
    local titleStroke = Instance.new("UIStroke")
    titleStroke.Thickness = 1
    titleStroke.Color = Color3.fromRGB(0, 0, 0)
    titleStroke.Transparency = 0.5
    titleStroke.Parent = self.title

    -- Botão minimizar
    self.minimizeButton = Instance.new("TextButton")
    self.minimizeButton.Name = "MinimizeButton"
    self.minimizeButton.Size = UDim2.new(0, 40, 0, 30)
    self.minimizeButton.Position = UDim2.new(1, -90, 0, (self.headerHeight - 30) / 2)
    self.minimizeButton.BackgroundColor3 = self.Theme.MinimizeButton
    self.minimizeButton.BorderSizePixel = 0
    self.minimizeButton.Text = "--"
    self.minimizeButton.TextColor3 = self.Theme.Text
    self.minimizeButton.TextSize = self:IsMobile() and 16 or 14
    self.minimizeButton.Font = Enum.Font.GothamBold
    self.minimizeButton.ZIndex = 3
    self.minimizeButton.Parent = self.header

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = self.minimizeButton

    -- Botão fechar
    self.closeButton = Instance.new("TextButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0, 30, 0, 30)
    self.closeButton.Position = UDim2.new(1, -40, 0, (self.headerHeight - 30) / 2)
    self.closeButton.BackgroundColor3 = self.Theme.CloseButton
    self.closeButton.BorderSizePixel = 0
    self.closeButton.Text = "X"
    self.closeButton.TextColor3 = self.Theme.Text
    self.closeButton.TextSize = self:IsMobile() and 16 or 14
    self.closeButton.Font = Enum.Font.GothamBold
    self.closeButton.ZIndex = 3
    self.closeButton.Parent = self.header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = self.closeButton

    -- Container de Tabs
    self.tabsWidth = self:IsMobile() and 140 or 120
    self.tabsContainer = Instance.new("Frame")
    self.tabsContainer.Name = "TabsContainer"
    self.tabsContainer.Size = UDim2.new(0, self.tabsWidth, 1, -self.headerHeight)
    self.tabsContainer.Position = UDim2.new(0, 0, 0, self.headerHeight)
    self.tabsContainer.BackgroundColor3 = self.Theme.Tab
    self.tabsContainer.BorderSizePixel = 0
    self.tabsContainer.ZIndex = 2
    self.tabsContainer.Parent = self.mainFrame

    -- Gradiente no container de tabs
    local tabsGradient = Instance.new("UIGradient")
    tabsGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Theme.Tab),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 45))
    })
    tabsGradient.Rotation = 90
    tabsGradient.Parent = self.tabsContainer

    -- Container de Conteúdo
    self.contentContainer = Instance.new("Frame")
    self.contentContainer.Name = "ContentContainer"
    self.contentContainer.Size = UDim2.new(1, -self.tabsWidth, 1, -self.headerHeight)
    self.contentContainer.Position = UDim2.new(0, self.tabsWidth, 0, self.headerHeight)
    self.contentContainer.BackgroundTransparency = 1
    self.contentContainer.ZIndex = 2
    self.contentContainer.Parent = self.mainFrame

    -- ScrollingFrame para conteúdo
    self.scrollingFrame = Instance.new("ScrollingFrame")
    self.scrollingFrame.Name = "ScrollingFrame"
    self.scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    self.scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
    self.scrollingFrame.BackgroundTransparency = 1
    self.scrollingFrame.BorderSizePixel = 0
    self.scrollingFrame.ScrollBarThickness = self:IsMobile() and 6 or 3
    self.scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.scrollingFrame.ZIndex = 2
    self.scrollingFrame.Parent = self.contentContainer

    self.layout = Instance.new("UIListLayout")
    self.layout.Padding = UDim.new(0, self:IsMobile() and 15 or 10)
    self.layout.Parent = self.scrollingFrame

    -- Frame minimizado (apenas mostra o título)
    self.minimizedFrame = Instance.new("Frame")
    self.minimizedFrame.Name = "MinimizedFrame"
    self.minimizedFrame.Size = UDim2.new(0, 200, 0, self.headerHeight)
    self.minimizedFrame.Position = self.Config.Position
    self.minimizedFrame.BackgroundColor3 = self.Theme.Header
    self.minimizedFrame.BackgroundTransparency = 0.1
    self.minimizedFrame.BorderSizePixel = 0
    self.minimizedFrame.Visible = false
    self.minimizedFrame.ZIndex = 10
    self.minimizedFrame.Parent = self.screenGui

    local minimizedCorner = Instance.new("UICorner")
    minimizedCorner.CornerRadius = UDim.new(0, 15)
    minimizedCorner.Parent = self.minimizedFrame

    local minimizedStroke = Instance.new("UIStroke")
    minimizedStroke.Thickness = 2
    minimizedStroke.Color = Color3.fromRGB(100, 100, 255)
    minimizedStroke.Transparency = 0.3
    minimizedStroke.Parent = self.minimizedFrame

    -- Gradiente na frame minimizada
    local minimizedGradient = Instance.new("UIGradient")
    minimizedGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Theme.Header),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 60))
    })
    minimizedGradient.Rotation = 90
    minimizedGradient.Parent = self.minimizedFrame

    self.minimizedTitle = Instance.new("TextLabel")
    self.minimizedTitle.Name = "MinimizedTitle"
    self.minimizedTitle.Size = UDim2.new(0.7, 0, 1, 0)
    self.minimizedTitle.Position = UDim2.new(0, 15, 0, 0)
    self.minimizedTitle.BackgroundTransparency = 1
    self.minimizedTitle.Text = self.Config.Name
    self.minimizedTitle.TextColor3 = self.Theme.Text
    self.minimizedTitle.TextSize = self:IsMobile() and 16 or 14
    self.minimizedTitle.Font = Enum.Font.GothamBold
    self.minimizedTitle.TextXAlignment = Enum.TextXAlignment.Left
    self.minimizedTitle.ZIndex = 11
    self.minimizedTitle.Parent = self.minimizedFrame

    -- Sombra no texto minimizado
    local minimizedTitleStroke = Instance.new("UIStroke")
    minimizedTitleStroke.Thickness = 1
    minimizedTitleStroke.Color = Color3.fromRGB(0, 0, 0)
    minimizedTitleStroke.Transparency = 0.5
    minimizedTitleStroke.Parent = self.minimizedTitle

    self.minimizedToggleButton = Instance.new("TextButton")
    self.minimizedToggleButton.Name = "MinimizedToggleButton"
    self.minimizedToggleButton.Size = UDim2.new(0, 40, 0, 30)
    self.minimizedToggleButton.Position = UDim2.new(1, -45, 0, (self.headerHeight - 30) / 2)
    self.minimizedToggleButton.BackgroundColor3 = self.Theme.MinimizeButton
    self.minimizedToggleButton.BorderSizePixel = 0
    self.minimizedToggleButton.Text = "+"
    self.minimizedToggleButton.TextColor3 = self.Theme.Text
    self.minimizedToggleButton.TextSize = self:IsMobile() and 16 or 14
    self.minimizedToggleButton.Font = Enum.Font.GothamBold
    self.minimizedToggleButton.ZIndex = 11
    self.minimizedToggleButton.Parent = self.minimizedFrame

    local minimizedToggleCorner = Instance.new("UICorner")
    minimizedToggleCorner.CornerRadius = UDim.new(0, 6)
    minimizedToggleCorner.Parent = self.minimizedToggleButton

    -- Configurar eventos e iniciar animações
    self:SetupGUIEvents()
    self:StartAnimations()
end

-- Iniciar animações
function BeautifulGUI:StartAnimations()
    -- Animação de partículas
    if self.Config.EnableParticles and self.particlesFrame then
        for _, particle in pairs(self.particlesFrame:GetChildren()) do
            if particle:IsA("Frame") then
                local randomX = math.random(-50, self.guiWidth + 50)
                local randomY = math.random(-50, self.guiHeight + 50)
                local randomTime = math.random(5, 15)
                
                local tween = TweenService:Create(
                    particle,
                    TweenInfo.new(randomTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true),
                    {Position = UDim2.new(0, randomX, 0, randomY)}
                )
                tween:Play()
            end
        end
    end

    -- Animação de pulso
    if self.Config.EnablePulse and self.pulseRing then
        local pulseTween = TweenService:Create(
            self.pulseRing,
            TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true),
            {Size = UDim2.new(0, 160, 0, 160), BackgroundTransparency = 1}
        )
        pulseTween:Play()
    end

    -- Animação de brilho na borda
    local glowTween = TweenService:Create(
        self.mainFrame.UIStroke,
        TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true),
        {Transparency = 0.1}
    )
    glowTween:Play()
end

-- Configurar eventos da GUI
function BeautifulGUI:SetupGUIEvents()
    -- Botão fechar
    self.closeButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)

    -- Botão minimizar
    self.minimizeButton.MouseButton1Click:Connect(function()
        self:Minimize()
    end)

    -- Botão expandir (na frame minimizada)
    self.minimizedToggleButton.MouseButton1Click:Connect(function()
        self:Maximize()
    end)

    -- Atualizar canvas size
    self.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.layout.AbsoluteContentSize.Y)
    end)

    -- Sistema de drag para a GUI principal
    local mainDragging = false
    local mainDragStart, mainStartPos

    self.header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            mainDragging = true
            mainDragStart = input.Position
            mainStartPos = self.mainFrame.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            mainDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if mainDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                           input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mainDragStart
            self.mainFrame.Position = UDim2.new(
                mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X,
                mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Sistema de drag para a frame minimizada
    local minimizedDragging = false
    local minimizedDragStart, minimizedStartPos

    self.minimizedFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            minimizedDragging = true
            minimizedDragStart = input.Position
            minimizedStartPos = self.minimizedFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if minimizedDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                               input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - minimizedDragStart
            self.minimizedFrame.Position = UDim2.new(
                minimizedStartPos.X.Scale, minimizedStartPos.X.Offset + delta.X,
                minimizedStartPos.Y.Scale, minimizedStartPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Efeitos hover para botões (apenas no PC)
    if not self:IsMobile() then
        -- Botão minimizar
        self.minimizeButton.MouseEnter:Connect(function()
            TweenService:Create(self.minimizeButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.MinimizeButtonHover,
                Size = UDim2.new(0, 42, 0, 32)
            }):Play()
        end)

        self.minimizeButton.MouseLeave:Connect(function()
            TweenService:Create(self.minimizeButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.MinimizeButton,
                Size = UDim2.new(0, 40, 0, 30)
            }):Play()
        end)

        -- Botão fechar
        self.closeButton.MouseEnter:Connect(function()
            TweenService:Create(self.closeButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.CloseButtonHover,
                Size = UDim2.new(0, 32, 0, 32)
            }):Play()
        end)

        self.closeButton.MouseLeave:Connect(function()
            TweenService:Create(self.closeButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.CloseButton
    self.closeButton.BorderSizePixel = 0
    self.closeButton.Text = "X"
    self.closeButton.TextColor3 = self.Theme.Text
    self.closeButton.TextSize = self:IsMobile() and 16 or 14
    self.closeButton.Font = Enum.Font.GothamBold
    self.closeButton.ZIndex = 3
    self.closeButton.Parent = self.header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = self.closeButton

    -- Container de Tabs
    self.tabsWidth = self:IsMobile() and 140 or 120
    self.tabsContainer = Instance.new("Frame")
    self.tabsContainer.Name = "TabsContainer"
    self.tabsContainer.Size = UDim2.new(0, self.tabsWidth, 1, -self.headerHeight)
    self.tabsContainer.Position = UDim2.new(0, 0, 0, self.headerHeight)
    self.tabsContainer.BackgroundColor3 = self.Theme.Tab
    self.tabsContainer.BorderSizePixel = 0
    self.tabsContainer.ZIndex = 2
    self.tabsContainer.Parent = self.mainFrame

    -- Gradiente no container de tabs
    local tabsGradient = Instance.new("UIGradient")
    tabsGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Theme.Tab),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 45))
    })
    tabsGradient.Rotation = 90
    tabsGradient.Parent = self.tabsContainer

    -- Container de Conteúdo
    self.contentContainer = Instance.new("Frame")
    self.contentContainer.Name = "ContentContainer"
    self.contentContainer.Size = UDim2.new(1, -self.tabsWidth, 1, -self.headerHeight)
    self.contentContainer.Position = UDim2.new(0, self.tabsWidth, 0, self.headerHeight)
    self.contentContainer.BackgroundTransparency = 1
    self.contentContainer.ZIndex = 2
    self.contentContainer.Parent = self.mainFrame

    -- ScrollingFrame para conteúdo
    self.scrollingFrame = Instance.new("ScrollingFrame")
    self.scrollingFrame.Name = "ScrollingFrame"
    self.scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    self.scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
    self.scrollingFrame.BackgroundTransparency = 1
    self.scrollingFrame.BorderSizePixel = 0
    self.scrollingFrame.ScrollBarThickness = self:IsMobile() and 6 or 3
    self.scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.scrollingFrame.ZIndex = 2
    self.scrollingFrame.Parent = self.contentContainer

    self.layout = Instance.new("UIListLayout")
    self.layout.Padding = UDim.new(0, self:IsMobile() and 15 or 10)
    self.layout.Parent = self.scrollingFrame

    -- Frame minimizado (apenas mostra o título)
    self.minimizedFrame = Instance.new("Frame")
    self.minimizedFrame.Name = "MinimizedFrame"
    self.minimizedFrame.Size = UDim2.new(0, 200, 0, self.headerHeight)
    self.minimizedFrame.Position = self.Config.Position
    self.minimizedFrame.BackgroundColor3 = self.Theme.Header
    self.minimizedFrame.BackgroundTransparency = 0.1
    self.minimizedFrame.BorderSizePixel = 0
    self.minimizedFrame.Visible = false
    self.minimizedFrame.ZIndex = 10
    self.minimizedFrame.Parent = self.screenGui

    local minimizedCorner = Instance.new("UICorner")
    minimizedCorner.CornerRadius = UDim.new(0, 15)
    minimizedCorner.Parent = self.minimizedFrame

    local minimizedStroke = Instance.new("UIStroke")
    minimizedStroke.Thickness = 2
    minimizedStroke.Color = Color3.fromRGB(100, 100, 255)
    minimizedStroke.Transparency = 0.3
    minimizedStroke.Parent = self.minimizedFrame

    -- Gradiente na frame minimizada
    local minimizedGradient = Instance.new("UIGradient")
    minimizedGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Theme.Header),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 60))
    })
    minimizedGradient.Rotation = 90
    minimizedGradient.Parent = self.minimizedFrame

    self.minimizedTitle = Instance.new("TextLabel")
    self.minimizedTitle.Name = "MinimizedTitle"
    self.minimizedTitle.Size = UDim2.new(0.7, 0, 1, 0)
    self.minimizedTitle.Position = UDim2.new(0, 15, 0, 0)
    self.minimizedTitle.BackgroundTransparency = 1
    self.minimizedTitle.Text = self.Config.Name
    self.minimizedTitle.TextColor3 = self.Theme.Text
    self.minimizedTitle.TextSize = self:IsMobile() and 16 or 14
    self.minimizedTitle.Font = Enum.Font.GothamBold
    self.minimizedTitle.TextXAlignment = Enum.TextXAlignment.Left
    self.minimizedTitle.ZIndex = 11
    self.minimizedTitle.Parent = self.minimizedFrame

    -- Sombra no texto minimizado
    local minimizedTitleStroke = Instance.new("UIStroke")
    minimizedTitleStroke.Thickness = 1
    minimizedTitleStroke.Color = Color3.fromRGB(0, 0, 0)
    minimizedTitleStroke.Transparency = 0.5
    minimizedTitleStroke.Parent = self.minimizedTitle

    self.minimizedToggleButton = Instance.new("TextButton")
    self.minimizedToggleButton.Name = "MinimizedToggleButton"
    self.minimizedToggleButton.Size = UDim2.new(0, 40, 0, 30)
    self.minimizedToggleButton.Position = UDim2.new(1, -45, 0, (self.headerHeight - 30) / 2)
    self.minimizedToggleButton.BackgroundColor3 = self.Theme.MinimizeButton
    self.minimizedToggleButton.BorderSizePixel = 0
    self.minimizedToggleButton.Text = "+"
    self.minimizedToggleButton.TextColor3 = self.Theme.Text
    self.minimizedToggleButton.TextSize = self:IsMobile() and 16 or 14
    self.minimizedToggleButton.Font = Enum.Font.GothamBold
    self.minimizedToggleButton.ZIndex = 11
    self.minimizedToggleButton.Parent = self.minimizedFrame

    local minimizedToggleCorner = Instance.new("UICorner")
    minimizedToggleCorner.CornerRadius = UDim.new(0, 6)
    minimizedToggleCorner.Parent = self.minimizedToggleButton

    -- Configurar eventos e iniciar animações
    self:SetupGUIEvents()
    self:StartAnimations()
end

-- Iniciar animações
function BeautifulGUI:StartAnimations()
    -- Animação de partículas
    if self.Config.EnableParticles and self.particlesFrame then
        for _, particle in pairs(self.particlesFrame:GetChildren()) do
            if particle:IsA("Frame") then
                local randomX = math.random(-50, self.guiWidth + 50)
                local randomY = math.random(-50, self.guiHeight + 50)
                local randomTime = math.random(5, 15)
                
                local tween = TweenService:Create(
                    particle,
                    TweenInfo.new(randomTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true),
                    {Position = UDim2.new(0, randomX, 0, randomY)}
                )
                tween:Play()
            end
        end
    end

    -- Animação de pulso
    if self.Config.EnablePulse and self.pulseRing then
        local pulseTween = TweenService:Create(
            self.pulseRing,
            TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true),
            {Size = UDim2.new(0, 160, 0, 160), BackgroundTransparency = 1}
        )
        pulseTween:Play()
    end

    -- Animação de brilho na borda
    local glowTween = TweenService:Create(
        self.mainFrame.UIStroke,
        TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true),
        {Transparency = 0.1}
    )
    glowTween:Play()
end

-- Configurar eventos da GUI
function BeautifulGUI:SetupGUIEvents()
    -- Botão fechar
    self.closeButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)

    -- Botão minimizar
    self.minimizeButton.MouseButton1Click:Connect(function()
        self:Minimize()
    end)

    -- Botão expandir (na frame minimizada)
    self.minimizedToggleButton.MouseButton1Click:Connect(function()
        self:Maximize()
    end)

    -- Atualizar canvas size
    self.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.layout.AbsoluteContentSize.Y)
    end)

    -- Sistema de drag para a GUI principal
    local mainDragging = false
    local mainDragStart, mainStartPos

    self.header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            mainDragging = true
            mainDragStart = input.Position
            mainStartPos = self.mainFrame.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            mainDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if mainDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                           input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mainDragStart
            self.mainFrame.Position = UDim2.new(
                mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X,
                mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Sistema de drag para a frame minimizada
    local minimizedDragging = false
    local minimizedDragStart, minimizedStartPos

    self.minimizedFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            minimizedDragging = true
            minimizedDragStart = input.Position
            minimizedStartPos = self.minimizedFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if minimizedDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                               input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - minimizedDragStart
            self.minimizedFrame.Position = UDim2.new(
                minimizedStartPos.X.Scale, minimizedStartPos.X.Offset + delta.X,
                minimizedStartPos.Y.Scale, minimizedStartPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Efeitos hover para botões (apenas no PC)
    if not self:IsMobile() then
        -- Botão minimizar
        self.minimizeButton.MouseEnter:Connect(function()
            TweenService:Create(self.minimizeButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.MinimizeButtonHover,
                Size = UDim2.new(0, 42, 0, 32)
            }):Play()
        end)

        self.minimizeButton.MouseLeave:Connect(function()
            TweenService:Create(self.minimizeButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.MinimizeButton,
                Size = UDim2.new(0, 40, 0, 30)
            }):Play()
        end)

        -- Botão fechar
        self.closeButton.MouseEnter:Connect(function()
            TweenService:Create(self.closeButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.CloseButtonHover,
                Size = UDim2.new(0, 32, 0, 32)
            }):Play()
        end)

        self.closeButton.MouseLeave:Connect(function()
            TweenService:Create(self.closeButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.CloseButton,
                Size = UDim2.new(0, 30, 0, 30)
            }):Play()
        end)

        -- Botão expandir minimizado
        self.minimizedToggleButton.MouseEnter:Connect(function()
            TweenService:Create(self.minimizedToggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.MinimizeButtonHover,
                Size = UDim2.new(0, 42, 0, 32)
            }):Play()
        end)

        self.minimizedToggleButton.MouseLeave:Connect(function()
            TweenService:Create(self.minimizedToggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.MinimizeButton,
                Size = UDim2.new(0, 40, 0, 30)
            }):Play()
        end)
    end
end

-- =============================================
-- MÉTODOS PRINCIPAIS
-- =============================================

-- Minimizar GUI
function BeautifulGUI:Minimize()
    if self.isMinimized then return end
    
    self.isMinimized = true
    
    -- Salvar posição atual
    self.savedPosition = self.mainFrame.Position
    
    -- Animação de minimização
    local minimizeTween = TweenService:Create(
        self.mainFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}
    )
    
    minimizeTween:Play()
    minimizeTween.Completed:Connect(function()
        self.mainFrame.Visible = false
        self.minimizedFrame.Visible = true
        self.minimizedFrame.Position = self.savedPosition
        
        -- Parar animações da GUI principal
        if self.pulseRing then
            self.pulseRing.Visible = false
        end
    end)
end

-- Maximizar GUI
function BeautifulGUI:Maximize()
    if not self.isMinimized then return end
    
    self.isMinimized = false
    
    -- Salvar posição da frame minimizada
    self.savedPosition = self.minimizedFrame.Position
    
    -- Esconder frame minimizada
    self.minimizedFrame.Visible = false
    
    -- Mostrar e animar frame principal
    self.mainFrame.Visible = true
    self.mainFrame.Size = UDim2.new(0, 0, 0, 0)
    self.mainFrame.BackgroundTransparency = 1
    self.mainFrame.Position = self.savedPosition
    
    local maximizeTween = TweenService:Create(
        self.mainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, self.guiWidth, 0, self.guiHeight), 
            BackgroundTransparency = 0.1
        }
    )
    
    maximizeTween:Play()
    maximizeTween.Completed:Connect(function()
        -- Retomar animações
        if self.pulseRing then
            self.pulseRing.Visible = true
        end
    end)
end

-- Mostrar GUI
function BeautifulGUI:Show()
    if self.isMinimized then
        self:Maximize()
    else
        self.screenGui.Enabled = true
        self.mainFrame.Visible = true
        self.minimizedFrame.Visible = false
        
        if self.blurEffect then
            self.blurEffect.Enabled = true
        end
    end
    self.guiVisible = true
end

-- Esconder GUI
function BeautifulGUI:Hide()
    self.screenGui.Enabled = false
    if self.blurEffect then
        self.blurEffect.Enabled = false
    end
    self.guiVisible = false
end

-- Alternar GUI
function BeautifulGUI:Toggle()
    if self.guiVisible then
        self:Hide()
    else
        self:Show()
    end
end

-- Alternar entre minimizado/maximizado
function BeautifulGUI:ToggleMinimize()
    if self.isMinimized then
        self:Maximize()
    else
        self:Minimize()
    end
end

-- =============================================
-- SISTEMA DE TABS E ELEMENTOS
-- =============================================

-- Criar Tab
function BeautifulGUI:CreateTab(tabName)
    local tab = {
        Name = tabName,
        Container = nil,
        Button = nil
    }
    
    -- Botão da Tab
    local tabHeight = self:IsMobile() and 45 or 35
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1, -10, 0, tabHeight)
    tabButton.Position = UDim2.new(0, 5, 0, 5 + (#self.Tabs * (tabHeight + 5)))
    tabButton.BackgroundColor3 = self.Theme.Tab
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = self.Theme.TextSecondary
    tabButton.TextSize = self:IsMobile() and 16 or 14
    tabButton.Font = Enum.Font.Gotham
    tabButton.Parent = self.tabsContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton
    
    -- Efeito hover para tabs (apenas no PC)
    if not self:IsMobile() then
        tabButton.MouseEnter:Connect(function()
            if tabButton.BackgroundColor3 ~= self.Theme.TabSelected then
                TweenService:Create(tabButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                }):Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if tabButton.BackgroundColor3 ~= self.Theme.TabSelected then
                TweenService:Create(tabButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = self.Theme.Tab
                }):Play()
            end
        end)
    end
    
    -- Container da Tab
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = tabName .. "Container"
    tabContainer.Size = UDim2.new(1, 0, 0, 0)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Visible = false
    tabContainer.Parent = self.scrollingFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, self:IsMobile() and 15 or 10)
    tabLayout.Parent = tabContainer
    
    tab.Container = tabContainer
    tab.Button = tabButton
    
    -- Evento de clique
    tabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tabName)
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Selecionar primeira tab
    if #self.Tabs == 1 then
        self:SwitchTab(tabName)
    end
    
    return tab
end

-- Mudar de Tab
function BeautifulGUI:SwitchTab(tabName)
    for _, tab in pairs(self.Tabs) do
        if tab.Name == tabName then
            tab.Container.Visible = true
            tab.Button.BackgroundColor3 = self.Theme.TabSelected
            tab.Button.TextColor3 = self.Theme.Text
            self.CurrentTab = tab
            
            -- Efeito de transição
            TweenService:Create(tab.Button, TweenInfo.new(0.3), {
                BackgroundColor3 = self.Theme.TabSelected
            }):Play()
        else
            tab.Container.Visible = false
            tab.Button.BackgroundColor3 = self.Theme.Tab
            tab.Button.TextColor3 = self.Theme.TextSecondary
        end
    end
end

-- Criar Section
function BeautifulGUI:CreateSection(sectionName, parentTab)
    local tab = parentTab or self.CurrentTab
    if not tab then return end
    
    local section = Instance.new("Frame")
    section.Name = sectionName .. "Section"
    section.Size = UDim2.new(1, -20, 0, self:IsMobile() and 40 or 30)
    section.BackgroundTransparency = 1
    section.Parent = tab.Container
    
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Name = "Label"
    sectionLabel.Size = UDim2.new(1, 0, 1, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = "▸ " .. sectionName:upper()
    sectionLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    sectionLabel.TextSize = self:IsMobile() and 18 or 16
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = section
    
    -- Sombra no texto da section
    local sectionStroke = Instance.new("UIStroke")
    sectionStroke.Thickness = 1
    sectionStroke.Color = Color3.fromRGB(0, 0, 0)
    sectionStroke.Transparency = 0.3
    sectionStroke.Parent = sectionLabel
    
    return section
end

-- Criar Button
function BeautifulGUI:CreateButton(buttonConfig, parentTab)
    local tab = parentTab or self.CurrentTab
    if not tab then return end
    
    local buttonHeight = self:IsMobile() and 45 or 35
    local button = Instance.new("TextButton")
    button.Name = buttonConfig.Name .. "Button"
    button.Size = UDim2.new(1, -20, 0, buttonHeight)
    button.BackgroundColor3 = self.Theme.Button
    button.BorderSizePixel = 0
    button.Text = buttonConfig.Text or buttonConfig.Name
    button.TextColor3 = self.Theme.Text
    button.TextSize = self:IsMobile() and 16 or 14
    button.Font = Enum.Font.Gotham
    button.Parent = tab.Container
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    -- Sombra no botão
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Thickness = 1
    buttonStroke.Color = Color3.fromRGB(0, 0, 0)
    buttonStroke.Transparency = 0.5
    buttonStroke.Parent = button
    
    -- Efeito hover (apenas no PC)
    if not self:IsMobile() then
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.ButtonHover,
                Size = UDim2.new(1, -18, 0, buttonHeight + 2)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.Button,
                Size = UDim2.new(1, -20, 0, buttonHeight)
            }):Play()
        end)
    end
    
    -- Callback
    if buttonConfig.Callback then
        button.MouseButton1Click:Connect(buttonConfig.Callback)
    end
    
    return button
end

-- Criar Toggle
function BeautifulGUI:CreateToggle(toggleConfig, parentTab)
    local tab = parentTab or self.CurrentTab
    if not tab then return end
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = toggleConfig.Name .. "Toggle"
    toggleFrame.Size = UDim2.new(1, -20, 0, self:IsMobile() and 40 or 30)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = tab.Container
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = toggleConfig.Text or toggleConfig.Name
    toggleLabel.TextColor3 = self.Theme.Text
    toggleLabel.TextSize = self:IsMobile() and 16 or 14
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    -- Calcular valores baseados na plataforma ANTES de usar no UDim2
    local toggleWidth = self:IsMobile() and 60 or 50
    local toggleHeight = self:IsMobile() and 30 or 25
    local toggleYPos = self:IsMobile() and 5 or 2
    local dotSize = self:IsMobile() and 26 or 21

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0, toggleWidth, 0, toggleHeight)
    toggleButton.Position = UDim2.new(1, -toggleWidth, 0, toggleYPos)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleButton
    
    local toggleDot = Instance.new("Frame")
    toggleDot.Name = "Dot"
    toggleDot.Size = UDim2.new(0, dotSize, 0, dotSize)
    toggleDot.Position = UDim2.new(0, 2, 0, 2)
    toggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleDot.BorderSizePixel = 0
    toggleDot.Parent = toggleButton
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = toggleDot
    
    local state = toggleConfig.Default or false
    
    local function updateToggle()
        -- Calcular posição do dot baseado no estado
        local dotPositionX = state and (toggleWidth - dotSize - 2) or 2
        
        if state then
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 180, 100)
            }):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                Position = UDim2.new(0, dotPositionX, 0, 2)
            }):Play()
        else
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            }):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                Position = UDim2.new(0, dotPositionX, 0, 2)
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

-- =============================================
-- UTILITÁRIOS
-- =============================================

-- Destruir GUI
function BeautifulGUI:Destroy()
    for _, connection in pairs(self.Connections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    
    if self.screenGui then
        pcall(function() self.screenGui:Destroy() end)
    end
    
    if self.blurEffect then
        pcall(function() self.blurEffect:Destroy() end)
    end
end

-- Mudar título
function BeautifulGUI:SetTitle(newTitle)
    if self.title then
        self.title.Text = newTitle
    end
    if self.minimizedTitle then
        self.minimizedTitle.Text = newTitle
    end
end

-- =============================================
-- EXPORTAÇÃO
-- =============================================

return BeautifulGUI