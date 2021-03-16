{******************************************}
{                                          }
{             FastReport v5.0              }
{         Zeos enduser components          }
{                                          }
{           Created by Dfox                }
{                                          }
{******************************************}

unit frxZEOSComponents;

interface

{$I frx.inc}

uses
  Windows, Classes, frxClass, frxCustomDB, Graphics, SysUtils, DB, ZDataset,
  ZAbstractRODataset, ZAbstractDataset, ZConnection
{$IFDEF Delphi6}
  ,Variants
{$ENDIF}

{$IFDEF QBUILDER}
  ,fqbClass
{$ENDIF};


type
  TfrxZEOSComponents = class(TfrxDBComponents)
  private
    FDefaultDatabase: TZConnection;
    FOldComponents: TfrxZEOSComponents;
    procedure SetDefaultDatabase(const Value: TZConnection);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDescription: String; override;
  published
    property DefaultDatabase: TZConnection read FDefaultDatabase write SetDefaultDatabase;
  end;

  TfrxZEOSDatabase = class(TfrxCustomDatabase)
  private
    FDatabase: TZConnection;
    procedure SetHost(const Value : string);
    function GetHost : string;
    procedure SetProtocol(const Value : String);
    function GetProtocol : string;
    procedure SetPort(const Value : Integer);
    function GetPort : Integer;
  protected
    procedure SetConnected(Value: Boolean); override;
    procedure SetDatabaseName(const Value: String); override;
    procedure SetLoginPrompt(Value: Boolean); override;
    procedure SetParams(Value: TStrings); override;
    function GetConnected: Boolean; override;
    function GetDatabaseName: String; override;
    function GetLoginPrompt: Boolean; override;
    function GetParams: TStrings; override;
    procedure SetUser(Value : string);
    procedure SetPass(Value : string);
    function GetUser : string;
    function GetPass : string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    function ToString: WideString; override;
    procedure FromString(const Connection: WideString); override;
    procedure SetLogin(const Login, Password: String); override;
    property Database: TZConnection read FDatabase;
  published
    property Protocol: string read GetProtocol write SetProtocol;
    property Port: Integer read GetPort write SetPort;
    property Hostname: string read GetHost write SetHost;
    property DatabaseName;
    property LoginPrompt;
    property Username: string read GetUser write SetUser;
    property Password: string read GetPass write SetPass;
    property Params;
    property Connected;
  end;

  TfrxZEOSTable = class(TfrxCustomTable)
  private
    FDatabase: TfrxZEOSDatabase;
    FTable: TZTable;
    procedure SetDatabase(const Value: TfrxZEOSDatabase);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetMaster(const Value: TDataSource); override;
    procedure SetMasterFields(const Value: String); override;
    procedure SetIndexFieldNames(const Value: String); override;
    procedure SetTableName(const Value: String); override;
    function GetIndexFieldNames: String; override;
    function GetTableName: String; override;
  public
    constructor Create(AOwner: TComponent); override;
    constructor DesignCreate(AOwner: TComponent; Flags: Word); override;
    class function GetDescription: String; override;
    procedure BeforeStartReport; override;
    property Table: TZTable read FTable;
  published
    property Database: TfrxZEOSDatabase read FDatabase write SetDatabase;
  end;

  TfrxZEOSQuery = class(TfrxCustomQuery)
  private
    FDatabase: TfrxZEOSDatabase;
    FQuery: TZQuery;
    procedure SetDatabase(const Value: TfrxZEOSDatabase);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetMaster(const Value: TDataSource); override;
    procedure SetSQL(Value: TStrings); override;
    function GetSQL: TStrings; override;
  public
    constructor Create(AOwner: TComponent); override;
    constructor DesignCreate(AOwner: TComponent; Flags: Word); override;
    class function GetDescription: String; override;
    procedure BeforeStartReport; override;
    procedure UpdateParams; override;
{$IFDEF QBUILDER}
    function QBEngine: TfqbEngine; override;
{$ENDIF}
    property Query: TZQuery read FQuery;
  published
    property Database: TfrxZEOSDatabase read FDatabase write SetDatabase;

  end;

{$IFDEF QBUILDER}
  TfrxEngineZEOS = class(TfqbEngine)
  private
    FQuery: TZQuery;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ReadTableList(ATableList: TStrings); override;
    procedure ReadFieldList(const ATableName: string; var AFieldList: TfqbFieldList); override;
    function ResultDataSet: TDataSet; override;
    procedure SetSQL(const Value: string); override;
  end;
{$ENDIF}


var
  ZEOSComponents: TfrxZEOSComponents;

{$R *.res}

implementation

uses 
  frxZEOSRTTI,
{$IFNDEF NO_EDITORS}
  frxZEOSEditor,
{$ENDIF}
  frxDsgnIntf,
  frxRes;

{ TfrxZEOSComponents }

constructor TfrxZEOSComponents.Create(AOwner: TComponent);
begin
  inherited;
  FOldComponents := ZEOSComponents;
  ZEOSComponents := Self;
end;

destructor TfrxZEOSComponents.Destroy;
begin
  if ZEOSComponents = Self then
    ZEOSComponents := FOldComponents;
  inherited;
end;

function TfrxZEOSComponents.GetDescription: String;
begin
  Result := 'ZEOS';
end;

procedure TfrxZEOSComponents.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = FDefaultDatabase) and (Operation = opRemove) then
    FDefaultDatabase := nil;
end;


procedure TfrxZEOSComponents.SetDefaultDatabase(const Value: TZConnection);
begin
  if (Value <> nil) then
    Value.FreeNotification(Self);

  if FDefaultDatabase <> nil then
      FDefaultDatabase.RemoveFreeNotification(Self);

  FDefaultDatabase := Value;
end;

{ TfrxZEOSDatabase }

constructor TfrxZEOSDatabase.Create(AOwner: TComponent);
begin
  inherited;
  FDatabase := TZConnection.Create(nil);
  Component := FDatabase;
end;

destructor TfrxZEOSDatabase.Destroy;
begin
  inherited;
end;

class function TfrxZEOSDatabase.GetDescription: String;
begin
  Result := 'ZEOS Database';
end;

function TfrxZEOSDatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

function TfrxZEOSDatabase.GetDatabaseName: String;
begin
  Result := FDatabase.Database;
end;

function TfrxZEOSDatabase.GetHost: String;
begin
  Result := FDatabase.HostName;
end;

procedure TfrxZEOSDatabase.SetHost(const Value : string);
begin
  FDatabase.HostName := Value;
end;

function TfrxZEOSDatabase.GetProtocol : string;
begin
  Result := FDatabase.Protocol;
end;

procedure TfrxZEOSDatabase.SetProtocol(const Value : String);
begin
  FDatabase.Protocol := Value;
end;

function TfrxZEOSDatabase.GetPort : Integer;
begin
  Result := FDatabase.Port;
end;

procedure TfrxZEOSDatabase.SetPort(const Value : Integer);
begin
  FDatabase.Port := Value;
end;

function TfrxZEOSDatabase.GetUser : string;
begin
  Result := FDatabase.User;
end;

procedure TfrxZEOSDatabase.SetUser(Value : string);
begin
  FDatabase.User := Value;
end;

function TfrxZEOSDatabase.GetPass: String;
begin
  Result := FDatabase.Password;
end;

procedure TfrxZEOSDatabase.SetPass(Value : string);
begin
  FDatabase.Password := Value;
end;

function TfrxZEOSDatabase.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

function TfrxZEOSDatabase.GetParams: TStrings;
begin
  Result := FDatabase.Properties;
end;

procedure TfrxZEOSDatabase.SetConnected(Value: Boolean);
begin
  BeforeConnect(Value);
  FDatabase.Connected := Value;
end;

procedure TfrxZEOSDatabase.SetDatabaseName(const Value: String);
begin
  FDatabase.Database := Value;
end;

procedure TfrxZEOSDatabase.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

procedure TfrxZEOSDatabase.SetParams(Value: TStrings);
begin
  FDatabase.Properties := Value;
end;

procedure TfrxZEOSDatabase.SetLogin(const Login, Password: String);
begin
  FDatabase.User := Login;
  FDatabase.Password := Password;
end;

procedure TfrxZEOSDatabase.FromString(const Connection: WideString);
var
  i: Integer;
  s, v: String;
  mode: Integer;

  procedure SetParam(const ParamName: String; const ParamValue: String);
  var
    List: TStringList;
{$IFNDEF Delphi6}
    i, j: Integer;
    s: String;
{$ENDIF}
  begin
    if ParamName = 'DBName' then
      FDatabase.Database := ParamValue
    else if ParamName = 'DBParams' then
    begin
      List := TStringList.Create;
      try
{$IFDEF Delphi6}
        List.Delimiter := ';';
        List.DelimitedText := ParamValue;
{$ELSE}
        i := 1;
        j := 1;
        while i <= Length(ParamValue) do
        begin
          if ParamValue[i] = ';' then
          begin
            s := Copy(ParamValue, j, i - j);
            List.Add(s);
            j := i + 1;
          end;
          Inc(i);
        end;
        s := Copy(ParamValue, j, i - j);
        List.Add(s);
{$ENDIF}
        FDatabase.Properties.Text := List.Text;
      finally
        List.Free;
      end;
    end
    else if ParamName = 'HostName' then
      FDatabase.HostName := ParamValue
    else if ParamName = 'Protocol' then
      FDatabase.Protocol := ParamValue;
  end;

begin
  s := '';
  v := '';
  mode := 0;
  for i := 1 to Length(Connection) do
    if (Connection[i] = '=') and (mode = 0) then
      Inc(mode)
    else if (Connection[i] = '"') and (mode = 1) then
      Inc(mode)
    else if (Connection[i] = '"') and (mode = 2) then
      Dec(mode)
    else if (Connection[i] = ';') and (mode = 1) then
    begin
      Dec(mode);
      SetParam(s, v);
      s := '';
      v := '';
    end
    else if mode = 2 then
      v := v + Connection[i]
    else if mode = 0 then
      s := s + Connection[i];
end;

function TfrxZEOSDatabase.ToString: WideString;
var
  List: TStringList;
{$IFNDEF Delphi6}
  i, nCount: Integer;
{$ENDIF}
begin
  if FDatabase.Database <> '' then
    Result := 'DBName="' + FDatabase.Database + '";';
  if FDatabase.Properties.Count <> 0 then
  begin
    List := TStringList.Create;
    try
      List.Assign(FDatabase.Properties);
{$IFDEF Delphi6}
      List.Delimiter := ';';
      Result := Result + 'DBParams="' + List.DelimitedText + '";';
{$ELSE}
      Result := Result + 'DBParams="';
      nCount := List.Count - 1;
      for i := 0 to nCount  do
      begin
        Result := Result + List[i];
        if nCount > i then
          Result := Result + ';';
      end;
      Result := Result + '";';
{$ENDIF}
    finally
      List.Free;
    end;
  end;
  if FDatabase.Protocol <> '' then
    Result := Result + 'Protocol="' + FDatabase.Protocol + '";';
  if FDatabase.HostName <> '' then
    Result := Result + 'HostName="' + FDatabase.HostName + '";';
end;

{ TfrxZEOSTable }

constructor TfrxZEOSTable.Create(AOwner: TComponent);
begin
  FTable := TZTable.Create(nil);
  DataSet := FTable;
  inherited;
end;

constructor TfrxZEOSTable.DesignCreate(AOwner: TComponent; Flags: Word);
var
  i: Integer;
  l: TList;
begin
  inherited;
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
    if TObject(l[i]) is TfrxZEOSDatabase then
    begin
      SetDatabase(TfrxZEOSDatabase(l[i]));
      break;
    end;
end;
	
class function TfrxZEOSTable.GetDescription: String;
begin
  Result := 'ZEOS Table';
end;

procedure TfrxZEOSTable.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    SetDatabase(nil);
end;

procedure TfrxZEOSTable.SetDatabase(const Value: TfrxZEOSDatabase);
begin
  FDatabase := Value;
  if Value <> nil then
    FTable.Connection := Value.Database
  else if ZEOSComponents <> nil then
    FTable.Connection := ZEOSComponents.DefaultDatabase
  else
    FTable.Connection := nil;
  if FTable.Connection = nil then
     DBConnected := False
  else begin
     try
        FTable.Connection.Connect;
        DBConnected := True;
     except
        on Exception do begin
           DBConnected := False;
        end;
     end;
  end;
end;

function TfrxZEOSTable.GetIndexFieldNames: String;
begin
  Result := FTable.IndexFieldNames;
end;

function TfrxZEOSTable.GetTableName: String;
begin
  Result := FTable.TableName;
end;

procedure TfrxZEOSTable.SetIndexFieldNames(const Value: String);
begin
  FTable.IndexFieldNames := Value;
end;

procedure TfrxZEOSTable.SetTableName(const Value: String);
begin
  FTable.TableName := Value;
end;

procedure TfrxZEOSTable.SetMaster(const Value: TDataSource);
begin
  FTable.MasterSource := Value;
end;

procedure TfrxZEOSTable.SetMasterFields(const Value: String);
begin
  FTable.MasterFields := Value;
end;

procedure TfrxZEOSTable.BeforeStartReport;
begin
  SetDatabase(FDatabase);
end;


{ TfrxZEOSQuery }

constructor TfrxZEOSQuery.Create(AOwner: TComponent);
begin
  FQuery := TZQuery.Create(nil);
  Dataset := FQuery;
  SetDatabase(nil);
  inherited;
end;

constructor TfrxZEOSQuery.DesignCreate(AOwner: TComponent; Flags: Word);
var
  i: Integer;
  l: TList;
begin
  inherited;
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
    if TObject(l[i]) is TfrxZEOSDatabase then
    begin
      SetDatabase(TfrxZEOSDatabase(l[i]));
      break;
    end;
end;

class function TfrxZEOSQuery.GetDescription: String;
begin
  Result := 'ZEOS Query';
end;

procedure TfrxZEOSQuery.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    SetDatabase(nil);
end;

procedure TfrxZEOSQuery.SetDatabase(const Value: TfrxZEOSDatabase);
begin
  FDatabase := Value;
  if Value <> nil then
    FQuery.Connection := Value.FDatabase
  else if ZEOSComponents <> nil then
    FQuery.Connection := ZEOSComponents.DefaultDatabase
  else
    FQuery.Connection := nil;

  DBConnected := FQuery.Connection <> nil;
end;

procedure TfrxZEOSQuery.SetMaster(const Value: TDataSource);
begin
  FQuery.DataSource := Value;
end;

function TfrxZEOSQuery.GetSQL: TStrings;
begin
  Result := FQuery.SQL;
end;

procedure TfrxZEOSQuery.SetSQL(Value: TStrings);
begin
  FQuery.SQL := Value;
end;

procedure TfrxZEOSQuery.UpdateParams;
begin
  frxParamsToTParams(Self, FQuery.Params);
end;

procedure TfrxZEOSQuery.BeforeStartReport;
begin
  SetDatabase(FDatabase);
end;

{$IFDEF QBUILDER}
function TfrxZEOSQuery.QBEngine: TfqbEngine;
begin
  Result := TfrxEngineZEOS.Create(nil);
  TfrxEngineZEOS(Result).FQuery.Connection := FQuery.Connection;
end;
{$ENDIF}


{$IFDEF QBUILDER}
constructor TfrxEngineZEOS.Create(AOwner: TComponent);
begin
  inherited;
  FQuery := TZQuery.Create(Self);
end;

destructor TfrxEngineZEOS.Destroy;
begin
  FQuery.Free;
  inherited;
end;

procedure TfrxEngineZEOS.ReadFieldList(const ATableName: string;
  var AFieldList: TfqbFieldList);
var
  TempTable: TZTable;
  Fields: TFieldDefs;
  i: Integer;
  tmpField: TfqbField;
begin
  AFieldList.Clear;
  TempTable := TZTable.Create(Self);
  TempTable.Connection := FQuery.Connection;
  TempTable.TableName := ATableName;
  Fields := TempTable.FieldDefs;
  try
    try
      TempTable.Active := True;
      tmpField:= TfqbField(AFieldList.Add);
      tmpField.FieldName := '*';
      for i := 0 to Fields.Count - 1 do
      begin
        tmpField := TfqbField(AFieldList.Add);
        tmpField.FieldName := Fields.Items[i].Name;
        tmpField.FieldType := Ord(Fields.Items[i].DataType)
      end;
    except
    end;
  finally
    TempTable.Free;
  end;
end;

procedure TfrxEngineZEOS.ReadTableList(ATableList: TStrings);
begin
  ATableList.Clear;
  FQuery.Connection.GetTableNames('', ATableList);
end;

function TfrxEngineZEOS.ResultDataSet: TDataSet;
begin
  Result := FQuery;
end;

procedure TfrxEngineZEOS.SetSQL(const Value: string);
begin
  FQuery.SQL.Text := Value;
end;
{$ENDIF}

var
  ZDBQ, ZTAB, ZQUE: TBitmap;

initialization
  ZDBQ := TBitmap.Create; ZDBQ.LoadFromResourceName(hInstance, 'TfrxZEOSDataBase');
  ZTAB := TBitmap.Create; ZTAB.LoadFromResourceName(hInstance, 'TfrxZEOSTable');
  ZQUE := TBitmap.Create; ZQUE.LoadFromResourceName(hInstance, 'TfrxZEOSQuery');
  frxObjects.RegisterObject1(TfrxZEOSDataBase, ZDBQ, '', {$IFDEF DB_CAT}'DATABASES'{$ELSE}''{$ENDIF}, 0);
  frxObjects.RegisterObject1(TfrxZEOSTable, ZTAB, '', {$IFDEF DB_CAT}'TABLES'{$ELSE}''{$ENDIF}, 0);
  frxObjects.RegisterObject1(TfrxZEOSQuery, ZQUE, '', {$IFDEF DB_CAT}'QUERIES'{$ELSE}''{$ENDIF}, 0);

finalization
  frxObjects.UnRegister(TfrxZEOSDatabase);
  frxObjects.UnRegister(TfrxZEOSTable);
  frxObjects.UnRegister(TfrxZEOSQuery);
end.