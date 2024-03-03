unit FirstTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Types;

type
  TForm1 = class(TForm)
    lblInput: TLabel;
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawRectanglesFromArray();
    procedure CheckingCursorInRgn(point: TPoint);
    procedure CreateRegion();
    procedure CheckRegion(mousePoint: TPoint);
    function IsMouseInPoly(x,y: integer; myP: array of TPointF): boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  pointsArray: array of TPoint;
  countOfArray: Integer;
  isRgnCreated: Boolean;
  rgn: HRGN;
  arrayOfPointsF: array of TPointF;


implementation

{$R *.dfm}

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  mousePosition: TPoint;
begin
  if (isRgnCreated = true) then
    begin
    mousePosition.X:=X;
    mousePosition.Y:=Y;
    CheckingCursorInRgn(mousePosition)
    end;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  mousePosition: TPoint;
begin
  if (isRgnCreated = false) then
    begin
    mousePosition.X:=X;
    mousePosition.Y:=Y;
  if Button=mbLeft then
    begin
    countOfArray:=countOfArray+1;
    Canvas.Pen.Color:=clred;
    Canvas.Brush.color:=clRed;
    Canvas.Ellipse(mousePosition.X-2,mousePosition.Y-2,mousePosition.X+2,mousePosition.Y+2);
    SetLength(pointsArray,countOfArray);
    pointsArray[countOfArray-1].X:= mousePosition.X;
    pointsArray[countOfArray-1].Y:= mousePosition.Y;
    end
    else
    begin
    //DrawRectanglesFromArray();
    CreateRegion();
    //CheckRegion(mousePosition);
    end;
  end;
end;

procedure TForm1.DrawRectanglesFromArray();
var
  i: Integer;
begin
  Canvas.Pen.Color:=clRed;
  Canvas.MoveTo(pointsArray[0].X,pointsArray[0].Y);
    for i := 1 to Length(pointsArray)-1 do
      begin
      Canvas.MoveTo(pointsArray[i-1].X,pointsArray[i-1].Y);
      if(i <= Length(pointsArray)-1) then
        begin
        Canvas.LineTo(pointsArray[i].X,pointsArray[i].Y);
        end
    end;
  Canvas.LineTo(pointsArray[0].X,pointsArray[0].Y);
end;

procedure TForm1.CheckingCursorInRgn(point: TPoint);
begin
  if (PtInRegion(rgn, Point.X, Point.Y) = True) then
    begin
    lblInput.Caption := 'В области';
    end
    else
    begin
    lblInput.Caption := 'Вне области';
    end;
end;

procedure TForm1.CreateRegion();
begin
  rgn := CreatePolygonRgn(pointsArray[0], Length(pointsArray), WINDING);
  isRgnCreated := True;
  //Canvas.Polyline(pointsArray);
  Canvas.Polygon(pointsArray);
end;

procedure TForm1.CheckRegion(mousePoint: TPoint);
var
  i,j,maxX,maxY: Integer;
  minMaxPointX, minMaxPointY: TPoint;
begin
  for i := 0 to maxX do
  begin
    for j := 0 to maxY do
    begin

    end;
  end;
  //if(Canvas.Pixels[mousePoint.X,mousePoint.Y] = clRed) then
  //ShowMessage('Yes');
end;

function TForm1.IsMouseInPoly(x,y: integer; myP: array of TPointF): boolean; //x и y - это координаты мыши
  var                                                                        //myP - массив с вершинами полигона
    i,j,npol: integer;
    inPoly: boolean;
  begin
    npol:=length(myP)-1;
    j:=npol;
    inPoly:=false;
    for i:=0 to npol do
    begin
      if ((((myP[i].y<=y) and (y<myP[j].y)) or ((myP[j].y<=y) and (y<myP[i].y))) and
         (x>(myP[j].x-myP[i].x)*(y-myP[i].y) / (myP[j].y-myP[i].y)+myP[i].x))
           then inPoly:=not inPoly;
      j:=i;
    end;
    result:=inPoly;
  end;

end.
