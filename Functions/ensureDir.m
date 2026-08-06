function ensureDir(p)
%ENSUREDIR Create a directory if it does not exist.
    if ~exist(p, 'dir')
        mkdir(p);
    end
end
