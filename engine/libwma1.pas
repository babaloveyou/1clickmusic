(*
  This file is a part of New Audio Components package v. 1.5
  Copyright (c) 2002-2008, Andrei Borovsky. All rights reserved.
  See the LICENSE file for more details.
  You can contact me at anb@symmetrica.net
*)

(* $Id: libwma1.pas 323 2008-02-08 19:54:47Z andrei.borovsky $ *)

unit libwma1;

(* Title: libwma1.pas
    This Delphi unit provides a simple C-style interface for reading and writing WMA files.
    (c) 2007 Andrei Borovsky *)

interface

uses
  Windows, Classes, SysUtils, ActiveX, MMSystem, wmfintf, SyncObjs;

type

  TMediaType = (mtV8, mtV9, mtLossless);

  QWORD = Int64;

   // ADDED TO REMOVE NEED OF _TYPES
  TBuffer8 = array[0..0] of Byte;
  PBuffer8 = ^TBuffer8;

  TSampleInfo = record
    Data: PBuffer8;
    Length: LongWord;
    Offset: LongWord;
  end;
  PSampleInfo = ^TSampleInfo;

  wma_async_reader = record
    status: TWMTStatus;
    reader: IWMReader;
    MaxWaitMilliseconds: LongWord;
    BufferingTime: LongWord;
    StretchFactor: Single;
    EnableTCP: Boolean;
    EnableHTTP: Boolean;
    EnableUDP: Boolean;
    BlockList: TList;
    WMReaderCallback: IWMReaderCallback;
    Event: TEvent;
    CriticalSection: TCriticalSection;
    HeaderInfo: IWMHeaderInfo;
    TimedOut: Boolean;
    Paused: Boolean;
    output: LongWord;
    has_audio: Boolean;
    channels: Integer;
    SampleRate: Integer;
    BitsPerSample: Integer;
    Bitrate: LongWord;
    duration: QWORD;
    BytesBuffered : Cardinal;
  end;
  pwma_async_reader = ^wma_async_reader;

  TWMReaderCallback = class(TInterfacedObject, IWMReaderCallback)
  private
    FReader: pwma_async_reader;
  public
    constructor Create(reader: pwma_async_reader);
    function OnStatus(Status: TWMTStatus; hr: HRESULT; dwType: TWMTAttrDataType;
      pValue: PBYTE; pvContext: Pointer): HRESULT; stdcall;
    function OnSample(dwOutputNum: LongWord; cnsSampleTime, cnsSampleDuration: Int64;
      dwFlags: LongWord; pSample: INSSBuffer; pvContext: Pointer): HRESULT; stdcall;
  end;

procedure lwma_async_reader_init(var async_reader: wma_async_reader);
procedure lwma_async_reader_open(var async_reader: wma_async_reader; const URL: WideString);
//procedure lwma_async_reader_add_logging_url(var async_reader: wma_async_reader; const URL: WideString);
//procedure lwma_async_reader_clear_logging_urls(var async_reader: wma_async_reader);
procedure lwma_async_reader_pause(var async_reader: wma_async_reader);
procedure lwma_async_reader_resume(var async_reader: wma_async_reader);
//procedure lwma_async_reader_set_proxy(var async_reader: wma_async_reader; const Protocol, Host: WideString; Port: LongWord);
//procedure lwma_async_reader_reset_stretch(var async_reader: wma_async_reader; new_stretch: Single);
procedure lwma_async_reader_get_author(var async_reader: wma_async_reader; var result: WideString);
procedure lwma_async_reader_get_title(var async_reader: wma_async_reader; var result: WideString);
procedure lwma_async_reader_get_album(var async_reader: wma_async_reader; var result: WideString);
procedure lwma_async_reader_get_genre(var async_reader: wma_async_reader; var result: WideString);
procedure lwma_async_reader_get_track(var async_reader: wma_async_reader; var result: WideString);
procedure lwma_async_reader_get_year(var async_reader: wma_async_reader; var result: WideString);
procedure lwma_async_reader_get_copyright(var async_reader: wma_async_reader; var result: WideString);
procedure lwma_async_reader_get_data(var async_reader: wma_async_reader; var buffer: Pointer; var bufsize: LongWord);
procedure lwma_async_reader_free(var async_reader: wma_async_reader);
implementation


function GUIDSEqual(const g1, g2: TGUID): Boolean;
var
  p1, p2 : PDWORD;
begin
  Result := False;
  p1 := @g1;
  p2 := @g2;
  if p1^ <> p2^ then Exit;
  Inc(p1);
  Inc(p2);
  if p1^ <> p2^ then Exit;
  Inc(p1);
  Inc(p2);
  if p1^ <> p2^ then Exit;
  Inc(p1);
  Inc(p2);
  if p1^ <> p2^ then Exit;
  Result := True;
  {Result := False;
  if g1.D1 <> g2.D1 then Exit;
  if g1.D2 <> g2.D2 then Exit;
  if g1.D3 <> g2.D3 then Exit;
  if g1.D4[0] <> g2.D4[0] then Exit;
  if g1.D4[1] <> g2.D4[1] then Exit;
  if g1.D4[2] <> g2.D4[2] then Exit;
  if g1.D4[3] <> g2.D4[3] then Exit;
  if g1.D4[4] <> g2.D4[4] then Exit;
  if g1.D4[5] <> g2.D4[5] then Exit;
  if g1.D4[6] <> g2.D4[6] then Exit;
  if g1.D4[7] <> g2.D4[7] then Exit;
  Result := True;}
end;

procedure lwma_async_reader_init(var async_reader: wma_async_reader);
begin
  FillChar(async_reader, SizeOf(async_reader), 0);
  async_reader.MaxWaitMilliseconds := 10000;
  async_reader.StretchFactor := 1.0;
  CoInitialize(nil);
  if WMCreateReader(nil, 1, async_reader.reader) <> S_OK then
    async_reader.reader := nil;
end;

procedure lwma_async_reader_open(var async_reader: wma_async_reader; const URL: WideString);
var
  WMReaderCallback: TWMReaderCallback;
  OutputCount: LongWord;
  i, size: LongWord;
  MediaProps: IWMOutputMediaProps;
  MediaType: PWMMEDIATYPE;
  format: PWAVEFORMATEX;
  datatype: WMT_ATTR_DATATYPE;
  len, astream: Word;
  res: HResult;
  NetworkConfig: IWMReaderNetworkConfig;
begin
  NetworkConfig := async_reader.reader as IWMReaderNetworkConfig;
  if async_reader.EnableTCP then
    NetworkConfig.SetEnableTCP(True);
  if async_reader.EnableHTTP then
    NetworkConfig.SetEnableHTTP(True);
  if async_reader.EnableUDP then
    NetworkConfig.SetEnableUDP(True);
  if async_reader.BufferingTime <> 0 then
    if NetworkConfig.SetBufferingTime(async_reader.BufferingTime) <> S_OK then
      raise Exception.Create('Failed seting buffering.');
  async_reader.Event := TEvent.Create(nil, False, False, '');
  async_reader.CriticalSection := TCriticalSection.Create;
  WMReaderCallback := TWMReaderCallback.Create(@async_reader);
  async_reader.WMReaderCallback := WMReaderCallback as IWMReaderCallback;
  res := async_reader.reader.Open(PWideChar(URL), async_reader.WMReaderCallback, nil);
  if res <> S_OK then
  begin
    raise Exception.Create('Result ' + IntToStr(res));
    async_reader.reader := nil;
    async_reader.WMReaderCallback := nil;
    async_reader.Event.Free;
    async_reader.CriticalSection.Free;
    Exit;
  end;
  async_reader.Event.WaitFor(async_reader.MaxWaitMilliseconds);
  if async_reader.status <> WMT_OPENED then
  begin
    async_reader.reader := nil;
    async_reader.WMReaderCallback := nil;
    async_reader.Event.Free;
    async_reader.CriticalSection.Free;
    async_reader.TimedOut := True;
    Exit;
  end;
  if async_reader.reader.GetOutputCount(OutputCount) <> S_OK then
  begin
    async_reader.reader := nil;
    async_reader.WMReaderCallback := nil;
    async_reader.Event.Free;
    async_reader.CriticalSection.Free;
    Exit;
  end;
  for i := 0 to OutputCount - 1 do
  begin
    async_reader.reader.GetOutputProps(i, MediaProps);
    MediaProps.GetMediaType(nil, size);
    GetMem(MediaType, size);
    MediaProps.GetMediaType(MediaType, size);
    if GUIDSEqual(MediaType.majortype, WMMEDIATYPE_Audio) and GUIDSEqual(MediaType.formattype, WMFORMAT_WaveFormatEx) then
    begin
      async_reader.has_audio := True;
      async_reader.output := i;
      format := PWAVEFORMATEX(MediaType.pbFormat);
      async_reader.channels := format.nChannels;
      async_reader.SampleRate := format.nSamplesPerSec;
      async_reader.BitsPerSample := format.wBitsPerSample;
    end;
    FreeMem(MediaType);
    MediaProps := nil;
  end;
  if async_reader.has_audio then
  begin
    len := 8;
    astream := 0;
    async_reader.reader.QueryInterface(IID_IWMHeaderInfo, async_reader.HeaderInfo);
    if async_reader.HeaderInfo.GetAttributeByName(astream, g_wszWMDuration, datatype, PByte(@(async_reader.duration)), len) <> S_OK then
      async_reader.duration := 0;
    async_reader.duration := Round(async_reader.duration / 1.E7);
    len := 4;
    if async_reader.HeaderInfo.GetAttributeByName(astream, g_wszWMCurrentBitrate, datatype, PByte(@async_reader.Bitrate), len) <> S_OK then
      async_reader.Bitrate := 0;
    async_reader.BlockList := TList.Create;
    res := async_reader.reader.Start(0, 0, async_reader.StretchFactor, nil);
    if res <> S_OK then
    begin
      raise Exception.Create('Result ' + IntToHex(res, 8));
      async_reader.reader := nil;
      async_reader.WMReaderCallback := nil;
      async_reader.Event.Free;
      async_reader.CriticalSection.Free;
      Exit;
    end;
  end;
end;

procedure lwma_async_reader_pause(var async_reader: wma_async_reader);
begin
  async_reader.reader.Pause;
  async_reader.Paused := True;
end;

procedure lwma_async_reader_resume(var async_reader: wma_async_reader);
begin
  async_reader.reader.Resume;
end;

{procedure lwma_async_reader_set_proxy(var async_reader: wma_async_reader; const Protocol, Host: WideString; Port: LongWord);
var
  NetworkConfig: IWMReaderNetworkConfig;
begin
  NetworkConfig := async_reader.reader as IWMReaderNetworkConfig;
  NetworkConfig.SetProxyHostName(PWideChar(Protocol), PWideChar(Host));
  NetworkConfig.SetProxyPort(PWideChar(Protocol), Port)
end;

procedure lwma_async_reader_add_logging_url(var async_reader: wma_async_reader; const URL: WideString);
var
  NetworkConfig: IWMReaderNetworkConfig;
begin
  NetworkConfig := async_reader.reader as IWMReaderNetworkConfig;
  if NetworkConfig.AddLoggingUrl(PWideChar(URL)) <> S_OK then
    raise Exception.Create('Canoot add a logging URL');
end;

procedure lwma_async_reader_clear_logging_urls(var async_reader: wma_async_reader);
var
  NetworkConfig: IWMReaderNetworkConfig;
begin
  NetworkConfig := async_reader.reader as IWMReaderNetworkConfig;
  NetworkConfig.ResetLoggingUrlList;
end;


procedure lwma_async_reader_reset_stretch(var async_reader: wma_async_reader; new_stretch: Single);
begin
  async_reader.reader.Pause;
  async_reader.reader.Start(WM_START_CURRENTPOSITION, 0, new_stretch, nil);
end;   }

procedure get_async_tag(var async_reader: wma_async_reader; name: PWideChar; var result: WideString);
var
  stream: Word;
  datatype: WMT_ATTR_DATATYPE;
  len: Word;
begin
  stream := 0;
  if async_reader.HeaderInfo.GetAttributeByName(stream, name, datatype, nil, len) <> S_OK then
  begin
    result := '';
    Exit;
  end;
  SetLength(result, len div 2);
  if async_reader.HeaderInfo.GetAttributeByName(stream, name, datatype, PByte(@result[1]), len) <> S_OK then
  begin
    result := '';
    Exit;
  end;
end;


procedure lwma_async_reader_get_author(var async_reader: wma_async_reader; var result: WideString);
begin
  get_async_tag(async_reader, g_wszWMAuthor, result);
end;

procedure lwma_async_reader_get_title(var async_reader: wma_async_reader; var result: WideString);
begin
  get_async_tag(async_reader, g_wszWMTitle, result);
end;

procedure lwma_async_reader_get_album(var async_reader: wma_async_reader; var result: WideString);
begin
  get_async_tag(async_reader, g_wszWMAlbumTitle, result);
end;

procedure lwma_async_reader_get_genre(var async_reader: wma_async_reader; var result: WideString);
begin
  get_async_tag(async_reader, g_wszWMGenre, result);
end;

procedure lwma_async_reader_get_track(var async_reader: wma_async_reader; var result: WideString);
begin
  get_async_tag(async_reader, g_wszWMTrack, result);
end;

procedure lwma_async_reader_get_year(var async_reader: wma_async_reader; var result: WideString);
begin
  get_async_tag(async_reader, g_wszWMYear, result);
end;

procedure lwma_async_reader_get_copyright(var async_reader: wma_async_reader; var result: WideString);
begin
  get_async_tag(async_reader, g_wszWMCopyright, result);
end;


function has_data_block(var async_reader: wma_async_reader): Boolean;
begin
  Result := False;
  if async_reader.BlockList.Count = 0 then
  begin
    if not async_reader.Paused then
    begin
      if (async_reader.status = WMT_CLOSED) or async_reader.TimedOut or (async_reader.status = WMT_EOF) then
      begin
        async_reader.StretchFactor := 1.0;
        Exit;
      end;
    end
    else
    begin
      async_reader.status := WMT_STARTED;
      async_reader.Paused := False;
    end;
    async_reader.Event.WaitFor(async_reader.MaxWaitMilliseconds);
    if async_reader.BlockList.Count = 0 then
    begin
      async_reader.TimedOut := True;
      Exit;
    end;
  end;
  Result := True;
end;

procedure lwma_async_reader_get_data(var async_reader: wma_async_reader; var buffer: Pointer; var bufsize: LongWord);
var
  SI: PSampleInfo;
begin
  buffer := nil;
  repeat
    //if not has_data_block(async_reader) then
    if async_reader.BlockList.Count = 0 then
    begin
      bufsize := 0;
      Exit;
    end;
    //async_reader.CriticalSection.Enter;
    SI := PSampleInfo(async_reader.BlockList.First);
    //async_reader.CriticalSection.Leave;
    if SI.Offset = SI.Length then
    begin
      async_reader.CriticalSection.Enter;
      async_reader.BlockList.Delete(0);
      async_reader.CriticalSection.Leave;
      Freemem(SI.Data);
      Freemem(SI);
    end
    else
    begin
      buffer := @(SI.Data[SI.Offset]);
      if bufsize > SI.Length - SI.Offset then
      begin
        bufsize := SI.Length - SI.Offset;
        SI.Offset := SI.Length;
      end
      else
        Inc(SI.Offset, bufsize)
    end;
  until buffer <> nil;
  Dec(async_reader.BytesBuffered, bufsize);
end;

procedure lwma_async_reader_free(var async_reader: wma_async_reader);
var
  i: Integer;
  SI: PSampleInfo;
begin
  async_reader.reader.Stop;
  async_reader.reader.Close;
  async_reader.reader := nil;
  async_reader.WMReaderCallback := nil;
  async_reader.Event.SetEvent;
  async_reader.Event.Free;
  async_reader.CriticalSection.Release;
  async_reader.CriticalSection.Free;
  for i := 0 to async_reader.BlockList.Count - 1 do
  begin
    SI := async_reader.BlockList.Items[i];
    Freemem(SI.Data);
    Freemem(SI);
  end;
  async_reader.BlockList.Free;
end;

constructor TWMReaderCallback.Create;
begin
  FReader := reader;
  inherited Create;
end;

function TWMReaderCallback.OnStatus;
begin

  FReader.status := Status;
  if Status = WMT_Opened then
    FReader.Event.SetEvent;
  if hr <> S_OK then
    FReader.status := WMT_CLOSED;
       //raise EAuException.Create(IntToHex(hr, 8));
  Result := S_OK;
end;

function TWMReaderCallback.OnSample(dwOutputNum: LongWord; cnsSampleTime, cnsSampleDuration: Int64;
      dwFlags: LongWord; pSample: INSSBuffer; pvContext: Pointer): HRESULT; stdcall;
var
  Buffer: PByte;
  Length: DWord;
  SI: PSampleInfo;
begin
  if dwOutputNum = FReader.output then
  begin
    pSample.GetBufferAndLength(Buffer, Length);
    GetMem(SI, SizeOf(TSampleInfo));
    GetMem(SI.Data, Length);
    Move(Buffer^, SI.Data^, Length);
    SI.Length := Length;
    SI.Offset := 0;
    FReader.CriticalSection.Enter;
    FReader.BlockList.Add(Pointer(SI));
    FReader.CriticalSection.Leave;
    FReader.Event.SetEvent;
    FReader.Event.ResetEvent;
    Inc(FReader.BytesBuffered, Length);
  end;
  Result := S_OK;
end;


end.

