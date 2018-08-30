unit ServerUnit1;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ActiveX,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics,Vcl.Controls, Vcl.Forms, Vcl.Dialogs

  ,uROClient, uROServer,uROPoweredByRemObjectsButton, uROClientIntf, uROClasses
  ,uROBaseSuperTCPServer, uROSynapseSuperTCPServer, uROBinMessage,uROAESEncryptionEnvelope
  ,uROSuperTCPServer,uROComboService,uROBaseConnection, uROComponent, uROMessage
  ,uRONamedPipeServer,uRoHTTPDispatch,uRoHTTPTools,uRoSessions,uROHttpApiDispatcher
  ,uROCustomHTTPServer,uROBaseHTTPServer,uROIndyHTTPServer,uROServerIntf
  ,uROHttpApiSimpleAuthenticationManager,uROHttpApiBaseAuthenticationManager

  ,IdBaseComponent, IdComponent, IdTCPServer, IdCustomHTTPServer, IdContext
  ,IdHTTPServer,IdSSLOpenSSL,IdSSL,IdSSLOpenSSLHeaders
  ,IdSocketHandle,IdUDPServer,IdGlobal, Vcl.StdCtrls
  ;

type
  TServerForm = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  public
    ROMessage: TROBinMessage;
    ROSuperTCPServer: TROSuperTCPServer;
    RONamedPipeServer: TRONamedPipeServer;
    ROIndyHTTPServer: TROIndyHTTPServer;
    ROIndyServerSSL: TIdServerIOHandlerSSLOpenSSL;
    ROInMemorySessionManager: TROInMemorySessionManager;
    ROHttpApiDispatcher: TROHttpApiDispatcher;
    ROHttpApiSimpleAuthenticationManager: TROHttpApiSimpleAuthenticationManager;

    procedure ROSuperTCPServerOnConnect(AContext: TIdContext);
    procedure ROIndyHTTPServerOnQuerySSLPort(APort: Word; var VUseSSL: Boolean);
    procedure ROIndyHTTPServerOnHTTPAuthentication (const aRequest: IROHTTPRequest; const aUserName, aPassword: String; var aHandled: Boolean);
    procedure ROIndyHTTPServerSendCrossOriginHeader(var AllowedOrigin: String);
    function  ROIndyServerSSLOnVerifyPeer(Certificate: TIdX509; AOk: Boolean; ADepth, AError: Integer): Boolean;
    procedure ROIndyServerSSLOnGetPassword(var Password : String);
    procedure ROInMemorySessionManager1SessionCreated(const aSession : TROSession);
    procedure ROInMemorySessionManager1SessionDeleted(const aSessionID : TGUID; IsExpired : boolean);
    procedure ROHttpApiSimpleAuthenticationManager1CanWriteMethodSecurity (aServiceName, aMethodName: string; var CanWrite: Boolean);
//  private
//    HttpServer : TIdHTTPServer;
//    procedure IdHTTPServerCommandGet(AContext: TIdContext;ARequestInfo: TIdHTTPRequestInfo;AResponseInfo: TIdHTTPResponseInfo);
  public
    procedure Log(_Message : String; _Exception : Exception = nil);
  end;

var
  ServerForm: TServerForm;

implementation

{$R *.dfm}

procedure TServerForm.FormCreate(Sender: TObject);
begin
  ROMessage := TROBinMessage.Create(nil);
  ROMessage.Name := 'ROMessage';
  ROMessage.UseCompression := false;

  ROIndyHTTPServer := TROIndyHTTPServer.Create(nil);
  ROIndyHTTPServer.Name := 'ROIndyHTTPServer';
  with ROIndyHTTPServer.Dispatchers.Add as TROHTTPDispatcher do
  begin
    Name := 'ROMessage';
    Message := ROMessage;
    Enabled := True;
    PathInfo := 'Bin';
  end;
  ROIndyHTTPServer.SendCrossOriginHeader := true;
  ROIndyHTTPServer.OnSendCrossOriginHeader := ROIndyHTTPServerSendCrossOriginHeader;
  {$IFDEF RELEASE}
  ROIndyHTTPServer.ServeRodl := false;
  ROIndyHTTPServer.ServeInfoPage := false;
  {$ENDIF}
  ROIndyHTTPServer.SendClientAccessPolicyXml := captAllowAll;
  ROIndyHTTPServer.Port := 8099;
  ROIndyHTTPServer.RequireHTTPAuthentication := false;
  ROIndyHTTPServer.OnHTTPAuthentication := ROIndyHTTPServerOnHTTPAuthentication;
  ROHttpApiDispatcher := TROHttpApiDispatcher.Create(nil);
  ROHttpApiDispatcher.Server := ROIndyHTTPServer;
  ROHttpApiDispatcher.ApiHost := 'localhost:8099';
  ROHttpApiDispatcher.Path := '/api';

  ROInMemorySessionManager:= TROInMemorySessionManager.Create(nil);
  ROInMemorySessionManager.OnSessionCreated := ROInMemorySessionManager1SessionCreated;
  ROInMemorySessionManager.OnSessionDeleted := ROInMemorySessionManager1SessionDeleted;

  ROHttpApiSimpleAuthenticationManager:= TROHttpApiSimpleAuthenticationManager.Create(nil);
  ROHttpApiDispatcher.AuthenticationManager := ROHttpApiSimpleAuthenticationManager;
  ROHttpApiSimpleAuthenticationManager.OnCanWriteMethodSecurity := ROHttpApiSimpleAuthenticationManager1CanWriteMethodSecurity;
  ROHttpApiSimpleAuthenticationManager.SecurityMode := smPerMethod;
  ROHttpApiSimpleAuthenticationManager.SessionManager := ROInMemorySessionManager;

//  HttpServer := TIdHTTPServer.Create(nil);
//  HttpServer.DefaultPort := 80;
//  HttpServer.OnCommandGet := IdHTTPServerCommandGet;

//    ROIndyHTTPServer.Port := Sys.ServerHTTPPort;
//    if Sys.ServerHTTPOverSSL then
//    begin
//      ROIndyHTTPServer.IndyServer.IOHandler := ROIndyServerSSL;
//      ROIndyHTTPServer.IndyServer.OnQuerySSLPort := ROIndyHTTPServerOnQuerySSLPort;
//      ROIndyHTTPServer.IndyServer.UseNagle := false;
//    end;
      ROIndyHTTPServer.Active := true;
end;

procedure TServerForm.FormDestroy(Sender: TObject);
begin
  if ROIndyHTTPServer.Active then
    ROIndyHTTPServer.Active := false;

  if Assigned(ROHttpApiSimpleAuthenticationManager) then begin  ROHttpApiSimpleAuthenticationManager.Free; ROHttpApiSimpleAuthenticationManager := nil; end;
  if Assigned(ROHttpApiDispatcher) then begin  ROHttpApiDispatcher.Free; ROHttpApiDispatcher := nil; end;
  if Assigned(ROIndyHTTPServer) then begin  ROIndyHTTPServer.Free; ROIndyHTTPServer := nil; end;
  if Assigned(ROMessage) then begin  ROMessage.Free; ROMessage := nil; end;
  if Assigned(ROInMemorySessionManager) then begin  ROInMemorySessionManager.Free; ROInMemorySessionManager := nil; end;
//  if Assigned(HttpServer) then begin  HttpServer.Free; HttpServer := nil; end;
end;

//procedure TServerForm.IdHTTPServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
//  AResponseInfo: TIdHTTPResponseInfo);
//begin
//end;

procedure TServerForm.Log(_Message: String; _Exception: Exception);
begin
  if _Exception <> nil then
    _Message := _Message+' '+_Exception.ClassName+' '+_Exception.Message;

  Memo1.lines.add(_Message);
end;

procedure TServerForm.ROHttpApiSimpleAuthenticationManager1CanWriteMethodSecurity(
  aServiceName, aMethodName: string; var CanWrite: Boolean);
begin
  CanWrite := not ((aServiceName = 'ServiceLogin') and (aMethodName = 'Login'));
end;

procedure TServerForm.ROIndyHTTPServerOnHTTPAuthentication(const aRequest: IROHTTPRequest;
  const aUserName, aPassword: String; var aHandled: Boolean);
begin
  aHandled := SameText(aUserName,aPassword);
end;

procedure TServerForm.ROIndyHTTPServerOnQuerySSLPort(APort: Word; var VUseSSL: Boolean);
begin
  VUseSSL := true;
end;

procedure TServerForm.ROIndyHTTPServerSendCrossOriginHeader(
  var AllowedOrigin: String);
begin
  AllowedOrigin := '*';
end;

procedure TServerForm.ROIndyServerSSLOnGetPassword(var Password: String);
begin
  //https://stackoverflow.com/questions/8646781/simple-tidhttpserver-example-supporting-ssl
  Password := '';
end;

function TServerForm.ROIndyServerSSLOnVerifyPeer(Certificate: TIdX509; AOk: Boolean; ADepth,
  AError: Integer): Boolean;
begin
  result := true;
end;

procedure TServerForm.ROInMemorySessionManager1SessionCreated(
  const aSession: TROSession);
begin

end;

procedure TServerForm.ROInMemorySessionManager1SessionDeleted(
  const aSessionID: TGUID; IsExpired: boolean);
begin

end;

procedure TServerForm.ROSuperTCPServerOnConnect(AContext: TIdContext);
begin
//  if AContext.Connection.Socket.Binding.Port = fSSLPort then
  if (AContext.Connection.IOHandler is TIdSSLIOHandlerSocketBase) then
    TIdSSLIOHandlerSocketBase(AContext.Connection.Socket).PassThrough := true;
end;

//procedure TServerForm.ROServerCustomResponseEvent(const aTransport: IROHTTPTransport;
//  const aRequestStream, aResponseStream: TStream; const aResponse: IROHTTPResponse; var aHandled: Boolean);
//begin
//end;

end.
