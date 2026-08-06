function paths = setup_paths()
%SETUP_PATHS Add this publication package folder to the MATLAB path.
%
%   Self-contained: only the local Functions/ folder is required.
%   No external Shared library is needed to run these scripts.

    thisFile = mfilename('fullpath');
    projectRoot = fileparts(thisFile);
    paths.projectRoot = projectRoot;
    paths.functions = fullfile(projectRoot, 'Functions');
    paths.config = fullfile(projectRoot, 'config');

    addpath(paths.functions);
    rehash path;

    fprintf('Publication package paths configured: %s\n', projectRoot);
end
