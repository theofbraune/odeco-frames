% function mexbuild(pathToTbbInclude, pathToMosek)
% 
% if ismac
    % platform = 'osxaarch64';
% elseif isunix
    % platform = 'linux64x86';
% end
% 
% mosekIncludeDir = fullfile(pathToMosek, 'tools/platform', platform, 'h');
% mosekLibDir = fullfile(pathToMosek, 'tools/platform', platform, 'bin');
% 
% ldflags = '';
% if ~ismac && isunix
    % ldflags = ['LDFLAGS=$LDFLAGS -Wl,-rpath=' mosekLibDir];
% end
% 
% mex('MultiSdp.cpp', ...
    % '-cxx', '-O', '-g', ['-I' pathToTbbInclude], ...
    % ['-I' mosekIncludeDir], ['-L' mosekLibDir], ...
    % '-lmosek64', '-lfusion64', '-ltbb', ldflags);
% 
% if ismac
    % system(['install_name_tool -change libmosek64.11.0.dylib ' fullfile(mosekLibDir, 'libmosek64.11.0.dylib') ' MultiSdp.mexmaca64']);
    % system(['install_name_tool -change libfusion64.11.0.dylib ' fullfile(mosekLibDir, 'libfusion64.11.0.dylib') ' MultiSdp.mexmaca64']);
% end
% 
% end
function mexbuild(pathToTbbInclude, pathToMosek)

    if ismac, platform = 'osxaarch64';
    else, error('Unsupported OS'); end

    mosekBase   = fullfile(pathToMosek,'tools','platform',platform);
    mosekIncDir = fullfile(mosekBase,'h');
    mosekLibDir = fullfile(mosekBase,'bin');

    [~,brewPrefix] = system('brew --prefix'); brewPrefix = strtrim(brewPrefix);
    if isempty(brewPrefix)
        if isfolder('/opt/homebrew'), brewPrefix='/opt/homebrew'; else, brewPrefix='/usr/local'; end
    end
    tbbIncDir = pathToTbbInclude;
    tbbLibDir = fullfile(brewPrefix,'lib');

    % Header padding + rpaths so we never need install_name_tool later
    ldflags = sprintf(['LDFLAGS=$LDFLAGS ' ...
                       '-Wl,-headerpad_max_install_names ' ...
                       '-Wl,-rpath,%s -Wl,-rpath,%s'], ...
                       mosekLibDir, tbbLibDir);

    mex('-v','MultiSdp.cpp', ...
        '-cxx','-O','-g', ...
        ['-I' tbbIncDir], ['-I' mosekIncDir], ...
        ['-L' mosekLibDir], ['-L' tbbLibDir], ...
        '-lmosek64','-lfusion64','-ltbb', ldflags);

    fprintf('Built: MultiSdp.%s\n', mexext);
end
