function clr = mount_colororder(varargin)

if nargin < 1
    idx = 1:9;
else
    idx = varargin{:};
end

clr = [ ...
     45,  95, 172; ... % indigo
    179,  39,  37; ... % red
     38, 180,  93; ... % green 2
    205,  62, 147; ... % fuchsia
    230, 158,  43; ... % orange
     91,  81, 162; ... % blue
     78, 195, 198; ... % turquoise
    138,  64, 152; ... % purple
    150, 180,  60; ... % yellow-green
] ./ 255;

clr = clr(idx, :);

end