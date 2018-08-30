program Server;

uses
  uROCOMInit, //Important !!! If you get an exception saying "CoInitialize has not been called" make sure the unit uROCOMInit.pas is included in *and* is the FIRST UNIT of your DPR file.
  Vcl.Forms,
  ServerUnit1 in 'ServerUnit1.pas' {ServerForm},
  RODLTypes in 'RODLTypes.pas',
  ServerLogin_Impl in 'ServerLogin_Impl.pas' {ServiceLogin: TRORemoteDataModule},
  ServerService_Impl in 'ServerService_Impl.pas' {Service: TRORemoteDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TServerForm, ServerForm);
  Application.Run;
end.
