unit SimpleSSLServerDelphiIndyUnit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs

  ,uRORTTIServerSupport
  ,uROClient, uROServer,uROPoweredByRemObjectsButton, uROClientIntf, uROClasses
  ,uROBaseSuperTCPServer, uROSynapseSuperTCPServer, uROBinMessage,uROAESEncryptionEnvelope
  ,uROSuperTCPServer,uROComboService,uROBaseConnection, uROComponent, uROMessage
  ,uRONamedPipeServer,uRoHTTPDispatch,uRoHTTPTools
  ,uROCustomHTTPServer,uROBaseHTTPServer,uROIndyHTTPServer,uROServerIntf

  ,IdBaseComponent, IdComponent, IdTCPServer, IdCustomHTTPServer, IdContext,IdHTTPServer,IdSSLOpenSSL,IdSSL
  ;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  public
    ROMessage: TROBinMessage;
    ROAESEncryptionEnvelope: TROAESEncryptionEnvelope;
    ROSuperTCPServer: TROSuperTCPServer;
    RONamedPipeServer: TRONamedPipeServer;
    ROIndyHTTPServer: TROIndyHTTPServer;
    ROIndyServerSSL: TIdServerIOHandlerSSLOpenSSL;
  public
    procedure ROSuperTCPServerOnConnect(AContext: TIdContext);
    procedure ROIndyHTTPServerOnQuerySSLPort(APort: Word; var VUseSSL: Boolean);
    procedure ROIndyHTTPServerOnHTTPAuthentication (const aRequest: IROHTTPRequest; const aUserName, aPassword: String; var aHandled: Boolean);
    procedure ROIndyServerSSLOnGetPassword(var Password : String);
  end;

  TRO = class
  public
    const AES_PASSWORD = 'mypwd';
    const SSL_PASSWORD = 'mypwdssl';
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  uRORTTIServerSupport.RODLLibraryName := 'SimpleService';

  ROAESEncryptionEnvelope := TROAESEncryptionEnvelope.Create(nil);
  ROAESEncryptionEnvelope.Name := 'ROAESEncryptionEnvelope';
  ROAESEncryptionEnvelope.EnvelopeMarker := 'AES';
  ROAESEncryptionEnvelope.Password := TRO.AES_PASSWORD;

  ROMessage := TROBinMessage.Create(nil);
  ROMessage.Name := 'ROMessage';
  with ROMessage.Envelopes.Add as TROMessageEnvelopeItem do
  begin
    Envelope := ROAESEncryptionEnvelope;
  end;

  ROIndyServerSSL:= TIdServerIOHandlerSSLOpenSSL.Create(nil);
//  ROIndyServerSSL.SSLOptions.SSLVersions := [sslvSSLv2,sslvSSLv3,sslvTLSv1,sslvTLSv1_1,sslvTLSv1_2];
  ROIndyServerSSL.SSLOptions.Method := sslvSSLv23;//sslvTLSv1_2;// // Avoid using SSL - sslvSSLv23;
  ROIndyServerSSL.SSLOptions.Mode := sslmServer;
  ROIndyServerSSL.SSLOptions.VerifyDepth := 0;
  ROIndyServerSSL.SSLOptions.VerifyMode := [];// [sslvrfPeer,sslvrfFailIfNoPeerCert,sslvrfClientOnce];
  ROIndyServerSSL.OnGetPassword := ROIndyServerSSLOnGetPassword;
  //TODO load cert from ressource http://stackoverflow.com/questions/29845063/can-indy-load-ssl-certificates-from-memory
  ROIndyServerSSL.SSLOptions.RootCertFile := ExtractFilePath(Application.ExeName)+ 'ca.cert.pem';
  ROIndyServerSSL.SSLOptions.CertFile := ExtractFilePath(Application.ExeName)+ 'localhost.cert.pem';
  ROIndyServerSSL.SSLOptions.KeyFile := ExtractFilePath(Application.ExeName)+ 'localhost.key.pem';

  ROSuperTCPServer := TROSuperTCPServer.Create(nil);
  ROSuperTCPServer.Name := 'ROSuperTCPServer';
  with ROSuperTCPServer.Dispatchers.Add as TROMessageDispatcher do
  begin
    Name := 'ROMessage';
    Message := ROMessage;
    Enabled := True;
  end;
  ROSuperTCPServer.ServeRodl := {$IFDEF RELEASE}false{$ELSE}true{$ENDIF};
  ROSuperTCPServer.AckWaitTimeout := 60000;
  ROSuperTCPServer.DefaultResponse := 'ROSC:Invalid connection string';
  ROSuperTCPServer.Server.IOHandler := ROIndyServerSSL;
  ROSuperTCPServer.Server.OnConnect := ROSuperTCPServerOnConnect;
  ROSuperTCPServer.Server.UseNagle := false;

  RONamedPipeServer := TRONamedPipeServer.Create(nil);
  RONamedPipeServer.Name := 'RONamedPipeServer';
  with RONamedPipeServer.Dispatchers.Add as TROMessageDispatcher do
  begin
    Name := 'ROMessage';
    Message := ROMessage;
    Enabled := True;
  end;
  RONamedPipeServer.ServeRodl := {$IFDEF RELEASE}false{$ELSE}true{$ENDIF};
  RONamedPipeServer.ServerID := 'NamedPipeServer';
  RONamedPipeServer.AllowEveryone := True;

  ROIndyHTTPServer := TROIndyHTTPServer.Create(nil);
  ROIndyHTTPServer.Name := 'ROIndyHTTPServer';
  ROIndyHTTPServer.IndyServer.IOHandler := ROIndyServerSSL;
  ROIndyHTTPServer.IndyServer.OnQuerySSLPort := ROIndyHTTPServerOnQuerySSLPort;
  ROIndyHTTPServer.IndyServer.UseNagle := false;
  with ROIndyHTTPServer.Dispatchers.Add as TROHTTPDispatcher do
  begin
    Name := 'ROMessage';
    Message := ROMessage;
    Enabled := True;
    PathInfo := 'Bin';
  end;
  ROIndyHTTPServer.ServeRodl := {$IFDEF RELEASE}false{$ELSE}true{$ENDIF};
  ROIndyHTTPServer.ServeInfoPage := {$IFDEF RELEASE}false{$ELSE}true{$ENDIF};
  ROIndyHTTPServer.SendClientAccessPolicyXml := captAllowAll;
  ROIndyHTTPServer.Port := 8099;
  ROIndyHTTPServer.RequireHTTPAuthentication := false;
  ROIndyHTTPServer.OnHTTPAuthentication := ROIndyHTTPServerOnHTTPAuthentication;

  ROSuperTCPServer.Active := true;
  ROIndyHTTPServer.Active := true;
  RONamedPipeServer.Active := false;//Sys.ServerActivateNP;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if ROSuperTCPServer.Active then
    ROSuperTCPServer.Active := false;
  if RONamedPipeServer.Active then
    RONamedPipeServer.Active := false;
  if ROIndyHTTPServer.Active then
    ROIndyHTTPServer.Active := false;

  if Assigned(ROIndyHTTPServer) then begin  ROIndyHTTPServer.Free; ROIndyHTTPServer := nil; end;
  if Assigned(ROIndyServerSSL) then begin  ROIndyServerSSL.Free; ROIndyServerSSL := nil; end;
  if Assigned(RONamedPipeServer) then begin  RONamedPipeServer.Free; RONamedPipeServer := nil; end;
  if Assigned(ROSuperTCPServer) then begin  ROSuperTCPServer.Free; ROSuperTCPServer := nil; end;
  if Assigned(ROMessage) then begin  ROMessage.Free; ROMessage := nil; end;
  if Assigned(ROAESEncryptionEnvelope) then begin  ROAESEncryptionEnvelope.Free; ROAESEncryptionEnvelope := nil; end;
end;

procedure TForm1.ROIndyHTTPServerOnHTTPAuthentication(const aRequest: IROHTTPRequest; const aUserName,
  aPassword: String; var aHandled: Boolean);
begin
  aHandled := false;
end;

procedure TForm1.ROIndyHTTPServerOnQuerySSLPort(APort: Word; var VUseSSL: Boolean);
begin
  VUseSSL := true;
end;

procedure TForm1.ROIndyServerSSLOnGetPassword(var Password: String);
begin
  Password := TRO.SSL_PASSWORD;
end;

procedure TForm1.ROSuperTCPServerOnConnect(AContext: TIdContext);
begin
  if (AContext.Connection.IOHandler is TIdSSLIOHandlerSocketBase) then
    TIdSSLIOHandlerSocketBase(AContext.Connection.Socket).PassThrough := False;
end;

end.
