
function y=bittofloat(x)

    Exp=bitshift(bitand(x,31744),-10); %% 31744=0x7C00
    Manti=bitand(x,1023);              %% 1023=0x03ff
    Symbol=bitand(x,32768);            %% 32768=0x8000
    if Symbol==0
        y=2^Exp*Manti;
    else
        y=-1*2^Exp*Manti;
    end
