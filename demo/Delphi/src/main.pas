unit Main;

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  {$IFDEF MSWINDOWS}Windows,{$ENDIF} Classes, SysUtils, Messages, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ActnList, ComCtrls, rhash4p, librhash
  {$IFDEF FPC}, dynlibs{$ENDIF}
  ;

const

  {$IFDEF MSWINDOWS}APP_OS = 'Win';{$ELSE}APP_OS = 'Linux';{$ENDIF}
  {$IFDEF CPUX64}APP_BITS_STR = '64-bit';{$ELSE}APP_BITS_STR = '32-bit';{$ENDIF}
  APP_NAME = 'LibRHash4P Demo';

type


  TFormMain = class(TForm)
    btnBrowseLib: TButton;
    btnHashCount: TButton;
    btnHashNames: TButton;
    btnHashesInfo: TButton;
    btnHashFile: TButton;
    btnAbort: TButton;
    btnBrowseFile: TButton;
    edLib: TLabeledEdit;
    edFile: TLabeledEdit;
    Label1: TLabel;
    dlgOpenFile: TOpenDialog;
    dlgOpenLib: TOpenDialog;
    pnHashType: TPanel;
    lblProgress: TLabel;
    me: TMemo;
    pnBottom: TPanel;
    pb: TProgressBar;
    rbSha3_512: TRadioButton;
    rbSha3_256: TRadioButton;
    rbSha2_512: TRadioButton;
    rbSha2_256: TRadioButton;
    rbSha1: TRadioButton;
    rbMd5: TRadioButton;
    rbCrc32: TRadioButton;
    procedure btnAbortClick(Sender: TObject);
    procedure btnBrowseLibClick(Sender: TObject);
    procedure btnHashCountClick(Sender: TObject);
    procedure btnHashesInfoClick(Sender: TObject);
    procedure btnHashNamesClick(Sender: TObject);
    procedure btnHashFileClick(Sender: TObject);
    procedure btnBrowseFileClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    function CheckLib: Boolean;
    {$IFDEF FPC}procedure FormDropFiles(Sender: TObject; const FileNames: array of String);{$ENDIF}
    procedure Log(const s: string);
    procedure ClearLog;
    function RHashCallback(PercentComplete: integer; {%H-}BufNo: integer): Boolean;
  end;

var
  FormMain: TFormMain;
  Aborted: Boolean;

const
  LINE = '------------------------------------------------';

implementation

{$IFDEF DCC}
{$R *.dfm}
{$ELSE}
{$R *.lfm}
{$ENDIF}

function Pad(Text: string; Len: integer; PaddingChar: Char = ' '): string;
var
  x, y, k: integer;
  s: string;
begin
  s := '';
  if Length(Text) < Len then
  begin
    x := Length(Text);
    y := Len - x;
    for k := 1 to y do
      s := s + PaddingChar;
    Text := s + Text;
  end;
  Result := Text;
end;

function BoolToStrYN(const b: Boolean): string;
begin
  if b then Result := 'Yes' else Result := 'No';
end;


procedure TFormMain.FormCreate(Sender: TObject);
var
  TestFile, LibFile: string;
begin
  Caption := APP_NAME + '  [' + APP_OS + ' ' + APP_BITS_STR + ']';

  {$IFDEF MSWINDOWS}
  dlgOpenLib.Filter := 'DLL files|*.dll|All files|*.*';
  if APP_BITS_STR = '32-bit' then {%H-}LibFile := ExpandFileName('..\..\bin\librhash_1.3.8\32\librhash_32_TDM_GCC_510_O2.dll')
  else {%H-}LibFile := ExpandFileName('..\..\bin\librhash_1.3.8\64\librhash_64_TDM_GCC_510_O2.dll');
  {$ELSE}
  dlgOpenLib.Filter := 'SO files|*.so|All files|*.*';
  if APP_BITS_STR = '32-bit' then {%H-}LibFile := ExpandFileName('../../bin/librhash_1.3.8/32/librhash_32_GCC_540_O2.so')
  else {%H-}LibFile := ExpandFileName('../../bin/librhash_1.3.8/64/librhash_64_GCC_540_O2.so');
  {$ENDIF}

  if not FileExists(LibFile) then LibFile := '';
  edLib.Text := LibFile;

  edFile.Text := '';
  TestFile := ExpandFileName('hash_test_002MB-ółćśńę-目录-ディレクトリ-Κατάλογος-Каталог.txt');
  if FileExists(TestFile) then edFile.Text := TestFile;

  ClearLog;
  pb.Position := 0;
end;

procedure TFormMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  try
    me.Lines.SaveToFile('last.log');
  except
  end;
end;




function TFormMain.CheckLib: Boolean;
{$IFDEF DCC}
const NilHandle = 0;
{$ENDIF}
var
  LibFile: string;
begin
  Result := False;

  LibFile := Trim(edLib.Text);
  if not FileExists(LibFile) then
  begin
    Log('Library file not exists: "' + LibFile + '"');
    Exit;
  end;

  if RHLibHandle = NilHandle then
    if not RH_LoadLib(LibFile) then
    begin
      Log('RH_LoadLib failed!');
      Exit;
    end;

  if RHLibHandle = NilHandle then
  begin
    Log('An error occured while loading library: RHLibHandle = NilHandle');
    Exit;
  end;

  rhash_library_init;
  Result := True;
end;

{$IFDEF FPC}
procedure TFormMain.FormDropFiles(Sender: TObject; const FileNames: array of String);
begin
  if Length(FileNames) > 0 then edFile.Text := FileNames[0];
end;
{$ENDIF}

procedure TFormMain.Log(const s: string);
begin
  me.Lines.Add(s);
end;

procedure TFormMain.ClearLog;
begin
  me.Lines.Clear;
end;



procedure TFormMain.btnHashCountClick(Sender: TObject);
var
  x: integer;
begin
  ClearLog;
  if not CheckLib then Exit;
  x := rhash_count;
  Log('The number of supported cheksums/hashes: ' + x.ToString);
end;

procedure TFormMain.btnHashNamesClick(Sender: TObject);
var
  i, HashID: integer;
  s, s2: string;
begin
  ClearLog;
  if not CheckLib then Exit;

  for i := 0 to Length(ArrRHashIDs) - 1 do
  begin
    HashID := ArrRHashIDs[i];
    s := string(rhash_get_name(HashID));
    s2 := string(rhash_get_magnet_name(HashID));
    Log('No: ' + Pad((i + 1).ToString, 2) + '    Name: ' + Pad(s, 16) + '    Magnet name: ' + s2);
  end;
end;

procedure TFormMain.btnHashesInfoClick(Sender: TObject);
const
  Sep = '  ';
var
  i, HashID, xDigestSize, xHashLen: integer;
  sName, sMagnetName: string;
  bBase32: Boolean;
begin
  ClearLog;
  if not CheckLib then Exit;

  me.Lines.BeginUpdate;
  try

    for i := 0 to Length(ArrRHashIDs) - 1 do
    begin
      HashID := ArrRHashIDs[i];
      sName := string(rhash_get_name(HashID));
      sMagnetName := string(rhash_get_magnet_name(HashID));
      bBase32 := rhash_is_base32(HashID);
      xDigestSize := rhash_get_digest_size(HashID);
      xHashLen := rhash_get_hash_length(HashID);

      Log(Sep + 'No: ' + (i + 1).ToString);
      Log(Sep + 'Name: ' + sName);
      Log(Sep + 'Magnet name: ' + sMagnetName);
      Log(Sep + 'ID: ' + IntToStr(HashID) + ' ($' + IntToHex(HashID, 2) + ')');
      Log(Sep + 'Digest size: ' + xDigestSize.ToString);
      Log(Sep + 'Hash length: ' + xHashLen.ToString);
      Log(Sep + 'IsBase32: ' + BoolToStrYN(bBase32));

      Log('');
    end;

  finally
    {$IFDEF MSWINDOWS}SendMessage(me.Handle, EM_LINESCROLL, 0, me.Lines.Count);{$ENDIF}
    me.Lines.EndUpdate;
  end;
end;


procedure TFormMain.btnAbortClick(Sender: TObject);
begin
  Aborted := True;
end;



function TFormMain.RHashCallback(PercentComplete: integer; BufNo: integer): Boolean;
begin
  Result := not Aborted;
  if BufNo mod 16 = 0 then
  begin
    pb.Position := PercentComplete;
    Application.ProcessMessages;
  end;
end;

procedure TFormMain.btnHashFileClick(Sender: TObject);
var
  rhf: TRHashFile;
  TestFile: string;
begin
  Aborted := False;
  pb.Position := 0;
  TestFile := edFile.Text;
  if not CheckLib then Exit;
  if not FileExists(TestFile) then raise Exception.Create('Input file does not exists!');

  Log('Test file: ' + TestFile);
  btnAbort.Show;
  btnHashFile.Enabled := False;

  rhf := TRHashFile.Create;
  try

    if rbCrc32.Checked then rhf.HashType := rhtCrc32
    else if rbMd5.Checked then rhf.HashType := rhtMd5
    else if rbSha1.Checked then rhf.HashType := rhtSha1
    else if rbSha2_256.Checked then rhf.HashType := rhtSha2_256
    else if rbSha2_512.Checked then rhf.HashType := rhtSha2_512
    else if rbSha3_256.Checked then rhf.HashType := rhtSha3_256
    else rhf.HashType := rhtSha3_512;

    rhf.HashBufferSize := 1024 * 256;
    rhf.FileName := TestFile;
    rhf.LibraryFile := Trim(edLib.Text);

    rhf.RHashCallback := RHashCallback;
    rhf.LowerCaseHash := True;

    if rhf.CalcFileHash then
    begin
      Log(rhf.HashName + ': ' + rhf.StringResult);
      Log('Elapsed time: ' + rhf.ElapsedTimeMS.ToString + ' ms');
    end
    else
    begin
      Log('Error! Status = ' + rhf.Status.ToString);
    end;

  finally
    rhf.Free;
    btnAbort.Hide;
    btnHashFile.Enabled := True;
    if not ABorted then pb.Position := 100;
    Log(LINE);
  end;

end;

procedure TFormMain.btnBrowseFileClick(Sender: TObject);
begin
  if not dlgOpenFile.Execute then Exit;
  edFile.Text := dlgOpenFile.FileName;
end;

procedure TFormMain.btnBrowseLibClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := ExtractFileDir(edLib.Text);
  if DirectoryExists(Dir) then dlgOpenLib.InitialDir := Dir;
  if not dlgOpenLib.Execute then Exit;
  edLib.Text := dlgOpenLib.FileName;
end;




end.

