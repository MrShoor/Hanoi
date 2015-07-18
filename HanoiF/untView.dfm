object frmView: TfrmView
  Left = 0
  Top = 0
  Caption = 'frmView'
  ClientHeight = 386
  ClientWidth = 607
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnPaint = FormPaint
  DesignSize = (
    607
    386)
  PixelsPerInch = 96
  TextHeight = 13
  object tbOperation: TTrackBar
    Left = 8
    Top = 353
    Width = 591
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 0
    OnChange = tbOperationChange
  end
end
