unit themeengine;

interface

{$DEFINE LOADFROMFILE}

uses Windows, KOL;

type
  TThemeControlState = (stUP, stOVER, stDOWN);
  TThemeControl = record
    State: TThemeControlState;
    Rect: TRect;
  end;

type
  PTheme = ^TTheme;
  TTheme = object(TObj)
  private
    Owner: PControl;
    FupImg,
      FoverImg,
      FdownImg: PBitmap;

    FRGNDATA: _RGNDATA;
    FRGN: HRGN;

    mouse: TPoint;
    controls: array of TThemeControl;
    controlcount: Integer;
  public
    property MousePos: TPoint read mouse write mouse;
    procedure MouseMove(const Apos: TPoint);
    procedure MouseClick;
    procedure Paint;
    constructor Create(AOwner: PControl);
    destructor Destroy; virtual;
  end;

procedure NewTheme(var Theme : PTheme ;const AOwner : PControl);

procedure SaveRects(const rects : array of TRect);
procedure SaveRegion;

implementation

procedure SaveRects(const rects : array of TRect);
var
  i:Integer;
  data : PStream;
  dummy : TThemeControl;
begin
  data := NewFileStream('res/RECTS.dat',ofCreateAlways);
  i := High(rects);
  data.Write(i,4);
  for i := 0 to High(rects) do
  begin
    dummy.Rect := rects[i];
    data.Write(dummy,SizeOf(TThemeControl));
  end;
  data.Free;
end;

procedure SaveRegion;
var
  Bmp: PBitmap;
  i, j: Integer;
  transColor: TColor;
  Left, right: Integer;
  rectRgn, resultRgn: HRGN;
  data : PStream;
  resultRgnData : RGNDATA;
begin
  resultRgn := 0;
  Bmp := NewBitmap(0, 0);
  Bmp.LoadFromFile('res/up.bmp');
  
  transColor := Bmp.Pixels[0, 0];

  for i := 0 to Bmp.Height - 1 do
  begin
    Left := -1;
    for j := 0 to Bmp.Width - 1 do
    begin
      if Left < 0 then
      begin
        if Bmp.Canvas.Pixels[j, i] <> transColor then
          Left := j;
      end
      else
        if Bmp.Canvas.Pixels[j, i] = transColor then
        begin
          right := j;
          rectRgn := CreateRectRgn(Left, i, right, i + 1);
          if resultRgn = 0 then
            resultRgn := rectRgn
          else
          begin
            CombineRgn(resultRgn, resultRgn, rectRgn, RGN_OR);
            DeleteObject(rectRgn);
          end;
          Left := -1;
        end;
    end;
    if Left >= 0 then
    begin
      rectRgn := CreateRectRgn(Left, i, Bmp.Width - Left, i + 1);
      if resultRgn = 0 then
        resultRgn := rectRgn
      else
      begin
        CombineRgn(resultRgn, resultRgn, rectRgn, RGN_OR);
        DeleteObject(rectRgn);
      end;
    end;
  end;
  Bmp.Free;

  GetRegionData(resultRgn,SizeOf(resultRgnData),@resultRgnData);

  data := NewFileStream('res/RGN.dat',ofCreateAlways);
  data.Write(resultRgnData,SizeOf(RGNDATA));
  data.Free;
end;

procedure NewTheme(var Theme : PTheme ;const AOwner : PControl);
begin
  New(Theme,Create(AOwner));
end;

{ TTheme }

constructor TTheme.Create(AOwner: PControl);
var
  data: PStream;
begin
  Owner := AOwner;
  Owner.Add2AutoFree(@Self);

  FupImg := NewBitmap(0, 0);
{$IFDEF LOADFROMFILE}
  FupImg.LoadFromFile('res/up.bmp');
{$ELSE}
  FupImg.LoadFromResourceName(HInstance, 'UP');
{$ENDIF}

  FdownImg := NewBitmap(0, 0);
{$IFDEF LOADFROMFILE}
  FdownImg.LoadFromFile('res/down.bmp');
{$ELSE}
  FdownImg.LoadFromResourceName(HInstance, 'DOWN');
{$ENDIF}

  FoverImg := NewBitmap(0, 0);
{$IFDEF LOADFROMFILE}
  FoverImg.LoadFromFile('res/over.bmp');
{$ELSE}
  FoverImg.LoadFromResourceName(HInstance, 'OVER');
{$ENDIF}

{$IFDEF LOADFROMFILE}
  data := NewFileStream('res/RGN.dat', ofOpenRead);
{$ELSE}
  data := NewMemoryStream;
  Resource2Stream(data, HInstance, 'RGN', RT_RCDATA);
{$ENDIF}
  data.Read(FRGNDATA, SizeOf(RGNDATA));
  data.Free;

{$IFDEF LOADFROMFILE}
  data := NewFileStream('res/RECTS.dat', ofOpenRead);
{$ELSE}
  data := NewMemoryStream;
  Resource2Stream(data, HInstance, 'RECTS', RT_RCDATA);
{$ENDIF}
  data.Read(controlcount, 4);
  SetLength(controls, controlcount);
  data.Read(controls[0], SizeOf(TThemeControl) * controlcount);
  data.Free;

  FRGN := ExtCreateRegion(nil, SizeOf(FRGNDATA), FRGNDATA);
  SetWindowRgn(owner.Handle,FRGN,True);
end;

destructor TTheme.Destroy;
begin
  FupImg.Free;
  FdownImg.Free;
  FoverImg.Free;
end;

procedure TTheme.MouseClick;
var
  i: Integer;
begin
  for i := 0 to controlcount - 1 do
    if PointInRect(mouse, controls[i].Rect) then
      controls[i].State := stDOWN
    else
      controls[i].State := stUP;
end;

procedure TTheme.MouseMove(const Apos: TPoint);
var
  i: Integer;
begin
  mouse := Apos;
  for i := 0 to controlcount - 1 do
    if PointInRect(mouse, controls[i].Rect) then
      controls[i].State := stOVER
    else
      controls[i].State := stUP;
end;

procedure TTheme.Paint;
var
  i: Integer;
begin
  FupImg.Draw(Owner.Canvas.Handle, 0, 0);
  for i := 0 to controlcount - 1 do
    if PointInRect(mouse, controls[i].Rect) then
    begin
      if controls[i].State = stDOWN then //# DOWN
        Owner.Canvas.CopyRect(
          controls[i].Rect,
          FDownimg.Canvas,
          controls[i].Rect)
      else //# OVER
        Owner.Canvas.CopyRect(
          controls[i].Rect,
          FDownimg.Canvas,
          controls[i].Rect)
    end;
end;

end.

