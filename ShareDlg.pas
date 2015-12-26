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

unit ShareDlg;

{$MODE Delphi}

interface

uses unix, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, SysUtils, Dialogs, RegDialog;

type
  TSharewareDlg = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Timer1: TTimer;
    OKBtn: TButton;
    RegistrierBtn: TButton;
    Label16: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BestellBtnClick(Sender: TObject);
    procedure RegistrierBtnClick(Sender: TObject);
  private
    { Private declarations }
    Zaehler : Integer;
  public
    { Public declarations }
  end;

var
  SharewareDlg: TSharewareDlg;

implementation

{$R *.lfm}

procedure TSharewareDlg.Timer1Timer(Sender: TObject);
begin
   If Zaehler=0 Then Begin
     Timer1.enabled:=false;
     OkBtn.Caption:='OK';
     OKBtn.ModalResult:=mrOk;
     Timer1.free
   End Else Begin
     OkBtn.Caption:='Bitte warten! - ' + IntToStr(Zaehler);
     Dec(Zaehler);
   End;
end;



procedure TSharewareDlg.FormCreate(Sender: TObject);
begin
  Zaehler:=5;
end;

procedure TSharewareDlg.BestellBtnClick(Sender: TObject);
begin
  //WinExec('wordpad.exe',SW_SHOWNORMAL);
end;



procedure TSharewareDlg.RegistrierBtnClick(Sender: TObject);
begin
  RegisterDlg.ShowModal
end;

end.
