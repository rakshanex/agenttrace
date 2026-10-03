; AgentTrace Installer — Inno Setup script
; Wraps the standalone PyInstaller agenttrace.exe into a proper Windows installer
; so Microsoft Store package validation passes:
;   - Silent install support (/VERYSILENT)  -> "Silent install check"
;   - Add/Remove Programs entry (name+publisher) -> "Entry in add or remove programs"
;   - Clean uninstaller, no bundled extras -> "Bundleware check"
;
; Publisher: RAKSHANEX TECHNOLOGIES

#define MyAppName "AgentTrace"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "RAKSHANEX TECHNOLOGIES"
#define MyAppURL "https://www.rakshanex.cv"
#define MyAppExeName "agenttrace.exe"

[Setup]
; AppId uniquely identifies this app in Add/Remove Programs. Keep it stable across versions.
AppId={{B7E6B2A1-4C3D-4E5F-9A8B-AGENTTRACE001}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
; These two drive the Add/Remove Programs ("Apps & features") entry that Store validation looks for.
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
; Per-machine install (shows up in system Add/Remove Programs). Requires admin.
PrivilegesRequired=admin
OutputBaseFilename=agenttrace-setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Clean, honest metadata — no bundleware.
VersionInfoCompany={#MyAppPublisher}
VersionInfoProductName={#MyAppName}
VersionInfoVersion={#MyAppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
; Optional: add the install dir to PATH so `agenttrace` works from any terminal.
Name: "addtopath"; Description: "Add AgentTrace to the system PATH (recommended for CLI use)"; GroupDescription: "Additional options:"

[Files]
Source: "agenttrace.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "README.txt"; DestDir: "{app}"; Flags: ignoreversion isreadme

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"

[Registry]
; Add install dir to PATH only if the "addtopath" task is selected.
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; \
    ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"; \
    Check: NeedsAddPath('{app}'); Tasks: addtopath

[Code]
// Only append to PATH if the directory isn't already present.
function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', OrigPath)
  then begin
    Result := True;
    exit;
  end;
  Result := Pos(';' + Param + ';', ';' + OrigPath + ';') = 0;
end;
