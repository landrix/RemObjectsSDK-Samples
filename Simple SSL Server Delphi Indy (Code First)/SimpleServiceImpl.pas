unit SimpleServiceImpl;

{$I RemObjects.inc}

interface

uses
  System.SysUtils, System.Classes, System.TypInfo,
  uROXMLIntf, uROClientIntf, uROClasses, uROTypes, uROServer, uROServerIntf, uROSessions,
  uRORemoteDataModule, uRORTTIAttributes, uRORTTIServerSupport, uROArray;

{$REGION 'brief info for CodeFirst Services'}
  (*
  some useful attributes:
  [ROSkip] - type with this attribute will be skiped at generating RODL for client-side
  [RORole('allow_role')]  - service&service methods only
  [RORole('!deny_role')]  - service&service methods only
  [ROCustom('myname','myvalue')] - custom attributes
  [RODocumentation('documentation')] - documentation
  [ROObsolete] - add "obsolete" message into documentation
  [ROObsolete('custom message')] - add specified message into documentation
  [ROService('name')] - service identificator
  [ROServiceMethod]   - service method identificator
  [ROEventSink]       - event sink identificator

  examples:
  TMyStruct = class(TROComplexType)
  private
    fA: Integer;
  published
    property A :Integer read fA write fA;
  end;

  TMyStructArray = class(TROArray<TMyStruct>);

  [ROEventSink]
  IMyEvents = interface(IROEventSink)
    ['{75F9A466-518A-4B09-9DC4-9272B1EEFD95}']
    procedure OnMyEvent(const aStr: String);
  end;

  simple usage of event sinks:
    //ev: IROEventWriter<IMyEvents>;
    ..
    ev := EventRepository.GetWriter<IMyEvents>(Session.SessionID);
    ev.Event.OnMyEvent('Message');
  *)
{$ENDREGION}

const
  __ServiceName ='SimpleService';

type
  { TSimpleService }
  [ROService(__ServiceName)]
  TSimpleService = class(TRORemotable)
  protected
    [ROServiceMethod]
    procedure Sum(const aA,aB: Integer; out aResult : Integer);
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{ TSimpleService }

procedure TSimpleService.Sum(const aA, aB: Integer; out aResult: Integer);
begin
  aResult := aA + aB;
end;

procedure Create_NewService(out anInstance : IUnknown);
begin
  anInstance := TSimpleService.Create;
end;

var
  fClassFactory: IROClassFactory;
initialization
  fClassFactory := TROClassFactory.Create(__ServiceName, Create_NewService, TRORTTIInvoker);
  //RegisterForZeroConf(fClassFactory, Format('_%s_rosdk._tcp.',[__ServiceName]));
finalization
  UnRegisterClassFactory(fClassFactory);
  fClassFactory := nil;
end.
