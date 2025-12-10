clc;
clear all;

SND=30;
cc=0.01;
f0=1270;
PRF=f0;
WaveLength=0.1;

fd=120;%平均多普勒频移120Hz
vel=WaveLength/2*fd
Vmax=WaveLength/4*PRF
dv1=1;%谱宽1m/s
dv2=2;%谱宽2m/s
dv3=4;%谱宽4m/s
df1=2/WaveLength*dv1;
df2=2/WaveLength*dv2;
df3=2/WaveLength*dv3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%数值模拟产生噪声谱%%%%%%%%%%%%%%
NoiseSND=-50;
df=df2;
Pn=f0*cc;
Pr=Pn*10^(NoiseSND/10);
fi=[-f0/2:10:f0/2];
Sf=-log(1-randn(1,length(fi))).*(Pr/(sqrt(2*pi)*df).*exp(-(fi-fd).^2./(2*(df.^2)))+cc);%s为模拟的离散后的有白噪声的回波信号
%对多普勒相位谱进行模拟,假设相位谱随机分布在(0, 2P) 区间,即: ,ψ（f）=2πRND
rd=2*pi*randn(1,length(fi));
An=sqrt(Sf).*cos(rd);
Bn=sqrt(Sf).*sin(rd);
A=An+Bn*j;
Pyy=A.*conj(A);
NoiseSf=Pyy;
%频谱搬移
% NoiseSf(1:length(fi)/2) =  A(length(fi)/2+1:length(fi));
% NoiseSf(length(fi)/2+1:length(fi)) = A(1:length(fi)/2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%结束产生噪声谱%%%%%%%%%%%%%%%%%%
figure(1);subplot(211);plot(fi,Pyy);title('模拟回波.功率谱');subplot(212);plot(fi,10*log10(abs(Sf)));title('模拟回波.理想功率谱');
%%%%%%%%%%%数值模拟产生对应多普勒平移、谱宽的高斯模型天气信号%%%%%
df=df2;
Pn=f0*cc;
Pr=Pn*10^(SND/10);

fi=[-f0/2:10:f0/2];
Sf1=-log(1-randn(1,length(fi))).*(Pr/(sqrt(2*pi)*df).*exp(-(fi-fd).^2./(2*(df.^2)))+cc);%s为模拟的离散后的有白噪声的回波信号
% Sf1=(Pr/(sqrt(2*pi)*df).*exp(-(fi-fd).^2./(2*(df.^2)))+cc);%s为模拟的离散后的有白噪声的回波信号
fd=120;
Sf2=-log(1-randn(1,length(fi))).*(Pr/(sqrt(2*pi)*df).*exp(-(fi-fd).^2./(2*(df.^2)))+cc);%s为模拟的离散后的有白噪声的回波信号
Sf=Sf1;%+Sf2;
%对多普勒相位谱进行模拟,假设相位谱随机分布在(0, 2P) 区间,即: ,ψ（f）=2πRND
rd=2*pi*randn(1,length(fi));
An=sqrt(Sf).*cos(rd);
Bn=sqrt(Sf).*sin(rd);
A=An+Bn*j;
Pyy=10*log10(An.^2+Bn.^2);
% vi =  WaveLength/2*fi;
figure(1);subplot(211);plot(fi,Pyy);title('模拟回波.功率谱');subplot(212);plot(fi,10*log10(abs(Sf1)));title('模拟回波.理想功率谱');

%频谱搬移
tempL = A(1:length(fi)/2);
tempH = A(length(fi)/2+1:length(fi));
A(1:length(fi)/2) = tempH;
A(length(fi)/2+1:length(fi)) =tempL;

TimeDomainSeq=ifft(A,length(fi));
figure(2);
subplot(2,1,1),plot(real(TimeDomainSeq));title('时域.实部');
subplot(2,1,2),plot(imag(TimeDomainSeq));title('时域.虚部');
%%%%%%%%%%%%%%%%%%%%%%%%结束产生高斯模型天气信号%%%%%%%%%%%%

%%%%%%%%%%%%%%%% FFT方法求速度、谱宽 %%%%%%%%%%%%%%%%
%加窗
FFTlen=length(fi);
IQs=TimeDomainSeq;
win=hamming(FFTlen);
% win=hanning(FFTlen);
% IQs=IQs.*win';
Y=fft(IQs,FFTlen);
n=[1:1:FFTlen];
fi=(n-FFTlen/2)*(PRF/FFTlen);
pyy=Y.*conj(Y);
%%频谱搬移
tempL = pyy(1:length(fi)/2);tempH = pyy(length(fi)/2+1:length(fi));
pyy(1:length(fi)/2) = tempH;pyy(length(fi)/2+1:length(fi)) =tempL;
figure(3);plot(fi,10*log10(pyy));
title('带噪声功率谱');
pyy=pyy-NoiseSf;%%%%%%%%%%%%%%%%%%%%%%改进的FFT方法去除噪声谱
figure(4);plot(fi,10*log10(pyy));
title('去除噪声后功率谱');

%求平均多普勒速度
sumsf = sum(pyy.*fi);
sumf = sum(pyy);
FFT_fd=sumsf/sumf;                %多普勒频率
FFT_vel=FFT_fd*WaveLength/2.0      %计算结果：多普勒速度
%求谱宽
sumdf = sum( ((fi-FFT_fd).^2) .*pyy);			
FFT_wid=(sqrt(sumdf/sumf)) *  WaveLength/2.0        %计算结果：谱宽
%%%%%%%%%%%%%% FFT方法计算结束 %%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%% 脉冲对方法 %%%%%%%%%%%%%%%%%
RT_ImagSum=0;RT_RealSum=0;
X_T = real(TimeDomainSeq);%X(T)
Y_T = -imag(TimeDomainSeq);%Y(T)
len=length(TimeDomainSeq);
for i=1 : (len-1);
    RT_ImagSum=RT_ImagSum + Y_T(i)*X_T(i+1)-X_T(i)*Y_T(i+1);
    RT_RealSum=RT_RealSum + X_T(i)*X_T(i+1)+Y_T(i)*Y_T(i+1);
end

Ts=1/f0;
VNYQ=WaveLength/(4*Ts);
PPP_vel=VNYQ*atan2(RT_ImagSum,RT_RealSum)/3.1415926

%%%%%%%%%%%%%%%
% R0_p=0;
% for i=1 : len;
%     R0_p=R0_p+X_T(i)^2 + Y_T(i)^2;
% end
% RT_ImagSum=RT_ImagSum/len;
% RT_RealSum=RT_RealSum/len;
% sum=sqrt(RT_ImagSum^2+RT_RealSum^2)
% R0_p=R0_p/len
%     
% PPP_wid=(1/2*pi*Ts)*sqrt( 2*(1-sum/R0_p))
%%%%%%%%%%%%%%%
m_Sweeps=length(TimeDomainSeq);
M2=(m_Sweeps-1.0)*(m_Sweeps-1.0);
VS3=  VNYQ / sqrt(3.0);
VPI = VNYQ / pi;
		
NUM = (RT_ImagSum* RT_ImagSum + RT_RealSum* RT_RealSum)/M2;
PPcens=0;
for i=1 : length(TimeDomainSeq);
   PPcens=PPcens+abs(TimeDomainSeq(i))*abs(TimeDomainSeq(i));
end
NSEadj=0;
DEN = (PPcens/m_Sweeps - NSEadj)*(PPcens/m_Sweeps - NSEadj); 
lnND=log(NUM/DEN);
PPP_wid=0;
if(lnND > 0) PPP_wid = 0
else 
    PPP_wid = VPI * sqrt(-lnND);
    if(PPP_wid > VS3)     PPP_wid =VS3	
    else PPP_wid
    end
end
%%%%%%%%%%%%%% 脉冲对方法计算结束 %%%%%%%%%%

