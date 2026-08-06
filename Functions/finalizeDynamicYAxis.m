function finalizeDynamicYAxis(fig)
%FINALIZEDYNAMICYAXIS Re-snap y-axes after overlays (e.g. significance brackets).

    if nargin < 1 || isempty(fig) || ~isgraphics(fig)
        fig = gcf;
    end

    snapYAxesToTopTick(fig);
end
