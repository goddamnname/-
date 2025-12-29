function PPI_plot(DATA, Numgates, Detection_range, AZ_rxm, RangeResolution, type, el)
%--------type:z为绘制反射率,v为绘制速度,w为绘制谱宽,Zdr为绘制差分反射率,rhv0为绘制相关系数,PPI_Diff为绘制PPI差值图,(DATA为处理后一圈的气象信息,Numgates为距离库数量,Detection_range为探测距离，AZ_rxm为画图每个径向对应角度,RangeResolution为距离分辨率,el为仰角层数)
    %----------------------绘制伪彩图----------------------%
if strcmp(type,'z')
    az_rxm = AZ_rxm(1,:)*pi/180; %将角度转换成弧度
%     colorRef= [                 
%         0  0  0  % <-5
%         0 154 154  % -5-0
%         192 192 254  % 0-5
%         91 88 228
%         30 38 208  % 10-15
%         166 252 168
%         0 232 10  % 20-25
%         0 136 0 
%         252 244 100  % 30-35
%         200 200 2
%         140 140 0  % 40-45
%         254 176 176  % 50-55
%         254 88 88
%         238 2 48
%         212 142 254  % 60-70
%         170 36  250];
%         colormap(colorRef/255);

        colorRef= [                 
         0  0  0  % <-5

        0 151 154
        192 192 254
        122 114 238
        30 38 208
        166 252 168 

        0 232 10
        0 136 0
        252 244 100
        200 200 2
        140 140 0

        254 176 176
        254 88 88
        238 2 48
        212 142 254
        170 36 250 %>65
        ];%16种
        colormap(colorRef/255.); 
        DATA(DATA==0) = -999.;
%         global Z_index;
        Z_index=[-5;0;5;10;15; 20;25;30;35;40;45;50;55;60;65;150];  %对应的水平反射率Zh
        Z_nan = nan(size( DATA));  

             %数值与色标对应
        for i=1:length(Z_index)-1
             %数值与色标对应
             c= DATA>Z_index(i) & DATA<= Z_index(i+1); 
             Z_nan(c)=i+1.5;
             if DATA > Z_index(16)
                Z_nan(c)=16; 
             elseif DATA < Z_index(1)
                 Z_nan(c)=1;
             end
        end
        Z_nan(isnan(Z_nan)) = -999;

        
        r=(1:Numgates)' * RangeResolution;  %对应每一格的探测距离
        X = (r*sin(az_rxm))';  
        Y = (r*cos(az_rxm))';

        DATA(DATA==0) = -999.;
        pcolor(X,Y,Z_nan);%绘制伪彩图
%         pcolor(X,Y,Z_nan-4.7);%绘制伪彩图,参数修改
        hold on;
%         caxis([-20,85]);    %caxis(limits) 设置当前坐标区的颜色图范围。
                            %limits 是 [cmin cmax] 形式的二元素向量。
                            %颜色图索引数组中小于或等于 cmin 的所有值映射到颜色图的第一行。
                            %大于或等于 cmax 的所有值映射到颜色图的最后一行。
                            %介于 cmin 和 cmax 之间的所有值以线性方式映射到颜色图的中间各行。
                            %%%在给出的范围内等距划分出之前colorRef的每个颜色
        DATA(DATA==-999) = 0.;  
     elseif strcmp(type,'v')
        az_rxm = AZ_rxm(1,:)*pi/180; %将角度转换成弧度
%         colorRef= [                 
%         123 227 255
%         0 227 255
%         0 178 181
%         0 255 0
%         0 199 0
%         0 130 0
%         200 194 162
%         252 252 252
%         255 0 0
%         255 89 90
%         255 178 181
%         255 125 0
%         255 211 0
%         255 255 0
%         123 0 123];
%         figure(1)
%         colormap(colorRef/255);

        colorRef= [                 
             0  0  0  % <-5
        124 224 224
        0 239 239
        0 151 154
        0 255 0
        0 196 0

        0 128 0
        255 255 255
        255 255 255
        245 0 0
        254 88 88

        254 176 176
        255 152 0
        255 230 0
        254 254 0
        ];%15种
        colormap(colorRef/255.); 
        DATA(DATA==0) = -999.;
%         global Z_index
        Z_index=[-30;-27;-20;-15;-10;-5;-1;0;1;5;10;15;20;27;100];  %对应的水平反射率Zh
        Z_nan = nan(size(DATA));  

             %数值与色标对应
        for i=1:length(Z_index)-1
             %数值与色标对应
             c= DATA>Z_index(i) & DATA<= Z_index(i+1); 
             Z_nan(c)=i+1.5;
             if DATA > Z_index(15)
                Z_nan(c)=15; 
             elseif DATA < Z_index(1)
                 Z_nan(c)=1;
             end
        end
        Z_nan(isnan(Z_nan)) = -999;

        r=(1:Numgates)' * RangeResolution;  %对应每一格的探测距离
        X = (r*sin(az_rxm))';  
        Y = (r*cos(az_rxm))';

%         DATA(DATA==0) = -999.;
        pcolor(X,Y,Z_nan);%绘制伪彩图
        hold on;
%         caxis([-64,63]);    %caxis(limits) 设置当前坐标区的颜色图范围。
                            %limits 是 [cmin cmax] 形式的二元素向量。
                            %颜色图索引数组中小于或等于 cmin 的所有值映射到颜色图的第一行。
                            %大于或等于 cmax 的所有值映射到颜色图的最后一行。
                            %介于 cmin 和 cmax 之间的所有值以线性方式映射到颜色图的中间各行。
                            %%%在给出的范围内等距划分出之前colorRef的每个颜色
                            
        DATA(DATA==-999) = 0.;

    elseif strcmp(type,'w')
        az_rxm = AZ_rxm(1,:)*pi/180; %将角度转换成弧度
%         colorRef= [                 
%         231 227 231
%         123 227 231
%         0 227 231
%         0 157 181
%         0 255 255
%         0 199 0
%         0 130 0
%         255 255 0
%         255 211 0
%         255 125 0
%         255 178 181
%         255 121 121
%         200 53 53
%         255 0 0
%         123 0 123];
% %         figure(1)
%         colormap(colorRef/255);

        colorRef= [  
        0 0 0
        220 240 220 
        124 224 224
        0 210 212
        0 151 154
        0 255 255

        0 196 0
        0 128 0
        254 254 0
        255 230 0
        255 152 0

        254 176 176
        175 88 88
        242 15 0
        230 0 0
        ];%15种

        colormap(colorRef/255.); 
        DATA(DATA==0) = -999.;
    %     global Z_index;
        Z_index=[0;1;2;3;4;5;6;7;8;9;10;11;12;13;100];  %对应的水平反射率Zh
        Z_nan = nan(size( DATA));
        for i=1:length(Z_index)-1
             %数值与色标对应
             c= DATA>Z_index(i) & DATA<= Z_index(i+1); 
             Z_nan(c)=i+1.5;
             if DATA > Z_index(15)
                Z_nan(c)=15; 
             elseif DATA < Z_index(1)
                 Z_nan(c)=1;
             end
        end
        Z_nan(isnan(Z_nan)) = -999;

            r=(1:Numgates)' * RangeResolution;  %对应每一格的探测距离
            X = (r*sin(az_rxm))';  
            Y = (r*cos(az_rxm))';
    %         Z_nan(Z_nan>6) = 0;
            DATA(DATA==0) = -999.;
            pcolor(X,Y,Z_nan);%绘制伪彩图
    %         pcolor(X,Y,Z_nan-1.8);%绘制伪彩图,参数修改
            hold on;
    %         caxis([0,63]);    %caxis(limits) 设置当前坐标区的颜色图范围。
                                %limits 是 [cmin cmax] 形式的二元素向量。
                                %颜色图索引数组中小于或等于 cmin 的所有值映射到颜色图的第一行。
                                %大于或等于 cmax 的所有值映射到颜色图的最后一行。
                                %介于 cmin 和 cmax 之间的所有值以线性方式映射到颜色图的中间各行。
                                %%%在给出的范围内等距划分出之前colorRef的每个颜色
            DATA(DATA==-999) = 0.;
        elseif strcmp(type,'Zdr')
            az_rxm = AZ_rxm(1,:)*pi/180; %将角度转换成弧度
            
            colorRef= [    
                0 0 0
               70, 70, 70
               110, 110, 110
               150, 150, 150
               200, 200, 200
               220, 240, 220

               0, 192, 39
               0, 232, 10
               36, 255, 36
               255, 255, 30
               255, 230, 0

               255, 188, 0
               255, 152, 0
               255, 94, 0
               242, 15, 0
               187, 0, 58
               255, 0, 255
               ];%17种
            colormap(colorRef/255.); 
            DATA(DATA==0) = -999.;
%             global Z_index;
            Z_index=[-4.0;-3.0;-2.0;-1.0;0.0;0.2;0.5;0.8;1.0;1.5;2.0;2.5;3.0;3.5;4.0;5.0;100];  %对应的水平反射率Zh
            Z_nan = nan(size( DATA));  

                 %数值与色标对应
            for i=1:length(Z_index)-1
                 %数值与色标对应
                 c= DATA>Z_index(i) & DATA<= Z_index(i+1); 
                 Z_nan(c)=i+1.5;
                 if DATA > Z_index(17)
                    Z_nan(c)=17; 
                elseif DATA < Z_index(1)
                    Z_nan(c)=1;
             end
            end
            Z_nan(isnan(Z_nan)) = -999;

            r=(1:Numgates)' * RangeResolution;  %对应每一格的探测距离
            X = (r*sin(az_rxm))';  
            Y = (r*cos(az_rxm))';

    %         DATA(DATA==0) = -999.;
            pcolor(X,Y,Z_nan);%绘制伪彩图
            hold on;

            DATA(DATA==-999) = 0.;
        elseif strcmp(type,'PPI_Diff')
            az_rxm = AZ_rxm(1,:)*pi/180; %将角度转换成弧度
            
            colorRef= [    
                0 0 0
               70, 70, 70
               110, 110, 110
               150, 150, 150
               200, 200, 200
               220, 240, 220

               0, 192, 39
               0, 232, 10
               36, 255, 36
               255, 255, 30
               255, 230, 0

               255, 188, 0
               255, 152, 0
               255, 94, 0
               242, 15, 0
               187, 0, 58
               255, 0, 255
               ];
            colormap(colorRef/255.); 
            DATA(DATA==0) = -999.;
%             global Z_index;
            Z_index=[-3;-2;-1.5;-1;-0.8;-0.4;-0.2;0;0.2;0.4;0.8;1.0;1.5;2;3;4;5];  %对应的水平反射率Zh
            Z_nan = nan(size( DATA));  

                 %数值与色标对应
            for i=1:length(Z_index)-1
                 %数值与色标对应
                 c= DATA>Z_index(i) & DATA<= Z_index(i+1); 
                 Z_nan(c)=i+1.5;
            end
            Z_nan(isnan(Z_nan)) = -999;

            r=(1:Numgates)' * RangeResolution;  %对应每一格的探测距离
            X = (r*sin(az_rxm))';  
            Y = (r*cos(az_rxm))';

    %         DATA(DATA==0) = -999.;
            pcolor(X,Y,Z_nan);%绘制伪彩图
            hold on;

            DATA(DATA==-999) = 0.;
        elseif strcmp(type,'rhv0')
            az_rxm = AZ_rxm(1,:)*pi/180; %将角度转换成弧度
            
            colorRef= [   
                0  0    0  
                0  60  255
                0  239  239
                0  210  212
                0  130  97
                0  150  55

                0  192  39
                0  218  13
                0  255  0
                255  255  30
                255  230  0

                255  188  0
                255  152  0
                255  94  0
                255  31  0
                193  0  0
                212  0  170
               ];%17种
            colormap(colorRef/255.); 
            DATA(DATA==0) = -999.;
        %     global Z_index;
            Z_index=[0;0.1;0.3;0.5;0.6;0.7;0.8;0.85;0.90;0.92;0.94;0.95;0.96;0.97;0.98;0.99;100];
            Z_nan = nan(size( DATA));  

            for i=1:length(Z_index)-1
                 c= DATA>Z_index(i) & DATA<= Z_index(i+1); 
                 Z_nan(c)=i+1.5;
                 if DATA > Z_index(17)
                    Z_nan(c)=17; 
                 elseif DATA < Z_index(1)
                     Z_nan(c)=1;
                 end
            end
            Z_nan(isnan(Z_nan)) = -999;

            r=(1:Numgates)' * RangeResolution;  %对应每一格的探测距离
            X = (r*sin(az_rxm))';  
            Y = (r*cos(az_rxm))';

    %         DATA(DATA==0) = -999.;
            pcolor(X,Y,Z_nan);%绘制伪彩图
            hold on;

            DATA(DATA==-999) = 0.;
            
        elseif strcmp(type,'Phi')
            az_rxm = AZ_rxm(1,:)*pi/180; %将角度转换成弧度
            
            colorRef= [    
            0 0 0
             0  60  255
            0  239  239
            0  210  212
            0  130  97
            0  150  55
            0  192  39
            0  218  13
            0  255  0
            255  255  30
            255  230  0
            255  188  0
            255  152  0
            255  94  0
            255  31  0
            193  0  0
            212  0  170
               ];%17种
            colormap(colorRef/255.); 
            DATA(DATA==0) = -999.;
            Z_index=[0;24;48;72;96;120;144;168;192;216;240;264;288;312;336;360;1000];  %对应的水平反射率Zh
            Z_nan = nan(size( DATA));  

                 %数值与色标对应
            for i=1:length(Z_index)-1
                 %数值与色标对应
                 c= DATA>Z_index(i) & DATA<= Z_index(i+1); 
                 Z_nan(c)=i+1.5;
                 if DATA > Z_index(17)
                    Z_nan(c)=17; 
                 elseif DATA < Z_index(1)
                     Z_nan(c)=1;
                 end
            end
            Z_nan(isnan(Z_nan)) = -999;

            r=(1:Numgates)' * RangeResolution;  %对应每一格的探测距离
            X = (r*sin(az_rxm))';  
            Y = (r*cos(az_rxm))';

    %         DATA(DATA==0) = -999.;
            pcolor(X,Y,Z_nan);%绘制伪彩图
            hold on;

            DATA(DATA==-999) = 0.;
        elseif strcmp(type,'SNR')
            az_rxm = AZ_rxm(1,:)*pi/180; %将角度转换成弧度
            
            colorRef= [                 
             0  0  0  % <-5

             0 151 154
            192 192 254
            122 114 238
            30 38 208
            166 252 168 

            0 232 10
            0 136 0
            252 244 100
            200 200 2
            140 140 0

            254 176 176
            254 88 88
            238 2 48
            212 142 254
            170 36 250];%16种
            colormap(colorRef/255.); 
            DATA(DATA==0) = -999.;
            Z_index=[-5;0;5;10;15; 20;25;30;35;40;45;50;55;60;65;150];  %对应的水平反射率Zh
            Z_nan = nan(size( DATA));  

                 %数值与色标对应
            for i=1:length(Z_index)-1
                 %数值与色标对应
                 c= DATA>Z_index(i) & DATA<= Z_index(i+1); 
                 Z_nan(c)=i+1.5;
                 if DATA > Z_index(16)
                    Z_nan(c)=16; 
                 elseif DATA < Z_index(1)
                     Z_nan(c)=1;
                 end
            end
            Z_nan(isnan(Z_nan)) = -999;

            r=(1:Numgates)' * RangeResolution;  %对应每一格的探测距离
            X = (r*sin(az_rxm))';  
            Y = (r*cos(az_rxm))';

    %         DATA(DATA==0) = -999.;
            pcolor(X,Y,Z_nan);%绘制伪彩图
            hold on;

            DATA(DATA==-999) = 0.;
            
         elseif strcmp(type,'KDP')
            az_rxm = AZ_rxm(1,:)*pi/180; %将角度转换成弧度
            
            colorRef= [    
            0 0 0
            0  255  255
            0  239  239
            0  151  154
            180  180  180
            0  192  39

            0  232  10 
            36  255  36
              255  255  30
             255  230  0 
            255  188  0

            255  152  0
            255  94  0
            242  15  0
            187  0  58
            255  0  255
               ];%16种
            colormap(colorRef/255.); 
            DATA(DATA==0) = -999.;
            Z_index=[-0.80;-0.40;-0.20;-0.10;0.10; 0.15;0.22;0.33;0.50;0.75;1.10;1.70;2.40;3.10;7.00;100];  %对应的水平反射率Zh
            Z_nan = nan(size( DATA));  

                 %数值与色标对应
            for i=1:length(Z_index)-1
                 %数值与色标对应
                 c= DATA>Z_index(i) & DATA<= Z_index(i+1); 
                 Z_nan(c)=i+1.5;
                 if DATA > Z_index(16)
                    Z_nan(c)=16; 
                 elseif DATA < Z_index(1)
                     Z_nan(c)=1;
                 end
            end
            Z_nan(isnan(Z_nan)) = -999;
            
            r=(1:Numgates)' * RangeResolution;  %对应每一格的探测距离
            X = (r*sin(az_rxm))';  
            Y = (r*cos(az_rxm))';

    %         DATA(DATA==0) = -999.;
            pcolor(X,Y,Z_nan);%绘制伪彩图
            hold on;

            DATA(DATA==-999) = 0.;
end

    %%
    %--------------------绘制图中定位坐标网格-------------------------%
    for R=Detection_range/5:Detection_range/5:Detection_range
        ta=0:0.001:2*pi; %提高分辨率使网格逼近圆形
        x=R*cos(ta);
        y=R*sin(ta);
        plot(x,y,'-w');
        hold on;
    end

    plot([0,0],[-Detection_range,Detection_range],'-w');
    hold on;
    plot([-Detection_range,Detection_range],[0,0],'-w');
    hold on;
    plot([-Detection_range,Detection_range],[-Detection_range,Detection_range],'-w');
    hold on;
    plot([-Detection_range,Detection_range],[Detection_range,-Detection_range],'-w');
    hold on;
    %%
    %---------------------着色------------------------%
%     colorbar;   %colorbar 在当前坐标区或图的右侧显示一个垂直颜色栏。颜色栏显示当前颜色图并指示数据值到颜色图的映射
%     shading flat;    % set color
%     % axis([80,150,-70,0]);
%     axis equal tight;  %调整图像为正方
%     % title('RXM(dBZ)')
    axis xy;
    ylim([-Detection_range Detection_range]);
    xlim([-Detection_range Detection_range]);
    axis square;                                                      %产生正方形坐标系
    hold on;
    set(gca,'YTick',ceil(-Detection_range:Detection_range/5:Detection_range))
    set(gca,'XTick',ceil(-Detection_range:Detection_range/5:Detection_range))
    xlabel({'Range (km)'},'FontSize',10,'FontName','Times New Roman');
    ylabel({'Range (km)'},'FontSize',10,'FontName','Times New Roman');
    set(gca,'FontSize',10,'FontName','Times New Roman');
    caxis([1 length(Z_index)+1]);
%      caxis([-5 80]);

    hh=colorbar('location','EastOutside');hold on;
    set(get(gca,'title'),'fontname','宋体');            %配置标题显示中文 
    set(hh,'ytick',1:1:length(Z_index)+1);
    set(hh,'FontSize',10,'FontName','Times New Roman'); %设置横纵坐标的字体大小
    shading flat;    % set color

    axis equal tight;  
    if strcmp(type,'z')
        title(['反射率(仰角为)',num2str(el)])
        set(hh,'yticklabel',{'Unit:dBz ',Z_index(1),Z_index(2),Z_index(3),Z_index(4),Z_index(5),Z_index(6),Z_index(7),Z_index(8),Z_index(9),Z_index(10),Z_index(11),Z_index(12),...
                                    Z_index(13),Z_index(14),Z_index(15)});
    elseif strcmp(type,'v')
        title(['速度(仰角为)',num2str(el)])
        set(hh,'yticklabel',{'Unit:m/s ',Z_index(1),Z_index(2),Z_index(3),Z_index(4),Z_index(5),Z_index(6),Z_index(7),Z_index(8),Z_index(9),Z_index(10),Z_index(11),Z_index(12),...
                                    Z_index(13),Z_index(14)});
    elseif strcmp(type,'w')
        title(['谱宽(仰角为)',num2str(el)])
        set(hh,'yticklabel',{'Unit:m/s ',Z_index(1),Z_index(2),Z_index(3),Z_index(4),Z_index(5),Z_index(6),Z_index(7),Z_index(8),Z_index(9),Z_index(10),Z_index(11),Z_index(12),...
                                    Z_index(13),Z_index(14)});
    elseif strcmp(type,'Zdr')
        title(['差分反射率(仰角为)',num2str(el)])
        set(hh,'yticklabel',{'Unit:dB ',Z_index(1),Z_index(2),Z_index(3),Z_index(4),Z_index(5),Z_index(6),Z_index(7),Z_index(8),Z_index(9),Z_index(10),Z_index(11),Z_index(12),...
                                    Z_index(13),Z_index(14),Z_index(15),Z_index(16)});
    elseif strcmp(type,'Zdr_Diff')
        title(['差分反射率差值(仰角为)',num2str(el)])
        set(hh,'yticklabel',{'Unit:dB ',Z_index(1),Z_index(2),Z_index(3),Z_index(4),Z_index(5),Z_index(6),Z_index(7),Z_index(8),Z_index(9),Z_index(10),Z_index(11),Z_index(12),...
                                    Z_index(13),Z_index(14),Z_index(15)});
    elseif strcmp(type,'rhv0')
        title(['相关系数(仰角为)',num2str(el)])
        set(hh,'yticklabel',{'Unit: ',Z_index(1),Z_index(2),Z_index(3),Z_index(4),Z_index(5),Z_index(6),Z_index(7),Z_index(8),Z_index(9),Z_index(10),Z_index(11),Z_index(12),...
                                    Z_index(13),Z_index(14),Z_index(15),Z_index(16)});
    elseif strcmp(type,'Phi')
        title(['差分传播相位(仰角为)',num2str(el)])
        set(hh,'yticklabel',{'Unit:deg ',Z_index(1),Z_index(2),Z_index(3),Z_index(4),Z_index(5),Z_index(6),Z_index(7),Z_index(8),Z_index(9),Z_index(10),Z_index(11),Z_index(12),...
                                    Z_index(13),Z_index(14),Z_index(15),Z_index(16)});
    elseif strcmp(type,'SNR')
        title(['信噪比(仰角为)',num2str(el)])
        set(hh,'yticklabel',{'Unit:dBZ ',Z_index(1),Z_index(2),Z_index(3),Z_index(4),Z_index(5),Z_index(6),Z_index(7),Z_index(8),Z_index(9),Z_index(10),Z_index(11),Z_index(12),...
                                    Z_index(13),Z_index(14),Z_index(15)});
    elseif strcmp(type,'PPI_Diff')
        title(['差值图(仰角为)',num2str(el)])
        set(hh,'yticklabel',{'Unit:dBZ ',Z_index(1),Z_index(2),Z_index(3),Z_index(4),Z_index(5),Z_index(6),Z_index(7),Z_index(8),Z_index(9),Z_index(10),Z_index(11),Z_index(12),...
                                    Z_index(13),Z_index(14),Z_index(15)});
    elseif strcmp(type,'KDP')
        title(['差分传播相移率(仰角为)',num2str(el)])
        set(hh,'yticklabel',{'Unit:deg/km ',Z_index(1),Z_index(2),Z_index(3),Z_index(4),Z_index(5),Z_index(6),Z_index(7),Z_index(8),Z_index(9),Z_index(10),Z_index(11),Z_index(12),...
                                Z_index(13),Z_index(14),Z_index(15)});
    end
    
    hold on

end

