function [fd, sigma] = CalVdandSigma(spec_log, Noise_level,N,prf)
    snf = spec_log - Noise_level;
    snf = 10.^(snf./10);
    k = 0:N-1;  %N为采样点数
    fi = -prf/2+prf/N.*k;
    resu1 = sum(snf.*fi');
    resu2 = sum(snf);
    fd = resu1/resu2;
    resu3 = sum(snf .* (fi'-fd).^2);
    sigma = sqrt(resu3/resu2);
end

