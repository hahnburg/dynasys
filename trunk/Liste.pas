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

unit Liste;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, 
  SimObjekt, Dialogs;

type
   tObjektListe = class (TList)
    private
      function GetSimuObjekt(index:integer):TSimuObjekt;
      procedure Vertausche(i,j:integer);
    public
      procedure ZeichneAlles;
      function  ObjektUnterMaus(x,y:integer;Var obj:TSimuObjekt):Boolean;
      procedure LoescheAlleMarkierungen;
      function  VerschiebeObjekte(dx,dy:integer):boolean;
      procedure WaehleObjekteInRechteck(Rect:TRect);
      function  HohleAuswahlRechteck:TRect;
      procedure LoescheMarkierteObjekte;
      procedure LoescheAlles;
      procedure AllesAuswaehlen;
      function  NameVorhanden(ObjName:string):Boolean;
      function  ModellGueltig:integer;
      function  SortiereListe:Boolean;
      procedure Speichern(W:TWriter);
      procedure Lesen(R:TReader);


      property items[index:integer]:TSimuObjekt read GetSimuObjekt;
   end;

var  ObjektListe       : TObjektListe;

implementation


{ ----------------------------------------------------------- }
function tObjektListe.GetSimuObjekt(index:integer):TSimuObjekt;
begin
  result:= TSimuObjekt(TList(self).items[index])
end;

procedure tObjektListe.ZeichneAlles;
var i : integer;
begin

   for i:=0 to count-1 do
    with items[i] do begin
      if key<>-1 then begin
        Zeichne;
        if selected then ZeichneMarkierung;
      End;
    end;
  for i:=0 to count-1 do
    with items[i] do begin
      if key=-1 then begin
        Zeichne;
        if selected then ZeichneMarkierung;
      End;
    end;
End;

function tObjektListe.ObjektUnterMaus(x,y:integer;
                              Var obj:TSimuObjekt):boolean;
var ObjektVorhanden : boolean;
    pv              : boolean;
    i               : integer;
begin
  ObjektVorhanden:=false;
  For i:=0 to Count-1 do begin
    with items[i] do pv:=IstObjekt(x,y);
    ObjektVorhanden:=ObjektVorhanden or pv;
    if pv then  obj:=items[i];
  end;
  Result:=ObjektVorhanden;
end;

procedure tObjektListe.LoescheAlleMarkierungen;
var i : integer;
begin
  for i:=0 to count-1 do
    if items[i].selected then begin
      items[i].selected:=false;
      items[i].ZeichneMarkierung;
    end;
end;

function tObjektListe.VerschiebeObjekte(dx,dy:integer):boolean;
var i : integer;
    repaint : boolean;
begin
  for i:=0 to count-1 do
    with items[i]do
      if selected  then
        begin
          Verschiebe(dx,dy);
          repaint:=true;
        end;
  result:=repaint;
end;

procedure tObjektListe.WaehleObjekteInRechteck(Rect:TRect);
var i : integer;
begin
  for i:=0 to count-1 do
    with items[i] do
      if PtInRect(Rect,Mitte) and (key>0) then begin
        if not selected then ZeichneMarkierung;
        selected:=true;
      end;
end;

function tObjektListe.HohleAuswahlRechteck:TRect;
var i    : integer;
    R :TRect;
begin
  R:=Rect(30000,30000,-30000,-30000);
  for i:=0 to count-1 do
    with items[i] do
      if selected then begin
        IF Mitte.x<R.left then R.left:=Mitte.x;
        If Mitte.y<R.top then R.top:=Mitte.y;
        If Mitte.x>R.right then R.right:=Mitte.x;
        If Mitte.y>R.bottom then R.bottom:=Mitte.y;
      end;
  R.left:=R.left-17;
  R.right:=R.right+17;
  R.top:=R.top-14;
  R.bottom:=R.bottom+14;
  Result:=R;
end;

procedure tObjektListe.LoescheMarkierteObjekte;
var i : integer;
begin
  For i:=0 to count-1 do
    with items[i] do
      if selected and not geloescht then begin
        ZeichneMarkierung;
        Loesche;
      end;
  i:=count-1;
  { Liste packen }
  while i>=0 do
    with items[i]do begin
      if geloescht then begin
        Free;
        Delete(i)
      end;
      dec(i);
    end;
end;

procedure tObjektListe.LoescheAlles;
var i : integer;
begin
  i:=count-1;
  { Liste packen }
  while i>=0 do
    with items[i]do begin
        Free;
        Delete(i);
        dec(i);
    end;
end;

procedure tObjektListe.AllesAuswaehlen;
var i : integer;
begin
  for i:=0 to count-1 do
    with items[i] do
      if (not selected) and (key>0) then begin
        ZeichneMarkierung;
        selected:=true;
      end;
end;


Function tObjektListe.NameVorhanden(ObjName:String):Boolean;
Var i:Integer;
    vorhanden:Boolean;
Begin
  vorhanden:=false;
  for i:=0 to Count-1 Do
    vorhanden:=vorhanden or (CompareText(ObjName,items[i].Name)=0); 
  Result:=Vorhanden;
End;

procedure tObjektListe.Speichern(W:TWriter);
var i : integer;
begin
  W.WriteInteger(count);
  for i:=0 to count-1 do
    with items[i] do begin
      W.WriteString(ClassName);
      Store(W);
    end;
End;

procedure tObjektListe.Lesen(R:TReader);
var i : integer;
    Anzahl : LongInt;
    ClassName:String;
    ClassRef:TClass;
    Objekt : TObject;
begin
  Anzahl:=R.ReadInteger;
  for i:=1 to Anzahl do begin
    ClassName:=R.ReadString;
    ClassRef:=FindClass(ClassName);
    Objekt:=ClassRef.Create;
    TSimuObjekt(Objekt).Load(R);
    add(Objekt);
  end;
  for i:=0 to Count-1 do items[i].ErzeugeZeiger;
  for i:=0 to Count-1 do items[i].Zeichne;
end;

Function tObjektListe.ModellGueltig:integer;
Var i  : Integer;
Begin
  if count=0 then begin result:=0; exit end; 
  i:=-1;
  repeat
     Inc(i);
  until (i=count-1) or (not items[i].gueltig);
  if i=count-1 then result:=-1 else result:=i
End;

Procedure tObjektListe.Vertausche (i,j:integer);
VAR P1,P2:TSimuObjekt;
Begin
 P1:=items[i];
 P2:=items[j];
 If i<j Then
   Begin
     Delete(j);
     Delete(i);
     Insert(i,P2);
     Insert(j,P1);
   End
 Else
   Begin
     Delete(i);
     Delete(j);
     Insert(j,P1);
     Insert(i,P2);
   End

End;
Function tObjektListe.SortiereListe:Boolean;
Var unfertig,zyklus : Boolean;
    index,i,x,vergleich,Zaehler,Maximum:integer;
    p:TSimuObjekt;
Begin
 unfertig:=True;
 zyklus:=False;
 index:=0;
 Zaehler:=0;
   {Konstanten kommen ganz nach vorne}
   {Bubble-Sort}
 For x:=Count-2 downto 1 Do
     For i:=0 to x Do
       If items[i].key>items[i+1].key Then Vertausche(i,i+1);
   Index:=0;
   While (index<=ObjektListe.Count-1) and not zyklus do Begin
        p:=TSimuObjekt(items[index]);
        If (p.key=4) or (p.Key=6) Then Begin
        (*  WriteLn(p^.Name,index:5);  *)
          Maximum:=index;
          For x:=1 to p.EingangMax do Begin
            Vergleich:=IndexOf(TWirkPfeilObjekt(p.Eingaenge[x].zgr).von);
        (*    WriteLn('    ',PWirkPfeilObjekt(p^.Eingaenge[x].zgr)^.von^.name,Vergleich:5);  *)
            If (Vergleich>Maximum) and (items[vergleich].key<8)
                   Then Maximum:=Vergleich;
          End;
          If Maximum>Index Then Begin
         (*     WriteLN(' ---->> Vertausche ',Index:5,' mit ' ,Maximum:5); *)
              Vertausche(index,Maximum);
              Index:=-1;Inc(Zaehler);
          End;
        End;
        Inc(Index);
        zyklus:=Zaehler>500;
   End;
  SortiereListe:=Not zyklus;
End;

end.
