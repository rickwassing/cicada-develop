function cmap = mount_colormap(type)

load('colormap_batlow.mat')

switch type
    case 'linear'
        cmap = batlow;
    case 'log2'
        cmap = batlow;
    case 'log10'
        cmap = batlow;
end

end