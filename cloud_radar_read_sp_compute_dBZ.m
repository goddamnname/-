clc;
clear all;
close all;
 
% fid = fopen('C:\Users\EECJH\Desktop\机载气象信号处理\云雷达IQ\20161225_000205_P02500_C195841026.YWIQ','r');
[file, path] = uigetfile({'*.*'}, '数据选择');     
fname = fullfile(path, file);
fid = fopen(fname, 'rb');
% 长度定义

C=299792457.4;                  %光速
TransmitFrequency=35e9;       %发射频率
WaveLength=C/TransmitFrequency;  %雷达工作波长
DIF_PowerGain=152;%dB
Receiver_Powergain=45;%dB
Receiver_Loss =0.6;%dB

Total_PowerGain=DIF_PowerGain+Receiver_Powergain+Receiver_Loss;% from the DIF to entrance of antenna
% fs=1000;IQ_POWER_NonItg_withnoise

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%——————cloud radar 读取文件头———————%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 读取头文件——时间
prt_num=0;

M_time_I=2;        %% pulse integration 
M_FFT=512;           %% FFT 
M_Spectral_I=32;    %% Spectral average 
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

        pulse_mode= bitand(PRT_Sys_sts1,3);        %% 00:2us, 01:5us 10:20us, 11:reserved
    %     %%test
        IQ_data_tmp=fread (fid,(PRT_DataLen-8)*2,'ubit16');
        I_data_tmp=IQ_data_tmp(1:2:length(IQ_data_tmp));
        Q_data_tmp=IQ_data_tmp(2:2:length(IQ_data_tmp));
        I_data(Intg_time,1:length(I_data_tmp))=bittofloatvec(I_data_tmp);%
        Q_data(Intg_time,1:length(Q_data_tmp))=bittofloatvec(Q_data_tmp);%
        IQ_data=I_data+j*Q_data;
        
%       xx=1:length(I_data_tmp);
%       figure,subplot(211);plot(xx,I_data,'r',xx,Q_data,'b');
%              subplot(212);plot(10*log10(abs(IQ_data)));   
      %%%% another way to read data
%         for i=1:PRT_DataLen-8
%             I_data_tmp=fread (fid,1,'ubit16');
%             I_data(Intg_time,i)=bittofloat(I_data_tmp);
% 
%             Q_data_tmp=fread (fid,1,'ubit16');
%             Q_data(Intg_time,i)=bittofloat(Q_data_tmp);  
%         end

    end%%while(Intg_time) 
    
 
     
    if(fft_time==1)%% initiate the variant
        I_data_TI=zeros(M_FFT,length(I_data(1,:)));
        Q_data_TI=zeros(M_FFT,length(I_data(1,:)));
    end
   %%pulse integration  
    tmp1=sum(I_data,1)/M_time_I;
    tmp2=sum(Q_data,1)/M_time_I;
    I_data_TI(fft_time,1:length(tmp1))= tmp1;
    Q_data_TI(fft_time,1:length(tmp1))= tmp2;
    
    %%%%calculate the noise power
    %if (mod(Spectral_time,8)==1 && fft_time==1 )
    if(Spectral_time==1 && fft_time==1 )
        IQ_powInt1=(abs(I_data_TI(1,:)+j*Q_data_TI(1,:))).^2;
        IQ_powNoInt1=(abs(I_data(M_time_I,:)+j*Q_data(M_time_I,:))).^2;
        %% noise power where there is no echo.
         Npow_Power =10*log10( sum(IQ_powInt1(1,400:600))/201)-Total_PowerGain;
         Npow_noInt =10*log10( sum(IQ_powNoInt1(1,400:600))/201);
        IQ_powInt=10*log10(IQ_powInt1);
        IQ_powNoInt=10*log10(IQ_powNoInt1);
         xx=1:length(I_data_TI(1,:));  
        figure,plot(xx,(IQ_powInt),'r',xx,(IQ_powNoInt),'--b'); hold on;
        title('pulse integration');
        ylabel('dB');xlabel('range bin (30m)');
        legend('Integration','non-integration');   
          Nm=501:600;
        NoiseNoInt =sum(IQ_powNoInt(Nm))/length(Nm);
        IQ_powNoInt=IQ_powNoInt-NoiseNoInt;

        pulse_mode;
    end

    
end%%while(fft_time)   




%%%%% get the average power : non coherent integration
IQ_TI=I_data_TI+ j*Q_data_TI;
IQ_POWER=sum(((abs(IQ_TI)).^2),1)/M_FFT;
% IQ_POWER=10*log10(abs(sum((((IQ_TI))),1)/M_FFT));
IQ_POWER_AVG(Spectral_time,:)=(IQ_POWER);
NoisePower_AVG(Spectral_time)=10*log10(sum(IQ_POWER(400:600-1)/200));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%DFT   %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
win=(ones(1,length(IQ_TI(:,1))))';
% win=hann(length(IQ_TI(:,1)));
%% fft
    for i=1:length(I_data_TI(1,:))
        IQ_TI_WIN=real(IQ_TI(:,i)).*win+j*imag(IQ_TI(:,i)).*win;
        FFT_IQ(:,i)=fftshift(fft(IQ_TI_WIN));
    end

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% %% Spectral average%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if Spectral_time==1
     Spectral_avg_tmp=zeros(M_FFT,length(FFT_IQ(1,:)));
 end
 spectral_pow =(abs(FFT_IQ)/M_FFT).^2; %power spectral
 Spectral_avg_tmp= spectral_pow+  (Spectral_avg_tmp);% power average
 
 %%%% 
 

end %% while(Spectral_time)
  Spectral_avg = ((Spectral_avg_tmp/Spectral_time));
  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% %%remove constant current in  the Spectral average%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% %% zero frequency( three point) are replaced by the neigbout 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 Spectral_avg(M_FFT/2-1,:)=(Spectral_avg(M_FFT/2-3,:)+Spectral_avg(M_FFT/2+3,:))/2;
 Spectral_avg(M_FFT/2,:)=(Spectral_avg(M_FFT/2-2,:)+Spectral_avg(M_FFT/2+2,:))/2;
 Spectral_avg(M_FFT/2+1,:)=(Spectral_avg(M_FFT/2-4,:)+Spectral_avg(M_FFT/2+4,:))/2;
  
  xx=((-M_FFT)/2:M_FFT/2-1).*double((radar_prf/M_FFT))*WaveLength/2/M_time_I;

  figure,
  subplot(211);plot(xx, 10*log10(Spectral_avg(:,40)),'r',xx,20*log10(abs(FFT_IQ(:,280))/M_FFT),'b');title('Velocity Spectral');ylabel('dB');xlabel('m/s');legend('average','no average');
  subplot(212);plot(xx, 10*log10(Spectral_avg(:,41)),'r',xx,20*log10(abs(FFT_IQ(:,560))/M_FFT),'b');title('Velocity Spectral');ylabel('dB');xlabel('m/s');legend('average','no average');
  tt=1:M_FFT/2-30;
  
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% %% Peak Spectral search %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iii=1:length(Spectral_avg(1,:))
    Peak_SignalPower(iii)=max( Spectral_avg(:,iii));
    
    %%%noise power calculation:0-3/8Nfft  or 5/8Nfft-Nfft
    xx=1:floor(3*M_FFT/8);
    Noise1Power = sum(Spectral_avg(xx,iii))/length(xx);
    xx=floor(5*M_FFT/8):M_FFT;
    Noise2Power = sum(Spectral_avg(xx,iii))/length(xx);
    if (Noise1Power>Noise2Power)
        NoiseSpectralPower(iii)=Noise2Power;
    else
        NoiseSpectralPower(iii)=Noise1Power;
    end
    STR_spectral_withnoise(iii)=10*log10(Peak_SignalPower(iii)/NoiseSpectralPower(iii));
    
end
  Nm=501:600;
  %dection threshold
  THR_DectSpectral= max(STR_spectral_withnoise(Nm))+1;
  for iii=1:length(STR_spectral_withnoise)
      if STR_spectral_withnoise(iii)<THR_DectSpectral %%noise 
        STR_spectral(iii)=STR_spectral_withnoise(iii)-THR_DectSpectral;
      else  % signal
         STR_spectral(iii)=STR_spectral_withnoise(iii);  
      end;
  end
        
  %%%%%% non-coherent power average
  IQ_POWER_AVG2=sum(IQ_POWER_AVG,1)/M_Spectral_I;
  IQ_POWER_NonItg_withnoise= 10*log10(sum(IQ_POWER_AVG,1)/M_Spectral_I);
  THR_DectPavg= sum(IQ_POWER_NonItg_withnoise(Nm))/length(Nm);
  IQ_POWER_NonItg=IQ_POWER_NonItg_withnoise-THR_DectPavg;
  yy=(1:length(IQ_POWER_NonItg_withnoise)); 
 
  figure(1);plot(yy,(IQ_POWER_NonItg_withnoise),'k');
  xx=(1:length(IQ_POWER_NonItg_withnoise))*0.03; 
   yy=1:length(STR_spectral)-1;
   xx=xx(yy);
%    figure,plot(xx,STR_spectral(yy),'r',xx,IQ_POWER_NonItg(yy),'b',xx,IQ_powNoInt(yy),'k');  
   figure,
   plot(xx,IQ_powNoInt(yy),'k');xlabel('range(km)');ylabel('signal-to-threshold ratio (dB)'); axis([4 15 -5 50]);grid on;title('no integration');
   set(gcf, 'position', [450 100 400 350 ]);  %[起始位置  宽度]
   figure,
   plot(xx,IQ_POWER_NonItg(yy),'k');xlabel('range(km)');ylabel('signal-to-threshold ratio(dB)'); axis([4 15 -5 50]);grid on;title('non conherent(power average M=32768)');
   set(gcf, 'position', [450 100 400  350 ]);  %[起始位置  宽度]
   figure,
   plot(xx,STR_spectral(yy),'k');xlabel('range(km)');ylabel('signal-to-threshold ratio (dB)'); axis([4 15 -5 50]);grid on;title('conherent(Npa=2,Ndft=512 Nsavg=32)');
   set(gcf, 'position', [450 100 400 350 ]);  %[起始位置  宽度]
  
    %% moment estimation
  IQ_m0= (sum(Spectral_avg));
  fi=((-M_FFT)/2:M_FFT/2-1).*double((radar_prf/M_FFT))/M_time_I;
  IQ_m1=fi*Spectral_avg;
  IQ_m2=(fi.^2)*Spectral_avg;
  Nm=501:600;
  Noisepow= 10*log10(sum(IQ_m0(Nm))/length(Nm));
  %% power,velocity ,spectral width
  Pr=10*log10(IQ_m0);
  fr=-1*IQ_m1./IQ_m0;
   Wr=2*((IQ_m2./IQ_m0-fr.^2).^0.5)*WaveLength/2;
   for ii=1:length(fr)
     fii=fi-fr(i);
   end
   IQ_m22=(fii.^2)*Spectral_avg;
   Wr2=IQ_m22./IQ_m0*WaveLength/2;
   Vr2=fr*WaveLength/2;
   Vr_max=radar_prf*WaveLength/2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% %% signal power %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% no echo, then spectralwidth=0
for iii=1:length(Wr2)
    if STR_spectral(iii)<2
        Wr2(iii)=0;
        Wr2_2(iii)=1;% 
        Vr2(iii)=0;     
    elseif STR_spectral(iii)<25
        Wr2_2(iii)=floor(2*M_FFT/Vr_max); % 2m/s
    else
        Wr2_2(iii)=floor(Wr(iii)*M_FFT/Vr_max);
    end
end

%信号带宽:MHz
Radar_B=5;
%噪声系数:dB
Radar_F=5.5;%5.5dB
Pn=-114+10*log10(Radar_B)+(Radar_F);
STR_Thresd=0.25;
Pr_Spectal= STR_spectral_withnoise -10*log10(M_FFT)+Pn- 10*log10(M_time_I)+10*log10(Wr2_2)%;+10*log10(STR_Thresd)%;-0.5*10*log10(Spectral_time); %noise level did not decrease
Pn_Spenctal=10*log10(sum(NoiseSpectralPower(500:600-1)/100))-Total_PowerGain;
STR_Thresd=0.15;
%Pr_Avgpower=IQ_POWER_NonItg+Pn-0.5*10*log10(M_time_I*M_FFT*Spectral_time)%;-10*log10(STR_Thresd);
Pr_Avgpower1=IQ_POWER_NonItg_withnoise-Total_PowerGain;
Pn_Avgpower=10*log10(sum(IQ_POWER_AVG2(500:600-1))/100)-Total_PowerGain;
for iii=1:length(IQ_POWER_NonItg)
    if IQ_POWER_NonItg(iii)>5
        Pr_Avgpower(iii)=10*log10((10.^(Pr_Avgpower1(iii)/10))-(10.^(Pn_Avgpower/10)));
    else
         Pr_Avgpower(iii)=Pr_Avgpower1(iii);
    end

end
figure,
plot(xx,Pr_Spectal(yy),'k');;xlabel('range(km)');ylabel('radar echo power(dBm)'); axis([4 15 -5 50]);grid on;title('conherent(Npa=2,Ndft=512 Nsavg=32)');
 set(gcf, 'position', [450 100 400 350 ]);  %[起始位置  宽度]
 axis([4 15 -140 -60]); 
figure,
plot(xx,Pr_Avgpower(yy),'k');;xlabel('range(km)');ylabel('radar echo power (dBm) '); axis([4 15 -5 50]);grid on;title('non conherent(power average M=32768)');
 set(gcf, 'position', [450 100 400 350 ]);  %[起始位置  宽度]
 axis([4 15 -140 -60]); 
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% %% reflectivity factor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
 Pt=10;%W
 tao_t=[2,5,20];%us
WaveWidth=0.4;%degree
G_dB=52;%增益45.5
G=10^(G_dB/10);
Kw=0.813;% for water at 94GHZ
% R_bin=50*10^3;%50km
lamga=0.86;%cm
%噪声系数:dB
Radar_F=5.5;%5.5dBSpectral_avg
%信号带宽:MHz
Radar_B=5;
%灵敏度

L_rec=0.6;L_send=0.6;%接收和发射损耗为2dB
tao=tao_t(3);
C_eq1=pi^5*(10^-17)*Pt*G^2*tao*WaveWidth^2*Kw;
C_eq2=6.75*2^14*log(2)*lamga^2;
Radar_C=C_eq1/C_eq2;     
R_bin=(1:length(IQ_POWER_NonItg_withnoise))*0.03;

Ze_Spectral=Pr_Spectal-10*log10(Radar_C)+L_rec+L_send+20*log10(R_bin);
Ze_NonPowAvg=Pr_Avgpower-10*log10(Radar_C)+L_rec+L_send+20*log10(R_bin);

figure,
plot(xx,Ze_Spectral(yy),'k');;xlabel('range(km)');ylabel('refelctor factor(dBZ)'); axis([4 15 -5 50]);grid on;title('conherent(Npa=2,Ndft=512 Nsavg=32)');
 set(gcf, 'position', [450 100 400 350 ]);  %[起始位置  宽度]
 axis([4 15 -40 30]);
figure,
plot(xx,Ze_NonPowAvg(yy),'k');;xlabel('range(km)');ylabel('refelctor factor(dBZ)'); axis([4 15 -5 50]);grid on;title('non conherent(power average M=32768)');
 set(gcf, 'position', [450 100 400 350 ]);  %[起始位置  宽度]
 axis([4 15 -40 30]); 

   Pr=Pr-Total_PowerGain;
   figure,
   subplot(121);plot(Ze_Spectral(yy),xx,'k',Ze_NonPowAvg(yy),xx,'b');grid on;
   title('Power,pulsewidth=20us');xlabel('dBZ');ylabel('km');
   legend('coherent','non coherent');
   axis([ -40 20 4 15 ]);
   subplot(122);h=plot((Vr2(yy)),xx,'k');
    title('velocity,pulsewidth=20us');xlabel('m/s');ylabel('km');grid on;
   axis([ -10 +10 4 15 ]);
%    set(h,'LineWidth',1.5)
%       subplot(133);plot(round(Wr2(yy)),xx,'b');
%     title('velocity,pulsewidth=20us');xlabel('m/s');ylabel('km');
%    axis([ -10 +10 4 15 ]);
 over =1; 

end
over=1;








