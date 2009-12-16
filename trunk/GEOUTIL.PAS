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

unit GeoUtil;

interface

uses SysUtils, WinTypes, WinProcs,  Classes, Graphics, Dialogs,
     SimObjekt;

procedure ZeichneWolke(x,y:Integer;art:LongInt);
function  BestimmeKreispunkt(M,P:TPoint):TPoint;
procedure ZeichnePfeil(P:TPunktFeld);
procedure BerechnePfeilspitze(Var Pfeil: Array of TPoint;
                                  pax,pay,pex,pey:integer);
procedure ZeichneVentil(x,y:Integer);
procedure ZeichneFlussWolkeZustand(Zufluss,Abfluss:TRect;M:TPoint);
procedure ZeichneFlussZustandWolke(Zufluss,Abfluss:TRect;M:TPoint);
procedure ZeichneFlussZustandZustand(Zufluss,Abfluss:TRect;M:TPoint);

implementation

uses ModEditor;

procedure ZeichneWolke(x,y:Integer;art:LongInt);
const r=9;
      s=1;
begin
  with  ModellEditor.Modell.Canvas do begin
    Arc(x+r-s,y-r+s,x-s,y+s, x,y,x,y);
    Arc(x-r+s,y-r+s,x+s,y+s, x,y,x,y);
    Arc(x-r+s,y+r-s,x+s,y-s, x,y,x,y);
    Arc(x+r-s,y+r-s,x-s,y-s, x,y,x,y);
  end;
end;

procedure ZeichneVentil(x,y:Integer);
const b=11;h=16;a=5;
begin
  with ModellEditor.Modell.Canvas do begin
    MoveTo(x,y+a);LineTo(x,y-a);
    MoveTo(x-3,y-a);LineTo(x+3,y-a);
    Arc(x-b,y-b+h,x+b,y+b+h,x-b,y-b+h,x-b,y-b+h);
  end;
end;

procedure Markiere(x,y:Integer);
Begin
  ModellEditor.Modell.Canvas.Rectangle(x-3,y+3,x+3,y-3);
End;

procedure PfeilRechts(x,y:integer);
Var  Pts:Array [1..4] of tPoint;
Begin
  Pts[1].x:=x;   Pts[1].y:=y;
  Pts[2].x:=x-7; Pts[2].y:=y+6;
  Pts[3].x:=x-7; Pts[3].y:=y-6;
  Pts[4].x:=x;   Pts[4].y:=y;
  ModellEditor.Modell.Canvas.PolyLine(pts);
End;

Procedure PfeilLinks(x,y:integer);
Var  Pts:Array [1..4] of tPoint;
Begin
  Pts[1].x:=x;   Pts[1].y:=y;
  Pts[2].x:=x+7; Pts[2].y:=y+6;
  Pts[3].x:=x+7; Pts[3].y:=y-6;
  Pts[4].x:=x;   Pts[4].y:=y;
  ModellEditor.Modell.Canvas.PolyLine(pts);
End;

Procedure PfeilUnten(x,y:integer);
Var  Pts:Array [1..4] of tPoint;
Begin
  Pts[1].x:=x;   Pts[1].y:=y;
  Pts[2].x:=x+7; Pts[2].y:=y-6;
  Pts[3].x:=x-7; Pts[3].y:=y-6;
  Pts[4].x:=x;   Pts[4].y:=y;
  ModellEditor.Modell.Canvas.PolyLine(pts);
End;

Procedure PfeilOben(x,y:integer);
Var  Pts:Array [1..4] of tPoint;
Begin
  Pts[1].x:=x;   Pts[1].y:=y;
  Pts[2].x:=x+7; Pts[2].y:=y+6;
  Pts[3].x:=x-7; Pts[3].y:=y+6;
  Pts[4].x:=x;   Pts[4].y:=y;
  ModellEditor.Modell.Canvas.PolyLine(pts);
End;


function BestimmeKreispunkt(M,P:TPoint):TPoint;
const radius = 12;
var alpha:double;
begin
  if M.x<>P.x then
       alpha:=arctan((P.y-M.y)/(P.x-M.x))
  else begin
    if P.y<M.y then alpha:=-90/180*pi
    else alpha:=90/180*pi
  end;
  if M.x<=P.x then
      BestimmeKreispunkt:=
       Point(M.x+Round(radius*cos(alpha)),M.y+round(radius*sin(alpha)))
  else BestimmeKreispunkt:=
       Point(M.x-Round(radius*cos(alpha)),M.y-round(radius*sin(alpha)));
end;


procedure BerechnePfeilspitze(Var Pfeil: Array of TPoint;
                              pax,pay,pex,pey:integer);
const PWinkel=0.8;
      Pfeillaenge=6;
 var alpha : double;
begin
     if pex<>pax then
   alpha:=arctan((pey-pay)/(pex-pax))
 else
   alpha:=90/180*pi;
 if (pex>pax) or  ((pex=pax) and (pey>pay)) Then Begin
   Pfeil[0].x:=pex;Pfeil[0].y:=pey;
   Pfeil[1].x:=pex-Round(cos(alpha+PWinkel)*Pfeillaenge);
   Pfeil[1].y:=pey-Round(sin(alpha+PWinkel)*Pfeillaenge);
   Pfeil[2].x:=pex-Round(cos(alpha-PWinkel)*Pfeillaenge);
   Pfeil[2].y:=pey-Round(sin(alpha-PWinkel)*Pfeillaenge);
   Pfeil[3]:=Pfeil[0];
 end else begin
   Pfeil[0].x:=pex;Pfeil[0].y:=pey;
   Pfeil[1].x:=pex+Round(cos(alpha+PWinkel)*Pfeillaenge);
   Pfeil[1].y:=pey+Round(sin(alpha+PWinkel)*Pfeillaenge);
   Pfeil[2].x:=pex+Round(cos(alpha-PWinkel)*Pfeillaenge);
   Pfeil[2].y:=pey+Round(sin(alpha-PWinkel)*Pfeillaenge);
   Pfeil[3]:=Pfeil[0];
 end;
end;



procedure ZeichnePfeil(P:TPunktFeld);
 const PWinkel=0.8;
       Pfeillaenge=6;
 var i     : integer;
     Pfeil : array[0..3] of TPoint;

begin { ZeichnePfeil }
  if (P[Anfang].x=P[Ende].x) and
                  (P[Anfang].y=P[Ende].y) Then Exit;
  with ModellEditor.Modell do begin
  //  Canvas.Pen.Mode := pmNotXor;
    Canvas.Pen.Color := clBlue;
    Canvas.MoveTo(P[Anfang].x,P[Anfang].y);
    Canvas.LineTo(P[Ende].x,P[Ende].y);
    BerechnePfeilSpitze(Pfeil,P[Anfang].x,P[Anfang].y,
                                    P[Ende].x,P[Ende].y);
    Canvas.PolyLine(Pfeil);
 //   ZeichnePfeilAnfang(P[Anfang]);
    end;
end;


procedure ZeichneFlussWolkeZustand(Zufluss,Abfluss:TRect;M:TPoint);
var ex,ax,ey,ay,mx,my : integer;
begin
with ModellEditor.Modell.Canvas do begin
  ey:=(Zufluss.top +Zufluss.bottom) div 2;
  ay:=(Abfluss.top +Abfluss.bottom) div 2;
  ex:=(Zufluss.left +Zufluss.right) div 2;
  ax:=(Abfluss.left +Abfluss.right) div 2;
  if (ex=ax) and (ey=ay) then exit;
  mx:=M.x;my:=ey;
    {Ventil links}
    If mx<(Abfluss.left + Abfluss.right) div 2 Then Begin
      {Wolke und Zustand gerade verbinden }
      If (my<Abfluss.bottom) and (my>Abfluss.top) Then Begin
         ex:=Zufluss.right;
         ax:=Abfluss.left;
         PfeilRechts(ax,my);
         MoveTo(ex,my-2);
         Lineto(ax-7,my-2);
         MoveTo(ex,my+2);
         Lineto(ax-7,my+2);
      End
      Else {Wolke und Zustand auf unterschiedlischer Höhe}
      Begin
         ex:=Zufluss.right;
         ax:=Abfluss.left+7;
         if my<Abfluss.top Then
           Begin  { Wolke unter dem Zustand }
             ay:=Abfluss.top;
             MoveTo(ex,my-2);
             Lineto(ax+2,my-2);
             LineTo(ax+2,ay-6);
             MoveTo(ex,my+2);
             Lineto(ax-2,my+2);
             LineTo(ax-2,ay-6);
             PfeilUnten(ax,ay)
           End
         Else
           Begin  { Wolke über dem Zustand }
             ay:=Abfluss.bottom;
             MoveTo(ex,my-2);
             Lineto(ax-2,my-2);
             LineTo(ax-2,ay+6);
             MoveTo(ex,my+2);
             Lineto(ax+2,my+2);
             LineTo(ax+2,ay+6);
             PfeilOben(ax,ay)
           End;

      End;
    End
    {1. Fall Wolke --> Zustand   Ventil rechts }
    Else {if mx>Abfluss.right Then} Begin
      {Wolke und Zustand gerade verbinden }
      If (my<Abfluss.bottom) and (my>Abfluss.top) Then Begin
         ex:=Zufluss.left;
         ax:=Abfluss.right;
         PfeilLinks(ax,my);
         MoveTo(ex,my-2);
         Lineto(ax+6,my-2);
         MoveTo(ex,my+2);
         Lineto(ax+6,my+2);
      End
      Else {Wolke und Zustand auf unterschiedlischer Höhe}
      Begin
         ex:=Zufluss.left;
         ax:=Abfluss.right-7;
         if my<Abfluss.top Then
           Begin  { Wolke unter dem Zustand }
             ay:=Abfluss.top;
             MoveTo(ex,my-2);
             Lineto(ax-2,my-2);
             LineTo(ax-2,ay-6);
             MoveTo(ex,my+2);
             Lineto(ax+2,my+2);
             LineTo(ax+2,ay-6);
             PfeilUnten(ax,ay)
           End
         Else
           Begin  { Wolke über dem Zustand }
             ay:=Abfluss.bottom;
             MoveTo(ex,my-2);
             Lineto(ax+2,my-2);
             LineTo(ax+2,ay+6);
             MoveTo(ex,my+2);
             Lineto(ax-2,my+2);
             LineTo(ax-2,ay+6);
             PfeilOben(ax,ay)
           End;
         end;
      End;
    End;
end;


Procedure ZeichneFlussZustandWolke(Zufluss,Abfluss:TRect;M:TPoint);
var ex,ax,ey,ay,mx,my : integer;
Begin
with ModellEditor.Modell.Canvas do begin
   ay:=(Zufluss.top +Zufluss.bottom) div 2;
   ey:=(Abfluss.top +Abfluss.bottom) div 2;
   ax:=(Zufluss.left +Zufluss.right) div 2;
   ex:=(Abfluss.left +Abfluss.right) div 2;
   if (ex=ax) and (ey=ay) then exit;
   mx:=M.x;my:=M.y;
   If mx<(Zufluss.left + Zufluss.left) div 2 Then Begin
    {Ventil links}
      {Wolke und Zustand gerade verbinden }
      If (my<Zufluss.bottom) and (my>Zufluss.top) Then Begin
         ex:=Zufluss.left;
         ax:=Abfluss.right;
         PfeilLinks(ax,my);
         MoveTo(ex,my-2);
         Lineto(ax+7,my-2);
         MoveTo(ex,my+2);
         Lineto(ax+7,my+2);
      End
      Else {Wolke und Zustand auf unterschiedlischer Höhe}
      Begin
         ax:=Abfluss.right;
         ex:=Zufluss.left+7;
         if my<Zufluss.top Then
           Begin  { Wolke unter dem Zustand }
             ey:=Zufluss.top;
             MoveTo(ex+2,ey);
             Lineto(ex+2,my-2);
             LineTo(ax+6,my-2);
             MoveTo(ex-2,ey);
             Lineto(ex-2,my+2);
             LineTo(ax+6,my+2);
             PfeilLinks(ax,my)
           End
         Else
           Begin  { Wolke über dem Zustand }
             ey:=Zufluss.bottom;
             MoveTo(ex+2,ey);
             Lineto(ex+2,my+2);
             LineTo(ax+6,my+2);
             MoveTo(ex-2,ey);
             Lineto(ex-2,my-2);
             LineTo(ax+6,my-2);
             PfeilLinks(ax,my)
           End;

      End;
    End
    {2. Fall Zustand --> Wolke   Ventil rechts }
    Else   { If mx>Zufluss.Right Then} Begin
      {Wolke und Zustand gerade verbinden }
      If (my<Zufluss.bottom) and (my>Zufluss.top) Then Begin
         ex:=Zufluss.right;
         ax:=Abfluss.left;
         PfeilRechts(ax,my);
         MoveTo(ex,my-2);
         Lineto(ax-7,my-2);
         MoveTo(ex,my+2);
         Lineto(ax-7,my+2);
      End
      Else {Wolke und Zustand auf unterschiedlischer Höhe}
      Begin
         ax:=Abfluss.left;
         ex:=Zufluss.right-7;
         if my<Zufluss.top Then
           Begin  { Wolke unter dem Zustand }
             ey:=Zufluss.top;
             MoveTo(ex+2,ey);
             Lineto(ex+2,my+2);
             LineTo(ax-6,my+2);
             MoveTo(ex-2,ey);
             Lineto(ex-2,my-2);
             LineTo(ax-6,my-2);
             PfeilRechts(ax,my)
           End
         Else
           Begin  { Wolke über dem Zustand }
             ey:=Zufluss.bottom;
             MoveTo(ex+2,ey);
             Lineto(ex+2,my-2);
             LineTo(ax-6,my-2);
             MoveTo(ex-2,ey);
             Lineto(ex-2,my+2);
             LineTo(ax-6,my+2);
             PfeilRechts(ax,my)
           End;
        end;
      End;
   End;
end;

procedure ZeichneFlussZustandZustand(Zufluss,Abfluss:TRect;M:TPoint);
var ex,ax,ey,ay,mx,my : integer;
Begin
with ModellEditor.Modell.Canvas do begin
   ey:=(Zufluss.top +Zufluss.bottom) div 2;
   ay:=(Abfluss.top +Abfluss.bottom) div 2;
   ex:=(Zufluss.left +Zufluss.right) div 2;
   ax:=(Abfluss.left +Abfluss.right) div 2;
   mx:=M.x;
   my:=M.y;
   if (ex=ax) and (ey=ay) then exit;
       Begin
       { links nach rechts }
       If mx > (Zufluss.left + Zufluss.right) div 2 Then Begin
       { Zustand bis Ventil }
         IF (my>=Zufluss.top) and (my<=Zufluss.bottom) Then
           Begin
             ax:=Zufluss.right;
             MoveTo(ax,my+2);
             Lineto(mx,my+2);
             MoveTo(ax,my-2);
             Lineto(mx,my-2);
           End
         Else if my<Zufluss.top Then
           Begin
             ax:=Zufluss.right-7;
             ay:=Zufluss.top;
             MoveTo(ax-2,ay);
             Lineto(ax-2,my-2);
             LineTo(mx,my-2);
             MoveTo(ax+2,ay);
             Lineto(ax+2,my+2);
             LineTo(mx,my+2);
           End
         Else
           Begin
             ax:=Zufluss.right-7;
             ay:=Zufluss.bottom;
             MoveTo(ax-2,ay);
             Lineto(ax-2,my+2);
             LineTo(mx,my+2);
             MoveTo(ax+2,ay);
             Lineto(ax+2,my-2);
             LineTo(mx,my-2);
           End;
        { Ventil bis Zustand }
         IF (my>=Abfluss.top) and (my<=Abfluss.bottom) Then
           Begin
             ex:=Abfluss.Left;
             MoveTo(ex-7,my+2);
             Lineto(mx,my+2);
             MoveTo(ex-7,my-2);
             Lineto(mx,my-2);
             PfeilRechts(ex,my);
           End
         Else if my<Abfluss.top Then
           Begin
             ex:=Abfluss.left+7;
             ey:=Abfluss.top;
             MoveTo(ex-2,ey-7);
             Lineto(ex-2,my+2);
             LineTo(mx,my+2);
             MoveTo(ex+2,ey-7);
             Lineto(ex+2,my-2);
             LineTo(mx,my-2);
             PfeilUnten(ex,ey);
           End
         Else
           Begin
             ex:=Abfluss.left+7;
             ey:=Abfluss.bottom;
             MoveTo(ex-2,ey+7);Lineto(ex-2,my-2);LineTo(mx,my-2);
             MoveTo(ex+2,ey+7);Lineto(ex+2,my+2);LineTo(mx,my+2);
             PfeilOben(ex,ey);
           End;
       End
       Else Begin{rechts nach links }
       { Zustand bis Ventil }
         IF (my>=Zufluss.top) and (my<=Zufluss.bottom) Then
           Begin
             ax:=Zufluss.left;
             MoveTo(ax,my+2);Lineto(mx,my+2);
             MoveTo(ax,my-2);Lineto(mx,my-2);
           End
         Else if my<Zufluss.top Then
           Begin
             ax:=Zufluss.left+7;
             ay:=Zufluss.top;
             MoveTo(ax-2,ay);Lineto(ax-2,my+2);LineTo(mx,my+2);
             MoveTo(ax+2,ay);Lineto(ax+2,my-2);LineTo(mx,my-2);
           End
         Else
           Begin
             ax:=Zufluss.left+7;
             ay:=Zufluss.bottom;
             MoveTo(ax-2,ay);Lineto(ax-2,my-2);LineTo(mx,my-2);
             MoveTo(ax+2,ay);Lineto(ax+2,my+2);LineTo(mx,my+2);
           End;
        { Ventil bis Zustand }
         IF (my>=Abfluss.top) and (my<=Abfluss.bottom) Then
           Begin
             ex:=Abfluss.right;
             MoveTo(ex+7,my+2);Lineto(mx,my+2);
             MoveTo(ex+7,my-2);Lineto(mx,my-2);
             PfeilLinks(ex,my);
           End
         Else if my<Abfluss.top Then
           Begin
             ex:=Abfluss.right-7;
             ey:=Abfluss.top;
             MoveTo(ex-2,ey-7);Lineto(ex-2,my-2);LineTo(mx,my-2);
             MoveTo(ex+2,ey-7);Lineto(ex+2,my+2);LineTo(mx,my+2);
             PfeilUnten(ex,ey);
           End
         Else
           Begin
             ex:=Abfluss.right-7;
             ey:=Abfluss.bottom;
             MoveTo(ex-2,ey+7);Lineto(ex-2,my+2);LineTo(mx,my+2);
             MoveTo(ex+2,ey+7);Lineto(ex+2,my-2);LineTo(mx,my-2);
             PfeilOben(ex,ey);
           End;
       End
    End;
  end;
end;

end.
