object ShortCutForm: TShortCutForm
  Left = 0
  Top = 0
  Caption = 'ShortCutForm'
  ClientHeight = 300
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object TrayIcon: TTrayIcon
    PopupMenu = PopupMenu
    Visible = True
    Left = 424
    Top = 168
  end
  object PopupMenu: TPopupMenu
    Left = 216
    Top = 144
    object StartwithWindows1: TMenuItem
      Caption = 'Start with Windows'
      OnClick = StartwithWindows1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Exit1: TMenuItem
      Caption = 'Exit'
      OnClick = Exit1Click
    end
  end
end
