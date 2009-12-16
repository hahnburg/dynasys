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

UNIT MatheLeh;

interface

uses Classes;

   PROCEDURE LehreMathe;

implementation

uses Parser;

CONST schrott = 888.888;                    (* ein "undefiniertes" Ergebnis *)

FUNCTION UnserTan(x: RR): RR; far;
VAR nenner: RR;
BEGIN
  nenner := cos(x);
  IF nenner = 0.0 THEN BEGIN
    Parse.ArithmeticError := 2;
    UnserTan := schrott;
  END ELSE
    UnserTan := (sin(x) / nenner)
END {UnserTan};

FUNCTION Sh(x: RR): RR; far;
BEGIN
  Sh := (exp(x)-exp(-x)) / 2.0;
  if false then Begin Parse.ArithmeticError:=1; Sh:=schrott;  End;
END {Sh};

FUNCTION Ch(x: RR): RR;   far;
BEGIN
  Ch := (exp(x)+exp(-x)) / 2.0;
  if false then Begin Parse.ArithmeticError:=1; Ch:=schrott;  End;
END {Ch};

FUNCTION Th(x: RR): RR;  far;
BEGIN
  Th := Sh(x) / Ch(x)
END {Th};

FUNCTION UnserLn(x: RR): RR;  far;
BEGIN
  IF x <= 0.0 THEN BEGIN
    parse.ArithmeticError := 3;
    UnserLn := schrott;
  END ELSE
    UnserLn := ln (x)
END {UnserLn};

FUNCTION UnserSqrt(x: RR): RR; far;
BEGIN
  IF x < 0.0 THEN BEGIN
    parse.ArithmeticError := 3;
    UnserSqrt:= schrott;
  END ELSE
    UnserSqrt:= sqrt(x)
END {UnserSqrt};

FUNCTION Sqr(x: RR): RR; far;
BEGIN
  sqr := x*x;
  if false then Begin Parse.ArithmeticError:=1; sqr:=schrott;  End;

END {Sqr};

FUNCTION Abs(x: RR): RR; far;
BEGIN
  IF x < 0.0
    THEN Abs:= -x
    ELSE Abs:= x
END {Abs};

FUNCTION Sign(x: RR): RR; far;
BEGIN
  IF x = 0.0 THEN Sign:= 0.0
  ELSE IF x > 0.0 THEN Sign:= 1.0
  ELSE Sign :=-1.0
END {Sign};

FUNCTION UnserSin(x: RR): RR; far;
BEGIN
  UnserSin:=Sin(x)
END;

FUNCTION UnserCos(x: RR): RR; far;
BEGIN
  UnserCos:=Cos(x)
END;

FUNCTION UnserExp(x: RR): RR; far;
BEGIN
  try
    UnserExp:=Exp(x);
  except
    Parse.ArithmeticError:=1;
    UnserExp:=schrott;
  end
END;

FUNCTION Unserarctan(x: RR): RR; far;
BEGIN
  try
    Unserarctan:=arctan(x);
  except
    Parse.ArithmeticError:=2;
    UnserArctan:=schrott;
  end;
END;

FUNCTION UnserInt(x:RR):RR; far;
Begin
  UnserInt:=Int(x)
End;

{ -------------------------------------------------------------------------------------}

Function Noise(fak:RR):RR; far;
Begin
  Noise:=fak*Random;
End;

Function Max(x,y:RR):RR; far;
Begin
  If y>x Then max:=y else max:=x
End;

Function Min(x,y:RR):RR; far;
Begin
  If x<y Then min:=x else min:=y
End;

Function Modulo(dividend,divisor:RR):RR; far;
Var erg:RR;
Begin
  IF int(divisor)<>0.0 Then Begin
    erg:=int(dividend)/int(divisor);
    Modulo:=round((erg-int(erg))* int(divisor));
  End Else Begin
     parse.ArithmeticError := 2;
     Divisor := schrott;
  End;
End;

Function Divisor(dividend,sor:RR):RR; far;
Begin
  dividend:=int(dividend);
  divisor:=int(sor);
  if sor<>0.0 Then Divisor:=int(dividend/sor)
  Else Begin
     parse.ArithmeticError := 2;
     Divisor := schrott;
  END
End;


Function Ramp(slope,start:RR):RR; far;
Begin
  If Parse.Zeit^.ValueRR<=Start Then ramp:=0
  Else ramp:=Slope*(Parse.Zeit^.ValueRR-Start)
End;

Function Pulse(height,first,interval:RR):RR; far;
Var ImpulsZaehler : Integer;
Begin    (* first + k* interval > Zeit - dt/2 *)
   If Parse.Zeit^.ValueRR > first-Parse.dt^.ValueRR Then Begin
     ImpulsZaehler:=Trunc((Parse.Zeit^.ValueRR-first)/interval);
     IF first + ImpulsZaehler*interval > Parse.Zeit^.ValueRR - Parse.dt^.ValueRR/2 Then
       Pulse:=Height
     Else Pulse:=0
   End
   Else Pulse:=0
End;

Function Clip(p,q,r,s:RR):RR; far;
Begin
  If r>=s Then Clip:=p
  Else Clip :=q
End;

Function Switch(p,q,r:RR):RR; far;
Begin
  If r=0.0 Then Switch:=p
  Else Switch:=q
End;

Function TabFkt(x:RR;Var Tab:XtbfFeld):RR; far;
Var zgr:Integer;
    m:RR;
Begin
(*  { Erst mal die Tabelle ordnen, man weiß ja nie }
  { zumindestens überprüfen --  fehlt hier noch -  ergänzen !!!!!!!! }
  zgr:=0;
  While (x>=PWPaar(Tab^.at(zgr))^.x) and (zgr<Tab^.Count-1) do inc(Zgr);
  { Außerhalb der Grenzen wird der Randwert genommen:}
  If Zgr=0 Then TabFkt:=PWPaar(Tab^.at(0))^.y
  Else if x>PWPaar(Tab^.at(Tab^.Count-1))^.x Then TabFkt:=PWPaar(Tab^.at(Tab^.Count-1))^.y
  { Jetzt linear interpolieren! }
  Else Begin
    m:=(PWPaar(Tab^.at(zgr-1))^.y-PWPaar(Tab^.at(zgr))^.y)/
                       (PWPaar(Tab^.at(zgr-1))^.x-PWPaar(Tab^.at(zgr))^.x);
    TabFkt:=PWPaar(Tab^.at(zgr-1))^.y + m*(x-PWPaar(Tab^.at(zgr-1))^.x)
End;    *)
End;

Function Wenn(a,b,c,d:RR;bed:Relation):RR;  far;
Begin
  Case Bed of
    gl     : If a=b  Then wenn:=c else wenn:=d;
    gr     : If a>b Then wenn:=c else wenn:=d;
    kl     : If a<b Then wenn:=c else wenn:=d;
    grgl   : If a>=b Then wenn:=c else wenn:=d;
    klgl   : If a<=b Then wenn:=c else wenn:=d;
    ungl   : if a<>b Then wenn:=c else wenn:=d
    Else  Begin parse.ArithmeticError := 3; Wenn:=Schrott End;
  End
End;

Function AlterWert(init,delay,time,dt: RR; Var Tab:TList):RR; far;
Var index : Integer;
Begin
  if delay<dt Then Begin parse.ArithmeticError := 4; AlterWert:=Schrott;Exit End;
  if time<delay Then AlterWert:=Init
  Else Begin
    index:=Round((time-delay)/dt);
    AlterWert:= TRR(Tab.items[Index]).Eintrag
  End;
End;

{ -------------------------------------------------------------------------------------}

PROCEDURE LehreKonstanten;
BEGIN
  Parse.LerneVariable('PI', 3.14159265358979328);
  Parse.LerneVariable('E', exp(1.0));
END {LehreKonstanten};

PROCEDURE LehreFunktionen;
BEGIN
  Parse.LerneFunktion('SIN', unsersin);
  Parse.LerneFunktion('COS', unsercos);
  Parse.LerneFunktion('TAN', UnserTan);
  Parse.LerneFunktion('ARCTAN',unserarctan);

  Parse.LerneFunktion('SINH', Sh);
  Parse.LerneFunktion('COSH', Ch);
  Parse.LerneFunktion('TANH', Th);

  Parse.LerneFunktion('LN', UnserLn);
  Parse.LerneFunktion('EXP', Unserexp);
  Parse.LerneFunktion('SQR', Sqr);
  Parse.LerneFunktion('QUADRAT', Sqr);
  Parse.LerneFunktion('SQRT', UnserSqrt);
  Parse.LerneFunktion('WURZEL', UnserSqrt);
  Parse.LerneFunktion('ABS', Abs);
  Parse.LerneFunktion('SIGN', Sign);
  Parse.LerneFunktion('NOISE',Noise);
  Parse.LerneFunktion('ZUFALL',Noise);
  Parse.LerneFunktion('INT',UnserInt);

  Parse.LerneFunktion2('MAX',Max);
  Parse.LerneFunktion2('MIN',Min);
  Parse.LerneFunktion2('RAMP',Ramp);
  Parse.LerneFunktion2('RAMPE',Ramp);

  Parse.LerneFunktion2('MOD',Modulo);
  Parse.LerneFunktion2('DIV',Divisor);

  Parse.LerneFunktion3('PULSE',Pulse);
  Parse.LerneFunktion3('IMPULS',Pulse);

  Parse.LerneFunktion3('SWITCH',Switch);
  Parse.LerneFunktion3('FIFZE',Switch);

  Parse.LerneFunktion4('CLIP',Clip);
  Parse.LerneFunktion4('FIFGE',Clip);

  Parse.LerneWenn('WENN',Wenn);
  Parse.LerneWenn('IF',Wenn);

  Parse.LerneFunktionXtbf('XTBF',TabFkt);
  Parse.LerneFunktionXtbf('TABELLE',TabFkt);

  Parse.LerneFunktionDelay('ALTERWERT',AlterWert);

END{ LehreFunktionen};


PROCEDURE LehreMathe;
BEGIN
  LehreFunktionen;
  LehreKonstanten;
END {LehreMathe};


BEGIN
  Randomize
END.
