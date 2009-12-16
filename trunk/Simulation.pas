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

unit Simulation;

(* Runge-Kutta und Euler-Cauchy-Verfahren
   Version: 2.0
*)

interface

Uses Dialogs,WinTypes, WinProcs,Forms, SysUtils,
     ErrorTxt, Liste, SimObjekt, Parser, Numerik, Tabelle, GraphWin, PhaseWin;

Type TSimulator = Class
          Procedure StarteBerechnung;
      end;

Var Simulator:TSimulator;

implementation
uses DynaMain;

Procedure TSimulator.StarteBerechnung;
Label AError;
Const MaxEintrag = 15;
Var i,j,k,z,v      : integer;
    SpaltenZahl    : integer;
    Zeile          : String;
    ErrTxt         : String;
    AutoMinMax     : Boolean;
    s1,s2,s1min,s2min,s1max,s2max : double;
    GMaximum,GMinimum : double;
    RZ : TRR;
    test : String;


    Function Berechne_Werte:Boolean;
    Var i:integer;
    Begin
     With ObjektListe do Begin
      For i:=0 to Count-1 do
        If items[i].key=WertId Then
        With items[i] {as TWertObjekt} Do Begin
          g_Wert:=Parse.Berechne(Baum);
          If Parse.ArithmeticError>0 Then Begin Berechne_Werte:=false;Exit End;
        End;
      For i:=0 to Count-1 do
       If items[i].key=VentilId Then
        With items[i] {as TVentilObjekt} Do  Begin
          g_Wert:=Parse.Berechne(Baum);
          If Parse.ArithmeticError>0 Then Begin Berechne_Werte:=false;Exit End;
        End;
     End;
     Berechne_Werte:=true;
    End;


Begin
  i:=ObjektListe.ModellGueltig;
  If i>0 then begin
    MessageDlg(ErrorTxt15+' : '+ObjektListe.items[i].Name,mtInformation,[mbok],0);
    Exit
  end;
  if i=0 then begin
    MessageDlg(ErrorTxt23,mtInformation,[mbok],0); Exit;
  end;

  // Modell ist gültig

  If Not ObjektListe.SortiereListe then Begin
     MessageDlg(ErrorTxt16,mtError,[mbok],0); Exit
  End;

  // Modell hat keine Schleifen

  s1:=0;s2:=0;s1max:=0;s1min:=0;s2max:=0;s2min:=0;

  { Erst die lokale Bezeichnerliste löschen }
  parse.LoescheLokBezListe;

  { Die lokalen Bezeichner hochladen }
  With ObjektListe do Begin
    For i:=0 to Count-1 do
      If items[i].key>0 Then
         With items[i] Do Begin
            Parse.LerneLokVariable(Name,@G_Wert,@delay,DelayValue);
            G_Wert:=0.0;
            Z_Wert:=0.0;
            V_Wert:=0.0;
         End;

    { Die Parserbäume erzeugen }
    For i:=0 to Count-1 do
      If items[i].key>0 Then
         With items[i] Do Begin
           If key=WertID then begin
               If TWertObjekt(items[i]).xtbf<>NoTab Then
                    Baum:=Parse.Parse(Eingabe,TWertObjekt(items[i]).Tabelle)
               Else Baum:=Parse.Parse(Eingabe,NIL);
           end
           else Baum:=Parse.Parse(Eingabe,NIL);
           If Parse.SyntaxError Then Begin
              MessageDlg(ErrorTxt17+Name+'.'+#13#10#13#10
                                         +ErrorTxt18,mtError,[mbok],0);
              Exit; { Sollte eigentlich nie passieren ! }
           End;
         End; //with //for
    { Funktion AlterWert dabei ?
    For i:=0 to Count-1 do
      If PSimuObjekt(At(i))^.delay Then Begin
        MessageBox(0, PSimuObjekt(At(i))^.Name,'AlterWert',mb_ok);
      End;
    }

    // Initialisierung
    Parse.SetzeVariable(Parse.dt,NumerikDlg.dt);
    Parse.SetzeVariable(Parse.Zeit,NumerikDlg.StartZeit);
    GMaximum:=0 {-1000.0};
    GMinimum:=0 {1000.0};

    // Nullpunkt immer auf Null
    For i:=0 to Count-1 do
      With items[i] do
        Begin Minimum:=0; Maximum:=0 End;

    { Formeln für Zustände ermitteln }
    { Startwerte der Zustände setzen }
    For i:=0 to Count-1 do
      If items[i].key=ZustandId Then
        With TZustandObjekt(items[i]) Do Begin
          StartWert:=Baum;
          G_Wert:=Parse.Berechne(StartWert);
          Z_Wert:=0.0;
          V_Wert:=g_wert;

          If NumerikDlg.Euler then Begin              { Euler-Cauchy }
            Zeile:=Name+' + dt * (';
            For j:=1 to ZuflussMax do
              Zeile:=Zeile+Zufluesse[j].zgr.Name+' + ';
            Zeile:=Zeile+'0';
            For j:=1 to AbflussMax do
              Zeile:=Zeile+' - '+Abfluesse[j].zgr.Name;
            Zeile:=Zeile+' )';
          End
          Else  { Runge-Kutta-Verfahren }
          Begin
            Zeile:='';
            For j:=1 to ZuflussMax do
              Zeile:=Zeile+Zufluesse[j].zgr.Name+' + ';
            Zeile:=Zeile+'0';
            For j:=1 to AbflussMax do
              Zeile:=Zeile+' - '+Abfluesse[j].zgr.Name;
          End;
          Baum:=Parse.Parse(Zeile,Nil);
          If parse.SyntaxError Then Begin
             MessageDlg(ErrorTxt10+cr+ErrorMsg(Parse.ErrorArt),mtError,[mbok],0);
             Exit;
          End;
        End; { with PZustandObjekt(At(i))^}

      k:=Round((NumerikDlg.EndZeit-NumerikDlg.StartZeit)/NumerikDlg.dt);
    (*  AutoMinMax:=State^.automatisch and not State^.gleich; *)

    For i:=0 to Application.componentCount-1 do
      if Application.Components[i] is TTabForm then
         with Application.Components[i] as TTabForm do InitWerte(k+1)
      else if Application.Components[i] is TGraphForm then
         with Application.Components[i] as TGraphForm do InitWerte(k+1)
      else if Application.Components[i] is TPhaseForm then
         with Application.Components[i] as TPhaseForm do InitWerte(k+1);

{========================================================================== }
  {  Berechne_Werte;   }
For j:=1 to k+1 do Begin
    MainForm.Gauge1.progress:=Round(j/k*100);
   (* Application.ProcessMessages;*)

    { Jetzt die Zwischenwerte und die Ventile berechnen }
    If not Berechne_Werte then goto AError;
    { Jetzt die Zustände berechnen }

    If NumerikDlg.Euler Then  Begin  { Euler-Cauchy-Verfahren }
      For i:=0 to Count-1 do
        If items[i].Key=ZustandId Then
           With items[i] {as TZustandObjekt} Do begin
             z_Wert:=Parse.Berechne(Baum);
             If Parse.ArithmeticError>0 Then goto AError;
           end;
    { ==================================================================================== }
    End Else Begin                 { Runge-Kutta-Verfahren }
       { Die Zwischenwerte müssen umkopiert werden, da sonst in der Ausgabe nur die
         Werte nach dem 4. Runge-Schritt erscheinen.
         Anschließend müssen die Werte nach dem 1 Runge-Schritt wieder hergestellt
         werden.}
       For i:=0 to Count-1 do
        If (items[i].Key=WertId)or (items[i].Key=VentilId) Then
           With items[i] Do
               v_wert:=g_Wert;

       For i:=0 to Count-1 do                              { 1. k1 - berechnen }
        If items[i].Key=ZustandId Then
           With items[i] as TZustandObjekt Do
             Begin
               v_wert:=g_Wert;
               k1:=NumerikDlg.dt*Parse.Berechne(Baum);
             End;
       For i:=0 to Count-1 do                              { umkopieren }
        If items[i].Key=ZustandId Then
           With items[i] as TZustandObjekt Do g_Wert:=v_Wert+k1/2;
       If not Berechne_Werte then goto AError;


       For i:=0 to Count-1 do                              { 2. k2 - berechnen }
        If items[i].Key=ZustandId Then
           With items[i] as TZustandObjekt Do
               k2:=NumerikDlg.dt*Parse.Berechne(Baum);
       For i:=0 to Count-1 do                              { umkopieren }
        If items[i].Key=ZustandId Then
           With items[i] as TZustandObjekt Do g_Wert:=v_Wert+k2/2;
       If not Berechne_Werte then goto AError;


       For i:=0 to Count-1 do                              { 3. k3 - berechnen }
        If items[i].Key=ZustandId Then
           With items[i] as TZustandObjekt Do
               k3:=NumerikDlg.dt*Parse.Berechne(Baum);
       For i:=0 to Count-1 do                              { umkopieren }
        If items[i].Key=ZustandId Then
           With items[i] as TZustandObjekt Do g_Wert:=v_Wert+k3;
       If not Berechne_Werte then goto AError;


       For i:=0 to Count-1 do                              { 3. k3 - berechnen }
        If items[i].Key=ZustandId Then
           With items[i] as TZustandObjekt Do  Begin
               k4:=NumerikDlg.dt*Parse.Berechne(Baum);  End;
       If Parse.ArithmeticError>0 Then goto AError;
       For i:=0 to Count-1 do                              { 3. k3 - berechnen }
        If items[i].Key=ZustandId Then
           Begin
             With items[i] as TZustandObjekt Do Begin
                try
                   z_Wert:=v_Wert+(k1+2*k2+2*k3+k4)/6
                except
                     if MessageDlg(ErrorTxt19,mtError,mbOkCancel,0)<>0 then
                end;
                g_Wert:=V_Wert;
             End;
           End;
       { Jezt die Zwischengrößen wieder herstellen }
       For i:=0 to Count-1 do                              { 3. k3 - berechnen }
         If (items[i].Key=WertId) or (items[i].Key=VentilId) Then
           With items[i] Do g_wert:=v_Wert;
    End;

    { Funktion AlterWert dabei ? }
    For i:=0 to Count-1 do
      If items[i].delay Then Begin
        RZ:=TRR.create;
        RZ.init(items[i].g_wert);
        items[i].DelayValue.add(RZ);
      End;

    For i:=0 to Application.componentCount-1 do
      if Application.Components[i] is TTabForm then
         with Application.Components[i] as TTabForm do HoleWerte(Parse.Zeit^.ValueRR)

      else if Application.Components[i] is TGraphForm then
         with Application.Components[i] as TGraphForm do HoleWerte(Parse.Zeit^.ValueRR)

      else if Application.Components[i] is TPhaseForm then
         with Application.Components[i] as TPhaseForm do HoleWerte(Parse.Zeit^.ValueRR);

    { =========================================================================== }
    { Maxima und Minima festhalten }
    For i:=0 to Count-1 do with items[i] do
      begin
        if g_wert<Minimum then Minimum:=g_Wert;
        if g_wert>Maximum then Maximum:=g_wert;
        if G_Wert>GMaximum Then GMaximum:=G_Wert;
        if G_Wert<GMinimum Then GMinimum:=G_Wert;
      end;

    { Jetzt umkopieren }
    For i:=0 to Count-1 do
      With items[i] Do
        If key=ZustandId Then
            Begin V_Wert:=G_Wert;G_Wert:=Z_Wert;Z_Wert:=0.0; End;

    Parse.SetzeVariable(Parse.Zeit,Parse.Zeit^.ValueRR+Parse.dt^.ValueRR);
 End;    { Ende der Schleife }
End; { With ObjListe }

If GMaximum<=GMinimum Then Begin GMinimum:=0;GMaximum:=10 End;
If GMaximum>1e10 Then GMaximum:=1e10;
If GMinimum<-1e10 Then GMinimum:=-1e10;

For i:=0 to Application.componentCount-1 do
  if Application.Components[i] is TTabForm then
    with Application.Components[i] as TTabForm do ExitWerte(GMinimum,GMaximum)
  else if Application.Components[i] is TGraphForm then
         with Application.Components[i] as TGraphForm do ExitWerte(GMinimum,GMaximum)
  else if Application.Components[i] is TPhaseForm then
         with Application.Components[i] as TPhaseForm do ExitWerte(GMinimum,GMaximum);
(*
   If State^.InitZeigeDatum Then  XTWindow^.SetDate(AktDate) Else  XTWindow^.SetDate(Nil);
   InvalidateRect(XTWindow^.Hwindow,Nil,True)
   { XT-Window neu zeichnen }
 End;  *)

(* if State^.ModellEd^.Parent^.IndexOf(xyWindow) <> 0 Then Begin
   xyWindow^.SetScale(MakeRound(s1min),MakeRound(s1max),MakeRound(s2min),MakeRound(s2max));
   If State^.InitZeigeDatum Then xyWindow^.SetDate(AktDate)  Else  xyWindow^.SetDate(Nil);
 End;     *)

 { Funktion AlterWert dabei ?  Dann wieder löschen}
 For i:=0 to ObjektListe.Count-1 do
      If ObjektListe.items[i].delay Then Begin
        For j:=0 to ObjektListe.items[i].DelayValue.Count-1 Do
           Dispose(ObjektListe.items[i].DelayValue.items[j]);
        While ObjektListe.items[i].DelayValue.count>0 do ObjektListe.items[i].DelayValue.delete(0);
        ObjektListe.items[i].delay:=False
      End;
 Exit;

 AError:
         Case Parse.ArithmeticError of
         1: MessageDlg(ErrorTxt11+#10#13+ErrorTxt20,mtError,[mbok],0);
         2: MessageDlg(ErrorTxt12+#10#13+ErrorTxt20,mtError,[mbok],0);
         3: MessageDlg(ErrorTxt13+#10#13+ErrorTxt20,mtError,[mbok],0);
         4: MessageDlg(ErrorTxt14+#10#13+ErrorTxt20,mtError,[mbok],0);
         End;

End;


initialization
  Simulator:=TSimulator.create;
End.
