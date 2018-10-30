program WindowNinjaCat;

uses
  Vcl.Forms,
  Windows,
  Main in 'Main.pas' {ShortCutForm};

var
  vMutex: THandle;

{$R *.res}

begin
  vMutex := CreateMutex(nil, false, 'WindowNinjaCat');
  if GetLastError = ERROR_ALREADY_EXISTS then
    Halt(0);
  Application.Initialize;
  Application.ShowMainForm := false;
  Application.MainFormOnTaskbar := false;
  Application.CreateForm(TShortCutForm, ShortCutForm);
  Application.Run;
  CloseHandle(vMutex);

end.
