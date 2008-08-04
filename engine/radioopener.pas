unit radioopener;

interface

uses
  SysUtils,
  Windows,
  Classes,
  DSoutput,
  mmsstream,
  mp3stream,
  obj_playlist;

function OpenRadio(const url: string; var APlayer: TRadioPlayer; const ADevice: TDSoutput): LongBool;

implementation

uses utils;

function OpenRadio(const url: string; var APlayer: TRadioPlayer; const ADevice: TDSoutput): LongBool;
var
  playlist: TPlaylist;
  i: Integer;
begin
  Result := False;
  playlist := TPlaylist.Create;
  playlist.openpls(url);
  for i := 0 to playlist.urls.Count - 1 do
  begin
    if MultiPos(['.as', '.wm'], url) or // asp aspx wmx wma
      (Pos('mms://', playlist.urls[i]) > 0) then
      APlayer := TMMS.Create(ADevice)
    else
      APlayer := TMP3.Create(ADevice);

    Result := APlayer.Open(playlist.urls[i]);
    if Result then
      Break
    else
      FreeAndNil(APlayer);
  end;
  playlist.Free;
end;

end.

