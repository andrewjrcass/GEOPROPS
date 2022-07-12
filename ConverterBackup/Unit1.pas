unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, Grids, Polig, ExtCtrls, Buttons, Math, ComCtrls,
  Menus, UAbout;
const
   crMyDragCursor = 5;
   PIDiv180 = 0.017453292519943295769236907684886;


type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Grid: TStringGrid;
    Splitter1: TSplitter;
    Panel2: TPanel;
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    btnCalcula: TButton;
    Panel3: TPanel;
    memo: TMemo;
    Splitter2: TSplitter;
    View: TPaintBox;
    ControlBar1: TControlBar;
    dlgSave: TSaveDialog;
    dlgOpen: TOpenDialog;
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    Abre1: TMenuItem;
    Salva1: TMenuItem;
    Sobre1: TMenuItem;
    Vista1: TMenuItem;
    Zomm1: TMenuItem;
    Zoom1: TMenuItem;
    ZoomFit1: TMenuItem;
    Panel4: TPanel;
    SpeedButton3: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton5: TSpeedButton;
    Panel5: TPanel;
    SpeedButton9: TSpeedButton;
    SpeedButton8: TSpeedButton;
    lblScale: TLabel;
    SpeedButton11: TSpeedButton;
    btnNew: TSpeedButton;
    edtUnit: TEdit;
    lbl1: TLabel;
    pnl1: TPanel;
    seFix: TSpinEdit;
    lbl2: TLabel;
    procedure SpinEdit1Change(Sender: TObject);
    procedure btnCalculaClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ViewPaint(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ViewMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SpeedButton10Click(Sender: TObject);
    procedure ViewDblClick(Sender: TObject);
    procedure ViewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Sobre1Click(Sender: TObject);
    procedure Zomm1Click(Sender: TObject);
    procedure Zoom1Click(Sender: TObject);
    procedure ZoomFit1Click(Sender: TObject);
    procedure Abre1Click(Sender: TObject);
    procedure Salva1Click(Sender: TObject);
    procedure SpeedButton11Click(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ViewClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure seFixChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure PaintShape;
    procedure Calcula;
    procedure BestFit;
    procedure SetBase;
    procedure Scale_Up;
    procedure Scale_Down;
    procedure ClearView;
    procedure ShowData;
    procedure ShowResults;
    procedure GetFromGrid;
    function getUnit: string;
    function getFixStr: string;
  end;

var
  Form1: TForm1;
  Pontos: array of TRPoints;

  //scale: Double;
  dx, dy, iFix: Integer;
  Geo: TGeoData;
  pMax, pMin: tRPoints;
  fStartDrag, fEndDrag, Base: TPoint;
  Drawing, Draging: Boolean;
  Scale: Real;
  sUnit, sFixStr: string[10];
implementation

{$R *.dfm}
{$R Cursor.res}

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
  Grid.RowCount:= SpinEdit1.Value+1;
end;

procedure TForm1.btnCalculaClick(Sender: TObject);
begin
 try
  ShowData;
  Calcula;
  ShowResults;
  Drawing:= True;
  //BestFit;
  PaintShape;
  except
    ShowMessage('Dados com erro ou inexistentes!');
  end;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
    SpinEdit1.Value:=1;
    seFix.Value:= 16;
    sUnit:= '';
    Grid.Cells[0,0]:= 'Point';
    Grid.Cells[1,0]:= 'X';
    Grid.Cells[2,0]:= 'Y';
    Scale:= 1;
    dx:= 1; dy:= 1;
    Drawing:= False;
    Base:= Point(0,0);
    Grid.ColWidths[0]:=40;
    Screen.Cursors[crMyDragCursor]:= LoadCursor(HInstance,'CURSORDRAG');
end;

procedure TForm1.PaintShape;
var
i, nPontos: Integer;
iPontos: array of TPoint;
MaxP, MinP: TPoint;

  procedure DrawPolig;
  var
   i: Integer;
  begin
   View.Canvas.Pen.Color:= clYellow;
   View.Canvas.Brush.Color := clTeal;
   View.Canvas.Brush.Style:= bsFDiagonal;

   if Draging then
      View.Canvas.Polyline(iPontos)
   else
      View.Canvas.Polygon(iPontos);

   View.Canvas.Font.Color:= View.Canvas.Pen.Color;
   View.Canvas.Font.Size:= 10;
   View.Canvas.Font.Style:= [];

   View.Canvas.Font.Color:= clAqua;
   For i:= 0 to nPontos -1 do begin
       if (Pontos[i].X =0) and (Pontos[i].Y=0) then
            View.Canvas.Font.Color:= $42C2F5
       else View.Canvas.Font.Color:= clAqua;
       View.Canvas.TextOut(iPontos[i].X+3, iPontos[i].Y, 'P('+IntToStr(i+1)+')');
   end;
  // CG Cross
  View.Canvas.Pen.Color:= clLime;
  View.Canvas.Font.Color:= clLime;
  View.Canvas.Font.Style:= [fsBold];
  View.Canvas.Polyline([Point(Round(Geo.C.X*Scale)+5+dx,-Round(Geo.C.Y*Scale)+dy),
                       Point(Round(Geo.C.X*Scale)-5+dx,-Round(Geo.C.Y*Scale)+dy)]);
  View.Canvas.Polyline([Point(Round(Geo.C.X*Scale)+dx, -Round(Geo.C.Y*Scale)+5+dy),
                       Point(Round(Geo.C.X*Scale)+dx, -Round(Geo.C.Y*Scale)-5+dy)]);

  if (Round(Geo.C.X) =0) and (Round(Geo.C.Y)=0) then
            View.Canvas.Font.Color:= $42C2F5
       else View.Canvas.Font.Color:= clLime;
  View.Canvas.TextOut(Round(Geo.C.X*Scale)+dx+3, -Round(Geo.C.Y*Scale)+dy+3,
                      'CG: '+ FormatFloat('(0.00',Geo.C.X)+', '+FormatFloat('0.00)',Geo.C.Y));
  //Origin Marker
  View.Canvas.Pen.Color:= $42C2F5;//F5C242;
  View.Canvas.Polyline([Point(0+5+dx,-0+dy),
                       Point(0-5+dx,0+dy)]);
  View.Canvas.Polyline([Point(0+dx, 0+5+dy),
                       Point(0+dx, 0-5+dy)]);
  end;


begin
 // i:=0;
  if not Drawing then Exit;

  nPontos:= Length(Pontos);
  SetLength(iPontos, nPontos+1);
  lblScale.Caption:= 'Scale:= '+FormatFloat('0.00',Scale);

  For i:= 0 to nPontos -1 do begin
      iPontos[i].X:=+Round(Pontos[i].X*Scale)+dx;
      iPontos[i].Y:=-Round(Pontos[i].Y*Scale)+dy;
  end;
  iPontos[i]:= ipontos[0];

  ClearView;
  DrawPolig;
end;

procedure TForm1.ViewPaint(Sender: TObject);
begin
 if not Drawing then
    ClearView
 else
    PaintShape;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  Dec(dx,5);
  PaintShape;
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
  Inc(dx,5);
  PaintShape;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
 Dec(dy,5);
 PaintShape;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
 Inc(dy,5);
 PaintShape;
end;

procedure TForm1.SpeedButton5Click(Sender: TObject);
begin
Scale_Up;
end;

procedure TForm1.SpeedButton6Click(Sender: TObject);
begin
Scale_Down
end;

procedure TForm1.SpeedButton7Click(Sender: TObject);
begin
  Scale:= 1;
  SetBase;
  PaintShape;
end;

procedure TForm1.SpeedButton8Click(Sender: TObject);
var
  f: TextFile;
  i,n: Integer;
begin
 i:=0;
 if dlgOpen.Execute then begin
    AssignFile(f, dlgOpen.FileName);
    Reset(f);
    Readln(f, iFix);
    seFix.Value:= iFix;
    readln(f, sUnit);
    edtUnit.Text:= sUnit;
     while not Eof(f) do begin
       SetLength(Pontos, i+1);
       Readln(f, Pontos[i].X, Pontos[i].Y);
       inc(i);
     end;
     
    CloseFile(f);
    SpinEdit1.Value:= Length(Pontos);
    for i:= 1 to Length(Pontos) do begin
        Grid.Cells[1,i]:= FloatToStr(Pontos[i-1].X);
        Grid.Cells[2,i]:= FloatToStr(Pontos[i-1].Y);
    end;

    Scale:= 1;
    ShowData;
    Calcula;
    Drawing:= True;
    BestFit;
    PaintShape;
    ShowResults;
    Panel3.SetFocus;
 end;
end;

procedure TForm1.Calcula;
begin
 Geo:= PolygonGeo(Pontos);
end;

procedure TForm1.SpeedButton9Click(Sender: TObject);
var
f: TextFile;
i: Integer;
begin
  if Length(Pontos) >= 3 then
     if dlgSave.Execute then begin
        AssignFile(f, dlgSave.FileName);
        Rewrite(f);
        Writeln(f, iFix);
        Writeln(f, edtUnit.text);
         For i:= 0 to Length(Pontos)-1 do begin
             Writeln(f, Pontos[i].X, ' ',Pontos[i].Y);
         end;
        CloseFile(f);
     end;
end;

procedure TForm1.ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Shift = [ssLeft] then begin
     fStartDrag:= Point(X,Y);
     Screen.Cursor:= crMyDragCursor;
  end;
end;

procedure TForm1.ViewMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
 var
  i: Integer;
begin
  Base:= Point(X,Y);
  Form1.SetFocus;
  if (Shift = [ssLeft]) then begin
     Draging:= True;
     fEndDrag:= Point(X,Y);
     dx:= dx + Round((fEndDrag.X-fStartDrag.X));
     dy:= dy + Round((fEndDrag.y-fStartDrag.y));
     fStartDrag:= fEndDrag;
     PaintShape;
  end;
end;

procedure TForm1.BestFit;
var
  v, vX, vY: Real;
begin
 if ((Geo.fMax.X-Geo.fMin.X)<>0) or ((Geo.fMax.Y-Geo.fMin.Y)<>0) then begin
  dx:= 1; dy:= 1;
  Vx:= (View.Width-20)/(Geo.fMax.X-Geo.fMin.X);
  Vy:= (View.Height-5)/(Geo.fMax.Y-Geo.fMin.Y);
  v:= Min(vx,vy);
  Scale:= v;
  SetBase;
 end;
end;

procedure TForm1.SetBase;
begin
 dx:= Round(Abs(Geo.fMin.X*Scale));
 dy:= Round(Abs(Geo.fMax.Y*Scale))+1;
end;

procedure TForm1.SpeedButton10Click(Sender: TObject);
begin
  BestFit;
  PaintShape;
end;

procedure TForm1.Scale_Down;
begin
  Scale:= Scale*0.9;
  PaintShape;
end;

procedure TForm1.Scale_Up;
begin
  Scale:= Scale*1.1;
  PaintShape;
end;

procedure TForm1.ViewDblClick(Sender: TObject);
begin
  BestFit;
end;

procedure TForm1.ClearView;
begin
  View.Canvas.Pen.Color:= clBlack;
  View.Canvas.Brush.Style:= bsSolid;
  View.Canvas.Brush.Color := clBlack;
  View.Canvas.FillRect(View.Canvas.ClipRect);
end;

procedure TForm1.ViewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   Screen.Cursor:= crDefault;
   Draging:= False;
   PaintShape;
end;

procedure TForm1.Sobre1Click(Sender: TObject);
begin
   frmAbout.ShowModal;
end;



procedure TForm1.ShowData;
var
  i, nPontos: Word;
begin
 sUnit:= getUnit;
 iFix:= seFix.Value;
 sFixStr:= getFixStr;
 nPontos:= SpinEdit1.Value;
 SetLength(Pontos, nPontos);
 memo.Clear;
 memo.Lines.Add('****** Begin ******');
 memo.Lines.Add('****** Polygon data ******');
 For i:= 0 to nPontos-1 do begin
     Pontos[i].X:= StrToFloat(Grid.Cells[1,i+1]);
     Pontos[i].Y:= StrToFloat(Grid.Cells[2,i+1]);
     Grid.Cells[0,i+1]:= IntToStr(i+1);
     memo.Lines.Add('Read: '+Grid.Cells[1,i+1]+sUnit+', '+Grid.Cells[2,i+1]+ sUnit);
     PMax.X:= Max(Pontos[i].X, pMax.X);
     PMax.Y:= Max(Pontos[i].Y, pMax.Y);
     PMin.X:= Min(Pontos[i].X, pMin.X);
     PMin.Y:= Min(Pontos[i].Y, pMin.Y);
end;
end;

procedure TForm1.ShowResults;
begin
 with Geo do begin
      memo.Lines.Add('****** Geometric parameters ******');
      //memo.Lines.Add('Area: '+FloatToStr(Area)+sUnit+'^2');
      memo.Lines.Add('Area: ' + Format(sFixStr, [Area])+ sUnit +'^2');
      //memo.Lines.Add('Perimeter: '+FloatToStr(P)+ sUnit);
      memo.Lines.Add('Perimeter: ' + Format(sFixStr, [P])+ sUnit);
      //memo.Lines.Add(Format('CG: (%8.8n;%8.8n)' + sUnit ,[C.X,C.Y]));
      memo.Lines.Add('X: ' + Format(sFixStr, [C.X])+ sUnit);
      memo.Lines.Add('Y: ' + Format(sFixStr, [C.Y])+ sUnit);
      memo.Lines.Add('****** Results from origin (0,0) coodinates ******');
      //memo.Lines.Add('Ixx: ' + FloatToStr(Ix)+sUnit+'^4');
      memo.Lines.Add('Ixx: ' + Format(sFixStr, [Ix])+ sUnit +'^4');
      //memo.Lines.Add('Iyy: ' + FloatToStr(Iy)+sUnit+'^4');
      memo.Lines.Add('Iyy: ' + Format(sFixStr, [Iy])+ sUnit +'^4');
      //memo.Lines.Add('Ixy: ' + FloatToStr(Ixy)+sUnit+'^4');
      memo.Lines.Add('Ixy: ' + Format(sFixStr, [Ixy])+ sUnit +'^4');
      //memo.Lines.Add('Izz: ' + FloatToStr(Izz)+sUnit+'^4');
      memo.Lines.Add('Izz: ' + Format(sFixStr, [Izz])+ sUnit +'^4');
      //memo.Lines.Add('rx: ' + FloatToStr(rx)+ sUnit);
      memo.Lines.Add('rx: ' + Format(sFixStr, [rx])+ sUnit);
      //memo.Lines.Add('ry: ' + FloatToStr(ry)+sUnit);
      memo.Lines.Add('ry: ' + Format(sFixStr, [ry])+ sUnit);

      memo.Lines.Add('****** Results from centroid ******');
      //memo.Lines.Add('Ixx(cg): ' + FloatToStr(Ixcg)+sUnit+'^4');
      memo.Lines.Add('Ixx (cg): ' + Format(sFixStr, [Ixcg])+ sUnit +'^4');
      //memo.Lines.Add('Iyy(cg): ' + FloatToStr(Iycg)+sUnit+'^4');
      memo.Lines.Add('Iyy (cg): ' + Format(sFixStr, [Iycg])+ sUnit +'^4');
      //memo.Lines.Add('Ixy(cg): ' + FloatToStr(Ixycg)+sUnit+'^4');
      memo.Lines.Add('Ixy (cg): ' + Format(sFixStr, [Ixycg])+ sUnit +'^4');
      //memo.Lines.Add('Izz (cg): ' + FloatToStr(Izzcg)+sUnit+'^4');
      memo.Lines.Add('Izz (cg): ' + Format(sFixStr, [Izzcg])+ sUnit +'^4');
      //memo.Lines.Add('rx(cg): ' + FloatToStr(rxcg)+ sUnit);
      memo.Lines.Add('rx (cg): ' + Format(sFixStr, [rxcg])+ sUnit);
      //memo.Lines.Add('ry(cg): ' + FloatToStr(rycg)+sUnit);
      memo.Lines.Add('ry (cg): ' + Format(sFixStr, [rycg])+ sUnit);

      memo.Lines.Add('****** Principal moments of inertia and axis angle ******');
      //memo.Lines.Add('I1: ' + FloatToStr(I1)+sUnit+'^4');
      memo.Lines.Add('I1 (Imax): ' + Format(sFixStr, [I1])+ sUnit +'^4');
      //memo.Lines.Add('I2: ' + FloatToStr(I2)+sUnit+'^4');
      memo.Lines.Add('I2 (Imin): ' + Format(sFixStr, [I2])+ sUnit +'^4');
      memo.Lines.Add('Theta: ' + Format(sFixStr, [theta])+'° (degrees)');
      //memo.Lines.Add('Theta: ' + FloatToStr(theta)+'° (degrees)');

      memo.Lines.Add('****** Section Modulus ******');
      //memo.Lines.Add('WxSup: ' + FloatToStr(WxSup)+ sUnit+'^3');
      memo.Lines.Add('Wx Sup: ' + Format(sFixStr, [WxSup])+ sUnit +'^3');
      //memo.Lines.Add('WxInf: ' + FloatToStr(WxInf)+ sUnit+'^3');
      memo.Lines.Add('Wx Inf: ' + Format(sFixStr, [WxInf])+ sUnit +'^3');
      //memo.Lines.Add('Wy<-: ' + FloatToStr(WyInf)+ sUnit+'^3');
      memo.Lines.Add('Wy<-: ' + Format(sFixStr, [WyInf])+ sUnit +'^3');
      //memo.Lines.Add('Wy->: ' + FloatToStr(WySup)+ sUnit+'^3');
      memo.Lines.Add('Wy->: ' + Format(sFixStr, [WySup])+ sUnit +'^3');
      //memo.Lines.Add('WxMax: ' + FloatToStr(WxMax)+ sUnit+'^3');
      memo.Lines.Add('Wx Sup: ' + Format(sFixStr, [WxSup])+ sUnit +'^3');
      //memo.Lines.Add('WyMax: ' + FloatToStr(WyMax)+ sUnit+'^3');
      memo.Lines.Add('Wy<-: ' + Format(sFixStr, [WyInf])+ sUnit +'^3');
   end;
 memo.Lines.Add('****** End ******');
end;

procedure TForm1.GetFromGrid;
begin

end;

procedure TForm1.Zomm1Click(Sender: TObject);
begin
  SpeedButton5Click(Self);
end;

procedure TForm1.Zoom1Click(Sender: TObject);
begin
 SpeedButton6Click(Self);
end;

procedure TForm1.ZoomFit1Click(Sender: TObject);
begin
 SpeedButton10Click(Self);
end;

procedure TForm1.Abre1Click(Sender: TObject);
begin
 SpeedButton8Click(Self);
end;

procedure TForm1.Salva1Click(Sender: TObject);
begin
 SpeedButton9Click(Self);
end;

procedure TForm1.SpeedButton11Click(Sender: TObject);
var
   i: Integer;
begin
 if Length(Pontos) > 0 then begin
  for i:= 0 to Length(Pontos)-1 do begin
    Pontos[i].X:= Pontos[i].X-Geo.C.X;
    Pontos[i].Y:= Pontos[i].Y-Geo.C.Y;
  end;

  for i:= 1 to Length(Pontos) do begin
      Grid.Cells[1,i]:= FloatToStr(Pontos[i-1].X);
      Grid.Cells[2,i]:= FloatToStr(Pontos[i-1].Y);
  end;
    Scale:= 1;
    ShowData;
    Calcula;
    Drawing:= True;
    BestFit;
    PaintShape;
    ShowResults;
 end;  
end;

procedure TForm1.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  c: TControl;
begin
 if Panel3.Focused then begin
 if WheelDelta > 0 then
    Scale_Up
 else Scale_Down;
 Handled:= True;
 end else Handled:= False;
end;

procedure TForm1.ViewClick(Sender: TObject);
begin
Panel3.SetFocus;
end;

procedure TForm1.btnNewClick(Sender: TObject);
begin
//New Project
 Grid.RowCount:=2;
 ClearView;
 Activate;
end;

function TForm1.getUnit: string;
var
  s: string;
begin
 s:= Trim(edtUnit.Text);
 if s = '' then Result:= ' (unit)'
           else Result:= ' ('+s+')';
end;

procedure TForm1.seFixChange(Sender: TObject);
begin
 iFix:= seFix.Value;
end;

function TForm1.getFixStr: string;
var
  s: string;
begin
  s:='%.'; //'%.2f'
  s:=s+IntToStr(iFix)+'f';
  Result:= s;
end;

end.
