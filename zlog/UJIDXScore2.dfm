inherited JIDXScore2: TJIDXScore2
  Left = 99
  Top = 209
  Caption = 'Score'
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object Grid: TStringGrid
    Left = 0
    Top = 0
    Width = 281
    Height = 202
    Align = alClient
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 15
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #65325#65331' '#12468#12471#12483#12463
    Font.Style = []
    Options = [goHorzLine]
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 1
    OnDrawCell = GridDrawCell
  end
end
