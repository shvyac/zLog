unit UARRLDXScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Grids, StdCtrls, ExtCtrls, UzLogGlobal, Buttons;

type
  TARRLDXScore = class(TBasicScore)
    Grid: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Renew; override;
    procedure Reset; override;
    procedure AddNoUpdate(var aQSO : TQSO);  override;
    procedure Update; override;
    procedure CalcPoints(var aQSO : TQSO); virtual;
  end;

implementation

{$R *.DFM}

procedure TARRLDXScore.Renew;
var
   i: Integer;
   band: TBand;
begin
   Reset;
   for i := 1 to Log.TotalQSO do begin
      band := TQSO(Log.List[i]).QSO.band;
      Inc(QSO[band]);
      Inc(Points[band], TQSO(Log.List[i]).QSO.Points);

      if TQSO(Log.List[i]).QSO.NewMulti1 then begin
         Inc(Multi[band]);
      end;
   end;
end;

procedure TARRLDXScore.Reset;
var
   band: TBand;
begin
   for band := b19 to HiBand do begin
      QSO[band] := 0;
      CWQSO[band] := 0;
      Points[band] := 0;
      Multi[band] := 0;
   end;
end;

procedure TARRLDXScore.CalcPoints(var aQSO: TQSO);
begin
   aQSO.QSO.Points := 3;
end;

procedure TARRLDXScore.FormShow(Sender: TObject);
begin
   inherited;
   Button1.SetFocus;
   Grid.Col := 1;
   Grid.Row := 1;
   CWButton.Visible := False;
end;

procedure TARRLDXScore.AddNoUpdate(var aQSO: TQSO);
begin
   inherited;

   if aQSO.QSO.Dupe then begin
      Exit;
   end;

   CalcPoints(aQSO);
   Inc(Points[aQSO.QSO.band], aQSO.QSO.Points);
end;

procedure TARRLDXScore.Update;
var
   band: TBand;
   TotQSO, TotPts, TotMulti: LongInt;
   row: Integer;
begin
   TotQSO := 0;
   TotPts := 0;
   TotMulti := 0;
   row := 1;

   // ���o���s
   Grid.Cells[0,0] := 'MHz';
   Grid.Cells[1,0] := 'QSOs';
   Grid.Cells[2,0] := 'Points';
   Grid.Cells[3,0] := 'Multi';

   for band := b19 to b28 do begin
      if NotWARC(band) then begin
         TotQSO := TotQSO + QSO[band];
         TotPts := TotPts + Points[band];
         TotMulti := TotMulti + Multi[band];

         Grid.Cells[0, row] := '*' + MHzString[band];
         Grid.Cells[1, row] := IntToStr(QSO[band]);
         Grid.Cells[2, row] := IntToStr(Points[band]);
         Grid.Cells[3, row] := IntToStr(Multi[band]);

         Inc(row);
      end;
   end;

   Grid.Cells[0, 7] := 'Total';
   Grid.Cells[1, 7] := IntToStr3(TotQSO);
   Grid.Cells[2, 7] := IntToStr3(TotPts);
   Grid.Cells[3, 7] := IntToStr3(TotMulti);

   Grid.Cells[0, 8] := 'Score';
   Grid.Cells[1, 8] := '';
   Grid.Cells[2, 8] := '';
   Grid.Cells[3, 8] := IntToStr3(TotPts * TotMulti);

   Grid.ColCount := 4;
   Grid.RowCount := 9;
   ClientWidth := (Grid.DefaultColWidth * Grid.ColCount) + (Grid.ColCount * Grid.GridLineWidth);
   ClientHeight := (Grid.DefaultRowHeight * Grid.RowCount) + (Grid.RowCount * Grid.GridLineWidth) + Panel1.Height + 4;
end;

procedure TARRLDXScore.GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
   strText: string;
begin
   inherited;
   strText := TStringGrid(Sender).Cells[ACol, ARow];

   with TStringGrid(Sender).Canvas do begin
      Brush.Color := TStringGrid(Sender).Color;
      Brush.Style := bsSolid;
      FillRect(Rect);

      Font.Name := '�l�r �S�V�b�N';
      Font.Size := 11;

      if Copy(strText, 1, 1) = '*' then begin
         strText := Copy(strText, 2);
         Font.Color := clBlue;
      end
      else begin
         Font.Color := clBlack;
      end;

      TextRect(Rect, strText, [tfRight,tfVerticalCenter,tfSingleLine]);
   end;
end;

end.
