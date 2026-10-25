-- PolarFrame SaveManager: API-compatible config manager with in-memory storage.
-- Roblox clients cannot write local files. Use a server DataStoreService bridge for persistence in a published game.
local HttpService = game:GetService('HttpService')
local SaveManager = { Library=nil, Folder='PolarFrameSettings', Ignore={}, Memory={} }
function SaveManager:SetLibrary(lib) self.Library=lib end
function SaveManager:SetFolder(folder) self.Folder=folder or self.Folder end
function SaveManager:BuildFolderTree() return true end
function SaveManager:SetIgnoreIndexes(list) for _, key in ipairs(list or {}) do self.Ignore[key]=true end end
function SaveManager:IgnoreThemeSettings()
    self:SetIgnoreIndexes({'BackgroundColor','MainColor','AccentColor','OutlineColor','FontColor','ThemeManager_ThemeList','ThemeManager_CustomThemeList','ThemeManager_CustomThemeName'})
end
local function encodeValue(obj)
    local v=obj.Value
    if typeof(v)=='Color3' then return {__kind='Color3',value=v:ToHex()} end
    if typeof(v)=='EnumItem' then return {__kind='EnumItem',value=v.Name} end
    return v
end
function SaveManager:Save(name)
    if not name or tostring(name):gsub('%s','')=='' then return false,'no config file is selected' end
    local lib=assert(self.Library,'Call SetLibrary first')
    local data={objects={}}
    for idx,obj in pairs(lib.Toggles or {}) do if not self.Ignore[idx] then table.insert(data.objects,{idx=idx,type=obj.Type,value=encodeValue(obj)}) end end
    for idx,obj in pairs(lib.Options or {}) do if not self.Ignore[idx] and obj.Type then table.insert(data.objects,{idx=idx,type=obj.Type,value=encodeValue(obj),transparency=obj.Transparency,mode=obj.Mode,multi=obj.Multi}) end end
    local ok, encoded=pcall(function() return HttpService:JSONEncode(data) end)
    if not ok then return false,'failed to encode data' end
    self.Memory[name]=encoded
    return true
end
function SaveManager:Load(name)
    if not name then return false,'no config file is selected' end
    local encoded=self.Memory[name]
    if not encoded then return false,'config not found in this session' end
    local ok, data=pcall(function() return HttpService:JSONDecode(encoded) end)
    if not ok then return false,'decode error' end
    local lib=assert(self.Library,'Call SetLibrary first')
    for _, item in ipairs(data.objects or {}) do
        local obj=(lib.Toggles or {})[item.idx] or (lib.Options or {})[item.idx]
        if obj and obj.SetValue then
            local v=item.value
            if type(v)=='table' and v.__kind=='Color3' then
                local color=Color3.fromHex(v.value)
                if obj.SetValueRGB then obj:SetValueRGB(color,item.transparency) else obj:SetValue(color) end
            elseif type(v)=='table' and v.__kind=='EnumItem' and Enum.KeyCode[v.value] then
                obj:SetValue({v.value,item.mode})
            elseif obj.Type=='KeyPicker' then
                obj:SetValue({item.key or v,item.mode})
            else obj:SetValue(v) end
        end
    end
    return true
end
function SaveManager:RefreshConfigList()
    local names={}; for name in pairs(self.Memory) do table.insert(names,name) end; table.sort(names); return names
end
function SaveManager:LoadAutoloadConfig()
    if self.Memory.Autoload then return self:Load(self.Memory.Autoload) end
    return false,'no autoload config'
end
function SaveManager:BuildConfigSection(tab)
    local lib=assert(self.Library,'Must set SaveManager.Library')
    local section=tab:AddRightGroupbox('Configuration')
    section:AddInput('SaveManager_ConfigName',{Text='Config name'})
    section:AddDropdown('SaveManager_ConfigList',{Text='Config list',Values=self:RefreshConfigList(),AllowNull=true})
    section:AddDivider()
    section:AddButton('Create config',function()
        local name=lib.Options.SaveManager_ConfigName.Value
        local ok,err=self:Save(name); if not ok then return lib:Notify('Save failed: '..tostring(err)) end
        lib:Notify('Config saved in this session')
        lib.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
    end):AddButton('Load config',function()
        local name=lib.Options.SaveManager_ConfigList.Value
        local ok,err=self:Load(name); if not ok then return lib:Notify('Load failed: '..tostring(err)) end
        lib:Notify('Config loaded')
    end)
    section:AddButton('Overwrite config',function()
        local name=lib.Options.SaveManager_ConfigList.Value
        local ok,err=self:Save(name); if not ok then return lib:Notify('Save failed: '..tostring(err)) end
        lib:Notify('Config updated')
    end)
    section:AddButton('Refresh list',function() lib.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList()) end)
    section:AddButton('Set as autoload',function()
        local name=lib.Options.SaveManager_ConfigList.Value
        if name then self.Memory.Autoload=name; self.AutoloadLabel:SetText('Current autoload config: '..name) end
    end)
    self.AutoloadLabel=section:AddLabel('Current autoload config: '..tostring(self.Memory.Autoload or 'none'))
    self:SetIgnoreIndexes({'SaveManager_ConfigList','SaveManager_ConfigName'})
end
return SaveManager
