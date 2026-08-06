function fitOut = fitSimple24hCosinor(t, y)
%FITSIMPLE24HCOSINOR Fit null line vs 24 h cosine model (F-test on amplitude).

    fitOut = struct();
    fitOut.ok = false;
    fitOut.note = '';
    fitOut.isRhythmic = false;
    fitOut.betaNull = NaN;
    fitOut.betaCos = [NaN, NaN, NaN];
    fitOut.mesor = NaN;
    fitOut.amplitude = NaN;
    fitOut.acrophase_h = NaN;
    fitOut.acrophase_deg = NaN;
    fitOut.pZeroAmplitude = NaN;
    fitOut.R2Cos = NaN;
    fitOut.AdjR2Cos = NaN;
    fitOut.AICNull = NaN;
    fitOut.AICCos = NaN;
    fitOut.BICNull = NaN;
    fitOut.BICCos = NaN;

    t = t(:);
    y = y(:);
    n = numel(y);

    if n < 6
        fitOut.note = 'Too few observations.';
        return;
    end
    if numel(unique(y)) < 3
        fitOut.note = 'Too little variation.';
        return;
    end

    c = cos(2 * pi * t / 24);
    s = sin(2 * pi * t / 24);
    X0 = ones(n, 1);
    X1 = [ones(n, 1), c, s];

    if rank(X1) < 3
        fitOut.note = 'Cosinor design matrix is rank deficient.';
        return;
    end

    betaNull = X0 \ y;
    betaCos = X1 \ y;
    yhat0 = X0 * betaNull;
    yhat1 = X1 * betaCos;
    res0 = y - yhat0;
    res1 = y - yhat1;

    SSE0 = sum(res0 .^ 2);
    SSE1 = sum(res1 .^ 2);
    SST = sum((y - mean(y)) .^ 2);

    p0 = size(X0, 2);
    p1 = size(X1, 2);
    df1 = p1 - p0;
    df2 = n - p1;

    if df2 <= 0 || ~isfinite(SSE0) || ~isfinite(SSE1)
        fitOut.note = 'Invalid model degrees of freedom.';
        return;
    end

    F = ((SSE0 - SSE1) / df1) / (SSE1 / df2);
    if ~isfinite(F) || F < 0
        pZero = 1;
    else
        pZero = 1 - fcdf(F, df1, df2);
    end

    mesor = betaCos(1);
    betaC = betaCos(2);
    betaS = betaCos(3);
    amplitude = hypot(betaC, betaS);
    phi = atan2(betaS, betaC);
    acrophase_h = mod((24 / (2 * pi)) * phi, 24);
    acrophase_deg = mod(rad2deg(phi), 360);

    if SST > 0
        R2Cos = 1 - SSE1 / SST;
    else
        R2Cos = 0;
    end
    AdjR2Cos = 1 - (1 - R2Cos) * ((n - 1) / (n - p1));

    sigma20 = SSE0 / n;
    sigma21 = SSE1 / n;
    if sigma20 <= 0, sigma20 = realmin; end
    if sigma21 <= 0, sigma21 = realmin; end

    fitOut.ok = true;
    fitOut.betaNull = betaNull(:).';
    fitOut.betaCos = betaCos(:).';
    fitOut.mesor = mesor;
    fitOut.amplitude = amplitude;
    fitOut.acrophase_h = acrophase_h;
    fitOut.acrophase_deg = acrophase_deg;
    fitOut.pZeroAmplitude = pZero;
    fitOut.R2Cos = R2Cos;
    fitOut.AdjR2Cos = AdjR2Cos;
    fitOut.AICNull = n * log(sigma20) + 2 * p0;
    fitOut.AICCos = n * log(sigma21) + 2 * p1;
    fitOut.BICNull = n * log(sigma20) + log(n) * p0;
    fitOut.BICCos = n * log(sigma21) + log(n) * p1;
    fitOut.isRhythmic = pZero < 0.05;
end
