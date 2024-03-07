unit FourthTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,System.Math, System.Types, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  {TNode = record
    p: ^TPoint;
  end;
  TTriangle = record
    Nodes: array[0..2] of ^TNode;
  end;
  TEdge = record
    Nodes: array[0..1] of ^TNode;
    Triangles: array[0..1] of ^TTriangle;
  end;
  TStruct = record
    Triangle: ^TTriangle;
    Triangles: array[0..2] of ^TTriangle;
  end;}
  TNode = record
    X: Integer;
    Y: Integer;
  end;
  TEdge = record
    Nodes: array [0..1] of TNode;
  end;
  TTriangle = record
    Center: TPoint;
    Nodes: array [0..2] of TPoint; //TNode
    //Edges: array [0..2] of TEdge;
  end;
  TStructDate = record


  end;

  TForm4 = class(TForm)
    Button1: TButton;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CreateRegion();
    procedure CreateRegion2(arrP: array of TPoint);
    procedure FormPaint(Sender: TObject);
    procedure HalfTriangulition();
    procedure SortArray();
    procedure Button1Click(Sender: TObject);
    procedure CreateOuterShell();
    procedure TwoHalfTriangulation();

    function InsideConvexPolygon(p: TPointF; triangle: TTriangle): Boolean;
    function CheckAreaTriangle(a,b,p: TPointF): Real;
    function CheckOnEdge(a, b, p: TPointF): Boolean;
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
  countOfArray: Integer;
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

procedure TForm4.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  mousePoint: TPoint;
  i: Integer;
begin
  mousePoint.X:=X;
  mousePoint.Y:=Y;
  if (isRgnCreated = false) then
  begin
    if Button=mbLeft then
    begin
      Canvas.Pen.Color:=clred;
      Canvas.Brush.color:=clRed;
      Canvas.Ellipse(mousePoint.X-2,mousePoint.Y-2,mousePoint.X+2,mousePoint.Y+2);
      countOfArray:=countOfArray+1;
      SetLength(pointsArray,countOfArray);
      pointsArray[countOfArray-1].X:= mousePoint.X;
      pointsArray[countOfArray-1].Y:= mousePoint.Y;
    end
    else
    begin
      CreateRegion();
      isRgnCreated := True;
    end;
  end
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

  Canvas.Brush.Color := clRed;
  for I := 0 to Length(PointsArray)-1 do
    Canvas.Ellipse(PointsArray[i].X -4, PointsArray[i].Y-4, PointsArray[i].X+4, PointsArray[i].Y+4);


end;

procedure TForm4.CreateRegion2(arrP: array of TPoint);
var
  I,x1,y1: Integer;
  x,y: Real;
  teamArr: array of TPoint;
begin
  Canvas.Brush.Color := clRed;
  Canvas.FillRect(ClientRect);
  PatBlt(Canvas.Handle, 0, 0, ClientWidth, ClientHeight, WHITENESS);
  SetLength(teamArr,3);

  x:= 0;
  y:= 0;
  for I := 0 to Length(arrP)-1 do
  begin
    x:= x + arrP[i].X;
    y:= y + arrP[i].Y;
  end;

  x1:= Round(x/Length(arrP));
  y1:= Round(y/Length(arrP));

  for i := 0 to Length(arrP)-2 do
  begin
    Canvas.MoveTo(arrP[i].X,arrP[i].Y);
    Canvas.LineTo(arrP[i+1].X,arrP[i+1].Y);
    Canvas.MoveTo(arrP[i].X,arrP[i].Y);
    Canvas.LineTo(cc.X,cc.Y);
  end;
  Canvas.MoveTo(arrP[Length(arrP)-1].X,arrP[Length(arrP)-1].Y);
  Canvas.LineTo(arrP[0].X,arrP[0].Y);
  for I := 0 to Length(PointsArray)-1 do
    Canvas.Ellipse(PointsArray[i].X -4, PointsArray[i].Y-4, PointsArray[i].X+4, PointsArray[i].Y+4);

  Canvas.Brush.Color := clYellow;
  //Canvas.Ellipse(cc.X -4, cc.Y-4, cc.X+4, cc.Y+4);
  //Canvas.MoveTo(arrP[Length(arrP)-1].X,arrP[Length(arrP)-1].Y);
  //Canvas.LineTo(cc.X,cc.X);

end;

procedure TForm4.HalfTriangulition();
var
  i,j,k,m, sign:Integer;
  isPointFind, test: Boolean;
  centerPoint: TPoint;
  triangle: TTriangle;
begin

  for I := 0 to 2 do
  begin
    triangle.Nodes[i] := Point(0,0);
    triangle.Center := Point(0,0);
  end;

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
      centerPoint:= pointsArray[k + m];
      break;
    end;
  end;
  cc:= centerPoint;

  for i := 0 to Length(shellPoints)-2 do
  begin
    triangle.Nodes[0] := shellPoints[i];
    triangle.Nodes[1] := shellPoints[i+1];
    triangle.Nodes[2] := cc; //Change
    SetLength(TrianglesArray, Length(TrianglesArray)+1);
    TrianglesArray[Length(TrianglesArray)-1] := triangle;
  end;

  triangle.Nodes[0] := shellPoints[Length(shellPoints)-1];
  triangle.Nodes[1] := shellPoints[0];
  triangle.Nodes[2] := cc; //Change
  SetLength(TrianglesArray, Length(TrianglesArray)+1);
  TrianglesArray[Length(TrianglesArray)-1] := triangle;
  test:= True;
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
    //pointsOutside
  end;

  //ShowMessage('');
  TwoHalfTriangulation();
end;

procedure TForm4.TwoHalfTriangulation();
var
  i,j,k: Integer;
  triangle: TTriangle;
begin
  for i := 0 to Length(pointsOutside)-1 do
  begin
    for j := 0 to Length(TrianglesArray)-1 do
    begin
      if(InsideConvexPolygon(pointsOutside[i], TrianglesArray[j]))then
      begin
        if((CheckOnEdge(TrianglesArray[j].Nodes[0],TrianglesArray[j].Nodes[1],TrianglesArray[j].Nodes[2]))
          And (CheckOnEdge(TrianglesArray[j].Nodes[1],TrianglesArray[j].Nodes[2],TrianglesArray[j].Nodes[0]))
          And (CheckOnEdge(TrianglesArray[j].Nodes[2],TrianglesArray[j].Nodes[0],TrianglesArray[j].Nodes[1])))then
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

  //ShowMessage('');
  CreateRegion();
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

  HalfTriangulition();
  //CreateRegion2(shellPoints);
end;

function TForm4.InsideConvexPolygon(p: TPointF; triangle: TTriangle): Boolean;
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

function TForm4.CheckOnEdge(a, b, p: TPointF): Boolean;
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


