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

unit Funktion;

{$MODE Delphi}

(*
   Diverse Funktionen für den Parser
   Autor: Walter Hupfeld
   Version: 2.0
   zuletzt bearbeitet:

*)
{ $V-,I-,B-,N+,E+,D-}

interface
const

    e=2.718281828459045235360;
    ln10 = 2.3025851;

type
    Reelle_Funktion = Function(x:Double):Double;

function Min(a,b:Double):Double;
function Max(a,b:Double):Double;
function Maxb(a,b:integer):integer;

function log(x:Double):Double;
function lne(x:Double):Double;
function log10(x:Double):Double;

function xy(x,y:Double):Double;
function xyi(x:Double;i:Integer):Double;

function intelligentes_Aufrunden(x : Double) : Double;
function intelligentes_Aufrunden2(x : Double) : Double;
function intelligentes_Abrunden(x : Double) : Double;
function intelligentes_Abrunden2(x : Double) : Double;
function Aufrunden_125(x : Double) : Double;



implementation

function Min(a,b:Double):Double;
begin if a<b then Min:=a
             else Min:=b
end;

function Max(a,b:Double):Double;
Begin If a>b then Max:=a
             else Max:=b
End;

Function Maxb(a,b:integer):integer;
Begin If a>b then Maxb:=a
             else Maxb:=b
End;

Function log(x:Double):Double;
Begin If x<>0 then log:=ln(abs(x))/ln10
  else log:=-1E300
End;

Function lne(x:Double):Double;
Begin
  x:=abs(x);
  If x>1e-100
    then lne:=ln(x)
    else lne:=-1E300
End;

Function log10(x:Double):Double;
Begin If x<>0 then log10:=ln(abs(x))/ln10
			  else log10:=-1E300
End;




Function xy(x,y:Double):Double;
Begin xy:=exp(y*ln(abs(x))) End;

Function xyi(x:Double;i:Integer):Double;
Var Hilf : Double;
	j : Integer;
Begin
	Hilf:=1;
	For j:=1 to i
		Do Hilf:=Hilf*x;
	xyi:=Hilf
End;


Function intelligentes_Aufrunden(x : Double) : Double;
{ Runden auf eine gültige Stelle, z.B. 2210 => 3000 }
Var i : Integer;
	 negativ : Boolean;
Begin
  If x=0 then intelligentes_Aufrunden:=0
	else Begin
	i:=0;
	negativ:=x<0;
	x:=abs(x);
	If (x>=10)
		then Begin
                  Repeat
                    x:=x/10;
                    inc(i)
                    Until (x<10);
                    If negativ
                      then intelligentes_Aufrunden:=-round(x+0.49999)*xy(10,i)
                      else intelligentes_Aufrunden:=round(x+0.49999)*xy(10,i);
                    Exit;
                  End;
	If (x<1)
		then Begin
                  Repeat
                    x:=x*10;
                    inc(i)
                  Until (x>1);
                  If negativ
                    then intelligentes_Aufrunden:=-round(x+0.49999)/xy(10,i)
                    else intelligentes_Aufrunden:=round(x+0.49999)/xy(10,i);
                  Exit
                End;
	 If (x>=1) and (x<10)
		then If negativ
                  then intelligentes_Aufrunden:=-round(x+0.49999)
                  else intelligentes_Aufrunden:=round(x+0.49999);
	 End
End;



Function intelligentes_Abrunden(x : Double) : Double;
{ Runden auf eine gültige Stelle, z.B. 2210 => 2000 }
Var i : Integer;
	 negativ : Boolean;
Begin
  If x=0 then intelligentes_Abrunden:=0
  else Begin
    i:=0;
    negativ:=x<0;
    x:=abs(x);
    If (x>=10) then Begin
      Repeat
        x:=x/10;
        inc(i)
      Until (x<10);
      If negativ
        then intelligentes_Abrunden:=-round(x-0.5001)*xy(10,i)
        else intelligentes_Abrunden:=round(x-0.5001)*xy(10,i);
        Exit;
      End;
      If (x<1) then Begin
        Repeat
          x:=x*10;
          inc(i)
        Until (x>1);
        If negativ
          then intelligentes_Abrunden:=-round(x-0.5001)/xy(10,i)
          else intelligentes_Abrunden:=round(x-0.5001)/xy(10,i);
          Exit
      End;
      If (x>=1) and (x<10)
        then If negativ
          then intelligentes_Abrunden:=-round(x-0.5001)
          else intelligentes_Abrunden:=round(x-0.5001);
    End
End;

Function intelligentes_Aufrunden2(x : Double) : Double;
{ Runden auf zwei gültige Stellen, z.B. 2210 => 2300 }
Var i : Integer;
	negativ : Boolean;
Begin
  If x=0 then intelligentes_Aufrunden2:=0
  else Begin
    i:=0;
    negativ:=x<0;
    x:=abs(x);
    If (x>=100) then Begin
      Repeat
        x:=x/10;
        inc(i)
      Until (x<100);
      If negativ
        then intelligentes_Aufrunden2:=-round(x+0.49999)*xy(10,i)
        else intelligentes_Aufrunden2:=round(x+0.49999)*xy(10,i);
      Exit;
    End;
    If (x<1) then Begin
      Repeat
        x:=x*10;
        inc(i)
      Until (x>10);
      If negativ
        then intelligentes_Aufrunden2:=-round(x+0.49999)/xy(10,i)
        else intelligentes_Aufrunden2:=round(x+0.49999)/xy(10,i);
      Exit
    End;
    If (x>=1) and (x<100)
      then If negativ
        then intelligentes_Aufrunden2:=-round(x+0.49999)
        else intelligentes_Aufrunden2:=round(x+0.49999);
  End
End;

Function intelligentes_Abrunden2(x : Double) : Double;
{ Runden auf zwei gültige Stellen, z.B. 2210 => 2200 }
Var i : Integer;
	negativ : Boolean;
Begin
  If x=0 then intelligentes_Abrunden2:=0
  else Begin
    i:=0;
    negativ:=x<0;
    x:=abs(x);
    If (x>=100) then Begin
      Repeat
        x:=x/10;
        inc(i)
      Until (x<100);
    If negativ
      then intelligentes_Abrunden2:=-round(x-0.49999)*xy(10,i)
      else intelligentes_Abrunden2:=round(x-0.49999)*xy(10,i);
    Exit;
  End;
  If (x<1) then Begin
    Repeat
      x:=x*10;
      inc(i)
    Until (x>10);
    If negativ
      then intelligentes_Abrunden2:=-round(x-0.49999)/xy(10,i)
      else intelligentes_Abrunden2:=round(x-0.49999)/xy(10,i);
    Exit
  End;
  If (x>=1) and (x<100)
    then If negativ
      then intelligentes_Abrunden2:=-round(x-0.49999)
      else intelligentes_Abrunden2:=round(x-0.49999);
  End
End;

Function Aufrunden_125(x : Double) : Double;
Var i : Integer;
	 negativ : Boolean;
//	 y : Double;

Function Runden(x : Double) : Double;
Begin
	If x<=1
		then Runden:=1;
	If (x>1) and (x<=2)
		then Runden:=2;
	If (x>2) and (x<=5)
		then Runden:=5;
	If x>5
		then Runden:=10
End;

Begin
	negativ:=x<0;
	x:=abs(x);
	i:=0;
	If (x>=10)
		then Begin
				Repeat
				x:=x/10;
				inc(i)
				Until (x<10);
				If negativ
				then Aufrunden_125:=-Runden(x)*xy(10,i)
				else Aufrunden_125:=Runden(x)*xy(10,i);
				Exit;
			 End;
	If (x<1)
		then Begin
				Repeat
				x:=x*10;
				inc(i)
				Until (x>1);
				If negativ
				then Aufrunden_125:=-Runden(x)*xy(10,-i)
				else Aufrunden_125:=Runden(x)*xy(10,-i);
				Exit
			 End;
	 If (x>=1) and (x<10)
		then If negativ
				then Aufrunden_125:=-Runden(x)
				else  Aufrunden_125:=Runden(x);
End;



END.
