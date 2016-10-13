function write_obj(vertex3d, tri, fn)
% % This funciton writes the 3d model to a .obj file. No texture.
% % vertex3d, tir: 3xn
% % fn: string, obj file name
addpath('D:\allProjects\toolBox\WOBJ_toolbox_Version2b');
norm = NormDirection(vertex3d, tri);    % calc normal directions at vertices.
obj.vertices = vertex3d';
obj.vertices_normal = norm';
% Make a material structure
material(1).type='newmtl';
material(1).data='skin';
material(2).type='Ka';
material(2).data=[0 0 0];
material(3).type='Kd';
material(3).data=[1 1 1];
material(4).type='Ks';
material(4).data=[0 0 0];
material(5).type='illum';
material(5).data=2;
material(6).type='Ns';
material(6).data=27;

% Make OBJ structure
obj.material = material;
obj.objects(1).type='g';
obj.objects(1).data='skin';
obj.objects(2).type='usemtl';
obj.objects(2).data='skin';
obj.objects(3).type='f';
temp = tri';
temp = temp(:, [3,2,1]);    % Matlab and .obj has different triangle vertex order.
obj.objects(3).data.vertices=temp;
obj.objects(3).data.normal=temp;
write_wobj(obj, fn);
end