object Form6: TForm6
  Left = 0
  Top = 0
  Caption = 'Form6'
  ClientHeight = 442
  ClientWidth = 632
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnPaint = FormPaint
  TextHeight = 15
  object btnTriangulation: TButton
    Left = 504
    Top = 376
    Width = 105
    Height = 41
    Caption = #1058#1088#1080#1072#1085#1075#1091#1083#1103#1094#1080#1103
    TabOrder = 0
    OnClick = btnTriangulationClick
  end
  object editNumberPoints: TEdit
    Left = 504
    Top = 328
    Width = 105
    Height = 23
    TabOrder = 1
    Text = #1050#1086#1083'-'#1074#1086' '#1090#1086#1095#1077#1082
    OnClick = editNumberPointsClick
  end
end
