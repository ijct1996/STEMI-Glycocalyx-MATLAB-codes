function hourOut = parseTimeToHours(t)
%PARSETIMETOHOURS Convert mixed clock-time formats to decimal hours [0, 24).

    if istable(t)
        t = t{:, :};
    end

    n = numel(t);
    hourOut = nan(n, 1);

    if isduration(t)
        hourOut = mod(hours(t(:)), 24);
        return;
    end
    if isdatetime(t)
        hourOut = hour(t) + minute(t) / 60 + second(t) / 3600;
        hourOut = mod(hourOut(:), 24);
        return;
    end
    if isnumeric(t)
        x = double(t(:));

        fracMask = x >= 0 & x <= 1;
        if any(fracMask)
            hourOut(fracMask) = x(fracMask) * 24;
        end

        hourMask = x > 1 & x < 24;
        if any(hourMask)
            hourOut(hourMask) = x(hourMask);
        end

        otherMask = isnan(hourOut) & ~isnan(x);
        if any(otherMask)
            xx = x(otherMask);
            hh = floor(xx / 100);
            mm = round(xx - 100 * hh);
            ok = (hh >= 0 & hh <= 23) & (mm >= 0 & mm <= 59);
            tmp = nan(size(xx));
            tmp(ok) = hh(ok) + mm(ok) / 60;
            hourOut(otherMask) = tmp;
        end
        return;
    end

    s = string(t(:));
    s = strtrim(s);
    s(s == "") = missing;

    try
        d = duration(s, 'InputFormat', 'hh:mm');
        hourOut = mod(hours(d), 24);
        hourOut = hourOut(:);
        return;
    catch
    end
    try
        d = duration(s, 'InputFormat', 'hh:mm:ss');
        hourOut = mod(hours(d), 24);
        hourOut = hourOut(:);
        return;
    catch
    end

    for i = 1:n
        if ismissing(s(i))
            continue;
        end
        tok = regexp(s(i), '^\s*(\d{1,2})\s*:\s*(\d{1,2})(?::(\d{1,2}))?\s*$', 'tokens', 'once');
        if isempty(tok)
            continue;
        end
        hh = str2double(tok{1});
        mm = str2double(tok{2});
        ss = 0;
        if numel(tok) >= 3 && ~isempty(tok{3})
            ss = str2double(tok{3});
        end
        if any(isnan([hh, mm, ss])) || hh < 0 || hh > 23 || mm < 0 || mm > 59 || ss < 0 || ss > 59
            continue;
        end
        hourOut(i) = hh + mm / 60 + ss / 3600;
    end
end
