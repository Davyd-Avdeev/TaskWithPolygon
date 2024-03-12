unit FourthTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,System.Types,System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  PTriangle = ^TTriangle; //Указатель на треугольник
  PRib = ^TRib; //Указатель на ребро
  TRib = class //Класс ребра
    Nodes: array[0..1] of PPoint; //Точки
    Triangles: array[0..1] of PTriangle; // соседине треугольники
    Index: Integer; //Индекс в массиве
    constructor Create(p1,p2: PPoint; t1,t2: PTriangle); //Конструктор
  end;
  TTriangle = class //Класс треугольника
    Nodes: array[0..2] of PPoint; //Точки
    Index: Integer; //Индекс в массиве
    constructor Create(p1,p2,p3: PPoint); //Конструктор
  end;

  TForm6 = class(TForm)
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject); 
    procedure DrawTriangulation();
    procedure SortArray();
    procedure CreateOuterShell();
    procedure LocalitationOutsidePoints();
    procedure CreateInitialTriangles();
    procedure LocalitationPoints();
    procedure Rebuilding();

    function LeftTurn(a,b,p: TPointF): Real;
    function CheckAreaTriangle(a,b,p: TPointF): Real;
    function IsInsideTriangle(p: TPointF; triangle: TTriangle): Boolean;
    function IsOnRib(p: TPointF; rib: TRib): Boolean;
    function FindRib(rib: TRib): Integer;
    function FindAngle(p1,p2,p3: TPointF): Real;
    function IsRibEquals(rib1, rib2: TRib): BooLean;
    function FindCentralPoint(): Boolean;
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  Form6: TForm6;
  allPointsArray: array of TPoint;
  shellPointsArray, outsidePointsArray: array of PPoint;
  TrianglesArray: array of TTriangle;
  RibsArray: array of TRib;
  cpIndex: Integer;

implementation

{$R *.dfm}

constructor TRib.Create(p1,p2: PPoint; t1,t2: PTriangle);
begin
  Nodes[0]:= p1; Nodes[1]:= p2;
  Triangles[0]:= t1; Triangles[1]:= t2;
end;

constructor TTriangle.Create(p1,p2,p3: PPoint);
begin
  Nodes[0]:= p1; Nodes[1]:= p2; Nodes[2]:= p3;
end;

procedure TForm6.FormCreate(Sender: TObject);
var
  x,y: Integer;
begin
  form6.height:= 800;
  form6.Width:= 1000;
  Form6.Position:=poScreenCenter;
    y:= (Height - button1.Height) - 100;
    x:= (Width - button1.Width) - 80;
   button1.Top := y;
   button1.Left:= x;
end;

procedure TForm6.Button1Click(Sender: TObject);
var
  i: Integer;
  p: TPoint;
begin
  SetLength(allPointsArray,15);
  for i := 0 to Length(allPointsArray)-1 do
  begin
    p:= Point(Random(1100),Random(900));
    allPointsArray[i] := p;
  end;
  SortArray();
  CreateOuterShell();
  if(FindCentralPoint() = false)then
    Exit();
  CreateInitialTriangles();
  LocalitationOutsidePoints();
  LocalitationPoints();
  Rebuilding();
  DrawTriangulation();
end;

procedure TForm6.DrawTriangulation();
var
  i,j: Integer;
  tempTriangle: TTriangle;
begin
  Canvas.Brush.Color := clRed;
  Canvas.FillRect(ClientRect);
  PatBlt(Canvas.Handle, 0, 0, ClientWidth, ClientHeight, WHITENESS);

  for I := 0 to Length(RibsArray)-1 do
  begin
    Canvas.MoveTo(RibsArray[i].Nodes[0].X, RibsArray[i].Nodes[0].Y);
    Canvas.LineTo(RibsArray[i].Nodes[1].X, RibsArray[i].Nodes[1].Y);;
  end;

  Canvas.Pen.Color:= clRed;
  Canvas.Brush.Color:= clRed;
  for i := 0 to Length(AllPointsArray)-1 do
    Canvas.Ellipse(AllPointsArray[i].X-2, AllPointsArray[i].Y-2, AllPointsArray[i].X+2, AllPointsArray[i].Y+2);
  Canvas.Pen.Color:= clBlack;
  Canvas.Brush.Color:= clBlack;
end;

procedure TForm6.SortArray(); //Процедура сортировки массива точек
var
  i,j,k,f,m: Integer;
  temp: TPoint;
begin
  //Сортировка по X
  for i := 0 to Length(allPointsArray)-1 do
  begin
    for j := i+1 to Length(allPointsArray)-1 do
    begin
      if(allPointsArray[j].X < allPointsArray[i].X)then
     begin
        temp := allPointsArray[i];
        allPointsArray[i] := allPointsArray[j];
        allPointsArray[j] := temp;
      end;
    end;
  end;

  //Сортировка по Y
  f:= 0;
  for I := 0 to Length(allPointsArray)-2 do
  begin
    if((allPointsArray[i].X <> allPointsArray[i+1].X) or (i+2 = Length(allPointsArray))) then
    begin
      if (i+2 = Length(allPointsArray)) then m:= i+1
      else m:= i;
      for k := f to m do
      begin
        for j := k+1 to m do
        begin
          if(allPointsArray[j].Y < allPointsArray[k].Y)then
          begin
            temp := allPointsArray[k];
            allPointsArray[k] := allPointsArray[j];
            allPointsArray[j] := temp;
          end;
        end;
      end;
      f:= i+1;
    end;
  end;
end;

procedure TForm6.CreateOuterShell(); //Создание внешней оболочки
var
  i,j,curI: Integer;
  endpoint, pointOnHull : TPoint;
  tempArray: array of TPoint;
begin
  pointOnHull:= allPointsArray[0];
  curI:=0;
  repeat
    SetLength(tempArray,Length(tempArray)+1);
    tempArray[curI]:= pointOnHull;
    endpoint:= allPointsArray[0];
  for i := 0 to Length(allPointsArray)-1 do
  begin
    if (endpoint = pointOnHull) or (LeftTurn(tempArray[curI], endpoint, allPointsArray[i]) > 0) then
      endpoint := allPointsArray[i];
  end;
    curI:= curI + 1;
    pointOnHull := endpoint;
  until endpoint = allPointsArray[0];

  for i := 0 to Length(tempArray)-1 do
  begin
    for j := 0 to Length(allPointsArray)-1 do
      if(tempArray[i] = allPointsArray[j])then
      begin
        SetLength(shellPointsArray, Length(shellPointsArray)+1);
        shellPointsArray[Length(shellPointsArray)-1]:= @(allPointsArray[j]);
      end;
  end;
end;

//Поиск самой центральной точки, не входящей в оболочку
function TForm6.FindCentralPoint(): Boolean;
var
  i,j,k,m,sign,pointIndex: Integer;
  isPointInShell: Boolean;
begin
  if(Length(allPointsArray) = Length(shellPointsArray))then
  begin
    Exit(False);
  end;

  sign := 1;
  k:= (Length(allPointsArray)-1) div 2;
  i:= 0;
  While(True) do
  begin
    m:= (i div 2) * sign;
    sign:= sign * -1;
    isPointInShell:= False;
    for j := 0 to Length(shellPointsArray)-1 do
    begin
      if(allPointsArray[k + m] = shellPointsArray[j]^) then
      begin
      isPointInShell:= True;
      break;
      end;
    end;
    if (isPointInShell = False) then
    begin
      pointIndex := k + m;
      break;
    end;
    i:= i+1;
  end;
  cpIndex:= pointIndex;

  Exit(True);
end;

//Создание начальных треугольников и рёбер
procedure TForm6.CreateInitialTriangles();
var
  i,j,k: Integer;
  rib1,rib2,rib3: TRib;
  triangle:TTriangle;
begin
  for i := 0 to Length(shellPointsArray)-2 do
  begin
    SetLength(RibsArray, Length(RibsArray)+2);
    rib1:= TRib.Create(shellPointsArray[i], shellPointsArray[i+1], nil,nil);

    rib3:= TRib.Create(@(AllPointsArray[cpIndex]), shellPointsArray[i], nil,nil);
    RibsArray[Length(RibsArray)-2]:= rib1; RibsArray[Length(RibsArray)-1]:= rib3;
    RibsArray[Length(RibsArray)-2].Index:=Length(RibsArray)-2;
    RibsArray[Length(RibsArray)-1].Index:=Length(RibsArray)-1;
    SetLength(TrianglesArray, Length(TrianglesArray)+1);
    triangle:= TTriangle.Create(shellPointsArray[i],shellPointsArray[i+1], @(AllPointsArray[cpIndex]));
    TrianglesArray[Length(TrianglesArray)-1]:= triangle;
    TrianglesArray[Length(TrianglesArray)-1].Index:= Length(TrianglesArray)-1;

  end;
    SetLength(RibsArray, Length(RibsArray)+2);
    rib1:= TRib.Create(shellPointsArray[Length(shellPointsArray)-1], shellPointsArray[0], nil,nil);
    rib2:= TRib.Create(shellPointsArray[Length(shellPointsArray)-1], @(AllPointsArray[cpIndex]),nil,nil);
    RibsArray[Length(RibsArray)-2]:= rib1;
    RibsArray[Length(RibsArray)-1]:= rib2;
    RibsArray[Length(RibsArray)-2].Index:=Length(RibsArray)-2;
    RibsArray[Length(RibsArray)-1].Index:=Length(RibsArray)-1;
    SetLength(TrianglesArray, Length(TrianglesArray)+1);
    triangle:= TTriangle.Create(shellPointsArray[Length(shellPointsArray)-1],shellPointsArray[0], @(AllPointsArray[cpIndex]));
    TrianglesArray[Length(TrianglesArray)-1]:= triangle;
    TrianglesArray[Length(TrianglesArray)-1].Index:= Length(TrianglesArray)-1;

    RibsArray[1].Triangles[0]:= @(TrianglesArray[0]);
    RibsArray[1].Triangles[1]:= @(TrianglesArray[Length(TrianglesArray)-1]);
    j:= 3;
    for i := 1 to Length(ShellPointsArray)-1 do
    begin
      RibsArray[j].Triangles[0]:= @(TrianglesArray[i]);
      RibsArray[j].Triangles[1]:= @(TrianglesArray[i-1]);
      j:= j+2;
    end;
    j:= 0;
    for i := 0 to Length(ShellPointsArray)-1 do
    begin
      RibsArray[j].Triangles[0]:= @(TrianglesArray[i]);
      j:= j+2;
    end;
end;

//Поиск всех точек вне оболочки
procedure TForm6.LocalitationOutsidePoints();
var
  i,j:Integer;
  isNotInShell: Boolean;
begin
  SetLength(shellPointsArray, Length(shellPointsArray)+1);
  shellPointsArray[Length(shellPointsArray)-1]:= @(allPointsArray[cpIndex]);

  //Находим все точки не попавшие в 'триангуляцию' и добавляем в массив
  for i := 0 to Length(allPointsArray)-1 do
  begin
    isNotInShell:=true;
    for j := 0 to Length(shellPointsArray)-1 do
    begin
      if(allPointsArray[i] = shellPointsArray[j]^) then
      begin
      isNotInShell:= false;
      break;
      end;
    end;
    if(isNotInShell)Then
    begin
      SetLength(outsidePointsArray, Length(outsidePointsArray)+1);
      outsidePointsArray[Length(outsidePointsArray)-1]:= @(allPointsArray[i]);
    end;
  end;

end;

//1 этап триангуляции, создание новых треугольников
procedure TForm6.LocalitationPoints();
var
  i,j,k,m,count: Integer;
  tempTriangle1: TTriangle;
  rib1,rib2,rib3,rib4: TRib;
  tempIndex1, tempIndex2,tempIndex3,tempIndex4,tempIndex5,tempIndex6,tempIndex7: Integer;
  tempP1,tempP2,tempP3:TPoint;
  tempBool: Boolean;
begin

  for i := 0 to Length(OutsidePointsArray)-1 do
  begin
    for j := 0 to Length(TrianglesArray)-1 do
    begin
      //Проверка находится ли точка внутри треугольника
      if(IsInsideTriangle(OutsidePointsArray[i]^, TrianglesArray[j])) then
      begin
        //Проверяется находится ли точка на ребре
        rib1:= TRib.Create(TrianglesArray[j].Nodes[0],TrianglesArray[j].Nodes[1],nil,nil);
        rib2:= TRib.Create(TrianglesArray[j].Nodes[1],TrianglesArray[j].Nodes[2],nil,nil);
        rib3:= TRib.Create(TrianglesArray[j].Nodes[2],TrianglesArray[j].Nodes[0],nil,nil);
        if((IsOnRib(OutsidePointsArray[i]^, rib1))
        or (IsOnRib(OutsidePointsArray[i]^, rib2))
        or (IsOnRib(OutsidePointsArray[i]^, rib3)))then
        begin
          //Если  да
          //Строится 1-2 новых треугольника и заменяется 1-2 старых,
          //т.е из 1 треугольника строится 2 или из двух - четыре
          if (IsOnRib(OutsidePointsArray[i]^, rib1)) then
            rib4:= rib1
          else if (IsOnRib(OutsidePointsArray[i]^, rib2)) then
            rib4:= rib2
          else
            rib4:= rib3;
          count:= 0; tempBool:= false;
          tempIndex1:= FindRib(rib4);
          for k := 0 to 1 do
          begin
            if(RibsArray[tempIndex1].Triangles[k] <> nil) then
              count:= count+1;
          end;
          if(count > 1) then
          begin
            tempBool:= true;
            for k := 0 to 1 do
              if(RibsArray[tempIndex1].Triangles[k]^ <> TrianglesArray[j]) then
                tempIndex5:= RibsArray[tempIndex1].Triangles[k].Index;
          end;

          for k := 0 to 2 do
          begin
            if(LeftTurn(rib4.Nodes[0]^, rib4.Nodes[1]^, TrianglesArray[j].Nodes[k]^) <> 0) then
              tempIndex3:= k;
          end;

          SetLength(TrianglesArray, Length(TrianglesArray)+1);
          tempTriangle1:= TTriangle.Create(rib4.Nodes[0], OutsidePointsArray[i], TrianglesArray[j].Nodes[tempIndex3]);
          TrianglesArray[Length(TrianglesArray)-1]:= tempTriangle1;
          TrianglesArray[Length(TrianglesArray)-1].Index:= Length(TrianglesArray)-1;
          rib1:= TRib.Create(OutsidePointsArray[i], TrianglesArray[j].Nodes[tempIndex3], @(TrianglesArray[Length(TrianglesArray)-1]), nil);
          rib2:= TRib.Create(rib4.Nodes[0], TrianglesArray[j].Nodes[tempIndex3], nil,nil);
          rib3:= TRib.Create(OutsidePointsArray[i], rib4.Nodes[0], @(TrianglesArray[Length(TrianglesArray)-1]), nil);
          tempIndex2:= FindRib(rib2);

          for k := 0 to 1 do
            if (RibsArray[tempIndex2].Triangles[k] <> nil) then
              if(RibsArray[tempIndex2].Triangles[k]^ = TrianglesArray[j]) then
                RibsArray[tempIndex2].Triangles[k]:= @(TrianglesArray[Length(TrianglesArray)-1]);

          SetLength(RibsArray, Length(RibsArray)+2);
          RibsArray[Length(RibsArray)-2]:= rib1;
          RibsArray[Length(RibsArray)-1]:= rib3;
          RibsArray[Length(RibsArray)-2].Index:= Length(RibsArray)-2;
          RibsArray[Length(RibsArray)-1].Index:= Length(RibsArray)-1;

          tempTriangle1:= TTriangle.Create(rib4.Nodes[1], OutsidePointsArray[i],TrianglesArray[j].Nodes[tempIndex3]);
          rib2:= TRib.Create(rib4.Nodes[1], TrianglesArray[j].Nodes[tempIndex3], nil,nil);
          tempIndex2:= FindRib(rib2);
          for k := 0 to 1 do
            if (RibsArray[tempIndex2].Triangles[k] <> nil) then
              if(RibsArray[tempIndex2].Triangles[k]^ = TrianglesArray[j]) then
                tempIndex4:= k;

          TrianglesArray[j]:= tempTriangle1;
          RibsArray[Length(RibsArray)-2].Triangles[1]:= @(TrianglesArray[j]);
          RibsArray[tempIndex2].Triangles[tempIndex4]:= @(TrianglesArray[j]);
          RibsArray[tempIndex1].Nodes[0]:= OutsidePointsArray[i];
          RibsArray[tempIndex1].Nodes[1]:= rib4.Nodes[1];

          if(tempBool) then
          begin
            for k := 0 to 1 do
              if (RibsArray[tempIndex1].Triangles[k] <> nil) then
                if(RibsArray[tempIndex1].Triangles[k]^ <> TrianglesArray[tempIndex5]) then
                  RibsArray[tempIndex1].Triangles[k]:= @(TrianglesArray[j]);
          end
          else
            for k := 0 to 1 do
              if (RibsArray[tempIndex1].Triangles[k] <> nil) then
                RibsArray[tempIndex1].Triangles[k]:= @(TrianglesArray[j]);

          if(tempBool) then
          begin
            for k := 0 to 2 do
              if(LeftTurn(RibsArray[tempIndex1].Nodes[0]^, RibsArray[tempIndex1].Nodes[1]^, TrianglesArray[tempIndex5].Nodes[k]^) <> 0) then
                tempIndex3:= k;
            for k := 0 to 2 do
              if((k <> tempIndex3) And (TrianglesArray[tempIndex5].Nodes[k] <> RibsArray[tempIndex1].Nodes[1])) then
                tempIndex6:= k;

            SetLength(TrianglesArray, Length(TrianglesArray)+1);
            tempTriangle1:= TTriangle.Create(OutsidePointsArray[i], RibsArray[tempIndex1].Nodes[1], TrianglesArray[tempIndex5].Nodes[tempIndex3]);
            TrianglesArray[Length(TrianglesArray)-1]:= tempTriangle1;
            TrianglesArray[Length(TrianglesArray)-1].Index:= Length(TrianglesArray)-1;
            for m := 0 to 1 do
              if (RibsArray[tempIndex1].Triangles[m] <> nil) then
                if(RibsArray[tempIndex1].Triangles[m]^ <> TrianglesArray[j]) then
                  RibsArray[tempIndex1].Triangles[m]:= @(TrianglesArray[Length(TrianglesArray)-1]);

            rib2:= TRib.Create(RibsArray[tempIndex1].Nodes[1], TrianglesArray[tempIndex5].Nodes[tempIndex3],nil,nil);
            tempIndex2:= FindRib(rib2);
            for m := 0 to 1 do
              if(RibsArray[tempIndex2].Triangles[m] <> nil) then
                if(RibsArray[tempIndex2].Triangles[m]^ = TrianglesArray[tempIndex5]) then
                  RibsArray[tempIndex2].Triangles[m]:= @(TrianglesArray[Length(TrianglesArray)-1]);

            rib1:= TRib.Create(OutsidePointsArray[i], TrianglesArray[tempIndex5].Nodes[tempIndex3], @(TrianglesArray[Length(TrianglesArray)-1]),nil);
            SetLength(RibsArray,Length(RibsArray)+1);
            RibsArray[Length(RibsArray)-1]:= rib1;
            RibsArray[Length(RibsArray)-1].Index:= Length(RibsArray)-1;

            tempTriangle1:= TTriangle.Create(OutsidePointsArray[i], TrianglesArray[tempIndex5].Nodes[tempIndex3], TrianglesArray[tempIndex5].Nodes[tempIndex6]);
            rib2:= TRib.Create(TrianglesArray[tempIndex5].Nodes[tempIndex3], TrianglesArray[tempIndex5].Nodes[tempIndex6],nil,nil);
            tempIndex2:= FindRib(rib2);
            for m := 0 to 1 do
              if (RibsArray[tempIndex2].Triangles[m] <> nil) then
                if(RibsArray[tempIndex2].Triangles[m]^ = TrianglesArray[tempIndex5]) then
                  tempIndex1:= m;

            TrianglesArray[tempIndex5]:= tempTriangle1;
            TrianglesArray[tempIndex5].Index:= tempIndex5;

            RibsArray[tempIndex2].Triangles[tempIndex1]:= @(TrianglesArray[tempIndex5]);
            RibsArray[Length(RibsArray)-1].Triangles[1]:= @(TrianglesArray[tempIndex5]);
            RibsArray[Length(RibsArray)-2].Triangles[1] := @(TrianglesArray[tempIndex5]);
          end;
          break;
        end
        else
        begin
          //Если  нет
          //Строится 3 новых треугольника (1 существующий изменяется на новый)
          SetLength(TrianglesArray, Length(TrianglesArray)+1);
          tempTriangle1:= TTriangle.Create(OutsidePointsArray[i], TrianglesArray[j].Nodes[0], TrianglesArray[j].Nodes[1]);
          TrianglesArray[Length(TrianglesArray)-1]:= tempTriangle1;
          TrianglesArray[Length(TrianglesArray)-1].Index:= Length(TrianglesArray)-1;
          tempP1:= TrianglesArray[j].Nodes[0]^;
          tempP2:= TrianglesArray[j].Nodes[1]^;
          rib4:= TRib.Create(@(tempP1),@(tempP2),nil,nil);
          tempIndex1:= FindRib(rib4);

          rib1:= TRib.Create(OutsidePointsArray[i], TrianglesArray[j].Nodes[0], @(TrianglesArray[Length(TrianglesArray)-1]), nil);
          rib3:= TRib.Create(TrianglesArray[j].Nodes[1], OutsidePointsArray[i], @(TrianglesArray[Length(TrianglesArray)-1]),nil);

          SetLength(RibsArray, Length(RibsArray)+2);
          RibsArray[Length(RibsArray)-2]:= rib1; RibsArray[Length(RibsArray)-1]:= rib3;
          RibsArray[Length(RibsArray)-2].Index:= Length(RibsArray)-2;
          RibsArray[Length(RibsArray)-1].Index:= Length(RibsArray)-1;

          for m := 0 to 1 do
            if (RibsArray[tempIndex1].Triangles[m] <> nil) then
              if(RibsArray[tempIndex1].Triangles[m]^ = TrianglesArray[j]) then
                RibsArray[tempIndex1].Triangles[m]:= @(TrianglesArray[Length(TrianglesArray)-1]);

          SetLength(TrianglesArray, Length(TrianglesArray)+1);
          tempTriangle1:= TTriangle.Create(OutsidePointsArray[i], TrianglesArray[j].Nodes[1], TrianglesArray[j].Nodes[2]);
          TrianglesArray[Length(TrianglesArray)-1]:= tempTriangle1;
          TrianglesArray[Length(TrianglesArray)-1].Index:= Length(TrianglesArray)-1;
          tempP1:= TrianglesArray[j].Nodes[1]^;
          tempP2:= TrianglesArray[j].Nodes[2]^;
          rib4:= TRib.Create(@(tempP1),@(tempP2),nil,nil);
          tempIndex1:= FindRib(rib4);

          RibsArray[Length(RibsArray)-1].Triangles[1]:=  @(TrianglesArray[Length(TrianglesArray)-1]);

          SetLength(RibsArray, Length(RibsArray)+1);
          rib1:= TRib.Create(OutsidePointsArray[i], TrianglesArray[j].Nodes[2], @(TrianglesArray[Length(TrianglesArray)-1]), nil);

          RibsArray[Length(RibsArray)-1]:= rib1;
          RibsArray[Length(RibsArray)-1].Index:= Length(RibsArray)-1;

          for m := 0 to 1 do
            if (RibsArray[tempIndex1].Triangles[m] <> nil) then
              if(RibsArray[tempIndex1].Triangles[m]^ = TrianglesArray[j]) then
                RibsArray[tempIndex1].Triangles[m]:= @(TrianglesArray[Length(TrianglesArray)-1]);

          tempTriangle1:= TTriangle.Create(OutsidePointsArray[i], TrianglesArray[j].Nodes[2], TrianglesArray[j].Nodes[0]);

          tempP1:= TrianglesArray[j].Nodes[2]^;
          tempP2:= TrianglesArray[j].Nodes[0]^;
          rib4:= TRib.Create(@(tempP1),@(tempP2),nil,nil);
          tempIndex1:= FindRib(rib4);

          for m := 0 to 1 do
            if (RibsArray[tempIndex1].Triangles[m] <> nil) then
              if(RibsArray[tempIndex1].Triangles[m]^ = TrianglesArray[j]) then
                tempIndex2:= m;

          TrianglesArray[j]:= tempTriangle1;
          TrianglesArray[j].Index:= j;
          RibsArray[Length(RibsArray)-3].Triangles[1]:= @(TrianglesArray[j]);
          RibsArray[Length(RibsArray)-1].Triangles[1]:= @(TrianglesArray[j]);
          RibsArray[tempIndex1].Triangles[tempIndex2]:= @(TrianglesArray[j]);

          break;
        end;
      end;            
    end;
  end;
end;

//Процедура перестройки для удовлетворению условию делоне
procedure TForm6.Rebuilding();
var
  i,j,count:Integer;
  p0,p1,p2,p3:PPoint;
  ribIndex1,ribIndex2,ribIndex3,ribIndex4: Integer;
  tIndex1,tIndex2,tIndex3,tIndex4:Integer;
  triangle1,triangle2: TTriangle;
  rib1:Trib;
  isFinish:Boolean;
begin
  isFinish:=False;
  count:=0;
  //Проверяются все ребра, пока не будет найдено не одно неправильное
  while isFinish = False do
  begin
    for i := 0 to Length(RibsArray)-1 do
    begin
      TIndex1:=-1; TIndex2:=-1; TIndex3:=-1; TIndex4:=-1;
      ribIndex1:=-1; ribIndex2:=-1; ribIndex3:=-1; ribIndex4:=-1;
      p0:= nil; p1:= nil; p2:= nil; p3:= nil;
      count:=0;
      for j := 0 to 1 do
        if(RibsArray[i].Triangles[j] <> nil)then
          count:= count+1;
      if(count < 2) then
        Continue;
      for j := 0 to 2 do
        if(LeftTurn(RibsArray[i].Nodes[0]^, RibsArray[i].Nodes[1]^, RibsArray[i].Triangles[0].Nodes[j]^) <> 0)then
          p0:= RibsArray[i].Triangles[0].Nodes[j];
      for j := 0 to 2 do
        if(LeftTurn(RibsArray[i].Nodes[0]^, RibsArray[i].Nodes[1]^, RibsArray[i].Triangles[1].Nodes[j]^) <> 0)then
          p2:= RibsArray[i].Triangles[1].Nodes[j];

      p1:= RibsArray[i].Nodes[0];
      p3:= RibsArray[i].Nodes[1];

      //Проверяется больше ли оба угла 90*
      if((FindAngle(p0^,p1^,p3^) > 90) And (FindAngle(p2^,p1^,p3^) > 90))then
      begin
        //Eсли да перестраевается
        rib1:= TRib.Create(p1,p0,nil,nil);
        ribIndex1:= FindRib(rib1);
        for j := 0 to 1 do
        begin
          if (ribIndex1 < 0) or (ribIndex1 > High(RibsArray))  then
            ribIndex1:=0;
          if (RibsArray[ribIndex1].Triangles[j] <> nil) then
            if (RibsArray[ribIndex1].Triangles[j] = RibsArray[i].Triangles[0]) then
              TIndex1:= j;
        end;

        rib1:= TRib.Create(p3,p0,nil,nil);
        ribIndex2:= FindRib(rib1);
        for j := 0 to 1 do
          if (RibsArray[ribIndex2].Triangles[j] <> nil) then
            if (RibsArray[ribIndex2].Triangles[j] = RibsArray[i].Triangles[0]) then
              TIndex2:= j;

        rib1:= TRib.Create(p1,p2,nil,nil);
        ribIndex3:= FindRib(rib1);
        for j := 0 to 1 do
          if (RibsArray[ribIndex3].Triangles[j] <> nil) then
            if (RibsArray[ribIndex3].Triangles[j] = RibsArray[i].Triangles[1]) then
              TIndex3:= j;

        rib1:= TRib.Create(p3,p2,nil,nil);
        ribIndex4:= FindRib(rib1);
        for j := 0 to 1 do
          if (RibsArray[ribIndex4].Triangles[j] <> nil) then
            if (RibsArray[ribIndex4].Triangles[j] = RibsArray[i].Triangles[1]) then
              TIndex4:= j;

        triangle1:= TTriangle.Create(p0,p2,p1);

        triangle2:= TTriangle.Create(p0,p2,p3);

        TrianglesArray[RibsArray[i].Triangles[0].Index]:= triangle1;
        TrianglesArray[RibsArray[i].Triangles[0].Index].Index:= RibsArray[i].Triangles[0].Index;
        TrianglesArray[RibsArray[i].Triangles[1].Index]:= triangle2;
        TrianglesArray[RibsArray[i].Triangles[1].Index].Index:= RibsArray[i].Triangles[1].Index;

        if(tIndex1 <> -1) then
          RibsArray[ribIndex1].Triangles[tIndex1]:= @(TrianglesArray[RibsArray[i].Triangles[0].Index]);
        if(tIndex2 <> -1) then
          RibsArray[ribIndex2].Triangles[tIndex2]:= @(TrianglesArray[RibsArray[i].Triangles[1].Index]);
        if(tIndex3 <> -1) then
          RibsArray[ribIndex3].Triangles[tIndex3]:= @(TrianglesArray[RibsArray[i].Triangles[0].Index]);
        if(tIndex4 <> -1) then
          RibsArray[ribIndex4].Triangles[tIndex4]:= @(TrianglesArray[RibsArray[i].Triangles[1].Index]);

        tIndex1:= RibsArray[i].Triangles[0].Index;
        tIndex2:= RibsArray[i].Triangles[1].Index;

        RibsArray[i].Nodes[0]:= p0;
        RibsArray[i].Nodes[1]:= p2;
        RibsArray[i].Triangles[0]:= @(TrianglesArray[tIndex1]);
        RibsArray[i].Triangles[1]:= @(TrianglesArray[tIndex2]);
        break;
      end;
      //else if()then
      //Eсли нет проверятеся условия полность

      //Проверка есть ли ещё рёбра не перестроенные
      if(i >= Length(RibsArray)-1)then
      isFinish:=True;
    end;
  end;
end;

//Предикат левого поворота
function TForm6.LeftTurn(a,b,p: TPointF): Real;
begin
  Exit(((p.X-a.X) * (b.Y-a.Y)) - ((p.Y-a.Y) * (b.X-a.X)));
end;

//Нахождение площади треугольника
function TForm6.CheckAreaTriangle(a,b,p: TPointF): Real;
begin
  Exit((Abs((a.X-p.X)*(b.Y-p.Y)-(a.Y-p.Y)*(b.X-p.X)) / 2));
end;

//Проверка на нахождения точки в треугольнике
function TForm6.IsInsideTriangle(p: TPointF; triangle: TTriangle): Boolean;
var
  i: Integer;
  sumArea, polygonArea: Real;
begin
  polygonArea := CheckAreaTriangle(triangle.Nodes[0]^,triangle.Nodes[1]^,triangle.Nodes[2]^);
  sumArea:= 0;
  for i := 0 to 1 do
  begin
    sumArea := sumArea + abs(CheckAreaTriangle(triangle.Nodes[i]^,triangle.Nodes[i+1]^, p));
  end;
    sumArea := sumArea + abs(CheckAreaTriangle(triangle.Nodes[2]^,triangle.Nodes[0]^, p));

  if(FloatToStr(sumArea) = FloatToStr(polygonArea)) then
    Exit(True)
  else
    Exit(False);
end;

//Поиск индекса ребра
function TForm6.FindRib(rib: TRib): Integer;
var
  i,index: Integer;
begin
  index:=-1;
  for i:= 0 to Length(RibsArray)-1 do
  begin
    if(IsRibEquals(rib, RibsArray[i]))then
    begin
      index:= RibsArray[i].Index;
      Exit(index);
    end;
  end;

  Exit(index);
end;

//Проверка на равенство рёбер
function TForm6.IsRibEquals(rib1,rib2: TRib): BooLean;
var
  i: Integer;
begin
  if(((rib1.Nodes[0].X + rib1.Nodes[1].X) / 2) = ((rib2.Nodes[0].X + rib2.Nodes[1].X) / 2))then
    if(((rib1.Nodes[0].Y + rib1.Nodes[1].Y) / 2) = ((rib2.Nodes[0].Y + rib2.Nodes[1].Y) / 2)) then
      Exit(True);

  Exit(false);
end;

//Проверка, находится ли точка на ребре
function TForm6.IsOnRib(p: TPointF; rib: TRib): Boolean;
var
  ABLength, APLength, BPLength: Real;
  isOnLine:Boolean;
begin
  isOnLine := false;

  if(rib.Nodes[1].X - rib.Nodes[0].X = 0) then
    if(p.X = rib.Nodes[0].X)then
      Exit(True)
    else Exit(False);
  if (rib.Nodes[1].Y - rib.Nodes[0].Y = 0) then
    if(p.Y = rib.Nodes[0].Y) then
      Exit(True)
    else Exit(False);

  isOnLine := ((p.X-rib.Nodes[0].X) / (rib.Nodes[1].X-rib.Nodes[0].X)) = ((p.Y - rib.Nodes[0].Y) / (rib.Nodes[1].Y - rib.Nodes[0].Y));;

  if(isOnLine) then
  begin
    ABLength:=sqrt(Power(rib.Nodes[1].X-rib.Nodes[0].X,2) + Power(rib.Nodes[1].Y-rib.Nodes[0].Y,2));
    APLength:=sqrt(Power(p.X-rib.Nodes[0].X,2) + Power(p.Y-rib.Nodes[0].Y,2));
    BPLength:=sqrt(Power(p.X-rib.Nodes[1].X,2) + Power(p.Y-rib.Nodes[1].Y,2));
    if(ABLength = APLength + BPLength)then
      Exit(True)
    else
      Exit(False);
  end;

  Exit(False);
end;

//Получение угла через 2 вектора
function TForm6.FindAngle(p1,p2,p3: TPointF): Real;
var
ABLength,BCLength, scalar, res:Real;
sinA,tanA,arctgA: Real;
begin
  ABLength:= sqrt(Power((p2.X-p1.X),2) + Power((p2.Y-p1.Y),2));
  BCLength:= sqrt(Power((p3.X-p1.X),2) + Power((p3.Y-p1.Y),2));

  scalar:= ((p2.X-p1.X) * (p3.X-p1.X)) + ((p2.Y-p1.Y) * (p3.Y-p1.Y));

  res:= scalar/(ABLength * BCLength);

  sinA:= sqrt(1-Power(res,2));
  if(sinA = 1)then
  Exit(90);

  tanA:= sinA/res;
  arctgA:= ArcTan(tanA);
  if(arctgA > 0)then
  Exit(arctgA * (180/PI))
  else if(arctgA < 0) then
  Exit(180 + (arctgA * (180/PI)));

  Exit(0);
end;

end.
