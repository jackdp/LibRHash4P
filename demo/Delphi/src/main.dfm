object FormMain: TFormMain
  Left = 363
  Top = 250
  Caption = 'FormMain'
  ClientHeight = 586
  ClientWidth = 864
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    864
    586)
  PixelsPerInch = 96
  TextHeight = 13
  object edLib: TLabeledEdit
    Left = 15
    Top = 24
    Width = 756
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 100
    EditLabel.Height = 13
    EditLabel.Caption = 'Library file (DLL/SO):'
    EditLabel.Color = clBtnFace
    EditLabel.ParentColor = False
    LabelSpacing = 1
    TabOrder = 0
    Text = 'edLib'
  end
  object me: TMemo
    Left = 8
    Top = 200
    Width = 847
    Height = 336
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Fira Mono'
    Font.Style = []
    Lines.Strings = (
      'me')
    ParentFont = False
    TabOrder = 11
  end
  object btnHashCount: TButton
    Left = 16
    Top = 144
    Width = 80
    Height = 25
    Caption = 'Hash count'
    TabOrder = 7
    OnClick = btnHashCountClick
  end
  object btnHashNames: TButton
    Left = 105
    Top = 144
    Width = 124
    Height = 25
    Caption = 'Show hash names'
    TabOrder = 8
    OnClick = btnHashNamesClick
  end
  object btnHashesInfo: TButton
    Left = 238
    Top = 144
    Width = 128
    Height = 25
    Caption = 'Show hashes info'
    TabOrder = 9
    OnClick = btnHashesInfoClick
  end
  object btnHashFile: TButton
    Left = 16
    Top = 102
    Width = 104
    Height = 25
    Caption = 'Hash file'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = btnHashFileClick
  end
  object pnBottom: TPanel
    Left = 0
    Top = 538
    Width = 864
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 10
    DesignSize = (
      864
      48)
    object lblProgress: TLabel
      Left = 8
      Top = 6
      Width = 91
      Height = 13
      Caption = 'File hash progress:'
      Color = clBtnFace
      ParentColor = False
    end
    object pb: TProgressBar
      Left = 6
      Top = 24
      Width = 852
      Height = 20
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
  end
  object btnAbort: TButton
    Left = 128
    Top = 102
    Width = 75
    Height = 25
    Caption = 'Abort'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
    Visible = False
    OnClick = btnAbortClick
  end
  object pnHashType: TPanel
    Left = 408
    Top = 102
    Width = 258
    Height = 90
    TabOrder = 6
    object Label1: TLabel
      Left = 8
      Top = 6
      Width = 144
      Height = 13
      Caption = 'Select a hash to calculate'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
    end
    object rbCrc32: TRadioButton
      Left = 11
      Top = 24
      Width = 55
      Height = 19
      Caption = 'CRC32'
      TabOrder = 6
    end
    object rbMd5: TRadioButton
      Left = 11
      Top = 43
      Width = 45
      Height = 19
      Caption = 'MD5'
      TabOrder = 0
    end
    object rbSha1: TRadioButton
      Left = 11
      Top = 62
      Width = 54
      Height = 19
      Caption = 'SHA-1'
      Checked = True
      TabOrder = 1
      TabStop = True
    end
    object rbSha2_256: TRadioButton
      Left = 80
      Top = 24
      Width = 72
      Height = 19
      Caption = 'SHA2-256'
      TabOrder = 2
    end
    object rbSha2_512: TRadioButton
      Left = 80
      Top = 43
      Width = 72
      Height = 19
      Caption = 'SHA2-512'
      TabOrder = 3
    end
    object rbSha3_256: TRadioButton
      Left = 168
      Top = 24
      Width = 72
      Height = 19
      Caption = 'SHA3-256'
      TabOrder = 4
    end
    object rbSha3_512: TRadioButton
      Left = 168
      Top = 43
      Width = 72
      Height = 19
      Caption = 'SHA3-512'
      TabOrder = 5
    end
  end
  object edFile: TLabeledEdit
    Left = 16
    Top = 69
    Width = 756
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 59
    EditLabel.Height = 13
    EditLabel.Caption = 'File to hash:'
    EditLabel.Color = clBtnFace
    EditLabel.ParentColor = False
    LabelSpacing = 1
    TabOrder = 2
    Text = 'edFile'
  end
  object btnBrowseFile: TButton
    Left = 780
    Top = 68
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse...'
    TabOrder = 3
    OnClick = btnBrowseFileClick
  end
  object btnBrowseLib: TButton
    Left = 780
    Top = 23
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse...'
    TabOrder = 1
    OnClick = btnBrowseLibClick
  end
  object dlgOpenFile: TOpenDialog
    Filter = 'All files|*'
    Left = 704
    Top = 128
  end
  object dlgOpenLib: TOpenDialog
    Filter = 'DLL files|*.dll|All files|*.*'
    Left = 792
    Top = 128
  end
end
