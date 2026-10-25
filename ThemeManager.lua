-- PolarFrame ThemeManager (compatible with the Linoria-style Library API)
local HttpService = game:GetService('HttpService')
local ThemeManager = { Library = nil, Folder = 'PolarFrameSettings', DefaultTheme = 'Polar Light' }
ThemeManager.BuiltInThemes = {
    ['Polar Light'] = {1, {FontColor='252D38', MainColor='FFFFFF', AccentColor='EF972E', BackgroundColor='F2F4F7', OutlineColor='D2D8E0'}},
    ['Graphite'] = {2, {FontColor='EFF2F6', MainColor='272C34', AccentColor='EF972E', BackgroundColor='1E2228', OutlineColor='464E5A'}},
    ['Mono'] = {3, {FontColor='252B33', MainColor='FAFAFB', AccentColor='788493', BackgroundColor='EBEDF0', OutlineColor='C7CCD3'}},
}
function ThemeManager:SetLibrary(lib) self.Library = lib end
function ThemeManager:SetFolder(folder) self.Folder = folder or self.Folder end
function ThemeManager:BuildFolderTree() return true end -- Standard Roblox clients cannot write local files.
function ThemeManager:GetCustomTheme(name) return self.CustomThemes and self.CustomThemes[name] end
function ThemeManager:ReloadCustomThemes()
    local names = {}
    for name in pairs(self.CustomThemes or {}) do table.insert(names, name) end
    table.sort(names)
    return names
end
function ThemeManager:ThemeUpdate()
    if not self.Library then return end
    self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor)
    self.Library:UpdateColorsUsingRegistry()
end
function ThemeManager:ApplyTheme(name)
    if not self.Library then return false end
    local custom = self:GetCustomTheme(name)
    local entry = self.BuiltInThemes[name]
    local data = custom or (entry and entry[2])
    if not data then return false end
    for key, hex in pairs(data) do
        local ok, color = pcall(Color3.fromHex, hex)
        if ok then self.Library[key] = color end
        local option = self.Library.Options and self.Library.Options[key]
        if option and option.SetValueRGB then option:SetValueRGB(color) end
    end
    self.CurrentTheme = name
    self:ThemeUpdate()
    return true
end
function ThemeManager:SaveDefault(name) self.DefaultTheme = name end
function ThemeManager:LoadDefault() return self:ApplyTheme(self.DefaultTheme) end
function ThemeManager:SaveCustomTheme(name)
    if not name or name:gsub('%s','') == '' then return false end
    local lib = assert(self.Library, 'Call SetLibrary first')
    local data = {}
    for _, key in ipairs({'FontColor','MainColor','AccentColor','BackgroundColor','OutlineColor'}) do data[key] = lib[key]:ToHex() end
    self.CustomThemes = self.CustomThemes or {}; self.CustomThemes[name] = data
    return true
end
function ThemeManager:CreateThemeManager(groupbox)
    local lib = assert(self.Library, 'Must set ThemeManager.Library first!')
    for _, key in ipairs({'BackgroundColor','MainColor','AccentColor','OutlineColor','FontColor'}) do
        groupbox:AddLabel(key):AddColorPicker(key, {Default=lib[key]})
    end
    local names = {}; for name in pairs(self.BuiltInThemes) do table.insert(names, name) end; table.sort(names)
    groupbox:AddDivider()
    groupbox:AddDropdown('ThemeManager_ThemeList', {Text='Theme', Values=names, Default=self.CurrentTheme or 'Polar Light'})
    local list = lib.Options.ThemeManager_ThemeList
    if list and list.OnChanged then list:OnChanged(function() self:ApplyTheme(list.Value) end) end
    groupbox:AddInput('ThemeManager_CustomThemeName', {Text='Custom theme name'})
    groupbox:AddButton('Save custom theme', function()
        local input = lib.Options.ThemeManager_CustomThemeName
        local ok = self:SaveCustomTheme(input and input.Value)
        lib:Notify(ok and 'Theme saved in this session' or 'Enter a theme name')
    end)
    groupbox:AddDropdown('ThemeManager_CustomThemeList', {Text='Saved themes', Values=self:ReloadCustomThemes(), AllowNull=true})
    groupbox:AddButton('Load custom theme', function()
        local opt = lib.Options.ThemeManager_CustomThemeList
        if opt and opt.Value then self:ApplyTheme(opt.Value) end
    end)
end
function ThemeManager:CreateGroupBox(tab) return tab:AddLeftGroupbox('Themes') end
function ThemeManager:ApplyToTab(tab) self:CreateThemeManager(self:CreateGroupBox(tab)) end
function ThemeManager:ApplyToGroupbox(groupbox) self:CreateThemeManager(groupbox) end
return ThemeManager
