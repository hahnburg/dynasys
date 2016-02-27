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

unit Info;

{$MODE Delphi}

(*
  Modellinformation mit einem RTF-Editor
  Version: 2.0
  Autor: Walter Hupfeld
  zuletzt bearbeitet:
*)

interface

uses unix, Classes, Graphics, Forms, Controls, Buttons, RichView,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TModellInfo = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    Bevel1: TBevel;
    RichEdit1: TRichView;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure StoreData(W:TWriter);
    procedure ReadData(R:TReader);
    procedure Clear;
  end;

var
  ModellInfo: TModellInfo;

implementation

{$R *.lfm}
     procedure TModellInfo.StoreData(W:TWriter);
     var i:integer;
     begin
       W.WriteFloat(RichEdit1.Lines.Count);
       for i:=0 to RichEdit1.Lines.count-1 do
          W.WriteString(RichEdit1.Lines[i]);
     end;

     procedure TModellInfo.ReadData(R:TReader);
     var i:integer;
         count:integer;
     begin
       self.clear;
       try
         count:=round(R.ReadFloat);
         for i:=0 to count-1 do
            RichEdit1.Lines.Append(R.ReadString);
       except ;
       end;
     end;

     procedure TModellInfo.Clear;
     begin
       RichEdit1.Lines.Clear;
     end;

end.
