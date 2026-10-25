# PolarFrame

Лёгкая Roblox Luau UI-библиотека с чистой серо-белой панелью, янтарным акцентом и геометрическими деталями. Фоновая фотография и зимние элементы не используются.

## Подключение

Поместите `Library.lua`, `ThemeManager.lua` и `SaveManager.lua` в подходящие `ModuleScript` в Roblox Studio. Затем из LocalScript:

```lua
local Library = require(path.to.Library)
local ThemeManager = require(path.to.ThemeManager)
local SaveManager = require(path.to.SaveManager)

local Window = Library:CreateWindow({
    Title = "PolarFrame",
    Subtitle = "CONTROL PANEL / READY",
    Watermark = "POLARFRAME  /  LIVE",
    Width = 620,
    Height = 430,
})

local Home = Window:AddTab("Главная")
local Status = Home:AddSection("Состояние")

local liveLabel = Status:AddLabel("Статус: ожидание")
-- Обновление текста в любое время:
liveLabel:SetText("Статус: активно")
-- Также доступно имя в нижнем регистре:
liveLabel:setText("Статус: готово")

Status:AddButton("Проверить", function()
    liveLabel:SetText("Проверка завершена")
    Library:Notify("Готово")
end)

Status:AddToggle("Enabled", { Text = "Включить функцию", Default = false }, function(value)
    print("Enabled =", value)
end)

Status:AddSlider("Power", { Text = "Мощность", Min = 0, Max = 100, Default = 35 }, function(value)
    print("Power =", value)
end)

Status:AddDropdown("Mode", { Text = "Режим", Values = {"Мягкий", "Обычный", "Высокий"}, Default = "Обычный" }, function(value)
    print("Mode =", value)
end)

Status:AddColorPicker("AccentColor", { Text = "Цвет акцента" }, function(color)
    print("Accent color =", color)
end)

Status:AddKeyPicker("ToggleKey", { Text = "Клавиша действия", Default = Enum.KeyCode.RightShift })

local Settings = Window:AddTab("Настройки")
local Config = Settings:AddSection("Конфигурация")
Config:AddInput("ProfileName", { Text = "Имя профиля", Default = "default" })

ThemeManager:SetLibrary(Library)
ThemeManager:ApplyTheme("Polar Light") -- "Graphite" или "Mono"

SaveManager:SetLibrary(Library)
SaveManager:SetFolder("PolarFrame")
SaveManager:Save("default")
-- SaveManager:Load("default")
```

## Важные отличия

- Реализованы базовые контролы: Label, Button, Toggle, Input, Slider, Dropdown, ColorPicker и KeyPicker. Это самостоятельная реализация и всё ещё не гарантирует полной drop-in совместимости со всеми методами LinoriaLib.
- `SetText` и `setText` доступны у объекта, возвращаемого `AddLabel`.
- Сохранение в памяти работает в обычном Roblox-клиенте. Постоянное сохранение через `writefile`/`readfile` возможно только в средах, которые предоставляют такие функции; стандартный Roblox Studio их не предоставляет.
- Для сохранения данных игроков в опубликованной игре используйте серверную логику и DataStoreService, а не клиентские файлы.
