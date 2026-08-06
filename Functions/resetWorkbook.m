function resetWorkbook(wb)
%RESETWORKBOOK Delete an existing workbook so a fresh export can be written.
    if exist(wb, 'file')
        delete(wb);
    end
end
