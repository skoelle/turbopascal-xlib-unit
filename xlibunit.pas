{ >>> *The X-LIB UNiT V0.3á* <<< - first beta release }

(*
  Hi Everybody!
  this is the XLIB-UNIT
  made by Stefan KOelle
  You can use this LIB freely, but you have to
  credit me in you program and you have to send me a fido messy to:
  Stefan Koelle 2:2480/330

  New in this version: Virtual Horizontal 640 Pixel

  If you have any questions then also write a message to me
  Comming soon: Double wide
                Panning
                Lines, Circle, Ellipse -Draw
                Demosource using the LIB
                and even more...
*)

unit xlibunit;

interface
type paltype=array[0..767] of byte;
var textpal:array[1..3,0..15] of byte;
procedure initxlib;                          {init vgamode 13}
procedure initxmode;                         {init xmode}
procedure clearxmode;                        {quick clearscreen for xmode}
procedure cleartext;                         {quick clearscreen for txtmode}
procedure exitxlib;                          {exit lib and init vgamode 3}
procedure point(x,y,c:word);                 {point in xmode}
procedure blackpal;                          {all colors in black}
procedure vert_retr;                         {wait for vert-retr}
procedure fadeup(scol:paltype;speed:integer);   {fadeup-palette}
procedure fadedown(scol:paltype;speed:integer); {fadedown-palette}
procedure copypic13(s,o,b,c:word);       {copy pic from segment o
                                                    and offset o
                                            to vga from begin b
                                                      c times
                                                      in mode 13}
procedure copypicx(s,o,b,c:word);            {same as copypic13 but in xmode}
procedure copypicxd(s,o,b,c:word);           {same as copypic13 but in xmode
                                              but in virtual horizontal 640}
procedure copypal(s,o,b,c,ps,po:word);    {copy pal from segment o
                                                     and offset o
                                                      at begin b
                                                         c times
                                               to pal at segment s
                                                     and offset o}
procedure startingarea(s:word);              {Linear Staring Area}
procedure vert400;                           {Switch to 320*400}
procedure vert200;                           {Switch to 320*200}
procedure vert100;                           {Switch to 320*100 not testet!}
procedure hor640;                            {Switch to virual horizontal 640}
procedure hor320;                            {Switch to normal horizontal 320}
procedure vpan(b:byte);
procedure hpan(b:byte);
procedure hbegin(b:byte);
Procedure CRTC_UnProtect;
Procedure CRTC_Protect;
procedure unprotect;
procedure protect;
procedure hor_retr;
procedure moveblock(s,d,b,h,p:word);
procedure setdac(c,r,g,b:byte);
procedure print(x,y:byte;s:string;c:byte);
procedure locate(x,y:word);
function key:boolean;

implementation
procedure initxlib; assembler;
asm
  mov ax,13h
  int 10h
end;
procedure clearxmode; assembler;
asm
  mov dx,3c4h
  mov al,02h
  out dx,al
  inc dx
  mov al,00001111b
  out dx,al
  mov ax,0a000h
  mov es,ax
  mov cx,0ffffh
  xor di,di
  xor ax,ax
  cld
  rep stosw
end;
procedure initxmode; assembler;
asm
  mov dx,3c4h
  mov al,4
  out dx,al
  inc dx
  in al,dx
  and al,11110111b {Enable Chain4}
  or al,00000100b  {Odd/Even}
  out dx,al

  mov dx,3d4h
  mov al,14h
  out dx,al
  inc dx
  in al,dx
  and al,10111111b {Disable Doubleword addressing}
  out dx,al

  mov dx,3d4h
  mov al,17h
  out dx,al
  inc dx
  in al,dx
  or al,01000000b {Byte Mode}
  out dx,al
end;
procedure cleartext; assembler;
asm
  mov ax,0b800h
  mov es,ax
  mov cx,01fffh
  xor di,di
  mov ax,$0720
  cld
  rep stosw
end;
procedure exitxlib; assembler;
asm
  mov ax,3h
  int 10h
  jmp cleartext
end;
procedure point(x,y,c:word); assembler;
asm
  mov ax,0a000h
  mov es,ax

  mov cx,x
  and cx,3
  mov ax,1
  shl ax,cl
  mov ah,al
  mov dx,3c4h
  mov al,2
  out dx,ax

  mov ax,80
  mul y
  mov di,ax
  mov ax,x
  shr ax,2
  add di,ax
  mov al,byte ptr c
  mov es:[di],al
end;
procedure blackpal; assembler;
asm
  mov cx,255
 @delloop:
  mov dx,3c8h
  mov ax,cx
  out dx,ax
  mov dx,3c9h
  mov ax,0
  out dx,ax
  out dx,ax
  out dx,ax
  loop @delloop
end;
procedure vert_retr; assembler;
asm
      mov dx,$3da
     @wait1:
      in al,dx
      test al,$8
      jnz @wait1
     @wait2:
      in al,dx
      test al,$8
      jz @wait2
end;
procedure fadeup(scol:paltype;speed:integer);
var i,j:integer;
begin
  for i:=1 to speed do begin
    vert_retr;
    for j:=0 to 255 do begin
      port[$3c8]:=j;
      port[$3c9]:=(scol[j*3]*i) div speed;
      port[$3c9]:=(scol[j*3+1]*i) div speed;
      port[$3c9]:=(scol[j*3+2]*i) div speed;
    end;
  end;
end;
procedure fadedown(scol:paltype;speed:integer);
var i,j:integer;
begin
  for i:=speed downto 1 do begin
    vert_retr;
    for j:=0 to 255 do begin
      port[$3c8]:=j;
      port[$3c9]:=(scol[j*3]*i) div speed;
      port[$3c9]:=(scol[j*3+1]*i) div speed;
      port[$3c9]:=(scol[j*3+2]*i) div speed;
    end;
  end;
end;
procedure copypic13(s,o,b,c:word); assembler;
asm
  push es
  push ds
  push di
  push si
  mov ds,s
  mov si,o
  mov ax,0a000h
  mov es,ax
  mov di,b
  mov cx,c
  rep movsw
  pop si
  pop di
  pop ds
  pop es
end;
procedure copypicx(s,o,b,c:word); assembler;
asm
  push es
  push ds
  push di
  push si

  mov dl,00000001b  {Init}
  mov ds,s          {Segs. laden}
  mov ax,0a000h
  mov es,ax
  mov si,o

 @planeloop:
  mov cl,dl   {Plane setzten}
  mov dx,3c4h
  mov al,02h
  out dx,al
  inc dx
  mov al,cl
  out dx,al
  mov dl,al

  mov di,b
  mov cx,c

 @copy1plane:
  movsb
  add si,3
  loop @copy1plane

  sub si,c
  sub si,c
  sub si,c
  sub si,c
  add si,1
  shl dl,1
  cmp dl,10h
  jne @planeloop

  pop si
  pop di
  pop ds
  pop es
end;
procedure copypicxd(s,o,b,c:word); assembler;
asm
  push es
  push ds
  push di
  push si

  mov dl,00000001b  {Init}
  mov ds,s          {Segs. laden}
  mov ax,0a000h
  mov es,ax
  mov si,o

 @planeloop:
  mov cl,dl   {Plane setzten}
  mov dx,3c4h
  mov al,02h
  out dx,al
  inc dx
  mov al,cl
  out dx,al
  mov dl,al

  mov di,b
  mov cx,c

  mov al,80

 @copy1plane:
  movsb
  add si,3
  dec al
  cmp al,0
  jnz @weitercopy
  mov al,80
  add di,80
 @weitercopy:
  loop @copy1plane

  sub si,c
  sub si,c
  sub si,c
  sub si,c
  add si,1
  shl dl,1
  cmp dl,10h
  jne @planeloop

  pop si
  pop di
  pop ds
  pop es
end;
procedure copypal(s,o,b,c,ps,po:word); assembler;
asm
  push es
  push ds
  push di
  push si
  mov ds,s
  mov si,o
  mov es,ps
  mov ax,po
  add ax,b
  mov di,ax
  mov cx,c
  rep movsb
  pop si
  pop di
  pop ds
  pop es
end;
procedure startingarea(s:word); assembler;
asm
  mov dx,3d4h
  mov al,0ch
  mov ah,byte ptr s + 1
  out dx,ax
  mov al,0dh
  mov ah,byte ptr s
  out dx,ax
end;
procedure vert400; assembler;
asm
  mov dx,3d4h
  mov al,9
  out dx,al
  inc dx
  in al,dx
  and al,01110000b
  out dx,al
end;
procedure vert200; assembler;
asm
  mov dx,3d4h
  mov al,9
  out dx,al
  inc dx
  in al,dx
  or al,00000001b
  out dx,al
end;
procedure vert100; assembler;
asm
  mov dx,3d4h
  mov al,9
  out dx,al
  inc dx
  in al,dx
  or al,00000010b
  out dx,al
end;
procedure hor640; assembler;
asm
  mov dx,3d4h
  mov ax,5013h
  out dx,ax
end;
procedure hor320; assembler;
asm
  mov dx,3d4h
  mov ax,2813h
  out dx,ax
end;
procedure vpan(b:byte); assembler;
asm
  mov dx,3d4h
  mov al,8
  mov ah,b
  out dx,ax
end;
procedure hpan(b:byte); assembler;
asm
  mov dx,3dah
  in al,dx

  mov dx,3c0h
  mov al,13h or 32d
  out dx,al
  mov al,b
  or al,32d
  out dx,al
end;
procedure hbegin(b:byte); assembler;
asm
  mov dx,3d4h
  mov al,4
  mov ah,b
  out dx,ax
end;
Procedure CRTC_UnProtect;
Begin
  Port[$3d4]:=$11;              {Register 11h des CRTC (Vertical Sync End)}
  Port[$3d5]:=Port[$3d5] and not $80  {Bit 7 (Protection Bit) l”schen}
End;
Procedure CRTC_Protect;
Begin
  Port[$3d4]:=$11;              {Register 11h des CRTC (Vertical Sync End)}
  Port[$3d5]:=Port[$3d5] or $80 {Bit 7 (Protection Bit) setzen}
End;
procedure unprotect; assembler;
asm
  mov dx,3d4h
  mov al,11h
  out dx,al
  inc dx
  in al,dx
  and al,10111111b
  out dx,al
end;
procedure protect; assembler;
asm
  mov dx,3d4h
  mov al,11h
  out dx,al
  inc dx
  in al,dx
  or al,01000000b
  out dx,al
end;
procedure hor_retr; assembler;
asm
  mov dx,3dah
 @in_display:
  in al,dx
  test al,1
  je @in_display
 @in_retrace:
  in al,dx
  test al,1
  jne @in_retrace
end;
procedure moveblock(s,d,b,h,p:word); assembler;
asm
  push ds
  push es
  push si
  push di

  mov dx,3ceh      {Select all planes}
  mov ax,4105h
  out dx,ax
  mov dx,3c4h
  mov ax,0f02h
  out dx,ax

  mov ax,0a000h
  mov es,ax
  mov ds,ax
  mov si,s
  mov di,d
  mov dx,h

@line_lp:
  mov cx,b
  rep movsb
  add si,p
  add di,p

  dec dx
  jne @line_lp

  pop di
  pop si
  pop es
  pop ds
end;
procedure setdac(c,r,g,b:byte); assembler;
asm
  mov dx,3c8h
  mov al,c
  out dx,al
  inc dx
  mov al,r
  out dx,al
  mov al,g
  out dx,al
  mov al,b
  out dx,al
end;
procedure print(x,y:byte;s:string;c:byte);
var i:byte;
begin
  for i:=1 to length(s) do begin
    mem[$b800:(i-1+x)*2+y*160]:=ord(s[i]);
    mem[$b800:(i-1+x)*2+y*160+1]:=c;
  end;
end;
procedure locate(x,y:word); assembler;
asm
  mov ah,02h
  xor bh,bh
  mov dh,byte ptr x
  mov dl,byte ptr y
  int 10h
end;
procedure splitscreen(b:byte); assembler;
asm
  mov bl,b
  xor bh,bh
  shl bx,1
  mov cx,bx

  mov dx,3d4h
  mov al,07h
  out dx,al
  inc dx
  in al,dx
  and al,11101111b
  shr cx,4
  and cl,16
  or al,cl
  out dx,al

  dec dx
  mov al,09h
  out dx,al
  inc dx
  in al,dx
  and al,10111111b
  shr bl,3
  and bl,64
  or al,bl
  out dx,al

  dec dx
  mov al,18h
  mov ah,b
  shl ah,1
  out dx,ax
end;
function key:boolean;
begin
  if port[$60] and 128=128 then key:=false else key:=true;
end;
var i:byte;
begin
  for i:=0 to 15 do begin
    port[$3c7]:=i;
    textpal[1,i]:=port[$3c9];
    textpal[2,i]:=port[$3c9];
    textpal[3,i]:=port[$3c9];
  end;
end.