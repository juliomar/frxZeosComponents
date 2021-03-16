{******************************************}
{                                          }
{             FastReport v5.0              }
{         Zeos enduser components          }
{                                          }
{           Created by Dfox                }
{                                          }
{******************************************}

unit frxZeosRTTI;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, fs_iinterpreter, frxZeosComponents, ZConnection
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TFunctions = class(TfsRTTIModule)
  private
    function CallMethod(Instance: TObject; ClassType: TClass;
      const MethodName: String; Caller: TfsMethodHelper): Variant;
    function GetProp(Instance: TObject; ClassType: TClass;
      const PropName: String): Variant;
  public
    constructor Create(AScript: TfsScript); override;
  end;


{ TFunctions }

constructor TFunctions.Create(AScript: TfsScript);
begin
  inherited Create(AScript);
  with AScript do
  begin
    with AddClass(TfrxZeosDatabase, 'TfrxCustomDatabase') do
      AddProperty('Database', 'TZConnection', GetProp, nil);
    with AddClass(TfrxZeosTable, 'TfrxCustomTable') do
      AddProperty('Table', 'TZTable', GetProp, nil);
    with AddClass(TfrxZeosQuery, 'TfrxCustomQuery') do begin
      AddMethod('procedure ExecSQL', CallMethod);
      AddProperty('Query', 'TZQuery', GetProp, nil);
    end;
  end;
end;

function TFunctions.CallMethod(Instance: TObject; ClassType: TClass;
  const MethodName: String; Caller: TfsMethodHelper): Variant;
begin
  Result := 0;

  if ClassType = TfrxZeosQuery then
  begin
    if MethodName = 'EXECSQL' then
      TfrxZeosQuery(Instance).Query.ExecSQL
  end
end;

function TFunctions.GetProp(Instance: TObject; ClassType: TClass;
  const PropName: String): Variant;
begin
  Result := 0;

  if ClassType = TfrxZeosDatabase then
  begin
    if PropName = 'DATABASE' then
      Result := Integer(TfrxZeosDatabase(Instance).Database)
  end
  else if ClassType = TfrxZeosTable then
  begin
    if PropName = 'TABLE' then
      Result := Integer(TfrxZeosTable(Instance).Table)
  end
  else if ClassType = TfrxZeosQuery then
  begin
    if PropName = 'QUERY' then
      Result := Integer(TfrxZeosQuery(Instance).Query)
  end
end;

initialization
  fsRTTIModules.Add(TFunctions);

end.
