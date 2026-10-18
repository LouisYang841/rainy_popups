' ============================================================
'  雨天弹窗 —— 模拟图片中的多窗口视觉效果
'  运行：双击 .vbs 文件
'  退出：按 Esc（全局有效），或逐个关闭窗口
' ============================================================
Option Explicit

Dim fso, shell, tempDir, ps1Path, ps1, ts, execCmd
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
tempDir = shell.ExpandEnvironmentStrings("%TEMP%")
ps1Path = fso.BuildPath(tempDir, "RainyPopups_" & Replace(Replace(CStr(Timer), ".", ""), ",", "") & ".ps1")

ps1 = ""

' 逐行追加；~ 代表双引号（避免 VBS 里的引号转义）
Sub L(s)
    ps1 = ps1 & Replace(s, "~", Chr(34)) & vbCrLf
End Sub

L "$ErrorActionPreference = 'Stop'"
L "Add-Type -AssemblyName System.Windows.Forms"
L "Add-Type -AssemblyName System.Drawing"
L "[System.Windows.Forms.Application]::EnableVisualStyles()"
L "Add-Type -Namespace Win -Name Key -MemberDefinition '[DllImport(~user32.dll~)] public static extern short GetAsyncKeyState(int vKey);'"
L ""
L "$phrases = @("
L "  '原谅我廉价的眼泪',"
L "  '泪是无法临摹的雨季',"
L "  '如果情绪有天气，那我一直困在阴雨天',"
L "  '痛，但我无言',"
L "  '你的誓言回落在冷色调里',"
L "  '永不停息的雨季是我潮湿的眼底回忆',"
L "  '像仿青色的湖',"
L "  '生锈的感情又该如何重置',"
L "  '如同雨落，回忆没有尽头'"
L ")"
L "$rand = New-Object System.Random"
L "$screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea"
L "$forms = New-Object System.Collections.ArrayList"
L "$font = New-Object System.Drawing.Font('Microsoft YaHei UI', 16, [System.Drawing.FontStyle]::Regular)"
L "$count = 300"
L ""
L "for ($i = 0; $i -lt $count; $i++) {"
L "  $form = New-Object System.Windows.Forms.Form"
L "  $form.Text = ''"
L "  $form.Size = New-Object System.Drawing.Size((300 + $rand.Next(150)), (115 + $rand.Next(35)))"
L "  $form.StartPosition = 'Manual'"
L "  $form.FormBorderStyle = 'Sizable'"
L "  $form.MaximizeBox = $false"
L "  $form.MinimizeBox = $true"
L "  $form.BackColor = [System.Drawing.Color]::FromArgb(235,235,235)"
L "  $form.Opacity = 0.90"
L "  $form.ShowInTaskbar = $false"
L "  $maxX = [Math]::Max(0, $screen.Width - $form.Width)"
L "  $maxY = [Math]::Max(0, $screen.Height - $form.Height)"
L "  $form.Location = New-Object System.Drawing.Point(($screen.X + $rand.Next($maxX + 1)), ($screen.Y + $rand.Next($maxY + 1)))"
L "  $label = New-Object System.Windows.Forms.Label"
L "  $label.Dock = 'Fill'"
L "  $label.TextAlign = 'MiddleCenter'"
L "  $label.Text = $phrases[$rand.Next($phrases.Count)]"
L "  $label.Font = $font"
L "  $label.ForeColor = [System.Drawing.Color]::FromArgb(125,125,125)"
L "  $label.BackColor = [System.Drawing.Color]::FromArgb(225,225,225)"
L "  $form.Controls.Add($label)"
L "  [void]$forms.Add($form)"
L "}"
L ""
L "$ctx = New-Object System.Windows.Forms.ApplicationContext"
L "$script:shown = 0"
L ""
L "# 逐个显示窗口"
L "$showTimer = New-Object System.Windows.Forms.Timer"
L "$showTimer.Interval = 60"
L "$showTimer.Add_Tick({"
L "  if ($script:shown -lt $forms.Count) {"
L "    $f = $forms[$script:shown]"
L "    if (-not $f.IsDisposed) { $f.Show(); $f.BringToFront() }"
L "    $script:shown++"
L "  } else {"
L "    $showTimer.Stop()"
L "  }"
L "})"
L ""
L "# 监听 Esc + 检测是否所有窗口都已关闭"
L "$watchTimer = New-Object System.Windows.Forms.Timer"
L "$watchTimer.Interval = 50"
L "$watchTimer.Add_Tick({"
L "  $esc = ([Win.Key]::GetAsyncKeyState(27) -band 0x8000) -ne 0"
L "  $allGone = ($script:shown -ge $forms.Count) -and (@($forms | Where-Object { -not $_.IsDisposed }).Count -eq 0)"
L "  if ($esc -or $allGone) {"
L "    $showTimer.Stop(); $watchTimer.Stop()"
L "    foreach ($f in @($forms)) { if (-not $f.IsDisposed) { $f.Dispose() } }"
L "    $ctx.ExitThread()"
L "  }"
L "})"
L ""
L "$showTimer.Start()"
L "$watchTimer.Start()"
L "[System.Windows.Forms.Application]::Run($ctx)"
L "Remove-Item -LiteralPath $PSCommandPath -Force -ErrorAction SilentlyContinue"

' 以 UTF-16 LE（带 BOM）写入，PowerShell 能正确识别中文
Set ts = fso.CreateTextFile(ps1Path, True, True)
ts.Write ps1
ts.Close

execCmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File " & Chr(34) & ps1Path & Chr(34)
shell.Run execCmd, 0, False