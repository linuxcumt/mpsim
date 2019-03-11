function apl = load_apl (filename, convert_to_double)
    if (nargin < 2),  convert_to_double = true;  end
    fid = fopen(filename);
    %D     1  54282     0.0  2007.07.01-00:00:00  ALGOPARK -0.00234 -0.00019  0.00376    
    format = '%*c %*d %d %f %4d.%2d.%2d-%2d:%2d:%2d %s %f %f %f';
    % what's are the first two fields?
    fieldname = {...
        'mjd_trunc', ... % modified julian date, truncated (no decimal days).
        'sod', ... % seconds of day
        'year', ...
        'mon', ...
        'day', ...
        'hour', ...
        'min', ...
        'sec', ...
        'station', ...
        'u', ...
        'e', ...
        'n', ...
    };
    temp = textscan(fid, format, 'CommentStyle','%');
    fclose(fid);
    %size(temp), size(fieldname)  % DEBUG
    apl = cell2struct(temp, fieldname, 2);
    apl.epoch = mydatenum(cast(horzcat(...
        apl.year, apl.mon, apl.day, ...
        apl.hour, apl.min, apl.sec  ...
    ), 'double'));
    apl.pos_local = horzcat(apl.n, apl.e, apl.u);
    if convert_to_double
        temp = apl.station;
        apl = rmfield(apl, 'station');
        apl = structfun2(@(x) cast(x, 'double'), apl);
        apl.station = temp;
    end
end

%!test
%! file_contents = {...
%!     'D     1  54282     0.0  2007.07.01-00:00:00  ALGOPARK -0.00234 -0.00019  0.00376'
%!     'D     2  54282 21600.0  2007.07.01-06:00:00  ALGOPARK -0.00311 -0.00006  0.00379'
%! };
%! apl = struct(...
%!     'mjd_trunc', [54282 54282]', ...
%!     'sod', [0.0 21600.0]', ...
%!     'year', [2007 2007]', ...
%!     'mon', [07 07]', ...
%!     'day', [01 01]', ...
%!     'hour', [00 06]', ...
%!     'min', [00 00]', ...
%!     'sec', [00 00]', ...
%!     'station', {{'ALGOPARK' 'ALGOPARK'}'}, ...  % notice repeated {}
%!     'u', [-0.00234 -0.00311]', ...
%!     'e', [-0.00019 -0.00006]', ...
%!     'n', [0.00376 0.00379]' ...
%! );
%! filename = write_to_temp_file (file_contents);
%! apl2 = load_apl(filename);
%! apl2 = rmfield(apl2, {'epoch', 'pos_local'});
%! apl, apl2  % DEBUG
%! myassert(apl2, apl)
