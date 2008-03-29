unit static_mpg123;
interface

uses windows, SysUtils;

const
  libmpg123 = 'libmpg123-0.dll';

type
  PDWord = ^DWORD;
  PPbyte = ^PByte;
  PPchar = ^PChar;
  Pdouble = ^double;
  PPlongint = ^Plongint;
  off_t = Integer;
  Poff_t = ^off_t;
  PPoff_t = ^Poff_t;
  size_t = cardinal;
  Psize_t = ^size_t;
  PPsize_T = ^Psize_t;

type
  Pmpg123_handle_struct = ^Tmpg123_handle_struct;
  Tmpg123_handle_struct = packed record
    {undefined structure}
  end;

  Tmpg123_handle = Tmpg123_handle_struct;
  Pmpg123_handle = ^Tmpg123_handle;

function mpg123_init: Longint; cdecl; external libmpg123 Name 'mpg123_init';

procedure mpg123_exit; cdecl; external libmpg123 Name 'mpg123_exit';

function mpg123_new(decoder: PChar; Error: Plongint): Pmpg123_handle; cdecl; external libmpg123 Name 'mpg123_new';

procedure mpg123_delete(mh: Pmpg123_handle); cdecl; external libmpg123 Name 'mpg123_delete';

type
  Tmpg123_parms = Longint;
const
  MPG123_VERBOSE = 0;
  MPG123_FLAGS = 1;
  MPG123_ADD_FLAGS = 2;
  MPG123_FORCE_RATE = 3;
  MPG123_DOWN_SAMPLE = 4;
  MPG123_RVA = 5;
  MPG123_DOWNSPEED = 6;
  MPG123_UPSPEED = 7;
  MPG123_START_FRAME = 8;
  MPG123_DECODE_FRAMES = 9;
  MPG123_ICY_INTERVAL = 10;
  MPG123_OUTSCALE = 11;
  MPG123_TIMEOUT = 12;
  MPG123_REMOVE_FLAGS = 13;
  MPG123_RESYNC_LIMIT = 14;

type
  Tmpg123_param_flags = Longint;
const
  MPG123_FORCE_MONO = $7;
  MPG123_MONO_LEFT = $1;
  MPG123_MONO_RIGHT = $2;
  MPG123_MONO_MIX = $4;
  MPG123_FORCE_STEREO = $8;
  MPG123_FORCE_8BIT = $10;
  MPG123_QUIET = $20;
  MPG123_GAPLESS = $40;
  MPG123_NO_RESYNC = $80;

type
  Tmpg123_param_rva = Longint;
const
  MPG123_RVA_OFF = 0;
  MPG123_RVA_MIX = 1;
  MPG123_RVA_ALBUM = 2;
  MPG123_RVA_MAX = MPG123_RVA_ALBUM;

function mpg123_param(mh: Pmpg123_handle; _type: Tmpg123_parms; value: Longint; fvalue: double): Longint; cdecl; external libmpg123 Name 'mpg123_param';

function mpg123_getparam(mh: Pmpg123_handle; _type: Tmpg123_parms; val: Plongint; fval: Pdouble): Longint; cdecl; external libmpg123 Name 'mpg123_getparam';

type
  Tmpg123_errors = Longint;
const
  MPG123_DONE = -(12);
  MPG123_NEW_FORMAT = -(11);
  MPG123_NEED_MORE = -(10);
  MPG123_ERR = -(1);
  MPG123_OK = 0;
  MPG123_BAD_OUTFORMAT = 1;
  MPG123_BAD_CHANNEL = 2;
  MPG123_BAD_RATE = 3;
  MPG123_ERR_16TO8TABLE = 4;
  MPG123_BAD_PARAM = 5;
  MPG123_BAD_BUFFER = 6;
  MPG123_OUT_OF_MEM = 7;
  MPG123_NOT_INITIALIZED = 8;
  MPG123_BAD_DECODER = 9;
  MPG123_BAD_HANDLE = 10;
  MPG123_NO_BUFFERS = 11;
  MPG123_BAD_RVA = 12;
  MPG123_NO_GAPLESS = 13;
  MPG123_NO_SPACE = 14;
  MPG123_BAD_TYPES = 15;
  MPG123_BAD_BAND = 16;
  MPG123_ERR_NULL = 17;
  MPG123_ERR_READER = 18;
  MPG123_NO_SEEK_FROM_END = 19;
  MPG123_BAD_WHENCE = 20;
  MPG123_NO_TIMEOUT = 21;
  MPG123_BAD_FILE = 22;
  MPG123_NO_SEEK = 23;
  MPG123_NO_READER = 24;
  MPG123_BAD_PARS = 25;
  MPG123_BAD_INDEX_PAR = 26;
  MPG123_OUT_OF_SYNC = 27;
  MPG123_RESYNC_FAIL = 28;

function mpg123_plain_strerror(errcode: Longint): PChar; cdecl; external libmpg123 Name 'mpg123_plain_strerror';

function mpg123_strerror(mh: Pmpg123_handle): PChar; cdecl; external libmpg123 Name 'mpg123_strerror';

function mpg123_errcode(mh: Pmpg123_handle): Longint; cdecl; external libmpg123 Name 'mpg123_errcode';

function mpg123_decoders: PPChar; cdecl; external libmpg123 Name 'mpg123_decoders';

function mpg123_supported_decoders: PPChar; cdecl; external libmpg123 Name 'mpg123_supported_decoders';

function mpg123_decoder(mh: Pmpg123_handle; decoder_name: PChar): Longint; cdecl; external libmpg123 Name 'mpg123_decoder';

type
  Tmpg123_enc_enum = Longint;
const
  MPG123_ENC_16 = $40;
  MPG123_ENC_SIGNED = $80;
  MPG123_ENC_8 = $0F;
  MPG123_ENC_SIGNED_16 = (MPG123_ENC_16 or MPG123_ENC_SIGNED) or $10;
  MPG123_ENC_UNSIGNED_16 = MPG123_ENC_16 or $20;
  MPG123_ENC_UNSIGNED_8 = $01;
  MPG123_ENC_SIGNED_8 = MPG123_ENC_SIGNED or $02;
  MPG123_ENC_ULAW_8 = $04;
  MPG123_ENC_ALAW_8 = $08;
  MPG123_ENC_ANY = ((((MPG123_ENC_SIGNED_16 or MPG123_ENC_UNSIGNED_16) or MPG123_ENC_UNSIGNED_8) or MPG123_ENC_SIGNED_8) or MPG123_ENC_ULAW_8) or MPG123_ENC_ALAW_8;

type
  Tmpg123_channelcount = Longint;
const
  MPG123_MONO = 1;
  MPG123_STEREO = 2;

procedure mpg123_rates(list: PPlongint; number: Psize_t); cdecl; external libmpg123 Name 'mpg123_rates';

procedure mpg123_encodings(list: PPlongint; number: Psize_t); cdecl; external libmpg123 Name 'mpg123_encodings';

function mpg123_format_none(mh: Pmpg123_handle): Longint; cdecl; external libmpg123 Name 'mpg123_format_none';

function mpg123_format_all(mh: Pmpg123_handle): Longint; cdecl; external libmpg123 Name 'mpg123_format_all';

function mpg123_format(mh: Pmpg123_handle; rate: Longint; channels: Longint; encodings: Longint): Longint; cdecl; external libmpg123 Name 'mpg123_format';

function mpg123_format_support(mh: Pmpg123_handle; rate: Longint; encoding: Longint): Longint; cdecl; external libmpg123 Name 'mpg123_format_support';

function mpg123_getformat(mh: Pmpg123_handle; rate: Plongint; channels: Plongint; encoding: Plongint): Longint; cdecl; external libmpg123 Name 'mpg123_getformat';

function mpg123_open(mh: Pmpg123_handle; path: PChar): Longint; cdecl; external libmpg123 Name 'mpg123_open';

function mpg123_open_fd(mh: Pmpg123_handle; fd: Longint): Longint; cdecl; external libmpg123 Name 'mpg123_open_fd';

function mpg123_open_feed(mh: Pmpg123_handle): Longint; cdecl; external libmpg123 Name 'mpg123_open_feed';

function mpg123_close(mh: Pmpg123_handle): Longint; cdecl; external libmpg123 Name 'mpg123_close';

function mpg123_read(mh: Pmpg123_handle; outmemory: PByte; outmemsize: size_t; done: Psize_t): Longint; cdecl; external libmpg123 Name 'mpg123_read';

function mpg123_decode(mh: Pmpg123_handle; inmemory: PByte; inmemsize: size_t; outmemory: PByte; outmemsize: size_t;
  done: Psize_t): Longint; cdecl; external libmpg123 Name 'mpg123_decode';

function mpg123_decode_frame(mh: Pmpg123_handle; num: Poff_t; audio: PPbyte; bytes: Psize_t): Longint; cdecl; external libmpg123 Name 'mpg123_decode_frame';

function mpg123_tell(mh: Pmpg123_handle): off_t; cdecl; external libmpg123 Name 'mpg123_tell';

function mpg123_tellframe(mh: Pmpg123_handle): off_t; cdecl; external libmpg123 Name 'mpg123_tellframe';

function mpg123_seek(mh: Pmpg123_handle; sampleoff: off_t; whence: Longint): off_t; cdecl; external libmpg123 Name 'mpg123_seek';

function mpg123_feedseek(mh: Pmpg123_handle; sampleoff: off_t; whence: Longint; input_offset: Poff_t): off_t; cdecl; external libmpg123 Name 'mpg123_feedseek';

function mpg123_seek_frame(mh: Pmpg123_handle; frameoff: off_t; whence: Longint): off_t; cdecl; external libmpg123 Name 'mpg123_seek_frame';

function mpg123_timeframe(mh: Pmpg123_handle; sec: double): off_t; cdecl; external libmpg123 Name 'mpg123_timeframe';

function mpg123_index(mh: Pmpg123_handle; offsets: PPoff_t; step: Poff_t; fill: Psize_t): Longint; cdecl; external libmpg123 Name 'mpg123_index';

function mpg123_position(mh: Pmpg123_handle; frame_offset: off_t; buffered_bytes: off_t; current_frame: Poff_t; frames_left: Poff_t;
  current_seconds: Pdouble; seconds_left: Pdouble): Longint; cdecl; external libmpg123 Name 'mpg123_position';

type
  Tmpg123_channels = Longint;
const
  MPG123_LEFT = $1;
  MPG123_RIGHT = $2;

function mpg123_eq(mh: Pmpg123_handle; channel: Tmpg123_channels; band: Longint; val: double): Longint; cdecl; external libmpg123 Name 'mpg123_eq';

function mpg123_reset_eq(mh: Pmpg123_handle): Longint; cdecl; external libmpg123 Name 'mpg123_reset_eq';

function mpg123_volume(mh: Pmpg123_handle; vol: double): Longint; cdecl; external libmpg123 Name 'mpg123_volume';

function mpg123_volume_change(mh: Pmpg123_handle; change: double): Longint; cdecl; external libmpg123 Name 'mpg123_volume_change';

function mpg123_getvolume(mh: Pmpg123_handle; base: Pdouble; really: Pdouble; rva_db: Pdouble): Longint; cdecl; external libmpg123 Name 'mpg123_getvolume';

type
  Tmpg123_vbr = Longint;
const
  MPG123_CBR = 0;
  MPG123_VBR = 1;
  MPG123_ABR = 2;

type
  Tmpg123_version = Longint;
const
  MPG123_1_0 = 0;
  MPG123_2_0 = 1;
  MPG123_2_5 = 2;

type
  Tmpg123_mode = Longint;
const
  MPG123_M_STEREO = 0;
  MPG123_M_JOINT = 1;
  MPG123_M_DUAL = 2;
  MPG123_M_MONO = 3;

type
  Tmpg123_flags = Longint;
const
  MPG123_CRC = $1;
  MPG123_COPYRIGHT = $2;
  MPG123_PRIVATE = $4;
  MPG123_ORIGINAL = $8;

type
  Pmpg123_frameinfo = ^Tmpg123_frameinfo;
  Tmpg123_frameinfo = packed record
    version: Tmpg123_version;
    layer: Longint;
    rate: Longint;
    mode: Tmpg123_mode;
    mode_ext: Longint;
    framesize: Longint;
    Flags: Tmpg123_flags;
    emphasis: Longint;
    bitrate: Longint;
    abr_rate: Longint;
    vbr: Tmpg123_vbr;
  end;

function mpg123_info(mh: Pmpg123_handle; mi: Pmpg123_frameinfo): Longint; cdecl; external libmpg123 Name 'mpg123_info';

function mpg123_safe_buffer: size_t; cdecl; external libmpg123 Name 'mpg123_safe_buffer';

function mpg123_scan(mh: Pmpg123_handle): Longint; cdecl; external libmpg123 Name 'mpg123_scan';

function mpg123_length(mh: Pmpg123_handle): off_t; cdecl; external libmpg123 Name 'mpg123_length';

function mpg123_tpf(mh: Pmpg123_handle): double; cdecl; external libmpg123 Name 'mpg123_tpf';

function mpg123_clip(mh: Pmpg123_handle): Longint; cdecl; external libmpg123 Name 'mpg123_clip';

type

  Pmpg123_string = ^Tmpg123_string;
  Tmpg123_string = packed record
    p: PChar;
    Size: size_t;
    fill: size_t;
  end;

procedure mpg123_init_string(sb: Pmpg123_string); cdecl; external libmpg123 Name 'mpg123_init_string';

procedure mpg123_free_string(sb: Pmpg123_string); cdecl; external libmpg123 Name 'mpg123_free_string';

function mpg123_resize_string(sb: Pmpg123_string; news: size_t): Longint; cdecl; external libmpg123 Name 'mpg123_resize_string';

function mpg123_copy_string(from: Pmpg123_string; _to_ : Pmpg123_string): Longint; cdecl; external libmpg123 Name 'mpg123_copy_string';

function mpg123_add_string(sb: Pmpg123_string; stuff: PChar): Longint; cdecl; external libmpg123 Name 'mpg123_add_string';

function mpg123_set_string(sb: Pmpg123_string; stuff: PChar): Longint; cdecl; external libmpg123 Name 'mpg123_set_string';

type
  Pmpg123_text = ^Tmpg123_text;
  Tmpg123_text = packed record
    lang: array[0..2] of Char;
    id: array[0..3] of Char;
    description: Tmpg123_string;
    Text: Tmpg123_string;
  end;

  Pmpg123_id3v2 = ^Tmpg123_id3v2;
  Tmpg123_id3v2 = packed record
    version: Byte;
    title: Pmpg123_string;
    artist: Pmpg123_string;
    album: Pmpg123_string;
    year: Pmpg123_string;
    genre: Pmpg123_string;
    comment: Pmpg123_string;
    comment_list: Pmpg123_text;
    comments: size_t;
    Text: Pmpg123_text;
    texts: size_t;
    extra: Pmpg123_text;
    extras: size_t;
  end;

  Pmpg123_id3v1 = ^Tmpg123_id3v1;
  Tmpg123_id3v1 = packed record
    tag: array[0..2] of Char;
    title: array[0..29] of Char;
    artist: array[0..29] of Char;
    album: array[0..29] of Char;
    year: array[0..3] of Char;
    comment: array[0..29] of Char;
    genre: Byte;
  end;

const
  MPG123_ID3 = $3;

  MPG123_NEW_ID3 = $1;

  MPG123_ICY = $C;

  MPG123_NEW_ICY = $4;

function mpg123_meta_check(mh: Pmpg123_handle): Longint; cdecl; external libmpg123 Name 'mpg123_meta_check';

function mpg123_id3_(mh: Pmpg123_handle; var v1: Pmpg123_id3v1; var v2: Pmpg123_id3v2): Longint; cdecl; external libmpg123 Name 'mpg123_id3';

function mpg123_icy_(mh: Pmpg123_handle; icy_meta: PPchar): Longint; cdecl; external libmpg123 Name 'mpg123_icy';

type
  Pmpg123_pars_struct = ^Tmpg123_pars_struct;
  Tmpg123_pars_struct = packed record
    {undefined structure}
  end;

  Tmpg123_pars = Tmpg123_pars_struct;
  Pmpg123_pars = ^Tmpg123_pars;

function mpg123_parnew(mp: Pmpg123_pars; decoder: PChar; Error: Plongint): Pmpg123_handle; cdecl; external libmpg123 Name 'mpg123_parnew';

function mpg123_new_pars(Error: Plongint): Pmpg123_pars; cdecl; external libmpg123 Name 'mpg123_new_pars';

procedure mpg123_delete_pars(mp: Pmpg123_pars); cdecl; external libmpg123 Name 'mpg123_delete_pars';

function mpg123_fmt_none(mp: Pmpg123_pars): Longint; cdecl; external libmpg123 Name 'mpg123_fmt_none';

function mpg123_fmt_all(mp: Pmpg123_pars): Longint; cdecl; external libmpg123 Name 'mpg123_fmt_all';

function mpg123_fmt(mh: Pmpg123_pars; rate: Longint; channels: Longint; encodings: Longint): Longint; cdecl; external libmpg123 Name 'mpg123_fmt';

function mpg123_fmt_support(mh: Pmpg123_pars; rate: Longint; encoding: Longint): Longint; cdecl; external libmpg123 Name 'mpg123_fmt_support';

function mpg123_par(mp: Pmpg123_pars; _type: Tmpg123_parms; value: Longint; fvalue: double): Longint; cdecl; external libmpg123 Name 'mpg123_par';

function mpg123_getpar(mp: Pmpg123_pars; _type: Tmpg123_parms; val: Plongint; fval: Pdouble): Longint; cdecl; external libmpg123 Name 'mpg123_getpar';

function mpg123_replace_buffer(mh: Pmpg123_handle; data: PByte; Size: size_t): Longint; cdecl; external libmpg123 Name 'mpg123_replace_buffer';

function mpg123_outblock(mh: Pmpg123_handle): size_t; cdecl; external libmpg123 Name 'mpg123_outblock';

//function mpg123_replace_reader(mh:Pmpg123_handle; r_read:function (_para1:longint; _para2:pointer; _para3:size_t):Tssize_t; r_lseek:function (_para1:longint; _para2:off_t; _para3:longint):off_t):longint;cdecl;external libmpg123 name 'mpg123_re

implementation

end.

