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

unit Register;

(*
  Berechnung der Registriernummer für Shareware-Version
  Version: 2.0
*)

interface
  uses SysUtils;

  function LicenceOk (SNum, s1, s2, s3: String): Boolean;

implementation
    procedure CountChars(Var pu:String);
    var k, i : Integer;
        pz   : Array [0..3] of Integer;
        ps   : String[20];
        temp : Array [0..255] of char;
    begin
    For k := Length(pu) DownTo 1 do
      If (pu[k] <= #32) or (pu[k] >= #127) then
        Delete(pu, k, 1)                { Alle Leer- und Sonderzeichen raus... }
      else
        pu[k] := UpCase(pu[k]);         { ...alles in Großbuchstaben umwandeln!}

    pz [0] := 19;                       { Startwerte setzen;                   }
    pz [1] := 13;                       {   hier kann der Algorithmus je nach  }
    pz [2] := 39;                       {   Bedarf verschieden initialisiert   }
    pz [3] := 19;                       {   werden. Aber: auf Synchronisation  }
    i      :=  2;                       {   mit dem Word-Makro achten !        }

    For k := 1 to Length(pu) do begin
      pz [i] := (pz [i] + Byte(pu[k])) Mod 100;
        { einfache Prüf"summe" }
      i      :=  pz [i] Mod 4;
      end;
    pu := '';
    For k := 0 to 3 do begin
      Str(pz[k], ps);
      While Length(ps) < 2 do ps := '0' + ps;
      pu := pu + ps;
      end;
    If pu[1] = '0' then Delete(pu, 1, 1);
    StrPCopy(temp,pu);
    end;




function LicenceOk (SNum, s1, s2, s3: String): Boolean;
  var SNr,NNr      : LongInt;
      pu           : String;
      code         : Integer;
  begin
  LicenceOk := False;
  Val (SNum, SNr, code);
  If code = 0 then begin
    pu  := '';
    pu  := s1 + s2 + s3;
    CountChars(pu);
    Val(pu, NNr, code);
    If code = 0 then
      LicenceOk := NNr = SNr;
    end;
  end;
end.
 