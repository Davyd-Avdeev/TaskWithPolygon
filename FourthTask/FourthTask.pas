unit FourthTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,System.Math, System.Types, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TTriangle = record
    Nodes: array[0..2] of Tpoint;
  end;
  TEdge = record
    Nodes: array[0..1] of TPoint;
    Triangles: array[0..1] of TTriangle;
  end;

  TForm4 = class(TForm)
    Button1: TButton;
    procedure CreateRegion();
    procedure FormPaint(Sender: TObject);
    procedure SortArray();
    procedure Button1Click(Sender: TObject);
    procedure CreateOuterShell();
    procedure Triangulition();

    function IsInsideTriangle(p: TPointF; triangle: TTriangle): Boolean;
    function CheckAreaTriangle(a,b,p: TPointF): Real;
    function IsOnEdge(a, b, p: TPointF): Boolean;
    function LeftTurn(a,b,p: TPointF): Boolean;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;
  pointsArray, shellPoints, pointsOutside: array of TPoint;
  TrianglesArray: array of TTriangle;
  EdgesArray: array of TEdge;
  countOfArray, cpIndex: Integer;
  cc:Tpoint;
  isRgnCreated: Boolean;

implementation

{$R *.dfm}

procedure TForm4.FormCreate(Sender: TObject);
var
  x,y: Integer;
begin
  form4.height:= 800;
  form4.Width:= 1000;
  Form4.Position:=poScreenCenter;
    y:= (Height - button1.Height) - 100;
    x:= (Width - button1.Width) - 80;
   button1.Top := y;
   button1.Left:= x;
end;

function TForm4.LeftTurn(a,b,p: TPointF): Boolean;
begin
  Exit((((p.X-a.X) * (b.Y-a.Y)) - ((p.Y-a.Y) * (b.X-a.X))) > 0);
end;

procedure TForm4.FormPaint(Sender: TObject);
begin
  //CreateRegion(pointsArray);

end;

procedure TForm4.Button1Click(Sender: TObject);
var
  i: Integer;
  p: TPoint;
  triangle: TTriangle;
begin
  SetLength(pointsArray,20);
  for i := 0 to Length(pointsArray)-1 do
  begin
    p:= Point(Random(900),Random(700));
    pointsArray[i] := p;
  end;

  SortArray();
  CreateOuterShell();
end;

procedure TForm4.CreateRegion();
var
  i,j: Integer;
begin
  Canvas.Brush.Color := clRed;
  Canvas.FillRect(ClientRect);
  PatBlt(Canvas.Handle, 0, 0, ClientWidth, ClientHeight, WHITENESS);



  for I := 0 to Length(TrianglesArray)-1 do
  begin
    for j := 0 to 1 do
    begin
      Canvas.MoveTo(TrianglesArray[i].Nodes[j].X,TrianglesArray[i].Nodes[j].Y);
      Canvas.LineTo(TrianglesArray[i].Nodes[j+1].X,TrianglesArray[i].Nodes[j+1].Y);
    end;
    Canvas.MoveTo(TrianglesArray[i].Nodes[2].X,TrianglesArray[i].Nodes[2].Y);
    Canvas.LineTo(TrianglesArray[i].Nodes[0].X,TrianglesArray[i].Nodes[0].Y);
    //ShowMessage('');
  end;
  //ShowMessage('');
  {Canvas.Brush.Color := clRed;
  for I := 0 to Length(PointsArray)-1 do
    Canvas.Ellipse(PointsArray[i].X -4, PointsArray[i].Y-4, PointsArray[i].X+4, PointsArray[i].Y+4);}

    {Canvas.Pen.Color := clRed;
    Canvas.MoveTo(EdgesArray[8].Triangles[0].Nodes[0].X,EdgesArray[8].Triangles[0].Nodes[0].Y);
    Canvas.LineTo(EdgesArray[8].Triangles[0].Nodes[1].X,EdgesArray[8].Triangles[0].Nodes[1].Y);
    Canvas.MoveTo(EdgesArray[8].Triangles[0].Nodes[1].X,EdgesArray[8].Triangles[0].Nodes[1].Y);
    Canvas.LineTo(EdgesArray[8].Triangles[0].Nodes[2].X,EdgesArray[8].Triangles[0].Nodes[2].Y);
    Canvas.MoveTo(EdgesArray[8].Triangles[0].Nodes[2].X,EdgesArray[8].Triangles[0].Nodes[2].Y);
    Canvas.LineTo(EdgesArray[8].Triangles[0].Nodes[0].X,EdgesArray[8].Triangles[0].Nodes[0].Y);

    Canvas.MoveTo(EdgesArray[8].Triangles[1].Nodes[0].X,EdgesArray[8].Triangles[1].Nodes[0].Y);
    Canvas.LineTo(EdgesArray[8].Triangles[1].Nodes[1].X,EdgesArray[8].Triangles[1].Nodes[1].Y);
    Canvas.MoveTo(EdgesArray[8].Triangles[1].Nodes[1].X,EdgesArray[8].Triangles[1].Nodes[1].Y);
    Canvas.LineTo(EdgesArray[8].Triangles[1].Nodes[2].X,EdgesArray[8].Triangles[1].Nodes[2].Y);
    Canvas.MoveTo(EdgesArray[8].Triangles[1].Nodes[2].X,EdgesArray[8].Triangles[1].Nodes[2].Y);
    Canvas.LineTo(EdgesArray[8].Triangles[1].Nodes[0].X,EdgesArray[8].Triangles[1].Nodes[0].Y);

    Canvas.Pen.Color := clYellow;
    Canvas.Brush.Color := clYellow;
    Canvas.Ellipse(EdgesArray[8].Triangles[1].Nodes[1].X -4,
    EdgesArray[8].Triangles[1].Nodes[1].Y-4, EdgesArray[8].Triangles[1].Nodes[1].X+4,
    EdgesArray[8].Triangles[1].Nodes[1].Y+4);    }
end;

procedure TForm4.Triangulition();
var
  i, j, k, m, sign, pointIndex:Integer;
  isPointFind, test: Boolean;
  edge: TEdge;
  triangle: TTriangle;
begin
 //
  sign := 1;
  isPointFind := False;
  k:= (Length(pointsArray)-1) div 2;
  for i := 0 to k-1 do
  begin
    m:= i * sign;
    sign:= sign * -1;
    test:= true;
    for j := 0 to Length(shellPoints)-1 do
    begin
      if(pointsArray[k + m] = shellPoints[j]) then
      begin
      test:= False;
      break;
      end;
    end;
    if (test) then
    begin
      pointIndex := k + m;
      break;
    end;
  end;
  cpIndex:= pointIndex; //Нашли центральную точку

  SetLength(TrianglesArray, 1);
  TrianglesArray[0].Nodes[0] := shellPoints[0];
  TrianglesArray[0].Nodes[1] := shellPoints[1];
  TrianglesArray[0].Nodes[2] := pointsArray[cpIndex];

  SetLength(EdgesArray, 1);
  EdgesArray[0].Nodes[0] := shellPoints[1];
  EdgesArray[0].Nodes[1] := pointsArray[cpIndex];
  EdgesArray[0].Triangles[0] := TrianglesArray[0];

  for I := 1 to Length(shellPoints)-2 do
  begin
    SetLength(TrianglesArray, Length(TrianglesArray)+1);
    TrianglesArray[i].Nodes[0] := shellPoints[i];
    TrianglesArray[i].Nodes[1] := shellPoints[i+1];
    TrianglesArray[i].Nodes[2] := pointsArray[cpIndex];
    SetLength(EdgesArray, Length(EdgesArray)+1);
    EdgesArray[i-1].Triangles[0] := TrianglesArray[i];

    EdgesArray[Length(EdgesArray)-1].Nodes[0] := shellPoints[i+1];
    EdgesArray[Length(EdgesArray)-1].Nodes[1] := pointsArray[cpIndex];
    EdgesArray[Length(EdgesArray)-1].Triangles[0] := TrianglesArray[i];
  end;

  SetLength(TrianglesArray, Length(TrianglesArray)+1);
  TrianglesArray[Length(TrianglesArray)-1].Nodes[0] := shellPoints[Length(shellPoints)-1];
  TrianglesArray[Length(TrianglesArray)-1].Nodes[1] := shellPoints[0];
  TrianglesArray[Length(TrianglesArray)-1].Nodes[2] := pointsArray[cpIndex];

  EdgesArray[Length(EdgesArray)-1].Triangles[1] := TrianglesArray[Length(TrianglesArray)-1];

  SetLength(EdgesArray, Length(EdgesArray)+1);
  EdgesArray[Length(EdgesArray)-1].Nodes[0] := shellPoints[0];
  EdgesArray[Length(EdgesArray)-1].Nodes[1] := pointsArray[cpIndex];
  EdgesArray[Length(EdgesArray)-1].Triangles[0] := TrianglesArray[Length(TrianglesArray)-1];
  EdgesArray[Length(EdgesArray)-1].Triangles[1] := TrianglesArray[0];

  //Находим все точки не попавшие в 'триангуляцию' и добавляем в массив
  for I := 0 to Length(pointsArray)-1 do
  begin
    test:=true;
    for j := 0 to Length(shellPoints)-1 do
    begin
      if(pointsArray[i] = shellPoints[j]) then
      begin
      test:= false;
      break;
      end;
    end;
    if(test)Then
    begin
      SetLength(pointsOutside, Length(pointsOutside)+1);
      pointsOutside[Length(pointsOutside)-1]:= pointsArray[i];
    end;

  end; //Закончили

  for i := 0 to Length(pointsOutside)-1 do
  begin
    for j := 0 to Length(TrianglesArray)-1 do
    begin
      if(IsInsideTriangle(pointsOutside[i], TrianglesArray[j]))then
      begin
        if((IsOnEdge(TrianglesArray[j].Nodes[0],TrianglesArray[j].Nodes[1],TrianglesArray[j].Nodes[2]))
          And (IsOnEdge(TrianglesArray[j].Nodes[1],TrianglesArray[j].Nodes[2],TrianglesArray[j].Nodes[0]))
          And (IsOnEdge(TrianglesArray[j].Nodes[2],TrianglesArray[j].Nodes[0],TrianglesArray[j].Nodes[1])))then
        begin
          SetLength(TrianglesArray, Length(TrianglesArray)+1);
          triangle.Nodes[0]:= TrianglesArray[j].Nodes[0];
          triangle.Nodes[1]:= TrianglesArray[j].Nodes[1];
          triangle.Nodes[2]:= pointsOutside[i];
          TrianglesArray[Length(TrianglesArray)-1] := triangle;

          triangle.Nodes[0]:= TrianglesArray[j].Nodes[1];
          triangle.Nodes[1]:= TrianglesArray[j].Nodes[2];
          triangle.Nodes[2]:= pointsOutside[i];
          TrianglesArray[j] := triangle;
        end
        else
        begin
          //Строим 3 треугольника
          for k := 0 to 1 do
          begin
            triangle.Nodes[0]:= TrianglesArray[j].Nodes[k];
            triangle.Nodes[1]:= TrianglesArray[j].Nodes[k+1];
            triangle.Nodes[2]:= pointsOutside[i];
            SetLength(TrianglesArray, Length(TrianglesArray)+1);
            TrianglesArray[Length(TrianglesArray)-1] := triangle;
          end;
          triangle.Nodes[0]:= TrianglesArray[j].Nodes[2];
          triangle.Nodes[1]:= TrianglesArray[j].Nodes[0];
          triangle.Nodes[2]:= pointsOutside[i];
          TrianglesArray[j] := triangle;
        end;
      end;
    end;
  end;

  CreateRegion();
end;

procedure SortAngles();
var
  i: Integer;
  sA,sB : real;
begin
  for I := 0 to Length(EdgesArray)-1 do
  begin

  end;
end;

procedure CheckForComplianceWithDelone();
var
  i: Integer;
begin
  //
end;

procedure TForm4.SortArray();
var
  min,i,j,k,f,m,n: Integer;
  temp: TPoint;
  count: Integer;
begin
  for I := 0 to Length(pointsArray)-1 do
  begin
    for j := i+1 to Length(pointsArray)-1 do
    begin
      if(pointsArray[j].X < pointsArray[i].X)then
     begin
        temp := pointsArray[i];
        pointsArray[i] := pointsArray[j];
        pointsArray[j] := temp;
      end;
    end;
  end;

  j:= 1;
  k:= 0;
  f:= 0;
  for I := 0 to Length(pointsArray)-2 do
  begin
    if((pointsArray[i].X <> pointsArray[i+1].X) or (i+2 = Length(pointsArray))) then
    begin
      if (i+2 = Length(pointsArray)) then
        m:= i+1
      else
        m:= i;
      for k := f to m do
      begin
        for j := k+1 to m do
        begin
          if(pointsArray[j].Y < pointsArray[k].Y)then
          begin
            temp := pointsArray[k];
            pointsArray[k] := pointsArray[j];
            pointsArray[j] := temp;
          end;
        end;
      end;
      f:= i+1;
    end;
  end;
end;

procedure TForm4.CreateOuterShell();
var
  i,curI: Integer;
  endpoint, pointOnHull : TPoint;
begin
  pointOnHull:= pointsArray[0];
  curI:=0;
  repeat
    SetLength(shellPoints,Length(shellPoints)+1);
    shellPoints[curI]:= pointOnHull;
    endpoint:= pointsArray[0];
  for i := 0 to Length(pointsArray)-1 do
  begin
    if (endpoint = pointOnHull) or (LeftTurn(shellPoints[curI], endpoint, pointsArray[i])) then
      endpoint := pointsArray[i];
  end;
    curI:= curI + 1;
    pointOnHull := endpoint;
  until endpoint = pointsArray[0];

  Triangulition();
end;

function TForm4.IsInsideTriangle(p: TPointF; triangle: TTriangle): Boolean;
var
  i: Integer;
  sumArea, polygonArea: Real;
begin
  polygonArea := CheckAreaTriangle(triangle.Nodes[0],triangle.Nodes[1],triangle.Nodes[2]);
  sumArea:= 0;
  for i := 0 to 2 do
  begin
    if (i = 2) then
      sumArea := sumArea + abs(CheckAreaTriangle(triangle.Nodes[i],triangle.Nodes[0], p))
    else
      sumArea := sumArea + abs(CheckAreaTriangle(triangle.Nodes[i],triangle.Nodes[i+1], p));
  end;

  if(FloatToStr(sumArea) = FloatToStr(polygonArea)) then
    Exit(True)
  else
    Exit(False);
end;

function TForm4.CheckAreaTriangle(a,b,p: TPointF): Real;
var
  S: Real;
begin
  S:= ((a.X-p.X)*(b.Y-p.Y)-(a.Y-p.Y)*(b.X-p.X)) / 2;
  Exit(S);
end;

function TForm4.IsOnEdge(a, b, p: TPointF): Boolean;
var
  ABLength, APLength, BPLength: Real;
  isOnLine:Boolean;
begin
  isOnLine := false;

  if(b.X - a.X = 0) then
    if(p.X = a.X)then
      Exit(True)
    else Exit(False);
  if (b.Y - a.Y = 0) then
    if(p.Y = a.Y) then
      Exit(True)
    else Exit(False);

  isOnLine := ((p.X-a.X) / (b.X-a.X)) = ((p.Y - a.Y) / (b.Y - a.Y));;

  if(isOnLine) then
  begin
    ABLength:=sqrt(Power(b.X-a.X,2) + Power(b.Y-a.Y,2));
    APLength:=sqrt(Power(p.X-a.X,2) + Power(p.Y-a.Y,2));
    BPLength:=sqrt(Power(p.X-b.X,2) + Power(p.Y-b.Y,2));
    if(ABLength = APLength + BPLength)then
      Exit(True)
    else
      Exit(False);
  end;

  Exit(False);
end;

end.


