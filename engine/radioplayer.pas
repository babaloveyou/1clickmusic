unit radioplayer;

interface

uses SysUtils, Windows, Classes, DSoutput, mmsstream, mp3stream, obj_playlist;

function OpenRadio(const url: string; var APlayer: TRadioPlayer; const ADevice: TDSoutput): Boolean;

implementation

function OpenRadio(const url: string; var APlayer: TRadioPlayer; const ADevice: TDSoutput): Boolean;
var
  playlist: TPlaylist;
  RadioType : TRADIOTYPE;
  i: Integer;
begin
  Result := False;

  playlist := TPlaylist.Create;
  try
    RadioType := playlist.openpls(url);
    for i := 0 to playlist.urls.Count - 1 do
    begin
      if RadioType = rtMMS then
        APlayer := TMMS.Create(ADevice)
      else
        APlayer := TMP3.Create(ADevice);

      if APlayer.open(playlist.urls[i]) then
      begin
        Result := True;
        break;
      end
      else
        FreeAndNil(APlayer);
    end;
  finally
    playlist.Free;
  end;
end;

end.

 