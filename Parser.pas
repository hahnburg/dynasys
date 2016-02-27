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

Unit Parser;

{$MODE Delphi}

interface

uses SysUtils, unix, Classes, Dialogs,
     Util;

type
     RR = double;
     BezString = String;
     MaxString = String;
     Relation  = (gl,gr,kl,grgl,klgl,ungl);

     FunR1 = Function (w:RR): RR;    (* Reelle, eindimensionale Funktion *)
     FunR2 = Function (w1,w2:RR) : RR;
     FunR3 = Function (w1,w2,w3:RR) : RR;
     FunR4 = Function (w1,w2,w3,w4:RR) : RR;
     FunWenn=Function (w1,w2,w3,w4:RR;Bed:Relation):RR;
     FunXtbf=Function (w1:RR; Var Werte:TList):RR;
     FunDelay=Function(w1,w2,w3,w4: RR; Var Werte:TList):RR;

     ErrorType = (
          errOK,         (* Kein Fehler *)
          errCharacter,  (* unerlaubtes Zeichen im Text *)
          errBezeichner, (* undeklarierter Bezeichner *)
          errKlammerAuf, (* "(" erwartet *)
          errKlammerZu,  (* ")" erwartet *)
          errSemikolon,  (* ";" erwartet *)
          errAusdruck,   (* Arithmetischer Ausdruck erwartet *)
          errOperator,   (* Operator erwartet *)
          errXtbf,       (* Tabellenfunktion fehlerhaft *)
          errXtbf2,      (* Tabellenfunktion muß sortiert sein *)
          errEmpty,      (* Leere Eingabe *)
          errKommentar,  (* Kommentarklammer fehlt *)
          errRelation,   (* Relation falsch *)
          errDelay,      (* Funktion AlterWert *)
          errZahl);      (* Zahldarstellung *)

     SymType = (
          SymUnbekannt, SymEnde,
          KlammerAuf, KlammerZu, SymSemikolon,
          OpMinus, OpPlus, OpDurch, OpMal, OpHoch, OpNeg,
          SymFunR1,SymFunR2,SymFunR3,SymFunR4, SymWenn, SymXtbf, SymVarRR, SymKoRR, SymBezRR,
          SymRelation,SymDelay);

     RRPtr = ^RR;
     BoolPtr = ^boolean;

     BezPtr = ^Bezeichner;
     Bezeichner = Record
          Name: BezString;
          CASE BezArt: SymType OF
               SymFunR1 :  (Fkt1    : FunR1);
               SymFunR2 :  (Fkt2    : FunR2);
               SymFunR3 :  (Fkt3    : FunR3);
               SymFunR4 :  (Fkt4    : FunR4);
               SymWenn  :  (Fkt6    : FunWenn);
               SymDelay :  (Fkt7    : FunDelay);
               SymXtbf  :  (Fkt5    : FunXtbf);
               SymVarRR :  (ValueRR : RR);
               SymBezRR :  (ValuePtr: RRPtr; delay:BoolPtr; WerteTab:Tlist)
          END;

     ParserPtr = ^ParserNode;
     ParserNode = RECORD
          CASE OperArt   : SymType OF
               OpNeg     : (Operand: ParserPtr);
               OpMinus, OpPlus, OpDurch, OpMal, OpHoch:
                           (Operand1, Operand2: ParserPtr);
               SymFunR1  : (BezFkt1: BezPtr;Parameter: ParserPtr);
               SymFunR2  : (BezFkt2: BezPtr;Parameter21,Parameter22:ParserPtr);
               SymFunR3  : (BezFkt3: BezPtr;Parameter31,Parameter32,Parameter33:ParserPtr);
               SymFunR4  : (BezFkt4: BezPtr;Parameter41,Parameter42,Parameter43,Parameter44:ParserPtr);
               SymXtbf   : (BezFkt5: BezPtr;Bez:ParserPtr;Anz:Integer;Tab:TList);
               SymDelay  : (BezFkt7: BezPtr;Init,delay:ParserPtr;Werte:TList);
               SymWenn   : (BezFkt6: BezPtr;Bed1,Bed2,dann,sonst:ParserPtr;Bed:Relation);
               SymVarRR  : (Variable: BezPtr);
               SymKoRR   : (KoRR: RR);
               SymBezRR  : (Bezeichner:BezPtr);

          END;

TParser = Class
     LokBezListe,XTab          : TList;
     ScanZeile                 : MaxString;
     ScanPosition, ScanErrPos  : Integer;
     SyntaxError               : BOOLEAN;
     ArithmeticError           : Byte;
     ErrorArt                  : ErrorType;
     Zeit,dt                   : BezPtr;

    Procedure Init;
    Procedure done;
    FUNCTION  HoleBezeichner(name: BezString): BezPtr; 
    PROCEDURE LerneFunktion (name: BezString; Funktion: FunR1);
    PROCEDURE LerneFunktion2 (name: BezString; Funktion: FunR2);
    PROCEDURE LerneFunktion3 (name: BezString; Funktion: FunR3);
    PROCEDURE LerneFunktion4 (name: BezString; Funktion: FunR4);
    PROCEDURE LerneWenn      (name:BezString; Funktion: FunWenn);
    PROCEDURE LerneFunktionXtbf(name:BezString; Funktion:FunXtbf);
    PROCEDURE LerneFunktionDelay(name:BezString; Funktion:FunDelay);
    PROCEDURE LerneVariable (name: BezString; Wert: RR);
    PROCEDURE LerneLokVariable (name: BezString; val:RRPtr;Adelay:BoolPtr;AWerte:TList);
    PROCEDURE SetzeVariable (bez: BezPtr; wert: RR);
    FUNCTION  parse(Eingabezeile: String;AXTab:TList): ParserPtr;  virtual;
    PROCEDURE BaumZuString(baum: ParserPtr; var st:String);
    PROCEDURE LoescheBaum(VAR p: ParserPtr);
    PROCEDURE NewNode(VAR node: ParserPtr);
    PROCEDURE LoescheLokBezListe;

    FUNCTION  berechne(baum: ParserPtr): RR;              virtual;

    private

    BezListe : TList;    (* Liste aller Bezeichner (Funktionen) *)
    Function  Ziffer (z: CHAR): BOOLEAN;
    Function  Buchstabe(z: CHAR): BOOLEAN;
    Function  AlphaNum(z: CHAR): BOOLEAN;
    PROCEDURE error(e: ErrorType);
    PROCEDURE ClearNode(VAR node: ParserNode);
    Function  LiesZeichen: CHAR;
    PROCEDURE SkipZeichen;
    PROCEDURE LiesWort(VAR s: BezString);
    PROCEDURE LiesZahl;
    PROCEDURE LiesSymbol;
    Function  LiesRelation:Relation;
    PROCEDURE StarteScanner(Eingabe: String);
    PROCEDURE SkipSymbol;
    PROCEDURE BaueSymbol(VAR nodePtr: ParserPtr);
    PROCEDURE MussSymbol(ErwartetesSymbol: SymType; err: ErrorType);
    Function  makeTerm: ParserPtr;
    Function  makePrimary: ParserPtr;
    FUNCTION  makeFaktor: ParserPtr;
    FUNCTION  makeSummand: ParserPtr;
    Function  eval(p: ParserPtr): RR;
   End;


Type tRR = Class
        Eintrag : RR;
        Procedure init(Ein:RR);
     End;


Var Parse : TParser;




implementation

uses MatheLehrer;

Procedure tRR.init;
Begin
  Eintrag:=Ein;
End;
(* ====================================================================
 * ====================   Zeichen-Behandlung   ========================
 *)

procedure TParser.init;
Begin
    BezListe := TList.Create;;
    LokBezListe:=TList.Create;
    LerneVariable('ZEIT',0.0);
    LerneVariable('DT',1.0);
    Zeit := HoleBezeichner('ZEIT');
    dt   := HoleBezeichner('DT');
End;

procedure TParser.done;
Begin
  (*Dispose(BezListe);*)
End;

Function TParser.Ziffer(z: CHAR): BOOLEAN;
BEGIN
    Ziffer := ('0' <= z) AND (z <= '9')
END ;

Function TParser.Buchstabe(z: CHAR): BOOLEAN;
BEGIN
    Buchstabe:= (('A' <= z) AND (z <= 'Z')) or (z='_') or (z='Ä') or (z='Ö') or (z='Ü') or (z='ß')
END;

Function TParser.AlphaNum(z: CHAR): BOOLEAN;
BEGIN
    AlphaNum:= Ziffer(z) OR Buchstabe(z);
END;


(* ==================================================================== *)

PROCEDURE TParser.error(e: ErrorType);
BEGIN
    IF e = errOK THEN BEGIN
        SyntaxError := FALSE;
        ErrorArt := errOK
    END ELSE
        IF NOT SyntaxError THEN BEGIN
            ErrorArt := e;
            SyntaxError := TRUE
        END
END;

(* -------------------------------------------------------------------- *)


Function TParser.HoleBezeichner(name: BezString): BezPtr;
(* ....................................................................
 * liefert zu einem BezeichnerNamen einen Pointer auf den Bezeichner-
 * deskriptor, wenn er in der Bezeichnerliste steht, sonst NIL
 *)
VAR i:Integer;
BEGIN
    i:=0;
    While (i < BezListe.Count) AND (BezPtr(BezListe.items[i])^.Name<>name) do Inc(i);
    If i<BezListe.Count Then HoleBezeichner:=BezListe.items[i]
    Else Begin
    { in der lokalen Liste nachschauen ! }
      i:=0;
      While (i < LokBezListe.Count) AND (BezPtr(LokBezListe.items[i])^.Name<>name) do Inc(i);
      If i<LokBezListe.Count Then HoleBezeichner:=LokBezListe.items[i]
    Else  HoleBezeichner:=Nil;
    End
END {HoleBezeichner};

PROCEDURE TParser.LoescheLokBezListe;
VAR i:integer;
BEGIN
  For i:=0 to LokBezListe.Count-1 do Dispose(LokBezListe.items[i]);
  While LokBezListe.count>0 do LokBezListe.delete(0);
END;

PROCEDURE TParser.LerneFunktion( name: BezString; Funktion: FunR1);
VAR  neuer: BezPtr;
BEGIN
    IF HoleBezeichner(name) <> NIL THEN Begin
         MessageDlg('Innterner Fehler 10!',mtError,[mbok],0);
         HALT;   End;     (* schon definiert! *)
    NEW(neuer);  {SIZE(Bezeichner};                  (* Platz holen ... *)
    neuer^.Name:=name;                                      (* belegen... *)
    neuer^.BezArt := SymFunR1;
    neuer^.Fkt1 := Funktion;
    BezListe.add(neuer);
END {LerneFunktion};


PROCEDURE TParser.LerneFunktion2( name: BezString; Funktion: FunR2);
VAR  neuer: BezPtr;
BEGIN
    IF HoleBezeichner(name) <> NIL THEN Begin
         MessageDlg('Interner Fehler  11!',mtError,[mbok],0);
         HALT;   End;
    NEW(neuer);
    neuer^.Name:=name;
    neuer^.BezArt := SymFunR2;
    neuer^.Fkt2 := Funktion;
    BezListe.add(neuer);
END {LerneFunktion};


PROCEDURE TParser.LerneFunktion3( name: BezString; Funktion: FunR3);
VAR  neuer: BezPtr;
BEGIN
    IF HoleBezeichner(name) <> NIL THEN Begin
         MessageDlg('Interner Fehler 13!',mtError,[mbok],0);
         HALT;   End;
    NEW(neuer);
    neuer^.Name:=name;
    neuer^.BezArt := SymFunR3;
    neuer^.Fkt3 := Funktion;
    BezListe.add(neuer);
END;

PROCEDURE TParser.LerneFunktion4( name: BezString; Funktion: FunR4);
VAR  neuer: BezPtr;
BEGIN
    IF HoleBezeichner(name) <> NIL THEN Begin
         MessageDlg('Interner Fehler 14!',mtError,[mbok],0);
         HALT;   End;
    NEW(neuer);
    neuer^.Name:=name;
    neuer^.BezArt := SymFunR4;
    neuer^.Fkt4 := Funktion;
    BezListe.add(neuer);
END;

PROCEDURE TParser.LerneWenn( name: BezString; Funktion: FunWenn);
VAR  neuer: BezPtr;
BEGIN
    IF HoleBezeichner(name) <> NIL THEN Begin
         MessageDlg('Interner Fehler 15!',mtError,[mbok],0);
         HALT;   End;
    NEW(neuer);
    neuer^.Name:=name;
    neuer^.BezArt := SymWenn;
    neuer^.Fkt6 := Funktion;
    BezListe.add(neuer);
END;

PROCEDURE TParser.LerneFunktionXtbf( name: BezString; Funktion: FunXtbf);
VAR  neuer: BezPtr;
BEGIN
    IF HoleBezeichner(name) <> NIL THEN Begin
         MessageDlg('Interner Fehler 15!',mtError,[mbok],0);
         HALT;   End;
    NEW(neuer);
    neuer^.Name:=name;
    neuer^.BezArt := SymXtbf;
    neuer^.Fkt5 := Funktion;
    BezListe.add(neuer);
END;

PROCEDURE TParser.LerneFunktionDelay( name: BezString; Funktion : FunDelay);
VAR  neuer: BezPtr;
BEGIN
    IF HoleBezeichner(name) <> NIL THEN Begin
         MessageDlg('Interner Fehler 15!',mtError,[mbok],0);
         HALT;   End;
    NEW(neuer);
    neuer^.Name:=name;
    neuer^.BezArt := SymDelay;
    neuer^.Fkt7 := Funktion;
    BezListe.add(neuer);
END;


PROCEDURE TParser.LerneVariable( name: BezString;  wert: RR);
VAR
    neuer: BezPtr;
BEGIN
    IF HoleBezeichner(name) <> NIL THEN Begin
         MessageDlg('Interner Fehler 16!',mtError,[mbok],0);
         HALT;   End;
    NEW(neuer);
    neuer^.Name:=name;
    StrGross(neuer^.Name);
    neuer^.BezArt := SymVarRR;
    neuer^.ValueRR := wert;
    BezListe.add(neuer);
END;

PROCEDURE TParser.LerneLokVariable( name: BezString;val:RRPtr;ADelay:BoolPtr;AWerte:TList);
VAR neuer: BezPtr;
BEGIN
    IF HoleBezeichner(name) <> NIL THEN Exit;  (* schon definiert! *)
    NEW(neuer);    (* Platz holen... *)
    neuer^.Name:=name;
    StrGross(neuer^.Name);
    neuer^.BezArt := SymBezRR;
    neuer^.ValuePtr := val;
    neuer^.delay:=Adelay;
    neuer^.delay^:=false;
    neuer^.WerteTab:=AWerte;
    LokBezListe.add(neuer);
END {LerneLokVariable};

PROCEDURE TParser.SetzeVariable(bez: BezPtr; wert: RR);
BEGIN
    IF bez = NIL THEN Begin
       MessageDlg('Interner Fehler 17!',mtError,[mbok],0); Halt End;
    IF bez^.BezArt <> SymVarRR THEN Begin   (* muss Variable sein *)
       MessageDlg('Interner Fehler 18!',mtError,[mbok],0); Halt End;
    bez^.ValueRR := wert
END {SetzeVariable};


PROCEDURE TParser.ClearNode(VAR node: ParserNode);
(* loescht einen ParserKnoten. Rein prophylaktische Angelegenheit *)
BEGIN
    WITH node DO
        CASE OperArt OF
            OpMinus, OpPlus, OpMal, OpDurch, OpHoch:
              Begin
                Operand1 := NIL;
                Operand2 := NIL
              End;
            OpNeg:     Operand := NIL;
            SymFunR1:  Parameter := NIL;
            SymFunR2:  Begin Parameter21:=NIL; Parameter22:=NIL End;
            SymFunR3:  Begin Parameter31:=NIL; Parameter32:=NIL; Parameter33:=NIL End;
            SymFunR4:  Begin Parameter41:=NIL; Parameter42:=NIL;
                             Parameter43:=NIL; Parameter44:=NIL End;
            SymVarRR:  Variable := NIL;
            SymBezRR:  Bezeichner:=NIL;
        ELSE
            (* NICHTS, nix zum loeschen da *)
        END
END {ClearNode};


PROCEDURE TParser.BaumZuString(baum: ParserPtr;var st: String);
VAR
    um:String[30];
    ump:Array[0..20] of Char;

    PROCEDURE schreib(s: String);
    BEGIN
       st:=st+s;
    END {schreib};

    PROCEDURE wandle(p: ParserPtr; level: SymType);
    BEGIN WITH p^ DO BEGIN
        IF OperArt < level THEN schreib('(');
        CASE OperArt OF
            OpNeg:
                Begin
                  schreib('- ');
                  wandle(Operand, OpNeg);
                End;
            OpMinus:
                Begin
                  wandle(Operand1,OpMinus);
                  schreib(' - ');
                  wandle(Operand2,OpDurch)
                End;
            OpPlus:
                Begin
                  wandle(Operand1, OpPlus);
                  schreib(' + ');
                  wandle(Operand2, OpDurch)
                End;
            OpDurch:
                Begin
                  wandle(Operand1, OpDurch);
                  schreib(' / ');
                  wandle(Operand2, OpHoch)
                End;
            OpMal:
                Begin
                  wandle(Operand1, OpMal);
                  schreib(' * ');
                  wandle(Operand2, OpHoch)
                End;
            OpHoch:
                Begin
                  wandle(Operand1, OpNeg);
                  schreib(' ^ ');
                  wandle(Operand2, OpHoch)
                End;
            SymVarRR,SymBezRR:
                schreib(Variable^.Name);
            SymFunR1:
                Begin
                  schreib(BezFkt1^.Name);
                  schreib(' ');
                  wandle(Parameter, OpNeg)
                End;
            SymFunR2:
                Begin
                  schreib(BezFkt3^.Name);
                  schreib('('); wandle(Parameter21, OpNeg); schreib(',');
                  wandle(Parameter22, OpNeg); schreib(')');
                End;
            SymFunR3:
                Begin
                  schreib(BezFkt3^.Name);
                  schreib('('); wandle(Parameter31, OpNeg); schreib(',');
                  wandle(Parameter32, OpNeg);
                  schreib(','); wandle(Parameter33, OpNeg); schreib(')');
                End;
            SymFunR4:
                Begin
                  schreib(BezFkt3^.Name);
                  schreib('(');  wandle(Parameter41, OpNeg); schreib(',');
                  wandle(Parameter42, OpNeg);  schreib(',');
                  wandle(Parameter43, OpNeg);  schreib(',');
                  wandle(Parameter44, OpNeg);  schreib(')');
                End;
            SymKoRR:
                Begin
                  str(KoRR:4:1,um);
                  StrPCopy(ump,um);
                  schreib(ump)
                End;
        END;
        IF OperArt < level THEN schreib(')');
    END END {wandle};
BEGIN

    st:='';
    If baum<>nil then
      wandle(baum, SymEnde);
END {BaumZuString};


(* ====================================================================
 * ==================   1. Teil: der Scanner   ========================
 *)

VAR
    ScanNode: ParserNode;       (* naechste Symbol vom Scanner  *)
    ScanChar: CHAR;

Function TParser.LiesZeichen: CHAR;
VAR z: CHAR;

  Procedure Kommentar;
  Begin
    While (ScanPosition <= 255)
           AND (ScanPosition<Length(ScanZeile))
           And (ScanZeile[Scanposition]<>'}')
      do  INC(ScanPosition);
    If ScanZeile[Scanposition]='}' Then Begin
         Inc(Scanposition);ScanChar:=ScanZeile[ScanPosition] End
    Else Begin
        error(errKommentar);
        ScanChar:=#0; End;
  End;

BEGIN
    z := ScanChar;
    IF (ScanPosition <= 255) AND (ScanPosition<Length(ScanZeile)) THEN BEGIN
        INC(ScanPosition);
        ScanChar := ScanZeile[ScanPosition]
    END ELSE
        ScanChar := #0;     (* Zeile zu Ende *)
    If ScanChar='{' Then Kommentar;
    Lieszeichen:=z
END {LiesZeichen};


PROCEDURE TParser.SkipZeichen;
VAR dummy: CHAR;
BEGIN
    dummy := LiesZeichen;
END {SkipZeichen};

PROCEDURE TParser.LiesWort(VAR s: BezString);
(* Liest genau ein Wort aus der 'ScanZeile' nach 's' *)
VAR  z: CHAR;
BEGIN
    s:='';
    REPEAT
        z := LiesZeichen;
        s:=s+z;
    UNTIL NOT AlphaNum(ScanChar);
END {LiesWort};

PROCEDURE TParser.LiesZahl;
(* einlesen einer RR- Konstante *)
VAR
    r,d10: RR;
    expo:Integer;
    Mantisse : Integer;
BEGIN
    r := 0.0;
    WHILE Ziffer(ScanChar) DO r := 10.0 * r +( ORD(LiesZeichen) - ORD('0') );
    IF (ScanChar = '.')OR(ScanChar=',') THEN BEGIN(* es kommen noch Nachkommastellen... *)
        SkipZeichen;
        d10 := 0.1;
        WHILE Ziffer(ScanChar) DO BEGIN
            r := r + (ORD(LiesZeichen)-ORD('0')) * d10;
            d10 := 0.1 * d10 END;
    End;
    IF ScanChar='E' Then Begin
        SkipZeichen;
        Mantisse:=+1;
        If ScanChar='-' Then Begin SkipZeichen;mantisse:=-1 End
        Else if ScanChar='+' Then SkipZeichen;
        expo:=0;
        If not Ziffer(ScanChar) Then Begin Error(errZahl);Exit End;
        While Ziffer(ScanChar) do Begin
          expo := 10 * expo +( ORD(LiesZeichen) - ORD('0') );
        End;
        if ln(r)/ln(10)+expo>36 Then Begin Error(errZahl);Exit End;
        If Mantisse=1 Then r:=r*exp(expo*ln(10)) Else r:=r/exp(expo*ln(10))
    END;
    ScanNode.OperArt := SymKoRR;
    ScanNode.KoRR := r
END {LiesZahl};

Function TParser.LiesRelation:Relation;
Var z1,z2:Char;
Begin
  z2:=#255;
  z1:=LiesZeichen;
  If not (z1 in ['<','>','=']) Then Begin error(errRelation); Exit End;
  If ScanChar in ['<','>','='] Then z2:=LiesZeichen;
  If z2=#255 Then
    Case z1 of
      '<' : LiesRelation:=kl;
      '>' : LiesRelation:=gr;
      '=' : LiesRelation:=gl;
    End
  Else If Z2='=' Then
    Case z1 of
      '<' : LiesRelation:=klgl;
      '>' : LiesRelation:=grgl;
      '=' : error(errRelation);
    End
  Else If Z2='>' Then
    Case z1 of
      '<' : LiesRelation:=ungl;
      '>' : error(errRelation);
      '=' : error(errRelation);
    End
  Else error(errRelation);
End;

PROCEDURE TParser.LiesSymbol;
(*
 * Liest aus der EingabeZeile ein Symbol und traegt es in 'ScanNode' ein
 *)
VAR
    BezName: BezString;
    bezei: BezPtr;
BEGIN
    IF SyntaxError THEN Begin   (* Parser nicht richtig gestoppt *)
       MessageDlg('Interner Fehler 19!',mtError,[mbok],0); Halt End;
    WHILE ScanChar = ' ' DO SkipZeichen;
    ScanErrPos := ScanPosition; (* Position merken, falls Fehler auftritt *)

    IF Buchstabe(ScanChar) THEN BEGIN            (* -------- Bezeichner -------- *)
        LiesWort(BezName);
        bezei := HoleBezeichner(BezName);
        IF bezei = NIL THEN BEGIN
            ScanNode.OperArt := SymUnbekannt;
            error(errBezeichner)
        END ELSE
            ScanNode.OperArt := bezei^.BezArt;
        ClearNode(ScanNode);
        CASE ScanNode.OperArt OF
            SymFunR1: ScanNode.BezFkt1 := bezei;
            SymFunR2: ScanNode.BezFkt2 := bezei;
            SymFunR3: ScanNode.BezFkt3 := bezei;
            SymFunR4: ScanNode.BezFkt4 := bezei;
            SymXtbf:  ScanNode.BezFkt5 := bezei;
            SymWenn:  ScanNode.BezFkt6 := bezei;
            SymDelay: ScanNode.BezFkt7 := bezei;
            SymVarRR: ScanNode.Variable := bezei;
            SymBezRR: ScanNode.Bezeichner:=bezei;
            SymUnbekannt: (* nix *)
        END
    END ELSE IF Ziffer(ScanChar) THEN            (* -------- Konstante ---------- *)
        LiesZahl
    ELSE BEGIN                     (* ---- sonst: Operator oder Satzzeichen ---- *)
        CASE ScanChar OF
            ';':    ScanNode.OperArt := SymSemikolon;
            '(':    ScanNode.OperArt := KlammerAuf;
            ')':    ScanNode.OperArt := KlammerZu;
            '-':    ScanNode.OperArt := OpMinus;
            '+':    ScanNode.OperArt := OpPlus;
            '/':    ScanNode.OperArt := OpDurch;
            '*':    ScanNode.OperArt := OpMal;
            '^':    ScanNode.OperArt := OpHoch;
             #0:    ScanNode.OperArt := SymEnde; (* Zeile zu Ende *)
   '<','>','=' :    ScanNode.OperArt := SymRelation;
        ELSE BEGIN
            ScanNode.OperArt := SymUnbekannt;
            error(errCharacter) END;
        END;
        If ScanNode.OperArt <> SymRelation Then SkipZeichen;
        ClearNode(ScanNode) (* sicherheitshalber durchloeschen *)
    END;
END {LiesSymbol};

PROCEDURE TParser.StarteScanner(Eingabe: String);
(* ---   Initialisiert den Scanner   --- *)
BEGIN   (* Reihenfolge Wichtig! *)
    ScanZeile:=Eingabe;
    StrGross(ScanZeile);
    ScanErrPos := 1;                        (* Startpositionen *)
    ScanPosition := 1;
    ScanChar := ScanZeile[1];          (* Erstes Zeichen Holen *)
    error(errOK);                      (* Fehler zuruecksetzen *)
    LiesSymbol;                        (* erstes Symbol einlesen *)
END {StarteScanner};


(* -------------------------------------------------------------------- *)

PROCEDURE TParser.NewNode(VAR node: ParserPtr);
(* -----   Erzeugt einen neuen ParserNode   ----- *)
BEGIN
    NEW(node);
    IF node = NIL THEN              (* kein Speicher: brutal raus! *)
      Begin MessageDlg('Interner Fehler 20: Kein Speicher',mtError,[mbok],0);Halt End;
    node^.OperArt := SymUnbekannt;                     (* sicherheitshalber *)
END {NewNode};

PROCEDURE TParser.LoescheBaum(VAR p: ParserPtr);
(* Loescht einen ParserBaum (gibt damit den Speicher wieder frei) *)
BEGIN
    IF p <> NIL THEN BEGIN
        CASE p^.OperArt OF
            OpNeg:
                LoescheBaum(p^.Operand);
            OpMinus, OpPlus, OpMal, OpDurch, OpHoch:
              Begin
                LoescheBaum(p^.Operand1);
                LoescheBaum(p^.Operand2)
              End;
            SymFunR1:
                LoescheBaum(p^.Parameter);
            SymFunR2:
                Begin
                  LoescheBaum(p^.Parameter21);
                  LoescheBaum(p^.Parameter22);
                End;
            SymFunR3:
                Begin
                  LoescheBaum(p^.Parameter31);
                  LoescheBaum(p^.Parameter32);
                  LoescheBaum(p^.Parameter33);
                End;
            SymFunR4:
                Begin
                  LoescheBaum(p^.Parameter41);
                  LoescheBaum(p^.Parameter42);
                  LoescheBaum(p^.Parameter43);
                  LoescheBaum(p^.Parameter44);
                End;
            SymWenn:
                Begin
                  LoescheBaum(p^.Bed1);
                  LoescheBaum(p^.Bed2);
                  LoescheBaum(p^.Dann);
                  LoescheBaum(p^.Sonst);
                End;
            SymXtbf:
                 Begin
                  LoescheBaum(p^.Bez);
                 End;
            SymDelay:
                 Begin
                  LoescheBaum(p^.Bez);
                  LoescheBaum(p^.init);
                  LoescheBaum(p^.delay);
                 End;
            SymVarRR, SymKoRR,SymBezRR,SymRelation :
                (* Nix, gibt keine UnterBaeume *)
            ELSE Begin MessageDlg('Interner Fehler: 21',mtError,[mbok],0); HALT End;
                (* da war wohl der Baum kaputt... *)
        END;
        Dispose(p);
        p := NIL
    END
END {LoescheBaum};

PROCEDURE TParser.SkipSymbol;
BEGIN
    IF NOT SyntaxError THEN LiesSymbol
END {SkipSymbol};

PROCEDURE TParser.BaueSymbol(VAR nodePtr: ParserPtr);
BEGIN
    IF SyntaxError THEN    (* Parser nicht richtig gestoppt *)
        Begin MessageDlg('Interner Fehler : 22',mtError,[mbok],0);Halt End;
    NewNode(nodePtr);
    nodePtr^ := ScanNode;
    LiesSymbol
END {BaueSymbol};

PROCEDURE TParser.MussSymbol(ErwartetesSymbol: SymType; err: ErrorType);
BEGIN
    IF ScanNode.OperArt = ErwartetesSymbol
        THEN SkipSymbol
        ELSE error(err)
END {MussSymbol};

(* ====================================================================
 * =================   2. der eigentliche Parser   ====================
 *)


Function TParser.makePrimary: ParserPtr;
Label 111,888,999;
VAR
    node : ParserPtr;
    Anz  :integer;
  (*  WPaar:PWPaar;  *)
    WertAlt:RR;
BEGIN
    IF SyntaxError THEN Begin MessageDlg('Interner Fehler: 23',mtError,[mbok],0);
                              makePrimary :=NIL;Exit END;
    CASE ScanNode.OperArt OF
        KlammerAuf: (* ---- "(" <Term> ")" ---- *)
          Begin
            SkipSymbol;
            node := makeTerm;
            MussSymbol(KlammerZu, errKlammerZu)
          End;
        OpMinus:    (* ---- "-" <Primary> ---- *)
          Begin
            BaueSymbol(node);
            node^.OperArt := OpNeg; (* das "-" hier monadisch *)
            node^.Operand := makePrimary
          End;
        SymFunR1:   (* ---- <Bezeichner> <Primary> ---- *)
          Begin
            BaueSymbol(node);
            MussSymbol(KlammerAuf, errKlammerAuf);
            node^.Parameter := makeTerm ;
            MussSymbol(KlammerZu, errKlammerZu)
          End;
        SymFunR2:   (* ---- <Bezeichner> "(" <Primary> "," <Primary> ")" ---- *)
          Begin
            BaueSymbol(node);
            MussSymbol(KlammerAuf, errKlammerAuf);
            node^.Parameter21 := makeTerm;
            MussSymbol(SymSemikolon, errSemikolon);
            node^.Parameter22 := makeTerm;
            MussSymbol(KlammerZu, errKlammerZu)
          End;
        SymFunR3:   (* ---- <Bezeichner> "(" <Primary> "," <Primary> ""," <Primary> ")" ---- *)
          Begin
            BaueSymbol(node);
            MussSymbol(KlammerAuf, errKlammerAuf);
            node^.Parameter31 := makePrimary;
            MussSymbol(SymSemikolon, errSemikolon);
            node^.Parameter32 := makePrimary;
            MussSymbol(SymSemikolon, errSemikolon);
            node^.Parameter33 := makePrimary;
            MussSymbol(KlammerZu, errKlammerZu)
          End;
        SymFunR4:   (* ---- <Bezeichner> <(> <Primary> <)> ---- *)
          Begin
            BaueSymbol(node);
            MussSymbol(KlammerAuf, errKlammerAuf);
            node^.Parameter41 := makePrimary;
            MussSymbol(SymSemikolon, errSemikolon);
            node^.Parameter42 := makePrimary;
            MussSymbol(SymSemikolon, errSemikolon);
            node^.Parameter43 := makePrimary;
            MussSymbol(SymSemikolon, errSemikolon);
            node^.Parameter44 := makePrimary;
            MussSymbol(KlammerZu, errKlammerZu)
          End;
        SymWenn:
          Begin
            BaueSymbol(node);
            MussSymbol(KlammerAuf, errKlammerAuf);
            node^.bed1 := makePrimary;

            If ScanNode.operart<>SymRelation Then
               Begin error(errRelation); MakePrimary:=nil; exit End;
            node^.Bed:=LiesRelation;  SkipSymbol;
            If SyntaxError Then Begin MakePrimary:=NIL; Exit End;

            node^.bed2 := makePrimary;                If SyntaxError Then goto 888;
            MussSymbol(SymSemikolon, errSemikolon);   If SyntaxError Then goto 888;
            node^.dann := makeTerm;                   If SyntaxError Then goto 888;
            MussSymbol(SymSemikolon, errSemikolon);   If SyntaxError Then goto 888;
            node^.sonst := makeTerm;                  If SyntaxError Then goto 888;
            MussSymbol(KlammerZu, errKlammerZu);
   888:       If SyntaxError Then
                    Begin
                      LoescheBaum(node^.bed1);
                      MakePrimary:=NIL;
                    End;
          End;
        SymXtbf:
          Begin
            WertAlt:=-1e30;
            BaueSymbol(node);
            MussSymbol(KlammerAuf, errKlammerAuf);
            node^.bez:=MakePrimary;
            MussSymbol(KlammerZu,errKlammerZu); If Syntaxerror Then goto 999;
            If Xtab<>NIL Then Begin Node^.tab:=Xtab; Goto 999; End;
            Node^.tab:=TList.create;
            MussSymbol(KlammerAuf,errKlammerAuf);
            If not SyntaxError Then
              Repeat
       (*         WPaar:=New(PWPaar,Init);
                MussSymbol(KlammerAuf, errKlammerAuf);  If Syntaxerror Then goto 999;
                WPaar^.x:=ScanNode.KoRR;Skipsymbol;     If Syntaxerror Then goto 999;
                If WPaar^.x<=WertAlt Then Error(errXtbf2); If Syntaxerror Then goto 999;
                MussSymbol(symSemikolon,errXtbf);       If Syntaxerror Then goto 999;
                WPaar^.y:=ScanNode.KoRR;SkipSymbol;     If Syntaxerror Then goto 999;
                Node^.tab^.Insert(WPaar);
                MussSymbol(Klammerzu,errKlammerZU);     If Syntaxerror Then goto 999;
                WertAlt:=WPaar^.x;   *)
              Until (ScanNode.operart=Klammerzu) or Syntaxerror;
              SkipSymbol;
   999:       If SyntaxError Then
                    Begin
                      Node^.tab.free;
                      LoescheBaum(node^.bez);
                      MakePrimary:=NIL;
                    End;
          End;
        SymDelay:
          Begin
            BaueSymbol(node);
            MussSymbol(Klammerauf, errKlammerAuf);
            node^.bez:=MakePrimary;
            if node^.bez^.OperArt<>SymBezRR Then Begin error(errDelay); goto 111; End;
            {  Messagebox(0,node^.bez^.Bezeichner^.name,'AlterWert-Test',mb_ok); }
            node^.bez^.Bezeichner^.delay^:=true;
            node^.Werte:=node^.bez^.Bezeichner^.WerteTab;
            MussSymbol(symSemikolon,errDelay);       If Syntaxerror Then goto 111;
            node^.init:=MakeTerm;                   If Syntaxerror Then goto 111;
            MussSymbol(symSemikolon,errDelay);       If Syntaxerror Then goto 111;
            node^.delay:=MakePrimary;               If Syntaxerror Then goto 111;
            MussSymbol(Klammerzu, errKlammerZu);
111:        If SyntaxError Then Begin
              LoescheBaum(node^.bez);
              MakePrimary:=NIL;
            End
          End;
        SymVarRR, SymKoRR,SymBezRR :     (* ---- Variable / Konstante ---- *)
            BaueSymbol(node)
    ELSE BEGIN
        error(errAusdruck);
        makePrimary:=NIL;
        Exit;
        End;
    END;
    makePrimary:=node;
END {makePrimary};

FUNCTION TParser.makeFaktor: ParserPtr;
VAR node, p: ParserPtr;
BEGIN
    IF SyntaxError THEN BEGIN makeFaktor:=NIL;EXIT END;
    node := makePrimary;
    IF ScanNode.OperArt = OpHoch THEN BEGIN  (* ---- <Primary> "^" <Faktor> ---- *)
        BaueSymbol(p);
        p^.Operand1 := node;
        p^.Operand2 := makeFaktor;
        node := p END;
    makeFaktor:=node;
END {makeFaktor};

FUNCTION TParser.makeSummand: ParserPtr;
VAR
    node, p: ParserPtr;
BEGIN
    IF SyntaxError THEN BEGIN makeSummand:= NIL;exit END;
    node := makeFaktor;
    While not SyntaxError and (ScanNode.OperArt IN [OpMal,OpDurch]) Do
        CASE ScanNode.OperArt OF
            OpMal, OpDurch:
              Begin
                BaueSymbol(p);
                p^.Operand1 := node;
                p^.Operand2 := makeFaktor;
                node := p
              End;
        END;
    makeSummand:=node;
END {makeSummand};

FUNCTION TParser.makeTerm: ParserPtr;
VAR
    node,p: ParserPtr;
BEGIN
    IF SyntaxError THEN BEGIN makeTerm:=NIL;exit END;
    node := makeSummand;
    While not Syntaxerror and (ScanNode.OperArt in [OpPlus,OpMinus]) Do Begin
        CASE ScanNode.OperArt OF
            OpPlus, OpMinus:
              Begin
                BaueSymbol(p);
                p^.Operand1 := node;
                p^.Operand2 := makeSummand;
                node := p
              End;
        END
    END;
    makeTerm:=node;
END {makeTerm};

FUNCTION TParser.parse(EingabeZeile:String;AXTab:TList): ParserPtr;
VAR node: ParserPtr;
BEGIN
    XTab:=AXTab;
    if (Length(EingabeZeile)=0) Then Begin
      Parse:=NIL;Error(errEmpty);
      Exit
    End;
    StarteScanner(EingabeZeile);                  (* Scanner Initialisieren *)
    node := makeTerm;                               (* Einen Term Abholen *)
    IF ScanNode.OperArt <> SymEnde THEN BEGIN
        error(errOperator);
        LoescheBaum(node) END;            (* Fehler ==> Baum wieder abbauen *)
    parse:= node
END {parse};

(* ====================================================================
 * ==============   3. der Rechner (berechnet den Baum)   =============
 *)


FUNCTION TParser.eval(p: ParserPtr): RR;
CONST schrott = 888.888;
VAR   temp: RR;
      temp1,temp2:RR;
      Anz:Integer;

    Function Power(x,y:RR):RR;
    Begin
      Power:=exp(y*ln(x))
    End;

BEGIN
    IF p = NIL THEN HALT;    (* Da ist wohl der Baum nicht vollstaendig *)
    IF ArithmeticError>0 THEN
      BEGIN
         eval:=schrott; exit
      END;    (* Bei Fehler: Ungueltig *)
    CASE p^.OperArt OF
        OpNeg:    eval:= - eval(p^.Operand);
        OpPlus:    Begin
                    temp1:=eval(p^.Operand1); temp2:=eval(p^.Operand2);
                    eval:= temp1+temp2;
                    if false then Begin ArithmeticError:=1; eval:=schrott; End;
                  End;
        OpMinus:  eval:= eval(p^.Operand1) - eval(p^.Operand2);
        OpMal:    Begin
                    temp1:=eval(p^.Operand1); temp2:=eval(p^.Operand2);
                    eval:= temp1*temp2;
                    if false then Begin ArithmeticError:=1; eval:=schrott; End;
                  End;
        OpDurch:
          BEGIN
            temp := eval(p^.Operand2);      (* Divisor zuerst Berechnen ... *)
            temp2:= eval(p^.Operand1);
            IF temp = 0.0 THEN BEGIN             (* Division durch Null abfangen *)
                ArithmeticError := 2; eval:= 1 END
            Else Begin
                    eval := temp2 / temp;
                    if false then Begin ArithmeticError:=1; eval:=schrott; End;
                 end;
          End;
        OpHoch:
          Begin
            temp := eval(p^.Operand1);
            IF temp <= 0.0 THEN BEGIN             (* negative Basis abfangen *)
                ArithmeticError := 3;
                eval:=schrott; Exit END;
            eval:= power(temp,eval(p^.Operand2))
          End;
        SymFunR1:  eval:= p^.BezFkt1^.Fkt1( eval(p^.Parameter) );
        SymFunR2:  eval:= p^.BezFkt2^.Fkt2( eval(p^.Parameter21),eval(p^.Parameter22));
        SymFunR3:
            eval:= p^.BezFkt3^.Fkt3( eval(p^.Parameter31),eval(p^.Parameter32),eval(p^.Parameter33));
        SymFunR4:
            eval:= p^.BezFkt4^.Fkt4( eval(p^.Parameter41),eval(p^.Parameter42),eval(p^.Parameter43),eval(p^.Parameter44));
        SymXtbf:   eval:=p^.BezFkt5^.Fkt5(eval(p^.Bez),p^.Tab);
{#}     SymDelay:  eval:=p^.BezFkt7^.Fkt7(eval(p^.delay),eval(p^.init),Zeit^.ValueRR,dt^.ValueRR,p^.Werte);
        SymVarRR:  eval:= p^.Variable^.ValueRR ;
        SymKoRR:   eval:= p^.KoRR;
        SymBezRR:  eval:= p^.Bezeichner^.ValuePtr^;
        SymWenn:   Begin
                        Case p^.Bed of
                           gl     : If eval(p^.bed1)=eval(p^.bed2)  Then eval:=eval(p^.dann) else eval:=eval(p^.sonst);
                           gr     : If eval(p^.bed1)>eval(p^.bed2) Then eval:=eval(p^.dann) else eval:=eval(p^.sonst);
                           kl     : If eval(p^.bed1)<eval(p^.bed2) Then eval:=eval(p^.dann) else eval:=eval(p^.sonst);
                           grgl   : If eval(p^.bed1)>=eval(p^.bed2) Then eval:=eval(p^.dann) else eval:=eval(p^.sonst);
                           klgl   : If eval(p^.bed1)<=eval(p^.bed2) Then eval:=eval(p^.dann) else eval:=eval(p^.sonst);
                           ungl   : if eval(p^.bed1)<>eval(p^.bed2) Then eval:=eval(p^.dann) else eval:=eval(p^.sonst);
                           Else  Begin ArithmeticError := 3; eval:=Schrott End;
                        End
                    (*  eval:=p^.BezFkt5^.Fkt6(eval(p^.bed1),eval(p^.bed2),
                              eval(p^.dann),eval(p^.sonst),p^.Bed); *)
                   End;
        ELSE  Begin
          MessageDlg('Interner Fehler: 24',mtError,[mbok],0); Halt
        End;         (* Baum defekt *)
    END;
END {eval};

FUNCTION TParser.berechne(baum: ParserPtr): RR;
BEGIN
    ArithmeticError := 0;   (* noch ist alles OK... *)
    berechne:=eval(baum);
END {berechne};


initialization

Parse:=TParser.Create;
Parse.init;
LehreMathe;

END {Parser}.
