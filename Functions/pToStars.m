function s = pToStars(p)
%PTOSTARS Convert p-value to star notation for figure brackets.
    if p < 1e-4
        s = '****';
    elseif p < 1e-3
        s = '***';
    elseif p < 1e-2
        s = '**';
    elseif p < 0.05
        s = '*';
    else
        s = 'n.s.';
    end
end
