function H_Filter = GMAP_Filter_newRemove(H,N,prf,wavelength)
    %% 1加窗
    [H_filter] = AddWin(2,H);%加海明窗
    %% 2求频谱
%     spec = H_filter.*conj(H_filter);%case2
%     spec = fftshift(fft(spec));%case2
%     sample = N;
    H_filter = fftshift(fft(H_filter));%case1
    spec = H_filter.*conj(H_filter);%case1

    spec_log = 10*log10(spec);
%     N = N * 2 - 1;
    %% 3求噪声电平
    [Max_spec,Max_indx] = max(real(spec_log));

    if Max_indx == round(N/2-1) || Max_indx == round(N/2) || Max_indx == round(N/2+1)
       spec_log_sort = sort(spec_log);
       k = 0;
       for i = 1:N
           if i>0.05*N && i<0.4*N
               k = k + 1;
               temp(k) = spec_log_sort(i);
           end
       end
       Noise_level = mean(temp);
      %% 第四步，指定杂波谱宽，根据指定的杂波谱宽，移除中间的几个点
       %估计原始回波谱的平均速度和速度谱宽
       [origin_fd, origin_sigma] = CalVdandSigma(spec_log, Noise_level,N,prf);
       %地物杂波参数拟合
       sim_sigma = 0.5;
       sim_fd = 0.1;
       sim_power = 1.0;
       sim_sigma = 2*sim_sigma/wavelength;
       sim_fd = 2*sim_fd/wavelength;
       %移除杂波点
       [spec_log,clur_point] = RemeClurPois(spec,N,sim_fd,sim_sigma,prf,sim_power,Noise_level,spec_log);
       %估算去掉杂波的回波谱的平均速度和速度谱宽
       [fd_remov, sigma_remov] = CalVdandSigma(spec_log, Noise_level,N,prf);
       spec_log = spec_log - Noise_level;
       %重建谱，用FFT方法求出均值和方差，对信号进行第一次高斯拟合
       %求出去掉杂波后的最大功率谱值
       [Max_Spec_log,MaxIndx] = max(spec_log);
       k = 0:N-1;  %N为采样点数
       fi = -prf/2+prf/N.*k;
       Ys = Max_Spec_log .* exp(-(fi-origin_fd).^2 ./ (2*origin_sigma.^2));
       %% 第五步，替换杂波点
       spec_log(round(N/2-clur_point/2):round(N/2+clur_point/2)) = Ys(round(N/2-clur_point/2):round(N/2+clur_point/2));
       %重复拟合，直到替换后计算的功率改变小于0.2dB且速度改变小于奈奎斯特速度的0.5%
       count = 0;%拟合次数
       Diff_power = 1;%功率差，dB
       Diff_vd = 1;%速度差，m/s
       Sum_clurem_old = 0;Sum_clurem_new = 0;fd_old = 0;fd_new = 0;
       while ((Diff_power>0.2) && (Diff_vd > 0.005* prf*wavelength / 4.0))
           Sum_clurem_old = Sum_clurem_new;
           fd_old = fd_new;
           Sum_clurem_new = sum(spec_log(round(N/2-clur_point/2):round(N/2+clur_point/2)));
           [fd_new, sigma_new] = CalVdandSigma(spec_log, Noise_level,N,prf);
           Ys = Max_Spec_log .* exp(-(fi-fd_new).^2 ./ (2*sigma_new.^2));
           spec_log(round(N/2-clur_point/2):round(N/2+clur_point/2)) = Ys(round(N/2-clur_point/2):round(N/2+clur_point/2));
           Diff_power = abs(Sum_clurem_new - Sum_clurem_old);
           Diff_vd = abs(fd_new - fd_old)*wavelength / 2;
           count = count +1;
           if count > 100%避免拟合存在死循环
               break;
           end
       end
       %计算滤波后的总功率
       spec_log(round(N/2-clur_point/2):round(N/2+clur_point/2)) = spec_log(round(N/2-clur_point/2):round(N/2+clur_point/2)) + Noise_level;
%        spec_log(round(N/2-clur_point/2):round(N/2+clur_point/2)) = Noise_level;
       spec_log(1:round(N/2-clur_point/2-1)) = 10*log10(spec(1:round(N/2-clur_point/2-1)));
       spec_log(round(N/2+clur_point/2+1):end) = 10*log10(spec(round(N/2+clur_point/2+1):end));
       spec_log = 10.^(spec_log./10);
       
%        H_Filter = spec_log();%仅用于观察频谱输出
       
       spec_log = ifft(spec_log);%傅里叶逆变换，便于后面PPP计算
        H_Filter = spec_log();

    else
        PPbyp = xcorr(H);
        H_Filter = PPbyp(N:end);
        
%         H_test = fftshift(fft(H));%仅用于观察频谱输出
%         spec_test = H_test.*conj(H_test);%仅用于观察频谱输出
%         H_Filter = spec_test;%仅用于观察频谱输出
    end
end




