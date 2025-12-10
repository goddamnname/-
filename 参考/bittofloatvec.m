
function y=bittofloatvec(x)

    Exp=bitshift(bitand(x,31744),-10); %% 31744=0x7C00
    Manti=bitand(x,1023);              %% 1023=0x03ff
    Symbol=bitand(x,32768);            %% 32768=0x8000
    sign_x=-1*sign(Symbol-1);           %% sign
    yy=2.^Exp.*Manti;
    y=double(yy.*sign_x);
 
