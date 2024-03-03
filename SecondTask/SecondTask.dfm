object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 442
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object lblResult: TLabel
    Left = 371
    Top = 120
    Width = 129
    Height = 21
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1079#1085#1072#1095#1077#1085#1080#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 400
    Top = 163
    Width = 9
    Height = 21
    Caption = #1061
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 472
    Top = 163
    Width = 9
    Height = 21
    Caption = 'Y'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 200
    Top = 8
    Width = 9
    Height = 21
    Caption = #1061
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 296
    Top = 8
    Width = 9
    Height = 21
    Caption = 'Y'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object lbxCoordinates: TListBox
    Left = 8
    Top = 22
    Width = 137
    Height = 242
    ItemHeight = 15
    TabOrder = 0
  end
  object editVertexX: TEdit
    Left = 160
    Top = 24
    Width = 89
    Height = 23
    TabOrder = 1
  end
  object editVertexY: TEdit
    Left = 255
    Top = 24
    Width = 89
    Height = 23
    TabOrder = 2
  end
  object btnAdd: TButton
    Left = 360
    Top = 23
    Width = 75
    Height = 25
    Caption = 'Add'
    TabOrder = 3
    OnClick = btnAddClick
  end
  object editPointX: TEdit
    Left = 360
    Top = 184
    Width = 75
    Height = 23
    TabOrder = 4
  end
  object editPointY: TEdit
    Left = 441
    Top = 184
    Width = 75
    Height = 23
    TabOrder = 5
  end
  object btnCheck: TButton
    Left = 400
    Top = 213
    Width = 75
    Height = 25
    Caption = 'Check'
    TabOrder = 6
    OnClick = btnCheckClick
  end
  object btnDefault: TButton
    Left = 160
    Top = 63
    Width = 170
    Height = 25
    BiDiMode = bdLeftToRight
    Caption = 'Preset Convex polygon'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentBiDiMode = False
    ParentFont = False
    TabOrder = 7
    OnClick = btnPresetConvexClick
  end
  object Button1: TButton
    Left = 160
    Top = 94
    Width = 170
    Height = 25
    Caption = 'Preset Non-Convex polygon'
    TabOrder = 8
    OnClick = btnPresetNonConvexClick
  end
end
