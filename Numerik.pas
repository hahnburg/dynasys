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

unit Numerik;

{$MODE Delphi}

(*
   Numerikdialog für Simulation
   Version: 2.0
   Autor: Walter Hupfeld
   zuletzt bearbeitet:
*)


interface

uses unix, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, SysUtils, Dialogs,
  ErrorTxt;

type
  TNumerikDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    Bevel1: TBevel;
    Rechenverfahren: TGroupBox;
    EulerBtn: TRadioButton;
    RungeBtn: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    EditStartzeit: TEdit;
    EditEndzeit: TEdit;
    Editdt: TEdit;
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    Euler : boolean;
    StartZeit:double;
    EndZeit:double;
    dt:double;
    procedure StoreData(S:TWriter);
    procedure LoadData(R:TReader);
  end;

var
  NumerikDlg: TNumerikDlg;

implementation

{$R *.lfm}

procedure TNumerikDlg.FormActivate(Sender: TObject);
begin
  EditStartZeit.Text:=FloatToStr(StartZeit);
  EditEndZeit.Text:=FloatToStr(EndZeit);
  EditDt.Text:=FloatToStr(dt);

  (*if NumParam^.dt<0.01 Then Begin
    Str(NumParam^.dt:8,Puffer); SetDlgItemText(HWindow,id_dt,Puffer)
  End Else Begin
    Str(NumParam^.dt:0:2,Puffer); SetDlgItemText(HWindow,id_dt,Puffer);
  End;
  If NumParam^.Intervall<0.01 Then Begin
    Str(NumParam^.Intervall:8,Puffer); SetDlgItemText(HWindow,id_intervall,Puffer);
  End Else Begin
    Str(NumParam^.Intervall:0:2,Puffer); SetDlgItemText(HWindow,id_intervall,Puffer);
  End; *)
end;

procedure TNumerikDlg.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  DecimalSeparator:=',';
  Euler:=EulerBtn.checked;
  try
    StartZeit:=StrToFloat(EditStartZeit.text);
    EndZeit:=StrToFloat(EditEndZeit.text);
    dt:=StrToFloat(Editdt.text);
  except
    on EConvertError do MessageDlg(ErrorTxt4,mtError,[mbok],0);
  end
end;

procedure TNumerikDlg.FormCreate(Sender: TObject);
begin
  StartZeit:=0;
  EndZeit:=100;
  dt:=1;
end;

procedure TNumerikDlg.StoreData(S:TWriter);
begin
  S.WriteFloat(StartZeit);
  S.WriteFloat(EndZeit);
  S.WriteFloat(dt);
end;

procedure TNumerikDlg.LoadData(R:TReader);
begin
  StartZeit:=R.ReadFloat;
  EndZeit:=R.ReadFloat;
  dt:=R.ReadFloat;
end;


end.
