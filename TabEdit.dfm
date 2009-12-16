object TabEditForm: TTabEditForm
  Left = 279
  Top = 173
  ActiveControl = OkBtn
  BorderStyle = bsDialog
  Caption = 'Tabelleneditor'
  ClientHeight = 277
  ClientWidth = 518
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 376
    Top = 8
    Width = 47
    Height = 13
    Caption = 'Eingang'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 440
    Top = 8
    Width = 50
    Height = 13
    Caption = 'Ausgang'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object xLabel: TLabel
    Left = 200
    Top = 256
    Width = 23
    Height = 13
    Caption = 'Zeit'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object y_max: TEdit
    Left = 8
    Top = 8
    Width = 65
    Height = 21
    TabOrder = 0
    OnKeyDown = KeyDown
  end
  object InputListBox: TListBox
    Left = 376
    Top = 24
    Width = 57
    Height = 177
    ItemHeight = 13
    TabOrder = 1
  end
  object OutputListBox: TListBox
    Left = 440
    Top = 24
    Width = 57
    Height = 177
    ItemHeight = 13
    TabOrder = 2
  end
  object x_max: TEdit
    Left = 312
    Top = 248
    Width = 49
    Height = 21
    TabOrder = 3
    OnKeyUp = KeyDown
  end
  object ObjectName: TEdit
    Left = 8
    Top = 56
    Width = 65
    Height = 21
    TabOrder = 4
  end
  object x_min: TEdit
    Left = 80
    Top = 248
    Width = 41
    Height = 21
    TabOrder = 5
    OnKeyUp = KeyDown
  end
  object y_min: TEdit
    Left = 8
    Top = 224
    Width = 57
    Height = 21
    TabOrder = 6
    OnKeyDown = KeyDown
  end
  object Panel: TPanel
    Left = 88
    Top = 8
    Width = 281
    Height = 233
    BevelInner = bvLowered
    TabOrder = 7
    object PaintBox: TImage
      Left = 2
      Top = 2
      Width = 277
      Height = 229
      Cursor = crCross
      Align = alClient
      OnMouseDown = PaintBoxMouseDown
      OnMouseMove = PaintBoxMouseMove
      OnMouseUp = PaintBoxMouseUp
    end
  end
  object OkBtn: TBitBtn
    Left = 425
    Top = 244
    Width = 88
    Height = 27
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 8
    OnClick = OkBtnClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    Margin = 2
    NumGlyphs = 2
    Spacing = -1
    IsControl = True
  end
  object CancelBtn: TBitBtn
    Left = 425
    Top = 214
    Width = 88
    Height = 27
    Caption = 'Abbruch'
    TabOrder = 9
    OnClick = CancelBtnClick
    Kind = bkCancel
    Margin = 2
    Spacing = -1
    IsControl = True
  end
end
