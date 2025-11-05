-- BeautifulGUI Library - Versão Corrigida
-- Correção para: Remote event invocation discarded event

local BeautifulGUI = {}
BeautifulGUI.__index = BeautifulGUI

-- Serviços
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Configuração padrão
local DefaultConfig = {
    Name = "BeautifulGUI",
    Size = UDim2.new(0, 500, 0, 400),
    Theme = "Dark",
    BlurBackground = false -- Desativado para evitar problemas
}

-- Temas
local Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 35),
        Header = Color3.fromRGB(35, 35, 45),
        Tab = Color3.fromRGB(40, 40, 50),
        TabSelected = Color3.fromRGB(60, 100, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        Button = Color3.fromRGB(60, 100, 255),
        ButtonHover = Color3.fromRGB(80, 120, 255),
        ToggleOff = Color3.fromRGB(60, 60, 70),
        ToggleOn = Color3.fromRGB(60, 180, 100)
    }
}

function BeautifulGUI.new(config)
    local self = setmetatable({}, BeautifulGUI)
    
    self.Config = setmetatable(config or {}, {__index = DefaultConfig})
    self.Theme = Themes[self.Config.Theme] or Themes.Dark
    self.Tabs = {}
    self.CurrentTab = nil
    self.Connections = {}
    
    -- Verificar se o player existe
    local success, err = pcall(function()
        self:Initialize()
    end)
    
    if not success then
        warn("Erro ao inicializar GUI:", err)
        return nil
    end
    
    return self
end

-- Inicialização segura
function BeautifulGUI:Initialize()
    local player = Players.LocalPlayer
    if not player then
        error("Player não encontrado")
    end
    
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = self.Config.Name
    self.ScreenGui.Parent = playerGui
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false

    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Começa pequeno
    self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BackgroundTransparency = 1
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = self.ScreenGui

    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.MainFrame

    -- Header
    self.Header = Instance.new("Frame")
    self.Header.Name = "Header"
    self.Header.Size = UDim2.new(1, 0, 0, 40)
    self.Header.Position = UDim2.new(0, 0, 0, 0)
    self.Header.BackgroundColor3 = self.Theme.Header
    self.Header.BorderSizePixel = 0
    self.Header.Parent = self.MainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = self.Header

    -- Título
    self.Title = Instance.new("TextLabel")
    self.Title.Name = "Title"
    self.Title.Size = UDim2.new(0, 200, 1, 0)
    self.Title.Position = UDim2.new(0, 15, 0, 0)
    self.Title.BackgroundTransparency = 1
    self.Title.Text = self.Config.Name
    self.Title.TextColor3 = self.Theme.Text
    self.Title.TextSize = 18
    self.Title.Font = Enum.Font.GothamSemibold
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    self.Title.Parent = self.Header

    -- Botão fechar
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -35, 0, 5)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "X"
    self.CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.CloseButton.TextSize = 14
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.Parent = self.Header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = self.CloseButton

    -- Container de Tabs
    self.TabsContainer = Instance.new("Frame")
    self.TabsContainer.Name = "TabsContainer"
    self.TabsContainer.Size = UDim2.new(0, 120, 1, -40)
    self.TabsContainer.Position = UDim2.new(0, 0, 0, 40)
    self.TabsContainer.BackgroundColor3 = self.Theme.Tab
    self.TabsContainer.BorderSizePixel = 0
    self.TabsContainer.Parent = self.MainFrame

    -- Container de Conteúdo
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -120, 1, -40)
    self.ContentContainer.Position = UDim2.new(0, 120, 0, 40)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.Parent = self.MainFrame

    -- ScrollingFrame para conteúdo
    self.ScrollingFrame = Instance.new("ScrollingFrame")
    self.ScrollingFrame.Name = "ScrollingFrame"
    self.ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    self.ScrollingFrame.Position = UDim2.new(0, 0, 0, 0)
    self.ScrollingFrame.BackgroundTransparency = 1
    self.ScrollingFrame.BorderSizePixel = 0
    self.ScrollingFrame.ScrollBarThickness = 3
    self.ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    self.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ScrollingFrame.Parent = self.ContentContainer

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = self.ScrollingFrame

    -- Atualizar canvas size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)

    -- Conectar eventos
    self:SetupEvents()
    
    -- Animação de entrada
    delay(0.1, function()
        self:AnimateIn()
    end)
end

-- Configurar eventos
function BeautifulGUI:SetupEvents()
    -- Fechar GUI
    self.Connections.Close = self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Drag seguro
    local dragging = false
    local dragInput, dragStart, startPos

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end

    local function onInputChanged(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end

    local function onInputChangedGlobal(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end

    self.Connections.InputBegan = self.Header.InputBegan:Connect(onInputBegan)
    self.Connections.InputChanged = self.Header.InputChanged:Connect(onInputChanged)
    self.Connections.InputChangedGlobal = UserInputService.InputChanged:Connect(onInputChangedGlobal)
end

-- Animação de entrada
function BeautifulGUI:AnimateIn()
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    local sizeTween = TweenService:Create(self.MainFrame, tweenInfo, {
        Size = self.Config.Size
    })
    
    local transparencyTween = TweenService:Create(self.MainFrame, tweenInfo, {
        BackgroundTransparency = 0
    })
    
    sizeTween:Play()
    transparencyTween:Play()
end

-- =============================================
-- MÉTODOS PRINCIPAIS
-- =============================================

function BeautifulGUI:CreateTab(tabName)
    local tab = {
        Name = tabName,
        Container = nil,
        Button = nil
    }
    
    -- Botão da Tab
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1, -10, 0, 35)
    tabButton.Position = UDim2.new(0, 5, 0, 5 + (#self.Tabs * 40))
    tabButton.BackgroundColor3 = self.Theme.Tab
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = self.Theme.TextSecondary
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.Gotham
    tabButton.Parent = self.TabsContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton
    
    -- Container da Tab
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = tabName .. "Container"
    tabContainer.Size = UDim2.new(1, 0, 0, 0)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Visible = false
    tabContainer.Parent = self.ScrollingFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 10)
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

-- =============================================
-- ELEMENTOS DA GUI
-- =============================================

function BeautifulGUI:CreateSection(sectionName, parentTab)
    local tab = parentTab or self.CurrentTab
    if not tab then return end
    
    local section = Instance.new("Frame")
    section.Name = sectionName .. "Section"
    section.Size = UDim2.new(1, -20, 0, 30)
    section.BackgroundTransparency = 1
    section.Parent = tab.Container
    
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Name = "Label"
    sectionLabel.Size = UDim2.new(1, 0, 1, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = "│ " .. sectionName
    sectionLabel.TextColor3 = self.Theme.Text
    sectionLabel.TextSize = 16
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = section
    
    return section
end

function BeautifulGUI:CreateButton(buttonConfig, parentTab)
    local tab = parentTab or self.CurrentTab
    if not tab then return end
    
    local button = Instance.new("TextButton")
    button.Name = buttonConfig.Name .. "Button"
    button.Size = UDim2.new(1, -20, 0, 35)
    button.BackgroundColor3 = self.Theme.Button
    button.BorderSizePixel = 0
    button.Text = buttonConfig.Text or buttonConfig.Name
    button.TextColor3 = self.Theme.Text
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
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
    
    -- Callback seguro
    if buttonConfig.Callback then
        button.MouseButton1Click:Connect(function()
            local success, err = pcall(buttonConfig.Callback)
            if not success then
                warn("Erro no callback do botão " .. buttonConfig.Name .. ":", err)
            end
        end)
    end
    
    return button
end

function BeautifulGUI:CreateToggle(toggleConfig, parentTab)
    local tab = parentTab or self.CurrentTab
    if not tab then return end
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = toggleConfig.Name .. "Toggle"
    toggleFrame.Size = UDim2.new(1, -20, 0, 30)
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
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0, 50, 0, 25)
    toggleButton.Position = UDim2.new(1, -50, 0, 2)
    toggleButton.BackgroundColor3 = self.Theme.ToggleOff
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
                BackgroundColor3 = self.Theme.ToggleOn
            }):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 27, 0, 2)
            }):Play()
        else
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Theme.ToggleOff
            }):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0, 2)
            }):Play()
        end
    end
    
    updateToggle()
    
    -- Evento seguro
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        if toggleConfig.Callback then
            local success, err = pcall(toggleConfig.Callback, state)
            if not success then
                warn("Erro no callback do toggle " .. toggleConfig.Name .. ":", err)
            end
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

function BeautifulGUI:CreateLabel(labelConfig, parentTab)
    local tab = parentTab or self.CurrentTab
    if not tab then return end
    
    local label = Instance.new("TextLabel")
    label.Name = labelConfig.Name .. "Label"
    label.Size = UDim2.new(1, -20, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = labelConfig.Text or labelConfig.Name
    label.TextColor3 = self.Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = tab.Container
    
    return label
end

-- =============================================
-- UTILITÁRIOS
-- =============================================

function BeautifulGUI:Destroy()
    -- Limpar conexões
    for _, connection in pairs(self.Connections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    
    -- Destruir GUI
    if self.ScreenGui then
        pcall(function() self.ScreenGui:Destroy() end)
    end
end

function BeautifulGUI:Toggle()
    if self.ScreenGui then
        self.ScreenGui.Enabled = not self.ScreenGui.Enabled
    end
end

-- Função para carregar seguro
local function safeLoad()
    local success, lib = pcall(function()
        return BeautifulGUI
    end)
    
    if success then
        return lib
    else
        warn("Erro ao carregar BeautifulGUI:", lib)
        return nil
    end
end

return safeLoad()