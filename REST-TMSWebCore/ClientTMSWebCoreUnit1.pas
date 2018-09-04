unit ClientTMSWebCoreUnit1;

interface

uses
  System.SysUtils, System.Classes, WEBLib.Graphics, WEBLib.Controls, WEBLib.Forms, WEBLib.Dialogs,
  Vcl.Controls, WEBLib.Login, WEBLib.REST, Vcl.StdCtrls, WEBLib.StdCtrls, web;

type
  TForm1 = class(TWebForm)
    WebLoginPanel1: TWebLoginPanel;
    WebLabel1: TWebLabel;
    WebLabel2: TWebLabel;
    WebLabel3: TWebLabel;
    WebLabel4: TWebLabel;
    WebSpinEdit1: TWebSpinEdit;
    WebSpinEdit2: TWebSpinEdit;
    WebButton1: TWebButton;
    WebMemo1: TWebMemo;
    WebRESTClient1: TWebRESTClient;
    WebHttpRequest1: TWebHttpRequest;
    procedure WebButton1Click(Sender: TObject);
    procedure WebRESTClient1Response(Sender: TObject; AResponse: string);
    procedure WebFormCreate(Sender: TObject);
    procedure WebLoginPanel1Click(Sender: TObject);
    procedure WebHttpRequest1RequestResponse(Sender: TObject;
      ARequest: TJSXMLHttpRequest; AResponse: string);
  end;

var
  Form1: TForm1;

  //curl -v -X POST "http://localhost:8099/api/login/login" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"Password\": \"test\", \"Username\": \"test\"}"
  //http://localhost:8099/api/login/login
  //accept-encoding: gzip, identity
  //access-control-allow-origin: http://localhost:8000
  //access-token: {D797A2FD-C52F-4643-B75E-26778B5193D4}
  //cache-control: no-cache
  //content-length: 0
  //content-type: application/json; charset=utf-8
  //date: Thu, 30 Aug 2018 13:17:59 GMT
  //etag: W/"0-0"
  //expires: -1
  //server: nginx
  //status: 200, 200 OK
  //x-powered-by: Express, Phusion Passenger 5.0.22

  //replace Access-Token from login above
  //http://localhost:8099/api/calculate?a=1&b=1
  //curl -v -X GET "http://localhost:8099/api/calculate?a=1&b=1" -H "accept: application/json" -H "Access-Token: {D797A2FD-C52F-4643-B75E-26778B5193D4}"

implementation

{$R *.dfm}

procedure TForm1.WebFormCreate(Sender: TObject);
begin
  WebHttpRequest1.Headers.Clear; //Remove Cache-Control=no-cache
  WebLoginPanel1.User := 'test';
  WebLoginPanel1.Password := 'test';
end;

procedure TForm1.WebHttpRequest1RequestResponse(Sender: TObject;
  ARequest: TJSXMLHttpRequest; AResponse: string);
begin
  WebMemo1.Lines.Add(AResponse);
  WebMemo1.Lines.Add(ARequest.ResponseHeaders['Access-Token']);
end;

procedure TForm1.WebLoginPanel1Click(Sender: TObject);
var
  postData : String;
begin
  postData := '{ "Password": "'+WebLoginPanel1.Password+'", "Username": "'+WebLoginPanel1.User+'" }';

  WebHttpRequest1.Command := httpPOST;
  WebHttpRequest1.Headers.AddPair('Content-Type','application/json');
  WebHttpRequest1.Headers.AddPair('Accept','application/json');
  WebHttpRequest1.URL := 'http://localhost:8099/api/login/login';
  WebHttpRequest1.PostData := '{"Password": "test","Username": "test"}';
  WebHttpRequest1.Execute;


  //WebRESTClient1.HttpsPost('http://localhost:8099/api/login/login',postData);
end;

procedure TForm1.WebButton1Click(Sender: TObject);
begin
  //WebHttpRequest1.URL := 'http://localhost:8099/api/calculate?a=1&b=4';
  //WebHttpRequest1.Execute;

  WebRESTClient1.HttpsGet('http://localhost:8099/api/calculate?a=1&b=4');
end;

procedure TForm1.WebRESTClient1Response(Sender: TObject; AResponse: string);
begin
  WebMemo1.Lines.Add(AResponse);
end;

end.