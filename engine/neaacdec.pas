
unit neaacdec;
interface

uses
  Windows,
  SysUtils,
  uDllfromMem;

const
  FAAD2_VERSION = '2.7';

  MAIN = 1;
  LC = 2;
  SSR = 3;
  LTP = 4;
  HE_AAC = 5;
  ER_LC = 17;
  ER_LTP = 19;
  LD = 23;

  DRM_ER_LC = 27;

  RAW = 0;
  ADIF = 1;
  ADTS = 2;
  LATM = 3;

  NO_SBR = 0;
  SBR_UPSAMPLED = 1;
  SBR_DOWNSAMPLED = 2;
  NO_SBR_UPSAMPLED = 3;

  FAAD_FMT_16BIT = 1;
  FAAD_FMT_24BIT = 2;
  FAAD_FMT_32BIT = 3;
  FAAD_FMT_FLOAT = 4;
  FAAD_FMT_FIXED = FAAD_FMT_FLOAT;
  FAAD_FMT_DOUBLE = 5;


  LC_DEC_CAP = 1 shl 0;

  MAIN_DEC_CAP = 1 shl 1;

  LTP_DEC_CAP = 1 shl 2;

  LD_DEC_CAP = 1 shl 3;

  ERROR_RESILIENCE_CAP = 1 shl 4;

  FIXED_POINT_CAP = 1 shl 5;

  FRONT_CHANNEL_CENTER = 1;
  FRONT_CHANNEL_LEFT = 2;
  FRONT_CHANNEL_RIGHT = 3;
  SIDE_CHANNEL_LEFT = 4;
  SIDE_CHANNEL_RIGHT = 5;
  BACK_CHANNEL_LEFT = 6;
  BACK_CHANNEL_RIGHT = 7;
  BACK_CHANNEL_CENTER = 8;
  LFE_CHANNEL = 9;
  UNKNOWN_CHANNEL = 0;

  DRMCH_MONO = 1;
  DRMCH_STEREO = 2;
  DRMCH_SBR_MONO = 3;
  DRMCH_SBR_STEREO = 4;
  DRMCH_SBR_PS_STEREO = 5;


  FAAD_MIN_STREAMSIZE = 768;

type

  PNeAACDecHandle = ^TNeAACDecHandle;
  TNeAACDecHandle = pointer;



  Pmp4AudioSpecificConfig = ^Tmp4AudioSpecificConfig;
  Tmp4AudioSpecificConfig = packed record
    objectTypeIndex: byte;
    samplingFrequencyIndex: byte;
    samplingFrequency: dword;
    channelsConfiguration: byte;
    frameLengthFlag: byte;
    dependsOnCoreCoder: byte;
    coreCoderDelay: word;
    extensionFlag: byte;
    aacSectionDataResilienceFlag: byte;
    aacScalefactorDataResilienceFlag: byte;
    aacSpectralDataResilienceFlag: byte;
    epConfig: byte;
    sbr_present_flag: char;
    forceUpSampling: char;
    downSampledSBR: char;
  end;

  PNeAACDecConfiguration = ^TNeAACDecConfiguration;
  TNeAACDecConfiguration = packed record
    defObjectType: byte;
    defSampleRate: dword;
    outputFormat: byte;
    downMatrix: byte;
    useOldADTSFormat: byte;
    dontUpSampleImplicitSBR: byte;
  end;
  TNeAACDecConfigurationPtr = PNeAACDecConfiguration;
  PNeAACDecConfigurationPtr = ^TNeAACDecConfigurationPtr;






  PNeAACDecFrameInfo = ^TNeAACDecFrameInfo;
  TNeAACDecFrameInfo = packed record
    bytesconsumed: dword;
    samples: dword;
    channels: byte;
    error: byte;
    samplerate: dword;
    sbr: byte;
    object_type: byte;
    header_type: byte;
    num_front_channels: byte;
    num_side_channels: byte;
    num_back_channels: byte;
    num_lfe_channels: byte;
    channel_position: array[0..63] of byte;
    ps: byte;
  end;

var
    //NeAACDecGetErrorMessage : function(errcode:byte):Pchar;cdecl;
    //NeAACDecGetCapabilities : function:dword;cdecl;
  NeAACDecOpen: function: TNeAACDecHandle; cdecl;
    //NeAACDecGetCurrentConfiguration : function(hDecoder:TNeAACDecHandle):TNeAACDecConfigurationPtr;cdecl;
    //NeAACDecSetConfiguration : function(hDecoder:TNeAACDecHandle; config:TNeAACDecConfigurationPtr):byte;cdecl;

  NeAACDecInit: function(hDecoder: TNeAACDecHandle; buffer: Pbyte; buffer_size: dword; samplerate: Pdword; channels: Pbyte): longint; cdecl;

    //NeAACDecInit2 : function(hDecoder:TNeAACDecHandle; pBuffer:Pbyte; SizeOfDecoderSpecificInfo:dword; samplerate:Pdword; channels:Pbyte):char;cdecl;

    //NeAACDecInitDRM : function(hDecoder:PNeAACDecHandle; samplerate:dword; channels:byte):char;cdecl;
    //NeAACDecPostSeekReset : procedure(hDecoder:TNeAACDecHandle; frame:longint);cdecl;
  NeAACDecClose: procedure(hDecoder: TNeAACDecHandle); cdecl;
  NeAACDecDecode: function(hDecoder: TNeAACDecHandle; hInfo: PNeAACDecFrameInfo; buffer: Pbyte; buffer_size: dword): pointer; cdecl;
    {NeAACDecDecode2 : function(hDecoder:TNeAACDecHandle; hInfo:PNeAACDecFrameInfo; buffer:Pbyte; buffer_size:dword; sample_buffer:Ppointer;
      sample_buffer_size:dword):pointer;cdecl;}
    //NeAACDecAudioSpecificConfig : function(pBuffer:Pbyte; buffer_size:dword; mp4ASC:Pmp4AudioSpecificConfig):char;cdecl;

implementation

{$I libfaad2.inc}

var
  libfaad2: Pointer;
initialization
  libfaad2 := memLoadLibrary(@libfaad2Data);
  NeAACDecOpen := memGetProcAddress(libfaad2, 'NeAACDecOpen');
  NeAACDecInit := memGetProcAddress(libfaad2, 'NeAACDecInit');
  NeAACDecClose := memGetProcAddress(libfaad2, 'NeAACDecClose');
  NeAACDecDecode := memGetProcAddress(libfaad2, 'NeAACDecDecode');

finalization
  memFreeLibrary(libfaad2);

end.

