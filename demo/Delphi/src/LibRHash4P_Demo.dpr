program LibRHash4P_Demo;

{$IFDEF FPC}{$mode objfpc}{$H+}{$ENDIF}

{$IFDEF MSWINDOWS}
  {$SetPEFlags $1}  // IMAGE_FILE_RELOCS_STRIPPED
  {$SetPEFlags $20} // IMAGE_FILE_LARGE_ADDRESS_AWARE
{$ENDIF}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  {$IFDEF FPC}Interfaces,{$ENDIF}
  Forms, Main;

{$R *.res}

begin
  {$IFDEF FPC}
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.

