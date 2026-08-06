function items = cellItems(varargin)
%CELLITEMS Build a uniform column cellstr list from mixed inputs.
    items = cell(0, 1);
    for k = 1:numel(varargin)
        part = cellstr(string(varargin{k}));
        part = part(:);
        if ~isempty(part)
            items = [items; part]; %#ok<AGROW>
        end
    end
end
