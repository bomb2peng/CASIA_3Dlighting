function [tri_small, vertex3d_small, small_idx] = meshDown(tri, vertex3d, r)
% % down sample a mesh.
[tri_small, vertex3d_small] = reducepatch(tri', vertex3d', r);
tri_small = tri_small';
vertex3d_small = vertex3d_small';
% % find small mesh's indices in original big mesh
small_idx = zeros(size(vertex3d_small, 2), 1);
for i = 1:size(vertex3d_small, 2)
    small_idx(i) = findVertex(vertex3d, vertex3d_small(:, i));
end
assert(numel(small_idx) == size(vertex3d_small, 2));    % in case a vertex can not find original index.
end