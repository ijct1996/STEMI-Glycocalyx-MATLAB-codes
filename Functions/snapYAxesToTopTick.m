function snapYAxesToTopTick(fig)
%SNAPYAXESTOTOPTick Force y-axes to end exactly on a labelled tick.

    if nargin < 1 || isempty(fig) || ~isgraphics(fig)
        fig = gcf;
    end

    axs = findall(fig, 'Type', 'axes');

    for aa = 1:numel(axs)
        ax = axs(aa);

        if ~isvalid(ax)
            continue
        end

        try
            if contains(lower(string(ax.Tag)), "colorbar")
                continue
            end
        catch
        end

        try
            if ~strcmpi(ax.YScale, 'linear')
                continue
            end
        catch
        end

        try
            yl = ylim(ax);
        catch
            continue
        end

        snapYAxisToNiceTicks(ax, yl(1), yl(2));
    end
end
