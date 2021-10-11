// форма становится прозрачной при перетаскивании
// как пользоваться
// 1. поместите в uses этот модуль
// 2. сделайте форму AlphaBlend=True
// 3. в OnCreate формы BlendOnMove:=True;


unit BlendOnMove;

interface
uses Windows,Forms,Messages;

type TForm=class(Forms.TForm)
    private
       FBlendOnMove:Boolean;
       FBlendOnMove_FinalValue:Byte;
       FBlended:Boolean;
       FShow:Boolean;
       BV:Byte;
       procedure NCD(var Msg: TMessage); message WM_NCLBUTTONDOWN;
       procedure NCU(var Msg: TMessage); message WM_NCMOUSEMOVE;
       procedure MM(var Msg: TMessage); message WM_MOUSEMOVE;
       procedure CL(var Msg: TMessage);message WM_CLOSE;
       procedure AC(var Msg: TMessage);message WM_ACTIVATE;

    public
       property BlendOnMove:Boolean read FBlendOnMove write FBlendOnMove default True;
       property BlendOnMove_FinalValue:Byte read FBlendOnMove_FinalValue write FBlendOnMove_FinalValue default 200;
       property BlendOnMove_IsBlended:Boolean read FBlended default False;
end;
    var BlendOnMove_FinalValue:Byte;

implementation
   var blendForm:TForm;
       BlendOnMove_StValue:Byte;

       procedure BLEND_OUT();stdcall;begin
       {if Assigned(blendForm) then
           if blendForm.FShow=false then begin
               blendForm.AlphaBlendValue:=255;
               KillTimer(blendform.Handle,1);
               Exit;
           end;}
           if Assigned(blendForm) then
           if blendform.AlphaBlendValue>BlendOnMove_FinalValue then
           blendform.AlphaBlendValue :=blendform.AlphaBlendValue-8 else
           KillTimer(blendform.Handle,1);
       end;
       procedure BLEND_IN;stdcall;begin
       {if Assigned(blendForm) then
           if blendForm.FShow=false then begin
               blendForm.AlphaBlendValue:=255;
               KillTimer(blendform.Handle,1);
               Exit;
           end;  }
           if Assigned(blendForm) then
           if blendform.AlphaBlendValue<255{BlendOnMove_StValue} then
           blendform.AlphaBlendValue :=blendform.AlphaBlendValue+8 else
           KillTimer(blendform.Handle,1);

       end;

procedure TForm.CL(var Msg: TMessage);begin

    //AlphaBlendValue:=255;
    FShow:=False;
    inherited;
end;
procedure TForm.AC(var Msg: TMessage);begin

    AlphaBlendValue:=255;
    FShow:=True;
    inherited;
end;
procedure TForm.MM(var Msg: TMessage);begin

    NCU(Msg);
    inherited;
end;
procedure TForm.NCD(var Msg: TMessage);begin
    if ((FBlendOnMove)and(FShow)) then
    begin

        blendForm:=Self;
        BlendOnMove_StValue:=AlphaBlendValue;
        KillTimer(Handle,1);
        SetTimer(Handle,1,10,@BLEND_OUT);


    end;
    FBlended:=True;
    inherited;
end;
procedure TForm.NCU(var Msg: TMessage);begin
    if FBlendOnMove then
    if FBlended then
    if FShow then begin
        blendForm:=Self;
        KillTimer(Handle,1);
        SetTimer(Handle,1,10,@BLEND_IN);

    end;

    FBlended:=False;


    inherited;
end;

initialization
BlendOnMove_FinalValue:=255-(8*12);

end.
