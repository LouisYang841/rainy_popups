# rainy_popups 雨天弹窗

一个 Windows 桌面整活小脚本：双击运行后，屏幕上会陆续弹出 **300 个**灰白色小窗口，每个窗口里随机显示一句"雨味"emo 文案——

> 原谅我廉价的眼泪
> 泪是无法临摹的雨季
> 如果情绪有天气，那我一直困在阴雨天
> ……

适合放在桌面截图里营造"一整个人emo住了"的氛围，也可以在朋友电脑上表演（后果自负🙂）。

## 使用方法

双击 `rainy_popups.vbs` 即可。无需安装任何依赖，Windows 自带的 VBScript + PowerShell 就能跑。

- **运行**：双击 `.vbs` 文件
- **退出**：按 **Esc**（全局有效），或逐个关闭窗口
- 窗口全部弹完约 18 秒（300 个 × 60ms 间隔）

## 工作原理

`.vbs` 脚本只是一个启动器：它把一段内嵌的 PowerShell WinForms 代码写到 `%TEMP%`，然后以隐藏窗口方式运行。PowerShell 部分负责创建 300 个随机位置、随机大小的窗体，用计时器逐个弹出，并用 `GetAsyncKeyState` 监听全局 Esc 键。脚本退出时会自动删除临时 `.ps1` 文件，不留残余。

## 自定义

想改文案、窗口数量或颜色？用文本编辑器打开 `rainy_popups.vbs`：

| 想改什么 | 找哪里 |
|---|---|
| 文案 | `$phrases = @(...)` 数组，一行一句 |
| 窗口数量 | `$count = 300` |
| 弹出速度 | `$showTimer.Interval = 60`（毫秒） |
| 窗口/文字颜色 | `FromArgb(235,235,235)` / `FromArgb(125,125,125)` 等 |
| 字体字号 | `New-Object System.Drawing.Font('Microsoft YaHei UI', 16, ...)` |

改完保存为 ANSI 或 UTF-16 编码都行（脚本里写临时文件时强制 UTF-16 LE，所以中文文案不会乱码）。

## 注意

- 纯视觉效果，不联网、不写注册表、不驻留后台；退出后临时文件自动清理
- 部分杀毒软件可能对 "VBS 生成并执行 PS1" 的组合敏感，属正常误报
- 需要 .NET Framework 的 WinForms（Windows 10/11 自带）

## License

[MIT](LICENSE)
