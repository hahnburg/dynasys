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

unit Diagram;

{$MODE Delphi}

{*
  Zeichnet Zeit-/ Phasendiagramme
  Autor: Walter Hupfeld
  Version: 2.0

  zuletzt bearbeitet: 2003-04-25
*}
interface

uses Graphics, unix, Classes, SysUtils,  LCLType, LCLIntf, IntfGraphics,
     Funktion;
const maxGraph = 4;

type
      tDbPoint = class
                    x,y:double;
                    procedure init(x1,y1:double);
               end;


      tGraph = class (tList)
            private
              function GetValue(index:integer):tDbPoint;
            public
              title : String[40];
              scale : double;
              color : TColor;
              procedure setColor(color:TColor);
              procedure GetYMinMax(var min,max:double);
              procedure GetXMinMax(var min,max:double);
              function NoData:boolean;
              property items[index:integer]:TDbPoint read GetValue;
          end;


    tDiagram = class (tobject)
        public
          y : array [1..maxGraph] of tGraph;
          xtyp, ytyp                  : integer;
          dot                         : boolean;
          procedure init(c:TCanvas;width,height:integer;mode:integer);
          procedure SetSize(width,height:integer);
  	  procedure SetPlotArea(x1,y1,x2,y2 : Double);
          Procedure xAutoSkalierung;
          Procedure yAutoSkalierung;
          Procedure AutoSkalierung;
          procedure Zeichnen;
        private
          mode : integer;
          xmin,xmax,ymin,ymax,
          xo,yo, dx,dy ,xselect,yselect:double;
          wmin,wmax,hmin,hmax         : integer;
          xlogmax, ylogmax,xlogmin, ylogmin : double;
          w,h,nx,ny                   :integer;

          PenStyle : TPenStyle;
          Canvas:TCanvas;
          procedure CanvasSetTextAngle( d: Word);
          procedure CanvasTextOutAngle( x,y: Integer; d: Word; s: string);
          function xp(x : Double) : Integer;
          function yp(y : Double) : Integer;
          function xt(x : Double) : Integer;
          function yt(y : Double) : Integer;
          function xd(x : Integer) : Double;
          function yd(y : Integer) : Double;
          Function xMittel(a,b :  Double): Double;
          Function yMittel(a,b :  Double): Double;
  	  procedure SetAxisType(x, y : Byte);
  	  procedure SetPercentWindow(x1,y1,x2,y2 : Double);
  	  procedure SelectColor(cl: TColor);
  	  procedure SetXYIntercepts(x, y : Double);
  	  procedure DrawXAxis(deltax : double; d : Byte);
  	  procedure DrawYAxis(deltay : double; d : Byte);
  	  procedure SetLineStyle(St : TPenStyle);
          procedure ScalePlotArea(x1,y1,x2,y2 : Double);
  	  procedure LabelXAxis(n : Byte; d : Byte);
  	  procedure LabelYAxis(n : Byte; d : Byte);
  	  procedure TitleWindow(const s : String);
  	  procedure TitleXAxis(const s : String; pos : Byte);
  	  procedure TitleYAxis(const s : String; pos : Byte);
  	  procedure DrawGridX(n : Byte);
  	  procedure DrawGridY(n : Byte);
  	  procedure DrawGridXY;
  	  procedure ClearGraph;
  	  procedure ClearWindow;
  	  procedure ScreenDump;
  	  procedure LabelGraphWindow(x, y : Double; s : String; xj, yj : Byte);
  	  procedure LabelPlotArea(x, y : Double; s : String; xj, yj : Byte);
  	  procedure LinePlotData(yi : tGraph;  cl : TColor; st : TPenStyle);
  	  procedure ScatterPlotData(yi : tGraph;  cl : TColor; st : Byte);
  	  procedure SetBackgroundColor(cl : TColor);
  	  procedure ZoomIn;
  	  procedure ZoomOut;
  	  procedure ZoomStandard;
  	  procedure SetTextStyle;
    end;

    Function NumExp(realnum :  Double): Integer;



implementation

uses Dynamain;

procedure tdbPoint.init(x1,y1:double);
begin
  x:=x1; y:=y1
end;

{ ============================================================= }

procedure tGraph.setColor(color:TColor);
begin
  self.color:=color;
end;

function tGraph.GetValue(index:integer):TDbPoint;
begin
  if (index<0) or (index>=count) then
  else
    result:= TDbPoint(Tlist(self).items[index])
end;

function tGraph.NoData:Boolean;
begin
  result:=count=0;
end;

procedure tGraph.GetYMinMax(var min,max:double);
var i : integer;
begin
 min:=items[0].y;
 max:=items[0].y;
 for i:= 1 to count-1 do begin
   if items[i].y<min then min:=items[i].y;
   if items[i].y>max then max:=items[i].y;
 end;
end;

procedure tGraph.GetXMinMax(var min,max:double);
var i : integer;
begin
 min:=items[0].x;
 max:=items[0].x;
 for i:= 1 to count-1 do begin
   if items[i].x<min then min:=items[i].x;
   if items[i].x>max then max:=items[i].x;
 end;
end;

{ ============================================================= }

Function NumExp(realnum :  Double): Integer;
{ 1k..9.99k => 3, 1m..9.99m => -3, 1..9.99 => 0 }
Var e : Integer;
Begin
  e := round(log10(abs(realnum*0.999))+0.5);
  If realnum<1  then e:=e-0*1;
  NumExp:=e
End;

 { ============ tDIAGRAM =========================================== }


procedure tDiagram.init(c:TCanvas;width,height:integer;mode:integer);
var i:integer;
begin
  Canvas:=c;
  w:=width;h:=height;
  for i:=1 to maxGraph do y[i]:=tGraph.create;
  SetAxisType(0,0);     	{ 0 heißt linear }
  { Man könnte auch die Autoskalierung benutzen! }
  dot := false;
  PenStyle := psSolid;

  dx:=1;
  dy:=1;
  nx:=5;
  ny:=2;

  xmin:=-1;
  xmax:=50;
  ymin:=-0;
  ymax:=10;

  self.mode:=mode;  // 1: Zeitdiagramm; 2: Phasendiagramm
end;

procedure tDiagram.SetSize(width,height:integer);
begin
  w:=width;
  h:=height;
end;


procedure tDiagram.SetAxisType(x, y : Byte);
begin
  xtyp:=x;
  ytyp:=y
end;

procedure tDiagram.SetPercentWindow(x1,y1,x2,y2 : Double);
begin
  (* w:=Image.Width;
  h:=Image.Height; *)
  hmin:=round(y1*h+12);
  hmax:=round(y2*h-22);
  wmin:=round(x1*w+24);
  wmax:=round(x2*w-14);
end;

procedure tDiagram.SetPlotArea(x1,y1,x2,y2 : Double);
begin
   ScalePlotArea(x1,y1,x2,y2);
   dx:=Aufrunden_125((xmax-xmin)/30);
   nx:=5;
   dy:=Aufrunden_125((ymax-ymin)/30);
   ny:=5;
end;


{ ------------------------------------  }

function tDiagram.xp(x : Double) : Integer;	{ Berechnung des Pixelwertes im Koordinantensystem }
begin
  If x<=xmin
    then xp:=wmin
    else If x>=xmax
      then xp:=wmax
        else
           case xtyp of
               0 : xp:=round((x-xmin)/(xmax-xmin)*(wmax-wmin)+wmin);
               else xp:=round((log10(x)-xlogmin)/(xlogmax-xlogmin)*(wmax-wmin)+wmin);
           end;
end;

function tDiagram.yp(y : Double) : Integer;
begin
  If y<=ymin
    then yp:=hmax
    else
      If y>=ymax
        then yp:=hmin
        else
          Case ytyp of
               0 : yp:=round((y-ymin)/(ymax-ymin)*(hmin-hmax)+hmax);
               else yp:=round((log10(y)-ylogmin)/(ylogmax-ylogmin)*(hmin-hmax)+hmax);
          End;
end;

function tDiagram.xt(x : Double) : Integer;
{ Berechnung des Pixelwertes im Koordinatensystem 0...1000.0}
begin
  Case xtyp of
    0 : xt:=round((x-0)/(1000-0)*w);
    else xt:=round((x-0)/(1000-0)*w);
  End;
end;

function tDiagram.yt(y : Double) : Integer;
begin
  Case ytyp of
    0 : yt:=round((y-0)/(1000-0)*(-h)+h);
    else yt:=round((y-0)/(1000-0)*(-h)+h);
  End;
end;

function tDiagram.xd(x : Integer) : Double;
{ Berechnung des x-Wertes aus Pixel-Koordinante }
begin
  If x>wmax-1
    then x:=wmax-1;
  If x<wmin+1
    then x:=wmin+1;
  Case xtyp of
    0 : xd:=(x-wmin)*(xmax-xmin)/(wmax-wmin)+xmin;
    else xd:=xy(10,(x-wmin)*(xlogmax-xlogmin)/(wmax-wmin)+xlogmin);
  End;
end;

function tDiagram.yd(y : Integer) : Double;
begin
  If y>hmax-1
    then y:=hmax-1;
  If y<hmin+1
    then y:=hmin+1;
  Case ytyp of
    0 : yd:=(y-hmax)*(ymax-ymin)/(hmin-hmax)+ymin;
    else yd:=xy(10,(y-hmax)*(ylogmax-ylogmin)/(hmin-hmax)+ylogmin);
  End;
end;

Function tDiagram.xMittel(a,b :  Double): Double;
begin
  Case xtyp of
    0 : xMittel:=(a+b)/2;
    else xMittel:=sqrt(a*b)
  End;
end;

Function tDiagram.yMittel(a,b :  Double): Double;
begin
  Case ytyp of
    0 : yMittel:=(a+b)/2;
    else yMittel:=sqrt(a*b)
  End;
end;



procedure tDiagram.ScalePlotArea(x1,y1,x2,y2 : Double);
Var e : Integer;
begin
  Case xtyp of
    0 : Begin
          xmin:=x1;
          xmax:=x2;
        End;
	else Begin
          e := NumExp(x2) + 0*1;
          xmax := xy(10, e);	  { entspricht Aufrunden zur nächsten 10er-Potenz }
          e := NumExp(x1);
          xmin := xy(10, e);	  { entspricht Abrunden zur nächsten 10er-Potenz }
          If xmax<=xmin
            then xmin:=xmax/10;
          xlogmin:=log10(xmin);
          xlogmax:=log10(xmax);
        End;
    End;
    Case ytyp of
      0 : Begin
            ymin:=y1;
            ymax:=y2;
          End;
	  else Begin
            e := NumExp(y2) + 0*1;
            ymax := xy(10, e);	  { entspricht Aufrunden zur nächsten 10er-Potenz }
            e := NumExp(y1);
            ymin := xy(10, e);	  { entspricht Abrunden zur nächsten 10er-Potenz }
            If ymax<=ymin
              then ymin:=ymax/10;
            ylogmin:=log10(ymin);
            ylogmax:=log10(ymax);
          End;
	End;
	xselect:=xmax;
	yselect:=ymax;
	 { Eigentlich Aufgabe von SetPercentWindow }
	(* w:=Image.Width;
	 h:=Image.Height; *)
      hmin:=round(0.05*h+12);
      hmax:=round(0.95*h-22);
      wmin:=round(0.05*w+28);
      wmax:=round(0.95*w-14);
end;



Procedure tDiagram.xAutoSkalierung;
var i:integer;
    amax,amin:double;
Begin
  if  y[1].noData then exit;
  y[1].getXMinMax(amin, amax);
  xmin:=amin;
  xmax:=amax;
  for i:=1 to maxGraph do
    if not y[i].noData then begin
       y[i].getXMinMax(amin, amax);
       if amin<xmin then xmin:=amin;
       if amax>xmax then xmax:=amax;
    end;
  Case xtyp of
  0 : Begin
        If (xmax>0) then
          xo:=0
        else
          xo:=Aufrunden_125(xmin/2);
         // xmin:=Min(0,Aufrunden_125(xmin/2));
         // xmax:=intelligentes_Aufrunden(1.001*xmax);
      End
      else Begin
        xmin:=xmin/10;
        xo:=xmin
      End;
	 End;
      dx:=Aufrunden_125((xmax-xmin)/30);
      nx:=5;
End;

Procedure tDiagram.yAutoSkalierung;
var i:integer;
    amax,amin:double;
Begin
  if  y[1].noData then exit;
  y[1].getYMinMax(amin, amax);
  ymin:=amin;
  ymax:=amax;
  for i:=1 to maxGraph do
    if not y[i].noData then begin
       y[i].getYMinMax(amin, amax);
       if amin<ymin then ymin:=amin;
       if amax>ymax then ymax:=amax;
    end;
  Case ytyp of
    0 : Begin
          If (ymax>0) then yo:=0
          else yo:=Aufrunden_125(ymin/2);

          //ymin:=Min(0,Aufrunden_125(ymin/2));
          if ymin<0 then
             ymin:=min(0,-1.0 * intelligentes_Aufrunden(-1.00001*ymin));
             ymax:=intelligentes_Aufrunden(1.00001*ymax);
        End
        else Begin
          ymin:=ymin/10;
          yo:=ymin
        End;
  End;
  dy:=Aufrunden_125((ymax-ymin)/30);
  ny:=5;
End;

Procedure tDiagram.AutoSkalierung;
Begin
  xAutoSkalierung;
  yAutoSkalierung;
End;


procedure tDiagram.CanvasSetTextAngle( d: Word);
var
  LogRec: TLogFont;     {* Storage area for font information *}
begin
 // GetObject(canvas.Font.Handle,SizeOf(LogRec),Addr(LogRec));
//  LogRec.lfEscapement := d;
//  canvas.Font.Handle := CreateFontIndirect(LogRec);
end;


procedure tDiagram.CanvasTextOutAngle( x,y: Integer; d: Word; s: string);
//var
  //LogRec: TLogFont;     {* Storage area for font information *}
  //OldFontHandle,        {* The old font handle *}
  //NewFontHandle: HFONT; {* Temporary font handle *}
begin
 // GetObject(canvas.Font.Handle, SizeOf(LogRec), Addr(LogRec));
//  LogRec.lfEscapement := d;
//  NewFontHandle := canvas.Font.CreateHandle(); //CreateFontIndirect(LogRec);
//  OldFontHandle := SelectObject(canvas.Handle,NewFontHandle);
  Canvas.TextOut(x,y,s);
//  NewFontHandle := SelectObject(canvas.Handle,OldFontHandle);
//  DeleteObject(NewFontHandle);
end;



procedure tDiagram.SelectColor(cl: TColor);
begin
  with Canvas do begin
    Pen.Color :=cl;
    Font.Color := cl;
  end;
end;

procedure tDiagram.SetXYIntercepts(x, y : Double);
begin
  Case xtyp of
    0 : Begin
          xo:=x;
        End;
	else Begin
          xo:=xmin;
        End;
  End;
  Case ytyp of
    0 : Begin
         yo:=y;
        End;
	else Begin
          yo:=ymin;
        End;
  End;
end;

procedure tDiagram.DrawXAxis(deltax : double; d : Byte);
Var i, ypixo, xpixmax,
	 px, py, offset : Integer;
	 x : Double;
begin
  with Canvas do begin
    If d=0	{ Richtung }
      then Offset:=Maxb(2,round(sqrt(hmax/20)))
      else Offset:=-Maxb(2,round(sqrt(hmax/20)));

    px:=round(0.006*w+1);
    py:=round(0.003*h+1);
    Case xtyp of
      0 : Begin
            dx:=deltax;

            ypixo:=yp(yo);
            xpixmax:=xp(xmax);
            { x-Achse }
            MoveTo(xp(xmin),ypixo);
            LineTo(xpixmax,ypixo);

            { Pfeil an Achse }
            MoveTo(xpixmax,ypixo);
            LineTo(xpixmax-px,ypixo+py);
            MoveTo(xpixmax,ypixo);
            LineTo(xpixmax-px,ypixo-py);

            { Striche an die Achse }
            x:=xo;
            While x<xmax-dx do begin
              x:=x+dx;
              MoveTo(xp(x),yp(yo));
              LineTo(xp(x),yp(yo)+Offset);
            end;
            x:=xo;
            While x>xmin do begin
              x:=x-dx;
              MoveTo(xp(x),yp(yo));
              LineTo(xp(x),yp(yo)+Offset);
            end;
         End;
	 else Begin
           ypixo:=yp(yo);
           xpixmax:=xp(xmax);
           { x-Achse }
           MoveTo(xp(xmin),ypixo);
           LineTo(xpixmax,ypixo);

           { Pfeil an Achse }
           MoveTo(xpixmax,ypixo);
           LineTo(xpixmax-px,ypixo+py);
           MoveTo(xpixmax,ypixo);
           LineTo(xpixmax-px,ypixo-py);

           { Striche an die Achse }
           x:=xo;
           While x<xmax/10 do begin
             For i:=2 to 9 Do Begin
               MoveTo(xp(x*i),ypixo);
               LineTo(xp(x*i),ypixo+Offset);
             End;
             x:=x*10;
             MoveTo(xp(x),yp(yo));
             LineTo(xp(x),yp(yo)+Offset);
           end;
           For i:=2 to 9 Do Begin
             MoveTo(xp(x*i),ypixo);
             LineTo(xp(x*i),ypixo+Offset);
           End;
	 End;
	 End; { Case }
	 end
end;

procedure tDiagram.DrawYAxis(deltay : double; d : Byte);
Var i, xpixo, ypixmax,
	 px, py,
	 offset : Integer;
	 y : Double;
begin
  with Canvas do begin
    If d=0 then Offset:=Maxb(2,round(sqrt(wmax/30)))
           else Offset:=-Maxb(2,round(sqrt(wmax/30)));
    px:=round(0.003*w+1);
    py:=round(0.01*h+1);
    Case ytyp of
      0 : Begin
            dy:=deltay;
            xpixo:=xp(xo);
            ypixmax:=yp(ymax);
            { x-Achse }
            MoveTo(xpixo,yp(ymin));
            LineTo(xpixo,yp(ymax));

            { Pfeil an Achse }
            MoveTo(xpixo,ypixmax);
            LineTo(xpixo-px,ypixmax+py);
            MoveTo(xpixo,ypixmax);
            LineTo(xpixo+px,ypixmax+py);

            { Striche an die Achse }
            y:=yo;
            While y<ymax-dy do begin
              y:=y+dy;
              MoveTo(xpixo,yp(y));
              LineTo(xpixo-Offset,yp(y));
            end;
            y:=yo;
            While y>ymin do begin
              y:=y-dy;
              MoveTo(xpixo,yp(y));
              LineTo(xpixo-Offset,yp(y));
            end;
           End;
	 else Begin
           xpixo:=xp(xo);
           ypixmax:=yp(ymax);
           MoveTo(xpixo,yp(ymin));
           LineTo(xpixo,yp(ymax));

           MoveTo(xpixo,ypixmax);
           LineTo(xpixo-px,ypixmax+py);
           MoveTo(xpixo,ypixmax);
           LineTo(xpixo+px,ypixmax+py);

           { Striche an die Achse }
           y:=yo;
           While y<ymax/10 do begin
             For i:=2 to 9 Do Begin
               MoveTo(xpixo,yp(y*i));
               LineTo(xpixo-Offset,yp(y*i));
             End;
             y:=y*10;
             MoveTo(xpixo,yp(y));
             LineTo(xpixo-Offset,yp(y));
           end;
           For i:=2 to 9 Do Begin
             MoveTo(xpixo,yp(y*i));
             LineTo(xpixo-Offset,yp(y*i));
           End;
          End;
	 End; { Case }
	 end;
end;

procedure tDiagram.LabelXAxis(n : Byte; d : Byte);
Var i, NK, ypo, Offset : Integer;
	 x : Double;
begin
  with Canvas do begin
    If d=0
      then Offset:=4
      else Offset:=-20;
    ypo:=yp(yo);
    Case xtyp of
	 0 : Begin
               NK:=1;
               If abs(xmax-xmin)/Max(abs(xmax),abs(xmin))<0.01 then Begin
                 NK:=2;
                 If abs(xmax-xmin)/Max(abs(xmax),abs(xmin))<0.001
                    then NK:=3
               End;
               x:=xo;
               While x<xmax-dx*n do begin
                 x:=x+dx*n;
                 Textout(xp(x)-11,ypo+Offset,floattostrf(x,ffgeneral,10,NK))
               end;
               x:=xo;
               While x>xmin+dx*n do begin
                 x:=x-dx*n;
                 Textout(xp(x)-11,ypo+Offset,floattostrf(x,ffgeneral,10,NK))
               end;
            End;
	 else Begin
            x:=xo;
            While x<=xmax/10 do begin
               Textout(xp(x)-11,ypo+Offset,floattostrf(x,ffgeneral,10,1));
               x:=x*10;
            end;
         End;
       End;
    end
end;

procedure tDiagram.LabelYAxis(n : Byte; d : Byte);
{ n: Anzahl der Einteilungen; d: Offset }
Var i, NK, xpo, Offset : Integer;
	 y : Double;
begin
  with Canvas do begin
    If d=0
      then Offset:=40
      else Offset:=-8;
    xpo:=xp(xo);
    Case ytyp of
      0 : Begin
            NK:=1;
            If abs(ymax-ymin)/Max(abs(ymax),abs(ymin))<0.01 then Begin
              NK:=2;
              If abs(ymax-ymin)/Max(abs(ymax),abs(ymin))<0.001 then NK:=3 End;
              y:=yo;
              While y<ymax-dy*n do begin
                y:=y+dy*n;
                canvas.Textout(xpo-Offset,yp(y)-8,floattostrf(y,ffnumber,6,NK))
              end;
              y:=yo;
              While y>ymin+dy*n do begin
                y:=y-dy*n;
                canvas.Textout(xpo-Offset,yp(y)-8,floattostrf(y,ffnumber,6,NK))
              end;
            End;
      else Begin
        y:=yo;
         While y<=ymax/10 do begin
           canvas.Textout(xpo-Offset,yp(y)-8,floattostrf(y,ffFixed,6,2));
           y:=y*10;
         end;
      End;
    End;
  end
end;

procedure tDiagram.TitleWindow(const s : String);
begin
  canvas.Textout(xp(xMittel(xmin,xmax))-Canvas.TextWidth(s) div 2,1,s);
end;

procedure tDiagram.TitleXAxis(const s : String;  Pos : Byte);
{ pos  0: unten  1: oben }
begin
 If Pos=0
   then canvas.Textout(xp(xMittel(xmin,xmax))-3*length(s),hmax+18,s)
   else canvas.Textout(xp(xMittel(xmin,xmax))-3*length(s),hmin-14,s);
end;

procedure tDiagram.TitleYAxis(const s : String; Pos : Byte);
{ Pos 0:links  1: rechts}
begin
// muss überarbeitet werden.
  CanvasSetTextAngle(900);
  If pos=0 then
    canvas.Textout(2,yp(yMittel(ymin,ymax))+Canvas.TextWidth(s) div 2,s)
  else
    canvas.Textout(wmax-4+(pos*Canvas.TextWidth('xx')),yp(yMittel(ymin,ymax))+Canvas.TextWidth(s) div 2,s);
  CanvasSetTextAngle(0);
end;

procedure tDiagram.SetLineStyle(St : TPenStyle);
begin
  Canvas.Pen.Style:=St;
end;

procedure tDiagram.DrawGridX(n : Byte);
Var i, ypmin, ypmax : Integer;
	 x : Double;
	 St : TPenStyle;
begin
  with Canvas
  do begin
	 St:=Pen.Style;
	 Pen.Style:=psDot;
	 ypmin:=yp(ymin);
	 ypmax:=yp(ymax);
	 Case xtyp of
	 0 : Begin
		 x:=xo+dx*n;
		 While x<xmax
		 do begin
			MoveTo(xp(x),ypmin);
			LineTo(xp(x),ypmax);
			x:=x+dx*n;
			end;
		 x:=xo-dx*n;
		 While x>xmin
		 do begin
			MoveTo(xp(x),ypmin);
			LineTo(xp(x),ypmax);
			x:=x-dx*n;
			end;
		 End;
	 else Begin
			 x:=xo;
			 While x<xmax
			 do begin
				For i:=2 to 9
					Do Begin
						MoveTo(xp(x*i),ypmin);
						LineTo(xp(x*i),ypmax);
					   End;
				x:=x*10;
				MoveTo(xp(x),ypmin);
				LineTo(xp(x),ypmax);
				end;
		End;
	 End;
	 Pen.Style:=St;
	 end
end;

procedure tDiagram.DrawGridY(n : Byte);
Var i, xpmin, xpmax : Integer;
	 y : Double;
	 St : TPenStyle;
begin
  with Canvas do begin
    St:=Pen.Style;
    Pen.Style:=psDot;
    xpmin:=xp(xmin);
    xpmax:=xp(xmax);
    Case ytyp of
      0 : Begin
            y:=yo+dy*n;
            While y<ymax do begin
              MoveTo(xpmin,yp(y));
              LineTo(xpmax,yp(y));
              y:=y+dy*n;
            end;
            y:=yo-dy*n;
            While y>ymin do begin
              MoveTo(xpmin,yp(y));
              LineTo(xpmax,yp(y));
              y:=y-dy*n;
            end;
          End;
       else Begin
              y:=yo;
              While y<ymax do begin
                For i:=2 to 9 Do Begin
                  MoveTo(xpmin,yp(y*i));
                  LineTo(xpmax,yp(y*i));
                End;
                y:=y*10;
                MoveTo(xpmin,yp(y));
                LineTo(xpmax,yp(y));
              end; {while}
             End; {else}
	 End; {case}
	 Pen.Style:=St;
    end {with}
end;

procedure tDiagram.DrawGridXY;
begin
	DrawGridX(1);
	DrawGridY(1)
end;

procedure tDiagram.ClearGraph;
var
  ARect: TRect;
begin
  with Canvas do begin
    CopyMode := cmWhiteness;
    ARect := Rect(0, 0, w, h);
    CopyRect(ARect, Canvas, ARect);
    CopyMode := cmSrcCopy;
  end;
end;

procedure tDiagram.ClearWindow;
var ARect: TRect;
begin
  with Canvas do begin
    CopyMode := cmWhiteness;
    ARect := Rect(wmin, hmin, wmax, hmax);
    CopyRect(ARect, Canvas, ARect);
    CopyMode := cmSrcCopy;
  end;
end;

procedure tDiagram.ScreenDump;
begin
 (* with Printer do
  begin
	 BeginDoc;
	 Canvas.Draw(0, 0, Image.Picture.Graphic);
	 EndDoc;
  end; *)
end;

procedure tDiagram.LabelGraphWindow(x, y : Double; s : String; xj, yj : Byte);
begin	{ Koordinantensystem (0,0)-(1000,1000) }
  Canvas.Textout(xt(x),yt(y),s)
end;

procedure tDiagram.LabelPlotArea(x, y : Double; s : String; xj, yj : Byte);
begin
  Canvas.Textout(xp(x),yp(y),s)
end;

procedure tDiagram.LinePlotData(yi : tGraph; cl : TColor; st : TPenStyle);
Var i, xpix, ypix : Integer;
	 OldSt : TPenStyle;
begin
  with Canvas do begin
    Pen.Color :=cl;
    OldSt:=Pen.Style;
    Pen.Style :=st;
    xpix:=xp(yi.items[0].x);
    ypix:=yp(yi.items[0].y);
    MoveTo(xpix,ypix);

    i:=1;
    xpix:=xp(yi.items[i].x);
    ypix:=yp(yi.items[i].y);
    While (i<=(yi.count-1)) Do begin
      xpix:=xp(yi.items[i].x);
      ypix:=yp(yi.items[i].y);
      If  true (*(xpix<wmax) and (ypix*1.05<hmax) and (xpix>wmin) and (ypix*1.05>hmin)*)
        then LineTo(xpix,ypix)
        else MoveTo(xpix,ypix);
        inc(i);
      end;
      Pen.Style :=Oldst;
    end
end;

procedure tDiagram.ScatterPlotData(yi :tGraph;  cl : TColor; st : Byte);
Var i, g, xpix, ypix,m : Integer;
	 Oldcl : TColor;
begin
  with Canvas do begin
    Oldcl:=Pen.Color;
    Pen.Color :=cl;
    i:=0;
    m:=yi.count;
    g:=round(1+(wmax+hmax)/500);	{ Größe abhängig von Fenstergröße }
    While (i<=m) Do begin
       xpix:=xp(yi.items[i].x);
       ypix:=yp(yi.items[i].y);
       If (xpix<wmax) and (ypix<hmax) and (xpix>wmin) and (ypix*1.05>hmin)
         then
           Case st of
             2 : Rectangle(xpix-g,ypix,xpix+g,ypix+g);	{ Rechteck }
             3 : Ellipse(xpix,ypix,xpix+g,ypix+g);		{ Kreis }
             4 : begin
                  MoveTo(xpix-g,ypix+g);				{ Kreuz }
                  LineTo(xpix+g,ypix-g);
                  MoveTo(xpix+g,ypix+g);
                  LineTo(xpix-g,ypix-g);
                 end;
             else Rectangle(xpix-1,ypix-1,xpix+1,ypix+1);	{ Punkt }
           end;
           inc(i);
    end; {while}
    Pen.Color:=Oldcl;
  end {with}
end;

procedure tDiagram.SetBackgroundColor(cl : TColor);
Var Oldcl : TColor;
    NewRect: TRect;
begin
  with Canvas  do begin
    NewRect := Rect(0, 0, w, h);
    Oldcl:=Brush.Color;
    Brush.Color := cl;
    FillRect(NewRect);
    Brush.Color:=Oldcl;
    { Oldcl eigentlich überflüssig und falsch!! }
    Brush.Color:=cl;
  end
end;

procedure tDiagram.ZoomIn;
begin
end;

procedure tDiagram.ZoomOut;
begin
end;

procedure tDiagram.ZoomStandard;
begin
end;

procedure tDiagram.SetTextStyle;
begin
end;



procedure TDiagram.Zeichnen;
var i:integer;
begin
  with Canvas do begin
    Font.Name:='Arial';
    Font.Style:=[];
    SetBackgroundColor(clWhite);
    SetAxisType(xtyp,ytyp);
    ScalePlotArea(xmin,ymin,xmax,ymax);
    SetXYIntercepts(xo,yo);

    SelectColor(clBlack);
    DrawXAxis(dx,0);
    DrawYAxis(dy,0);

    SelectColor(clGray);
    DrawGridX(nx);
    DrawGridY(ny);

    SelectColor(clBlack);
    LabelXAxis(nx,0);
    LabelYAxis(ny,0);

    SelectColor(clGreen);
    TitleWindow(ChangeFileExt(extractFileName(MainForm.Filename),''));
    SelectColor(clBlue);
    if mode=1 then begin //Zeitdiagramm
       LabelGraphWindow(3,995,'Zeitdiagramm :',0,0);
       TitleXAxis('Zeit t',0);
       for i:= 1 to maxGraph do
         if not y[i].noData then begin
           SelectColor(y[i].color);
           TitleYAxis(y[i].title,i-1);
           LinePlotData(y[i],y[i].color,PenStyle);
           if dot then ScatterPlotData(y[i],clBlue,4);
         end
    end
    else if mode=2 then begin // Phasendiagramm
       LabelGraphWindow(3,995,'Phasendiagramm :',0,0);
       //SelectColor(y[1].color);
       SelectColor(clBlue);
       TitleXAxis(y[1].title,0);
       TitleYAxis(y[2].title,0);
       SelectColor(clBlue);

       LinePlotData(y[1],y[1].color,PenStyle);
       if dot then ScatterPlotData(y[2],clBlue,4);
    end;
    { LabelPlotArea((xmin+xmax)/2,( xmin+ymax)/2,'Mitten drin!',0,0); }

    SelectColor(clBlue);
  end;
end;



end.
