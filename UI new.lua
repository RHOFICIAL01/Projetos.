-- BeautifulGUI Library
-- Versão: 2.0 - Compatível com PC e Mobile
-- Features: Botão flutuante, Tabs, Buttons, Sistema de arraste multiplataforma

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
    Position = UDim2.new(0, 20, 0.5, -30),
    ButtonSize = 60,
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
        CloseButtonHover = Color3.fromRGB(255, 100, 100)
    }
}

function BeautifulGUI.new(config)
    local self = setmetatable({}, BeautifulGUI)
    
    self.Config = setmetatable(config or {}, {__index = DefaultConfig})
    self.Theme = Themes[self.Config.Theme] or Themes.Dark
    self.Tabs = {}
    self.CurrentTab = nil
    self.Connections = {}
    self.guiVisible = false
    
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
    
    self:CreateFloatButton()
    self:CreateMainGUI()
    
    print("🎮 BeautifulGUI Carregada!")
    print("📟 Plataforma: " .. (self:IsMobile() and "📱 MOBILE" or "🖥️ PC"))
    print("📍 Clique no botão flutuante para abrir/fechar")
    print("🖱️ Segure e arraste para mover o botão")
end

-- =============================================
-- BOTÃO FLUTUANTE (PC E MOBILE)
-- =============================================

function BeautifulGUI:CreateFloatButton()
    -- ScreenGui para o botão flutuante
    self.floatGui = Instance.new("ScreenGui")
    self.floatGui.Name = "FloatButtonGui"
    self.floatGui.Parent = self.playerGui
    self.floatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.floatGui.ResetOnSpawn = false

    -- Botão flutuante
    self.floatButton = Instance.new("ImageButton")
    self.floatButton.Name = "FloatButton"
    self.floatButton.Size = UDim2.new(0, self.Config.ButtonSize, 0, self.Config.ButtonSize)
    self.floatButton.Position = self.Config.Position
    self.floatButton.BackgroundColor3 = self.Theme.Button
    self.floatButton.BackgroundTransparency = 0.1
    self.floatButton.Image = "rbxassetid://10734951901"
    self.floatButton.ScaleType = Enum.ScaleType.Fit
    self.floatButton.Parent = self.floatGui

    -- Cantos arredondados
    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = self.floatButton

    -- Borda
    local floatStroke = Instance.new("UIStroke")
    floatStroke.Thickness = 2
    floatStroke.Color = Color3.fromRGB(100, 100, 255)
    floatStroke.Parent = self.floatButton

    -- Sistema de arraste
    self.dragging = false
    self.dragOffset = Vector2.new(0, 0)
    self.touchInput = nil

    self:SetupDragSystem()
end

-- Sistema de arraste para PC e Mobile
function BeautifulGUI:SetupDragSystem()
    -- Função quando começa a arrastar
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            
            self.dragging = true
            self.touchInput = input
            
            local mousePos
            if input.UserInputType == Enum.UserInputType.Touch then
                mousePos = input.Position
            else
                mousePos = UserInputService:GetMouseLocation()
            end
            
            local buttonPos = self.floatButton.AbsolutePosition
            self.dragOffset = Vector2.new(buttonPos.X - mousePos.X, buttonPos.Y - mousePos.Y)
            
            -- Efeito visual durante o arraste
            TweenService:Create(self.floatButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.ButtonHover,
                Size = UDim2.new(0, self.Config.ButtonSize + 5, 0, self.Config.ButtonSize + 5)
            }):Play()
        end
    end

    -- Função quando solta
    self.Connections.InputEnded = UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 and not self:IsMobile()) or 
           (input.UserInputType == Enum.UserInputType.Touch and input == self.touchInput) then
            
            if self.dragging then
                self.dragging = false
                self.touchInput = nil
                
                -- Voltar ao normal
                TweenService:Create(self.floatButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = self.Theme.Button,
                    Size = UDim2.new(0, self.Config.ButtonSize, 0, self.Config.ButtonSize)
                }):Play()
            end
        end
    end)

    -- Atualizar posição durante o arraste
    self.Connections.Heartbeat = RunService.Heartbeat:Connect(function()
        if self.dragging then
            local mousePos
            if self.touchInput and self.touchInput.UserInputType == Enum.UserInputType.Touch then
                mousePos = self.touchInput.Position
            else
                mousePos = UserInputService:GetMouseLocation()
            end
            
            local viewportSize = game:GetService("Workspace").CurrentCamera.ViewportSize
            
            -- Calcular nova posição
            local newX = mousePos.X + self.dragOffset.X
            local newY = mousePos.Y + self.dragOffset.Y
            
            -- Limitar dentro da tela
            local buttonSize = self.floatButton.AbsoluteSize
            newX = math.clamp(newX, 10, viewportSize.X - buttonSize.X - 10)
            newY = math.clamp(newY, 10, viewportSize.Y - buttonSize.Y - 10)
            
            -- Aplicar nova posição
            self.floatButton.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    -- Conectar eventos de input
    self.floatButton.InputBegan:Connect(startDrag)

    -- Efeitos hover (apenas no PC)
    if not self:IsMobile() then
        self.floatButton.MouseEnter:Connect(function()
            if not self.dragging then
                TweenService:Create(self.floatButton, TweenInfo.new(0.3), {
                    Size = UDim2.new(0, self.Config.ButtonSize + 10, 0, self.Config.ButtonSize + 10),
                    BackgroundColor3 = self.Theme.ButtonHover
                }):Play()
            end
        end)

        self.floatButton.MouseLeave:Connect(function()
            if not self.dragging then
                TweenService:Create(self.floatButton, TweenInfo.new(0.3), {
                    Size = UDim2.new(0, self.Config.ButtonSize, 0, self.Config.ButtonSize),
                    BackgroundColor3 = self.Theme.Button
                }):Play()
            end
        end)
    end

    -- Evento de clique para abrir/fechar
    self.floatButton.MouseButton1Click:Connect(function()
        if not self.dragging then
            self:Toggle()
        end
    end)
end

-- =============================================
-- GUI PRINCIPAL
-- =============================================

function BeautifulGUI:CreateMainGUI()
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "MainGUI"
    self.screenGui.Parent = self.playerGui
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Enabled = false
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
    self.mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.mainFrame.BackgroundColor3 = self.Theme.Background
    self.mainFrame.BackgroundTransparency = 0.1
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.ClipsDescendants = true
    self.mainFrame.Parent = self.screenGui

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
    self.title.Size = UDim2.new(0, 200, 1, 0)
    self.title.Position = UDim2.new(0, 20, 0, 0)
    self.title.BackgroundTransparency = 1
    self.title.Text = self.Config.Name
    self.title.TextColor3 = self.Theme.Text
    self.title.TextSize = self:IsMobile() and 20 or 18
    self.title.Font = Enum.Font.GothamBold
    self.title.TextXAlignment = Enum.TextXAlignment.Left
    self.title.Parent = self.header

    -- Botão fechar
    self.closeButtonSize = self:IsMobile() and 40 or 30
    self.closeButton = Instance.new("TextButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0, self.closeButtonSize, 0, self.closeButtonSize)
    self.closeButton.Position = UDim2.new(1, -self.closeButtonSize - 10, 0, (self.headerHeight - self.closeButtonSize) / 2)
    self.closeButton.BackgroundColor3 = self.Theme.CloseButton
    self.closeButton.BorderSizePixel = 0
    self.closeButton.Text = "X"
    self.closeButton.TextColor3 = self.Theme.Text
    self.closeButton.TextSize = self:IsMobile() and 18 or 16
    self.closeButton.Font = Enum.Font.GothamBold
    self.closeButton.Parent = self.header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = self.closeButton

    -- Container de Tabs
    self.tabsWidth = self:IsMobile() and 140 or 120
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
    self.scrollingFrame.ScrollBarThickness = self:IsMobile() and 6 or 3
    self.scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.scrollingFrame.Parent = self.contentContainer

    self.layout = Instance.new("UIListLayout")
    self.layout.Padding = UDim.new(0, self:IsMobile() and 15 or 10)
    self.layout.Parent = self.scrollingFrame

    -- Configurar eventos
    self:SetupGUIEvents()
end

-- Configurar eventos da GUI
function BeautifulGUI:SetupGUIEvents()
    -- Botão fechar
    self.closeButton.MouseButton1Click:Connect(function()
        self:Hide()
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
end

-- =============================================
-- MÉTODOS PRINCIPAIS
-- =============================================

-- Mostrar GUI
function BeautifulGUI:Show()
    self.screenGui.Enabled = true
    if self.blurEffect then
        self.blurEffect.Enabled = true
    end
    
    -- Animação de entrada
    self.mainFrame.Size = UDim2.new(0, 0, 0, 0)
    self.mainFrame.BackgroundTransparency = 1
    
    local entranceTween = TweenService:Create(
        self.mainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, self.guiWidth, 0, self.guiHeight), BackgroundTransparency = 0.1}
    )
    entranceTween:Play()
    
    self.guiVisible = true
end

-- Esconder GUI
function BeautifulGUI:Hide()
    local exitTween = TweenService:Create(
        self.mainFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}
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
    sectionLabel.Text = "│ " .. sectionName:upper()
    sectionLabel.TextColor3 = self.Theme.Text
    sectionLabel.TextSize = self:IsMobile() and 18 or 16
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = section
    
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
    
    -- Efeito hover (apenas no PC)
    if not self:IsMobile() then
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.ButtonHover
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.Button
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
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0, self:IsMobile() and 60 or 50, 0, self:IsMobile() and 30 or 25)
    toggleButton.Position = UDim2.new(1, -self:IsMobile() and 60 or 50, 0, self:IsMobile() and 5 or 2)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleButton
    
    local toggleDot = Instance.new("Frame")
    toggleDot.Name = "Dot"
    toggleDot.Size = UDim2.new(0, self:IsMobile() and 26 or 21, 0, self:IsMobile() and 26 or 21)
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
                Position = UDim2.new(0, self:IsMobile() and 32 or 27, 0, 2)
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
    
    if self.floatGui then
        pcall(function() self.floatGui:Destroy() end)
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
end

-- Mudar ícone do botão flutuante
function BeautifulGUI:SetFloatButtonIcon(imageId)
    if self.floatButton then
        self.floatButton.Image = "rbxassetid://" .. imageId
    end
end

-- =============================================
-- EXPORTAÇÃO
-- =============================================

return BeautifulGUI