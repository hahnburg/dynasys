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

Unit SimObjekt;

{$MODE Delphi}

interface

uses SysUtils, unix, Forms, Messages, Classes, Graphics, Dialogs,  LCLType,
     LCLProc, Parser, LCLIntf;
     (*Status,*) (*,NumerikParameter*)

Const Radius = 22;  { Größe des Kreis für Zustandsgrößen/Parameter }
      Hoehe  = 22;
      Breite = 32;

      Steps  = 20;

      MaxVerb    = 10;
      MaxFluesse = 5;

      MaxLenName = 32;
      MaxLenEing = 255;

      ZustandID  = 8;
      WertID     = 4;
      VentilID   = 6;
      WirkPfeilID= -1;
      WolkeID    = -2;

      { Konstanten für Tabellenfunktion }
      NoTab      = 0;
      EditTab    = 1;
      FileTab    = 2;

Type
   RR = double;

   NameStr = String[MaxLenName];
   EingabeStr = String[MaxLenEing];

   PunktIndex = (Anfang,Bezier1,b11,Bezier2,b22,Ende);
   TPunktFeld =  Array [PunktIndex] of TPoint;
   PfeilModus = (pGerade,pNeu,pLoesche,pVerschiebe);

   TSimuObjekt = class; //forward declaration
  // Simo =   Record zgr:TSimuObjekt; index:Integer End;
   TSimuObjekt = class(TPersistent)
               Procedure   Init(x,y:Integer;AName:NameStr);  virtual;
               Procedure   Zeichne;                          virtual;  abstract;
               procedure   ZeichneMarkierung;                virtual;  abstract;
               Procedure   Radiere;                          virtual;
               Procedure   Loesche;                          virtual;
               Procedure   SchreibeNamen;                    virtual;
               Procedure   LoescheNamen;                     virtual;
               Procedure   SetzeNamen(AName:NameStr);        virtual;
               Procedure   MarkiereNamen;                    virtual;
               Function    istNamen(x,y:integer):boolean;    virtual;
               Procedure   getPositionNamen(var rec:tRect); virtual;
               Procedure   Verschiebe(dx,dy:Integer);        virtual;
               Procedure   SetzeAuswahl  ;                   virtual;
               Procedure   LoescheAuswahl  ;                 virtual;
               Function    GetObjekt(x,y:Integer):TSimuObjekt;virtual;
               function    istObjekt(x,y:integer):boolean;   virtual;abstract;
               Procedure   GetPosition(Var rect:tRect);      virtual;
               Procedure   SetPosition(x,y:integer);         virtual;abstract;
               Procedure   VerbindeEingang(zgr:TSimuObjekt); virtual;
               Procedure   VerbindeAusgang(zgr:TSimuObjekt); virtual;
               Procedure   LoescheAusgang (zgr:TSimuObjekt); virtual;
               Procedure   LoescheEingang (zgr:TSimuObjekt); virtual;
               Procedure   Store(Var S:TWriter);             virtual;
               Procedure   Load (Var S:TReader);             virtual;
               Procedure   ErzeugeZeiger;                    virtual;
             public
               Key          : Integer;
               Breite,Hoehe : Integer;
               Position     : TRect;
               Mitte        : TPoint;
               Name         : NameStr;
               Eingabe      : EingabeStr;
               Baum         : ParserPtr;
               Z_Wert       : RR;
               G_Wert       : RR;
               V_Wert       : RR;
               Maximum,Minimum : RR;
               Ausgabe_id   : integer;
               Phasen_id    : integer;
               Tabellen_id  : integer;
               selected     : boolean;
               gueltig      : Boolean;
               geloescht    : Boolean;
               delay        : Boolean;
               DelayValue   : TList;
               AusgangMax   : Integer;
               EingangMax   : Integer;
               Ausgaenge    : Array [1..MaxVerb] of Record zgr:TSimuObjekt; index:Integer End;
               Eingaenge    : Array [1..MaxVerb] of Record zgr:TSimuObjekt; index:Integer End;
             End;


  TWertObjekt = class(TSimuObjekt)
          Procedure   Init(x,y:Integer;AName:NameStr); override;
          Procedure   Load(Var S : TReader);          override;
          Procedure   Store(Var S : TWriter);         override;
          Procedure   Zeichne;                        override;
          Procedure   ZeichneMarkierung;              override;
          function    istObjekt(x,y:integer):boolean; override;
          Procedure   Radiere;                        override;
        public
          xtbf : Byte;
          xmin,xmax,ymin,ymax : Real;
          Tabelle : TList;
      End;


  TVentilObjekt = class(TSimuObjekt)
          procedure Init(x,y:Integer;AName:NameStr;
                                             AZufluss,AAbfluss:TSimuObjekt); virtual;
         Procedure  Load (Var S:TReader);          override;
         Procedure   Loesche;                      override;
         Procedure   Zeichne;                      override;
         procedure   ZeichneMarkierung;            override;
         Procedure   Verschiebe(dx,dy:integer);    override;
         Procedure   Store(Var S:TWriter);         override;
         Procedure   ErzeugeZeiger;                override;
         function    istObjekt(x,y:integer):boolean; override;
       public
         ZuFluss,AbFluss : TSimuObjekt;
         ZuFlussIndex,AbFlussIndex:Integer;
         mx,my:Integer;
    End;

  TZustandObjekt = class(TSimuObjekt)
              Procedure   Init(AMitte:TPoint;AName:NameStr);virtual;
             Procedure   Load (Var S:TReader);             override;
             Procedure   Loesche;                          override;
             Procedure   Zeichne;                          override;
             procedure   ZeichneMarkierung;                override;
             function    istObjekt(x,y:integer):boolean;   override;
             Procedure   Verschiebe(dx,dy:Integer);        override;
             Procedure   VerbindeZufluss(zgr:TSimuObjekt); virtual;
             Procedure   VerbindeAbfluss(zgr:TSimuObjekt); virtual;
             Procedure   LoescheZuFluss (zgr:TSimuObjekt); virtual;
             Procedure   LoescheAbfluss (zgr:TSimuObjekt); virtual;
             Procedure   Store(Var S:TWriter);             override;
             Procedure   ErzeugeZeiger;                    override;
           public
             StartWert : ParserPtr;
             k1,k2,k3,k4 : Real;    { Runge-Verfahren }
             ZuflussMax,AbFlussMax : integer;
             Abfluesse,ZuFluesse : Array [1..MaxFluesse] of
                    Record zgr:TSimuObjekt; index:Integer End;
         End;


   TWolkeObjekt = class(TSimuObjekt)
             procedure   Init(x,y:Integer);                 virtual;
             procedure   Load(Var S:TReader);               override;
             Procedure   Zeichne;                           override;
             procedure   ZeichneMarkierung;                 override;
             Procedure   Verschiebe(dx,dy:Integer);         override;
             Procedure   SetVentil(AVentil:TSimuObjekt);    virtual;
             Procedure   Store (Var S:TWriter);             override;
             Procedure   ErzeugeZeiger;                     override;
             Procedure   SetPosition(x,y:Integer);          override;
             function    istObjekt(x,y:integer):boolean;    override;
           public
             Ventil  : TSimuObjekt;
             VentilIndex: integer;
          End;


   TWirkPfeilObjekt = class(TSimuObjekt)
             procedure Init(Avon,Anach : TSimuObjekt);      virtual;
             procedure VeraendereBezierPunkt1(B1:TPoint);
             procedure VeraendereBezierPunkt2(B2:TPoint);

             procedure Zeichne;                             override;
             procedure Radiere;                             override;
             procedure ZeichneMarkierung;                   override;
             Procedure VerschiebeAnfang(dx,dy:integer);     virtual;
             Procedure VerschiebeEnde(dx,dy:integer);       virtual;
             Procedure Verschiebe(dx,dy:integer);           override;
             procedure ZeichnePfeil(P:TPunktFeld;Modus:PfeilModus);
             function  IstAnfangspunkt(x,y:integer):boolean;
             function  IstEndPunkt(x,y:integer):boolean;
             function  IstBezierPunkt1(x,y:integer):boolean;
             function  IstBezierPunkt2(x,y:integer):boolean;
             function  istObjekt(x,y:integer):boolean;      override;

             procedure   Load(Var S:TReader);               override;
             Procedure   Loesche;                           override;
             Procedure   Store (Var S:TWriter);             override;
             Procedure   ErzeugeZeiger;                     override;
            public
             von,nach           : TSimuObjekt;
             vonIndex,nachIndex :Integer;
             P                  : TPunktFeld;
            private
             PolyAlt,PolyNeu : array[0..steps] of TPoint;
             Pfeil : array[0..3] of TPoint;
             PMalt : TPoint;
          End;



{======================================================================================== }

implementation

uses Liste, ModEditor, GeoUtil, Util;




Function Max(x,y:integer):Integer;
Begin
  if x>y Then Max:=x Else Max:=y
End;

Function Min(x,y:integer):integer;
Begin
  if x<y Then Min:=x Else Min:=y
End;

{======================================================================================== }
{======================================================================================== }
{======================================================================================== }


procedure TSimuObjekt.Init(x,y:Integer;AName:NameStr);
Begin
  Key:=-1;     { muß überschrieben werden }
  Name:=AName;
  Eingabe:='';
  gueltig:=False;
  geloescht:=False;
  selected:=false;
  AusgangMax:=0;
  EingangMax:=0;
  Breite:=32;Hoehe:=22;
  G_Wert:=0.0;
  V_Wert:=0.0;
  Z_Wert:=0.0;
  Maximum:=0.0;
  Minimum:=0.0;
  Delay:=false;
  DelayValue:=TList.Create;
  Baum:=NIL;
  Mitte:=Point(x,y);
  Position:=Rect(x-Breite div 2,y - Hoehe div 2, x+Breite div 2,y+Hoehe div 2);
End;

Procedure TSimuObjekt.Loesche;
Var p:TSimuObjekt;
    i:integer;
Begin
  if not geloescht then Begin
    for i:=1 to EingangMax Do Begin
     P:=Eingaenge[i].zgr;
     p.Loesche;
    End;
    for i:=1 to AusgangMax Do Begin
      P:=Ausgaenge[i].zgr;
      P.Loesche;
    End;
    self.Radiere;
    geloescht:=True;
  End;
End;

Procedure   TSimuObjekt.SchreibeNamen;
Var
    yChar,xChar:integer;
Begin
  with ModellEditor.Modell.Canvas do begin
    Font.Name:='Arial';
    Font.Size:=8;
    Font.Color:=clBlack;
    yChar:=Mitte.y+13;
    xChar:=Mitte.x-TextWidth(Name) div 2;
    TextOut(xchar,ychar,Name);
    if not gueltig then
      TextOut(Mitte.x-TextWidth('?') div 2,Mitte.y-TextHeight('?')div 2,'?');
  end;
End;

Procedure TSimuObjekt.MarkiereNamen;
Var
   xChar,yChar:integer;
Begin
   with ModellEditor.Modell.Canvas do begin
    Font.Name:='Arial';
    Font.Size:=8;
    yChar:=Mitte.y+13;
    xChar:=Mitte.x-TextWidth(Name) div 2 - 1;
    DrawFocusRect(Rect(xChar,yChar,xChar+TextWidth(Name)+2,yChar+13));
   End;
End;

Function TSimuObjekt.istNamen;
Var yChar,xChar:integer;
    R:tRect;
    P:tPoint;
Begin
   with ModellEditor.Modell.Canvas do begin
    Font.Name:='Arial';
    Font.Size:=8;
    yChar:=Mitte.y+13;
    xChar:=Mitte.x-TextWidth(Name) div 2 - 1;
    R:=Rect(xChar,yChar,xChar+TextWidth(Name)+2,yChar+13);
    P:=Point(x,y);
    result:=PtInRect(R,P);
   End;
End;

Procedure TSimuObjekt.GetPositionNamen;
Var xChar,yChar:integer;
Begin
 with ModellEditor.Modell.Canvas do begin
    Font.Name:='Arial';
    Font.Size:=8;
    yChar:=Mitte.y+13;
    xChar:=Mitte.x-TextWidth(Name) div 2 - 1;
    Rec:=Rect(xChar,yChar,xChar+TextWidth(Name)+2,yChar+13);
   End;
End;

Procedure   TSimuObjekt.LoescheNamen;
Var  yChar,xChar:integer;
Begin
  with ModellEditor.Modell.Canvas do begin
    Font.Name:='Arial';
    Font.Size:=8;
    Font.Color:=clWhite;
    yChar:=Mitte.y+13;
    xChar:=Mitte.x-TextWidth(Name) div 2;
    TextOut(xchar,ychar,Name);
    if not gueltig then
      TextOut(Mitte.x-TextWidth('?') div 2,Mitte.y-TextHeight('?')div 2,'?');
  end;
End;

Procedure TSimuObjekt.Radiere;
Begin
  ModellEditor.Modell.Canvas.Pen.Mode := pmNotXor;
  self.Zeichne;
  LoescheNamen;
End;

Function TSimuObjekt.GetObjekt(x,y:Integer):TSimuObjekt;
Var P : tPoint;
Begin
  P:=Point(x,y);
  If PtInRect(Position,P) Then GetObjekt:=self
  Else GetObjekt:=Nil
End;


Procedure   TSimuObjekt.SetzeNamen(AName:NameStr);
Begin
  Name:=AName;
End;

Procedure   TSimuObjekt.Verschiebe(dx,dy:Integer);
Var P:TSimuObjekt;
    i:Integer;
Begin
(*
  for i:=1 to EingangMax Do Begin
    P:=Eingaenge[i].zgr;
    P.Radiere;
  End;
  for i:=1 to AusgangMax Do Begin
    P:=Ausgaenge[i].zgr;
    P.Radiere;
  End;
  Self.Radiere;
*)
  Mitte:=Point(Mitte.x+dx,Mitte.y+dy);
  With Mitte do
    Position:=Rect(x-Breite div 2,y - Hoehe div 2, x+Breite div 2,y+Hoehe div 2);
  for i:=1 to EingangMax Do Begin
    P:=Eingaenge[i].zgr;
    TWirkPfeilObjekt(P).VerschiebeEnde(dx,dy);
   // P.Zeichne;
  End;
  for i:=1 to AusgangMax Do Begin
    P:=Ausgaenge[i].zgr;
    TWirkPfeilObjekt(P).VerschiebeAnfang(dx,dy);
  //  P.Zeichne;
  End;
End;

Procedure   TSimuObjekt.SetzeAuswahl;
Begin
  selected:=true;
End;

Procedure   TSimuObjekt.LoescheAuswahl;
Begin
  selected:=false
End;

Procedure   TSimuObjekt.GetPosition(Var rect:tRect);
Begin
  rect:=Position
End;

Procedure   TSimuObjekt.VerbindeAusgang(zgr:TSimuObjekt);
Begin
  If AusgangMax<MaxVerb Then Begin
   Inc(AusgangMax);
   Ausgaenge[AusgangMax].Zgr:=zgr;
   Ausgaenge[AusgangMax].index:=ObjektListe.IndexOf(zgr);
  End;
End;

Procedure   TSimuObjekt.VerbindeEingang(zgr:TSimuObjekt);
Begin
  If EingangMax<MaxVerb Then Begin
   Inc(EingangMax);
   Eingaenge[EingangMax].Zgr:=zgr;
   Eingaenge[EingangMax].index:=ObjektListe.IndexOf(zgr);
  End;
End;

Procedure   TSimuObjekt.LoescheAusgang(zgr:TSimuObjekt);
Var loeschindex,i :integer;
Begin
   loeschindex:=-1;
   For i:=1 to AusgangMax Do
      if Ausgaenge[i].zgr=zgr Then loeschindex:=i;
   IF loeschindex=-1 Then Begin MessageBox(0,'Interner Fehler','SimuObjekt',mb_ok);exit End;
   For i:=loeschindex to AusgangMax-1 do Ausgaenge[i]:=Ausgaenge[i+1];
   Dec(AusgangMax)
End;

Procedure   TSimuObjekt.LoescheEingang(zgr:TSimuObjekt);
Var loeschindex,i :integer;
Begin
   loeschindex:=-1;
   For i:=1 to EingangMax Do
      if Eingaenge[i].zgr=zgr Then loeschindex:=i;
   IF loeschindex=-1 Then Begin MessageBox(0,'Interner Fehler','SimuObjekt',mb_ok);exit End;
   For i:=loeschindex to EingangMax-1 do Eingaenge[i]:=Eingaenge[i+1];
   Dec(EingangMax)
End;

procedure TSimuObjekt.Load(Var s:TReader);
Begin
  S.Read(Breite,SizeOf(Breite));
  S.Read(Hoehe,SizeOf(Hoehe));
  S.Read(Name,SizeOf(Name));
  S.Read(Eingabe,SizeOf(Eingabe));
  S.Read(Position,SizeOf(Position));
  S.Read(gueltig,SizeOf(gueltig));
  S.Read(AusgangMax,SizeOF(AusgangMax));
  S.Read(EingangMax,SizeOF(EingangMax));
  S.Read(Ausgaenge,SizeOf(Ausgaenge));
  S.Read(Eingaenge,SizeOf(Eingaenge));
  S.Read(Mitte,SizeOf(Mitte));
  Baum:=NIL;
  Key:=-1;
  G_Wert:=0.0;
  V_Wert:=0.0;
  Z_Wert:=0.0;
  Minimum:=0.0;
  Maximum:=0.0;
  geloescht:=false;
  Ausgabe_id:=-1;
  Phasen_id:=-1;
  Tabellen_id:=-1;
  delay:=false;
  DelayValue:=TList.Create;
End;


Procedure TSimuObjekt.Store(Var s:TWriter);
Var i:integer;
Begin
  S.Write(Breite,SizeOf(Breite));
  S.Write(Hoehe,SizeOf(Hoehe));
  S.Write(Name,SizeOf(Name));
  S.Write(Eingabe,SizeOf(Eingabe));
  S.Write(Position,SizeOf(Position));
  S.Write(gueltig,SizeOf(gueltig));
  For i:=1 To EingangMax do Eingaenge[i].index:=ObjektListe.IndexOf(Eingaenge[i].zgr);
  For i:=1 To AusgangMax do Ausgaenge[i].index:=ObjektListe.IndexOf(Ausgaenge[i].zgr);
  S.Write(AusgangMax,SizeOF(AusgangMax));
  S.Write(EingangMax,SizeOF(EingangMax));
  S.Write(Ausgaenge,SizeOf(Ausgaenge));
  S.Write(Eingaenge,SizeOf(Eingaenge));
  S.Write(Mitte,SizeOf(Mitte));
End;

Procedure TSimuObjekt.ErzeugeZeiger;
var i:integer;
Begin
  For i:=1 to EingangMax do Eingaenge[i].zgr:=ObjektListe.items[Eingaenge[i].index];
  For i:=1 to AusgangMax do Ausgaenge[i].zgr:=ObjektListe.items[Ausgaenge[i].index];
end;

{ ========================================================================== }

Procedure TZustandObjekt.Init(AMitte:TPoint;AName:NameStr);
Begin
  inherited Init(AMitte.x,AMitte.y,AName);
  Mitte:=AMitte;
  ZuFlussMax:=0;
  AbFlussMax:=0;
  key:=8;
  StartWert:=NIL;
End;


Procedure TZustandObjekt.Loesche;
Var P : TSimuObjekt;
    i : Integer;
Begin
  IF not geloescht Then Begin
    inherited loesche;
    {Referenzen auflösen }
    for i:=1 to ZuflussMax Do Begin
      P:=ZuFluesse[i].zgr;
      P.Loesche;
    End;
    for i:=1 to AbFlussMax Do Begin
      P:=Abfluesse[i].zgr;
      P.Loesche;
    End;
    geloescht:=true;
  End;
End;


Procedure   TZustandObjekt.Verschiebe(dx,dy:Integer);
Var i : integer;
Begin
{ Zuflüsse aus Quellen und Senken (Wolke) werden auch verschoben }
   For i:=1 to ZuFlussMax Do
      With  Zufluesse[i].zgr do
        if ((key=VentilId) and not selected)  Then Begin
           Verschiebe(dx,dy);
        End;
  For i:=1 to AbFlussMax Do
      With  Abfluesse[i].zgr do
        if ((key=VentilId) and not selected)  Then Begin
           Verschiebe(dx,dy);
        End;
  inherited Verschiebe(dx,dy);

End;

Procedure   TZustandObjekt.Zeichne;
Begin
  ModellEditor.Modell.Canvas.pen.color:=clBlue;
  With self.Position do
    ModellEditor.Modell.Canvas.Rectangle(left,top,right,bottom);
  ModellEditor.Modell.Canvas.pen.color:=clBlack;
  SchreibeNamen;
End;

function TZustandObjekt.istObjekt(x,y:integer):boolean;
begin
  istObjekt:=PtInRect(Position,Point(x,y)) or istNamen(x,y);
end;

Procedure   TZustandObjekt.ZeichneMarkierung;
var B,H : integer;
begin
   B:=Breite div 2;
   H:=Hoehe div 2;
   with ModellEditor.Modell do begin
      Canvas.Pen.Mode := pmNotXor;
      with Mitte do begin
        Canvas.brush.style:=bsSolid;
        Canvas.brush.color:=clBlue;
        Canvas.rectangle(x-B+1,y-H+1,x-B+6,y-H+5);
        Canvas.rectangle(x+B-1,y-H+1,x+B-6,y-H+5);
        Canvas.rectangle(x-B+1,y+H-1,x-B+6,y+H-5);
        Canvas.rectangle(x+B-1,y+H-1,x+B-6,y+H-5);
        Canvas.brush.color:=clWhite;
      end;
      Canvas.Pen.Style:=psSolid;
      Canvas.Pen.Mode := pmCopy;
    end;
    MarkiereNamen;
end;


Procedure   TZustandObjekt.VerbindeZuFluss(zgr:TSimuObjekt);
Begin
  If ZuflussMax<MaxFluesse Then Begin
   Inc(ZuflussMax);
   Zufluesse[ZuflussMax].Zgr:=zgr;
   Zufluesse[ZuflussMax].index:=ObjektListe.IndexOf(zgr);
  End;
End;

Procedure   TZustandObjekt.VerbindeAbFluss(zgr:TSimuObjekt);
Begin
  If AbflussMax<MaxFluesse Then Begin
   Inc(AbflussMax);
   Abfluesse[AbflussMax].Zgr:=zgr;
   Abfluesse[AbflussMax].index:=ObjektListe.IndexOf(zgr);
  End;
End;

Procedure   TZustandObjekt.LoescheZufluss(zgr:TSimuObjekt);
Var loeschindex,i :integer;
Begin
   loeschindex:=-1;
   For i:=1 to ZuFlussMax Do
      if Zufluesse[i].zgr=zgr Then loeschindex:=i;
   IF loeschindex=-1 Then
      Begin MessageBox(0,'Interner Fehler','ZustandObjekt',mb_ok);exit End;
   For i:=loeschindex to ZuFlussMax-1 do ZuFluesse[i]:=ZuFluesse[i+1];
   Dec(ZuFlussMax)
End;

Procedure   TZustandObjekt.LoescheAbfluss(zgr:TSimuObjekt);
Var loeschindex,i :integer;
Begin
   loeschindex:=-1;
   For i:=1 to AbFlussMax Do
      if Abfluesse[i].zgr=zgr Then loeschindex:=i;
   IF loeschindex=-1 Then
       Begin MessageBox(0,'Interner Fehler','ZustandObjekt',mb_ok);exit End;
   For i:=loeschindex to AbFlussMax-1 do AbFluesse[i]:=AbFluesse[i+1];
   Dec(AbFlussMax)
End;

procedure TZustandObjekt.Load(Var s:TReader);
Begin
  inherited Load(S);
  S.Read(ZuflussMax,SizeOf(ZuFlussMax));
  S.Read(AbflussMax,SizeOf(AbFlussMax));
  S.Read(Abfluesse,SizeOf(AbFluesse));
  S.Read(Zufluesse,SizeOf(ZuFluesse));
  StartWert:=NIL;
  key:=8;
End;

Procedure TZustandObjekt.Store(Var s:TWriter);
Var i : integer;
Begin
  inherited Store(S);
  For i:=1 To ZuflussMax do Zufluesse[i].index:=ObjektListe.IndexOf(Zufluesse[i].zgr);
  For i:=1 To AbflussMax do Abfluesse[i].index:=ObjektListe.IndexOf(Abfluesse[i].zgr);
  S.Write(ZuflussMax,SizeOf(ZuFlussMax));
  S.Write(AbflussMax,SizeOf(AbFlussMax));
  S.Write(Abfluesse,SizeOf(AbFluesse));
  S.Write(Zufluesse,SizeOf(ZuFluesse));
End;

Procedure TZustandObjekt.ErzeugeZeiger;
var i:integer;
Begin
  inherited ErzeugeZeiger;
  StartWert:=Baum;
  Baum:=NIL;
  For i:=1 to ZuFlussMax do Zufluesse[i].zgr:=ObjektListe.items[ZuFluesse[i].index];
  For i:=1 to AbFlussMax do AbFluesse[i].zgr:=ObjektListe.items[AbFluesse[i].index];

end;
{ ========================================================================== }

procedure TWertObjekt.Init(x,y:Integer;AName:NameStr);
Begin
  inherited Init(x,y,AName);
  key:=4;
  Breite:=22;Hoehe:=22;
  Mitte:=Point(x,y);
  Position:=Rect(x-Breite div 2,y - Hoehe div 2, x+Breite div 2,y+Hoehe div 2);
  xtbf:=NoTab;
  xmin:=0;xmax:=10;ymin:=0;ymax:=10;
  Tabelle:=NIL;
End;

function TWertObjekt.istObjekt(x,y:integer):boolean;
Const R=12;
begin
  istObjekt:=((abs(x-Mitte.x)<=R) and (abs(y-Mitte.y)<=R)) or istNamen(x,y);
end;



procedure TWertObjekt.Load(Var S:TReader);
var count,i:integer;
    x,y : double;
    punkt : TPunkt;
Begin
  Inherited Load(S);
  key:=4;
  S.Read(xtbf,SizeOf(xtbf));
  S.Read(xmin,SizeOf(xmin));
  S.Read(xmax,SizeOf(xmax));
  S.Read(ymin,SizeOf(ymin));
  S.Read(ymax,SizeOf(ymax));
  Tabelle:=nil;

  if xtbf<>NoTab then begin
     S.Read(count,SizeOf(count));
     if count>0 then begin
       tabelle:=TList.Create;
       for i:=1 to count do begin
          x:=S.ReadFloat;
          y:=S.ReadFloat;
          punkt:=TPunkt.create;punkt.init(x,y);
          tabelle.add(Punkt)
       end;
     end
  end
end;

procedure TWertObjekt.Store(Var S:TWriter);
var i, count, size:integer;
begin
  inherited Store(S);
  S.Write(xtbf,SizeOf(xtbf));
  S.Write(xmin,SizeOf(xmin));
  S.Write(xmax,SizeOf(xmax));
  S.Write(ymin,SizeOf(ymin));
  S.Write(ymax,SizeOf(ymax));
  if xtbf <> NoTab then begin
     count:=tabelle.Count;
     S.Write(count,SizeOf(count));
     for i:=0 to Tabelle.count-1 do begin
       S.WriteFloat(TPunkt(Tabelle.items[i]).x);
       S.WriteFloat(TPunkt(Tabelle.items[i]).y);
     end;
  end;
end;


Procedure   TWertObjekt.Zeichne;
Begin
  with ModellEditor.Modell.Canvas do begin
    if EingangMax=0 then Pen.Color:=clRed;
    with Position do begin
     RoundRect(left,top,right,bottom,left,top);
//      Arc(left,top,right,bottom,left,top,left,top);
      if xtbf=EditTab then
         TextOut(Mitte.x-TextWidth('~') div 2,
                              Mitte.y-TextHeight('~')div 2,'~');

    end;
    Pen.Color:=clBlack;
  end;
  SchreibeNamen;

    (*  Font:=CreateFontIndirect(f_normal);
  oldFont:=SelectObject(DC,Font);
  With Position do Arc(DC,left,top,right,bottom,left,top,left,top);
  If Eingangmax=0 Then Begin
     Pen:=CreatePen(ps_solid,1,RGB(255,0,0));
     PenAlt:=SelectObject(DC,Pen);
     With Position do Arc(DC,left,top,right,bottom,left,top,left,top);
     DeleteObject(SelectObject(DC,PenAlt));
  End
  Else
    With Position do Arc(DC,left,top,right,bottom,left,top,left,top);
  If xtbf=EditTab Then DrawText(DC,'~',1,Position, DT_Center or DT_vcenter or DT_SINGLELINE);
  If xtbf=FileTab Then DrawText(DC,'-',1,Position, DT_Center or DT_vcenter or DT_SINGLELINE);
  SchreibeName;
  DeleteObject(SelectObject(DC,oldFont));*)
End;

Procedure TWertObjekt.ZeichneMarkierung;
Const R = 12;
begin
    with ModellEditor.Modell do begin
      Canvas.Pen.Mode := pmNotXor;
      with Mitte do begin
        Canvas.brush.style:=bsSolid;
        Canvas.brush.color:=clRed;
        Canvas.rectangle(x-R+3,y-R+3,x-R-2,y-R-2);
        Canvas.rectangle(x+R-3,y-R+3,x+R+2,y-R-2);
        Canvas.rectangle(x-R+3,y+R-3,x-R-2,y+R+2);
        Canvas.rectangle(x+R-3,y+R-3,x+R+2,y+R+2);
        Canvas.brush.color:=clWhite;
      end;
      Canvas.Pen.Style:=psSolid;
      Canvas.Pen.Mode := pmCopy;
    end;
    MarkiereNamen;
end;


Procedure TWertObjekt.Radiere;
Var Font, oldFont : hFont;
    PenAlt,Pen : HPen;
Begin
  inherited Radiere;
(*  Pen:=CreatePen(ps_solid,1,RGB(255,255,255));
  PenAlt:=SelectObject(DC,Pen);
  With Position do Arc(DC,left,top,right,bottom,left,top,left,top);
  DeleteObject(SelectObject(DC,PenAlt));
  If xtbf<>NoTab Then Begin
    Font:=CreateFontIndirect(f_normal);
    oldFont:=SelectObject(DC,Font);
    SetTextColor(DC,RGB(255,255,255));
    if xtbf=EditTab Then DrawText(DC,'~',1,Position, DT_Center or DT_vcenter or DT_SINGLELINE);
    If xtbf=FileTab Then DrawText(DC,'-',1,Position, DT_Center or DT_vcenter or DT_SINGLELINE);
    SetTextColor(DC,RGB(0,0,0));
    DeleteObject(SelectObject(DC,oldFont));
  End;  *)
End;

{ ========================================================================== }


procedure TVentilObjekt.Init(x,y:Integer;AName:NameStr;AZuFluss,AAbFluss:TSimuObjekt);
var ex,ey,ax,ay : Integer;
Begin
  inherited Init(x,y,AName);
  key:=VentilId;
  ZuFluss:=AZuFluss;
  AbFluss:=AAbFluss;
  If ZuFluss is TZustandObjekt Then
                   TZustandObjekt(ZuFluss).VerbindeAbfluss(Self);
  If AbFluss is TZustandObjekt Then
                   TZustandObjekt(AbFluss).VerbindeZuFluss(Self);

  ex:=Zufluss.Mitte.x;
  ey:=Zufluss.Mitte.y;
  ax:=Abfluss.Mitte.x;
  ay:=Abfluss.Mitte.y;
  Breite:=40;Hoehe:=30;
  mx:=(ex+ax) div 2;
  If Zufluss.Key=WolkeId Then my:=ey
  Else if Abfluss.key=WolkeId Then my:=ay
  Else my:=(ey+ay) div 2;
  Position:=Rect( mx-Breite div 2, my+ 16 - Hoehe div 2,
                  mx+Breite div 2, my+ 16 + Hoehe div 2);
  Mitte:=Point(mx,my+16);
End;


Procedure TVentilObjekt.Loesche;
Begin
  If not geloescht Then Begin
    If ZuFluss is TZustandObjekt Then TZustandObjekt(ZuFluss).LoescheAbfluss(Self)
    Else if ZuFluss is TWolkeObjekt  Then Zufluss.Loesche;

    If AbFluss is TZustandObjekt Then TZustandObjekt(AbFluss).LoescheZuFluss(Self)
    Else if AbFluss is TWolkeObjekt  Then Abfluss.Loesche;
    inherited loesche;
    geloescht:=true;
End;
End;

Procedure   TVentilObjekt.Zeichne;
Begin
  {1. Fall  Wolke -->  Zustand}
  If ZuFluss.Key=WolkeId Then
    ZeichneFlussWolkeZustand(Zufluss.Position,Abfluss.Position,Point(mx,my));
    {2. Fall  Zustand -->  Wolke}
  If AbFluss.Key=WolkeId Then
    ZeichneFlussZustandWolke(Zufluss.Position,Abfluss.Position,Point(mx,my));
    { 2. Fall  Zustand --> Zustand }
  If (Abfluss.key=ZustandID) and (Zufluss.key=ZustandID) Then
    ZeichneFlussZustandZustand(Zufluss.Position,Abfluss.Position,Point(mx,my));
  ZeichneVentil(mx,my);
  SchreibeNamen;
End;

Procedure TVentilObjekt.ZeichneMarkierung;
Const R = 12;
begin
    with ModellEditor.Modell do begin
      Canvas.Pen.Mode := pmNotXor;
      with Mitte do begin
        Canvas.brush.style:=bsSolid;
        Canvas.brush.color:=clBlack;
        Canvas.rectangle(x-R+3,y-R+3,x-R-2,y-R-2);
        Canvas.rectangle(x+R-3,y-R+3,x+R+2,y-R-2);
        Canvas.rectangle(x-R+3,y+R-3,x-R-2,y+R+2);
        Canvas.rectangle(x+R-3,y+R-3,x+R+2,y+R+2);
        Canvas.brush.color:=clWhite;
      end;
      Canvas.Pen.Style:=psSolid;
      Canvas.Pen.Mode := pmCopy;
    end;
    MarkiereNamen;
end;

Procedure   TVentilObjekt.Verschiebe(dx,dy:integer);
Var
    ax,ex,i : integer;
    P:TSimuObjekt;
Begin

  Mitte:=Point(Mitte.x+dx,Mitte.y+dy);
  mx:=mx+dx;
  my:=my+dy;

  If Zufluss.key=WolkeID Then Begin
     ax:=Abfluss.Mitte.x;
     if Abfluss.selected
       then Zufluss.Verschiebe(dx,dy)
       else Zufluss.SetPosition(mx-(ax-mx),my);
  End
  Else If Abfluss.key=WolkeID Then Begin
     ax:=Zufluss.Mitte.x;
       if Zufluss.selected
         then Abfluss.Verschiebe(dx,dy)
         else Abfluss.SetPosition(mx-(ax-mx),my);
  End
  Else if (Abfluss.key=ZustandID) and (Zufluss.key=ZustandID) Then Begin
     ax:=Zufluss.Mitte.x;
     ex:=Abfluss.Mitte.x;
     If ((mx>ax) and (mx>ex)) Then mx:=max(ax,ex) - 20
     Else if ((mx<ax) and (mx<ex))Then mx:=min(ax,ex) + 20;
     Mitte:=Point(mx,Mitte.y);
  End
  Else Messagebox(0,'Verschiebe Ventile!','Interner Fehler',mb_ok);

  With Mitte do
    Position:=Rect(x-Breite div 2,y - Hoehe div 2, x+Breite div 2,y+Hoehe div 2);

  for i:=1 to EingangMax Do Begin
    P:=Eingaenge[i].zgr;
    TWirkPfeilObjekt(P).VerschiebeEnde(dx,dy);
   // P.Zeichne;
  End;
  for i:=1 to AusgangMax Do Begin
    P:=Ausgaenge[i].zgr;
    TWirkPfeilObjekt(P).VerschiebeAnfang(dx,dy);
  //  P.Zeichne;
  End;
End; //Verschiebe

//----------------------------------------------

function TVentilObjekt.istObjekt(x,y:integer):boolean;
Const R=12;
begin
  istObjekt:=((abs(x-Mitte.x)<=R) and (abs(y-Mitte.y)<=R))  or istNamen(x,y);
end;


procedure TVentilObjekt.Load(Var s:TReader);
Begin
  inherited Load(S);
  Breite:=40;Hoehe:=30;   { nur für alte Modelle }
  S.Read(ZuflussIndex,SizeOf(ZuflussIndex));
  S.Read(AbflussIndex,SizeOf(AbflussIndex));
  With Position do Begin
    mx:=left+Breite div 2;
    my:= top-16+Hoehe div 2;
  End;
  key:=6;
End;

Procedure TVentilObjekt.Store(Var s:TWriter);
Begin
  inherited Store(S);
  ZuFlussIndex:=ObjektListe.IndexOf(Zufluss);
  AbFlussIndex:=ObjektListe.IndexOf(AbFluss);
  S.Write(ZuflussIndex,SizeOf(ZuflussIndex));
  S.Write(AbflussIndex,SizeOf(AbflussIndex));
End;

Procedure TVentilObjekt.ErzeugeZeiger;
Begin
  inherited ErzeugeZeiger;
  ZuFluss:=ObjektListe.items[ZuFlussIndex];
  AbFluss:=ObjektListe.items[AbFlussIndex];
End;

{ ========================================================================================== }

procedure TWolkeObjekt.Init(x,y:Integer);
Begin
   inherited init(x,y,'YYY');
   Breite:=18;Hoehe:=18;
   Mitte:=Point(x,y);
   Position:=Rect(x-Breite div 2,y-Hoehe div 2,x+Breite div 2,y+Hoehe div 2);
   Ventil:=NIL;
   VentilIndex:=-1;
   Gueltig:=True;
   key:=WolkeID;
 End;

Procedure TWolkeObjekt.SetPosition(x,y:Integer);
Begin
  radiere;
  Mitte:=Point(x,y);
  Position:=Rect(x-Breite div 2,y-Hoehe div 2,x+Breite div 2,y+Hoehe div 2);
  zeichne;
End;

Procedure TWolkeObjekt.SetVentil(AVentil:TSimuObjekt);
Begin
   Ventil:=AVentil;
   VentilIndex:=ObjektListe.IndexOf(Ventil);
End;

Procedure   TWolkeObjekt.Zeichne;
Begin
  If not geloescht then
   ZeichneWolke(Mitte.x,Mitte.y,SRCCopy);
End;

procedure TWolkeObjekt.ZeichneMarkierung;
begin
end;

procedure TWolkeObjekt.Verschiebe(dx,dy:integer);
begin
  Mitte:=Point(Mitte.x+dx,Mitte.y+dy);
    with Mitte do
  Position:=Rect(x-Breite div 2,y-Hoehe div 2,x+Breite div 2,y+Hoehe div 2);
end;

function TWolkeObjekt.istObjekt(x,y:integer):boolean;
begin
  IstObjekt:=false;
end;


procedure TWolkeObjekt.Load(Var s:TReader);
Var x,y:integer;
Begin
  inherited Load(S);
  S.Read(VentilIndex,SizeOf(VentilIndex));
  gueltig:=true;
  key:=WolkeID;
  End;

Procedure TWolkeObjekt.Store(Var s:TWriter);
Begin
  inherited Store(S);
   VentilIndex:=ObjektListe.IndexOf(Ventil);
   S.Write(VentilIndex,SizeOf(VentilIndex));
End;

Procedure TWolkeObjekt.ErzeugeZeiger;
Begin
 inherited ErzeugeZeiger;
   gueltig:=true;
   Ventil:=ObjektListe.items[VentilIndex]
End;

{ ========================================================================================== }

Procedure TWirkPfeilObjekt.Init(Avon,Anach:TSimuObjekt);
Var wx,wy:Integer;
    alpha : double;
    dx,dy : integer;
Begin
  inherited Init(0,0,'Wirkpfeil');
  von:=Avon;
  nach:=ANach;
  selected:=false;
  Von.VerbindeAusgang(self);
  Nach.VerbindeEingang(self);
  gueltig:=true;
  Key:=WirkPfeilID;
  P[Anfang]:=BestimmeKreisPunkt(von.Mitte,nach.Mitte);
  P[Ende]:=BestimmeKreisPunkt(nach.Mitte,von.Mitte);


  dx:=P[Ende].x-P[Anfang].x;
  dy:=P[Ende].y-P[Anfang].y;
  if dx<>0 then alpha:=arctan(dy/dx)
  else begin
    if dy>0 then alpha:=-90/180*pi
    else alpha:=90/180*pi
  end;
  If (dx<0)  then begin
    P[Bezier1]:=Point(P[Anfang].x-Round(30*cos(alpha)),P[Anfang].y-round(30*sin(alpha)));
    P[Bezier2]:=Point(P[Ende].x+round(30*cos(alpha)),P[Ende].y+round(30*sin(alpha)));
  end else begin
    P[Bezier1]:=Point(P[Anfang].x+Round(30*cos(alpha)),P[Anfang].y+round(30*sin(alpha)));
    P[Bezier2]:=Point(P[Ende].x-round(30*cos(alpha)),P[Ende].y-round(30*sin(alpha)));
  end;
End;


procedure TWirkPfeilObjekt.VeraendereBezierPunkt1(B1:TPoint);
begin
  P[Bezier1]:=B1;
  P[Anfang]:=BestimmeKreisPunkt(von.Mitte,B1);
end;

procedure TWirkPfeilObjekt.VeraendereBezierPunkt2(B2:TPoint);
begin
  P[Bezier2]:=B2;
  P[Ende]:=BestimmeKreisPunkt(nach.Mitte,B2);
end;

procedure TWirkPfeilObjekt.Zeichne;
begin
  if not geloescht then begin
    (*P[Anfang]:=BestimmeKreisPunkt(von.Mitte,nach.Mitte);
    P[Ende]:=BestimmeKreisPunkt(nach.Mitte,von.Mitte);  *)
    ZeichnePfeil(P,pNeu);
  end;
end;

procedure TWirkPfeilObjekt.Radiere;
begin
  ZeichnePfeil(P,pLoesche);
end;

Procedure TWirkPfeilObjekt.VerschiebeAnfang(dx,dy:integer);
begin
  P[Anfang]:=Point(P[Anfang].x+dx,P[Anfang].y+dy);
  P[Bezier1]:=Point(P[Bezier1].x+dx,P[Bezier1].y+dy);
end;

Procedure TWirkPfeilObjekt.VerschiebeEnde(dx,dy:integer);
begin
  P[Ende]:=Point(P[Ende].x+dx,P[Ende].y+dy);
  P[Bezier2]:=Point(P[Bezier2].x+dx,P[Bezier2].y+dy);
end;

Procedure TWirkPfeilObjekt.Verschiebe(dx,dy:integer);
begin end;

procedure TWirkPfeilObjekt.ZeichneMarkierung;
begin
  if not geloescht then
    with ModellEditor.Modell.Canvas do begin
      Pen.Mode := pmNotXor;
  (*    rectangle(P[Anfang].x-4,P[Anfang].y-3,P[Anfang].x+4,P[Anfang].y+3);
      rectangle(P[Ende].x-4,P[Ende].y-3,P[Ende].x+4,P[Ende].y+3);  *)
      rectangle(P[Bezier1].x-4,P[Bezier1].y-3,P[Bezier1].x+4,P[Bezier1].y+3);
      rectangle(P[Bezier2].x-4,P[Bezier2].y-3,P[Bezier2].x+4,P[Bezier2].y+3);
      Pen.Style:=psDot;
      MoveTo(P[Anfang].x,P[Anfang].y);
      LineTo(P[Bezier1].x,P[Bezier1].y);
      Moveto(P[Ende].x,P[Ende].y);
      Lineto(P[Bezier2].x,P[Bezier2].y);
      Pen.Style:=psSolid;
    end;
end;

function  TWirkPfeilObjekt.IstAnfangspunkt(x,y:integer):boolean;
begin
  IstAnfangspunkt:= (Abs(x-P[Anfang].x)<6) and (Abs(y-P[Anfang].y)<6);
end;

function  TWirkPfeilObjekt.IstEndpunkt(x,y:integer):boolean;
begin
  IstEndpunkt:= (Abs(x-P[Ende].x)<4) and (Abs(y-P[Ende].y)<4);
end;

function  TWirkPfeilObjekt.IstBezierPunkt1(x,y:integer):boolean;
begin
  IstBezierPunkt1:= (Abs(x-P[Bezier1].x)<4) and (Abs(y-P[Bezier1].y)<4);
end;

function  TWirkPfeilObjekt.IstBezierPunkt2(x,y:integer):boolean;
begin
  IstBezierPunkt2:= (Abs(x-P[Bezier2].x)<4) and (Abs(y-P[Bezier2].y)<4);
end;

function TWirkPfeilObjekt.istObjekt(x,y:integer):boolean;
var i:integer;
    treffer : boolean;
begin
  treffer:=false;
  if not geloescht then
      for i:=0 to steps do
        treffer:=treffer or (Abs(x-PolyNeu[i].x)<4) and (Abs(y-PolyNeu[i].y)<4);
  if selected then
    treffer:=treffer or  IstBezierPunkt1(x,y) or  IstBezierPunkt2(x,y);
  result:=treffer;
end;


Procedure  TWirkPfeilObjekt.Loesche;
Begin
  If not geloescht then Begin
    Von.LoescheAusgang(self);
    Nach.LoescheEingang(self);
    Nach.Gueltig:=false;
    Radiere;
    geloescht:=true;
  End;
End;


procedure TWirkPfeilObjekt.Load(Var s:TReader);
Begin
  inherited Load(S);
  S.Read(VonIndex,SizeOf(VonIndex));
  S.Read(NachIndex,SizeOf(NachIndex));
  S.Read(P,SizeOf(P));
End;

Procedure TWirkPfeilObjekt.Store(Var s:TWriter);
Begin
   inherited Store(S);
   VonIndex:=ObjektListe.IndexOf(Von);
   NachIndex:=ObjektListe.IndexOf(Nach);
   S.Write(VonIndex,SizeOf(VonIndex));
   S.Write(NachIndex,SizeOf(NachIndex));
   S.Write(P,SizeOf(P));
End;

Procedure TWirkPfeilObjekt.ErzeugeZeiger;
Begin
 inherited ErzeugeZeiger;
 gueltig:=true;
 Von:=ObjektListe.items[VonIndex];
 Nach:=ObjektListe.items[NachIndex];
end;


procedure TWirkPfeilObjekt.ZeichnePfeil(P:TPunktFeld;Modus:PfeilModus);
Const PWinkel=0.8;
      Pfeillaenge=6;
Var
    i     : integer;
    xx,yy : double;

  procedure BerechneBezier(Schritt:integer; Var p1,p2:double);
  Var
    u,v : double;
    i,j : integer;
    Anzahl : integer;
  Begin
    u:=Schritt/Steps;
    p1:=0.0; p2:=0.0;
    Anzahl:=5;
    For i:=0 to Anzahl Do
      Begin
        v:=1.0;
        If i <> Anzahl Then
        Begin
          For j:=i+1 To Anzahl do
            v:=v*j;
          For j:=1 to Anzahl-i do
            v:=v/j;
        End;
        For j:=1 to i do
          v:=v*u;
        For j:=1 to Anzahl-i do
          v:=v*(1-u);
        p1:=p1+ P[PunktIndex(i)].x * v;
        p2:=p2+ P[PunktIndex(i)].y * v;
      End;
    End {Bezier};

begin { ZeichnePfeil }
  if (P[Anfang].x=P[Ende].x) and
                  (P[Anfang].y=P[Ende].y) Then Exit;
  with ModellEditor.Modell do begin
    Canvas.Pen.Mode := pmNotXor;
    Canvas.Pen.Color:=clBlue;
    Case  Modus of
pNeu :
      begin
       P[b11]:=P[Bezier1];
       P[b22]:=P[Bezier2];
       PolyNeu[0]:=Point(P[Anfang].x,P[Anfang].y);
       for i:=1 to Steps do begin
          BerechneBezier(i,XX,YY);
          PolyNeu[i]:=Point(round(XX),round(YY));
       end;
       BerechnePfeilSpitze(Pfeil,PolyNeu[steps-1].x,PolyNeu[steps-1].y,
                                               P[Ende].x,P[Ende].y);
      //Canvas.brush.color:=clBlue;
      //Canvas.brush.style:=bsSolid;
      Canvas.Polyline(Pfeil);
       Canvas.Polyline(PolyNeu);
       //ZeichnePfeilAnfang(P[Anfang]);
       //ZeichnePfeilMitte(PolyNeu[10]);
       PolyAlt:=PolyNeu;
       PMalt:=P[Anfang];
     end;
pVerschiebe:
      begin
       P[b11]:=P[Bezier1];
       P[b22]:=P[Bezier2];
       PolyNeu[0]:=Point(P[Anfang].x,P[Anfang].y);
       for i:=1 to Steps do begin
          BerechneBezier(i,XX,YY);
          PolyNeu[i]:=Point(round(XX),round(YY));
       end;
       Canvas.Polygon(Pfeil);
       Canvas.Polyline(PolyAlt);
       //ZeichnePfeilAnfang(PMalt);
       BerechnePfeilSpitze(Pfeil,PolyNeu[steps-2].x,PolyNeu[steps-2].y,
                                               P[Ende].x,P[Ende].y);
       Canvas.Polyline(PolyNeu);
       Canvas.Polyline(Pfeil);
       //ZeichnePfeilAnfang(P[Anfang]);
       PolyAlt:=PolyNeu;
       PMAlt:=P[Anfang];
     end;
pLoesche:
     begin
       Canvas.Polyline(PolyAlt);
       //ZeichnePfeilAnfang(PMalt);
       Canvas.Polygon(Pfeil);
     end;
    end;
        Canvas.Pen.Color:=clBlack;
  end;
end;
{ ========================================================================================== }
{ ========================================================================================== }
initialization
  RegisterClass(TSimuObjekt);
  RegisterClass(TWertObjekt);
  RegisterClass(TZustandObjekt);
  RegisterClass(TVentilObjekt);
  RegisterClass(TWirkPfeilObjekt);
  RegisterClass(TWolkeObjekt);
end.
