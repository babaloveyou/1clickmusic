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

function OpenRadio(const url: string; var APlayer: TRadioPlayer; const ADevice: TDSoutput): Boolean;

implementation

uses utils, StrUtils;

function OpenRadio(const url: string; var APlayer: TRadioPlayer; const ADevice: TDSoutput): Boolean;
var
  playlist: TPlaylist;
  i: Integer;
begin
  Result := False;
  playlist := TPlaylist.Create;
  playlist.openpls(url);
  for i := 0 to playlist.urls.Count - 1 do
  begin
    if MultiPos(['.as', '.wma', '.wmx'], url) or
      (Pos('mms://', playlist.urls[i]) > 0) then
      APlayer := TMMS.Create(ADevice)
    else
      APlayer := TMP3.Create(ADevice);

    Result := APlayer.open(playlist.urls[i]);
    if Result then
      break
    else
      FreeAndNil(APlayer);
  end;
  playlist.Free;
end;

end.

