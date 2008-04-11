{ KOL MCK } // Do not remove this line!
program oneclick;
{$R 'resources.res' 'resources.rc'}

uses
KOL,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2},
  DSoutput in 'engine\DSoutput.pas',
  httpstream in 'engine\httpstream.pas',
  mmsstream in 'engine\mmsstream.pas',
  mp3stream in 'engine\mp3stream.pas',
  obj_playlist in 'engine\obj_playlist.pas',
  radioopener in 'engine\radioopener.pas';

//{$R *.res}

begin // PROGRAM START HERE -- Please do not remove this comment

{$IFDEF KOL_MCK} {$I oneclick_0.inc} {$ELSE}

  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

{$ENDIF}

end.
