object OptionsForm: TOptionsForm
  Left = 540
  Top = 274
  Width = 728
  Height = 430
  Caption = 'OptionsForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LabelDevices: TLabel
    Left = 18
    Top = 18
    Width = 62
    Height = 13
    Caption = 'Device List : '
  end
  object LabelDebugLog: TLabel
    Left = 210
    Top = 18
    Width = 62
    Height = 13
    Caption = 'Debug Log : '
  end
  object LabelVLCLog: TLabel
    Left = 210
    Top = 120
    Width = 60
    Height = 13
    Caption = 'libVLC Log : '
  end
  object ScanButton: TButton
    Left = 16
    Top = 350
    Width = 75
    Height = 25
    Caption = 'Scan'
    TabOrder = 0
    OnClick = ScanButtonClick
  end
  object SetOPVLCCastDeviceList: TListBox
    Left = 16
    Top = 32
    Width = 181
    Height = 307
    ItemHeight = 13
    TabOrder = 1
  end
  object StopButton: TButton
    Left = 122
    Top = 350
    Width = 75
    Height = 25
    Caption = 'Stop'
    Enabled = False
    TabOrder = 2
    OnClick = StopButtonClick
  end
  object DebugLB: TListBox
    Left = 208
    Top = 32
    Width = 487
    Height = 83
    ItemHeight = 13
    TabOrder = 3
  end
  object LogLB: TListBox
    Left = 208
    Top = 134
    Width = 487
    Height = 241
    ItemHeight = 13
    TabOrder = 4
  end
end
