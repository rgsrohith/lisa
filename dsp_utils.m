function y = stdize(x)
%STDIZE Z-score standardization with protection against NaNs/const
    x = x(:);
    mu = nanmean(x);
    sd = nanstd(x);
    if sd < eps
        y = x*0;
    else
        y = (x - mu) ./ sd;
    end
end

function y = conv_enhance(x)
%CONV_ENHANCE Simple derivative-like convolution to emphasize motion edges
    k = [1 -1]; % first difference
    y = conv(x(:), k, 'same');
end

function Hd = make_lowpass_fir(fs, fp, fst, rp, ast)
%MAKE_LOWPASS_FIR Design a low-pass FIR filter
%   fs  - sample rate (Hz)
%   fp  - passband frequency (Hz)
%   fst - stopband frequency (Hz)
%   rp  - passband ripple (dB)
%   ast - stopband attenuation (dB)
    Hd = designfilt('lowpassfir', ...
        'PassbandFrequency', fp, ...
        'StopbandFrequency', fst, ...
        'PassbandRipple', rp, ...
        'StopbandAttenuation', ast, ...
        'SampleRate', fs);
end

function yf = apply_fir(x, Hd)
%APPLY_FIR Filter column vector x with FIR filter Hd
    if isempty(Hd)
        yf = x(:);
        return;
    end
    yf = filtfilt(Hd.Numerator, 1, x(:));
end

function [c,lags,peakLag,peakVal] = corr_with_template(x, tpl)
%CORR_WITH_TEMPLATE Normalized cross-correlation with a template vector
    x = stdize(x(:));
    tpl = stdize(tpl(:));
    [c,lags] = xcorr(x, tpl, 'normalized');
    [peakVal, idx] = max(c);
    peakLag = lags(idx);
end
