unit librhash;

{$IFDEF FPC}{$mode delphi}{$ENDIF}


{
  =========================================================

  RHash author: Aleksey Kravchenko
  GitHub: https://github.com/rhash/RHash
  RHash license: https://github.com/rhash/RHash/blob/master/COPYING   (BSD Zero Clause License)
  SourceForge: https://sourceforge.net/projects/rhash/
  Wiki: https://sourceforge.net/p/rhash/wiki/Home/
  LibRHash info: https://sourceforge.net/p/rhash/wiki/LibRHash/

  =========================================================

  Source files:
    librhash\rhash.c + h
    librhash\rhash_timing.c + h

  =========================================================

  Jacek Pazera
  2019.12.09
  http://www.pazera-software.com
  https://github.com/jackdp

  =========================================================

  Warning!
  EDONR512 - invalid hashes when buffer > 8 KB !

}

interface

uses
  {$IFDEF FPC}dynlibs;{$ELSE}Windows;{$ENDIF}


type
  BOOL = Longbool;

const

  RHASH_VERSION = '1.3.8';

{$region ' --------------------- CONSTS ------------------------'}

  RHASH_HASH_COUNT = 29; // The number of supported hash functions

  //RHASH_ERROR = -1;

{
  #ifndef RHASH_API
    Modifier for LibRHash functions
  # define RHASH_API
  #endif
}

{
  Identifiers of supported hash functions.
  The rhash_init() function allows mixing several ids using
  binary OR, to calculate several hash functions for one message.
}
	RHASH_CRC32 = $01;
	RHASH_MD4   = $02;
	RHASH_MD5   = $04;
	RHASH_SHA1  = $08;
	RHASH_TIGER = $10;
	RHASH_TTH   = $20;
	RHASH_BTIH  = $40;
	RHASH_ED2K  = $80;
	RHASH_AICH  = $100;
	RHASH_WHIRLPOOL = $200;
	RHASH_RIPEMD160 = $400;
  RHASH_GOST94    = $800;
  RHASH_GOST94_CRYPTOPRO = $1000;
	RHASH_HAS160    = $2000;
  RHASH_GOST12_256 = $4000;
  RHASH_GOST12_512 = $8000;
  RHASH_SHA224    = $10000;
  RHASH_SHA256    = $20000;
  RHASH_SHA384    = $40000;
  RHASH_SHA512    = $80000;
  RHASH_EDONR256  = $0100000;     // http://www.item.ntnu.no/people/personalpages/fac/danilog/edon-r
  RHASH_EDONR512  = $0200000;
  RHASH_SHA3_224  = $0400000;
  RHASH_SHA3_256  = $0800000;
  RHASH_SHA3_384  = $1000000;
  RHASH_SHA3_512  = $2000000;
  RHASH_CRC32C    = $4000000;
  RHASH_SNEFRU128 = $8000000;
  RHASH_SNEFRU256 = $10000000;


  // The bit-mask containing all supported hash functions
  RHASH_ALL_HASHES =
    RHASH_CRC32 or RHASH_CRC32C or RHASH_MD4 or RHASH_MD5 or
  	RHASH_ED2K or RHASH_SHA1 or RHASH_TIGER or RHASH_TTH or
  	RHASH_GOST94 or RHASH_GOST94_CRYPTOPRO or RHASH_GOST12_256 or RHASH_GOST12_512 or
  	RHASH_BTIH or RHASH_AICH or RHASH_WHIRLPOOL or RHASH_RIPEMD160 or
  	RHASH_HAS160 or RHASH_SNEFRU128 or RHASH_SNEFRU256 or
  	RHASH_SHA224 or RHASH_SHA256 or RHASH_SHA384 or RHASH_SHA512 or
  	RHASH_SHA3_224 or RHASH_SHA3_256 or RHASH_SHA3_384 or RHASH_SHA3_512 or
  	RHASH_EDONR256 or RHASH_EDONR512;

  RHASH_GOST = RHASH_GOST94;                     // deprecated constant name
  RHASH_GOST_CRYPTOPRO = RHASH_GOST94_CRYPTOPRO; // deprecated constant name


  // Flags for printing a hash sum
  // enum rhash_print_sum_flags
	RHPR_DEFAULT   = $0;  // Print in a default format
	RHPR_RAW       = $1;  // Output as binary message digest
	RHPR_HEX       = $2;  // Print as a hexadecimal string
	RHPR_BASE32    = $3;  // Print as a base32-encoded string
	RHPR_BASE64    = $4;  // Print as a base64-encoded string
	RHPR_UPPERCASE = $8;  // Print as an uppercase string. Can be used for base32 or hexadecimal format only.
	RHPR_REVERSE   = $10; // Reverse hash bytes. Can be used for GOST hash.
	RHPR_NO_MAGNET = $20; // Don't print 'magnet:?' prefix in rhash_print_magnet
	RHPR_FILESIZE  = $40; // Print file size in rhash_print_magnet


  // jp - some helpers
  ArrRHashIDs: array[0..RHASH_HASH_COUNT - 1] of integer =
  (
    RHASH_CRC32, RHASH_MD4, RHASH_MD5, RHASH_SHA1, RHASH_TIGER, RHASH_TTH, RHASH_BTIH,
    RHASH_ED2K, RHASH_AICH, RHASH_WHIRLPOOL, RHASH_RIPEMD160,
    RHASH_GOST94, RHASH_GOST94_CRYPTOPRO, RHASH_HAS160, RHASH_GOST12_256, RHASH_GOST12_512,
    RHASH_SHA224, RHASH_SHA256, RHASH_SHA384, RHASH_SHA512,
    RHASH_EDONR256, RHASH_EDONR512,
    RHASH_SHA3_224, RHASH_SHA3_256, RHASH_SHA3_384, RHASH_SHA3_512,
    RHASH_CRC32C,
    RHASH_SNEFRU128, RHASH_SNEFRU256
  );

  RHASH_DIGEST_SIZE_CRC32 = 4;
  RHASH_DIGEST_SIZE_CRC32C = 4;
  RHASH_DIGEST_SIZE_MD4 = 16;
  RHASH_DIGEST_SIZE_MD5 = 16;
  RHASH_DIGEST_SIZE_ED2K = 16;
  RHASH_DIGEST_SIZE_SHA1 = 20;
  RHASH_DIGEST_SIZE_TIGER = 24;
  RHASH_DIGEST_SIZE_TTH = 24;
  RHASH_DIGEST_SIZE_GOST94 = 32;
  RHASH_DIGEST_SIZE_GOST94_CRYPTOPRO = 32;
  RHASH_DIGEST_SIZE_GOST12_256 = 32;
  RHASH_DIGEST_SIZE_GOST12_512 = 64;
  RHASH_DIGEST_SIZE_HAS160 = 20;
  RHASH_DIGEST_SIZE_BTIH = 20;
  RHASH_DIGEST_SIZE_AICH = 20;
  RHASH_DIGEST_SIZE_WHIRLPOOL = 64;
  RHASH_DIGEST_SIZE_RIPEMD160 = 20;
  RHASH_DIGEST_SIZE_SNEFRU128 = 16;
  RHASH_DIGEST_SIZE_SNEFRU256 = 32;
  RHASH_DIGEST_SIZE_SHA224 = 28;
  RHASH_DIGEST_SIZE_SHA256 = 32;
  RHASH_DIGEST_SIZE_384 = 48;
  RHASH_DIGEST_SIZE_512 = 64;
  RHASH_DIGEST_SIZE_SHA3_224 = 28;
  RHASH_DIGEST_SIZE_SHA3_256 = 32;
  RHASH_DIGEST_SIZE_SHA3_384 = 48;
  RHASH_DIGEST_SIZE_SHA3_512 = 64;
  RHASH_DIGEST_SIZE_EDONR256 = 32;
  RHASH_DIGEST_SIZE_EDONR512 = 64;

  RHASH_MIN_DIGEST_SIZE = 4;
  RHASH_MAX_DIGEST_SIZE = 64;

{$endregion CONSTS}


type

{$region ' --------------------- TYPES ------------------------ '}

(*
  The rhash context structure contains contexts for several hash functions
  typedef struct rhash_context
  {
    unsigned long long msg_size; // The size of the hashed message
    unsigned hash_id;            // The bit-mask containing identifiers of the hashes being calculated
  } rhash_context;
  typedef struct rhash_context* rhash;
*)
  prhash_context = ^rhash_context;
  rhash_context = record
	  msg_size: UInt64;
	  hash_id: UInt32;
  end;
  rhash = prhash_context; // Hashing context.


  // The number of returned bytes = rhash_get_digest_size
  TRHashByteResult = array[0..(RHASH_MAX_DIGEST_SIZE * 1) - 1] of Byte;
  TRHashCharResult = array[0..(RHASH_MAX_DIGEST_SIZE * 2) - 1] of AnsiChar;

  size_t = UInt32; // UInt64;


{
  Type of a callback to be called periodically while hashing a file */
  typedef void (*rhash_callback_t)(void* data, unsigned long long offset);
}
  rhash_callback_t = procedure(data: Pointer; offset: UInt64);

{$endregion TYPES}



var

{
  Initialize static data of rhash algorithms
  RHASH_API void rhash_library_init(void);
}
  rhash_library_init: procedure; cdecl;


{$region ' ------------------------- HIGH-LEVEL LIBRHASH INTERFACE ----------------------------- '}

{
  Compute a hash of the given message.

    @param hash_id id of hash sum to compute
    @param message the message to process
    @param length message length
    @param result buffer to receive binary hash string
    @return 0 on success, -1 on error

  RHASH_API int rhash_msg(unsigned hash_id, const void* message, size_t length, unsigned char* result)
}
  rhash_msg: function(hash_id: UInt32; buffer: Pointer; length: size_t; var hash_rehash: TRHashByteResult): integer; cdecl;


{
  Compute a single hash for given file.

    @param hash_id id of hash sum to compute
    @param filepath path to the file to hash
    @param result buffer to receive hash value with the lowest requested id
    @return 0 on success, -1 on error and errno is set

  RHASH_API int rhash_file(unsigned hash_id, const char* filepath, unsigned char* result);
}
  rhash_file: function(hash_id: UInt32; filepath: PAnsiChar; var hash_result: TRHashByteResult): integer; cdecl;


{
  #ifdef _WIN32
  Compute a single hash for given file (Windows-specific function).

    @param hash_id id of hash sum to compute
    @param filepath path to the file to hash
    @param result buffer to receive hash value with the lowest requested id
    @return 0 on success, -1 on error, -1 on error and errno is set

  RHASH_API int rhash_wfile(unsigned hash_id, const wchar_t* filepath, unsigned char* result);
  #endif
}
{$IFDEF MSWINDOWS}
  rhash_wfile: function(hash_id: UInt32; filepath: WideString; var hash_result: TRHashByteResult): integer; cdecl;
{$ENDIF}

{$endregion HIGH-LEVEL LIBRHASH INTERFACE}


{$region ' ------------------------- LOW-LEVEL LIBRHASH INTERFACE ------------------------------ '}

{
  Allocate and initialize RHash context for calculating hash(es).
  After initializing rhash_update()/rhash_final() functions should be used.
  Then the context must be freed by calling rhash_free().

    @param hash_id union of bit flags, containing ids of hashes to calculate.
    @return initialized rhash context, NULL on error and errno is set

  RHASH_API rhash rhash_init(unsigned hash_id)
}
  rhash_init: function(hash_id: UInt32): rhash; cdecl;


{
  Calculate hashes of message.
  Can be called repeatedly with chunks of the message to be hashed.

    @param ctx the rhash context
    @param message message chunk
    @param length length of the message chunk
    @return 0 on success; On fail return -1 and set errno

  RHASH_API int rhash_update(rhash ctx, const void* message, size_t length)
}
  rhash_update: function(ctx: rhash; buffer: PByte; length: size_t): integer; cdecl;


{
  Hash a file or stream. Multiple hashes can be computed.
  First, inintialize ctx parameter with rhash_init() before calling
  rhash_file_update(). Then use rhash_final() and rhash_print()
  to retrive hash values. Finaly call rhash_free() on ctx
  to free allocated memory or call rhash_reset() to reuse ctx.

    @param ctx rhash context
    @param fd descriptor of the file to hash
    @return 0 on success, -1 on error and errno is set

  RHASH_API int rhash_file_update(rhash ctx, FILE* fd);
}
  rhash_file_update: function(ctx: rhash; aFile: Pointer): integer;
// TODO: rhash_file_update


{
  Finalize hash calculation and optionally store the first hash.

    @param ctx the rhash context
    @param first_result optional buffer to store a calculated hash with the lowest available id
    @return 0 on success; On fail return -1 and set errno

  RHASH_API int rhash_final(rhash ctx, unsigned char* first_result)
}
  rhash_final: function(ctx: rhash; first_result: Pointer): integer; cdecl;


{
  Re-initialize RHash context to reuse it.
  Useful to speed up processing of many small messages.

    @param ctx context to reinitialize

  RHASH_API void rhash_reset(rhash ctx);
}
  rhash_reset: procedure(ctx: rhash); cdecl;


{
  Free RHash context memory.

    @param ctx the context to free.

  RHASH_API void rhash_free(rhash ctx);
}
  rhash_free: procedure(ctx: rhash); cdecl;


{
  Set the callback function to be called from the
  rhash_file() and rhash_file_update() functions
  on processing every file block. The file block
  size is set internally by rhash and now is 8 KiB.

    @param ctx rhash context
    @param callback pointer to the callback function
    @param callback_data pointer to data passed to the callback

  RHASH_API void  rhash_set_callback(rhash ctx, rhash_callback_t callback, void* callback_data);
}
  rhash_set_callback: procedure(ctx: rhash; callback: rhash_callback_t; callback_data: Pointer); cdecl;

{$endregion LOW-LEVEL LIBRHASH INTERFACE}



{$region ' ------------------------- INFORMATION FUNCTIONS ------------------------------------- '}

{
  Returns the number of supported hash algorithms.

    @return the number of supported hash functions

  RHASH_API int  rhash_count(void);
}
  rhash_count: function: integer; cdecl; // number of supported hashes


{
  Returns size of binary digest for given hash algorithm.

    @param hash_id the id of hash algorithm
    @return digest size in bytes

  RHASH_API int  rhash_get_digest_size(unsigned hash_id);
}
  rhash_get_digest_size: function(hash_id: UInt32): integer; cdecl; // size of binary message digest


{
  Returns length of digest hash string in default output format.

    @param hash_id the id of hash algorithm
    @return the length of hash string

  RHASH_API int  rhash_get_hash_length(unsigned hash_id);
}
  rhash_get_hash_length: function(hash_id: UInt32): integer; cdecl; // length of formatted hash string


{
  Detect default digest output format for given hash algorithm.

    @param hash_id the id of hash algorithm
    @return 1 for base32 format, 0 for hexadecimal

  RHASH_API int  rhash_is_base32(unsigned hash_id);
}
  rhash_is_base32: function(hash_id: UInt32): BOOL; {int} cdecl; // default digest output format


{
  Returns a name of given hash algorithm.

    @param hash_id the id of hash algorithm
    @return algorithm name

  RHASH_API const char* rhash_get_name(unsigned hash_id);
}
  rhash_get_name: function(hash_id: UInt32): PAnsiChar; cdecl; // get hash function name


{
  Returns a name part of magnet urn of the given hash algorithm.
  Such magnet_name is used to generate a magnet link of the form
  urn:&lt;magnet_name&gt;=&lt;hash_value&gt;.

    @param hash_id the id of hash algorithm
    @return name

  RHASH_API const char* rhash_get_magnet_name(unsigned hash_id);
}
  rhash_get_magnet_name: function(hash_id: UInt32): PAnsiChar; cdecl; // get name part of magnet urn

{$endregion INFORMATION FUNCTIONS}




{$region ' ------------------------- HASH SUM OUTPUT INTERFACE --------------------------------- '}

{
  TRHashByteResult = array[0..(RHASH_MAX_DIGEST_SIZE * 1) - 1] of Byte;
  TRHashCharResult = array[0..(RHASH_MAX_DIGEST_SIZE * 2) - 1] of AnsiChar;
}


{
  Print a text presentation of a given hash sum to the specified buffer.

    @param output a buffer to print the hash to
    @param bytes a hash sum to print
    @param size a size of hash sum in bytes
    @param flags  a bit-mask controlling how to format the hash sum, can be a mix of the flags: RHPR_RAW, RHPR_HEX, RHPR_BASE32,
                  RHPR_BASE64, RHPR_UPPERCASE, RHPR_REVERSE
    @return the number of written characters

  RHASH_API size_t rhash_print_bytes(char* output, const unsigned char* bytes, size_t size, int flags);
}
  rhash_print_bytes: function(var output: TRHashCharResult; {%H-}bytes: TRHashByteResult; size: size_t; flags: integer): size_t; cdecl;


{
  Print text presentation of a hash sum with given hash_id to the specified output buffer. If the hash_id is zero, then print the hash sum
  with the lowest id stored in the hash context.
  The function call fails if the context doesn't include a hash with the given hash_id.

    @param output a buffer to print the hash to
    @param context algorithms state
    @param hash_id id of the hash sum to print or 0 to print the first hash saved in the context.
    @param flags  a bitmask controlling how to print the hash. Can contain flags RHPR_UPPERCASE, RHPR_HEX, RHPR_BASE32, RHPR_BASE64, etc.
    @return the number of written characters on success or 0 on fail

  RHASH_API size_t rhash_print(char* output, rhash ctx, unsigned hash_id, int flags);
}
  rhash_print: function(var output: TRHashCharResult; context: rhash; hash_id: UInt32; flags: integer): size_t; cdecl;


{
  Print magnet link with given filepath and calculated hash sums into the output buffer. The hash_mask can limit which hash values
  will be printed. The function returns the size of the required buffer. If output is NULL the .

    @param output a string buffer to receive the magnet link or NULL
    @param filepath the file path to be printed or NULL
    @param context algorithms state
    @param hash_mask bit mask of the hash sums to add to the link
    @param flags   can be combination of bits RHPR_UPPERCASE, RHPR_NO_MAGNET, RHPR_FILESIZE
    @return number of written characters, including terminating '\0' on success, 0 on fail

  RHASH_API size_t rhash_print_magnet(char* output, const char* filepath, rhash context, unsigned hash_mask, int flags);
}
  rhash_print_magnet: function(var output: TRHashCharResult; filepath: PAnsiChar; context: rhash; hash_mask: UInt32; flags: integer): size_t; cdecl;


{$endregion HASH SUM OUTPUT INTERFACE}




function RH_LoadLib(const LibFile: string): Boolean;
function RH_UnloadLib: Boolean;
function RH_GetHashNameByID(const hash_id: UInt32): string;


var
  RHLibHandle: {$IFDEF FPC}TLibHandle = dynlibs.NilHandle; {$ELSE} THandle = 0;{$ENDIF}
  RHLibFile: string = '';


implementation


function RH_GetProcAddress(ProcName: PChar; var Addr: Pointer): Boolean;
begin
  Addr := GetProcAddress(RHLibHandle, ProcName);
  Result := Addr <> nil;
end;

function RH_LoadLib(const LibFile: string): Boolean;
begin
  Result := False;
  RHLibFile := '';

  {$IFDEF FPC}
  if RHLibHandle = dynlibs.NilHandle then RHLibHandle := LoadLibrary(PChar(LibFile));
  {$ELSE}
  if RHLibHandle = 0 then RHLibHandle := LoadLibrary(PChar(LibFile));
  {$ENDIF}


  {$IFDEF FPC}
  if RHLibHandle <> dynlibs.NilHandle then
  {$ELSE}
  if RHLibHandle <> 0 then
  {$ENDIF}
  begin
    RHLibFile := LibFile;
    Result :=

      RH_GetProcAddress('rhash_library_init', @rhash_library_init) and

      // --------------------- High-Level ------------------------
      RH_GetProcAddress('rhash_msg', @rhash_msg) and
      RH_GetProcAddress('rhash_file', @rhash_file) and
      {$IFDEF MSWINDOWS}
      RH_GetProcAddress('rhash_wfile', @rhash_wfile) and
      {$ENDIF}

      // --------------------- Low-Level -------------------------
      RH_GetProcAddress('rhash_init', @rhash_init) and
      RH_GetProcAddress('rhash_update', @rhash_update) and
      RH_GetProcAddress('rhash_file_update', @rhash_file_update) and
      RH_GetProcAddress('rhash_final', @rhash_final) and
      RH_GetProcAddress('rhash_reset', @rhash_reset) and
      RH_GetProcAddress('rhash_free', @rhash_free) and
      RH_GetProcAddress('rhash_set_callback', @rhash_set_callback) and

      // --------------------- Information -----------------------
      RH_GetProcAddress('rhash_count', @rhash_count) and
      RH_GetProcAddress('rhash_get_digest_size', @rhash_get_digest_size) and
      RH_GetProcAddress('rhash_get_hash_length', @rhash_get_hash_length) and
      RH_GetProcAddress('rhash_is_base32', @rhash_is_base32) and
      RH_GetProcAddress('rhash_get_name', @rhash_get_name) and
      RH_GetProcAddress('rhash_get_magnet_name', @rhash_get_magnet_name) and

      // --------------------- Hash sum output -------------------
      RH_GetProcAddress('rhash_print_bytes', @rhash_print_bytes) and
      RH_GetProcAddress('rhash_print', @rhash_print) and
      RH_GetProcAddress('rhash_print_magnet', @rhash_print_magnet)

      ;
  end;
end;

function RH_UnloadLib: Boolean;
begin
  RHLibFile := '';

  {$IFDEF FPC}
  if RHLibHandle = dynlibs.NilHandle then Result := True
  else Result := FreeLibrary(RHLibHandle);
  if Result then RHLibHandle := dynlibs.NilHandle;
  {$ELSE}
  if RHLibHandle = 0 then Result := True
  else Result := FreeLibrary(RHLibHandle);
  if Result then RHLibHandle := 0;
  {$ENDIF}
end;

function RH_GetHashNameByID(const hash_id: UInt32): string;
begin
  case hash_id of
    RHASH_CRC32:  Result := 'CRC32';
    RHASH_CRC32C: Result := 'CRC32C';
    RHASH_MD4  : Result := 'MD4';
    RHASH_MD5  : Result := 'MD5';
    RHASH_SHA1 : Result := 'SHA-1';

    RHASH_SHA224    : Result := 'SHA2-224';
    RHASH_SHA256    : Result := 'SHA2-256';
    RHASH_SHA384    : Result := 'SHA2-384';
    RHASH_SHA512    : Result := 'SHA2-512';

    RHASH_SHA3_224  : Result := 'SHA3-224';
    RHASH_SHA3_256  : Result := 'SHA3-256';
    RHASH_SHA3_384  : Result := 'SHA3-384';
    RHASH_SHA3_512  : Result := 'SHA3-512';

    RHASH_TIGER: Result := 'Tiger';
    RHASH_TTH  : Result := 'TTH';
    RHASH_BTIH : Result := 'BTIH';
    RHASH_ED2K : Result := 'ED2K';
    RHASH_AICH : Result := 'AICH';
    RHASH_WHIRLPOOL: Result := 'Whirlpool';
    RHASH_RIPEMD160: Result := 'RIPEMD-160';
    RHASH_GOST94     : Result := 'GOST94';
    RHASH_GOST94_CRYPTOPRO: Result := 'GOST94 CryptoPro';
    RHASH_HAS160    : Result := 'HAS-160';
    RHASH_GOST12_256: Result := 'GOST12-256';
    RHASH_GOST12_512: Result := 'GOST12-512';
    RHASH_SNEFRU128 : Result := 'Snefru-128';
    RHASH_SNEFRU256 : Result := 'Snefru-256';
    RHASH_EDONR256  : Result := 'Edon-R256';
    RHASH_EDONR512  : Result := 'Edon-R512';

  else
    Result := ''; // unknown/invalid
  end;

end;



end.
