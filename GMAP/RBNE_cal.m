function RBNE = RBNE_cal(Pr)

%-----------------绘图观看径向上哪些地方属于噪声区域
%     figure;plot(Pr);
%     hold on;
%     for p = 1:vol_num
%         if Pr_Nflag(p) == 1
%             Pr_plot(p) = Pr(p);
% %             plot(p,Pr(p),'.','MarkerEdgeColor','r');
% %             hold on;
%         else
%             Pr_plot(p) = nan;
%         end
%     end
%     plot(Pr_plot);


    %距离库数vol_num
    vol_num = length(Pr);
    %点杂波乘积门限PCT
    PCT = 2.45;
%% %---------------去除异常信号点
    for i = 1:vol_num
        if i > 2 && i < vol_num - 2
            if abs(Pr(i)) > abs(Pr(i-2))*PCT || abs(Pr(i)) > abs(Pr(i+2))*PCT
                Pr(i) = mean(Pr(i-2:i+2));
            end
        elseif i <= 2
            if abs(Pr(i)) > abs(Pr(i+2))*PCT
                Pr(i) = mean(Pr(i:i+2));
            end
        else
            if abs(Pr(i)) > abs(Pr(i-2))*PCT
                Pr(i) = mean(Pr(i-2:i));
            end
        end
    end
%% %---------------方差判断噪声区间
    %滑窗长度K
    K = 16;
    %方差门限THR
    THR = 0.7;
    Variance = 0;
    Noise_num = 1;
    for j = 1:vol_num
        if j > K/2-1 && j < vol_num-K/2
            Variance = var(Pr(j-K/2+1:j+K/2));
            var_set(j) = Variance;
            if Variance < THR
                Pr_Nflag(j) = 1;%Pr_Nflag为1时判断此处为噪声
                Noise(Noise_num) = Pr(j);%保存噪声区间的信号值
                Noise_num = Noise_num + 1;
            else
                Pr_Nflag(j) = 0;
            end
        elseif j <= K/2-1
            Variance = var(Pr(j:j+K));
            var_set(j) = Variance;
            if Variance < THR
                Pr_Nflag(j) = 1;%Pr_Nflag为1时判断此处为噪声
                Noise(Noise_num) = Pr(j);
                Noise_num = Noise_num + 1;
            else
                Pr_Nflag(j) = 0;
            end
        else
            Variance = var(Pr(j-K:j));
            var_set(j) = Variance;
            if Variance < THR
                Pr_Nflag(j) = 1;%Pr_Nflag为1时判断此处为噪声
                Noise(Noise_num) = Pr(j);
                Noise_num = Noise_num + 1;
            else
                Pr_Nflag(j) = 0;
            end
        end
    end

%% %-----------------去除功率明显大于噪声的区间
    Nint = median(Noise);
    N_THR = 0.95;
    for i = 1:vol_num
        if Pr_Nflag(i) == 1
            if abs(Pr(i)) < abs(Nint) * N_THR
                Pr_Nflag(i) = 0;
            end
        end
    end
    
%% %------------------排除连续强回波
    %检测距离R=50个距离库
    R = 50;
    i = 1;
    while(1)
        Pr_m = median(Pr(i:i+R));
        for j = i:i+R-10
            if min(Pr(j:j+10)) > Pr_m
                Pr_Nflag(i:i+10) = 0;
            end
        end
        i = i + R;
        %判断径向是否遍历完
        if i >= vol_num
            break;
        end
        %判断所剩区间是否满足R个距离库
        if i + R > vol_num
            R = vol_num - i;
        end
    end
    
%% %----------------计算噪声区间平均功率
    noise = 0;
    noise_num = 0;
    for i = 1:vol_num
        if Pr_Nflag(i) == 1
            noise = noise + Pr(i);
            noise_num = noise_num + 1;
        end
    end
    RBNE = noise/noise_num;
end

