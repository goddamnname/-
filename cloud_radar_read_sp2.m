clc;
clear all;
close all;
 
subdir = 'figures';
subdir1 = 'figures/pulse integration';
if ~exist(subdir1, 'dir')    % 检查目录是否存在
    mkdir(subdir1);          % 不存在则创建
end
subdir2 = 'figures/SNR improvement';
if ~exist(subdir2, 'dir')    % 检查目录是否存在
    mkdir(subdir2);          % 不存在则创建
end
%% 雷达 I/Q 数据读取
[file, path] = uigetfile({'*.*'}, '数据选择');     
fname = fullfile(path, file);
fid = fopen(fname, 'rb');
% fid = fopen('C:\Users\EECJH\Desktop\机载气象信号处理\云雷达IQ\20161225_000205_P02500_C195841026.YWIQ','r');

% 长度定义
C=299792457.4;                  %光速
TransmitFrequency=35e9;       %发射频率
WaveLength=C/TransmitFrequency;  %雷达工作波长
% fs=1000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%——————cloud radar 读取文件头———————%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 读取头文件——时间
prt_num=0;

M_time_I=4;        %% pulse integration时域脉冲积累次数 
M_FFT=128;           %% FFT点数 
M_Spectral_I=32;    %% Spectral average 谱平均次数
while (feof(fid)==0)
%% fft tranformation

Spectral_time=0;
while Spectral_time<M_Spectral_I
    Spectral_time=Spectral_time+1
    fft_time=0;
while( fft_time<M_FFT)
%pulse integration in time domain
    fft_time=fft_time+1;
    Intg_time=0;

    while( Intg_time<M_time_I)
        prt_num=prt_num+1;  
        Intg_time=Intg_time+1;
        PRT_head=dec2hex(fread (fid,1,'bit32=>int32'));     %% 0x5a5a1234
        PRT_Prt_len=fread (fid,1,'bit16=>int32');   %% prt clk number
        PRT_DIFCLK=fread (fid,1,'bit16=>int32');    %% IF CLK 20000khz
        PRT_DataLen=fread (fid,1,'bit32=>int32');   %% data length 
        PRT_T0cnt=fread (fid,1,'bit32=>int32');     %% PRT counter
        PRT_Antdata0=fread (fid,1,'bit32=>int32');  %% antenna 
        PRT_Antdata1=fread (fid,1,'bit32=>int32');  %% antenna
        PRT_Antdat3Pe=fread (fid,1,'bit8=>int32');  %% antenna
        PRT_Sys_daatmp=fread (fid,1,'bit8=>int32'); %% data tmp
        PRT_Sys_sts1=fread (fid,1,'ubit8');   %% system status
        PRT_Sys_spare=fread (fid,1,'bit8=>int32');  %% unused data
        PRT_Sys_sts2=fread (fid,1,'bit32=>int32');  %% PRTcounter for timer
        IQ_data_length=PRT_DataLen;  
        radar_prf= PRT_DIFCLK/PRT_Prt_len*10^3;      %% 20000khz/2500=8khz
        % disp(PRT_Prt_len)
        % disp(PRT_DIFCLK)
        % disp(radar_prf)

        pulse_mode= bitand(PRT_Sys_sts1,3);        %% 00:2us, 01:5us 10:20us, 11:reserved
    %     %%test
    %     I_data_tmp=fread (fid,PRT_DataLen-8,'bit16');

        for i=1:PRT_DataLen-8
            I_data_tmp=fread (fid,1,'ubit16');
            I_data(Intg_time,i)=bittofloat(I_data_tmp);

            Q_data_tmp=fread (fid,1,'ubit16');
            Q_data(Intg_time,i)=bittofloat(Q_data_tmp);  
        end

    end
    %%while(Intg_time) 
    if(fft_time==1)%% initiate the variant
        I_data_TI=zeros(M_FFT,length(I_data(1,:)));
        Q_data_TI=zeros(M_FFT,length(I_data(1,:)));
    end
   %%pulse integration时域积累  
    tmp1=sum(I_data,1)/M_time_I;
    tmp2=sum(Q_data,1)/M_time_I;
    I_data_TI(fft_time,1:length(tmp1))= tmp1;
    Q_data_TI(fft_time,1:length(tmp1))= tmp2;
    
    %%%%calculate the noise power计算噪声功率
    if (mod(Spectral_time,2)==0 && fft_time==1 )
        IQ_powInt=20*log10(abs(I_data_TI(1,:)+j*Q_data_TI(1,:)));
        IQ_powNoInt=20*log10(abs(I_data(1,:)+j*Q_data(1,:)));
        %% noise power where there is no echo.
         Npow_Int = sum(IQ_powInt(1,400:600))/201;
         Npow_noInt = sum(IQ_powNoInt(1,400:600))/201;
        %% select some useful echo IQ_depack
         Siganl_Int=IQ_powInt(210:240)-Npow_Int;
         Siganl_NoInt=IQ_powNoInt(210:240)-Npow_noInt;

         SNR_imp=Siganl_Int-Siganl_NoInt;
         SNR_avg=sum(SNR_imp)/length(SNR_imp);
         xx=1:length(I_data_TI(1,:));

        % 1. 绘制并保存时域积累对比图 (Invisible)
        % h1 = figure('Visible', 'off'); % 关键：设置 Visible 为 off
        % plot(xx,IQ_powInt,'r',xx,IQ_powNoInt,'b'); 
        % title(['Pulse Integration脉冲积累 (PRT: ' num2str(prt_num) ')']);
        % ylabel('dB'); xlabel('range bin (30m)');
        % legend('Integration','one pulse');     
        % axis([1 625  60 140]);
        % % 保存文件：文件名包含 prt_num 以防覆盖
        % saveas(h1, fullfile(subdir1, sprintf('PulseInt_%d.png', prt_num)));
        % close(h1); % 关键：必须关闭，否则内存会溢出
        % 
        % % 2. 绘制并保存信噪比提升图 (Invisible)
        % h2 = figure('Visible', 'off'); % 关键：设置 Visible 为 off
        % plot(210:240,SNR_imp,'b');
        % title(['SNR improvement信噪比提升 (PRT: ' num2str(prt_num) ')']);
        % ylabel('dB'); xlabel('range bin (30m)');
        % % 保存文件
        % saveas(h2, fullfile(subdir2, sprintf('SNR_Imp_%d.png', prt_num)));
        % close(h2); % 关键：必须关闭
        % 
        % % 在命令行输出一点提示，让你知道程序还在动
        % fprintf('已保存第 %d 个脉冲时刻的调试图片...\n', prt_num);
        pulse_mode;
    end

    
end%%while(fft_time)   

IQ_TI=I_data_TI+ j*Q_data_TI;
%% fft转速度谱
    for i=1:length(I_data_TI(1,:))
        FFT_IQ(:,i)=fftshift(fft(IQ_TI(:,i)));
    end

 %% Spectral average谱平均
 if Spectral_time==1
     Spectral_avg_tmp=zeros(M_FFT,length(FFT_IQ(1,:)));
 end
 Spectral_avg_tmp= FFT_IQ+  Spectral_avg_tmp;

end %% while(Spectral_time)
  Spectral_avg = 10*log10(abs(Spectral_avg_tmp/Spectral_time));
  
  xx=((-M_FFT)/2:M_FFT/2-1).*double((radar_prf/M_FFT))*WaveLength/2;

  % figure,
  % subplot(211);plot(xx,Spectral_avg(:,220),'r',xx,10*log10(abs(FFT_IQ(:,220))),'b');title('Velocity Spectral速度谱');xlabel('dB');ylabel('m/s');legend('average','no average');
  % subplot(212);plot(xx,Spectral_avg(:,230),'r',xx,10*log10(abs(FFT_IQ(:,230))),'b');title('Velocity Spectral速度谱');xlabel('dB');ylabel('m/s');legend('average','no average');
% --- 修改开始：后台保存速度谱对比图 --- %
  
  % 创建不可见窗口
  h_spec = figure('Visible', 'off');
  
  % 子图1：距离库 220
  subplot(211);
  plot(xx, Spectral_avg(:,220), 'r', xx, 10*log10(abs(FFT_IQ(:,220))), 'b');
  % 标题增加脉冲计数，防止文件名重复
  title(['Velocity Spectral (Bin 220) - End of Pulse ' num2str(prt_num)]);
  % 【修正】原代码 xy 轴标签反了，这里已修正
  xlabel('Velocity (m/s)'); 
  ylabel('Power (dB)'); 
  legend('Average (32 times)', 'No Average (Single)', 'Location', 'eastoutside');
  
  % 子图2：距离库 230
  subplot(212);
  plot(xx, Spectral_avg(:,230), 'r', xx, 10*log10(abs(FFT_IQ(:,230))), 'b');
  title(['Velocity Spectral (Bin 230) - End of Pulse ' num2str(prt_num)]);
  xlabel('Velocity (m/s)'); 
  ylabel('Power (dB)'); 
  legend('Average (32 times)', 'No Average (Single)', 'Location', 'eastoutside');
  
  % 保存图片
  % 文件名示例: VelocitySpec_16384.png
  filename = fullfile(subdir, sprintf('VelocitySpec_%d.fig', prt_num));
  saveas(h_spec, filename);
  
  % 关闭窗口释放内存
  close(h_spec);
  
  fprintf('已保存速度谱图片: %s\n', filename);
  
  % --- 修改结束 --- %
over =1;
end
over=1;
% h = openfig('figures/VelocitySpec_16384.fig'); % 加载文件
% set(h, 'Visible', 'on'); % 强制显示







