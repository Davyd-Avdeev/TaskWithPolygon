unit FirstTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    lblInput: TLabel;
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawRectanglesFromArray();
    procedure CheckingCursorInRgn(point: TPoint);
    procedure CreateRegion();
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
    DrawRectanglesFromArray();
    CreateRegion();
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
end;

end.
