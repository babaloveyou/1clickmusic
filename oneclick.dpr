{ KOL MCK } // Do not remove this line!
program oneclick;
{$R 'resources.res' 'resources.rc'}
{$R 'winxp.res'}
uses
KOL,
  Unit1 in 'Unit1.pas' {Form1},
  obj_tweet in 'engine\obj_tweet.pas';

{$R *.res}

begin // PROGRAM START HERE -- Please do not remove this comment

{$IFDEF KOL_MCK} {$I oneclick_0.inc} {$ELSE}

  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

{$ENDIF}

end.

