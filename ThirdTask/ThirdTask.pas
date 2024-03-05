unit ThirdTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Types, System.Math, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TRealArray = array of array of Real;
  TForm3 = class(TForm)
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CreateRegion();
    procedure TurnFigure(point: TPointF; angle: Real);
    function TransformationMatrix(point, vertex: TPointF; angle: Real): TPointF;
    function MultiplicationMatrix(matrixA, matrixB: TRealArray): TRealArray;
    procedure FormPaint(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  pointsArray: array of TPoint;
  countOfArray: Integer;
  isRgnCreated: Boolean;
  rgn: HRGN;
  pointTF: TPoint;

implementation


{$R *.dfm}

procedure TForm3.FormMouseDown(Sender: TObject; Button: TMouseButton;
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
  else

end;

procedure TForm3.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  point: TPoint;
begin
  point.X := Form3.ScreenToClient(Mouse.CursorPos).X;
  point.Y := Form3.ScreenToClient(Mouse.CursorPos).Y;
  if(isRgnCreated = True)then
  begin
    if(WheelDelta > 0) then
      TurnFigure(point, 5)
    else
      TurnFigure(point, -5);
  end;
end;

procedure TForm3.FormPaint(Sender: TObject);
begin
  CreateRegion();
end;

procedure TForm3.TurnFigure(point: TPointF; angle: Real);
var
  i: Integer;
  pointF: TPointF;
begin
  for I := 0 to Length(pointsArray)-1 do
  begin
    pointF := TransformationMatrix(point, pointsArray[i], angle);
    pointsArray[i].X := Round(pointF.X);
    pointsArray[i].Y := Round(pointF.Y);
  end;

  CreateRegion();
end;

///
///Создание матриц и суммарное преобразование
///point - точка, относительно которой будет поворот
///vertex - вершина фигуры
///angle - угол поворота
///
function TForm3.TransformationMatrix(point, vertex: TPointF; angle: Real): TPointF;
var
  matrix1,matrix2,matrix3,matrix4, matrix5: TRealArray;
begin
  SetLength(matrix1,3,3);

  matrix1[0][0] := 1; matrix1[1][0] := 0; matrix1[2][0] := -point.X;  //1  0  0
  matrix1[0][1] := 0; matrix1[1][1] := 1; matrix1[2][1] := -point.Y;  //0  1  0
  matrix1[0][2] := 0; matrix1[1][2] := 0; matrix1[2][2] := 1;        //-X -Y  1

  SetLength(matrix2,3,3);

  matrix2[0][0] := Cos(angle * PI/180); // cos sin 0
  matrix2[0][1] := Sin(angle * PI/180); //-sin cos 0
  matrix2[0][2] := 0;                   //  0   0  1

  matrix2[1][0] := -Sin(angle * PI/180); matrix2[2][0] := 0;
  matrix2[1][1] := Cos(angle * PI/180);  matrix2[2][1] := 0;
  matrix2[1][2] := 0;                    matrix2[2][2] := 1;

  SetLength(matrix3,3,3);

  matrix3[0][0] := 1; matrix3[1][0] := 0; matrix3[2][0] := point.X; //1 0 0
  matrix3[0][1] := 0; matrix3[1][1] := 1; matrix3[2][1] := point.Y; //0 1 0
  matrix3[0][2] := 0; matrix3[1][2] := 0; matrix3[2][2] := 1;       //X Y 1

  SetLength(matrix4,1,3);

  matrix4[0][0] := vertex.X; matrix4[0][1] := vertex.Y; matrix4[0][2] := 1; //X Y 1

  SetLength(matrix5,3,3);

  matrix5 := MultiplicationMatrix(matrix4, MultiplicationMatrix(MultiplicationMatrix(matrix1, matrix2), matrix3));
  point.X := matrix5[0][0];
  point.Y := matrix5[0][1];

  Exit(point);
End;

procedure TForm3.CreateRegion();
var
  i: Integer;
begin
  Form3.Canvas.Brush.Color := clRed;
  Form3.Canvas.FillRect(Form3.ClientRect);
  PatBlt(Form3.Canvas.Handle, 0, 0, Form3.ClientWidth, Form3.ClientHeight, WHITENESS);

  Canvas.Polygon(pointsArray);
end;

function TForm3.MultiplicationMatrix(matrixA, matrixB: TRealArray): TRealArray;
var
  i,j,r: Integer;
  matrixC: TRealArray;
begin
  SetLength(matrixC, Length(matrixA),Length(matrixA[0]));

  for i := 0 to Length(matrixA)-1 do
  begin
    for j := 0 to Length(matrixB)-1 do
    begin
    matrixC[i][j] := 0;
      for r := 0 to Length(matrixB)-1 do
      begin
        matrixC[i][j] := matrixC[i][j] + matrixA[i][r] * matrixB[r][j];
      end;
    end;
  end;

  Exit(matrixC);
end;

end.
