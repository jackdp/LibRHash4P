unit rhash4p;

{
  =========================================================

  Jacek Pazera
  2019.12.09
  http://www.pazera-software.com
  https://github.com/jackdp

  =========================================================

  Warning!
  EDONR512 - invalid hashes when buffer > 8 KB !

  =========================================================

  TRHashFile

  Usage:

  1. Create instance.
  2. Assign DLL/SO file name to LibraryFile.
  3. Set desired HashType.
  4. Call CalcFileHash.
  5. If the CalcFileHash returns True, you can read the result from the StringResult property.

}

interface

uses 
  SysUtils, Classes, Dialogs, librhash {$IFDEF FPC}, dynlibs{$ENDIF}
  {$IFDEF MSWINDOWS}, Windows{$ENDIF}
  ;


const
  RH_OK = 0;

  RHST_OK = RH_OK;
  RHST_LIB_NOT_INITIALIZED = 1;
  RHST_LIB_INITIALIZED = 2;
  RHST_BEGIN_HASH = 100;

  RHERR_NO_LIB_FILE = 10;
  RHERR_NO_INPUT_FILE = 11;
  RHERR_CANNOT_LOAD_LIB = 12;
  RHERR_CANNOT_LOAD_LIB2 = 13;
  RHERR_RHASH_INIT_FAILED = 14;
  RHERR_RHASH_UPDATE_FAILED = 15;
  RHERR_RHASH_FINAL_FAILED = 16;
  RHERR_INVALID_OUTPUT = 17;

  RHERR_ABORTED = 80;

  __8KB = 1024 * 8;
  RH_DEFAULT_BUFFER_SIZE = __8KB;

type

  TRHashType = (
    rhtCrc32, rhtCrc32c, rhtMd4, rhtMd5, rhtSha1, rhtTiger, rhtTth, rhtBtih, rhtEd2k, rhtAich,
    rhtWhirlpool, rhtRipeMd160, rhtHas160,
    rhtGost94, rhtGost94CryptoPro, rhtGost12_256, rhtGost12_512,
    rhtSha2_224, rhtSha2_256, rhtSha2_384, rhtSha2_512,
    rhtSha3_224, rhtSha3_256, rhtSha3_384, rhtSha3_512,
    rhtEdonr256, rhtEdonr512, rhtSnefru128, rhtSnefru256
  );

  TRHashCallback = function(PercentComplete: integer; BufNo: integer): Boolean of object;

  TRHashFile = class
  private
    FDigestSize: Word;
    FElapsedTimeMS: Int64;
    FFileName: string;
    FFileSize: UInt64;
    FHashBufferSize: Cardinal;
    FHashName: string;
    FHashType: TRHashType;
    FLibraryFile: string;
    FByteResult: TBytes;
    FLowerCaseHash: Boolean;
    FStatus: Byte;
    FStringResult: string;
    FRHashCallback: TRHashCallback;
    FTickStart, FTickEnd: Int64;
    function GetStringResult: string;
    function GetValidHash: Boolean;
    procedure SetFileName(AValue: string);
    procedure SetHashBufferSize(AValue: Cardinal);
    procedure SetHashType(AValue: TRHashType);
    procedure SetLibraryFile(AValue: string);
    procedure SetLowerCaseHash(AValue: Boolean);
    procedure SetRHashCallback(AValue: TRHashCallback);
    function CheckLib: Boolean;
    procedure UpdateHashName;
  public
    constructor Create; overload;
    constructor Create(const LibraryFile: string); overload;
    destructor Destroy; override;

    function CalcFileHash: Boolean;
    procedure Clear; // resets params to default values

    property RHashCallback: TRHashCallback read FRHashCallback write SetRHashCallback;
    property ByteResult: TBytes read FByteResult;
    property StringResult: string read GetStringResult;
    property LowerCaseHash: Boolean read FLowerCaseHash write SetLowerCaseHash;
    property HashBufferSize: Cardinal read FHashBufferSize write SetHashBufferSize; // default RH_DEFAULT_BUFFER_SIZE (8 KB)
    property FileName: string read FFileName write SetFileName;
    property LibraryFile: string read FLibraryFile write SetLibraryFile;
    property Status: Byte read FStatus;
    property HashType: TRHashType read FHashType write SetHashType;
    property HashName: string read FHashName;
    property ElapsedTimeMS: Int64 read FElapsedTimeMS; // Use only when Status = RH_OK (when Valid = True)
    property DigestSize: Word read FDigestSize;
    property ValidHash: Boolean read GetValidHash;
    property FileSize: UInt64 read FFileSize;
  end;


// Helpers
function RHashTypeToHashID(const HashType: TRHashType): UInt32;
function RHashIDToHashType(const HashID: UInt32; Default: TRHashType = rhtCrc32): TRHashType;
function RHashNameByType(const HashType: TRHashType): string;
function RHash_CalcFileHash(const HashID: UInt32; const FileName: string; var HashResult: string; StartPos: Int64 = 0): Boolean; overload;
function RHash_CalcFileHash(const HashType: TRHashType; const FileName: string; var HashResult: string; StartPos: Int64 = 0): Boolean; overload;


implementation


{$region '                    helpers                       '}

{$hints off}
function GetTimeCounterMS: Int64;
{$IFDEF MSWINDOWS}
var
  Counter, Freq: Int64;
{$ENDIF}
begin
  Result := {$IFDEF FPC}GetTickCount64 {$ELSE} GetTickCount {$ENDIF};
  {$IFDEF MSWINDOWS}
  QueryPerformanceFrequency(Freq);
  if Freq = 0 then Exit;
  if not QueryPerformanceCounter(Counter) then Exit;
  Result := Round(1000 * Counter / Freq);
  {$ENDIF}
end;
{$hints on}


function RHashTypeToHashID(const HashType: TRHashType): UInt32;
begin
  case HashType of
    rhtCrc32: Result := RHASH_CRC32;
    rhtCrc32c: Result := RHASH_CRC32C;
    rhtMd4: Result := RHASH_MD4;
    rhtMd5: Result := RHASH_MD5;
    rhtSha1: Result := RHASH_SHA1;
    rhtTiger: Result := RHASH_TIGER;
    rhtTth: Result := RHASH_TTH;
    rhtBtih: Result := RHASH_BTIH;
    rhtEd2k: Result := RHASH_ED2K;
    rhtAich: Result := RHASH_AICH;
    rhtWhirlpool: Result := RHASH_WHIRLPOOL;
    rhtRipeMd160: Result := RHASH_RIPEMD160;
    rhtHas160: Result := RHASH_HAS160;
    rhtGost94: Result := RHASH_GOST94;
    rhtGost94CryptoPro: Result := RHASH_GOST94_CRYPTOPRO;
    rhtGost12_256: Result := RHASH_GOST12_256;
    rhtGost12_512: Result := RHASH_GOST12_512;
    rhtSha2_224: Result := RHASH_SHA224;
    rhtSha2_256: Result := RHASH_SHA256;
    rhtSha2_384: Result := RHASH_SHA384;
    rhtSha2_512: Result := RHASH_SHA512;
    rhtSha3_224: Result := RHASH_SHA3_224;
    rhtSha3_256: Result := RHASH_SHA3_256;
    rhtSha3_384: Result := RHASH_SHA3_384;
    rhtSha3_512: Result := RHASH_SHA3_512;
    rhtEdonr256: Result := RHASH_EDONR256;
    rhtEdonr512: Result := RHASH_EDONR512;
    rhtSnefru128: Result := RHASH_SNEFRU128;
    rhtSnefru256: Result := RHASH_SNEFRU256;
  {$IFDEF DCC}
  else
    Result := RHASH_CRC32;
  {$ENDIF}
  end;
end;

function RHashIDToHashType(const HashID: UInt32; Default: TRHashType = rhtCrc32): TRHashType;
begin
  case HashID of
    RHASH_CRC32: Result := rhtCrc32;
    RHASH_CRC32C: Result := rhtCrc32c;
    RHASH_MD4: Result := rhtMd4;
    RHASH_MD5: Result := rhtMd5;
    RHASH_SHA1: Result := rhtSha1;
    RHASH_TIGER: Result := rhtTiger;
    RHASH_TTH: Result := rhtTth;
    RHASH_BTIH: Result := rhtBtih;
    RHASH_ED2K: Result := rhtEd2k;
    RHASH_AICH: Result := rhtAich;
    RHASH_WHIRLPOOL: Result := rhtWhirlpool;
    RHASH_RIPEMD160: Result := rhtRipeMd160;
    RHASH_HAS160: Result := rhtHas160;
    RHASH_GOST94: Result := rhtGost94;
    RHASH_GOST94_CRYPTOPRO: Result := rhtGost94CryptoPro;
    RHASH_GOST12_256: Result := rhtGost12_256;
    RHASH_GOST12_512: Result := rhtGost12_512;
    RHASH_SHA224: Result := rhtSha2_224;
    RHASH_SHA256: Result := rhtSha2_256;
    RHASH_SHA384: Result := rhtSha2_384;
    RHASH_SHA512: Result := rhtSha2_512;
    RHASH_SHA3_224: Result := rhtSha3_224;
    RHASH_SHA3_256: Result := rhtSha3_256;
    RHASH_SHA3_384: Result := rhtSha3_384;
    RHASH_SHA3_512: Result := rhtSha3_512;
    RHASH_EDONR256: Result := rhtEdonr256;
    RHASH_EDONR512: Result := rhtEdonr512;
    RHASH_SNEFRU128: Result := rhtSnefru128;
    RHASH_SNEFRU256: Result := rhtSnefru256;
  else
    Result := Default;
  end;
end;

function RHashNameByType(const HashType: TRHashType): string;
begin
  Result := RH_GetHashNameByID(RHashTypeToHashID(HashType));
end;

function RHash_CalcFileHash(const HashID: UInt32; const FileName: string; var HashResult: string; StartPos: Int64 = 0): Boolean;
var
  fs: TFileStream;
  sHash: string;
  rh: rhash;
  x, i, xRead: integer;
  BufSize: integer;
  CharResult: TRHashCharResult;
  flags: integer;
  Buffer: TBytes;
  TotalRead: Int64;
begin
  Result := False;

  try

    rh := rhash_init(HashID);
    if not Assigned(rh) then Exit;

    if HashID = RHASH_EDONR512 then BufSize := 1024 * 8
    else BufSize := 1024 * 64;
    SetLength(Buffer, BufSize);

    TotalRead := 0;

    fs := TFileStream.Create(FileName, fmShareDenyWrite or fmOpenRead);
    try
      fs.Position := StartPos;

      while fs.Position < fs.Size do
      begin
        xRead := fs.Read(Buffer[0], BufSize);
        TotalRead := TotalRead + xRead;
        x := rhash_update(rh, @Buffer[0], xRead);
        if x < 0 then Exit;
      end;

      x := rhash_final(rh, nil);
      if x < 0 then Exit;

      flags := RHPR_HEX;
      x := rhash_print(CharResult, rh, HashID, flags);

      if x = 0 then Exit;
      if x > Length(CharResult) then Exit;

      sHash := '';
      for i := 0 to x - 1 do sHash := sHash + Char(CharResult[i]);

      rhash_free(rh);

      HashResult := sHash;


    finally
      fs.Free;
    end;

    Result := True;

  except
    Result := False;
  end;

end;

function RHash_CalcFileHash(const HashType: TRHashType; const FileName: string; var HashResult: string; StartPos: Int64 = 0): Boolean;
begin
  Result := RHash_CalcFileHash(RHashTypeToHashID(HashType), FileName, HashResult, StartPos);
end;

{$endregion helpers}


{$region '                                  TRHashFile                                  '}

constructor TRHashFile.Create;
begin
  inherited Create;
  Clear;
  FLibraryFile := '';
  FHashBufferSize := RH_DEFAULT_BUFFER_SIZE; // 8 KB
  FHashType := rhtCrc32;
  UpdateHashName;
end;

constructor TRHashFile.Create(const LibraryFile: string);
begin
  Create;
  FLibraryFile := LibraryFile;
end;

destructor TRHashFile.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TRHashFile.Clear;
begin
  FStringResult := '';
  SetLength(FByteResult, 0);
  FFileName := '';
  FFileSize := 0;
  FStatus := RHST_LIB_NOT_INITIALIZED;
  RH_UnloadLib;
end;

  {$region ' --------------------- TRHashFile.CalcFileHash ------------------------ '}
function TRHashFile.CalcFileHash: Boolean;
var
  HashID: UInt32;
  fs: TFileStream;
  Buffer: TBytes;
  xTotalRead: Int64;
  rh: rhash;
  x, i, xRead, BufNo, xPercent, flags: integer;
  cres: TRHashCharResult;

  function PercentValue(const Value, x100Percent: Double): Real;
  begin
    if x100Percent = 0 then Result := 0
    else Result := Value * 100 / x100Percent;
  end;

begin
  Result := False;

  if not FileExists(FFileName) then
  begin
    FStatus := RHERR_NO_INPUT_FILE;
    Exit;
  end;

  if not CheckLib then Exit;

  FStatus := RHST_BEGIN_HASH;

  HashID := RHashTypeToHashID(FHashType);

  rh := rhash_init(HashID);
  if not Assigned(rh) then
  begin
    FStatus := RHERR_RHASH_INIT_FAILED;
    Exit;
  end;


  SetLength(Buffer, FHashBufferSize);
  BufNo := 0;
  xTotalRead := 0;

  FTickStart := GetTimeCounterMS;

  fs := TFileStream.Create(FFileName, fmShareDenyWrite or fmOpenRead);
  try

    fs.Position := 0;
    FFileSize := fs.Size;

    while fs.Position < fs.Size do
    begin

      xRead := fs.Read(Buffer[0], FHashBufferSize);
      xTotalRead := xTotalRead + xRead;

      Inc(BufNo);

      x := rhash_update(rh, @Buffer[0], xRead); ///////////////////////////////////////

      if x < 0 then
      begin
        FStatus := RHERR_RHASH_UPDATE_FAILED;
        Exit;
      end;

      if Assigned(RHashCallback) then
      begin
        xPercent := Round(PercentValue(xTotalRead, FFileSize));
        if not RHashCallback(xPercent, BufNo) then
        begin
          FStatus := RHERR_ABORTED;
          Break;
        end;
      end;

    end; // while


    x := rhash_final(rh, nil);
    if x < 0 then
    begin
      FStatus := RHERR_RHASH_FINAL_FAILED;
      Exit;
    end;

    FDigestSize := rhash_get_digest_size(HashID);

    flags := RHPR_HEX;
    x := rhash_print(cres, rh, HashID, flags);
    if (x = 0) or (x > Length(cres)) then
    begin
      FStatus := RHERR_INVALID_OUTPUT;
      Exit;
    end;

    FStringResult := '';
    //for i := 0 to x - 1 do FStringResult := FStringResult + Char(cres[i]);
    FStringResult := string(cres);



    flags := RHPR_RAW;
    x := rhash_print(cres, rh, HashID, flags);
    if (x = 0) or (x > Length(cres)) then
    begin
      FStatus := RHERR_INVALID_OUTPUT;
      Exit;
    end;
    SetLength(FByteResult, x);
    for i := 0 to x - 1 do FByteResult[i] := Ord(cres[i]);



    if FStatus = RHST_BEGIN_HASH then FStatus := RH_OK;

  finally
    fs.Free;
    if rh <> nil then rhash_free(rh);
  end;

  FTickEnd := GetTimeCounterMS;
  FElapsedTimeMS := FTickEnd - FTickStart;
  Result := FStatus = RH_OK;

end;
  {$endregion TRHashFile.CalcFileHash}

function TRHashFile.CheckLib: Boolean;
{$IFDEF DCC}
const NilHandle = 0;
{$ENDIF}
begin
  Result := False;

  if not FileExists(FLibraryFile) then
  begin
    FStatus := RHERR_NO_LIB_FILE;
    Exit;
  end;

  if RHLibHandle = NilHandle then
    if not RH_LoadLib(FLibraryFile) then
    begin
      FStatus := RHERR_CANNOT_LOAD_LIB;
      Exit;
    end;

  if RHLibHandle = NilHandle then
  begin
    FStatus := RHERR_CANNOT_LOAD_LIB2;
    Exit;
  end;

  rhash_library_init;
  FStatus := RHST_LIB_INITIALIZED;
  Result := True;
end;

procedure TRHashFile.UpdateHashName;
begin
  FHashName := RH_GetHashNameByID(RHashTypeToHashID(FHashType));
end;

procedure TRHashFile.SetRHashCallback(AValue: TRHashCallback);
begin
  //if FRHashCallback = AValue then Exit;
  FRHashCallback := AValue;
end;

procedure TRHashFile.SetLowerCaseHash(AValue: Boolean);
begin
  if FLowerCaseHash = AValue then Exit;
  FLowerCaseHash := AValue;
end;

function TRHashFile.GetStringResult: string;
begin
  if FLowerCaseHash then Result := LowerCase(FStringResult)
  else Result := UpperCase(FStringResult);
end;

function TRHashFile.GetValidHash: Boolean;
begin
  Result := FStatus = RH_OK;
end;

procedure TRHashFile.SetFileName(AValue: string);
begin
  if FFileName = AValue then Exit;
  FFileName := AValue;
end;

procedure TRHashFile.SetHashBufferSize(AValue: Cardinal);
begin
  if AValue = 0 then AValue := RH_DEFAULT_BUFFER_SIZE;
  if (FHashType = rhtEdonr512) and (AValue > __8KB) then AValue := __8KB; // forced 8 KB buffer for EDONR512
  if FHashBufferSize = AValue then Exit;
  FHashBufferSize := AValue;
end;

procedure TRHashFile.SetHashType(AValue: TRHashType);
begin
  if FHashType = AValue then Exit;
  FHashType := AValue;
  if (FHashType = rhtEdonr512) and (FHashBufferSize > __8KB) then FHashBufferSize := __8KB; // forced 8 KB buffer for EDONR512
  UpdateHashName;
end;

procedure TRHashFile.SetLibraryFile(AValue: string);
begin
  if FLibraryFile = AValue then Exit;
  FLibraryFile := AValue;
  RH_UnloadLib;
end;

{$endregion TRHashFile}

end.
