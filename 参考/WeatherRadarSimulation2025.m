clear all
close all
clc
%%2025-12
WaveLength=0.1;   %雷达波长
%%     设置仿真的两个叠加信号的参数
f1=10;    %f1为信号1的多普勒频率
f2=200;   %f2为信号2的多普勒频率 
SR1=10;   %SR1为信号1的信噪比db
SR2=10;  %SR2为信号2的信噪比db
df1=5;   %df1为信号1的多普勒谱宽
df2=30;  %df2为信号2的多普勒谱宽

fs=1200;   %fs采样频率

cc=0.01;   %cc为噪声功率谱密度 
Pn=fs*cc;   %Pn为每秒种白噪声总功率

Pr1=Pn*10^(SR1/10);  %Pr1为信号1的总功率
Pr2=Pn*10^(SR2/10);  %Pr2为信号2的总功率
M=64;   %脉冲积累数

%% 模拟短PRT得到的编码后的I，Q信号(存在回波叠加) V
f=-fs/2 :fs/M:(fs/2-fs/M);   
s1=-log(1-rand(1,M)).*(Pr1/(sqrt(2*pi)*df1).*exp(-(f-f1).^2./(2*(df1.^2)))+cc); %s1为离散后的有白噪声的回波信号1 
s2=-log(1-rand(1,M)).*(Pr2/(sqrt(2*pi)*df2).*exp(-(f-f2).^2./(2*(df2.^2)))+cc); %s2为离散后的有白噪声的回波信号2
s=s1+s2;   %s为含有噪声的叠加回波功率谱

%绘制两个叠加信号s1和s2的回波功率谱
figure(5)
velocity=-fs/2*WaveLength/2 :fs/M*WaveLength/2:(fs/2-fs/M)*WaveLength/2;

plot(velocity,20*log10(abs(s)));
hold on
plot(velocity,20*log10(abs(s1)),'g--');
hold on
plot(velocity,20*log10(abs(s2)),'r--');
grid on
legend('叠加后的信号频谱','弱回波程的频谱','强回波程的频谱');
title('调制前叠加的两个信号的频谱');
xlabel('速度(m/s)');
ylabel('幅度(dB)');

a1=2*pi*rand(1,M);  %a1为模拟的一次回波的相位谱
a2=2*pi*rand(1,M);  %a2为模拟的二次回波的相位谱

As1=sqrt(s1).*cos(a1);  %As1为离散的一次回波复频谱的实部
As2=sqrt(s2).*cos(a2); %As2为离散的二次回波复频谱的实部

Bs1=sqrt(s1).*sin(a1);  %Bs1为离散的一次回波的复频谱的虚部
Bs2=sqrt(s2).*sin(a2);  %Bs2为离散的二次回波的复频谱的虚部

sf1=As1+1i*Bs1;   %sf1为离散的含有噪声的一次回波的复频谱
sf2=As2+1i*Bs2;  %sf2为离散的含有噪声的二次回波的复频谱

%对sf进行傅立叶反变换得到复时间序列sig
sig1=(ifft(sf1,M));
sig2=(ifft(sf2,M));

%叠加后的时间序列
sig=sig1+sig2;

figure,
subplot(211);
plot(1:length(sig1),real(sig1),'r--',1:length(sig1),imag(sig1),'b--');hold on;
plot(1:length(sig1),real(sig2),'g--',1:length(sig1),imag(sig2),'k--');hold on;
title('时域回波');xlabel('距离库');ylabel('幅度');grid on;
legend('信号1：I','信号1：Q','信号2：I','信号2：Q');

sig_FFT=abs((fft(sig)));
subplot(212);

plot(f,20*log10(sig_FFT));grid on;
title('时域两个信号的频谱');
xlabel('速度(m/s)');
ylabel('幅度(dB)');

OVER=1;

