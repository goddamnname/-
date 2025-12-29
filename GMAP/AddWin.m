function [H_filter] = AddWin(Wintype,H)
    
    if Wintype == 1%未加窗
        H_filter = H;
%         H_Q_filter = H_Q;
    elseif Wintype == 2%海明窗
        WinHam = hamming(length(H));
        H_filter = H .* WinHam;
%         H_Q_filter = H_Q .* WinHam;
    elseif Wintype == 3%布莱克曼窗
        WinBlack = blackman(length(H));
        H_filter = H .* WinBlack;
%         H_Q_filter = H_Q .* WinBlack;
    end
    
end

