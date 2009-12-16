object PhasenAuswahl: TPhasenAuswahl
  Left = 444
  Top = 207
  Width = 496
  Height = 302
  Caption = 'Variablenauswahl'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonPanel: TPanel
    Left = 385
    Top = 0
    Width = 96
    Height = 265
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object OKBtn: TBitBtn
      Left = 1
      Top = 12
      Width = 88
      Height = 27
      TabOrder = 0
      Kind = bkOK
      Margin = 2
      Spacing = -1
      IsControl = True
    end
    object CancelBtn: TBitBtn
      Left = 1
      Top = 46
      Width = 88
      Height = 27
      Caption = 'Abbruch'
      TabOrder = 1
      Kind = bkCancel
      Margin = 2
      Spacing = -1
      IsControl = True
    end
    object HelpBtn: TBitBtn
      Left = 1
      Top = 82
      Width = 88
      Height = 27
      TabOrder = 2
      Kind = bkHelp
      Margin = 2
      Spacing = -1
      IsControl = True
    end
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 377
    Height = 257
    ActivePage = TabSheet1
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'Variablen'
      object GroupBox1: TGroupBox
        Left = 8
        Top = 4
        Width = 353
        Height = 221
        Caption = 'Variablenauswahl'
        TabOrder = 0
        IsControl = True
        object SrcLabel: TLabel
          Left = 16
          Top = 24
          Width = 145
          Height = 16
          AutoSize = False
          Caption = 'Quell-Liste:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          IsControl = True
        end
        object DstLabel: TLabel
          Left = 200
          Top = 24
          Width = 145
          Height = 16
          AutoSize = False
          Caption = 'Zielliste:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          IsControl = True
        end
        object IncludeBtn: TSpeedButton
          Left = 168
          Top = 56
          Width = 24
          Height = 24
          Caption = '>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          OnClick = IncludeBtnClick
          IsControl = True
        end
        object IncAllBtn: TSpeedButton
          Left = 168
          Top = 88
          Width = 24
          Height = 24
          Caption = '>>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          OnClick = IncAllBtnClick
          IsControl = True
        end
        object ExcludeBtn: TSpeedButton
          Left = 168
          Top = 120
          Width = 24
          Height = 24
          Caption = '<'
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          OnClick = ExcludeBtnClick
          IsControl = True
        end
        object ExAllBtn: TSpeedButton
          Left = 168
          Top = 152
          Width = 24
          Height = 24
          Caption = '<<'
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          OnClick = IncAllBtnClick
          IsControl = True
        end
        object Label5: TLabel
          Left = 200
          Top = 48
          Width = 8
          Height = 13
          Caption = 'x:'
        end
        object Label6: TLabel
          Left = 200
          Top = 64
          Width = 8
          Height = 13
          Caption = 'y:'
        end
        object SrcList: TListBox
          Left = 16
          Top = 48
          Width = 144
          Height = 153
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ItemHeight = 13
          MultiSelect = True
          ParentFont = False
          Sorted = True
          TabOrder = 0
          IsControl = True
        end
        object DstList: TListBox
          Left = 216
          Top = 48
          Width = 128
          Height = 33
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ItemHeight = 13
          MultiSelect = True
          ParentFont = False
          TabOrder = 1
          IsControl = True
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Schaubild'
      ImageIndex = 1
      object GroupBox2: TGroupBox
        Left = 8
        Top = 8
        Width = 353
        Height = 217
        Caption = 'Farbwahl'
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        object Label1: TLabel
          Left = 16
          Top = 49
          Width = 56
          Height = 13
          Caption = 'Schaubild 1'
        end
        object Label2: TLabel
          Left = 16
          Top = 81
          Width = 56
          Height = 13
          Caption = 'Schaubild 2'
        end
        object Label3: TLabel
          Left = 16
          Top = 113
          Width = 56
          Height = 13
          Caption = 'Schaubild 3'
        end
        object Label4: TLabel
          Left = 16
          Top = 145
          Width = 56
          Height = 13
          Caption = 'Schaubild 4'
        end
        object ColorBox1: TColorBox
          Left = 104
          Top = 44
          Width = 105
          Height = 22
          ItemHeight = 16
          TabOrder = 0
        end
        object ColorBox2: TColorBox
          Left = 104
          Top = 76
          Width = 105
          Height = 22
          DefaultColorColor = clRed
          Selected = clRed
          ItemHeight = 16
          TabOrder = 1
        end
        object ColorBox3: TColorBox
          Left = 104
          Top = 108
          Width = 105
          Height = 22
          DefaultColorColor = clNavy
          Selected = clNavy
          ItemHeight = 16
          TabOrder = 2
        end
        object ColorBox4: TColorBox
          Left = 104
          Top = 140
          Width = 105
          Height = 22
          DefaultColorColor = clGreen
          Selected = clGreen
          Color = clWhite
          ItemHeight = 16
          TabOrder = 3
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Achsenkreuz'
      ImageIndex = 2
      object GroupBox3: TGroupBox
        Left = 8
        Top = 4
        Width = 353
        Height = 217
        Caption = 'Skalierung'
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        object RadioGroup1: TRadioGroup
          Left = 16
          Top = 24
          Width = 105
          Height = 73
          Caption = 'Skalierung'
          TabOrder = 0
        end
        object RadioButton1: TRadioButton
          Left = 24
          Top = 48
          Width = 81
          Height = 17
          Caption = 'ungleich'
          TabOrder = 1
        end
        object RadioButton2: TRadioButton
          Left = 24
          Top = 72
          Width = 81
          Height = 17
          Caption = 'gleich'
          Enabled = False
          TabOrder = 2
        end
        object RadioGroup2: TRadioGroup
          Left = 16
          Top = 112
          Width = 105
          Height = 81
          TabOrder = 3
        end
        object RadioButton4: TRadioButton
          Left = 24
          Top = 160
          Width = 81
          Height = 17
          Caption = 'manuell'
          Enabled = False
          TabOrder = 5
        end
        object RadioButton3: TRadioButton
          Left = 24
          Top = 136
          Width = 89
          Height = 17
          Caption = 'automatisch'
          Checked = True
          TabOrder = 4
          TabStop = True
        end
      end
    end
  end
end
