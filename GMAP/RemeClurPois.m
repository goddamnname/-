function [spec_log,clur_point] = RemeClurPois(spec_shift,N,sim_fd,sim_sigma,prf,sim_power,noise_level,spec_log)
    %计算回波谱上中间三点的功率和,没有取对数之前的值
    sum_centhree = sum(spec_shift(round(N/2-1):round(N/2+1)));
    k = 0:N-1;  %N为采样点数
    fi = -prf/2+prf/N.*k;
    %产生谱宽为Sim_sigma，速度为Sim_vd的归一化高斯信号
    sim_gs = sim_power.*exp(-(fi-sim_fd).^2 ./ (2*sim_sigma.^2));
    %归一化高斯信号中间三点的功率和
    sim_sum_centhree = sum(sim_gs(round(N/2-1):round(N/2+1)));
    %求出回波谱中间三点的功率和与归一化高斯信号中间三点的功率和的比值
    sim_ratio = sum_centhree / sim_sum_centhree;
    %将归一化的信号扩大Sim_Ratio倍
    sim_gs = sim_gs .* sim_ratio;
    sim_gs_log = 10*log10(sim_gs);
    %杂波最大为中心点左右各4点，即最多去掉9个点
    clur_point = sum(sim_gs_log(round(N/2-4):round(N/2+4)) > noise_level);%sum(spec_log(N/2-4:N/2+4) > noise_level);
    clur_point = 2*clur_point;%8;%将要滤波的点数扩大2倍
    %将中间的Clur_poit个点和低于噪声电平的点设置为噪声电平
    spec_log(round(N/2-clur_point/2):round(N/2+clur_point/2)) = noise_level;
    spec_log(spec_log<noise_level) = noise_level;
    %求出谱值最大的点所在的位置
%     [Max_Spec_log, Max_Spec_Indx] = max(spec_log);%是否应该用实数部分比较最大值
    [Max_Spec_log, Max_Spec_Indx] = max(real(spec_log));
    Max_Spec_Indx_Botm = Max_Spec_Indx;  %将记录谱值最大点的位置赋给Max_Spec_Indx_Botm，作为下边界
	Max_Spec_Indx_Top = Max_Spec_Indx; %从Max_Spec_Indx往上搜索，找到上边界存于Max_Spec_Indx_Top中
    %如果边界到了中间的几点，要跨过去
    if Max_Spec_Indx_Top >= round(N/2-clur_point/2) && Max_Spec_Indx_Top <= round(N/2+clur_point/2)
        Max_Spec_Indx_Top = round(N/2+clur_point/2) + 1;
    end
    %搜寻边界
    while spec_log(Max_Spec_Indx_Top) > noise_level && Max_Spec_Indx_Top < N
        Max_Spec_Indx_Top = Max_Spec_Indx_Top + 1;
        if Max_Spec_Indx_Top >= round(N/2-clur_point/2) && Max_Spec_Indx_Top <= round(N/2+clur_point/2)
            Max_Spec_Indx_Top = round(N/2+clur_point/2) + 1;
        end
    end
%     Max_Spec_Indx_Botm = Max_Spec_Indx_Botm - 1;
    if Max_Spec_Indx_Botm >= round(N/2-clur_point/2) && Max_Spec_Indx_Botm <= round(N/2+clur_point/2)
        Max_Spec_Indx_Botm = round(N/2-clur_point/2) - 1;
    end
    while spec_log(Max_Spec_Indx_Botm) > noise_level && Max_Spec_Indx_Botm > 1
        Max_Spec_Indx_Botm = Max_Spec_Indx_Botm - 1;
        if Max_Spec_Indx_Botm >= round(N/2-clur_point/2) && Max_Spec_Indx_Botm <= round(N/2+clur_point/2)
            Max_Spec_Indx_Botm = round(N/2-clur_point/2) - 1;
        end
    end
    %将处于上下边界Max_Spec_Indx_Botm与Max_Spec_Indx_Top之间的数据保留下来，将处于界外的点置成噪声电平
    spec_log(1:Max_Spec_Indx_Botm-1) = noise_level;
    spec_log(Max_Spec_Indx_Top+1:end) = noise_level;
end

