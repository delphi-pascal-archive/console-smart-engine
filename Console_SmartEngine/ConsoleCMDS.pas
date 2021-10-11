unit ConsoleCMDS;

interface

uses
  Windows,SysUtils,Graphics;

type
  TConsoleCommands=class
      published
        procedure ___cd(params:array of string;paramc:byte;var cout:string;var iout:TBitmap);
        procedure ___view(params:array of string;paramc:byte;var cout:string;var iout:TBitmap);
        //procedure ___echo(params:array of string;paramc:byte;var cout:string;var iout:TBitmap);
  end;

implementation

procedure TConsoleCommands.___cd(params:array of string;paramc:byte;var cout:string;var iout:TBitmap);begin

    if paramc= 0 then cout:=cout+SysUtils.GetCurrentDir else
     if DirectoryExists(params[1])=true then
     ChDir(params[1])else cout:='\ce[Error]\cn ';

end;
procedure TConsoleCommands.___view(params:array of string;paramc:byte;var cout:string;var iout:TBitmap);begin
    iout:=TBitmap.Create;
    iout.PixelFormat:=pf24bit;
    iout.LoadFromFile(params[1]);
     
end;

end.
