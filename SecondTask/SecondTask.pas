unit SecondTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Types, Vcl.StdCtrls, System.Math;

type
  TForm2 = class(TForm)
    lbxCoordinates: TListBox;
    editVertexX: TEdit;
    editVertexY: TEdit;
    btnAdd: TButton;
    editPointX: TEdit;
    editPointY: TEdit;
    btnCheck: TButton;
    lblResult: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    btnDefault: TButton;
    Button1: TButton;
    procedure btnAddClick(Sender: TObject);
    procedure btnCheckClick(Sender: TObject);
    procedure AddInList();    
    function AreaConvexPolygon(): Real;
    function InsideNonConvexPolygon(p: TPointF): Boolean;
    function InsideConvexPolygon(p: TPointF): Boolean;
    function CheckOnEdge(a, b, p: TPointF): Boolean;
    function CheckAreaTriangle(a,b,p: TPointF): Real;
    function CheckForConvexityPolygon(): Boolean;
    function LeftTurn(a,b,p: TPointF): Integer;    
    procedure btnPresetConvexClick(Sender: TObject);
    procedure btnPresetNonConvexClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  pointsFArray: array of TPointF;
  countArray: Integer;

implementation

{$R *.dfm}

procedure TForm2.btnAddClick(Sender: TObject);
begin
  AddInList();
end;

procedure TForm2.btnCheckClick(Sender: TObject);
var
  point: TPointF;
begin
  point.X := StrToFloat(editPointX.Text);
  point.Y := StrToFloat(editPointY.Text);
  if CheckForConvexityPolygon() then
    if InsideConvexPolygon(point) then
      lblResult.Caption := 'Point in polygon'
    else
      lblResult.Caption := 'Point outside polygon'
  else
    if InsideNonConvexPolygon(point) then
      lblResult.Caption := 'Point in polygon'
    else
      lblResult.Caption := 'Point outside polygon';
end;

procedure TForm2.btnPresetConvexClick(Sender: TObject);
begin
  lbxCoordinates.Clear();
  SetLength(pointsFArray, 5);
  pointsFArray[0] := Point(-2,-3);
  pointsFArray[1] := Point(2,-3);
  pointsFArray[2] := Point(4,0);
  pointsFArray[3] := Point(0,3);
  pointsFArray[4] := Point(-4,0);

  lbxCoordinates.Items.Add('X1: -2, Y1: -3');
  lbxCoordinates.Items.Add('X2:  2, Y2: -3');
  lbxCoordinates.Items.Add('X3:  4, Y3: 0');
  lbxCoordinates.Items.Add('X4:  0, Y4: 3');
  lbxCoordinates.Items.Add('X5: -4, Y5: 0');
end;

procedure TForm2.btnPresetNonConvexClick(Sender: TObject);
begin
  lbxCoordinates.Clear();
  SetLength(pointsFArray, 5);
  pointsFArray[0] := Point(-3,-3);
  pointsFArray[1] := Point(2,-3);
  pointsFArray[2] := Point(3,0);
  pointsFArray[3] := Point(0,-1);
  pointsFArray[4] := Point(-1,3);
  pointsFArray[5] := Point(-5,1);

  lbxCoordinates.Items.Add('X1: -3, Y1: -3');
  lbxCoordinates.Items.Add('X2:  2, Y2: -3');
  lbxCoordinates.Items.Add('X3:  3, Y3: 0');
  lbxCoordinates.Items.Add('X4:  0, Y4: -1');
  lbxCoordinates.Items.Add('X5: -1, Y5: 3');
  lbxCoordinates.Items.Add('X6: -5, Y6: 1');
end;

procedure TForm2.AddInList();
var
  point: TPointF;
  text: String;
begin
  text := 'X' + IntToStr(countArray) + ': ' + editVertexX.Text + ', Y' + IntToStr(countArray) + ': ' + editVertexY.Text;
  point.X := StrToFloat(editVertexX.Text);
  point.Y := StrToFloat(editVertexY.Text);
  SetLength(pointsFArray, countArray);
  pointsFArray[countArray].X := point.X;
  pointsFArray[countArray].Y := point.Y;
  countArray:=countArray+1;
  editVertexX.Text := '';
  editVertexY.Text := '';

  lbxCoordinates.Items.Add(text);
end;

function TForm2.CheckAreaTriangle(a,b,p: TPointF): Real;
var
  S: Real;
begin
  S:= ((a.X-p.X)*(b.Y-p.Y)-(a.Y-p.Y)*(b.X-p.X)) / 2;
  Exit(S);
end;

function TForm2.AreaConvexPolygon(): Real;
var
  i: Integer;
  area: Real;
begin
  area := 0;
  for i := 0 to Length(pointsFArray)-3 do
  begin
    area:= area + abs(CheckAreaTriangle(pointsFArray[i+1],pointsFArray[i+2], pointsFArray[0]));
  end;

  Exit(area);
end;

function TForm2.InsideConvexPolygon(p: TPointF): Boolean;
var
  i: Integer;
  sumArea, polygonArea: Real;
begin
  polygonArea := AreaConvexPolygon();
  sumArea:= 0;
  for i := 0 to Length(pointsFArray)-1 do
  begin
    if (i = Length(pointsFArray)-1) then
      sumArea := sumArea + abs(CheckAreaTriangle(pointsFArray[i],pointsFArray[0], p))
    else
      sumArea := sumArea + abs(CheckAreaTriangle(pointsFArray[i],pointsFArray[i+1], p));
  end;

  if(FloatToStr(sumArea) = FloatToStr(polygonArea)) then
    Exit(True)
  else
    Exit(False);
end;

function TForm2.InsideNonConvexPolygon(p: TPointF): Boolean;
var
  count, i: Integer;
begin
  count:= 0;
  
  for i := 0 to Length(pointsFArray)-2 do
  begin
    if (CheckOnEdge(pointsFArray[i],pointsFArray[i+1],p)) then
      Exit(True);
    if (pointsFArray[i].Y = pointsFArray[i+1].Y) then Continue;
    if ((p.Y = Max(pointsFArray[i].Y, pointsFArray[i+1].Y)) And
       (p.Y < Min(pointsFArray[i].X, pointsFArray[i+1].X))) then count := count + 1;
    if (p.Y = Min(pointsFArray[i].Y, pointsFArray[i+1].Y)) then Continue;
    if ((p.Y >= Min(pointsFArray[i].Y, pointsFArray[i+1].Y)) And (p.Y <= Max(pointsFArray[i].Y, pointsFArray[i+1].Y))) then
      if (LeftTurn(pointsFArray[i],pointsFArray[i+1], p) = -1) then count := count + 1;
  end;

  if (CheckOnEdge(pointsFArray[i],pointsFArray[0],p)) then
    Exit(True);
  if (pointsFArray[i].Y = pointsFArray[0].Y) then
  else
  begin
    if ((p.Y = Max(pointsFArray[i].Y, pointsFArray[0].Y)) And
         (p.Y < Min(pointsFArray[i].X, pointsFArray[0].X))) then count := count + 1;
    if (p.Y = Min(pointsFArray[i].Y, pointsFArray[0].Y)) then
    else
      if ((p.Y >= Min(pointsFArray[i].Y, pointsFArray[0].Y)) And (p.Y <= Max(pointsFArray[i].Y, pointsFArray[0].Y))) then
        if (LeftTurn(pointsFArray[i],pointsFArray[0], p) = -1) then count := count + 1;
  end;

  if(((count mod 2) = 0) And (count <> 0)) then
    Exit(True)
  else
    Exit(False);

end;

function TForm2.CheckOnEdge(a, b, p: TPointF): Boolean;
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

function TForm2.LeftTurn(a,b,p: TPointF): Integer;
var
  total: Real;
begin
  total := ((p.X-a.X) * (b.Y-a.Y)) - ((p.Y-a.Y) * (b.X-a.X));
  if(total < 0) then
    Exit(-1)
  else if (total = 0) then
    Exit(0)
  else
    Exit(1);
end;

function TForm2.CheckForConvexityPolygon(): Boolean;
var
  i: Integer;
  arr: array of Integer;
begin
  SetLength(arr,Length(pointsFArray));
  for i := 0 to Length(pointsFArray)-3 do
  begin
    arr[i] := LeftTurn(pointsFArray[i], pointsFArray[i+1], pointsFArray[i+2]);
  end;
  arr[Length(arr)-2] := LeftTurn(pointsFArray[Length(arr)-2], pointsFArray[Length(arr)-1], pointsFArray[0]);
  arr[Length(arr)-1] := LeftTurn(pointsFArray[Length(arr)-1], pointsFArray[0], pointsFArray[1]);

  for i := 0 to Length(arr)-2 do
  begin    
    if (arr[i] = arr[i+1]) then
    else 
    begin
      Exit(False);
    end;
  end; 
  
  Exit(True);
end;

end.

