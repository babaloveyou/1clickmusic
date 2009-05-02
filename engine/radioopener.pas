unit radioopener;

interface

uses
  SysUtils,
  Classes,
  DSOutput,
  mmsstream, {$DEFINE MMS}
  mp3stream,  {$DEFINE MP3}
  //aacpstream, {$DEFINE AACP}
  httpsend;

function OpenRadio(const url: string; var APlayer: TRadioPlayer): LongBool;

implementation

uses utils;

// taken from fastcode posex
function PosEx(const SubStr, S: string; Offset: Integer = 1): Integer;
var
  len, lenSub: integer;
  ch: char;
  p, pSub, pStart, pStop: pchar;
label
  Loop0, Loop4,
  TestT, Test0, Test1, Test2, Test3, Test4,
  AfterTestT, AfterTest0,
  Ret, Exit;
begin;
  pSub:=pointer(SubStr);
  p:=pointer(S);

  if (p=nil) or (pSub=nil) or (Offset<1) then begin;
    Result:=0;
    goto Exit;
    end;

  lenSub:=pinteger(pSub-4)^-1;
  len:=pinteger(p-4)^;
  if (len<lenSub+Offset) or (lenSub<0) then begin;
    Result:=0;
    goto Exit;
    end;

  pStop:=p+len;
  p:=p+lenSub;
  pSub:=pSub+lenSub;
  pStart:=p;
  p:=p+Offset+3;

  ch:=pSub[0];
  lenSub:=-lenSub;
  if p<pStop then goto Loop4;
  p:=p-4;
  goto Loop0;

Loop4:
  if ch=p[-4] then goto Test4;
  if ch=p[-3] then goto Test3;
  if ch=p[-2] then goto Test2;
  if ch=p[-1] then goto Test1;
Loop0:
  if ch=p[0] then goto Test0;
AfterTest0:
  if ch=p[1] then goto TestT;
AfterTestT:
  p:=p+6;
  if p<pStop then goto Loop4;
  p:=p-4;
  if p<pStop then goto Loop0;
  Result:=0;
  goto Exit;

Test3: p:=p-2;
Test1: p:=p-2;
TestT: len:=lenSub;
  if lenSub<>0 then repeat;
    if (psub[len]<>p[len+1])
    or (psub[len+1]<>p[len+2]) then goto AfterTestT;
    len:=len+2;
    until len>=0;
  p:=p+2;
  if p<=pStop then goto Ret;
  Result:=0;
  goto Exit;

Test4: p:=p-2;
Test2: p:=p-2;
Test0: len:=lenSub;
  if lenSub<>0 then repeat;
    if (psub[len]<>p[len])
    or (psub[len+1]<>p[len+1]) then goto AfterTest0;
    len:=len+2;
    until len>=0;
  inc(p);
Ret:
  Result:=p-pStart;
Exit:
end;

procedure ParseASX(const Lines: TStrings);
var
  i, a, b: Integer;
  Line: string;
begin
  i := 0;
  while i < Lines.Count do
  begin
    Line := Lines[i];
    a := Pos('<ref', Line);
    if (a <> 0) { and (not MultiPos(['.htm', '.as', '.php', '.cgi'], Line)) } then
    begin
      a := PosEx('"', Line, a) + 1;
      b := PosEx('"', Line, a + 5);
      Lines[i] := Copy(Line, a, b - a);
      Inc(i);
    end
    else
      Lines.Delete(i);
  end;
end;

procedure ParsePLS(const Lines: TStrings);
var
  i, p: Integer;
  Line: string;
begin
  i := 0;
  while i < Lines.Count do
  begin
    Line := Lines[i];
    p := Pos('http://', Line); // can be mms or http
    if p = 0 then p := Pos('mms://', Line);

    if (p <> 0) and (Line[1] <> '#') then
    begin
      Lines[i] := Copy(Line, p, Length(Line) - p + 1);
      Inc(i);
    end
    else
      Lines.Delete(i);
  end;

end;

procedure openpls(const url: string; const urls: TStringList);
begin
  if Pos('mms://', url) <> 0 then
  begin
    urls.Add(url);
    Exit;
  end;

  // mms is the only we know for sure,
  // otherwise we will test the url for asx, m3u and pls
  HttpGetText(url, urls);
  if urls.Count = 0 then Exit;
  if urls[0] = '' then urls.Delete(0);
  // lowercase the content for parse
  urls.Text := LowerCase(urls.Text);

  if Pos('asx', urls[0]) <> 0 then
    ParseASX(urls)
  else
    if MultiPos(['playlist', 'm3u'], urls[0]) or
      (Pos('.m3u', url) <> 0) then
      ParsePLS(urls)
    else
      urls.Add(url);
end;

function OpenRadio(const url: string; var APlayer: TRadioPlayer): LongBool;
label
  _WMA_;
var
  urls: TStringList;
  i: Integer;
begin
  Result := False;
  urls := TStringList.Create;
  openpls(url, urls);
  for i := 0 to urls.Count - 1 do
  begin
    if MultiPos(['mms://','.wma'], urls[i]) then goto _WMA_;
    {$IFDEF MP3}
    APlayer := TMP3.Create();
    Result := APlayer.Open(urls[i]);
    if Result then Break;
    {$ENDIF}
    {$IFDEF AACP}
    APlayer.Free;
    APlayer := TAACP.Create();
    Result := APlayer.Open(urls[i]);
    if Result then Break;
    {$ENDIF}
    {$IFDEF MMS}
    APlayer.Free;
    _WMA_:
    APlayer := TMMS.Create();
    Result := APlayer.Open(urls[i]);
    if Result then Break;
    {$ENDIF}
    FreeAndNil(APlayer);
  end;
  urls.Free;
end;

end.

