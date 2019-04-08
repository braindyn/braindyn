function output = IJKtransformXYZ(transform_vox2coord, param, value)

switch param
    case 'voxel'
        vox = [value ones(size(value, 1), 1)]';
        pnt =  transform_vox2coord * vox;
    case 'coordsys'
        pnt = [value  ones(size(value, 1), 1)]';
        vox = round(inv(transform_vox2coord) * pnt);
end
output.vox = vox(1 : end - 1, :)';
output.pnt = pnt(1 : end - 1, :)';
output.transform = transform_vox2coord;

% vox = ft_warp_apply(inv(transform_vox2coord), pnt);
% pnt(1, :) ---> vox(1, :);
% pnt(2, :) ---> vox(2, :);
