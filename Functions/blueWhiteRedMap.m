function cmap = blueWhiteRedMap(n)
%BLUEWHITEREDMAP Diverging blue-white-red colormap for correlation heatmaps.
    if nargin < 1 || isempty(n)
        n = 256;
    end

    anchors = [
        0.00, 0.10, 0.55
        0.50, 1.00, 1.00
        1.00, 0.95, 0.95
        1.00, 0.55, 0.45
        0.65, 0.05, 0.10];
    x = linspace(-1, 1, size(anchors, 1));
    xi = linspace(-1, 1, n);
    cmap = [interp1(x, anchors(:, 1), xi, 'linear', 'extrap')', ...
            interp1(x, anchors(:, 2), xi, 'linear', 'extrap')', ...
            interp1(x, anchors(:, 3), xi, 'linear', 'extrap')'];
    cmap = max(min(cmap, 1), 0);
end
