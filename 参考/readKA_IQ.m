function PRT = readKA_IQ(fid)
        PRT.head=dec2hex(fread (fid,1,'bit32=>int32'));     %% 0x5a5a1234
        PRT.Prt_len=fread (fid,1,'bit16=>int32');   %% prt clk number
        PRT.DIFCLK=fread (fid,1,'bit16=>int32');    %% IF CLK 20000khz
        PRT.DataLen=fread (fid,1,'bit32=>int32');   %% data length 
        PRT.T0cnt=fread (fid,1,'bit32=>int32');     %% PRT counter
        PRT.Antdata0=fread (fid,1,'bit32=>int32');  %% antenna 
        PRT.Antdata1=fread (fid,1,'bit32=>int32');  %% antenna
        PRT.Antdat3Pe=fread (fid,1,'bit8=>int32');  %% antenna
        PRT.Sys_daatmp=fread (fid,1,'bit8=>int32'); %% data tmp
        PRT.Sys_sts1=fread (fid,1,'ubit8');   %% system status
        PRT.Sys_spare=fread (fid,1,'bit8=>int32');  %% unused data
        PRT.Sys_sts2=fread (fid,1,'bit32=>int32');  %% PRTcounter for timer
        % IQ_data_length=PRT.DataLen;  
        % radar_prf= PRT.DIFCLK/PRT.Prt_len*10^3;      %% 20000khz/2500=8khz
