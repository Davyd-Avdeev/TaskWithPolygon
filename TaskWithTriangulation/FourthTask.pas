unit FourthTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,System.Types,System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TRib = class //Класс ребра
    Nodes: array[0..1] of Integer; //Точки
    Triangles: array[0..1] of Integer; // соседине треугольники
    constructor Create(p1,p2, t1,t2: Integer); //Конструктор
  end;
  TTriangle = class //Класс треугольника
    Nodes: array[0..2] of Integer; //Точки
    constructor Create(p1,p2,p3: Integer); //Конструктор
  end;

  TForm6 = class(TForm)
    btnTriangulation: TButton;
    editNumberPoints: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnTriangulationClick(Sender: TObject);
    procedure editNumberPointsClick(Sender: TObject);
    procedure DrawTriangulation();
    procedure SortArray();
    procedure CreateOuterShell();
    procedure CreateCenterPoint();
    procedure LocalitationOutsidePoints();
    procedure CreateInitialTriangles();
    procedure LocalitationPoints();
    procedure Rebuilding();
    procedure RebuildRib(i,p0,p1,p2,p3: Integer);
    procedure testse();

    function LeftTurn(a,b,p: TPointF): Real;
    function CheckAreaTriangle(a,b,p: TPointF): Real;
    function IsInsideTriangle(p: TPointF; t: Integer): Boolean;
    function IsOnRib(p: TPointF; rib: TRib): Boolean;
    function FindRib(rib: TRib): Integer;
    function FindAngle(p1,p2,p3: TPointF): Real;
    function FindCentralPoint(): Boolean;
    procedure FormPaint(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  Form6: TForm6;
  allPointsArray: array of TPoint;
  shellPointsArray, outsidePointsArray:array of Integer;
  TrianglesArray: array of TTriangle;
  RibsArray: array of TRib;
  isFinish: Boolean;
  cpIndex: Integer;

implementation

{$R *.dfm}

constructor TRib.Create(p1,p2,t1,t2: Integer);
begin
  Nodes[0]:= p1; Nodes[1]:= p2;
  Triangles[0]:= t1; Triangles[1]:= t2;
end;

constructor TTriangle.Create(p1,p2,p3: Integer);
begin
  Nodes[0]:= p1; Nodes[1]:= p2; Nodes[2]:= p3;
end;

procedure TForm6.FormCreate(Sender: TObject);
var
  x,y: Integer;
begin
  form6.height:= 1000;
  form6.Width:= 1200;
  Form6.Position:= poScreenCenter;
    y:= (Height - btnTriangulation.Height) - 100;
    x:= (Width - btnTriangulation.Width) - 80;
  btnTriangulation.Top := y;
  btnTriangulation.Left:= x;
    y:= (Height - editNumberPoints.Height) - 140;
    x:= (Width - editNumberPoints.Width) - 80;
  editNumberPoints.Top := y;
  editNumberPoints.Left := x;
  isFinish:= False;
  Canvas.Brush.Color := clRed;
  Canvas.FillRect(ClientRect);
  PatBlt(Canvas.Handle, 0, 0, ClientWidth, ClientHeight, WHITENESS);
end;

procedure TForm6.FormPaint(Sender: TObject);
begin
  if (isFinish) then
    DrawTriangulation();
end;

procedure TForm6.btnTriangulationClick(Sender: TObject);
var
  i,count: Integer;
  p: TPoint;
  s: string;
begin
  s:= editNumberPoints.Text;
  if(TryStrToInt(s,count))then
  else
  begin
    ShowMessage('Неверный ввод числа точек');
    Exit();
  end;

  SetLength(allPointsArray, count);
  for i := 0 to Length(allPointsArray)-1 do
  begin
    p:= Point(Random(1000)+10,Random(900)+10);
    allPointsArray[i] := p;
  end;

  SortArray();
  CreateOuterShell();
  if(FindCentralPoint() = false)then
  begin
    testse();
    Rebuilding();
    isFinish:= True;
    DrawTriangulation();
    btnTriangulation.Enabled:= False;
    Exit();
  end;
  CreateInitialTriangles();

  LocalitationOutsidePoints();
  LocalitationPoints();
  Rebuilding();
  isFinish:= True;
  DrawTriangulation();
  btnTriangulation.Enabled:= False;
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
    Canvas.MoveTo(AllPointsArray[RibsArray[i].Nodes[0]].X, AllPointsArray[RibsArray[i].Nodes[0]].Y);
    Canvas.LineTo(AllPointsArray[RibsArray[i].Nodes[1]].X, AllPointsArray[RibsArray[i].Nodes[1]].Y);
  end;

  Canvas.Pen.Color:= clRed;
  Canvas.Brush.Color:= clRed;
  for i := 0 to Length(AllPointsArray)-1 do
    if(AllPointsArray[i].X <> -1)then
      Canvas.Ellipse(AllPointsArray[i].X-2, AllPointsArray[i].Y-2, AllPointsArray[i].X+2, AllPointsArray[i].Y+2);
  Canvas.Pen.Color:= clBlack;
  Canvas.Brush.Color:= clBlack;
end;

procedure TForm6.editNumberPointsClick(Sender: TObject);
begin
  if(editNumberPoints.Text = 'Кол-во точек') then
    editNumberPoints.Text:= '';
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

  for i := 0 to Length(AllPointsArray)-2 do
  begin
    if(allPointsArray[i].X = allPointsArray[i+1].X)then
      if(allPointsArray[i].Y = allPointsArray[i+1].Y) then
      begin
        allPointsArray[i].X := -1;
        allPointsArray[i].Y := -1;
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
      if(allPointsArray[i].X <> -1)then
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
        shellPointsArray[Length(shellPointsArray)-1]:= j;
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
      if(allPointsArray[k + m].X = -1)then
      begin
        Continue;
      end;
      if(allPointsArray[k + m] = AllPointsArray[shellPointsArray[j]]) then
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

procedure TForm6.CreateCenterPoint();
var
  x, y: Integer;
  p: TPoint;
begin  
  x:= Round((AllPointsArray[0].X + AllPointsArray[Length(shellPointsArray)-1].X)/2);
  y:= Round((AllPointsArray[0].Y + AllPointsArray[Length(shellPointsArray)-1].Y)/2);
  p:= Point(x,y);
  SetLength(AllPointsArray,Length(AllPointsArray)+1);
  AllPointsArray[Length(AllPointsArray)-1]:= p;
  cpIndex:= Length(AllPointsArray)-1;
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
    rib1:= TRib.Create(shellPointsArray[i], shellPointsArray[i+1], -1,-1);

    rib3:= TRib.Create(cpIndex, shellPointsArray[i], -1,-1);
    RibsArray[Length(RibsArray)-2]:= rib1; RibsArray[Length(RibsArray)-1]:= rib3;
    SetLength(TrianglesArray, Length(TrianglesArray)+1);
    triangle:= TTriangle.Create(shellPointsArray[i],shellPointsArray[i+1], cpIndex);
    TrianglesArray[Length(TrianglesArray)-1]:= triangle;

  end;
    SetLength(RibsArray, Length(RibsArray)+2);
    rib1:= TRib.Create(shellPointsArray[Length(shellPointsArray)-1], shellPointsArray[0], -1,-1);
    rib2:= TRib.Create(shellPointsArray[Length(shellPointsArray)-1], cpIndex,-1,-1);
    RibsArray[Length(RibsArray)-2]:= rib1;
    RibsArray[Length(RibsArray)-1]:= rib2;
    SetLength(TrianglesArray, Length(TrianglesArray)+1);
    triangle:= TTriangle.Create(shellPointsArray[Length(shellPointsArray)-1],shellPointsArray[0], cpIndex);
    TrianglesArray[Length(TrianglesArray)-1]:= triangle;

    RibsArray[1].Triangles[0]:= 0;
    RibsArray[1].Triangles[1]:= Length(TrianglesArray)-1;
    j:= 3;
    for i := 1 to Length(ShellPointsArray)-1 do
    begin
      RibsArray[j].Triangles[0]:= i;
      RibsArray[j].Triangles[1]:= i-1;
      j:= j+2;
    end;
    j:= 0;
    for i := 0 to Length(ShellPointsArray)-1 do
    begin
      RibsArray[j].Triangles[0]:= i;
      j:= j+2;
    end;

    //ShowMessage('');
end;

procedure TForm6.testse();
var
  i,j,lastIndex, tempIndex: Integer;
begin
  for i := 0 to Length(shellPointsArray)-2 do
  begin
    SetLength(RibsArray, Length(RibsArray)+1);
    RibsArray[Length(RibsArray)-1]:= TRib.Create(shellPointsArray[i], shellPointsArray[i+1], -1,-1);
  end;
  SetLength(RibsArray, Length(RibsArray)+1);
  RibsArray[Length(RibsArray)-1]:= TRib.Create(shellPointsArray[Length(shellPointsArray)-1], shellPointsArray[0], -1,-1);
  tempIndex:= Length(RibsArray);

  for i := 1 to Length(shellPointsArray)-3 do
  begin
    if(LeftTurn(AllPointsArray[shellPointsArray[i]], AllPointsArray[shellPointsArray[i+1]], AllPointsArray[shellPointsArray[Length(shellPointsArray)-1]]) <> 0) then
    begin
      SetLength(RibsArray, Length(RibsArray)+1);
      RibsArray[Length(RibsArray)-1]:= TRib.Create(shellPointsArray[i], shellPointsArray[Length(shellPointsArray)-1], -1,-1);;

      SetLength(TrianglesArray, Length(TrianglesArray)+1);
      TrianglesArray[Length(TrianglesArray)-1]:= TTriangle.Create(shellPointsArray[i-1], shellPointsArray[i], shellPointsArray[Length(shellPointsArray)-1]);
      lastIndex:= i;
      //
    end
    else
    begin
      SetLength(RibsArray, Length(RibsArray)+1);
      RibsArray[Length(RibsArray)-1]:= TRib.Create(shellPointsArray[i+1], shellPointsArray[lastIndex], -1,-1);
      SetLength(TrianglesArray, Length(TrianglesArray)+1);
      TrianglesArray[Length(TrianglesArray)-1]:= TTriangle.Create(shellPointsArray[i], shellPointsArray[i+1], shellPointsArray[lastIndex]);

    end;
  end;

  SetLength(TrianglesArray, Length(TrianglesArray)+1);
  TrianglesArray[Length(TrianglesArray)-1]:= TTriangle.Create(shellPointsArray[Length(shellPointsArray)-2], shellPointsArray[Length(shellPointsArray)-1], shellPointsArray[lastIndex]);
  j:=0;
  for i := tempIndex to Length(RibsArray)-1 do
  begin
    RibsArray[i].Triangles[0]:= j;
    if(j = lastIndex - 1) then
      RibsArray[i].Triangles[1]:= Length(TrianglesArray)-1
    else
      RibsArray[i].Triangles[1]:= j+1;
    j:=j+1;
  end;
  j:= 0;
  for i := 0 to tempIndex-1 do
  begin
    if(i = lastIndex + 2) then
    j:= j - 1
    else
    RibsArray[i].Triangles[0]:= j;
    j:= j + 1;
  end;
end;

//Поиск всех точек вне оболочки
procedure TForm6.LocalitationOutsidePoints();
var
  i,j:Integer;
  isNotInShell: Boolean;
begin
  SetLength(shellPointsArray, Length(shellPointsArray)+1);
  shellPointsArray[Length(shellPointsArray)-1]:= cpIndex;

  //Находим все точки не попавшие в 'триангуляцию' и добавляем в массив
  for i := 0 to Length(allPointsArray)-1 do
  begin
    if(allPointsArray[i].X = -1)then
    begin
      Continue;
    end;
    isNotInShell:=true;
    for j := 0 to Length(shellPointsArray)-1 do
    begin
      if(i = shellPointsArray[j]) then
      begin
      isNotInShell:= false;
      break;
      end;
    end;
    if(isNotInShell)Then
    begin
      SetLength(outsidePointsArray, Length(outsidePointsArray)+1);
      outsidePointsArray[Length(outsidePointsArray)-1]:= i;
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
      if(IsInsideTriangle(AllPointsArray[OutsidePointsArray[i]], j)) then
      begin
        //Проверяется находится ли точка на ребре
        rib1:= TRib.Create(TrianglesArray[j].Nodes[0],TrianglesArray[j].Nodes[1],-1,-1);
        rib2:= TRib.Create(TrianglesArray[j].Nodes[1],TrianglesArray[j].Nodes[2],-1,-1);
        rib3:= TRib.Create(TrianglesArray[j].Nodes[2],TrianglesArray[j].Nodes[0],-1,-1);
        if((IsOnRib(AllPointsArray[OutsidePointsArray[i]], rib1))
        or (IsOnRib(AllPointsArray[OutsidePointsArray[i]], rib2))
        or (IsOnRib(AllPointsArray[OutsidePointsArray[i]], rib3)))then
        begin
          //Если  да
          //Строится 1-2 новых треугольника и заменяется 1-2 старых,
          //т.е из 1 треугольника строится 2 или из двух - четыре
          if (IsOnRib(AllPointsArray[OutsidePointsArray[i]], rib1)) then
            rib4:= rib1
          else if (IsOnRib(AllPointsArray[OutsidePointsArray[i]], rib2)) then
            rib4:= rib2
          else
            rib4:= rib3;
          count:= 0; tempBool:= false;
          tempIndex1:= FindRib(rib4);
          for k := 0 to 1 do
          begin
            if(RibsArray[tempIndex1].Triangles[k] <> -1) then
              count:= count+1;
          end;
          if(count > 1) then
          begin
            tempBool:= true;
            for k := 0 to 1 do
              if(RibsArray[tempIndex1].Triangles[k] <> j) then
                tempIndex5:= RibsArray[tempIndex1].Triangles[k];
          end;

          for k := 0 to 2 do
          begin
            if(LeftTurn(AllPointsArray[rib4.Nodes[0]], AllPointsArray[rib4.Nodes[1]], AllPointsArray[TrianglesArray[j].Nodes[k]]) <> 0) then
              tempIndex3:= k;
          end;

          SetLength(TrianglesArray, Length(TrianglesArray)+1);
          tempTriangle1:= TTriangle.Create(rib4.Nodes[0], OutsidePointsArray[i], TrianglesArray[j].Nodes[tempIndex3]);
          TrianglesArray[Length(TrianglesArray)-1]:= tempTriangle1;
          rib1:= TRib.Create(OutsidePointsArray[i], TrianglesArray[j].Nodes[tempIndex3], Length(TrianglesArray)-1, -1);
          rib2:= TRib.Create(rib4.Nodes[0], TrianglesArray[j].Nodes[tempIndex3], -1,-1);
          rib3:= TRib.Create(OutsidePointsArray[i], rib4.Nodes[0], Length(TrianglesArray)-1, -1);
          tempIndex2:= FindRib(rib2);

          for k := 0 to 1 do
            if (RibsArray[tempIndex2].Triangles[k] <> -1) then
              if(RibsArray[tempIndex2].Triangles[k] = j) then
                RibsArray[tempIndex2].Triangles[k]:= Length(TrianglesArray)-1;

          SetLength(RibsArray, Length(RibsArray)+2);
          RibsArray[Length(RibsArray)-2]:= rib1;
          RibsArray[Length(RibsArray)-1]:= rib3;

          tempTriangle1:= TTriangle.Create(rib4.Nodes[1], OutsidePointsArray[i],TrianglesArray[j].Nodes[tempIndex3]);
          rib2:= TRib.Create(rib4.Nodes[1], TrianglesArray[j].Nodes[tempIndex3], -1,-1);
          tempIndex2:= FindRib(rib2);
          for k := 0 to 1 do
            if (RibsArray[tempIndex2].Triangles[k] <> -1) then
              if(RibsArray[tempIndex2].Triangles[k] = j) then
                tempIndex4:= k;

          TrianglesArray[j]:= tempTriangle1;
          RibsArray[Length(RibsArray)-2].Triangles[1]:= j;
          RibsArray[tempIndex2].Triangles[tempIndex4]:= j;
          RibsArray[tempIndex1].Nodes[0]:= OutsidePointsArray[i];
          RibsArray[tempIndex1].Nodes[1]:= rib4.Nodes[1];

          if(tempBool) then
          begin
            for k := 0 to 1 do
              if (RibsArray[tempIndex1].Triangles[k] <> -1) then
                if(RibsArray[tempIndex1].Triangles[k] <> tempIndex5) then
                  RibsArray[tempIndex1].Triangles[k]:= j;
          end
          else
            for k := 0 to 1 do
              if (RibsArray[tempIndex1].Triangles[k] <> -1) then
                RibsArray[tempIndex1].Triangles[k]:= j;

          if(tempBool) then
          begin
            for k := 0 to 2 do
              if(LeftTurn(AllPointsArray[RibsArray[tempIndex1].Nodes[0]], AllPointsArray[RibsArray[tempIndex1].Nodes[1]], AllPointsArray[TrianglesArray[tempIndex5].Nodes[k]]) <> 0) then
                tempIndex3:= k;
            for k := 0 to 2 do
              if((k <> tempIndex3) And (TrianglesArray[tempIndex5].Nodes[k] <> RibsArray[tempIndex1].Nodes[1])) then
                tempIndex6:= k;

            SetLength(TrianglesArray, Length(TrianglesArray)+1);
            tempTriangle1:= TTriangle.Create(OutsidePointsArray[i], RibsArray[tempIndex1].Nodes[1], TrianglesArray[tempIndex5].Nodes[tempIndex3]);
            TrianglesArray[Length(TrianglesArray)-1]:= tempTriangle1;
            for m := 0 to 1 do
              if (RibsArray[tempIndex1].Triangles[m] <> -1) then
                if(RibsArray[tempIndex1].Triangles[m] <> j) then
                  RibsArray[tempIndex1].Triangles[m]:= Length(TrianglesArray)-1;

            rib2:= TRib.Create(RibsArray[tempIndex1].Nodes[1], TrianglesArray[tempIndex5].Nodes[tempIndex3],-1,-1);
            tempIndex2:= FindRib(rib2);
            for m := 0 to 1 do
              if(RibsArray[tempIndex2].Triangles[m] <> -1) then
                if(RibsArray[tempIndex2].Triangles[m] = tempIndex5) then
                  RibsArray[tempIndex2].Triangles[m]:= Length(TrianglesArray)-1;

            rib1:= TRib.Create(OutsidePointsArray[i], TrianglesArray[tempIndex5].Nodes[tempIndex3], Length(TrianglesArray)-1,-1);
            SetLength(RibsArray,Length(RibsArray)+1);
            RibsArray[Length(RibsArray)-1]:= rib1;

            tempTriangle1:= TTriangle.Create(OutsidePointsArray[i], TrianglesArray[tempIndex5].Nodes[tempIndex3], TrianglesArray[tempIndex5].Nodes[tempIndex6]);
            rib2:= TRib.Create(TrianglesArray[tempIndex5].Nodes[tempIndex3], TrianglesArray[tempIndex5].Nodes[tempIndex6],-1,-1);
            tempIndex2:= FindRib(rib2);
            for m := 0 to 1 do
              if (RibsArray[tempIndex2].Triangles[m] <> -1) then
                if(RibsArray[tempIndex2].Triangles[m] = tempIndex5) then
                  tempIndex1:= m;

            TrianglesArray[tempIndex5]:= tempTriangle1;

            RibsArray[tempIndex2].Triangles[tempIndex1]:= tempIndex5;
            RibsArray[Length(RibsArray)-1].Triangles[1]:= tempIndex5;
            RibsArray[Length(RibsArray)-2].Triangles[1] := tempIndex5;
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
          rib4:= TRib.Create(TrianglesArray[j].Nodes[0],TrianglesArray[j].Nodes[1],-1,-1);
          tempIndex1:= FindRib(rib4);

          rib1:= TRib.Create(OutsidePointsArray[i], TrianglesArray[j].Nodes[0], Length(TrianglesArray)-1, -1);
          rib3:= TRib.Create(TrianglesArray[j].Nodes[1], OutsidePointsArray[i], Length(TrianglesArray)-1,-1);

          SetLength(RibsArray, Length(RibsArray)+2);
          RibsArray[Length(RibsArray)-2]:= rib1; RibsArray[Length(RibsArray)-1]:= rib3;

          for m := 0 to 1 do
            if (RibsArray[tempIndex1].Triangles[m] <> -1) then
              if(RibsArray[tempIndex1].Triangles[m] = j) then
                RibsArray[tempIndex1].Triangles[m]:= Length(TrianglesArray)-1;

          SetLength(TrianglesArray, Length(TrianglesArray)+1);
          tempTriangle1:= TTriangle.Create(OutsidePointsArray[i], TrianglesArray[j].Nodes[1], TrianglesArray[j].Nodes[2]);
          TrianglesArray[Length(TrianglesArray)-1]:= tempTriangle1;

          rib4:= TRib.Create(TrianglesArray[j].Nodes[1],TrianglesArray[j].Nodes[2],-1,-1);
          tempIndex1:= FindRib(rib4);

          RibsArray[Length(RibsArray)-1].Triangles[1]:=  Length(TrianglesArray)-1;

          SetLength(RibsArray, Length(RibsArray)+1);
          rib1:= TRib.Create(OutsidePointsArray[i], TrianglesArray[j].Nodes[2], Length(TrianglesArray)-1, -1);

          RibsArray[Length(RibsArray)-1]:= rib1;

          for m := 0 to 1 do
            if (RibsArray[tempIndex1].Triangles[m] <> -1) then
              if(RibsArray[tempIndex1].Triangles[m] = j) then
                RibsArray[tempIndex1].Triangles[m]:= Length(TrianglesArray)-1;

          tempTriangle1:= TTriangle.Create(OutsidePointsArray[i], TrianglesArray[j].Nodes[2], TrianglesArray[j].Nodes[0]);

          rib4:= TRib.Create(TrianglesArray[j].Nodes[2],TrianglesArray[j].Nodes[0],-1,-1);
          tempIndex1:= FindRib(rib4);

          for m := 0 to 1 do
            if (RibsArray[tempIndex1].Triangles[m] <> -1) then
              if(RibsArray[tempIndex1].Triangles[m] = j) then
                tempIndex2:= m;

          TrianglesArray[j]:= tempTriangle1;
          RibsArray[Length(RibsArray)-3].Triangles[1]:= j;
          RibsArray[Length(RibsArray)-1].Triangles[1]:= j;
          RibsArray[tempIndex1].Triangles[tempIndex2]:= j;

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
  p0,p1,p2,p3:Integer;
  isFinish:Boolean;
  angle1,angle2: Real;
begin
  isFinish:=False;
  count:=0;
  //Проверяются все ребра, пока не будет найдено не одно неправильное
  while isFinish = False do
  begin
    for i := 0 to Length(RibsArray)-1 do
    begin
      p0:= -1; p1:= -1; p2:= -1; p3:= -1;
      count:=0;
      for j := 0 to 1 do
        if(RibsArray[i].Triangles[j] <> -1)then
          count:= count+1;
      if(count < 2) then
        Continue;

      for j := 0 to 2 do
        if(LeftTurn(AllPointsArray[RibsArray[i].Nodes[0]], AllPointsArray[RibsArray[i].Nodes[1]], AllPointsArray[TrianglesArray[RibsArray[i].Triangles[0]].Nodes[j]]) <> 0)then
          p0:= TrianglesArray[RibsArray[i].Triangles[0]].Nodes[j];
      for j := 0 to 2 do
        if(LeftTurn(AllPointsArray[RibsArray[i].Nodes[0]], AllPointsArray[RibsArray[i].Nodes[1]], AllPointsArray[TrianglesArray[RibsArray[i].Triangles[1]].Nodes[j]]) <> 0)then
          p2:= TrianglesArray[RibsArray[i].Triangles[1]].Nodes[j];

      p1:= RibsArray[i].Nodes[0];
      p3:= RibsArray[i].Nodes[1];

      //Проверяется больше ли оба угла 90* TestF
      //angle1:= TestF(AllPointsArray[p0],AllPointsArray[p1],AllPointsArray[p3]);
      //angle2:= TestF(AllPointsArray[p2],AllPointsArray[p1],AllPointsArray[p3]);
      angle1:= FindAngle(AllPointsArray[p0],AllPointsArray[p1],AllPointsArray[p3]);
      angle2:= FindAngle(AllPointsArray[p2],AllPointsArray[p1],AllPointsArray[p3]);
      if((angle1 > 90) And (angle2 > 90))then
      begin
        //Eсли да перестраевается
        RebuildRib(i, p0,p1,p2,p3);
        break;
      end
      else if ((angle1 <= 90) And (angle2 <= 90)) then
      begin
        if(i >= Length(RibsArray)-1)then
        isFinish:=True;
        Continue;
      end
      else if(angle1 + angle2 > 180) then
      begin
        RebuildRib(i, p0,p1,p2,p3);
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

procedure TForm6.RebuildRib(i, p0,p1,p2,p3: Integer);
var
  rib1: TRib;
  ribIndex1,ribIndex2,ribIndex3,ribIndex4,j: Integer;
  tIndex1,tIndex2,tIndex3,tIndex4: Integer;
  triangle1, triangle2: TTriangle;
begin
  tIndex1:=-1; tIndex2:=-1; tIndex3:=-1; tIndex4:=-1;
  ribIndex1:=-1; ribIndex2:=-1; ribIndex3:=-1; ribIndex4:=-1;

  rib1:= TRib.Create(p1,p0,-1,-1);
  ribIndex1:= FindRib(rib1);
  for j := 0 to 1 do
    if (RibsArray[ribIndex1].Triangles[j] <> -1) then
      if (RibsArray[ribIndex1].Triangles[j] = RibsArray[i].Triangles[0]) then
        TIndex1:= j;

  rib1:= TRib.Create(p3,p0,-1,-1);
  ribIndex2:= FindRib(rib1);
  for j := 0 to 1 do
    if (RibsArray[ribIndex2].Triangles[j] <> -1) then
      if (RibsArray[ribIndex2].Triangles[j] = RibsArray[i].Triangles[0]) then
        TIndex2:= j;

  rib1:= TRib.Create(p1,p2,-1,-1);
  ribIndex3:= FindRib(rib1);
  for j := 0 to 1 do
    if (RibsArray[ribIndex3].Triangles[j] <> -1) then
      if (RibsArray[ribIndex3].Triangles[j] = RibsArray[i].Triangles[1]) then
        TIndex3:= j;

  rib1:= TRib.Create(p3,p2,-1,-1);
  ribIndex4:= FindRib(rib1);
  for j := 0 to 1 do
    if (RibsArray[ribIndex4].Triangles[j] <> -1) then
      if (RibsArray[ribIndex4].Triangles[j] = RibsArray[i].Triangles[1]) then
       TIndex4:= j;

  triangle1:= TTriangle.Create(p0,p2,p1);
  triangle2:= TTriangle.Create(p0,p2,p3);

  TrianglesArray[RibsArray[i].Triangles[0]]:= triangle1;
  TrianglesArray[RibsArray[i].Triangles[1]]:= triangle2;

  RibsArray[ribIndex1].Triangles[tIndex1]:= RibsArray[i].Triangles[0];

  RibsArray[ribIndex2].Triangles[tIndex2]:= RibsArray[i].Triangles[1];

  RibsArray[ribIndex3].Triangles[tIndex3]:= RibsArray[i].Triangles[0];

  RibsArray[ribIndex4].Triangles[tIndex4]:= RibsArray[i].Triangles[1];

  tIndex1:= RibsArray[i].Triangles[0];
  tIndex2:= RibsArray[i].Triangles[1];

  RibsArray[i].Nodes[0]:= p0;
  RibsArray[i].Nodes[1]:= p2;
  RibsArray[i].Triangles[0]:= tIndex1;
  RibsArray[i].Triangles[1]:= tIndex2;
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
function TForm6.IsInsideTriangle(p: TPointF; t: Integer): Boolean;
var
  i: Integer;
  sumArea, polygonArea: Real;
begin
  polygonArea := CheckAreaTriangle(AllPointsArray[TrianglesArray[t].Nodes[0]],AllPointsArray[TrianglesArray[t].Nodes[1]],AllPointsArray[TrianglesArray[t].Nodes[2]]);
  sumArea:= 0;
  for i := 0 to 1 do
  begin
    sumArea := sumArea + abs(CheckAreaTriangle(AllPointsArray[TrianglesArray[t].Nodes[i]],AllPointsArray[TrianglesArray[t].Nodes[i+1]], p));
  end;
    sumArea := sumArea + abs(CheckAreaTriangle(AllPointsArray[TrianglesArray[t].Nodes[2]],AllPointsArray[TrianglesArray[t].Nodes[0]], p));

  if(FloatToStr(sumArea) = FloatToStr(polygonArea)) then
    Exit(True)
  else
    Exit(False);
end;

//Поиск индекса ребра
function TForm6.FindRib(rib: TRib): Integer;
var
  i: Integer;
begin
  for i:= 0 to Length(RibsArray)-1 do
  begin
    if(rib.Nodes[0] = RibsArray[i].Nodes[0])then
    begin
      if(rib.Nodes[1] = RibsArray[i].Nodes[1]) then
        Exit(i);
    end
    else
    if(rib.Nodes[0] = RibsArray[i].Nodes[1]) then
      if(rib.Nodes[1] = RibsArray[i].Nodes[0]) then
         Exit(i);
  end;
end;

//Проверка, находится ли точка на ребре
function TForm6.IsOnRib(p: TPointF; rib: TRib): Boolean;
var
  ABLength, APLength, BPLength: Real;
  isOnLine:Boolean;
begin
  isOnLine := false;

  if(AllPointsArray[rib.Nodes[1]].X - AllPointsArray[rib.Nodes[0]].X = 0) then
    if(p.X = AllPointsArray[rib.Nodes[0]].X)then
      Exit(True)
    else Exit(False);
  if (AllPointsArray[rib.Nodes[1]].Y - AllPointsArray[rib.Nodes[0]].Y = 0) then
    if(p.Y = AllPointsArray[rib.Nodes[0]].Y) then
      Exit(True)
    else Exit(False);

  isOnLine := ((p.X-AllPointsArray[rib.Nodes[0]].X) / (AllPointsArray[rib.Nodes[1]].X-AllPointsArray[rib.Nodes[0]].X)) = ((p.Y - AllPointsArray[rib.Nodes[0]].Y) / (AllPointsArray[rib.Nodes[1]].Y - AllPointsArray[rib.Nodes[0]].Y));;
  if(isOnLine) then
    Exit(True)
  else
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
