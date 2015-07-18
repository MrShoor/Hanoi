program Hanoi;

{$APPTYPE CONSOLE}

uses
  Windows,
  Forms,
  untView in 'untView.pas' {frmView},
  untHTypes in 'untHTypes.pas';

{$R *.res}

procedure RedrawDebug(const towers: TTowers; fromindex, atindex: Integer);
var i: Integer;
    action: TAction;
begin
  action.FromIndex := fromindex;
  action.AtIndex := atindex;
  frmView.Show;
  frmView.Towers := towers;
  frmView.Action := action;
  for i := 0 to 1000 - 1 do
    begin
      Application.ProcessMessages;
      Sleep(1);
    end;
end;

procedure SolveHanoi;
var towers: TTowers;
  function GetThirdIndex(index1, index2: Integer): Integer; //по двум имеющимся осям возвращает третью независимую ось
  begin                                                     //на которую временно можно переложить стек
    Assert(index1 <> index2);
    case index1 of
      0: if index2 = 1 then Result := 2 else Result := 1;
      1: if index2 = 2 then Result := 0 else Result := 2;
      2: if index2 = 0 then Result := 1 else Result := 0;
    else
      Assert(False,'wrong indeces');
    end;
  end;
  procedure MoveStack(stacksize: Integer; fromindex, atindex: Integer); //перемещает стек из пирамидок с одной оси на другую
  var thirdindex: Integer;
  begin
    if stacksize = 0 then Exit;
    thirdindex := GetThirdIndex(fromindex, atindex);     //подбираем независимую ось
    MoveStack(stacksize - 1, fromindex, thirdindex);     //перемещаем подстек (на 1 меньший) на независимую ось
    RedrawDebug(towers, fromindex, atindex);             //  только отрисовка пирамидок
    towers[fromindex].MoveRing(towers[atindex]);         //перемещаем последнее кольцо на нужную нам ось
    WriteLn(fromindex,'-',atindex);                      //  записываем в консоль наше действие
    MoveStack(stacksize - 1, thirdindex, atindex);       //вовзращаем подстек с независимой на нужную нам ось
  end;
begin
  InitTowers(towers);
  MoveStack(MaxRingCount, 0, 1);
  RedrawDebug(towers, 0, 0);
end;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmView, frmView);
  SolveHanoi;
  Application.Run;
end.
