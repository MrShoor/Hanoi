unit untView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, untHTypes, ComCtrls;

type
  TfrmView = class(TForm)
    tbOperation: TTrackBar;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tbOperationChange(Sender: TObject);
  private
    FTowers: TTowers;
    FAction: TAction;

    procedure RestoreDisk(size, actionIndex, actionCount, fromAxe, atAxe: Integer);
    procedure RestoreTowers;
  end;

var
  frmView: TfrmView;

implementation

uses Math, GraphUtil;

{$R *.dfm}

function GetThirdIndex(index1, index2: Integer): Integer;
begin
  Assert(index1 <> index2);
  case index1 of
    0: if index2 = 1 then Result := 2 else Result := 1;
    1: if index2 = 2 then Result := 0 else Result := 2;
    2: if index2 = 0 then Result := 1 else Result := 0;
  else
    Assert(False,'wrong indeces');
  end;
end;

{ TfrmView }

procedure TfrmView.FormCreate(Sender: TObject);
begin
  tbOperation.Max := 2 shl (MaxRingCount - 1)- 2;
  RestoreTowers;
end;

procedure TfrmView.FormPaint(Sender: TObject);
  function GetTowerAreaRect(index: Integer): TRect;
  var w: Integer;
  begin
    w := ClientWidth div Length(FTowers);
    Result.Left := w * index;
    Result.Right := w * (index + 1);
    Result.Top := 100;
    Result.Bottom := ClientHeight - 40;
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
  for j := 0 to Length(FTowers) - 1 do
    begin
      towerarea := GetTowerAreaRect(j);
      basearea := GetBaseRect(towerarea);
      ringsarea := GetRingsRect(towerarea);

      Canvas.Pen.Color := clBlack;
      Canvas.Brush.Color := clBlack;
      Canvas.Brush.Style := bsSolid;
      Canvas.Rectangle(basearea);
      MaxRoundRect(GetAxeRect(towerarea));
      for i := 0 to Length(FTowers[j].Rings) - 1 do
        begin
          if FTowers[j].Rings[i] > 0 then
          begin
            GetRingColors(FTowers[j].Rings[i], pcol, bcol);
            Canvas.Pen.Color := pcol;
            Canvas.Brush.Color := bcol;
            Canvas.Brush.Style := bsSolid;
            ring := GetRingRect(i, FTowers[j].Rings[i], ringsarea);
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

procedure TfrmView.RestoreDisk(size, actionIndex, actionCount, fromAxe, atAxe: Integer);
var pivot: Integer;
    i: Integer;
    thirdAxe: Integer;
begin
  pivot := actionCount div 2;
  thirdAxe := GetThirdIndex(fromAxe, atAxe);

  if actionIndex = pivot then //попали в центр, значит знаем какой диск сейчас перекладывается
  begin                       //и можем восстановить весь стек дисков меньшего размера. Конец рекурсии
    FTowers[fromAxe].PutRing(size);
    for i := size - 1 downto 1 do
      FTowers[thirdAxe].PutRing(i);
    FAction.FromIndex := fromAxe;
    FAction.AtIndex := atAxe;
  end
  else
    if actionIndex < pivot then
    begin                             //значит выполняется стадия перекладывания подстека на независимую ось
      FTowers[fromAxe].PutRing(size); //и нижний диск еще не переложен
      RestoreDisk(size - 1, actionIndex, actionCount - pivot - 1, fromAxe, thirdAxe);
    end
    else
    begin                             //значит выполняется стадия перекладывания подстека с независимой на нужную ось
      FTowers[atAxe].PutRing(size);   //и нижний диск уже переложен
      RestoreDisk(size - 1, actionIndex - pivot - 1, actionCount - pivot - 1, thirdAxe, atAxe);
    end;
end;

procedure TfrmView.RestoreTowers;
var index: Integer;
begin
  ClearTowers(FTowers);
  index := tbOperation.Position;
  RestoreDisk(MaxRingCount, index, 2 shl (MaxRingCount - 1) - 1, 0, 1);
  Invalidate;
end;

procedure TfrmView.tbOperationChange(Sender: TObject);
begin
  RestoreTowers;
end;

end.
