program SimpleSSLServerDelphiIndy;

uses
  uROComInit,
  Vcl.Forms,
  SimpleSSLServerDelphiIndyUnit1 in 'SimpleSSLServerDelphiIndyUnit1.pas' {Form1},
  SimpleServiceImpl in 'SimpleServiceImpl.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
