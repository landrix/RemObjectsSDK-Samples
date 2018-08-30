unit ServerLogin_Impl;

{$I RemObjects.inc}

interface

uses
  System.SysUtils, System.Classes, System.TypInfo, System.Variants
  ,WinApi.Windows,Winapi.WinSvc, WinApi.Messages
  ,Data.DB,Vcl.Forms
  ,uROTypes,uROServer,uROServerIntf,uRORTTIAttributes,uROComboService
  ,uRORemoteDataModule
  ,RODLTypes
  ;

type
  [ROService('ServiceLogin')]
  TServiceLogin = class(TRORemoteDataModule)
  protected
    [ROServiceMethod]
    [ROCustom('HttpApiPath','login/login')]
    procedure Login(const Username: UnicodeString; const Password: UnicodeString);
    [ROServiceMethod]
    [ROCustom('HttpApiPath','login/logout')]
    procedure Logout(const Username: UnicodeString);
  public
    constructor Create(aOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses
  uRORTTIServerSupport, ServerUnit1;

{ ServiceManagement }

constructor TServiceLogin.Create(aOwner: TComponent);
begin
  inherited;
  SessionManager := ServerForm.ROInMemorySessionManager;
  RequiresSession := false;
end;

procedure TServiceLogin.Login(const Username, Password: UnicodeString);
var
  UserID : Integer;
begin
  //CreateSession;
  //Log('User ''' + UserID + ''' is trying logon with password ''' + Password + '''');
  if (Session.Values['Login'] <> Null) then
  begin
    UserID := Session.Values['UserID'];
    //Log('User ''' + Session.Values['Login'] + ''' is already connected to session ' + GUIDToString(ClientID));
    //Log('Login unsuccessful');
    Exit;
  end;

  //  result := (UserID <> '') and (UserID = Password); // Dummy test... You would code the one specific to your system
  if (Username <> '') and (Username = Password) then
  begin
    UserID := 5;
    Session.Values['Login'] := Username;
    Session.Values['Password'] := Password;
    Session.Values['UserID'] := UserID;
  end else
  begin
    DestroySession; // Wrong login! The session cannot be persisted
  end;
end;

procedure TServiceLogin.Logout(const Username: UnicodeString);
begin
  DestroySession;
end;

initialization

  RegisterCodeFirstService(TServiceLogin);

end.

