program Hanoi;

uses
  Windows,
  Forms,
  untView in 'untView.pas' {frmView},
  untHTypes in 'untHTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmView, frmView);
  Application.Run;
end.
