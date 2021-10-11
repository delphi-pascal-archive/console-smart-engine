unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ConsoleCMDS, Scriptix, AppEvnts;

type
  TForm1 = class(TForm)
    ApplicationEvents1: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 procedure NewString(S: string);
 procedure ExecCmd;
var
  Form1: TForm1;
type  TConsoleMethod   = procedure(params:array of string;paramc:byte;var cout:string;var iout:TBitmap) of Object;

implementation

{$R *.dfm}
const
  wDOS:string='°±Ііґµ¶·ё№є»јЅѕїАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧрЩЪЫЬЭЮЯтуфхцчшщсыьэюяШъЂЃ‚ѓ„…†‡€‰Љ‹ЊЌЋЏђ‘’“”•–—™љ›њќћџ ЎўЈ¤Ґ¦§Ё©Є«¬­®Їабвгдежзийклмноп';
  wWIN:string='ЂЃ‚ѓ„…†‡€‰Љ‹ЊЌЋЏђ‘’“”•–—™љ›њќћџ ЎўЈ¤Ґ¦§Ё©Є«¬­®Ї°±Ііґµ¶·ё№є»јЅѕїАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюя';

const c_caret_w=6;
      c_caret_h=12;
      c_caret_x=8;
      c_caret_y=18;
      c_console_header_h=14;

var   v_caret_x,v_caret_y:dword;v_caret_alpha:byte;v_caret_alpha_reverse:boolean;
      v_console_forecolor:dword;
      v_console_buff: TBitmap;
      v_console_cmd:string;
      v_console_input:boolean;
      v_console_cmds:TConsoleCommands;
      v_console_vscript:TScriptCommand;
      v_console_prompt:string;
      v_console_title:string;
      

      WantReturn:Boolean;
function GetUserFromWindows: string;
var
  UserName : string;
  UserNameLen : Dword;
begin
  UserNameLen := 255;
  SetLength(userName, UserNameLen);

  if GetUserName(PChar(UserName), UserNameLen) then
    Result := Copy(UserName,1,UserNameLen - 1)
  else
    Result := 'Unknown';
end;
function GetComputerFromWindows: string;
var
  UserName : string;
  UserNameLen : Dword;
begin
  UserNameLen := 255;
  SetLength(userName, UserNameLen);

  if GetComputerName(PChar(UserName), UserNameLen) then
    Result := Copy(UserName,1,UserNameLen - 1)
  else
    Result := 'Unknown';
end;

function DosToWin(source:string):string ;
var T:string; a:integer; i:integer; C:char;__TEMP_I:integer;
begin
	__TEMP_I:=length(source);
    for i:=1 to __TEMP_I
 do begin
    C := source[i];
    if ord(C) <128 then
      T := T + C
    else begin
      a := pos(C,wDOS);
      if a = 0 then
        T := T + '?'
      else
        T := T + copy(wWIN,a,1);
      end;
  end;

  result := T;
end;



function WinToDos(source:string):string ;
var T:string; a:integer; i:integer; C:char;__TEMP_I:integer;
begin
	__TEMP_I:=length(source);
    for i:=1 to __TEMP_I do begin
    C := source[i];
    if ord(C) <128 then
      T := T + C
    else begin
      a := pos(C,wWIN);
      if a = 0 then
        T := T + '?'
      else
        T := T + copy(wDOS,a,1);
      end;
  end;

  result := T;
end;

function GetDosOutput(const CommandLine: string; const Command: string): string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of Char;
  BytesRead: Cardinal;
  WorkDir, Line: String;
begin
  Application.ProcessMessages;
  with SA do
  begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  // создаём пайп для перенаправления стандартного вывода
  CreatePipe(StdOutPipeRead,  // дескриптор чтения
             StdOutPipeWrite, // дескриптор записи
             @SA,              // аттрибуты безопасности
             0                // количество байт принятых для пайпа - 0 по умолчанию
             );
  try
    // Создаём дочерний процесс, используя StdOutPipeWrite в качестве стандартного вывода,
    // а так же проверяем, чтобы он не показывался на экране.
    with SI do
    begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // стандартный ввод не перенаправляем
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;

    // Запускаем компилятор из командной строки
    WorkDir := Sysutils.GetCurrentDir; //ExtractFilePath(CommandLine);
    WasOK := CreateProcess(nil, PChar(CommandLine), nil, nil, True, 0, nil, PChar(WorkDir), SI, PI);

    // Теперь, когда дескриптор получен, для безопасности закрываем запись.
    // Нам не нужно, чтобы произошло случайное чтение или запись.
    CloseHandle(StdOutPipeWrite);
    // если процесс может быть создан, то дескриптор, это его вывод
    if not WasOK then //asm nop end
      NewString(#2'CError at console! '#2'7Command ['#2'2'+Command+#2+'7] does not recognized')
    else
      try
        // получаем весь вывод до тех пор, пока DOS-приложение не будет завершено
        Line := '';
        repeat
          // читаем блок символов (могут содержать возвраты каретки и переводы строки)
          WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);

          // есть ли что-нибудь ещё для чтения?
          if BytesRead > 0 then
          begin
            // завершаем буфер PChar-ом
            Buffer[BytesRead] := #0;
            // добавляем буфер в общий вывод
            Line := Line + Buffer;
          end;
        until not WasOK or (BytesRead = 0);
        // ждём, пока завершится консольное приложение
        WaitForSingleObject(PI.hProcess, INFINITE);
      finally
        // Закрываем все оставшиеся дескрипторы
        CloseHandle(PI.hThread);
        CloseHandle(PI.hProcess);
      end;
  finally
      result:= Line;
      CloseHandle(StdOutPipeRead);
  end;
end;

procedure ScrollPixel(Pixel:Integer);var flac:TBitmap;begin
    flac:=TBitmap.Create;
    flac.Canvas.Brush.Color:=clBlack;
    flac.Width := v_console_buff.Width;
    flac.Height := v_console_buff.Height;
    flac.PixelFormat :=pf24bit;
    flac.Canvas.FillRect(rect(0,0,flac.Width,flac.Height));
    flac.Canvas.Draw(0,-(Pixel+1),v_console_buff);
    //flac.Canvas.CopyRect(rect(0,0,v_console_buff.Width,v_console_buff.Height),v_console_buff.Canvas,rect(0,c_caret_h+1,v_console_buff.Width,v_console_buff.Height-c_caret_h+1));
    v_console_buff.Canvas.Draw(0,0,flac);
    Form1.Canvas.Draw(1,Pixel+1,v_console_buff);
    flac.Free;
end;

procedure ScrollLine;var flac:TBitmap;begin
    flac:=TBitmap.Create;
    flac.Canvas.Brush.Color:=clBlack;
    flac.Width := v_console_buff.Width;
    flac.Height := v_console_buff.Height;
    flac.PixelFormat :=pf24bit;
    flac.Canvas.FillRect(rect(0,0,flac.Width,flac.Height));
    flac.Canvas.Draw(0,-(c_caret_h+1),v_console_buff);
    //flac.Canvas.CopyRect(rect(0,0,v_console_buff.Width,v_console_buff.Height),v_console_buff.Canvas,rect(0,c_caret_h+1,v_console_buff.Width,v_console_buff.Height-c_caret_h+1));
    v_console_buff.Canvas.Draw(0,0,flac);
    Form1.Canvas.Draw(1,c_console_header_h+1,v_console_buff);
    flac.Free;
end;

procedure NewLine;begin

        // Check need scroll line or not
        if v_caret_y+c_caret_h+1>=form1.Height-c_caret_h-c_caret_y-c_console_header_h then begin
            v_caret_x:=c_caret_x;
            scrollLine;
            Form1.Repaint;
            Exit;
        end;

        v_caret_x:=c_caret_x;
        v_caret_y:=v_caret_y+c_caret_h+1;
        Form1.Repaint;
end;


procedure NewGraph(imgout:TBitmap);var scroll:boolean;begin
      scroll:=false;
      if v_caret_y+imgout.Height+1>=form1.Height-c_caret_h-c_caret_y-c_console_header_h then begin
      ScrollPixel(imgout.Height);
      //v_caret_y:=v_caret_y-c_caret_h+1;
      scroll:=true;
      end;
      if scroll then begin
        v_console_buff.canvas.Draw(v_caret_x,v_caret_y-imgout.Height,imgout);
        form1.canvas.Draw(v_caret_x+1,v_caret_y+c_console_header_h+1-imgout.Height,imgout);
      end else begin
        v_console_buff.canvas.Draw(v_caret_x,v_caret_y,imgout);
        form1.canvas.Draw(v_caret_x+1,v_caret_y+c_console_header_h+1,imgout);
      end;
      if scroll = false then v_caret_y:=v_caret_y+imgout.Height+1;
      newLine;
      form1.Repaint;
end;


function ReplaceC(S: string):String;begin
    Result:=S;
    Result:=StringReplace(Result,'\ce',#2'C',[rfReplaceAll]);
    Result:=StringReplace(Result,'\n',#10,[rfReplaceAll]);
    Result:=StringReplace(Result,'\cn',#2'7',[rfReplaceAll]);
    Result:=StringReplace(Result,'\%',#2,[rfReplaceAll]);
    Result:=StringReplace(Result,'%USERNAME%',GetUserFromWindows,[rfReplaceAll]);
    Result:=StringReplace(Result,'%CD%',GetCurrentDir,[rfReplaceAll]);
    Result:=StringReplace(Result,'%CD_PATH%',Copy(GetCurrentDir,3,length(GetCurrentDir)),[rfReplaceAll]);
    Result:=StringReplace(Result,'%COMPUTERNAME%',GetComputerFromWindows,[rfReplaceAll]);

end;

procedure RunScriptFromFile(AFile:string);var lines:TStrings;i:integer; begin

    if fileexists(AFile) = false then begin NewString(ReplaceC('\ceUnable to execute!\cn Cannot find file: \%5"'+AFile+'"\cn')); exit; end;

    lines:=TStringList.Create;
    lines.LoadFromFile(AFile);
    for i:=0 to lines.Count - 1 do begin
        v_console_cmd:=Trim(lines.Strings[i]);
        if copy(v_console_cmd,1,1)=';' then continue;
        if length(v_console_cmd)=0 then continue;
        ExecCmd; 
    end;

    lines.Free;

end;

procedure ExecCmd;var imgout:TBitmap;VScriptComp:TComp;exec:ShortInt;cn:integer;VScriptMethod:TScriptMethod;SM:TConsoleMethod;FF,SS,UP:string;i:integer;com:boolean;commA:STRING;params:array[0..255] of string; begin

  com:=false;
  cn:=0;
  SS:='';
  params[0]:=v_console_cmd;
  comma:='';

  v_console_buff.Canvas.Font.Color := clWhite;
  v_console_buff.Canvas.Font.Style:=[];

  form1.Canvas.Font:= v_console_buff.Canvas.Font;



  for i:=1 to length(v_console_cmd)do begin
      if v_console_cmd[i]='"' then begin com:=not com;continue;end;
      if v_console_cmd[i]=' ' then if com=false then begin
        
        if cn=0 then begin inc(cn);comma:=SS; end else begin params[cn]:=SS;inc(cn);end;
        SS:='';
        continue;
      end;

      //if com=false then
      SS:=SS + v_console_cmd[i];
  end;

  if length(SS)>0 then begin
        
        if cn=0 then begin inc(cn);comma:=SS; end else begin params[cn]:=SS;inc(cn);end;
        SS:='';
  end;

  // std commands
  up:=uppercase(comma);
  if up='CLS' then begin
      v_console_buff.canvas.Brush.Color :=clBlack;
       v_console_buff.canvas.Pen.Width :=1;
       v_console_buff.canvas.Pen.Color:=clGreen;
       v_console_buff.canvas.FillRect(Rect(0,0,v_console_buff.Width,v_console_buff.Height));
       form1.Paint;

      exit;
  end;
  if up='EXEC' then begin
      if cn-1=0 then begin
          NewString(#2'7Execute batch file');
          NewLine;
          NewString(#2'7 uses: exec <file>');
          NewLine;
          exit;
      end;
      RunScriptFromFile(params[1]);
      NewLine;
      exit;
  end;

  if up='PROMPT' then begin
      if cn-1=0 then begin
          NewString(#2'7Assign new prompt line');
          NewLine;
          NewString(#2'7 uses: prompt <string>');
          NewLine;

          exit;
      end;
      v_console_prompt:=(params[1]);
      NewLine;
      exit;
  end;

  if up='TITLE' then begin
      if cn-1=0 then begin
          NewString(#2'7Set new title line for console');
          NewLine;
          NewString(#2'7 uses: title <string>');
          NewLine;

          exit;
      end;
      v_console_title:=(params[1]);
      NewLine;
      exit;
  end;
  if up='ECHO' then begin
      if cn-1=0 then begin
          NewString(#2'7Shows string on screen');
          NewLine;
          NewString(#2'7 uses: echo <string>');
          NewLine;

          exit;
      end;
      NewString(#2'7'+ReplaceC(params[1]));
      NewLine;
      exit;
  end;
  if up='EXIT' then begin
      if cn-1=0 then begin
          Halt;
      end;
      Halt;
  end;



  TMethod(SM).Data:=v_console_cmds;
  TMethod(SM).Code:=v_console_cmds.MethodAddress('___'+comma);

  If Assigned(SM) then begin
    FF:='';
    SM(params,cn-1,FF,imgout);
    if Assigned(imgout) then begin
      NewGraph(imgout);
    end;
    if length(FF)<>0 then  begin WantReturn:=True;NewString(#2+'7'+ReplaceC(FF));end else WantReturn:=False;
    exit;
  end;

  //VSCRIPT

  TMethod(VScriptMethod).Data:=v_console_vscript;
  TMethod(VScriptMethod).Code:=v_console_vscript.MethodAddress('___'+comma);

  If Assigned(VScriptMethod) then begin
    FF:='';
    VScriptMethod(VScriptComp,params,exec,FF);
    if length(FF)<>0 then  begin WantReturn:=True;NewString(#2+'7'+escape_string(ReplaceC(FF)));end else WantReturn:=False;
    exit;
  end;



    WantReturn:=True;


    NewString(#2+'7'+DosToWin(GetDosOutput({WinToDos}(v_console_cmd),comma)));
end;

procedure Prompt();begin

    NewString(#2'F'+ReplaceC(v_console_prompt));

    form1.Canvas.Font.Color:=v_console_forecolor;
    v_console_buff.Canvas.Font.Color:=v_console_forecolor;


end;

procedure NewChar(C: Char);


begin
    //removes caret
    form1.canvas.Brush.Color :=RGB(0,0,0);
    form1.canvas.FillRect(rect(v_caret_x+1,v_caret_y+c_console_header_h+1,c_caret_w+v_caret_x+c_console_header_h,c_caret_h+v_caret_y+c_console_header_h+1));



    if c=#8 then begin  //backspace
    if length(v_console_cmd)=0 then exit;
    C:=copy(v_console_cmd,length(v_console_cmd),1)[1];
    v_console_cmd:=copy(v_console_cmd,1,length(v_console_cmd)-1);

    if v_caret_x <= c_caret_x then begin
    v_caret_y:=v_caret_y-c_caret_h+1;
    //v_caret_x:=
    end;

    v_caret_x:=v_caret_x-v_console_buff.canvas.TextWidth(C){+1};
    SetBkMode(v_console_buff.Canvas.Handle,OPAQUE);
    v_console_buff.Canvas.Font.Color :=clblack;
    form1.Canvas.Font.Color :=clBlack;
    v_console_buff.canvas.TextOut(v_caret_x,v_caret_y,C);
    form1.canvas.TextOut(v_caret_x+1,v_caret_y+c_console_header_h+1,C);
    v_console_buff.Canvas.Font.Color :=clGreen;
    v_console_buff.Canvas.Font.Style :=[];

    form1.Canvas.Font:=v_console_buff.Canvas.Font;

    //form1.Canvas.Font.Color :=clGreen;

        
    exit;
    end;

    if c=#10 then begin
    NewLine;
    exit;
    end;

    if c=#13 then begin
    if  v_console_cmd='' then begin
                NewLine;
                Prompt;
                exit;

    end;
        NewLine;

        ExecCmd;
        v_console_cmd:='';
        if WantReturn then NewLine;
        NewLine;
        Prompt;
    exit;
    end;

    //Check need new line or not

    if 1+(v_caret_x+v_console_buff.canvas.TextWidth(C))-c_caret_x*2>=Form1.Width-(c_caret_x*2)-c_caret_w  then begin

        NewLine;
    end;



    v_console_buff.Canvas.Brush.Style :=bsClear;
    SetBkMode(v_console_buff.Canvas.Handle,TRANSPARENT);
    form1.Canvas.Brush.Style :=bsClear;
    SetBkMode(form1.Canvas.Handle,TRANSPARENT);
    v_console_buff.canvas.TextOut(v_caret_x,v_caret_y,C);
    form1.canvas.TextOut(v_caret_x+1,v_caret_y+c_console_header_h+1,C);
    v_console_cmd:=v_console_cmd+C;
    v_caret_x:=v_caret_x+v_console_buff.canvas.TextWidth(C){+1};
end;
procedure SetForecolor(C: Char);begin
    case C of
    '0':v_console_buff.Canvas.Font.Color :=clBlack;
    '1':v_console_buff.Canvas.Font.Color :=clNavy;
    '2':v_console_buff.Canvas.Font.Color :=clGreen;
    '3':v_console_buff.Canvas.Font.Color :=clTeal;
    '4':v_console_buff.Canvas.Font.Color :=clMaroon;
    '5':v_console_buff.Canvas.Font.Color :=clPurple;
    '6':v_console_buff.Canvas.Font.Color :=clOlive;
    '7':v_console_buff.Canvas.Font.Color :=clSilver;
    '8':v_console_buff.Canvas.Font.Color :=clGray;
    '9':v_console_buff.Canvas.Font.Color :=clBlue;
    'A':v_console_buff.Canvas.Font.Color :=clLime;
    'B':v_console_buff.Canvas.Font.Color :=clAqua;
    'C':v_console_buff.Canvas.Font.Color :=clRed;
    'D':v_console_buff.Canvas.Font.Color :=clFuchsia;
    'E':v_console_buff.Canvas.Font.Color :=clYellow;
    'F':v_console_buff.Canvas.Font.Color :=clWhite;
    '*':v_console_buff.Canvas.Font.Style :=[fsBold];
    '^':v_console_buff.Canvas.Font.Style :=[];
    end;

    Form1.Canvas.Font := v_console_buff.Canvas.Font;

end;

procedure NewString(S: string);var i:integer;begin
    Form1.Tag:=1;
    S := StringReplace(S,#13,'',[rfReplaceAll]);

    for i:=1 to length(S) do
    case ord(S[i])of
    {foreground}2:SetForecolor(copy(S,i+1,1)[1]);
    else if ((copy(S,i-1,1)<>#2))then
    NewChar(S[i]);
    end;
    v_console_buff.Canvas.Font.Color :=clGreen;
    Form1.Canvas.Font.Color := v_console_buff.Canvas.Font.Color;
    
    v_console_cmd:='';
    Form1.Tag:=0;
end;

procedure Idle;begin
    //if GetForegroundWindow<>Form1.Handle then
end;
procedure BlinkCaret;begin
    if GetForegroundWindow<>Form1.Handle then begin
        v_caret_alpha:=4;
        Form1.canvas.Brush.Color :=RGB(0,v_caret_alpha,0);
        Form1.canvas.FillRect(rect(v_caret_x+1,v_caret_y+c_console_header_h+1,c_caret_w+v_caret_x+1,c_caret_h+v_caret_y+c_console_header_h+1));

        exit;
    end;
    case v_caret_alpha_reverse of
    false:begin
        if v_caret_alpha >= 248 then  v_caret_alpha_reverse:= true;
        v_caret_alpha:=v_caret_alpha+4;
    end;
    true:begin
        if v_caret_alpha <= 4 then  v_caret_alpha_reverse:= false;
        v_caret_alpha:=v_caret_alpha-4;
    end;
    end;


    Form1.canvas.Brush.Color :=RGB(0,v_caret_alpha,0);
    Form1.canvas.FillRect(rect(v_caret_x+1,v_caret_y+c_console_header_h+1,c_caret_w+v_caret_x+1,c_caret_h+v_caret_y+c_console_header_h+1));

end;


procedure TForm1.FormCreate(Sender: TObject);
begin
   v_console_cmds:=TConsoleCommands.Create;
   v_console_vscript:=TScriptCommand.Create;
   
   //BlendOnMove:=True;
   v_console_cmd:='';
   v_console_buff:=TBitmap.Create;
   v_console_buff.Width:=Width-2;
   v_console_buff.Height:=Height-c_console_header_h-2;
   v_console_buff.PixelFormat:=pf24bit;
                                       // v_console_buff.Canvas
   v_caret_x:=c_caret_x;
   // top
   v_caret_y:=c_caret_y-c_console_header_h;
   //bottom
   v_caret_y:=Height-c_caret_y-c_caret_h-8;
   
   v_caret_alpha:=0;
   v_caret_alpha_reverse:=false;
   v_console_forecolor:=clGreen;

   v_console_buff.canvas.Brush.Color :=clGreen;
   v_console_buff.canvas.FillRect(rect(c_caret_x,c_caret_y,c_caret_w+c_caret_x,c_caret_h+c_caret_y));



   SetTimer(0,1,10,@BlinkCaret);
   SetTimer(0,2,10,@Idle);
   DoubleBuffered:=True;
   //
   v_console_buff.canvas.Brush.Color :=clBlack;
    v_console_buff.canvas.Pen.Width :=1;
    v_console_buff.canvas.Pen.Color:=clGreen;
    v_console_buff.canvas.FillRect(Rect(0,0,v_console_buff.Width,v_console_buff.Height));


    v_console_buff.canvas.Brush.Color :=clBlack;
    v_console_buff.canvas.Pen.Width :=1;
    v_console_buff.canvas.Pen.Color:=clGreen;
    v_console_buff.canvas.Font.Color := v_console_forecolor;
    v_console_buff.canvas.Font.Name :='Consolas';
    v_console_buff.Canvas.font.Charset :=RUSSIAN_CHARSET;


    canvas.Brush := v_console_buff.canvas.Brush;
    canvas.Pen :=v_console_buff.canvas.Pen;
    canvas.Font := v_console_buff.canvas.Font;

    v_console_prompt:='\%7%CD%>';
    v_console_title:='Console';

    // autorun
    if FileExists(ParamStr(0)+'.smc') then begin
        RunScriptFromFile(ParamStr(0)+'.smc');
    end;

    Prompt;

    v_console_input:=true;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
    NewChar(Key);
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  const sc_dragmove = $f012;
begin
  if y > c_console_header_h then exit;

  releasecapture;
  perform(wm_syscommand, sc_dragmove, 0);
end;


procedure TForm1.FormPaint(Sender: TObject);var S,U:String;I,TW,_BEGIN,_CONT:integer;
f:tfont;
begin

  f:=TFont.Create;
f:=v_console_buff.Canvas.Font;

    Form1.canvas.Brush.Color :=clBlack;
    Form1.canvas.Pen.Width :=1;
    Form1.canvas.Pen.Color:=clGreen;
    Form1.canvas.FillRect(Rect(0,0,form1.width,c_console_header_h));
    Form1.canvas.Font.Color := v_console_forecolor;
    Form1.canvas.Rectangle(Rect(0,0,form1.width,c_console_header_h));
    Form1.canvas.FillRect(Rect(0,c_console_header_h-1,form1.width,form1.height));

    //text out
    
    SetBkMode(form1.Canvas.Handle,TRANSPARENT);

    form1.Canvas.Font.Style:=[];
    v_console_buff.Canvas.Font.Style:=[];
    Form1.Canvas.Font.Color := clWhite;
    v_console_buff.Canvas.Font.Color:=clWhite;

    S:= ReplaceC(v_console_title);
    U:='';
    S := StringReplace(S,#13,'',[rfReplaceAll]);
    TW:=0;
    for i:=1 to length(S) do
    case ord(S[i])of
    {foreground}2:SetForecolor(copy(S,i+1,1)[1]);
    else if ((copy(S,i-1,1)<>#2))then
    TW:=TW+Form1.canvas.TextWidth(S[i]);
    end;

    Form1.Canvas.Font.Color := v_console_buff.Canvas.Font.Color;

    _BEGIN:=(form1.width div 2) - TW div 2;
    _CONT:=_BEGIN;

    for i:=1 to length(S) do
    case ord(S[i])of
    {foreground}2:SetForecolor(copy(S,i+1,1)[1]);
    else if ((copy(S,i-1,1)<>#2))then begin
      Form1.canvas.TextOut(_CONT,1,s[i]);
      inc(_CONT,Form1.canvas.TextWidth(S[i]));
    end;
    end;
    if tag=0 then f.Color:=clGreen;

    form1.Canvas.Font:=f;
    v_console_buff.Canvas.Font:=f;

     {
    form1.Canvas.Font.Style:=[];
    v_console_buff.Canvas.Font.Style:=[];
    Form1.Canvas.Font.Color := v_console_forecolor;
    v_console_buff.Canvas.Font.Color:=v_console_forecolor; }

    Form1.canvas.Rectangle(Rect(0,c_console_header_h-1,form1.width,form1.height));
    Canvas.Draw(1,c_console_header_h+1,v_console_buff);
end;



procedure TForm1.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
//
        v_console_cmd:='';
        NewString(#2'C'+E.Message);
        NewLine;
        NewLine;
        Prompt;
        
end;

end.
