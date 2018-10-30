unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,
  Vcl.ExtCtrls;

type
  TShortCutForm = class(TForm)
    TrayIcon: TTrayIcon;
    PopupMenu: TPopupMenu;
    Exit1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
  private
    procedure Hotkey(Hotkey: String);
  end;

var
  ShortCutForm: TShortCutForm;
  FHook: HHook = 0;
  HotKeyProcessing: Boolean = False;
  WINPressed: Boolean = False;
  SHIFTPressed: Boolean = False;

const
  WH_KEYBOARD_LL = 13;
  LLKHF_ALTDOWN = KF_ALTDOWN shr 8;

type
  tagKBDLLHOOKSTRUCT = packed record
    vkCode: DWord;
    scanCode: DWord;
    flags: DWord;
    time: DWord;
    dwExtraInfo: PDWord;
  end;

  TKBDLLHOOKSTRUCT = tagKBDLLHOOKSTRUCT;
  PKBDLLHOOKSTRUCT = ^TKBDLLHOOKSTRUCT;

implementation

{$R *.dfm}

Function GetRetkesfaszuWindow: HWND;
var
  Wnd: HWND;
  TId, PId: DWord;
Begin
  Result := Winapi.Windows.GetFocus;
  If Result = 0 Then
  Begin
    Wnd := GetForegroundWindow;
    If Wnd <> 0 Then
    Begin
      TId := GetWindowThreadProcessId(Wnd, PId);
      If AttachThreadInput(GetCurrentThreadid, TId, True) Then
      Begin
        Result := Winapi.Windows.GetFocus;
        AttachThreadInput(GetCurrentThreadid, TId, False);
      end;
    end;
  end;
end;

procedure TShortCutForm.Hotkey(Hotkey: String);
var
  Window: HWND;
  Coordinates: TRect;
  Monitor: TMonitor;
Begin
  Window := GetForegroundWindow; // GetRetkesfaszuWindow;
  OutputDebugString(PWideChar('Window: ' + inttostr(Window)));
  GetWindowRect(Window, Coordinates);
  OutputDebugString(PWideChar('Rect: ' + inttostr(Coordinates.Left) + ',' +
    inttostr(Coordinates.Top)));
  Monitor := Screen.MonitorFromWindow(Window);
  OutputDebugString(PWideChar('Monitor: ' + inttostr(Monitor.MonitorNum)));
  If Hotkey = '7' Then
    With Coordinates do
    begin
      Left := Monitor.Left;
      Top := Monitor.Top;
      Width := Monitor.Width div 2;
      Height := Monitor.Height div 2;
    end;
  If Hotkey = '9' Then
    With Coordinates do
    begin
      Left := Monitor.Left + Monitor.Width div 2;
      Top := Monitor.Top;
      Width := Monitor.Width div 2;
      Height := Monitor.Height div 2;
    end;
  If Hotkey = '1' Then
    With Coordinates do
    begin
      Left := Monitor.Left;
      Top := Monitor.Top + Monitor.Height div 2;
      Width := Monitor.Width div 2;
      Height := Monitor.Height div 2;
    end;
  If Hotkey = '3' Then
    With Coordinates do
    begin
      Left := Monitor.Left + Monitor.Width div 2;
      Top := Monitor.Top + Monitor.Height div 2;
      Width := Monitor.Width div 2;
      Height := Monitor.Height div 2;
    end;
  MoveWindow(Window, Coordinates.Left, Coordinates.Top, Coordinates.Width,
    Coordinates.Height, True);
end;

function LowLevelKeyboardProc(HookCode: Longint; MessageParam: WParam;
  StructParam: LParam): DWord; stdcall;
var
  P: PKBDLLHOOKSTRUCT;
begin
  if (HookCode = HC_ACTION) then
    case (MessageParam) of
      WM_KEYDOWN, WM_SYSKEYDOWN, WM_KEYUP, WM_SYSKEYUP:
        begin
          P := PKBDLLHOOKSTRUCT(StructParam);
          if (P.vkCode = VK_LWIN) or (P.vkCode = VK_RWIN) then
          begin
            WINPressed := (MessageParam = WM_KEYDOWN);
          end
          else if (P.vkCode = VK_LSHIFT) or (P.vkCode = VK_RSHIFT) then
          begin
            SHIFTPressed := (MessageParam = WM_KEYDOWN);
          end
          else if MessageParam = WM_KEYDOWN then
            if WINPressed then
            begin
              if (P.vkCode = 36) then
              begin
                ShortCutForm.Hotkey('7');
                Result := 1;
                exit;
              end;
              if (P.vkCode = 33) then
              begin
                ShortCutForm.Hotkey('9');
                Result := 1;
                exit;
              end;
              if (P.vkCode = 35) then
              begin
                ShortCutForm.Hotkey('1');
                Result := 1;
                exit;
              end;
              if (P.vkCode = 34) then
              begin
                ShortCutForm.Hotkey('3');
                Result := 1;
                exit;
              end;
            end;
        end;
    end;
  Result := CallNextHookEx(0, HookCode, MessageParam, StructParam);
end;

procedure TShortCutForm.Exit1Click(Sender: TObject);
begin
  ShortCutForm.Close;
end;

procedure TShortCutForm.FormCreate(Sender: TObject);
begin
  FHook := SetWindowsHookEx(WH_KEYBOARD_LL, @LowLevelKeyboardProc,
    Hinstance, 0);
end;

procedure TShortCutForm.FormDestroy(Sender: TObject);
begin
  if FHook > 0 then
    UnHookWindowsHookEx(FHook);
end;

end.
