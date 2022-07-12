unit Polig;

{$MODE Delphi}

//Author: Rodrigo Alves Pons 
//email: rodpons@ig.com.br
//webpage: www.geocities.com/rodrigo_alves_pons/
//Version: 2006-12-07
//functions to calculate the area and centroid of a polygon,
//according to the algorithm defined at:
//http://local.wasp.uwa.edu.au/~pbourke/geometry/polyarea/

interface
Uses Math;

type

tRPoints = record
    X:double;
    Y:double;
end;

TGeoData = record
 Area, P, Ix, Iy, Ixy, Ixcg, Iycg, Ixycg, Izz, Izzcg, I1, I2, Theta, WxInf, WxSup, WyInf, WySup, WxMax, WyMax, rx, ry, rxcg, rycg: Double;
 C, fMax, fMin: tRPoints;
end;

function PolygonGeo(Points:Array of tRPoints): TGeoData;

implementation

function PolygonGeo(Points:Array of tRPoints): TGeoData;   // jogar aqui a inclinação
var
  i,j, N:integer;
  Area, Per, Ix, Iy, Ixy, Ixcg, Iycg, Ixycg, rx, ry, rxcg, rycg, Izz, Izzcg, I1, I2, Theta, ai, Max_X, Max_Y, Min_X, Min_Y, dx, dy, P: Double;
  C:tRPoints;
begin
  area:=0;
  C.X := 0;
  C.Y := 0;
  N:= Length(Points);
  Ix:= 0;
  Iy:=0;
  Ixy:=0;
  Max_X:= 0; Max_Y:= 0;
  Min_X:= 0; Min_Y:= 0;
  Per:= 0;
  dx:= 0; dy:= 0;

  For i:= 0 to N-1 do
  begin
    j:=(i + 1) mod N;
    area := area + (Points[i].X * Points[j].Y - Points[j].X * Points[i].Y)/2;
    ai:= Points[i].X*Points[j].Y-Points[j].X*Points[i].Y;
    Ix:= Ix + (Sqr(Points[i].Y)+Points[i].Y*Points[j].Y+Sqr(Points[j].Y))*ai/12;
    Iy:= Iy + (Sqr(Points[i].x)+Points[i].X*Points[j].X+Sqr(Points[j].X))*ai/12;
    Ixy:= Ixy + (Points[i].X*Points[j].Y+2*Points[i].X*Points[i].Y+2*Points[j].X*Points[j].Y+Points[j].X*Points[i].Y)*ai/24;
    P:= Points[i].X * Points[j].Y - Points[j].X * Points[i].Y;
    C.X := C.X + (Points[i].X + Points[j].X) * P;
    C.Y := C.Y + (Points[i].Y + Points[j].Y) * P;

    Max_X:= Max(Points[i].X, Max_X);
    Max_Y:= Max(Points[i].Y, Max_Y);
    Min_X:= Min(Points[i].X, Min_X);
    Min_Y:= Min(Points[i].Y, Min_Y);

    dx:= Abs(Points[j].X-Points[i].X);
    dy:= Abs(Points[j].Y-Points[i].Y);
    Per:= Per+Sqrt(Sqr(dx)+Sqr(dy));
  end;

  C.X := C.X / (6 * area);
  C.Y := C.Y / (6 * area);
  Area:= Area;
  Ixcg:= Ix-Sqr(C.Y)*Area;
  Iycg:= Iy-Sqr(C.X)*Area;
  Ixycg:= Ixy - C.X*C.Y*Area;
  Izz:= Ix+Iy;
  Izzcg:= Ixcg+Iycg;
  rx:= Sqrt(Ix/Area);
  ry:= Sqrt(Iy/Area);
  rxcg:= Sqrt(Ixcg/Area);
  rycg:= Sqrt(Iycg/Area);
  I1:= (Ixcg+Iycg)/2 + Sqrt(Sqr((Ixcg-Iycg)/2)+sqr(Ixycg));
  I2:= (Ixcg+Iycg)/2 - Sqrt(Sqr((Ixcg-Iycg)/2)+sqr(Ixycg));
  if (Ixcg-Iycg) <> 0 then Theta:= 57.295779513 * (ArcTan(2*Ixycg/(Ixcg-Iycg))/2)
                      else Theta:= 0;

  Result.Area:= Abs(Area);
  Result.P:= Per;
  Result.Ix:= Ix;
  Result.Iy:= Iy;
  Result.Ixy:= Ixy;
  Result.Ixcg:= Ixcg;
  Result.Iycg:= Iycg;
  Result.Ixycg:= Ixycg;
  Result.Izz:= Izz;
  Result.Izzcg:= Izzcg;
  Result.rx:= rx;
  Result.ry:= ry;
  Result.rxcg:= rxcg;
  Result.rycg:= rycg;
  Result.I1:= Max(Abs(I1),Abs(I2));
  Result.I2:= Min(Abs(I1),Abs(I2));
  Result.Theta:= Theta;
  Result.C.X:= C.X;
  Result.C.Y:= C.Y;
  Result.fMax.X:= Max_X;
  Result.fMax.Y:= Max_Y;
  Result.fMin.X:= Min_X;
  Result.fMin.Y:= Min_Y;

  Result.WxInf:= Result.Ix/Abs(Result.C.Y-Result.fMin.Y);
  Result.WxSup:= Result.Ix/Abs(Result.fMax.Y-Result.C.Y);
  Result.WxMax:= Max(Result.WxInf,Result.WxSup);//Result.Ix/Max(Abs(Result.C.Y-Result.fMin.Y),Abs(Result.fMax.Y-Result.C.Y));
  Result.WyInf:= Result.Iy/Abs(Result.C.X-Result.fMin.X);
  Result.WySup:= Result.Iy/Abs(Result.fMax.X-Result.C.X);
  Result.WyMax:= Max(Result.WyInf, Result.WySup);//Result.Iy/Max(Abs(Result.C.X-Result.fMin.X),Abs(Result.fMax.X-Result.C.X));
end;
end.