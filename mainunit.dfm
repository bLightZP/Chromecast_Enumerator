object OptionsForm: TOptionsForm
  Left = 540
  Top = 274
  Width = 509
  Height = 303
  Caption = 'OptionsForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ScanButton: TButton
    Left = 146
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Scan'
    TabOrder = 0
    OnClick = ScanButtonClick
  end
  object SetOPVLCCastDeviceList: TListBox
    Left = 74
    Top = 48
    Width = 349
    Height = 97
    ItemHeight = 13
    TabOrder = 1
  end
  object StopButton: TButton
    Left = 252
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 2
    OnClick = StopButtonClick
  end
end
