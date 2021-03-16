{******************************************}
{                                          }
{             FastReport v5.0              }
{         Zeos enduser components          }
{                                          }
{           Created by Dfox                }
{                                          }
{******************************************}

unit frxZEOSEditor;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, SysUtils, Forms, Dialogs, Types, ZConnection, ZDbcIntfs,
  ZAbstractDataset, ZAbstractRODataset, ZDataset, ZClasses, frxZEOSComponents,
  frxCustomDB, frxDsgnIntf, frxRes, ADODB, ADOInt, frxConnWizard
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxDatabaseNameProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    function Edit: Boolean; override;
    function GetValue: string; override;
    procedure GetValues; override;
    procedure SetValue(const Value: string); override;

  end;

  {** Implements a property editor for ZConnection.Protocol property. }
  TfrxZEOSProtocolProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    function GetValue: string; override;
    procedure GetValues; override;
    procedure SetValue(const Value: string); override;
  end;


  TfrxDatabaseProperty = class(TfrxComponentProperty)
  public
    function GetValue: String; override;
  end;

  TfrxTableNameProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
    procedure SetValue(const Value: String); override;
  end;

  TfrxIndexNameProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
  end;


{ TfrxDatabaseNameProperty }

function TfrxDatabaseNameProperty.GetAttributes: TfrxPropertyAttributes;
begin
  if (TfrxZEOSDatabase(Component).Protocol = 'mssql') or (TfrxZEOSDatabase(Component).Protocol = 'sybase') or (Copy(TfrxZEOSDatabase(Component).Protocol,1,5) = 'mysql') then
     Result := [paMultiSelect, paValueList, paSortList]
  else
     Result := [paDialog];
end;

function TfrxDatabaseNameProperty.GetValue: string;
begin
  Result := GetStrValue;
end;

procedure TfrxDatabaseNameProperty.SetValue(const Value: string);
begin
  SetStrValue(Value);
  TfrxZEOSDatabase(Component).Connected := False;
end;


procedure TfrxDatabaseNameProperty.GetValues;
var
  DbcConnection: IZConnection;
  Url: string;
begin
  try
    if TfrxZEOSDatabase(Component).Port = 0 then
      Url := Format('zdbc:%s://%s/%s?UID=%s;PWD=%s', [
        TfrxZEOSDatabase(Component).Protocol,
        TfrxZEOSDatabase(Component).HostName,
        '',
        TfrxZEOSDatabase(Component).UserName,
        TfrxZEOSDatabase(Component).Password])
    else
      Url := Format('zdbc:%s://%s:%d/%s?UID=%s;PWD=%s', [
        TfrxZEOSDatabase(Component).Protocol,
        TfrxZEOSDatabase(Component).HostName,
        TfrxZEOSDatabase(Component).Port,
        '',
        TfrxZEOSDatabase(Component).UserName,
        TfrxZEOSDatabase(Component).Password]);
    try
      DbcConnection := DriverManager.GetConnectionWithParams(Url,
        TfrxZEOSDatabase(Component).Params);

      with DbcConnection.GetMetadata.GetCatalogs do
      try
        while Next do
          Values.Append(GetStringByName('TABLE_CAT'));
      finally
        Close;
      end;

    finally

    end;
  except

  end;
end;


function TfrxDatabaseNameProperty.Edit: Boolean;
var
  OD: TOpenDialog;
  SaveConnected: Boolean;
begin
  SaveConnected := TfrxZEOSDatabase(Component).Connected;
  TfrxZEOSDatabase(Component).Connected := False;

  if (TfrxZEOSDatabase(Component).Protocol = '') then begin
  with TOpenDialog.Create(nil) do
    begin
      InitialDir := GetCurrentDir;
      Filter := frxResources.Get('ftAllFiles') + ' (*.*)|*.*';
      Result := Execute;
      if Result then
        with TfrxZEOSDatabase(Component).Database do
        begin
          SaveConnected := Connected;
          Connected := False;
          Database := FileName;
          Connected := SaveConnected;
        end;
      Free;
    end;
     end
  else if (TfrxZEOSDatabase(Component).Protocol = 'ado') then
     TfrxZEOSDatabase(Component).Database.Database := PromptDataSource(Application.Handle, TfrxZEOSDatabase(Component).Database.Database)

  else if (TfrxZEOSDatabase(Component).Protocol <> 'mssql') and (TfrxZEOSDatabase(Component).Protocol <> 'sybase') and (Copy(TfrxZEOSDatabase(Component).Protocol,1,5) <> 'mysql') then begin
     OD := TOpenDialog.Create(nil);
     try
        OD.InitialDir := ExtractFilePath(TfrxZEOSDatabase(Component).Database.Database);
        if Copy(TfrxZEOSDatabase(Component).Protocol,1,8) = 'firebird' then
           OD.Filter := frxResources.Get('ftDB') + ' (*.?db)|*.?db|' +
             frxResources.Get('ftAllFiles') + ' (*.*)|*.*'
        else
             OD.Filter := frxResources.Get('ftAllFiles') + ' (*.*)|*.*';
        if OD.Execute then
           TfrxZEOSDatabase(Component).Database.Database := OD.FileName;
     finally
        OD.Free;
     end;
     end
  else
     inherited Edit;

  try
     TfrxZEOSDatabase(Component).Connected := SaveConnected;
  finally
     //
  end;
  Result := True;
end;

{ TfrxZEOSProtocolProperty }

function TfrxZEOSProtocolProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList, paSortList];
end;

function TfrxZEOSProtocolProperty.GetValue: string;
begin
  Result := GetStrValue;
end;

procedure TfrxZEOSProtocolProperty.SetValue(const Value: string);
begin
  SetStrValue(Value);
end;

procedure TfrxZEOSProtocolProperty.GetValues;
var
  I, J: Integer;
  Drivers: IZCollection;
  Protocols: TStringDynArray;
begin
  Drivers := DriverManager.GetDrivers;
  Protocols := nil;
  for I := 0 to Drivers.Count - 1 do
  begin
    Protocols := (Drivers[I] as IZDriver).GetSupportedProtocols;
    for J := Low(Protocols) to High(Protocols) do
      Values.Append(Protocols[J]);
  end;
end;


{ TfrxDatabaseProperty }

function TfrxDatabaseProperty.GetValue: String;
var
  db: TfrxZEOSDatabase;
begin
  db := TfrxZEOSDatabase(GetOrdValue);
  if db = nil then
  begin
    if (ZEOSComponents <> nil) and (ZEOSComponents.DefaultDatabase <> nil) then
      Result := ZEOSComponents.DefaultDatabase.Name
    else
      Result := frxResources.Get('prNotAssigned');
  end
  else
    Result := inherited GetValue;
end;


{ TfrxTableNameProperty }

function TfrxTableNameProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList, paSortList];
end;

procedure TfrxTableNameProperty.GetValues;
begin
  inherited;
  with TfrxZEOSTable(Component).Table do
    if Connection <> nil then begin
      if not Connection.Connected then begin
         try
           Connection.Connect;
         finally
           //
         end;
      end;
      if Connection.Connected then
         Connection.GetTableNames('', Values);
    end;
end;

procedure TfrxTableNameProperty.SetValue(const Value: String);
begin
  inherited;
  Designer.UpdateDataTree;
end;


{ TfrxIndexProperty }

function TfrxIndexNameProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList];
end;

procedure TfrxIndexNameProperty.GetValues;
begin
  inherited;
  try
    with TfrxZEOSTable(Component).Table do
      if (TableName <> '') then
      begin

      end;
  except
  end;
end;


initialization
  frxPropertyEditors.Register(TypeInfo(String), TfrxZEOSDatabase, 'DatabaseName',
    TfrxDataBaseNameProperty);

  frxPropertyEditors.Register(TypeInfo(String), TfrxZEOSDatabase, 'Protocol',
    TfrxZEOSProtocolProperty);

  frxPropertyEditors.Register(TypeInfo(TfrxZEOSDatabase), TfrxZEOSTable, 'Database',
    TfrxDatabaseProperty);
  frxPropertyEditors.Register(TypeInfo(TfrxZEOSDatabase), TfrxZEOSQuery, 'Database',
    TfrxDatabaseProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxZEOSTable, 'TableName',
    TfrxTableNameProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxZEOSTable, 'IndexName',
    TfrxIndexNameProperty);

end.
