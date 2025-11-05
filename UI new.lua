-- BeautifulGUI Library
-- Versão: 2.0 - Compatível com PC e Mobile
-- Features: Botão de minimizar, Tabs, Buttons, Efeitos visuais, Minimizador com botão mobile

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
    EnableBlur = false
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
        MinimizeButtonHover = Color3.fromRGB(255, 200, 80),
        MobileButton = Color3.fromRGB(60, 100, 255),
        MobileButtonHover = Color3.fromRGB(80, 120, 255)
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
    self.minimizerEnabled = false
    self.mobileButton = nil
    
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
    print("📌 Use o botão '-' para minimizar/expandir")
end

-- =============================================
-- SISTEMA DE MINIMIZADOR
-- =============================================

function BeautifulGUI:NewMinimizer(config)
    local minimizer = {
        KeyCode = config.KeyCode or Enum.KeyCode.LeftControl,
        Enabled = true
    }
    
    self.minimizerEnabled = true
    self.minimizerKey = minimizer.KeyCode
    
    -- Configurar atalho de teclado (apenas no PC)
    if not self:IsMobile() then
        self.Connections.keyboard = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == self.minimizerKey then
                self:ToggleMinimize()
            end
        end)
    end
    
    return {
        CreateMobileMinimizer = function(mobileConfig)
            return self:CreateMobileMinimizer(mobileConfig)
        end
    }
end

function BeautifulGUI:CreateMobileMinimizer(config)
    if not self:IsMobile() then return end
    
    -- Criar botão mobile flutuante
    self.mobileButton = Instance.new("ImageButton")
    self.mobileButton.Name = "MobileMinimizer"
    self.mobileButton.Size = UDim2.new(0, 60, 0, 60)
    self.mobileButton.Position = UDim2.new(1, -80, 1, -80)
    self.mobileButton.BackgroundColor3 = config.BackgroundColor3 or self.Theme.MobileButton
    self.mobileButton.BackgroundTransparency = 0.1
    self.mobileButton.Image = config.Image or "rbxassetid://10734951901"
    self.mobileButton.ScaleType = Enum.ScaleType.Fit
    self.mobileButton.Parent = self.screenGui
    
    -- Cantos arredondados
    local mobileCorner = Instance.new("UICorner")
    mobileCorner.CornerRadius = UDim.new(1, 0)
    mobileCorner.Parent = self.mobileButton
    
    -- Borda
    local mobileStroke = Instance.new("UIStroke")
    mobileStroke.Thickness = 2
    mobileStroke.Color = Color3.fromRGB(100, 100, 255)
    mobileStroke.Parent = self.mobileButton
    
    -- Sistema de arraste para mobile
    local dragging = false
    local dragOffset = Vector2.new(0, 0)
    local touchInput = nil
    
    -- Função quando começa a arrastar
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            touchInput = input
            
            local touchPos = input.Position
            local buttonPos = self.mobileButton.AbsolutePosition
            dragOffset = Vector2.new(buttonPos.X - touchPos.X, buttonPos.Y - touchPos.Y)
            
            -- Efeito visual durante o arraste
            TweenService:Create(self.mobileButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.MobileButtonHover,
                Size = UDim2.new(0, 65, 0, 65)
            }):Play()
        end
    end
    
    -- Função quando solta
    self.mobileButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and input == touchInput then
            if dragging then
                dragging = false
                touchInput = nil
                
                -- Voltar ao normal
                TweenService:Create(self.mobileButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = self.Theme.MobileButton,
                    Size = UDim2.new(0, 60, 0, 60)
                }):Play()
            end
        end
    end)
    
    -- Atualizar posição durante o arraste
    self.Connections.mobileDrag = RunService.Heartbeat:Connect(function()
        if dragging and touchInput then
            local touchPos = touchInput.Position
            local viewportSize = game:GetService("Workspace").CurrentCamera.ViewportSize
            
            -- Calcular nova posição
            local newX = touchPos.X + dragOffset.X
            local newY = touchPos.Y + dragOffset.Y
            
            -- Limitar dentro da tela
            local buttonSize = self.mobileButton.AbsoluteSize
            newX = math.clamp(newX, 10, viewportSize.X - buttonSize.X - 10)
            newY = math.clamp(newY, 10, viewportSize.Y - buttonSize.Y - 10)
            
            -- Aplicar nova posição
            self.mobileButton.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
    
    -- Evento de clique para minimizar/expandir
    self.mobileButton.MouseButton1Click:Connect(function()
        if not dragging then
            self:ToggleMinimize()
        end
    end)
    
    -- Conectar eventos de input
    self.mobileButton.InputBegan:Connect(startDrag)
    
    return self.mobileButton
end

-- =============================================
-- GUI PRINCIPAL
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

    -- Ajustar tamanho baseado na plataforma (MAIOR para mobile)
    self.guiWidth = self:IsMobile() and 450 or 500
    self.guiHeight = self:IsMobile() and 600 or 400

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

    -- Efeito de sombra
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://2615687895"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(20, 20, 280, 280)
    shadow.Parent = self.mainFrame

    -- Cantos arredondados
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = self.mainFrame

    -- Borda luminosa
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Thickness = 2
    mainStroke.Color = Color3.fromRGB(100, 100, 255)
    mainStroke.Transparency = 0.3
    mainStroke.Parent = self.mainFrame

    -- Header
    self.headerHeight = self:IsMobile() and 60 or 50
    self.header = Instance.new("Frame")
    self.header.Name = "Header"
    self.header.Size = UDim2.new(1, 0, 0, self.headerHeight)
    self.header.Position = UDim2.new(0, 0, 0, 0)
    self.header.BackgroundColor3 = self.Theme.Header
    self.header.BackgroundTransparency = 0.1
    self.header.BorderSizePixel = 0
    self.header.Parent = self.mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = self.header

    -- Título
    self.title = Instance.new("TextLabel")
    self.title.Name = "Title"
    self.title.Size = UDim2.new(0.6, 0, 1, 0)
    self.title.Position = UDim2.new(0, 20, 0, 0)
    self.title.BackgroundTransparency = 1
    self.title.Text = self.Config.Name
    self.title.TextColor3 = self.Theme.Text
    self.title.TextSize = self:IsMobile() and 22 or 18
    self.title.Font = Enum.Font.GothamBold
    self.title.TextXAlignment = Enum.TextXAlignment.Left
    self.title.Parent = self.header

    -- Botão minimizar (adaptado para mobile)
    local minimizeButtonSize = self:IsMobile() and 45 or 35
    self.minimizeButton = Instance.new("TextButton")
    self.minimizeButton.Name = "MinimizeButton"
    self.minimizeButton.Size = UDim2.new(0, minimizeButtonSize, 0, minimizeButtonSize)
    self.minimizeButton.Position = UDim2.new(1, -95, 0, (self.headerHeight - minimizeButtonSize) / 2)
    self.minimizeButton.BackgroundColor3 = self.Theme.MinimizeButton
    self.minimizeButton.BorderSizePixel = 0
    self.minimizeButton.Text = "-"
    self.minimizeButton.TextColor3 = self.Theme.Text
    self.minimizeButton.TextSize = self:IsMobile() and 20 or 16
    self.minimizeButton.Font = Enum.Font.GothamBold
    self.minimizeButton.Parent = self.header

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 8)
    minimizeCorner.Parent = self.minimizeButton

    -- Botão fechar (adaptado para mobile)
    local closeButtonSize = self:IsMobile() and 45 or 35
    self.closeButton = Instance.new("TextButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0, closeButtonSize, 0, closeButtonSize)
    self.closeButton.Position = UDim2.new(1, -45, 0, (self.headerHeight - closeButtonSize) / 2)
    self.closeButton.BackgroundColor3 = self.Theme.CloseButton
    self.closeButton.BorderSizePixel = 0
    self.closeButton.Text = "X"
    self.closeButton.TextColor3 = self.Theme.Text
    self.closeButton.TextSize = self:IsMobile() and 18 or 14
    self.closeButton.Font = Enum.Font.GothamBold
    self.closeButton.Parent = self.header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = self.closeButton

    -- Container de Tabs (maior no mobile)
    self.tabsWidth = self:IsMobile() and 130 or 120
    self.tabsContainer = Instance.new("Frame")
    self.tabsContainer.Name = "TabsContainer"
    self.tabsContainer.Size = UDim2.new(0, self.tabsWidth, 1, -self.headerHeight)
    self.tabsContainer.Position = UDim2.new(0, 0, 0, self.headerHeight)
    self.tabsContainer.BackgroundColor3 = self.Theme.Tab
    self.tabsContainer.BorderSizePixel = 0
    self.tabsContainer.Parent = self.mainFrame

    -- Container de Conteúdo
    self.contentContainer = Instance.new("Frame")
    self.contentContainer.Name = "ContentContainer"
    self.contentContainer.Size = UDim2.new(1, -self.tabsWidth, 1, -self.headerHeight)
    self.contentContainer.Position = UDim2.new(0, self.tabsWidth, 0, self.headerHeight)
    self.contentContainer.BackgroundTransparency = 1
    self.contentContainer.Parent = self.mainFrame

    -- ScrollingFrame para conteúdo
    self.scrollingFrame = Instance.new("ScrollingFrame")
    self.scrollingFrame.Name = "ScrollingFrame"
    self.scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    self.scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
    self.scrollingFrame.BackgroundTransparency = 1
    self.scrollingFrame.BorderSizePixel = 0
    self.scrollingFrame.ScrollBarThickness = self:IsMobile() and 10 or 4
    self.scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.scrollingFrame.Parent = self.contentContainer

    self.layout = Instance.new("UIListLayout")
    self.layout.Padding = UDim.new(0, self:IsMobile() and 15 or 10)
    self.layout.Parent = self.scrollingFrame

    -- Frame minimizada (adaptada para mobile)
    local minimizedWidth = self:IsMobile() and 250 or 200
    self.minimizedFrame = Instance.new("Frame")
    self.minimizedFrame.Name = "MinimizedFrame"
    self.minimizedFrame.Size = UDim2.new(0, minimizedWidth, 0, self.headerHeight)
    self.minimizedFrame.Position = self.Config.Position
    self.minimizedFrame.BackgroundColor3 = self.Theme.Header
    self.minimizedFrame.BackgroundTransparency = 0.1
    self.minimizedFrame.BorderSizePixel = 0
    self.minimizedFrame.Visible = false
    self.minimizedFrame.Parent = self.screenGui

    -- Sombra da frame minimizada
    local minimizedShadow = Instance.new("ImageLabel")
    minimizedShadow.Name = "MinimizedShadow"
    minimizedShadow.Size = UDim2.new(1, 20, 1, 20)
    minimizedShadow.Position = UDim2.new(0, -10, 0, -10)
    minimizedShadow.BackgroundTransparency = 1
    minimizedShadow.Image = "rbxassetid://2615687895"
    minimizedShadow.ImageColor3 = Color3.new(0, 0, 0)
    minimizedShadow.ImageTransparency = 0.8
    minimizedShadow.ScaleType = Enum.ScaleType.Slice
    minimizedShadow.SliceCenter = Rect.new(20, 20, 280, 280)
    minimizedShadow.Parent = self.minimizedFrame

    local minimizedCorner = Instance.new("UICorner")
    minimizedCorner.CornerRadius = UDim.new(0, 15)
    minimizedCorner.Parent = self.minimizedFrame

    local minimizedStroke = Instance.new("UIStroke")
    minimizedStroke.Thickness = 2
    minimizedStroke.Color = Color3.fromRGB(100, 100, 255)
    minimizedStroke.Transparency = 0.3
    minimizedStroke.Parent = self.minimizedFrame

    self.minimizedTitle = Instance.new("TextLabel")
    self.minimizedTitle.Name = "MinimizedTitle"
    self.minimizedTitle.Size = UDim2.new(0.6, 0, 1, 0)
    self.minimizedTitle.Position = UDim2.new(0, 15, 0, 0)
    self.minimizedTitle.BackgroundTransparency = 1
    self.minimizedTitle.Text = self.Config.Name
    self.minimizedTitle.TextColor3 = self.Theme.Text
    self.minimizedTitle.TextSize = self:IsMobile() and 18 or 14
    self.minimizedTitle.Font = Enum.Font.GothamBold
    self.minimizedTitle.TextXAlignment = Enum.TextXAlignment.Left
    self.minimizedTitle.Parent = self.minimizedFrame

    local minimizedToggleSize = self:IsMobile() and 45 or 35
    self.minimizedToggleButton = Instance.new("TextButton")
    self.minimizedToggleButton.Name = "MinimizedToggleButton"
    self.minimizedToggleButton.Size = UDim2.new(0, minimizedToggleSize, 0, minimizedToggleSize)
    self.minimizedToggleButton.Position = UDim2.new(1, -50, 0, (self.headerHeight - minimizedToggleSize) / 2)
    self.minimizedToggleButton.BackgroundColor3 = self.Theme.MinimizeButton
    self.minimizedToggleButton.BorderSizePixel = 0
    self.minimizedToggleButton.Text = "+"
    self.minimizedToggleButton.TextColor3 = self.Theme.Text
    self.minimizedToggleButton.TextSize = self:IsMobile() and 20 or 16
    self.minimizedToggleButton.Font = Enum.Font.GothamBold
    self.minimizedToggleButton.Parent = self.minimizedFrame

    local minimizedToggleCorner = Instance.new("UICorner")
    minimizedToggleCorner.CornerRadius = UDim.new(0, 8)
    minimizedToggleCorner.Parent = self.minimizedToggleButton

    -- Configurar eventos
    self:SetupGUIEvents()
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

    local function startMainDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            mainDragging = true
            mainDragStart = input.Position
            mainStartPos = self.mainFrame.Position
            
            -- Efeito durante o arraste
            TweenService:Create(self.mainFrame, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.2,
                Size = UDim2.new(0, self.guiWidth + 5, 0, self.guiHeight + 5)
            }):Play()
        end
    end

    local function endMainDrag()
        if mainDragging then
            mainDragging = false
            TweenService:Create(self.mainFrame, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1,
                Size = UDim2.new(0, self.guiWidth, 0, self.guiHeight)
            }):Play()
        end
    end

    self.header.InputBegan:Connect(startMainDrag)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            endMainDrag()
        end
    end)

    -- Atualizar posição durante o arraste
    self.Connections.dragHeartbeat = RunService.Heartbeat:Connect(function()
        if mainDragging then
            local mousePos = UserInputService:GetMouseLocation()
            local delta = mousePos - mainDragStart
            local newX = mainStartPos.X.Offset + delta.X
            local newY = mainStartPos.Y.Offset + delta.Y
            
            -- Limitar dentro da tela
            local viewportSize = game:GetService("Workspace").CurrentCamera.ViewportSize
            newX = math.clamp(newX, 0, viewportSize.X - self.guiWidth)
            newY = math.clamp(newY, 0, viewportSize.Y - self.guiHeight)
            
            self.mainFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    -- Sistema de drag para a frame minimizada
    local minimizedDragging = false
    local minimizedDragStart, minimizedStartPos

    local function startMinimizedDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            minimizedDragging = true
            minimizedDragStart = input.Position
            minimizedStartPos = self.minimizedFrame.Position
            
            -- Efeito durante o arraste
            TweenService:Create(self.minimizedFrame, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.2
            }):Play()
        end
    end

    local function endMinimizedDrag()
        if minimizedDragging then
            minimizedDragging = false
            TweenService:Create(self.minimizedFrame, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1
            }):Play()
        end
    end

    self.minimizedFrame.InputBegan:Connect(startMinimizedDrag)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            endMinimizedDrag()
        end
    end)

    -- Atualizar posição da frame minimizada durante o arraste
    self.Connections.minimizedDragHeartbeat = RunService.Heartbeat:Connect(function()
        if minimizedDragging then
            local mousePos = UserInputService:GetMouseLocation()
            local delta = mousePos - minimizedDragStart
            local newX = minimizedStartPos.X.Offset + delta.X
            local newY = minimizedStartPos.Y.Offset + delta.Y
            
            -- Limitar dentro da tela
            local viewportSize = game:GetService("Workspace").CurrentCamera.ViewportSize
            local minimizedWidth = self.minimizedFrame.AbsoluteSize.X
            newX = math.clamp(newX, 0, viewportSize.X - minimizedWidth)
            newY = math.clamp(newY, 0, viewportSize.Y - self.headerHeight)
            
            self.minimizedFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    -- Efeitos hover para botões (apenas no PC)
    if not self:IsMobile() then
        -- Botão minimizar
        self.minimizeButton.MouseEnter:Connect(function()
            TweenService:Create(self.minimizeButton, TweenInfo.new(0.3), {
                BackgroundColor3 = self.Theme.MinimizeButtonHover,
                Size = UDim2.new(0, 40, 0, 40)
            }):Play()
        end)

        self.minimizeButton.MouseLeave:Connect(function()
            TweenService:Create(self.minimizeButton, TweenInfo.new(0.3), {
                BackgroundColor3 = self.Theme.MinimizeButton,
                Size = UDim2.new(0, 35, 0, 35)
            }):Play()
        end)

        -- Botão fechar
        self.closeButton.MouseEnter:Connect(function()
            TweenService:Create(self.closeButton, TweenInfo.new(0.3), {
                BackgroundColor3 = self.Theme.CloseButtonHover,
                Size = UDim2.new(0, 40, 0, 40)
            }):Play()
        end)

        self.closeButton.MouseLeave:Connect(function()
            TweenService:Create(self.closeButton, TweenInfo.new(0.3), {
                BackgroundColor3 = self.Theme.CloseButton,
                Size = UDim2.new(0, 35, 0, 35)
            }):Play()
        end)

        -- Botão expandir minimizado
        self.minimizedToggleButton.MouseEnter:Connect(function()
            TweenService:Create(self.minimizedToggleButton, TweenInfo.new(0.3), {
                BackgroundColor3 = self.Theme.MinimizeButtonHover,
                Size = UDim2.new(0, 40, 0, 40)
            }):Play()
        end)

        self.minimizedToggleButton.MouseLeave:Connect(function()
            TweenService:Create(self.minimizedToggleButton, TweenInfo.new(0.3), {
                BackgroundColor3 = self.Theme.MinimizeButton,
                Size = UDim2.new(0, 35, 0, 35)
            }):Play()
        end)
    else
        -- Efeitos para mobile (toque)
        local function buttonTouchEffect(button)
            button.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    TweenService:Create(button, TweenInfo.new(0.1), {
                        BackgroundTransparency = 0.3
                    }):Play()
                end
            end)

            button.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    TweenService:Create(button, TweenInfo.new(0.1), {
                        BackgroundTransparency = 0
                    }):Play()
                end
            end)
        end

        buttonTouchEffect(self.minimizeButton)
        buttonTouchEffect(self.closeButton)
        buttonTouchEffect(self.minimizedToggleButton)
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
    
    -- Animação de minimização com efeitos
    local minimizeTween = TweenService:Create(
        self.mainFrame,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {
            Size = UDim2.new(0, 0, 0, 0), 
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }
    )
    
    minimizeTween:Play()
    minimizeTween.Completed:Connect(function()
        self.mainFrame.Visible = false
        self.minimizedFrame.Visible = true
        self.minimizedFrame.Position = self.savedPosition
        
        -- Efeito de entrada da frame minimizada
        self.minimizedFrame.Size = UDim2.new(0, 0, 0, self.headerHeight)
        self.minimizedFrame.BackgroundTransparency = 1
        
        local minimizedEntrance = TweenService:Create(
            self.minimizedFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, self:IsMobile() and 250 or 200, 0, self.headerHeight),
                BackgroundTransparency = 0.1
            }
        )
        minimizedEntrance:Play()
    end)
end

-- Maximizar GUI
function BeautifulGUI:Maximize()
    if not self.isMinimized then return end
    
    self.isMinimized = false
    
    -- Salvar posição da frame minimizada
    self.savedPosition = self.minimizedFrame.Position
    
    -- Animação de saída da frame minimizada
    local minimizedExit = TweenService:Create(
        self.minimizedFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {
            Size = UDim2.new(0, 0, 0, self.headerHeight),
            BackgroundTransparency = 1
        }
    )
    
    minimizedExit:Play()
    minimizedExit.Completed:Connect(function()
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
        
        -- Efeito de entrada
        self.mainFrame.Size = UDim2.new(0, 0, 0, 0)
        self.mainFrame.BackgroundTransparency = 1
        
        local entranceTween = TweenService:Create(
            self.mainFrame,
            TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, self.guiWidth, 0, self.guiHeight),
                BackgroundTransparency = 0.1
            }
        )
        entranceTween:Play()
        
        if self.blurEffect then
            self.blurEffect.Enabled = true
        end
    end
    self.guiVisible = true
end

-- Esconder GUI
function BeautifulGUI:Hide()
    local exitTween = TweenService:Create(
        self.mainFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }
    )
    
    exitTween:Play()
    exitTween.Completed:Connect(function()
        self.screenGui.Enabled = false
        if self.blurEffect then
            self.blurEffect.Enabled = false
        end
    end)
    
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
    local tabHeight = self:IsMobile() and 50 or 35
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1, -10, 0, tabHeight)
    tabButton.Position = UDim2.new(0, 5, 0, 5 + (#self.Tabs * (tabHeight + 5)))
    tabButton.BackgroundColor3 = self.Theme.Tab
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = self.Theme.TextSecondary
    tabButton.TextSize = self:IsMobile() and 18 or 14
    tabButton.Font = Enum.Font.Gotham
    tabButton.Parent = self.tabsContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabButton
    
    -- Efeitos hover para tabs (apenas no PC)
    if not self:IsMobile() then
        tabButton.MouseEnter:Connect(function()
            if tab ~= self.CurrentTab then
                TweenService:Create(tabButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(50, 50, 65)
                }):Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if tab ~= self.CurrentTab then
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
            TweenService:Create(tab.Button, TweenInfo.new(0.3), {
                BackgroundColor3 = self.Theme.TabSelected,
                TextColor3 = self.Theme.Text
            }):Play()
            self.CurrentTab = tab
        else
            tab.Container.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.3), {
                BackgroundColor3 = self.Theme.Tab,
                TextColor3 = self.Theme.TextSecondary
            }):Play()
        end
    end
end

-- Criar Section
function BeautifulGUI:CreateSection(sectionName, parentTab)
    local tab = parentTab or self.CurrentTab
    if not tab then return end
    
    local section = Instance.new("Frame")
    section.Name = sectionName .. "Section"
    section.Size = UDim2.new(1, -20, 0, self:IsMobile() and 45 or 35)
    section.BackgroundTransparency = 1
    section.Parent = tab.Container
    
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Name = "Label"
    sectionLabel.Size = UDim2.new(1, 0, 1, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = "│ " .. sectionName:upper()
    sectionLabel.TextColor3 = self.Theme.Text
    sectionLabel.TextSize = self:IsMobile() and 20 or 16
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = section
    
    return section
end

-- Criar Button
function BeautifulGUI:CreateButton(buttonConfig, parentTab)
    local tab = parentTab or self.CurrentTab
    if not tab then return end
    
    local buttonHeight = self:IsMobile() and 50 or 35
    local button = Instance.new("TextButton")
    button.Name = buttonConfig.Name .. "Button"
    button.Size = UDim2.new(1, -20, 0, buttonHeight)
    button.BackgroundColor3 = self.Theme.Button
    button.BorderSizePixel = 0
    button.Text = buttonConfig.Text or buttonConfig.Name
    button.TextColor3 = self.Theme.Text
    button.TextSize = self:IsMobile() and 18 or 14
    button.Font = Enum.Font.Gotham
    button.Parent = tab.Container
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = button
    
    -- Efeito hover (apenas no PC)
    if not self:IsMobile() then
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.ButtonHover,
                Size = UDim2.new(1, -15, 0, buttonHeight + 5)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.Button,
                Size = UDim2.new(1, -20, 0, buttonHeight)
            }):Play()
        end)
    else
        -- Efeito de toque para mobile
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                TweenService:Create(button, TweenInfo.new(0.1), {
                    BackgroundColor3 = self.Theme.ButtonHover,
                    BackgroundTransparency = 0.2
                }):Play()
            end
        end)
        
        button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                TweenService:Create(button, TweenInfo.new(0.1), {
                    BackgroundColor3 = self.Theme.Button,
                    BackgroundTransparency = 0
                }):Play()
            end
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
    toggleFrame.Size = UDim2.new(1, -20, 0, self:IsMobile() and 45 or 35)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = tab.Container
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = toggleConfig.Text or toggleConfig.Name
    toggleLabel.TextColor3 = self.Theme.Text
    toggleLabel.TextSize = self:IsMobile() and 18 or 14
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    -- Calcular valores baseados na plataforma ANTES de usar no UDim2
    local toggleWidth = self:IsMobile() and 70 or 50
    local toggleHeight = self:IsMobile() and 35 or 25
    local toggleYPos = self:IsMobile() and 5 or 5
    local dotSize = self:IsMobile() and 30 or 21
    
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
            TweenService:Create(toggleButton, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(60, 180, 100)
            }):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.3), {
                Position = UDim2.new(0, dotPositionX, 0, 2)
            }):Play()
        else
            TweenService:Create(toggleButton, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            }):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.3), {
                Position = UDim2.new(0, dotPositionX, 0, 2)
            }):Play()
        end
    end
    
    updateToggle()
    
    -- Efeitos para o toggle
    if not self:IsMobile() then
        toggleButton.MouseEnter:Connect(function()
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                Size = UDim2.new(0, toggleWidth + 5, 0, toggleHeight + 5)
            }):Play()
        end)
        
        toggleButton.MouseLeave:Connect(function()
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                Size = UDim2.new(0, toggleWidth, 0, toggleHeight)
            }):Play()
        end)
    end
    
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
    
    if self.mobileButton then
        pcall(function() self.mobileButton:Destroy() end)
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