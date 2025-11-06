-- BeautifulGUI Library
-- Versão: VIP - Interface Centralizada com Efeitos
local BeautifulGUI = {}
BeautifulGUI.__index = BeautifulGUI

-- Serviços
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Configuração padrão
local DefaultConfig = {
    Name = "SISTEMA VIP",
    Theme = "Dark",
    EnableBlur = false
}

-- Temas VIP
local Themes = {
    Dark = {
        Background = Color3.fromRGB(10, 10, 20),
        Header = Color3.fromRGB(20, 20, 35),
        Tab = Color3.fromRGB(30, 30, 45),
        TabSelected = Color3.fromRGB(0, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 170, 170),
        Button = Color3.fromRGB(0, 100, 255),
        ButtonHover = Color3.fromRGB(0, 120, 255),
        CloseButton = Color3.fromRGB(255, 50, 50),
        CloseButtonHover = Color3.fromRGB(255, 80, 80),
        MinimizeButton = Color3.fromRGB(255, 150, 0),
        MinimizeButtonHover = Color3.fromRGB(255, 180, 0),
        Section = Color3.fromRGB(0, 150, 255)
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
    
    self:Initialize()
    return self
end

-- Inicialização
function BeautifulGUI:Initialize()
    self.player = Players.LocalPlayer
    self.playerGui = self.player:WaitForChild("PlayerGui")
    
    self:CreateMainGUI()
    
    print("🎮 SISTEMA VIP Carregado!")
end

-- =============================================
-- GUI PRINCIPAL (CENTRALIZADA)
-- =============================================

function BeautifulGUI:CreateMainGUI()
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "VIPSystem"
    self.screenGui.Parent = self.playerGui
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Enabled = true
    self.screenGui.ResetOnSpawn = false

    -- TAMANHO DA INTERFACE (600x500)
    self.guiWidth = 600
    self.guiHeight = 500

    -- Frame principal (CENTRALIZADO)
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, self.guiWidth, 0, self.guiHeight)
    self.mainFrame.Position = UDim2.new(0.5, -self.guiWidth/2, 0.5, -self.guiHeight/2) -- Centralizado
    self.mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.mainFrame.BackgroundColor3 = self.Theme.Background
    self.mainFrame.BackgroundTransparency = 0
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.ClipsDescendants = true
    self.mainFrame.Parent = self.screenGui

    -- Efeito de sombra forte (como na foto)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://2615687895"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(20, 20, 280, 280)
    shadow.ZIndex = 0
    shadow.Parent = self.mainFrame

    -- Borda brilhante azul (efeito da foto)
    local glowStroke = Instance.new("UIStroke")
    glowStroke.Thickness = 3
    glowStroke.Color = Color3.fromRGB(0, 150, 255)
    glowStroke.Transparency = 0.1
    glowStroke.Parent = self.mainFrame

    -- Efeito de gradiente interno
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
    })
    gradient.Parent = self.mainFrame

    -- Header com efeito de brilho
    self.headerHeight = 50
    self.header = Instance.new("Frame")
    self.header.Name = "Header"
    self.header.Size = UDim2.new(1, 0, 0, self.headerHeight)
    self.header.Position = UDim2.new(0, 0, 0, 0)
    self.header.BackgroundColor3 = self.Theme.Header
    self.header.BackgroundTransparency = 0
    self.header.BorderSizePixel = 0
    self.header.ZIndex = 3
    self.header.Parent = self.mainFrame

    -- Gradiente do header
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Rotation = 90
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 35))
    })
    headerGradient.Parent = self.header

    -- Borda inferior do header
    local headerStroke = Instance.new("UIStroke")
    headerStroke.Thickness = 2
    headerStroke.Color = Color3.fromRGB(0, 100, 255)
    headerStroke.Transparency = 0.3
    headerStroke.Parent = self.header

    -- Título SISTEMA VIP (estilo da foto)
    self.title = Instance.new("TextLabel")
    self.title.Name = "Title"
    self.title.Size = UDim2.new(0.7, 0, 1, 0)
    self.title.Position = UDim2.new(0, 20, 0, 0)
    self.title.BackgroundTransparency = 1
    self.title.Text = "SISTEMA VIP"
    self.title.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.title.TextSize = 18
    self.title.Font = Enum.Font.GothamBlack
    self.title.TextXAlignment = Enum.TextXAlignment.Left
    self.title.ZIndex = 4
    self.title.Parent = self.header

    -- Efeito de brilho no texto
    local titleStroke = Instance.new("UIStroke")
    titleStroke.Thickness = 1
    titleStroke.Color = Color3.fromRGB(0, 150, 255)
    titleStroke.Transparency = 0.5
    titleStroke.Parent = self.title

    -- Botão minimizar
    self.minimizeButton = Instance.new("TextButton")
    self.minimizeButton.Name = "MinimizeButton"
    self.minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    self.minimizeButton.Position = UDim2.new(1, -70, 0, 10)
    self.minimizeButton.BackgroundColor3 = self.Theme.MinimizeButton
    self.minimizeButton.BorderSizePixel = 0
    self.minimizeButton.Text = "-"
    self.minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.minimizeButton.TextSize = 16
    self.minimizeButton.Font = Enum.Font.GothamBold
    self.minimizeButton.ZIndex = 4
    self.minimizeButton.Parent = self.header

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = self.minimizeButton

    -- Botão fechar
    self.closeButton = Instance.new("TextButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0, 30, 0, 30)
    self.closeButton.Position = UDim2.new(1, -35, 0, 10)
    self.closeButton.BackgroundColor3 = self.Theme.CloseButton
    self.closeButton.BorderSizePixel = 0
    self.closeButton.Text = "X"
    self.closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.closeButton.TextSize = 14
    self.closeButton.Font = Enum.Font.GothamBold
    self.closeButton.ZIndex = 4
    self.closeButton.Parent = self.header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = self.closeButton

    -- Container de Tabs (lateral esquerda)
    self.tabsWidth = 150
    self.tabsContainer = Instance.new("Frame")
    self.tabsContainer.Name = "TabsContainer"
    self.tabsContainer.Size = UDim2.new(0, self.tabsWidth, 1, -self.headerHeight)
    self.tabsContainer.Position = UDim2.new(0, 0, 0, self.headerHeight)
    self.tabsContainer.BackgroundColor3 = self.Theme.Tab
    self.tabsContainer.BorderSizePixel = 0
    self.tabsContainer.ZIndex = 2
    self.tabsContainer.Parent = self.mainFrame

    -- Gradiente das tabs
    local tabsGradient = Instance.new("UIGradient")
    tabsGradient.Rotation = 90
    tabsGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 45))
    })
    tabsGradient.Parent = self.tabsContainer

    -- Borda direita das tabs
    local tabsStroke = Instance.new("UIStroke")
    tabsStroke.Thickness = 2
    tabsStroke.Color = Color3.fromRGB(0, 100, 255)
    tabsStroke.Transparency = 0.3
    tabsStroke.Parent = self.tabsContainer

    -- Container de Conteúdo (área principal)
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
    self.scrollingFrame.ScrollBarThickness = 4
    self.scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 100, 255)
    self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.scrollingFrame.Parent = self.contentContainer

    self.layout = Instance.new("UIListLayout")
    self.layout.Padding = UDim.new(0, 15)
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

    -- Botão minimizar
    self.minimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)

    -- Atualizar canvas size
    self.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.layout.AbsoluteContentSize.Y)
    end)

    -- Sistema de drag para a GUI principal
    local mainDragging = false
    local mainDragStart, mainStartPos

    local function startMainDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            mainDragging = true
            mainDragStart = input.Position
            mainStartPos = self.mainFrame.Position
            
            -- Efeito durante o arraste
            TweenService:Create(self.mainFrame, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1
            }):Play()
        end
    end

    local function endMainDrag()
        if mainDragging then
            mainDragging = false
            TweenService:Create(self.mainFrame, TweenInfo.new(0.2), {
                BackgroundTransparency = 0
            }):Play()
        end
    end

    self.header.InputBegan:Connect(startMainDrag)
    self.header.InputEnded:Connect(endMainDrag)

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

    -- Efeitos hover para botões
    self.minimizeButton.MouseEnter:Connect(function()
        TweenService:Create(self.minimizeButton, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Theme.MinimizeButtonHover,
            Size = UDim2.new(0, 32, 0, 32)
        }):Play()
    end)

    self.minimizeButton.MouseLeave:Connect(function()
        TweenService:Create(self.minimizeButton, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Theme.MinimizeButton,
            Size = UDim2.new(0, 30, 0, 30)
        }):Play()
    end)

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
end

-- =============================================
-- MÉTODOS PRINCIPAIS
-- =============================================

-- Minimizar GUI
function BeautifulGUI:Minimize()
    if self.isMinimized then return end
    
    self.isMinimized = true
    
    -- Animação de minimização
    local minimizeTween = TweenService:Create(
        self.mainFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {
            Size = UDim2.new(0, 0, 0, 0), 
            BackgroundTransparency = 1
        }
    )
    
    minimizeTween:Play()
end

-- Maximizar GUI
function BeautifulGUI:Maximize()
    if not self.isMinimized then return end
    
    self.isMinimized = false
    
    -- Animação de maximização
    local maximizeTween = TweenService:Create(
        self.mainFrame,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, self.guiWidth, 0, self.guiHeight), 
            BackgroundTransparency = 0
        }
    )
    
    maximizeTween:Play()
end

-- Mostrar GUI
function BeautifulGUI:Show()
    self.screenGui.Enabled = true
    self:Maximize()
    self.guiVisible = true
end

-- Esconder GUI
function BeautifulGUI:Hide()
    self.screenGui.Enabled = false
    self.guiVisible = false
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
    local tabHeight = 45
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1, -10, 0, tabHeight)
    tabButton.Position = UDim2.new(0, 5, 0, 5 + (#self.Tabs * (tabHeight + 5)))
    tabButton.BackgroundColor3 = self.Theme.Tab
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = self.Theme.TextSecondary
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.GothamBold
    tabButton.ZIndex = 3
    tabButton.Parent = self.tabsContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton
    
    -- Efeitos hover para tabs
    tabButton.MouseEnter:Connect(function()
        if tab ~= self.CurrentTab then
            TweenService:Create(tabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 65)
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
    
    -- Container da Tab
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = tabName .. "Container"
    tabContainer.Size = UDim2.new(1, 0, 0, 0)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Visible = false
    tabContainer.Parent = self.scrollingFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 15)
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
    section.Size = UDim2.new(1, -30, 0, 35)
    section.BackgroundTransparency = 1
    section.Parent = tab.Container
    
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Name = "Label"
    sectionLabel.Size = UDim2.new(1, 0, 1, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = sectionName
    sectionLabel.TextColor3 = self.Theme.Section
    sectionLabel.TextSize = 16
    sectionLabel.Font = Enum.Font.GothamBlack
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = section
    
    return section
end

-- Criar Button
function BeautifulGUI:CreateButton(buttonConfig, parentTab)
    local tab = parentTab or self.CurrentTab
    if not tab then return end
    
    local buttonHeight = 40
    local button = Instance.new("TextButton")
    button.Name = buttonConfig.Name .. "Button"
    button.Size = UDim2.new(1, -30, 0, buttonHeight)
    button.BackgroundColor3 = self.Theme.Button
    button.BorderSizePixel = 0
    button.Text = buttonConfig.Text or buttonConfig.Name
    button.TextColor3 = self.Theme.Text
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = tab.Container
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    -- Efeito hover
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
    toggleFrame.Size = UDim2.new(1, -30, 0, 40)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = tab.Container
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = toggleConfig.Text or toggleConfig.Name
    toggleLabel.TextColor3 = self.Theme.Text
    toggleLabel.TextSize = 14
    toggleLabel.Font = Enum.Font.GothamBold
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    -- Toggle button
    local toggleWidth = 60
    local toggleHeight = 30
    local dotSize = 22
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0, toggleWidth, 0, toggleHeight)
    toggleButton.Position = UDim2.new(1, -toggleWidth, 0, 5)
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
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
        local dotPositionX = state and (toggleWidth - dotSize - 2) or 2
        
        if state then
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            }):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                Position = UDim2.new(0, dotPositionX, 0, 2)
            }):Play()
        else
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 65)
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
end

-- Mudar título
function BeautifulGUI:SetTitle(newTitle)
    if self.title then
        self.title.Text = newTitle
    end
end

return BeautifulGUI