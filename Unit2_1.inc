{ KOL MCK } // Do not remove this line!

procedure NewForm2( var Result: PForm2; AParent: PControl );
begin

  {$IFDEF KOLCLASSES}
  Result := PForm2.Create;
  {$ELSE OBJECTS}
  New( Result, Create );
  {$ENDIF KOL CLASSES/OBJECTS}
  Result.Form := NewForm( AParent, 'Options' ).SetPosition( 481, 245 ).Tabulate;
  Result.Form.Add2AutoFree( Result );
{$IFDEF UNICODE_CTRLS}
     Result.Form.SetUnicode(TRUE);
{$ENDIF UNICODE_CTRLS}
   {$IFDEF USE_NAMES}
    Result.Form.SetName( Applet, 'Form2' );
   {$ENDIF}
    Result.Form.Style := Result.Form.Style and not WS_MAXIMIZEBOX;
    Result.Form.SetClientSize( 287, 305 );
    // Result.lblbuffersize.TabOrder = -1
    Result.lblbuffersize := NewLabel( Result.Form, 'Direct Sound buffer size:' ).SetPosition( 16, 72 ).SetSize( 161, 0 );
   {$IFDEF USE_NAMES}
    Result.lblbuffersize.SetName( Result.Form, 'lblbuffersize' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblbuffersize.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblbuffersize.Font.FontPitch := fpFixed;
    // Result.lblpass.TabOrder = -1
    Result.lblpass := NewLabel( Result.Form, 'Pass :' ).SetPosition( 16, 212 ).SetSize( 41, 0 );
   {$IFDEF USE_NAMES}
    Result.lblpass.SetName( Result.Form, 'lblpass' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblpass.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblpass.Font.FontPitch := fpFixed;
    // Result.lbluser.TabOrder = -1
    Result.lbluser := NewLabel( Result.Form, 'User :' ).SetPosition( 16, 180 ).SetSize( 41, 0 );
   {$IFDEF USE_NAMES}
    Result.lbluser.SetName( Result.Form, 'lbluser' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lbluser.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lbluser.Font.FontPitch := fpFixed;
    // Result.tabcontrol.TabOrder = 0
    Result.tabcontrol := NewTabControl( Result.Form, [  ], [  ], nil, 0 ).SetAlign ( caTop ).SetSize( 0, 271 );
   {$IFDEF USE_NAMES}
    Result.tabcontrol.SetName( Result.Form, 'tabcontrol' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.tabcontrol.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.tabcontrol.TabStop := FALSE;
    // Result.ckbxmsnenabled.TabOrder = 1
    Result.ckbxmsnenabled := NewCheckBox( Result.Form, 'Messenger Now playing' ).SetPosition( 16, 8 ).SetSize( 185, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxmsnenabled.SetName( Result.Form, 'ckbxmsnenabled' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxmsnenabled.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxmsnenabled.Font.FontPitch := fpFixed;
    // Result.cmbxmsnicon.TabOrder = 2
    Result.cmbxmsnicon := NewComboBox( Result.Form, [ coReadOnly, coNoIntegralHeight ] ).SetPosition( 16, 37 ).SetSize( 161, 0 );
   {$IFDEF USE_NAMES}
    Result.cmbxmsnicon.SetName( Result.Form, 'cmbxmsnicon' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.cmbxmsnicon.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.cmbxmsnicon.Font.FontPitch := fpFixed;
    Result.cmbxmsnicon.Color := clWindow;
    Result.cmbxmsnicon.Items[ 0 ] := 'Headfone icon';
    Result.cmbxmsnicon.Items[ 1 ] := 'Games icon';
    Result.cmbxmsnicon.Items[ 2 ] := 'Office icon';
    Result.cmbxmsnicon.CurIndex := 0;
    // Result.ckbxlistenabled.TabOrder = 3
    Result.ckbxlistenabled := NewCheckBox( Result.Form, 'Listened tracks list' ).SetPosition( 16, 65 ).SetSize( 153, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxlistenabled.SetName( Result.Form, 'ckbxlistenabled' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxlistenabled.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxlistenabled.Font.FontPitch := fpFixed;
    // Result.edtlistname.TabOrder = 4
    Result.edtlistname := NewEditBox( Result.Form, [  ] ).SetPosition( 16, 94 ).SetSize( 161, 0 );
   {$IFDEF USE_NAMES}
    Result.edtlistname.SetName( Result.Form, 'edtlistname' ); 
   {$ENDIF}
    Result.edtlistname.Font.FontPitch := fpFixed;
    {$IFNDEF UNICODE_CTRLS}Result.edtlistname.SetUnicode( TRUE );{$ENDIF}
    // Result.ckbxclipboard.TabOrder = 5
    Result.ckbxclipboard := NewCheckBox( Result.Form, 'Copy track name to Clipboard' ).SetPosition( 16, 122 ).SetSize( 201, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxclipboard.SetName( Result.Form, 'ckbxclipboard' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxclipboard.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxclipboard.Font.FontPitch := fpFixed;
    // Result.ckbxlastfm.TabOrder = 6
    Result.ckbxlastfm := NewCheckBox( Result.Form, 'Last.fm Scrobber plugin' ).SetPosition( 16, 151 ).SetSize( 169, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxlastfm.SetName( Result.Form, 'ckbxlastfm' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxlastfm.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxlastfm.Font.FontPitch := fpFixed;
    // Result.edtuser.TabOrder = 7
    Result.edtuser := NewEditBox( Result.Form, [  ] ).SetPosition( 64, 179 ).SetSize( 161, 0 );
   {$IFDEF USE_NAMES}
    Result.edtuser.SetName( Result.Form, 'edtuser' ); 
   {$ENDIF}
    Result.edtuser.Font.FontPitch := fpFixed;
    {$IFNDEF UNICODE_CTRLS}Result.edtuser.SetUnicode( TRUE );{$ENDIF}
    // Result.edtpass.TabOrder = 8
    Result.edtpass := NewEditBox( Result.Form, [ eoPassword ] ).SetPosition( 64, 208 ).SetSize( 161, 0 );
   {$IFDEF USE_NAMES}
    Result.edtpass.SetName( Result.Form, 'edtpass' ); 
   {$ENDIF}
    Result.edtpass.Font.FontPitch := fpFixed;
    {$IFNDEF UNICODE_CTRLS}Result.edtpass.SetUnicode( TRUE );{$ENDIF}
    // Result.btapply.TabOrder = 9
    Result.btapply := NewButton( Result.Form, 'Apply' ).SetPosition( 75, 280 );
   {$IFDEF USE_NAMES}
    Result.btapply.SetName( Result.Form, 'btapply' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.btapply.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.btapply.Font.FontPitch := fpFixed;
    // Result.btupdate.TabOrder = 10
    Result.btupdate := NewButton( Result.Form, 'Update!' ).SetPosition( 147, 280 );
   {$IFDEF USE_NAMES}
    Result.btupdate.SetName( Result.Form, 'btupdate' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.btupdate.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.btupdate.Font.FontPitch := fpFixed;
    // Result.ckbxuseprimary.TabOrder = 11
    Result.ckbxuseprimary := NewCheckBox( Result.Form, 'use Direct Sound primary buffer' ).SetPosition( 16, 8 ).SetSize( 209, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxuseprimary.SetName( Result.Form, 'ckbxuseprimary' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxuseprimary.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxuseprimary.Font.FontPitch := fpFixed;
    // Result.ckbxpriority.TabOrder = 12
    Result.ckbxpriority := NewCheckBox( Result.Form, 'use priority level on directsound' ).SetPosition( 16, 40 ).SetSize( 209, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxpriority.SetName( Result.Form, 'ckbxpriority' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxpriority.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxpriority.Font.FontPitch := fpFixed;
    // Result.cmbxbuffersize.TabOrder = 13
    Result.cmbxbuffersize := NewComboBox( Result.Form, [ coReadOnly, coNoIntegralHeight ] ).SetPosition( 16, 96 );
   {$IFDEF USE_NAMES}
    Result.cmbxbuffersize.SetName( Result.Form, 'cmbxbuffersize' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.cmbxbuffersize.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.cmbxbuffersize.Font.FontPitch := fpFixed;
    Result.cmbxbuffersize.Color := clWindow;
    Result.cmbxbuffersize.Items[ 0 ] := '64kb';
    Result.cmbxbuffersize.Items[ 1 ] := '500ms';
    Result.cmbxbuffersize.Items[ 2 ] := '1000ms';
    Result.cmbxbuffersize.Items[ 3 ] := '2000ms';
    Result.cmbxbuffersize.CurIndex := 0;
      Result.ckbxmsnenabled.OnClick := Result.ckbxmsnenabledClick;
      Result.ckbxlistenabled.OnClick := Result.ckbxlistenabledClick;
    Result.edtlistname.Color := clWindow;
      Result.ckbxlastfm.OnClick := Result.ckbxlastfmClick;
    Result.edtuser.Color := clWindow;
    Result.edtpass.Color := clWindow;
      Result.btapply.OnClick := Result.btapplyClick;
    Result.btapply.DefaultBtn := TRUE;
      Result.btupdate.OnClick := Result.btupdateClick;
    Result.Form.CenterOnParent.CanResize := False;
    Result.KOLForm1FormCreate( Result );

end;

