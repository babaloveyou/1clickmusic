{ KOL MCK } // Do not remove this line!

procedure NewForm1( var Result: PForm1; AParent: PControl );
begin

  {$IFDEF KOLCLASSES}
  Result := PForm1.Create;
  {$ELSE OBJECTS}
  New( Result, Create );
  {$ENDIF KOL CLASSES/OBJECTS}
  Result.Form := NewForm( AParent, '1ClickMusic' ).SetPosition( 228, 289 );
  Applet :=  Result.Form;
  Result.Form.Add2AutoFree( Result );
{$IFDEF UNICODE_CTRLS}
     Result.Form.SetUnicode(TRUE);
{$ENDIF UNICODE_CTRLS}
   {$IFDEF USE_NAMES}
    Result.Form.SetName( Applet, 'Form1' );
   {$ENDIF}
    Result.Form.Style := Result.Form.Style and not WS_MAXIMIZEBOX;
    Result.Form.SetClientSize( 608, 291 );
    Result.Form.IconLoad( hInstance, 'ZFORM1_TRAYICON1' );
    Result.Form.Font.FontPitch := fpFixed;
      Result.Form.OnMessage := Result.KOLForm1Message;
      Result.Form.OnDestroy := Result.KOLForm1Destroy;
    NewMenu( Result.Form, 0, [ '' ], nil );

    Result.Tray := NewBAPTrayIcon( Result.Form );
   {$IFDEF USE_NAMES}
    Result.Tray.SetName( Result.Form, 'Tray' ); 
   {$ENDIF}
  Result.Form.Add2AutoFree( Result.Tray );
      Result.Tray.OnMouseUp := Result.TrayMouseUp;

    Result.Timer := NewTimer( 250 );
   {$IFDEF USE_NAMES}
    Result.Timer.SetName( Result.Form, 'Timer' ); 
   {$ENDIF}
  Result.Form.Add2AutoFree( Result.Timer );
      Result.Timer.OnTimer := Result.TimerTimer;

   {$IFDEF USE_NAMES}
    Result.PopupMenu.SetName( Result.Form, 'PopupMenu' ); 
   {$ENDIF}
    // Result.lblbuffer.TabOrder = -1
    Result.lblbuffer := NewLabel( Result.Form, '' ).SetPosition( 448, 61 ).SetSize( 157, 20 );
   {$IFDEF USE_NAMES}
    Result.lblbuffer.SetName( Result.Form, 'lblbuffer' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblbuffer.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblbuffer.TextAlign := KOL.taRight;
    Result.lblbuffer.VerticalAlign := KOL.vaCenter;
    // Result.lblhelp.TabOrder = -1
    Result.lblhelp := NewLabel( Result.Form, 'Hotkeys:'+#13+#10+' CTRL + UP  : raise volume'+#13+#10+' CTRL + Down : decrease volume'+#13+#10+' CTRL + END : Stop'+#13+#10+' CTRL + HOME : Play'+#13+#10+' CTRL + (F1..F12) : Hotkey for Channels'+#13+#10+#13+#10+'!!! Right click on a channel to bind it for a hotkey'+#13+#10+'!!! Left or Right click on TrayIcon to Hide/Sho'+'w'+#13+#10+'Middle click on TrayIcon to see INFO' ).SetPosition( 233, 136 ).SetSize( 259, 153 );
   {$IFDEF USE_NAMES}
    Result.lblhelp.SetName( Result.Form, 'lblhelp' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblhelp.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblhelp.Font.Color := clMaroon;
    Result.lblhelp.Font.FontHeight := 15;
    Result.lblhelp.Font.FontWidth := 5;
    Result.lblhelp.Font.FontName := 'Arial';
    // Result.lblradio.TabOrder = -1
    Result.lblradio := NewLabel( Result.Form, '' ).SetPosition( 237, 96 ).SetSize( 233, 0 );
   {$IFDEF USE_NAMES}
    Result.lblradio.SetName( Result.Form, 'lblradio' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblradio.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblradio.Font.Color := clPurple;
    // Result.lblstatus.TabOrder = -1
    Result.lblstatus := NewLabel( Result.Form, '<<<<  Selecione um canal' ).SetPosition( 237, 60 ).SetSize( 196, 17 );
   {$IFDEF USE_NAMES}
    Result.lblstatus.SetName( Result.Form, 'lblstatus' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblstatus.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    // Result.lbltrack.TabOrder = -1
    Result.lbltrack := NewLabel( Result.Form, '' ).SetPosition( 237, 8 ).SetSize( 367, 38 ).MakeWordWrap;
   {$IFDEF USE_NAMES}
    Result.lbltrack.SetName( Result.Form, 'lbltrack' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lbltrack.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lbltrack.Font.FontStyle := [ fsBold ];
    // Result.channeltree.TabOrder = 0
    Result.channeltree := NewTreeView( Result.Form, [ tvoLinesRoot, tvoTrackSelect, tvoSingleExpand ], nil, nil ).SetAlign ( caLeft ).SetSize( 223, 0 );
   {$IFDEF USE_NAMES}
    Result.channeltree.SetName( Result.Form, 'channeltree' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.channeltree.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.channeltree.Color := clWindow;
    // Result.btoptions.TabOrder = 1
    Result.btoptions := NewButton( Result.Form, 'Options' ).SetPosition( 528, 264 ).SetSize( 76, 0 );
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
    Result.Timer.Enabled := True;
      Result.btoptions.OnClick := Result.btoptionsClick;
    Result.Form.CenterOnParent.CanResize := False;
    Result.Form.MinimizeNormalAnimated;
    Result.KOLForm1FormCreate( Result );

end;

