{******************************************}
{                                          }
{             FastReport v5.0              }
{         Zeos enduser components          }
{                                          }
{           Created by Dfox                }
{                                          }
{******************************************}

unit frxZeosReg;

interface

{$I frx.inc}

procedure Register;

implementation

uses
	Classes
	{$IFNDEF Delphi6}
 		,DsgnIntf,
	{$ELSE}
 		,DesignIntf, DesignEditors,
  {$ENDIF}
	frxZeosComponents;

procedure Register;
begin
  RegisterComponents('FastReport 5.0', [TfrxZeosComponents]);
end;

end.
