$Code = @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@
Add-Type $Code -Name 'Utils' -Namespace Win32

[Win32.Utils]::ShowWindowAsync(Hwnd, 7)
[Win32.Utils]::ShowWindowAsync(Hwnd, 9)
