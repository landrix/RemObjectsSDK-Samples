unit SimpleSSLClientTCPDelphiIndyUnit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Vcl.StdCtrls
  ,uROClient, uROClientIntf, uRORemoteService, uROBinMessage, uROSuperTCPChannel
  ,uROChannelAwareComponent, uROBaseConnection, uROTransportChannel,uROAESEncryptionEnvelope
  ,uROBaseActiveEventChannel, uROBaseSuperChannel, uROBaseSuperTCPChannel
  ,uROComponent, uROMessage, uRONamedPipeChannel
  ,IdSSLOpenSSL
  ,SimpleService_Intf;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  public
    ROMessage: TROBinMessage;
    ROChannel: TROSuperTCPChannel;
    RORemoteService: TRORemoteService;
    ROAESEncryptionEnvelope: TROAESEncryptionEnvelope;
    ROSSL: TIdSSLIOHandlerSocketOpenSSL;
  end;

  TRO = class
  public
    const AES_PASSWORD = 'mypwd';
    //const SSL_PASSWORD = 'mypwdssl';
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  result : Integer;
begin
  (RORemoteService as ISimpleService).Sum(1,3,result);
  Label1.Caption := result.ToString;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  RORemoteService := TRORemoteService.Create(nil);
  RORemoteService.Name := 'RORemoteService';

  ROSSL:= TIdSSLIOHandlerSocketOpenSSL.Create(nil);
//  ROIndyServerSSL.SSLOptions.SSLVersions := [sslvSSLv2,sslvSSLv3,sslvTLSv1,sslvTLSv1_1,sslvTLSv1_2];
  ROSSL.SSLOptions.Method := sslvSSLv23;//sslvTLSv1_2;// sslvSSLv23;
  ROSSL.SSLOptions.Mode := sslmClient;
  ROSSL.SSLOptions.VerifyDepth := 0;
  ROSSL.SSLOptions.VerifyMode := [];// [sslvrfPeer,sslvrfFailIfNoPeerCert,sslvrfClientOnce];

  ROChannel := TROSuperTCPChannel.Create(nil);
  ROChannel.Name := 'ROChannel';
  ROChannel.DispatchOptions := [];
  ROChannel.AutoReconnect := false;
  ROChannel.ConnectTimeout := 70000;
  ROChannel.TargetUrl := 'supertcp://localhost:8095';
  ROChannel.Host := 'localhost';
  ROChannel.Client.UseNagle := false; //ssl
  ROChannel.Client.IOHandler := ROSSL;

  RORemoteService.Channel := ROChannel;

  ROAESEncryptionEnvelope := TROAESEncryptionEnvelope.Create(nil);
  ROAESEncryptionEnvelope.Name := 'ROAESEncryptionEnvelope';
  ROAESEncryptionEnvelope.EnvelopeMarker := 'AES';
  ROAESEncryptionEnvelope.Password := TRO.AES_PASSWORD;
  ROMessage := TROBinMessage.Create(nil);
  with TROMessageEnvelopeItem(ROMessage.Envelopes.Add) do begin Envelope := ROAESEncryptionEnvelope; Enabled := true; end;

  RORemoteService.Message := ROMessage;
  ROMessage.Name := 'ROMessage';
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(ROChannel) then if ROChannel.Active then ROChannel.Active := false;
  if Assigned(ROMessage) then begin  ROMessage.Free; ROMessage := nil; end;
  if Assigned(ROAESEncryptionEnvelope) then begin  ROAESEncryptionEnvelope.Free; ROAESEncryptionEnvelope := nil; end;
  if Assigned(ROChannel) then begin  ROChannel.Free; ROChannel := nil; end;
  if Assigned(RORemoteService) then begin  RORemoteService.Free; RORemoteService := nil; end;
  if Assigned(ROSSL) then begin  ROSSL.Free; ROSSL := nil; end;
end;

end.
