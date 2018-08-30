unit ServerService_Impl;

{$I RemObjects.inc}
interface

uses
  System.SysUtils, System.Classes, System.TypInfo, System.Generics.Collections,
  uROXMLIntf, uROClientIntf, uROClasses, uROTypes, uROServer, uROServerIntf,
  uROSessions, uRORemoteDataModule, uRORTTIAttributes, uRORTTIServerSupport,
  uROArray,uROHttpApiUtils,uROHTTPTools;

{$REGION 'brief info for Code-First Services'}
  (*
  set library name, uid, namespace, documentation:
  uRORTTIServerSupport.RODLLibraryName := 'LibraryName';
  uRORTTIServerSupport.RODLLibraryID := '{2533A58A-49D9-47CC-B77A-FFD791F425BE}';
  uRORTTIServerSupport.RODLLibraryNamespace := 'namespace';
  uRORTTIServerSupport.RODLLibraryDocumentation := 'documentation';

  mandatory identificators for services/methods/event sinks:
  [ROService('name')]
  [ROServiceMethod]
  [ROEventSink]

  other (optional) attributes:
  [RORole('role')]  - allow role (service&service methods only)
  [RORole('!role')] - deny role, (service&service methods only)
  [ROSkip] - for excluding type at generting RODL for clientside
  [ROCustom('myname','myvalue')] - custom attributes
  [RODocumentation('documentation')] - documentation
  [ROObsolete] - add "obsolete" message into documentation
  [ROObsolete('custom message')] - add specified message into documentation
  [ROEnumSoapName(EntityName,SoapEntityName)] - soap mapping. multiple (enums only)

  serialization mode for properties, method parameters and arrays
  [ROSerializeAsAnsiString]
  [ROSerializeAsUTF8String]

  serialization mode for service's functions results
  [ROSerializeResultAsAnsiString]
  [ROSerializeResultAsUTF8String]
*)
{$ENDREGION}
{$REGION 'examples'}
(*
  [ROEnumSoapName('sxFemale','soap_sxFemale')]
  [ROEnumSoapName('sxMale','soap_sxMale')]
  TSex = (
    sxMale,
    sxFemale
  );
  TMyStruct = class(TROComplexType)
  private
    fA: Integer;
  published
    property A :Integer read fA write fA;
    [ROSerializeAsUTF8String]
    property AsUtf8: String read fAsUtf8 write fAsUtf8;
  end;

  TMyStructArray = class(TROArray<TMyStruct>);

  [ROSerializeAsUTF8String]
  TMyOtherArray = class(TROArray<String>);

  [ROEventSink]
  IMyEvents = interface(IROEventSink)
    ['{75F9A466-518A-4B09-9DC4-9272B1EEFD95}']
    procedure OnMyEvent([ROSerializeAsAnsiString] const aStr: String);
  end;

  [ROService('MyService')]
  TMyService = class(TRORemoteDataModule)
  private
  public
    [ROServiceMethod]
    [ROSerializeResultAsAnsiString]
    function Echo([ROSerializeAsAnsiString] const aValue: string):string;
  end;

  simple usage of event sinks:
    //ev: IROEventWriter<IMyEvents>;
    ..
    ev := EventRepository.GetWriter<IMyEvents>(Session.SessionID);
    ev.Event.OnMyEvent('Message');

  for using custom class factories, replace 
-----------
initialization
  RegisterCodeFirstService(TNewService1);
end.
-----------
  with
-----------
procedure Create_NewService1(out anInstance : IUnknown);
begin
  anInstance := TNewService1.Create(nil);
end;

var
  fClassFactory: IROClassFactory;
initialization
  fClassFactory := TROClassFactory.Create(__ServiceName, Create_NewService1, TRORTTIInvoker);
  //RegisterForZeroConf(fClassFactory, Format('_TRORemoteDataModule_rosdk._tcp.',[__ServiceName]));
finalization
  UnRegisterClassFactory(fClassFactory);
  fClassFactory := nil;
end.
-----------
  *)
{$ENDREGION}

type

  [ROService('Service')]
  TService = class(TRORemoteDataModule)
  private
    procedure RORemoteDataModuleCreate(Sender: TObject);
  public
    [ROServiceMethod]
    [ROCustom('HttpApiPath','convert/{value}')]
    function ConvertToString(value: Integer): String;

    [ROServiceMethod]
    [ROCustom('HttpApiPath','calculate')]
    [ROCustom('HttpApiMethod','GET')]
    function Calculate([ROCustom('HttpApiQueryParameter','1')] a: Integer;
                       [ROCustom('HttpApiQueryParameter','1')] b: Integer): TROArray<Integer>;

    [ROServiceMethod]
    [ROCustom('HttpApiPath','cache/{key}')]
    [ROCustom('HttpApiMethod','POST')]
    [ROCustom('HttpApiResult','201')]
    procedure AddToCache(key: String;
                        [ROCustom('HttpApiQueryParameter','1')] value: String);

    [ROServiceMethod]
    [ROCustom('HttpApiPath','cache/{key}')]
    [ROCustom('HttpApiMethod','GET')]
    function ReadFromCache(key: String): String;

    [ROServiceMethod]
    [ROCustom('HttpApiPath','cache/{key}')]
    [ROCustom('HttpApiMethod','PUT')]
    procedure UpdateCache(key: String;
                          [ROCustom('HttpApiQueryParameter','1')] value: String);

    [ROServiceMethod]
    [ROCustom('HttpApiPath','cache/{key}')]
    [ROCustom('HttpApiMethod','DELETE')]
    procedure DeleteFromCache(key: String);
  public
    constructor Create(aOwner : TComponent); override;
  end;

implementation

uses
  ServerUnit1;

const
  HTTP_409_code               = 409;
  HTTP_409_status             = 'Conflict';

var
  _dataCache: TDictionary<String, String>;

{$R *.dfm}

procedure TService.AddToCache(key, value: String);
begin
 if (_dataCache.ContainsKey(key)) then raise EROHttpApiException.Create(HTTP_409_code, HTTP_409_status);
  _dataCache.Add(key, value);
end;

function TService.Calculate(a, b: Integer): TROArray<Integer>;
begin
  Result := TROArray<Integer>.Create;
  Result.Add(a * b);
  // This code line will result in the DivideByZero exception
  // if the b parameter value is not provided or its value is 0
  // Client will receive a generic 500 Internal Server Error response code
  Result.Add(Round(a / b));
  Result.Add(a + b);
  Result.Add(a - b);
end;

function TService.ConvertToString(value: Integer): String;
begin
  Result :=  'The value is ' + IntToStr(value);
end;

constructor TService.Create(aOwner: TComponent);
begin
  inherited;
  SessionManager := ServerForm.ROInMemorySessionManager;
  RequiresSession := true;
end;

procedure TService.DeleteFromCache(key: String);
begin
  if not _dataCache.ContainsKey(key) then raise EROHttpApiException.Create(HTTP_404_code, HTTP_404_status);
  _dataCache.Remove(key);
end;

function TService.ReadFromCache(key: String): String;
begin
  if not _dataCache.ContainsKey(key) then raise EROHttpApiException.Create(HTTP_404_code, HTTP_404_status);
  result := _dataCache[key];
end;

procedure TService.RORemoteDataModuleCreate(Sender: TObject);
begin

end;

procedure TService.UpdateCache(key, value: String);
begin
  if not _dataCache.ContainsKey(key) then raise EROHttpApiException.Create(HTTP_404_code, HTTP_404_status);
  _dataCache[key] := value;
end;

initialization
  RegisterCodeFirstService(TService);
  _dataCache:= TDictionary<String, String>.Create;
finalization
  _dataCache.Free;
end.
