$Code = @"
[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();
"@
Add-Type $Code -Name 'Utils' -Namespace Win32

$Hwnd = [Win32.Utils]::GetForegroundWindow()
$Hwnd
