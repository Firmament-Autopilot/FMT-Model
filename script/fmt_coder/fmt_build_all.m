function binPath = fmt_build_all(varargin)
%fmt_build_all - Generate all selected models and compile firmware once
%   binPath = fmt_build_all builds the vehicle selected in the base workspace.
%
%   binPath = fmt_build_all(...,Board=BOARD,Airframe=AIRFRAME)
%   applies target settings in memory and builds the selected models.
%
%   See also fmt_sync_all, fmt_configure_models, slbuild
fmt_sync_all(varargin{:});
binPath = fmt_target.build('Controller');
end
