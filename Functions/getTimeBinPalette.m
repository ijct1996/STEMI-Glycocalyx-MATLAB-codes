function [binNames, binCols] = getTimeBinPalette()
%GETTIMEBINPALETTE Return fixed time-bin labels and publication colours.
    binNames = ["Morning", "Afternoon", "Evening", "Night"];

    tolBright = [
        68 119 170
        238 102 119
        34 136 51
        204 187 68
        102 204 238
        170 51 119
        187 187 187] / 255;

    binCols = tolBright([3 4 6 5], :);
end
