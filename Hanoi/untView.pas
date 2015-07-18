unit untView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, untHTypes;

type
  TfrmView = class(TForm)
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FTowers: TTowers;
    FAction: TAction;
    procedure SetTowers(const Value: TTowers);
    procedure SetAction(const Value: TAction);
  public
    property Towers: TTowers read FTowers write SetTowers;
    property Action: TAction read FAction write SetAction;
  end;

var
  frmView: TfrmView;

implementation

uses Math, GraphUtil;

{$R *.dfm}

{ TfrmView }

procedure TfrmView.FormCreate(Sender: TObject);
begin
  FAction.FromIndex := 0;
  FAction.AtIndex := 2;
end;

procedure TfrmView.FormPaint(Sender: TObject);
  function GetTowerAreaRect(index: Integer): TRect;
  var w: Integer;
  begin
    w := ClientWidth div Length(FTowers);
    Result.Left := w * index;
    Result.Right := w * (index + 1);
    Result.Top := 100;
    Result.Bottom := ClientHeight;
    InflateRect(Result, -20, -20);
  end;
  function GetBaseRect(TowerRect: TRect): TRect;
  begin
    Result := TowerRect;
    Result.Top := Result.Bottom - (TowerRect.Bottom - TowerRect.Top) div (MaxRingCount * 2);
  end;
  function GetAxeRect(TowerRect: TRect): TRect;
  var w: Integer;
  begin
    w := TowerRect.Right - TowerRect.Left;
    Result := TowerRect;
    Result.Left := (TowerRect.Left + TowerRect.Right) div 2;
    Result.Right := Result.Left;
    InflateRect(Result, Trunc(w * 0.25 * (1) / (MaxRingCount)), 0);
  end;
  function GetRingsRect(TowerRect: TRect): TRect;
  begin
    Result := TowerRect;
    Result.Bottom := Result.Bottom - (TowerRect.Bottom - TowerRect.Top) div (MaxRingCount * 2);
  end;
  function GetRingRect(index: Integer; size: Integer; rect: TRect): TRect;
  var w, h: Integer;
  begin
    w := rect.Right - rect.Left;
    h := rect.Bottom - rect.Top;

    Result.Bottom := Trunc(rect.Bottom - h * index / MaxRingCount);
    Result.Top := Trunc(rect.Bottom - h * (index + 1) / MaxRingCount);
    Result.Left := (rect.Left + rect.Right) div 2;
    Result.Right := Result.Left;
    InflateRect(Result, -2 + Trunc(w * 0.5 * (size + 2) / (MaxRingCount + 2)), -1);
  end;
  procedure GetRingColors(size: Integer; var pencolor, brushcolor: TColor);
  var hue: DWORD;
  begin
    hue := Trunc(240 * size / MaxRingCount);
    pencolor   := ColorHLSToRGB(hue, 160, 240);
    brushcolor := ColorHLSToRGB(hue, 200, 240);
  end;
  procedure MaxRoundRect(rct: TRect);
  var h, w: Integer;
  begin
    w := rct.Right - rct.Left;
    h := rct.Bottom - rct.Top;
    Canvas.RoundRect(rct, Min(w, h), Min(w, h));
  end;
var i, j: Integer;
    towerarea: TRect;
    basearea: TRect;
    ringsarea: TRect;
    ring: TRect;

    pcol, bcol: TColor;

    curve: array [0..3] of TPoint;
begin
  Canvas.Brush.Color := clWindow;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(Canvas.ClipRect);

  Canvas.Pen.Width := 3;
  for j := 0 to Length(Towers) - 1 do
    begin
      towerarea := GetTowerAreaRect(j);
      basearea := GetBaseRect(towerarea);
      ringsarea := GetRingsRect(towerarea);

      Canvas.Pen.Color := clBlack;
      Canvas.Brush.Color := clBlack;
      Canvas.Brush.Style := bsSolid;
      Canvas.Rectangle(basearea);
      MaxRoundRect(GetAxeRect(towerarea));
      for i := 0 to Length(Towers[j].Rings) - 1 do
        begin
          if Towers[j].Rings[i] > 0 then
          begin
            GetRingColors(Towers[j].Rings[i], pcol, bcol);
            Canvas.Pen.Color := pcol;
            Canvas.Brush.Color := bcol;
            Canvas.Brush.Style := bsSolid;
            ring := GetRingRect(i, Towers[j].Rings[i], ringsarea);
            MaxRoundRect(ring);
          end;
        end;
    end;

  if FAction.FromIndex = FAction.AtIndex then Exit;
  Canvas.Pen.Color := clRed;

  towerarea := GetTowerAreaRect(FAction.FromIndex);
  curve[0] := Point((towerarea.Left + towerarea.Right) div 2, towerarea.Top - 20);
  curve[1] := Point((towerarea.Left + towerarea.Right) div 2, 0);
  towerarea := GetTowerAreaRect(FAction.AtIndex);
  curve[2] := Point((towerarea.Left + towerarea.Right) div 2, 0);
  curve[3] := Point((towerarea.Left + towerarea.Right) div 2, towerarea.Top - 20);
  Canvas.PolyBezier(curve);
  Canvas.MoveTo(curve[3].X, curve[3].Y);
  Canvas.LineTo(curve[3].X + 15, curve[3].Y - 15);
  Canvas.MoveTo(curve[3].X, curve[3].Y);
  Canvas.LineTo(curve[3].X - 15, curve[3].Y - 15);
end;

procedure TfrmView.SetAction(const Value: TAction);
begin
  FAction := Value;
  Invalidate;
end;

procedure TfrmView.SetTowers(const Value: TTowers);
begin
  FTowers := Value;
  Invalidate;
end;

end.
