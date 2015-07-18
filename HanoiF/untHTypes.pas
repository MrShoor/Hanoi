unit untHTypes;

interface

const MaxRingCount = 15;

type
  TTower = record
    RingCount: Integer;
    Rings: array [0..MaxRingCount-1] of Integer;
    procedure MoveRing(var AtTower: TTower);
    procedure PutRing(size: Integer);
  end;

  TTowers = array [0..2] of TTower;

  TAction = record
    FromIndex: Integer;
    AtIndex  : Integer;
  end;

procedure InitTowers(var towers: TTowers);
procedure ClearTowers(var towers: TTowers);

implementation

procedure InitTowers(var towers: TTowers);
var i: Integer;
begin
  towers[0].RingCount := MaxRingCount;
  towers[1].RingCount := 0;
  towers[2].RingCount := 0;
  for i := 0 to MaxRingCount - 1 do
  begin
    towers[0].Rings[i] := MaxRingCount - i;
    towers[1].Rings[i] := 0;
    towers[2].Rings[i] := 0;
  end;
end;

procedure ClearTowers(var towers: TTowers);
var i: Integer;
begin
  towers[0].RingCount := 0;
  towers[1].RingCount := 0;
  towers[2].RingCount := 0;
  for i := 0 to MaxRingCount - 1 do
  begin
    towers[0].Rings[i] := 0;
    towers[1].Rings[i] := 0;
    towers[2].Rings[i] := 0;
  end;
end;

{ TTower }

procedure TTower.MoveRing(var AtTower: TTower);
begin
  Assert(RingCount > 0);
  Assert(AtTower.RingCount - 1 < MaxRingCount);
  if AtTower.RingCount > 0 then
    Assert(Rings[RingCount - 1] < AtTower.Rings[AtTower.RingCount - 1]);

  Dec(RingCount);
  AtTower.Rings[AtTower.RingCount] := Rings[RingCount];
  Rings[RingCount] := 0;
  Inc(AtTower.RingCount);
end;

procedure TTower.PutRing(size: Integer);
begin
  Assert(RingCount - 1 < MaxRingCount);
  if RingCount > 0 then
    Assert(size < Rings[RingCount - 1]);

  Rings[RingCount] := size;
  Inc(RingCount);
end;

end.
