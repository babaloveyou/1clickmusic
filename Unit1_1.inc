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
    Result.Form.SetClientSize( 638, 285 );
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

    Result.Timer := NewTimer( 500 );
   {$IFDEF USE_NAMES}
    Result.Timer.SetName( Result.Form, 'Timer' ); 
   {$ENDIF}
  Result.Form.Add2AutoFree( Result.Timer );
      Result.Timer.OnTimer := Result.TimerTimer;
    // Result.lblbuffer.TabOrder = -1
    Result.lblbuffer := NewLabel( Result.Form, '' ).SetPosition( 457, 96 ).SetSize( 176, 20 );
   {$IFDEF USE_NAMES}
    Result.lblbuffer.SetName( Result.Form, 'lblbuffer' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblbuffer.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblbuffer.Font.FontCharset := 0;
    Result.lblbuffer.TextAlign := KOL.taRight;
    Result.lblbuffer.VerticalAlign := KOL.vaCenter;
    // Result.lblhelp.TabOrder = -1
    Result.lblhelp := NewLabel( Result.Form, 'Hotkeys:'+#13+#10+' CTRL + UP  : raise volume'+#13+#10+' CTRL + Down : decrease volume'+#13+#10+' CTRL + END : Stop'+#13+#10+' CTRL + HOME : Play'+#13+#10+' CTRL + (F1..F12) : Hotkey for Channels'+#13+#10+#13+#10+'!!! Right click on a channel to bind it for a hotkey'+#13+#10+'!!! Left or Right click on TrayIcon to Hide/Sho'+'w'+#13+#10+'Middle click on TrayIcon to see INFO' ).SetPosition( 241, 136 ).SetSize( 272, 137 );
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
    Result.lblhelp.Transparent := True;
    // Result.lblradio.TabOrder = -1
    Result.lblradio := NewLabel( Result.Form, '' ).SetPosition( 245, 74 ).SetSize( 196, 0 );
   {$IFDEF USE_NAMES}
    Result.lblradio.SetName( Result.Form, 'lblradio' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblradio.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblradio.Font.Color := TColor(clPurple);
    Result.lblradio.Font.FontCharset := 0;
    // Result.lblstatus.TabOrder = -1
    Result.lblstatus := NewLabel( Result.Form, '' ).SetPosition( 528, 75 ).SetSize( 105, 17 );
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
    Result.lbltrack := NewLabel( Result.Form, '' ).SetPosition( 248, 8 ).SetSize( 369, 49 ).MakeWordWrap;
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
    Result.lbltrack.VerticalAlign := KOL.vaCenter;
    // Result.channeltree.TabOrder = 0
    Result.channeltree := NewTreeView( Result.Form, [ tvoLinesRoot, tvoTrackSelect ], nil, nil ).SetAlign ( caLeft ).SetSize( 231, 0 );
   {$IFDEF USE_NAMES}
    Result.channeltree.SetName( Result.Form, 'channeltree' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.channeltree.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.channeltree.Font.Color := TColor(clBlack);
    Result.channeltree.Font.FontStyle := [ fsBold ];
    // Result.btoptions.TabOrder = 1
    Result.btoptions := NewButton( Result.Form, 'Options' ).SetPosition( 536, 256 ).SetSize( 76, 0 );
   {$IFDEF USE_NAMES}
    Result.btoptions.SetName( Result.Form, 'btoptions' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.btoptions.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.btoptions.Font.FontStyle := [ fsBold ];
    Result.btoptions.Style := Result.btoptions.Style or BS_FLAT;
      Result.channeltree.OnMouseUp := Result.channeltreeMouseUp;
      Result.channeltree.OnSelChange := Result.channeltreeSelChange;
    {$IFDEF OVERRIDE_SCROLLBARS}
    OverrideScrollbars( Result.channeltree);
    {$ENDIF OVERRIDE_SCROLLBARS}
      Result.btoptions.OnClick := Result.btoptionsClick;
    Result.Timer.Enabled := True;
    Result.Form.CenterOnParent.CanResize := False;
    Result.Form.Perform( WM_INITMENU, 0, 0 );
    Result.KOLForm1FormCreate( Result );

end;

