Unit Main;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,
  Vcl.ExtCtrls;

Type
  TShortCutForm = Class(TForm)
    TrayIcon: TTrayIcon;
    PopupMenu: TPopupMenu;
    Exit1: TMenuItem;
    Procedure FormCreate(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure Exit1Click(Sender: TObject);
  Private
    Procedure Hotkey(Hotkey: Integer);
  End;

Var
  ShortCutForm: TShortCutForm;
  FHook: HHook = 0;
  WINPressed: Boolean = False;

Type
  TagKBDLLHOOKSTRUCT = Packed Record
    VkCode: DWord;
    ScanCode: DWord;
    Flags: DWord;
    Time: DWord;
    DwExtraInfo: PDWord;
  End;

  TKBDLLHOOKSTRUCT = TagKBDLLHOOKSTRUCT;
  PKBDLLHOOKSTRUCT = ^TKBDLLHOOKSTRUCT;

Const
  NUM0 = 45;
  NUM1 = 35;
  NUM2 = 40;
  NUM3 = 34;
  NUM4 = 37;
  NUM5 = 12;
  NUM6 = 39;
  NUM7 = 36;
  NUM8 = 38;
  NUM9 = 33;

  HK_ArrangeToTopLeftCorner = 7;
  HK_ArrangeToTopRightCorner = 9;
  HK_ArrangeToBottomLeftCorner = 1;
  HK_ArrangeToBottomRightCorner = 3;
  HK_ArrangeToBottom = 2;

Implementation

{$R *.dfm}

Procedure TShortCutForm.Hotkey(Hotkey: Integer);
Var
  Window: HWND;
  Coordinates: TRect;
  Monitor: TRect;
  Result: NativeInt;
Begin
  // Get foreground window
  Window := GetForegroundWindow;

  // We don't want to arrange Taskbar
  If Window = FindWindow('Shell_TrayWnd', Nil) Then
    Exit;

  // Get the window bounds
  GetWindowRect(Window, Coordinates);

  // Multimonitor support
  Monitor := Screen.MonitorFromWindow(Window).WorkareaRect;

  // Calculations depending on requested direction
  case Hotkey of
    HK_ArrangeToTopLeftCorner:
      With Coordinates Do
      Begin
        Left := Monitor.Left;
        Top := Monitor.Top;
        Width := Monitor.Width Div 2;
        Height := Monitor.Height Div 2;
      End;
    HK_ArrangeToTopRightCorner:
      With Coordinates Do
      Begin
        Left := Monitor.Left + Monitor.Width Div 2;
        Top := Monitor.Top;
        Width := Monitor.Width Div 2;
        Height := Monitor.Height Div 2;
      End;
    HK_ArrangeToBottomLeftCorner:
      With Coordinates Do
      Begin
        Left := Monitor.Left;
        Top := Monitor.Top + Monitor.Height Div 2;
        Width := Monitor.Width Div 2;
        Height := Monitor.Height Div 2;
      End;
    HK_ArrangeToBottom:
      With Coordinates Do
      Begin
        Left := Monitor.Left;
        Top := Monitor.Top + Monitor.Height Div 2;
        Width := Monitor.Width;
        Height := Monitor.Height Div 2;
      End;
    HK_ArrangeToBottomRightCorner:
      With Coordinates Do
      Begin
        Left := Monitor.Left + Monitor.Width Div 2;
        Top := Monitor.Top + Monitor.Height Div 2;
        Width := Monitor.Width Div 2;
        Height := Monitor.Height Div 2;
      End;
  end;

  // Send restore message, it remove maximized state of the window
  ShowWindow(Window, SW_RESTORE);

  // Moving window to the calculated rect
  MoveWindow(Window, Coordinates.Left, Coordinates.Top, Coordinates.Width,
    Coordinates.Height, True);
End;

Function LowLevelKeyboardProc(HookCode: Longint; MessageParam: WParam;
  StructParam: LParam): DWord; Stdcall;
Var
  P: PKBDLLHOOKSTRUCT;
Begin
  // Microsoft noidea, it is always = HC_ACTION (HC_ACTION=1)
  If (HookCode = HC_ACTION) Then
    Case (MessageParam) Of
      // Check only keydown and keyup events
      WM_KEYDOWN, WM_SYSKEYDOWN, WM_KEYUP, WM_SYSKEYUP:
        Begin
          // Get additional parameters about keystroke
          P := PKBDLLHOOKSTRUCT(StructParam);
          // Handle WIN button pressing
          If (P.VkCode = VK_LWIN) Or (P.VkCode = VK_RWIN) Then
            WINPressed := (MessageParam = WM_KEYDOWN)
          Else If MessageParam = WM_KEYDOWN Then
            If WINPressed Then
              // Independent whatisthis scancodes when pressing WIN+SHIFT+[whatever]
              Case P.VkCode Of
                NUM7:
                  Begin
                    ShortCutForm.Hotkey(HK_ArrangeToTopLeftCorner);
                    Result := 1;
                    Exit;
                  End;
                NUM9:
                  Begin
                    ShortCutForm.Hotkey(HK_ArrangeToTopRightCorner);
                    Result := 1;
                    Exit;
                  End;
                NUM1:
                  Begin
                    ShortCutForm.Hotkey(HK_ArrangeToBottomLeftCorner);
                    Result := 1;
                    Exit;
                  End;
                NUM2:
                  Begin
                    ShortCutForm.Hotkey(HK_ArrangeToBottom);
                    Result := 1;
                    Exit;
                  End;
                NUM3:
                  Begin
                    ShortCutForm.Hotkey(HK_ArrangeToBottomRightCorner);
                    Result := 1;
                    Exit;
                  End;
              End;
        End;
    End;
  // If no our keycombo, go to the next hook in chain
  Result := CallNextHookEx(0, HookCode, MessageParam, StructParam);
End;

Procedure TShortCutForm.Exit1Click(Sender: TObject);
Begin
  ShortCutForm.Close;
End;

Procedure TShortCutForm.FormCreate(Sender: TObject);
Begin
  FHook := SetWindowsHookEx(WH_KEYBOARD_LL, @LowLevelKeyboardProc,
    Hinstance, 0);
End;

Procedure TShortCutForm.FormDestroy(Sender: TObject);
Begin
  If FHook > 0 Then
    UnHookWindowsHookEx(FHook);
End;

End.
