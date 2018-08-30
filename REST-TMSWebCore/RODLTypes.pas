unit RODLTypes;

interface

uses
  System.Classes,
  uRORTTIAttributes, uRORTTIServerSupport,
  uROClientIntf, uROXMLIntf, uROExceptions, uROTypes, uROArray, uROEventRepository;

const
  LibraryName = 'ServerLibrary';
  LibraryUID = '{A5ABA5DC-C95D-4B35-AAB1-B5A801EB56BF}';

type
  {$REGION 'forward declarations'}
  IndexDocStruc = class;
  ErrorStruct = class;
  DBDocStruct = class;
  FileInfoStruc = class;
  SQLParamStruct = class;
  ContainerFiledataStruct = class;
  ContainerFileinfoStruct = class;
  ContainerFiletagStruct = class;

  DBDocArray = class;
  DBDocArrayArray = class;
  IndexDocArray = class;
  IntegerArray = class;
  SQLParamArray = class;
  SQLParamArrayArray = class;
  ContainerFiledataArray = class;
  ContainerFileinfoArray = class;
  ContainerFiletagArray = class;
  WideStringArray = class;
  {$ENDREGION}

  {$REGION 'structs'}
  IndexDocStruc = class(TROComplexType)
  private
    fRecType: Integer;
    fRecValue: UnicodeString;
  published
    property RecType: Integer read fRecType write fRecType;
    property RecValue: UnicodeString read fRecValue write fRecValue;
  end;

  IndexDocStrucCollection = class(TROCollection<IndexDocStruc>);

  ErrorStruct = class(TROComplexType)
  private
    fNr: Integer;
    fDescription: UnicodeString;
  published
    property Nr: Integer read fNr write fNr;
    property Description: UnicodeString read fDescription write fDescription;
  end;

  ErrorStructCollection = class(TROCollection<ErrorStruct>);

  [RODocumentation('Einzelner Spaltenwert einer Tabelle')]
  DBDocStruct = class(TROComplexType)
  private
    fField: UnicodeString;
    fVal: UnicodeString;
  published
    property Field: UnicodeString read fField write fField;
    property Val: UnicodeString read fVal write fVal;
  end;

  DBDocStructCollection = class(TROCollection<DBDocStruct>);

  FileInfoStruc = class(TROComplexType)
  private
    fFilename: UnicodeString;
    fFilesize: Int64;
    fCRCValue: UnicodeString;
  published
    property Filename: UnicodeString read fFilename write fFilename;
    property Filesize: Int64 read fFilesize write fFilesize;
    property CRCValue: UnicodeString read fCRCValue write fCRCValue;
  end;

  FileInfoStrucCollection = class(TROCollection<FileInfoStruc>);

  SQLParamStruct = class(TROComplexType)
  private
    fParam: UnicodeString;
    fFieldType: Integer;
    fValue: UnicodeString;
  published
    property Param: UnicodeString read fParam write fParam;
    property FieldType: Integer read fFieldType write fFieldType;
    property Value: UnicodeString read fValue write fValue;
  end;

  SQLParamStructCollection = class(TROCollection<SQLParamStruct>);

  ContainerFiledataStruct = class(TROComplexType)
  private
    fUID: Integer;
    fGUID: UnicodeString;
    fSHA256: UnicodeString;
    fVersion: Integer;
    fCreationTimestamp: UnicodeString;
    fCreatedBy: Integer;
    fCompressed : Integer;
  published
    property UID: Integer read fUID write fUID;
    property GUID: UnicodeString read fGUID write fGUID;
    property SHA256: UnicodeString read fSHA256 write fSHA256;
    property Version: Integer read fVersion write fVersion;
    property CreationTimestamp: UnicodeString read fCreationTimestamp write fCreationTimestamp;
    property CreatedBy: Integer read fCreatedBy write fCreatedBy;
    property Compressed: Integer read fCompressed write fCompressed;
  end;

  ContainerFiledataCollection = class(TROCollection<ContainerFiledataStruct>);

  ContainerFileinfoStruct = class(TROComplexType)
  private
    fUID: Integer;
    fType: Integer;
    fUIDFiledataTopRef: Integer;
    fSubNr: UnicodeString;
    fDeleted: UnicodeString;
    fDescription: UnicodeString;
  published
    property UID: Integer read fUID write fUID;
    property Type_: Integer read fType write fType;
    property UIDFiledataTopRef: Integer read fUIDFiledataTopRef write fUIDFiledataTopRef;
    property SubNr : UnicodeString read fSubNr write fSubNr;
    property Deleted : UnicodeString read fDeleted write fDeleted;
    property Description : UnicodeString read fDescription write fDescription;
  end;

  ContainerFileinfoStructCollection = class(TROCollection<ContainerFileinfoStruct>);

  ContainerFiletagStruct = class(TROComplexType)
  private
    fUID: Integer;
    fType: Integer;
    fUIDFileinfoRef: Integer;
    fUIDFiledataRef: Integer;
    fDescription: UnicodeString;
  published
    property UID: Integer read fUID write fUID;
    property Type_: Integer read fType write fType;
    property UIDFileinfoRef: Integer read fUIDFileinfoRef write fUIDFileinfoRef;
    property UIDFiledataRef: Integer read fUIDFiledataRef write fUIDFiledataRef;
    property Description : UnicodeString read fDescription write fDescription;
  end;

  ContainerFiletagStructCollection = class(TROCollection<ContainerFiletagStruct>);
  {$ENDREGION}

  {$REGION 'arrays'}
  DBDocArray = class(TROArray<DBDocStruct>);

  DBDocArrayArray = class(TROArray<DBDocArray>);

  FileInfoArray = class(TROArray<FileInfoStruc>);

  IndexDocArray = class(TROArray<IndexDocStruc>);

  IntegerArray = class(TROArray<Integer>);

  SQLParamArray = class(TROArray<SQLParamStruct>);

  SQLParamArrayArray = class(TROArray<SQLParamArray>);

  ContainerFiledataArray = class(TROArray<ContainerFiledataStruct>);

  ContainerFileinfoArray = class(TROArray<ContainerFileinfoStruct>);

  ContainerFiletagArray = class(TROArray<ContainerFiletagStruct>);

  WideStringArray = class(TROArray<UnicodeString>);
  {$ENDREGION}

implementation

initialization
  uRORTTIServerSupport.RODLLibraryName := LibraryName;
  uRORTTIServerSupport.RODLLibraryID := LibraryUID;
end.
