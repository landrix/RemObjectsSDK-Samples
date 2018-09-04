program SimpleSSLClientTCPDelphiIndy;

uses
  Vcl.Forms,
  SimpleSSLClientTCPDelphiIndyUnit1 in 'SimpleSSLClientTCPDelphiIndyUnit1.pas' {Form1},
  SimpleService_Intf in 'SimpleService_Intf.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
