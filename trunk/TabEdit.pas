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

unit TabEdit;
(*
   Tabelleneditor für graphische Eingabe
   Version: 2.0
*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,
  SimObjekt,ErrorTxt,Util;

type
  TTabEditForm = class(TForm)
    y_max: TEdit;
    InputListBox: TListBox;
    OutputListBox: TListBox;
    x_max: TEdit;
    ObjectName: TEdit;
    x_min: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    y_min: TEdit;
    xLabel: TLabel;
    Panel: TPanel;
    PaintBox: TImage;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    procedure FormActivate(Sender: TObject);
    procedure PaintboxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintboxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintboxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure CalculateAll(Sender: TObject);
    procedure KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CancelBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
 private
    werte : array [0..10] of integer;
    simobj : TWertObjekt;
    Bitmap: TBitmap;
    gridx,gridy : integer;
    xMin,xMax,yMin,yMax : double;
    mouseDown : boolean;
    selectX,selectPercent : integer;
    tabX : String;
    procedure DrawGrid();
    procedure DrawGraph();
    procedure Calculate(i:integer);
  public
    procedure Init(obj:TSimuObjekt);
  end;

var
  TabEditForm: TTabEditForm;


implementation

{$R *.dfm}

   procedure TTabEditForm.init(obj:TSimuObjekt);
   var i : integer;
       pkt:TPunkt;
   begin
     simobj:=obj as TWertObjekt;
     gridx:=28;
     gridy:=23;
     mouseDown:=false;
     for i:=0 to 10 do werte[i]:=0;
     ObjectName.text:=simobj.Name;
     Panel.Width:=10*gridx+4;
     Panel.Height:=10*gridy+4;
     xMin:=simobj.xmin;
     yMin:=simobj.ymin;
     xMax:=simobj.xmax;
     yMax:=simobj.ymax;
     y_min.text:=floatToStrF(yMin,ffFixed,6,2);
     y_max.text:=floatToStrF(yMax,ffFixed,6,2);
     x_min.text:=floatToStrF(xMin,ffFixed,6,2);
     x_max.text:=floatToStrF(xMax,ffFixed,6,2);

     if simobj.EingangMax=1 then
       tabX:=TWirkpfeilObjekt(simobj.Eingaenge[1].zgr).von.Name
     else tabX:='Zeit';
     xLabel.Caption:=tabX;
     if simobj.Tabelle<>nil then
       for i:=0 to 10 do begin
         pkt:=simobj.Tabelle.Items[i];
         InputListBox.Items.Add(FloatToStrF(pkt.x,ffFixed,6,2));
         OutputListBox.Items.Add(FloatToStrF(pkt.y,ffFixed,6,2));
         Werte[i]:=round(pkt.y/(yMax-yMin)*100);
       end
     else begin
       for i:=0 to 10 do InputListBox.Items.Add(IntToStr(i)+',00');
       for i:=0 to 10 do OutputListBox.Items.Add('0,00');
     end;
   end;


procedure TTabEditForm.DrawGrid();
var i : integer;
begin
 with Paintbox.Canvas do begin
    Pen.Color := clGreen;
    Pen.Style := psDot;
    for i:=1 to 9 do begin
       MoveTo(0,i*gridy);  LineTo(Paintbox.Width,i*gridy);
    end;
    for i:=1 to 9 do begin
       MoveTo(i*gridx,0);  LineTo(i*gridx,Paintbox.Height);
    end;
   end;
end;

procedure TTabEditForm.DrawGraph();
var i:integer;
begin
 with Paintbox.Canvas do begin
    Pen.Color := clBlue;
    Pen.Style := psSolid;
    MoveTo(0,Paintbox.Height-round(Werte[0]/100*Paintbox.Height)-1);
    for i:=1 to 10 do begin
       LineTo(i*gridx,Paintbox.Height-round(Werte[i]/100*Paintbox.Height)-1);
    end;
 end;
end;


procedure TTabEditForm.FormActivate(Sender: TObject);
var   i : integer;
begin
end;

procedure TTabEditForm.Calculate(i:integer);
var
  value:double;
begin
  try
     yMin:=StrToFloat(y_Min.text);
     yMax:=StrToFloat(y_Max.text);
     value:=Werte[i]*(yMax-yMin)/100.0+yMin;
     OutputListBox.Items.Strings[i]:=floatToStrF(value,ffFixed,6,2);
  except
      on EConvertError do MessageDlg(ErrorTxt40,mtError,[mbok],0);
  end;
end;

procedure TTabEditForm.CalculateAll(Sender: TObject);
var value:double;
    input:double;
    i : integer;
begin
  try
    xMin:=StrToFloat(x_Min.text);
    xMax:=StrToFloat(x_Max.text);
    yMin:=StrToFloat(y_Min.text);
    yMax:=StrToFloat(y_Max.text);
    for i:=0 to 10 do begin
      value:=Werte[i]*(yMax-yMin)/100.0+yMin;
      OutputListBox.Items.Strings[i]:=floatToStrF(value,ffFixed,6,2);
    end;
    for i:=0 to 10 do begin
      input:=xMin+i*(xMax-xMin)/10;
      InputListBox.Items.Strings[i]:=floatToStrF(input,ffFixed,6,2);
    end;
  except
      on EConvertError do MessageDlg(ErrorTxt40,mtError,[mbok],0);
  end;
end;


procedure TTabEditForm.PaintboxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   mouseDown:=true;
   selectX:=(x+gridX div 2) div gridX;
   selectPercent:=100-round(y/Paintbox.Height*100);
   Werte[selectX]:=selectPercent;
   FormPaint(Sender);
   Calculate(selectX);
end;

procedure TTabEditForm.PaintboxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   mouseDown:=false;
end;

procedure TTabEditForm.PaintboxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var MouseX : integer;
begin
end;

procedure TTabEditForm.FormPaint(Sender: TObject);
begin
  PaintBox.Canvas.FillRect(Rect(0,0,PaintBox.Width,PaintBox.Height));
  drawGrid();
  drawGraph();
end;

procedure TTabEditForm.KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   CalculateAll(Sender);
end;

procedure TTabEditForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var list:TList;
     pkt:TPunkt;
     i : integer;
begin
  simobj.Name:=ObjectName.Text;
  simobj.xtbf:=editTab;
  simobj.xmin:=xMin;
  simobj.xmax:=xMax;
  simobj.ymin:=yMin;
  simobj.ymax:=yMax;

  simobj.Eingabe:='Tabelle('+tabX+')';
  //MessageDlg(simobj.Eingabe, mtInformation,[mbOk], 0);
  simobj.gueltig:=true;

  if simobj.Tabelle<>nil then simobj.Tabelle.Free;
  list:= TList.create;
  for i:=0 to 10 do begin
    pkt:=TPunkt.create;
    pkt.init(StrToFloat(InputListBox.Items.Strings[i]),StrToFloat(OutputListBox.Items.Strings[i]));
    list.Add(pkt);
  end;
  simobj.Tabelle:=list;
  InputListBox.Items.Clear;
  OutputListBox.Items.Clear;
  canClose:=true;
end;

procedure TTabEditForm.CancelBtnClick(Sender: TObject);
begin
  close();
end;

procedure TTabEditForm.OkBtnClick(Sender: TObject);
var canClose:boolean;
begin
  FormCloseQuery(Sender,canClose);
  if canClose then close();
end;

end.
