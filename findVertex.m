function idx = findVertex(vts, vt)
% % find a vertex's index in a list of vertices
% % input vts: nx3
% % input vt: 3x1 or 1x3
vts = vts';
[~, temp_x] = find(vts(1, :) == vt(1));
if(numel(temp_x) > 1)    % multiple vertex same x coordinate; small number of
temp_y = find(vts(2, temp_x) == vt(2));
if(numel(temp_y) > 1)   % also same y coord; rare
    temp_z = find(vts(3, temp_x(temp_y)) == vt(3));
    assert(numel(temp_z) == 1)  % also same z coord: impossible
    idx = temp_x(temp_y(temp_z));
else
    idx = temp_x(temp_y);
end
else
idx = temp_x;
end
end