function outDir = selectOutputFolder(prompt)
%SELECTOUTPUTFOLDER Prompt the user to choose an output directory.
    if nargin < 1
        prompt = 'Select output folder';
    end

    outDir = uigetdir(pwd, prompt);
    if isequal(outDir, 0)
        error('selectOutputFolder:Cancelled', 'Output folder selection cancelled.');
    end
    ensureDir(outDir);
end
