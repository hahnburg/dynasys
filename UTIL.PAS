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

unit Util;

interface

uses SysUtils, Classes;

type
   TPunkt = class(TObject)
    x,y : real;
    procedure init(x,y:double);
  end;


function NameKorrekt(Name:String):Boolean;
function ErsetzeNamen(obj:TObject;NameAlt,NameNeu:String):Boolean;
procedure StrGross(var Str:String);
(*Function MakeRound(Z:double):double;*)


implementation

uses Simobjekt;

procedure TPunkt.init(x,y:double);
begin
  self.x:=x;
  self.y:=y;
end;

procedure StrGross(var Str:String);
Begin
  While Pos('ä',Str)>0 do Str[Pos('ä',Str)]:='Ä';
  While Pos('ö',Str)>0 do Str[Pos('ö',Str)]:='Ö';
  While Pos('ü',Str)>0 do Str[Pos('ü',Str)]:='Ü';
  Str:=UpperCase(Str);
End;


function NameKorrekt(Name:String):Boolean;
 var korrekt:Boolean;
     i:Integer;
 Begin
   If (Length(Name)<1) then begin Namekorrekt:=false; Exit end;
   If not (Name[1] in ['a'..'z','ä','ü','ö','ß','A'..'Z','Ä','Ü','Ö']) then
     Begin NameKorrekt:=False; Exit End;
   Korrekt:=true;
   For i:=1 to Length(Name) Do
      korrekt:=Korrekt and
        ( Name[i] in ['a'..'z','ä','ü','ö','ß','A'..'Z','Ä','Ü','Ö','_','0'..'9']);
   Namekorrekt:=korrekt;
 End;


Function ErsetzeNamen(obj:TObject;NameAlt,NameNeu:String):Boolean;
 Var  alt,Bez : String;
      position : Word;
      Stelle:Integer;
  Begin
    result:=false;
    with obj as TSimuObjekt do
    if Pos(NameAlt,Eingabe) >0 Then Begin
      alt:=Eingabe;
      Bez:=NameAlt;
      Stelle:=Pos(Bez,Alt);
      If Stelle=0 Then Begin Result:=False; exit End;
      Delete(Alt,Stelle,Length(Bez));
      if Pos(Bez,Alt) > 0 Then Begin Result:=False; exit End;
      Bez:=NameNeu;
      Insert(Bez,Alt,Stelle);
      Eingabe:=alt;
      result:=true;
    End
  End;

Function MakeRound(Z:double):double;
  Var Stellen,i:integer;
      fak:double;
  Begin
     fak:=1;
     If Z=0 Then Begin MakeRound:=0; Exit End;
     if Abs(z*100000000)<1 Then Begin MakeRound:=Z; Exit End;
     If z<0 Then Begin z:=Abs(z);fak:=-1*fak;End;
     If z<1 Then Begin Z:=Z*100000000; fak:=1/100000000*fak End;
     Stellen:=Trunc(ln(Z)/ln(10.0));
     For i:=2 to Stellen do Z:=Z/10;
     If Z>10
       Then Z:=Round(Z/4)*4
       Else   z:=Round(10*z/4)*0.4;;
     For I:=2 to Stellen do Z:=Z*10;
     MakeRound:=Z*fak;
  End;


 end.
