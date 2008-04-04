{ KOL MCK } // Do not remove this line!

procedure NewForm1( var Result: PForm1; AParent: PControl );
begin

  {$IFDEF KOLCLASSES}
  Result := PForm1.Create;
  {$ELSE OBJECTS}
  New( Result, Create );
  {$ENDIF KOL CLASSES/OBJECTS}
  Result.Form := NewForm( AParent, '1ClickMusic' ).SetPosition( 230, 261 );
  Applet :=  Result.Form;
  Result.Form.Add2AutoFree( Result );
{$IFDEF UNICODE_CTRLS}
     Result.Form.SetUnicode(TRUE);
{$ENDIF UNICODE_CTRLS}
   {$IFDEF USE_NAMES}
    Result.Form.SetName( Applet, 'Form1' );
   {$ENDIF}
    Result.Form.Style := Result.Form.Style and not WS_MAXIMIZEBOX;
    Result.Form.SetClientSize( 617, 276 );
    Result.Form.IconLoad( hInstance, 'TRAY' );
    Result.Form.Font.FontPitch := fpFixed;
      Result.Form.OnMessage := Result.KOLForm1Message;
      Result.Form.OnDestroy := Result.KOLForm1Destroy;

    Result.Tray := NewBAPTrayIcon( Result.Form );
   {$IFDEF USE_NAMES}
    Result.Tray.SetName( Result.Form, 'Tray' ); 
   {$ENDIF}
  Result.Form.Add2AutoFree( Result.Tray );
      Result.Tray.OnMouseUp := Result.TrayMouseUp;
    // Result.lblbuffer.TabOrder = -1
    Result.lblbuffer := NewLabel( Result.Form, '' ).SetPosition( 553, 112 ).SetSize( 57, 40 );
   {$IFDEF USE_NAMES}
    Result.lblbuffer.SetName( Result.Form, 'lblbuffer' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblbuffer.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblbuffer.Font.Color := TColor(clBlue);
    Result.lblbuffer.Font.FontCharset := 0;
    Result.lblbuffer.TextAlign := KOL.taRight;
    // Result.lblhelp.TabOrder = -1
    Result.lblhelp := NewLabel( Result.Form, 'Hotkeys:'+#13+#10+' CTRL + UP  : raise volume'+#13+#10+' CTRL + Down : decrease volume'+#13+#10+' CTRL + END : Stop'+#13+#10+' CTRL + HOME : Play'+#13+#10+' CTRL + (F1..F12) : Hotkey for Channels'+#13+#10+#13+#10+'!!! Right click on a channel to bind it for a hotkey'+#13+#10+'!!! Left or Right click on TrayIcon to Hide/Sho'+'w'+#13+#10+'Middle click on TrayIcon to see INFO' ).SetPosition( 241, 120 ).SetSize( 272, 153 );
   {$IFDEF USE_NAMES}
    Result.lblhelp.SetName( Result.Form, 'lblhelp' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblhelp.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblhelp.Font.Color := TColor(clMaroon);
    Result.lblhelp.Font.FontHeight := 15;
    Result.lblhelp.Font.FontName := 'Arial';
    Result.lblhelp.Font.FontPitch := fpDefault;
    // Result.lblradio.TabOrder = -1
    Result.lblradio := NewLabel( Result.Form, '' ).SetPosition( 245, 74 ).SetSize( 212, 0 );
   {$IFDEF USE_NAMES}
    Result.lblradio.SetName( Result.Form, 'lblradio' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblradio.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblradio.Font.Color := TColor(clPurple);
    Result.lblradio.Font.FontCharset := 0;
    // Result.lblstatus.TabOrder = -1
    Result.lblstatus := NewLabel( Result.Form, '' ).SetPosition( 480, 75 ).SetSize( 130, 17 );
   {$IFDEF USE_NAMES}
    Result.lblstatus.SetName( Result.Form, 'lblstatus' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblstatus.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblstatus.Font.Color := TColor(clDefault);
    Result.lblstatus.Font.FontCharset := 0;
    Result.lblstatus.TextAlign := KOL.taRight;
    Result.lblstatus.IgnoreDefault := TRUE;
    // Result.lbltrack.TabOrder = -1
    Result.lbltrack := NewLabel( Result.Form, '' ).SetPosition( 242, 8 ).SetSize( 366, 57 ).MakeWordWrap;
   {$IFDEF USE_NAMES}
    Result.lbltrack.SetName( Result.Form, 'lbltrack' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lbltrack.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lbltrack.Font.Color := TColor(clTeal);
    Result.lbltrack.Font.FontStyle := [ fsBold ];
    Result.lbltrack.Font.FontName := 'Times New Roman';
    Result.lbltrack.Font.FontCharset := 0;
    Result.lbltrack.TextAlign := KOL.taCenter;
    // Result.channeltree.TabOrder = 0
    Result.channeltree := NewTreeView( Result.Form, [ tvoLinesRoot, tvoTrackSelect ], nil, nil ).SetAlign ( caLeft ).SetSize( 231, 0 );
   {$IFDEF USE_NAMES}
    Result.channeltree.SetName( Result.Form, 'channeltree' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.channeltree.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.channeltree.Font.Color := TColor(clBlack);
    // Result.btoptions.TabOrder = 1
    Result.btoptions := NewButton( Result.Form, 'Options' ).SetPosition( 536, 248 ).SetSize( 76, 0 );
   {$IFDEF USE_NAMES}
    Result.btoptions.SetName( Result.Form, 'btoptions' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.btoptions.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.btoptions.Font.FontStyle := [ fsBold ];
    Result.btoptions.Style := Result.btoptions.Style or BS_FLAT;
    // Result.btplay.TabOrder = 1
    Result.btplay := NewButton( Result.Form, 'Play' ).SetPosition( 536, 216 ).SetSize( 76, 0 );
   {$IFDEF USE_NAMES}
    Result.btplay.SetName( Result.Form, 'btplay' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.btplay.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.btplay.Font.FontStyle := [ fsBold ];
    Result.btplay.Style := Result.btplay.Style or BS_FLAT;
    // Result.pgrbuffer.TabOrder = 2
    Result.pgrbuffer := NewProgressBarEx( Result.Form, [ pboSmooth ] ).SetPosition( 536, 93 ).SetSize( 74, 18 );
   {$IFDEF USE_NAMES}
    Result.pgrbuffer.SetName( Result.Form, 'pgrbuffer' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.pgrbuffer.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.pgrbuffer.Visible := False;
    Result.pgrbuffer.Color := TColor($E39C5A);
    Result.pgrbuffer.ProgressColor := clBtnFace;
      Result.channeltree.OnMouseUp := Result.channeltreeMouseUp;
      Result.channeltree.OnSelChange := Result.channeltreeSelChange;
    {$IFDEF OVERRIDE_SCROLLBARS}
    OverrideScrollbars( Result.channeltree);
    {$ENDIF OVERRIDE_SCROLLBARS}
      Result.btplay.OnClick := Result.btplayClick;
      Result.btoptions.OnClick := Result.btoptionsClick;
    Result.Form.CenterOnParent.CanResize := False;
    Result.Form.Perform( WM_INITMENU, 0, 0 );
    Result.KOLForm1FormCreate( Result );

end;

