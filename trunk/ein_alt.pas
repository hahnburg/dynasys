(* Dynasys, http://code.google.com/p/dynasys/
 * Copyright (C) 2009  Dynasys
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http:www.gnu.org/licenses/>.
 *)

Unit EingabeDlg;

interface

uses WinProcs, WinTypes, Objects, OWindows, ODialogs,Strings, WinDlgs,WinDos,
     Status, SimObjekt, Parser, ObjektListe, NumerikParameter, Tabelleneditor;




       ErrorTxt1 ='Fehlerhafter Name! Namen dürfen nur Buchstaben und Ziffern enthalten,'+
                  +#10+#13+'keine Sonderzeichen und Leerzeichen.';
       ErrorTxt2 ='Der Name ist bereits vergeben!';
T
  PZustandDialog = ^TZustandDialog;
  TZustandDialog  = Object(TTRDialog)
                     SimObj : PZustandObjekt;
                     ObjName : Array [0..30] of Char;
                     Eingabe : Array [0..250] of Char;
                     Constructor Init(AParent: PWindowsObject; AName: PChar; Var ASimObj:PSimuObjekt);
                     Procedure   SetUpWindow;       virtual;
                     Function    CanClose:Boolean;  virtual;

                   End;

  PWertDialog = ^TWertDialog;
  TWertDialog  = Object(TZustandDialog)
                     hEingaenge,
                     hFunktionen : HWnd;
                     AnzahlEingaenge : integer;
                     Constructor Init(AParent: PWindowsObject; AName: PChar; Var ASimObj:PSimuObjekt);
                     Procedure   SetUpWindow;       virtual;
                     Function    CanClose:Boolean;  virtual;
                     Procedure   LiesEingang(Var Msg:TMessage);  virtual id_first + id_Eingaenge;
                     Procedure   LiesFunktion(Var Msg:TMessage);  virtual id_first + id_Funktionen;
                     Procedure   Bearbeite_xtbf(Var Msg:TMessage); virtual id_first + id_xtbf;
                     Procedure   LiesWerte(Var Msg:TMessage); virtual id_first + id_disk;
                   End;


  PNamenDialog = ^TNamenDialog;
  TNamenDialog = Object(TDialog)
                    SimObj : PSimuObjekt;
                    Constructor Init(AParent: PWindowsObject; AName: PChar; Var ASimObj:PSimuObjekt);
                    Procedure   SetUpWindow;      virtual;
                    Function    CanClose:Boolean; virtual;
                 End;



  PNumerikDialog = ^TNumerikDialog;
  TNumerikDialog  = Object(TDialog)
                     Constructor Init(AParent: PWindowsObject; AName: PChar);
                     Procedure   SetUpWindow;       virtual;
                     Function    CanClose:Boolean;  virtual;
                   End;



  PAusgabeDialog = ^TAusgabeDialog;
  TAusgabeDialog = Object(TDialog)
                     hVariablen,hEdit1min : HWnd;
                     hPlot      : HWnd;
                     Zaehler    : Integer;
                     gleich,auto,farbig,dick: Boolean;
                     Constructor Init(AParent: PWindowsObject; AName: PChar;
                                             aauto,agleich,afarbig,adick:Boolean);
                     Procedure   SetUpWindow;       virtual;
                     Function    CanClose:Boolean;  virtual;
                     Procedure   LiesVariable(Var Msg:TMessage);  virtual id_first + id_variablen;
                     Procedure   LoescheVariable(Var Msg:TMessage);  virtual id_first + id_del;
                     Procedure   SetzeAuto(Var Msg:TMessage);    virtual id_first   + id_auto;
                     Procedure   SetzeManuel(Var Msg:TMessage);  virtual id_first + id_manuell;
                     Procedure   SetzeGleich(Var Msg:TMessage);  virtual id_first + id_gleich;
                     Procedure   SetzeUngleich(Var Msg:TMessage);virtual id_first + id_ungleich;

                   End;

  PPhasenDialog = ^TPhasenDialog;
  TPhasenDialog = Object(TDialog)
                     hVariablen : HWnd;
                     hPlot      : HWnd;
                     Zaehler    : Integer;
                     Constructor Init(AParent: PWindowsObject; AName: PChar);
                     Procedure   SetUpWindow;       virtual;
                     Function    CanClose:Boolean;  virtual;
                     Procedure   LiesVariable(Var Msg:TMessage);  virtual id_first + id_variablen;
                     Procedure   LoescheVariable(Var Msg:TMessage);  virtual id_first + id_del;
                   End;

  PTabellenDialog = ^TTabellenDialog;
  TTabellenDialog = Object(TDialog)
                     hVariablen : HWnd;
                     hPlot      : HWnd;
                     Zaehler    : Integer;
                     Nachkomma  : Integer;
                     Constructor Init(AParent: PWindowsObject; AName: PChar);
                     Procedure   SetUpWindow;       virtual;
                     Function    CanClose:Boolean;  virtual;
                     Procedure   LiesVariable(Var Msg:TMessage);  virtual id_first + id_variablen;
                     Procedure   LoescheVariable(Var Msg:TMessage);  virtual id_first + id_del;
                     Procedure   LiesAlle(Var Msg:TMessage);  virtual id_first + id_alle;
                   End;

  PModellInfoDialog = ^TModellInfoDialog;
  TModellInfoDialog = Object(TDialog)
                     Procedure   SetUpWindow;       virtual;
                     Function    CanClose:Boolean;  virtual;
                   End;



{========================================================================================}
implementation



 Procedure KommaPunkt(Var P:Array of Char);
 Var i:integer;
 Begin
   For i:=0 to High(P) do if P[i]=',' Then P[i]:='.'
 End;
------------------------------------------------------------------------- }


   Constructor TWertDialog.Init(AParent: PWindowsObject; AName: PChar;Var ASimObj:PSimuObjekt);
   Begin
     inherited Init(AParent,AName,ASimObj);
   End;

   Procedure TWertDialog.SetUpWindow;
   Var i:integer;
       P:PSimuObjekt;
       pStr:PChar;
       R:Real;
       hButton:HWnd;
   Begin
     inherited SetUpWindow;
     hEingaenge:=GetDlgItem(HWindow,id_Eingaenge);
     hFunktionen:=GetDlgItem(HWindow,id_Funktionen);
     AnzahlEingaenge:=0;
     { Erst Zustände }
     for i:=1 to SimObj^.EingangMax Do Begin
         P:=PWirkPfeilObjekt(SimObj^.Eingaenge[i].zgr)^.von;
         if P^.key=ZustandId Then Begin
           pStr:=@P^.Name[0];
           parse.LerneLokVariable(pStr,@R,@p^.delay,@p^.DelayValue);
           SendMessage(hEingaenge,LB_ADDSTRING,0,LongInt(pStr));
           INC(AnzahlEingaenge);
         End;
     End;  { Dann der Rest }
     for i:=1 to SimObj^.EingangMax Do Begin
         P:=PWirkPfeilObjekt(SimObj^.Eingaenge[i].zgr)^.von;
         If p^.key<>ZustandId Then Begin
           pStr:=@P^.Name[0];
           parse.LerneLokVariable(pStr,@R,@p^.delay,p^.DelayValue);
           SendMessage(hEingaenge,LB_ADDSTRING,0,LongInt(pStr));
           INC(AnzahlEingaenge);
         End;
     End;
     For i :=1 to MaxFunktionen do Begin
       pStr:=ListBox[i];
       SendMessage(hFunktionen,LB_ADDSTRING,0,LongInt(pStr));
     End;
     {Tabelleneintrag nur sichtbar bei Zwischenwerten}
     If (SimObj^.Key=WertId) And (AnzahlEingaenge<=1) Then Begin
       hButton:=GetDlgItem(HWindow,id_xtbf);
       SendMessage(hButton,wm_syscommand,sc_restore,0);
       {$ifndef land}
       hButton:=GetDlgItem(HWindow,id_disk);
       SendMessage(hButton,wm_syscommand,sc_restore,0);
       {$endif}
       End;
   End;


   Procedure TWertDialog.LiesEingang(Var Msg:TMessage);
   Var TPuffer:Array[0..30] of Char;
       index:longInt;
   Begin
     If Msg.lParamHi=lbn_selChange Then Begin
       StrCopy(TPuffer,'');
       index:=SendMessage(hEingaenge,lb_getcursel,0,0);
       SendMessage(hEingaenge,lb_gettext,Word(index),LongInt(@TPuffer));
       SendMessage(hEingabe,em_Replacesel,0,LongInt(@TPuffer));
       SetFocus(hEingabe);
     End;
   End;

   Procedure TWertDialog.LiesFunktion(Var Msg:TMessage);
   Var TPuffer:Array[0..10] of Char;
       index:longInt;
   Begin
     If Msg.lParamHi=lbn_selChange Then Begin
       StrCopy(TPuffer,'');
       index:=SendMessage(hFunktionen,lb_getcursel,0,0);
       SendMessage(hFunktionen,lb_gettext,Word(index),LongInt(@TPuffer));
       SendMessage(hEingabe,em_Replacesel,0,LongInt(@TPuffer));
       SetFocus(hEingabe);
     End;
   End;

   Procedure TWertDialog.Bearbeite_xtbf(Var Msg:TMessage);
   Begin
     If AnzahlEingaenge>1 Then
     MessageBox(HWindow,'Tabellenfunktionen dürfen max. einen Eingang besitzen!',
                                          'Dialog Hilfsgröße',mb_ok or mb_iconstop)
     Else Begin
       EndDialog(HWindow,0);
       Application^.ExecDialog(New(PTabEdDialog, Init(@Self, 'Tabelleneditor',PWertObjekt(SimObj))));
       End;
   End;

   Procedure TWertDialog.LiesWerte(Var Msg:TMessage);
   Label 999;
   Var OpenDialog: POFileDlg;
       TabName  : Array[0..80] of Char;
       PTabname : PChar;
       f        : Text;
       z        : String;
       ZahlString1,ZahlString2  : String[30];
       i,Result,TrennZeichen,Code,Stelle : Integer;
       Error       : Boolean;
       ZahlX,ZahlY,ZahlAlt : Real;
       p:PSimuObjekt;
   Begin
     If AnzahlEingaenge>1 Then
     MessageBox(HWindow,'Tabellenfunktionen dürfen max. einen Eingang besitzen!',
                                          'Dialog Hilfsgröße',mb_ok or mb_iconstop)
     Else Begin
       Error:=false;
       EndDialog(HWindow,0);
       OpenDialog:=New(POFileDlg,Init(HWindow,'Tabelle laden','Modelle (*.csv)','*.csv'));
       OpenDialog^.AddFilter('Alle Dateien (*.*)','*.*');
       PTabName:=@TabName;
       If OpenDialog^.GetOpenFName(PTabName) Then Begin
         FileExpand(TabName,PTabName);
         PWertObjekt(SimObj)^.Tabelle:=NEW(PCollection,Init(11,5));
         Assign(f,TabName);
         {$I-}
         Reset(f);i:=0;ZahlAlt:=-1e30;
         While not EOF(f) do Begin
            ReadLn(f,z);
            { Leerzeichen entfernen }
            While Pos(' ',z)>0 do Delete(z,Pos(' ',z),1);
            IF Length(z)>0 Then Begin
              { Kommas durch Punkte ersetzen }
              While pos(',',z)>0 Do Begin
                Stelle:=pos(',',z); Delete(z,Stelle,1); Insert('.',z,Stelle);
              End;
              TrennZeichen:=Pos(';',z);
              If Trennzeichen = 0 Then Begin
                MessageBox(HWindow,'In einer Wertetabelle müssen in jeder Zeile 2'+#10#13+
                                    'durch ";" getrennte Zahlen vorhanden sein!',
                                    'Tabelle laden',mb_ok or mb_iconhand);
                Error:=True;Goto 999 End;
              ZahlString1:=Copy(z,1,TrennZeichen-1);
              ZahlString2:=Copy(z,TrennZeichen+1,Length(z)-Trennzeichen);
              Val(ZahlString1,Zahlx,Code); If code>0 Then Begin Error:=true; Goto 999 End;
              If zahlAlt>ZahlX Then Begin
                MessageBox(HWindow,'In einer Tabelle müssen die x-Werte aufsteigend sortiert sein!',
                                    'Tabelle laden',mb_ok or mb_iconhand);
                Error:=True; Goto 999; End;
              Val(ZahlString2,Zahly,Code); If code>0 Then Begin Error:=true; Goto 999 End;
              PWertObjekt(SimObj)^.Tabelle^.Insert(NEW(PWPaar,Init));
              PWPaar(PWertObjekt(SimObj)^.Tabelle^.At(i))^.x:=Zahlx;
              PWPaar(PWertObjekt(SimObj)^.Tabelle^.At(i))^.y:=Zahly;
              Inc(i);
              ZahlAlt:=ZahlX;
            End
         End;
999:     Close(f);
         {$I+}
         Error:=Error or (IOResult<>0);
         if Error then begin
            Messagebox(HWindow,'Fehler beim Laden der Tabelle!',
                                  'Tabelle laden',mb_ok or mb_iconhand);
            SimObj^.gueltig:=false;
            Dispose(PWertObjekt(SimObj)^.Tabelle,done);
         end else Begin
            SimObj^.gueltig:=true;
            PWertObjekt(SimObj)^.xtbf:=FileTab;
            StrCopy(SimObj^.Eingabe,'Tabelle(');
            if SimObj^.EingangMax=1 Then
              Begin
                P:=PWirkPfeilObjekt(SimObj^.Eingaenge[1].zgr)^.von;
                {pStr:=@P^.Name[0];}
                StrCat(SimObj^.Eingabe,p^.Name)
              End
            Else StrCat(SimObj^.Eingabe,'Zeit');
            StrCat(SimObj^.Eingabe,') ');
            StrCat(SimObj^.Eingabe,'{');
            StrCat(SimObj^.Eingabe,StrLower(PTabName));
            StrCat(SimObj^.Eingabe,'}');
         End;
       End;
       Dispose(OpenDialog,done);
     End;
   End;

   Function TWertDialog.CanClose:Boolean;
   Var Msg:PChar;
       i:Integer;
       pStr:PChar;
       p:PSimuObjekt;
   Begin
 
   End;

   {==================================================================================== }



   Constructor TNamenDialog.Init(AParent: PWindowsObject; AName: PChar; Var ASimObj:PSimuObjekt);
   Begin
     inherited Init(AParent,AName);
     SimObj:=ASimObj;
   End;

   Procedure TNamenDialog.SetUpWindow;
   Begin
     inherited SetUpWindow;
     SetDlgItemText(HWindow, id_Name, SimObj^.Name);
   End;


   Function TNamenDialog.CanClose:Boolean;
   Var Msg:PChar;
       ObjName : Array [0..30] of Char;
       i : Integer;
   Begin
       GetDlgItemText(HWindow, id_Name, ObjName, 30);
       If not Name_korrekt(ObjName) Then Begin
          MessageBox(HWindow,errortxt1,'Eingabe',MB_OK OR MB_ICONSTOP);
          CanClose:=False;  Exit;
       End;

       If StrComp(SimObj^.Name,ObjName)=0 Then Begin CanClose:=true; Exit End;
       If NameVorhanden(ObjListe,ObjName) Then Begin
              MessageBox(HWindow,'Der Name ist bereits vergeben!','Eingabe',MB_OK OR MB_ICONSTOP);
              CanClose:=False; Exit
       End Else
          Begin

            If StrComp(SimObj^.Name,ObjName)<>0 Then Begin
              {Objekt mit Wirkverbindung ungültig erklären }
              For i:=1 To SimObj^.AusgangMax do Begin
                If Not Ersetze_Namen(PWirkPfeilObjekt(SimObj^.Ausgaenge[i].zgr)^.nach,SimObj^.Name,ObjName) Then
                   PWirkPfeilObjekt(SimObj^.Ausgaenge[i].zgr)^.nach^.gueltig:=False;
              End
            End;
            StrCopy (SimObj^.Name,ObjName);
          CanClose:=True;
         End;
   End;

{=================================================================================== }



{ ============================================================================== }



Constructor TAusgabeDialog.Init(AParent: PWindowsObject; AName: PChar;
                                    aauto,agleich,afarbig,adick:Boolean);
Begin
  inherited Init(AParent,AName);
  auto:=aauto;
  gleich:=agleich;
  farbig:=Not State^.InitSW;
  dick:=adick;
End;

Procedure TAusgabeDialog.SetupWindow;
Var Puffer: Array [0..30] of Char;
    i : integer;
    pstr:PChar;
Begin
  inherited SetUpWindow;
  hVariablen:=GetDlgItem(HWindow,id_Variablen);
  SendDlgItemMessage(HWindow,id_gleich, BM_SETCHECK,Word(gleich),0);
  SendDlgItemMessage(HWindow,id_ungleich,BM_SETCHECK,Word(not gleich),0);
  SendDlgItemMessage(HWindow,id_auto,   BM_SETCHECK,Word(auto),0);
  SendDlgItemMessage(HWindow,id_manuell,BM_SETCHECK,Word(not auto),0);
  SendDlgItemMessage(HWindow,id_farbe,  BM_SETCHECK,Word(farbig),0);
  SendDlgItemMessage(HWindow,id_dick,  BM_SETCHECK,Word(dick),0);

  hPlot:=GetDlgItem(HWindow,id_Var);
     for i:=0 to ObjListe^.Count-1 Do Begin
         If PSimuObjekt(ObjListe^.At(i))^.key=ZustandId
               Then  Begin
                   pstr:=PSimuObjekt(ObjListe^.At(i))^.Name;
                   SendMessage(hVariablen,LB_ADDSTRING,0,LongInt(pStr));
               End;
     End;
     for i:=0 to ObjListe^.Count-1 Do Begin
         If (PSimuObjekt(ObjListe^.At(i))^.key>0) and (PSimuObjekt(ObjListe^.At(i))^.key<ZustandId)
               Then  Begin
                   pstr:=PSimuObjekt(ObjListe^.At(i))^.Name;
                   SendMessage(hVariablen,LB_ADDSTRING,0,LongInt(pStr));
               End;
     End;
     Zaehler:=0;
End;

Procedure TAusgabeDialog.LiesVariable(Var Msg:TMessage);
   Var Puffer:Array[0..30] of Char;
       index:longInt;
       i : Integer;
       HControl : HWnd;
Begin
  If (Msg.lParamHi=lbn_selChange) and (Zaehler<4) Then Begin
       StrCopy(Puffer,'');
       index:=SendMessage(hVariablen,lb_getcursel,0,0);
       SendMessage(hVariablen,lb_gettext,Word(index),LongInt(@Puffer));
       SendMessage(hPlot,LB_ADDSTRING,0,LongInt(@puffer));
       If Not gleich and not auto Then
         For i:=zaehler*10+200 to zaehler*10+204 Do Begin
            HControl:=GetDlgItem(HWindow,i);
            EnableWindow(HControl,true);
         End;
       Inc(Zaehler)
  End;
End;

Procedure TAusgabeDialog.LoescheVariable(Var Msg:TMessage);
Var index:longInt;
    i : integer;
    HControl:HWnd;
Begin
  index:=SendMessage(hPlot,lb_getcursel,0,0);
  if (Zaehler>Index) and (Index>=0) Then Begin
    SendMessage(hPlot,lb_deletestring,Word(index),0);
    Dec(Zaehler);
    If Not gleich and not auto Then
       For i:=zaehler*10+200 to zaehler*10+204 Do Begin
          HControl:=GetDlgItem(HWindow,i);
          EnableWindow(HControl,false);
       End;
  End;
End;

Function TAusgabeDialog.CanClose:Boolean;
Label 99;
Var i:integer;
    Puffer:Array[0..30] of Char;
    MinMaxPuffer:Array[0..4] of Record  min,max:Real End;
    P:PSimuObjekt;
    Wert:Real;
    Code:Integer;
Begin
  If Zaehler=0 Then Begin
    MessageBox(HWindow,'Es wurde keine Ausgabevariable bestimmt!','AusgabeDialog',mb_ok or mb_iconstop);
    CanClose:=False; Exit
  End;
  State^.Farbe:=Word(True)=(SendDlgItemMessage(HWindow,id_Farbe,BM_GetCHECK,0,0));
  State^.dick:=Word(True)=(SendDlgItemMessage(HWindow,id_dick,BM_GetCHECK,0,0));
  State^.Gleich:=Word(True)=(SendDlgItemMessage(HWindow,id_gleich,BM_GetCHECK,0,0));;
  State^.Automatisch:=Word(True)=(SendDlgItemMessage(HWindow,id_auto,BM_GetCHECK,0,0));;
  If Not State^.Automatisch Then Begin
    If State^.Gleich Then { Minimum und Maximum im Modul Status merken }
      With State^ do
        Begin
          GetDlgItemText(HWindow, id_1min, Puffer, 30);
          KommaPunkt(Puffer);
          Val(Puffer,wert,code); if code>0 Then goto 99; xtMinimum:=Wert;
          GetDlgItemText(HWindow, id_1max, Puffer, 30);
          KommaPunkt(Puffer);
          Val(Puffer,wert,code); if code>0 Then goto 99; xtMaximum:=Wert;
          If xtMinimum>=xtMaximum Then Goto 99;
        End
    Else  { Festlegung erst mal im MinMaxPuffer zwischenspeichern }
      For i:=0 to Zaehler-1 Do Begin
         GetDlgItemText(HWindow, id_1min+i*10, Puffer, 30);
         KommaPunkt(Puffer);
         Val(Puffer,wert,code);if code>0 Then goto 99;MinMaxPuffer[i].min:=Wert;
         GetDlgItemText(HWindow, id_1max+i*10, Puffer, 30);
         KommaPunkt(Puffer);
         Val(Puffer,wert,code);if code>0 Then goto 99;MinMaxPuffer[i].max:=Wert;
         If MinMaxPuffer[i].max<=MinMaxPuffer[i].min Then goto 99;
      End;
  End;

  For i:=0 to ObjListe^.Count-1 do PSimuObjekt(ObjListe^.At(i))^.Ausgabe_id:=-1;
  For i:=0 To Zaehler-1 Do Begin
    SendMessage(hPlot,lb_gettext,Word(i),LongInt(@Puffer));
    P:=SucheNamen(ObjListe,Puffer);
    If p=NIL Then MessageBox(HWindow,'Fataler Fehler: Name nicht in Objektliste!',
                                   'AusgabeDialog', mb_ok or mb_iconstop)
    Else
      Begin
        p^.Ausgabe_id:=i+1;
        If not State^.Automatisch and not State^.Gleich Then Begin
          p^.Minimum:=MinMaxPuffer[i].min;
          p^.Maximum:=MinMaxPuffer[i].max
        End;
      End;
  End;
  CanClose:=true; Exit;
  99: Messagebox(HWindow,'Unsinnige Werte in den Eingabefeldern!'+#10+#13+' (Z.B.: Maximum < Mininum)',
      'Zeitdiagramm',mb_ok and mb_iconstop);
      Canclose:=False;
End;

Procedure   TAusgabeDialog.SetzeAuto(Var Msg:TMessage);
Var i,j : Integer;
    HControl : HWnd;
Begin
  Auto:=True;
  For j:=0 to 3 Do
    for i:=j*10+200 to j*10+204 Do Begin
       HControl:=GetDlgItem(HWindow,i);
       EnableWindow(HControl,False);
    End;

End;

Procedure   TAusgabeDialog.SetzeManuel(Var Msg:TMessage);
Const FirstId = 200;
Var i,j : Integer;
    HControl : HWnd;
    StyleBits : Word;
    Test:Array[0..20]of Char;
Begin
  Auto:=False;
  If Gleich Then
    Begin
        For i:=200 To 204 Do Begin
          HControl:=GetDlgItem(HWindow,i);
          EnableWindow(HControl,true);
        End;
      For j:=1 to 3 Do
        for i:=j*10+200 to j*10+204 Do Begin
          HControl:=GetDlgItem(HWindow,i);
          EnableWindow(HControl,False);
        End;
    End
  Else
    Begin
      For j:=0 to Zaehler-1 Do
        for i:=j*10+200 to j*10+204 Do Begin
          HControl:=GetDlgItem(HWindow,i);
          EnableWindow(HControl,true);
        End;
    End
End;

Procedure   TAusgabeDialog.SetzeGleich(Var Msg:TMessage);
Var i,j:Integer;
    HControl:HWnd;
Begin
  Gleich:=True;
  If Auto Then Begin
        For j:=0 to 3 Do
        for i:=j*10+200 to j*10+204 Do Begin
          HControl:=GetDlgItem(HWindow,i);
          EnableWindow(HControl,False);
        End;
  End
  Else Begin
        For i:=200 To 204 Do Begin
          HControl:=GetDlgItem(HWindow,i);
          EnableWindow(HControl,true);
        End;
      For j:=1 to 3 Do
        for i:=j*10+200 to j*10+204 Do Begin
          HControl:=GetDlgItem(HWindow,i);
          EnableWindow(HControl,False);
        End;
  End;
End;


Procedure   TAusgabeDialog.SetzeUngleich(Var Msg:TMessage);
Var i,j : Integer;
    HControl:HWnd;
Begin
  Gleich:=False;
  If Auto Then
    Begin
      For j:=0 to 3 Do
        for i:=j*10+200 to j*10+204 Do Begin
          HControl:=GetDlgItem(HWindow,i);
          EnableWindow(HControl,False);
        End;
    End
  Else
    Begin
      For j:=0 to Zaehler-1 Do
        for i:=j*10+200 to j*10+204 Do Begin
          HControl:=GetDlgItem(HWindow,i);
          EnableWindow(HControl,true);
        End;
    End
  End;

{ ============================================================================== }


Constructor TPhasenDialog.Init(AParent: PWindowsObject; AName: PChar);
Begin
  inherited Init(AParent,AName);
End;

Procedure TPhasenDialog.SetupWindow;
Var Puffer: Array [0..30] of Char;
    i : integer;
    pstr:PChar;
Begin
  inherited SetUpWindow;
  hVariablen:=GetDlgItem(HWindow,id_Variablen);
  hPlot:=GetDlgItem(HWindow,id_Var);
     for i:=0 to ObjListe^.Count-1 Do Begin
         If PSimuObjekt(ObjListe^.At(i))^.key=ZustandId
               Then  Begin
                   pstr:=PSimuObjekt(ObjListe^.At(i))^.Name;
                   SendMessage(hVariablen,LB_ADDSTRING,0,LongInt(pStr));
               End;
     End;
     for i:=0 to ObjListe^.Count-1 Do Begin
         If (PSimuObjekt(ObjListe^.At(i))^.key>0) and (PSimuObjekt(ObjListe^.At(i))^.key<ZustandId)
               Then  Begin
                   pstr:=PSimuObjekt(ObjListe^.At(i))^.Name;
                   SendMessage(hVariablen,LB_ADDSTRING,0,LongInt(pStr));
               End;
     End;
     Zaehler:=0;
End;

Procedure TPhasenDialog.LiesVariable(Var Msg:TMessage);
   Var Puffer:Array[0..30] of Char;
       index:longInt;
Begin
  If (Msg.lParamHi=lbn_selChange) and (Zaehler<2) Then Begin
       StrCopy(Puffer,'');
       index:=SendMessage(hVariablen,lb_getcursel,0,0);
       SendMessage(hVariablen,lb_gettext,Word(index),LongInt(@Puffer));
       SendMessage(hPlot,LB_ADDSTRING,0,LongInt(@puffer));
       Inc(Zaehler)
  End;
End;

Procedure TPhasenDialog.LoescheVariable(Var Msg:TMessage);
Var index:longInt;
Begin
  index:=SendMessage(hPlot,lb_getcursel,0,0);
  if (Zaehler>Index) and (Index>=0) Then Begin
    SendMessage(hPlot,lb_deletestring,Word(index),0);
    Dec(Zaehler);
  End;
End;

Function TPhasenDialog.CanClose:Boolean;
Var i:integer;
    Puffer:Array[0..30] of Char;
    P:PSimuObjekt;
Begin
  If Zaehler<2 Then Begin
    MessageBox(HWindow,'Es müssen zwei Ausgabevariablen angegeben werden!!',
                       'PhasenDialog',mb_ok or mb_iconstop);
    CanClose:=False; Exit
  End;
  For i:=0 to ObjListe^.Count-1 do PSimuObjekt(ObjListe^.At(i))^.Phasen_id:=-1;
  For i:=0 To Zaehler-1 Do Begin
    SendMessage(hPlot,lb_gettext,Word(i),LongInt(@Puffer));
    P:=SucheNamen(ObjListe,Puffer);
    If p=NIL Then MessageBox(HWindow,'Fataler Fehler: Name nicht in Objektliste!',
    'PhasenDialog',
                   mb_ok or mb_iconstop)
    Else Begin
      p^.Phasen_id:=i+1;
      State^.xy[i]:=p;
    End;
  End;
  CanClose:=true;
End;

{ ============================================================================== }
{ ============================================================================== }
Const id_nachkomma = 106;
      MaxEintrag   = 15;

Constructor TTabellenDialog.Init(AParent: PWindowsObject; AName: PChar);
Begin
  inherited Init(AParent,AName);
End;

Procedure TTabellenDialog.SetupWindow;
Var Puffer: Array [0..30] of Char;
    i : integer;
    pstr:PChar;
Begin
  inherited SetUpWindow;
  Str(State^.InitNachkomma:0,Puffer);
  SetDlgItemText(HWindow,id_Nachkomma,Puffer);
  hVariablen:=GetDlgItem(HWindow,id_Variablen);
  hPlot:=GetDlgItem(HWindow,id_Var);
     for i:=0 to ObjListe^.Count-1 Do Begin
         If PSimuObjekt(ObjListe^.At(i))^.key=ZustandId
               Then  Begin
                   pstr:=PSimuObjekt(ObjListe^.At(i))^.Name;
                   SendMessage(hVariablen,LB_ADDSTRING,0,LongInt(pStr));
               End;
     End;
     for i:=0 to ObjListe^.Count-1 Do Begin
         If (PSimuObjekt(ObjListe^.At(i))^.key>0) and (PSimuObjekt(ObjListe^.At(i))^.key<>ZustandId)
               Then  Begin
                   pstr:=PSimuObjekt(ObjListe^.At(i))^.Name;
                   SendMessage(hVariablen,LB_ADDSTRING,0,LongInt(pStr));
               End;
     End;
     Zaehler:=0;
End;

Procedure TTabellenDialog.LiesVariable(Var Msg:TMessage);
   Var Puffer:Array[0..30] of Char;
       index:longInt;
Begin
  If (Msg.lParamHi=lbn_selChange) {and (Zaehler<MaxEintrag)} Then Begin
       StrCopy(Puffer,'');
       index:=SendMessage(hVariablen,lb_getcursel,0,0);
       SendMessage(hVariablen,lb_gettext,Word(index),LongInt(@Puffer));
       SendMessage(hPlot,LB_ADDSTRING,0,LongInt(@puffer));
       Inc(Zaehler)
  End;
End;

Procedure TTabellenDialog.Liesalle(Var Msg:TMessage);
   Var  pstr:PChar;
        i : integer;
Begin
     for i:=0 to ObjListe^.Count-1 Do Begin
         If PSimuObjekt(ObjListe^.At(i))^.key=ZustandId
               Then  Begin
                   pstr:=PSimuObjekt(ObjListe^.At(i))^.Name;
                   SendMessage(hplot,LB_ADDSTRING,0,LongInt(pStr));
                   Inc(Zaehler);
               End;
     End;
     for i:=0 to ObjListe^.Count-1 Do Begin
         If (PSimuObjekt(ObjListe^.At(i))^.key>0) and (PSimuObjekt(ObjListe^.At(i))^.key<ZustandId)
               Then  Begin
                   pstr:=PSimuObjekt(ObjListe^.At(i))^.Name;
                   SendMessage(hplot,LB_ADDSTRING,0,LongInt(pStr));
                   Inc(Zaehler);
               End;
     End;
End;

Procedure TTabellenDialog.LoescheVariable(Var Msg:TMessage);
Var index:longInt;
Begin
  index:=SendMessage(hPlot,lb_getcursel,0,0);
  if (Zaehler>Index) and (Index>=0) Then Begin
    SendMessage(hPlot,lb_deletestring,Word(index),0);
    Dec(Zaehler);
  End;
End;

Function TTabellenDialog.CanClose:Boolean;
Var i:integer;
    Puffer:Array[0..30] of Char;
    P:PSimuObjekt;
    wert : Integer;
    code : integer;
Begin
  If Zaehler=0 Then Begin
    MessageBox(HWindow,'Keine Ausgabevariable ausgewählt !','Tabellen',mb_ok or mb_iconhand);
    CanClose:=False; Exit
  End;
  For i:=0 to ObjListe^.Count-1 do PSimuObjekt(ObjListe^.At(i))^.Tabellen_id:=-1;
  For i:=0 To Zaehler-1 Do Begin
    SendMessage(hPlot,lb_gettext,Word(i),LongInt(@Puffer));
    P:=SucheNamen(ObjListe,Puffer);
    If p=NIL Then MessageBox(HWindow,'Fataler Fehler: Name nicht in Objektliste!',
       'Tabellen', mb_ok or mb_iconstop)
    Else Begin
      If  p^.Tabellen_id=-1 Then p^.Tabellen_id:=i+1;
    End;
  End;
  GetDlgItemText(HWindow, id_NachKomma, Puffer, 30);
  KommaPunkt(Puffer); Val(Puffer,wert,code);
  If Code>0 Then begin
    MessageBox(HWindow,'Fehlerhafte Eingabe der Nachkommastellen !',
      'Tabellen',mb_ok or mb_iconhand);
    CanClose:=False; Exit
  End;
  State^.Nachkommastellen:=wert;
  CanClose:=true;
End;

{ ============================================================================== }
   Const idEdit = 300;

   Procedure TModellInfoDialog.SetUpWindow;
      Const NewLine:PCHar= #13#10;
      Var
          i : Integer;
          Z : Array [0..255] of Char;
   Begin
     For i:=0 to NumParam^.Liste^.Count-1 do Begin
       StrCopy(Z,NumParam^.Liste^.at(i));
       SendDlgItemMsg(idEdit, em_ReplaceSel, 0, longint(@z));
       SendDlgItemMsg(idEdit, em_ReplaceSel, 0, longint(NewLine));
    End;
   End;

   Function TModellInfoDialog.CanClose;
   Var   i : Integer;
         Anzahl,ret:Longint;
         Puffer : Array [0..255] of Char;
   Begin
       Anzahl:=SendDlgItemMsg(idEdit,em_GetLineCount,0,0);
       For i:=0 To NumParam^.Liste^.Count-1 Do Dispose(NumParam^.Liste^.at(i));
       NumParam^.Liste^.DeleteAll;
       If Anzahl<=0 Then MessageBox(HWindow,'Was ist das?','Modell-Information',mb_ok);
       For i:=0 to Anzahl-1 Do Begin
         StrCopy('',Puffer);
         ret:=SendDlgItemMsg(idEdit,em_GetLine,i,LongInt(@Puffer));
         If Ret>0 Then Begin
           Puffer[word(ret)]:=#0;
           NumParam^.Liste^.Insert(StrNew(Puffer));
         End;
       End;
       CanClose:=True;
   End;


end.