% % This user interrface let the user adjust the landmark output of a
% % landmark detector.
% % First, run the following two lines in the command window. "landmarks"
% % is the output from a lm detector, which is n x 2 x nFace
% % global landmarksA;
% % landmarksA = landmarks;

function landMarkAdjustment()
close all;
global landmarksA;
close all;
dataDir = 'D:\dataset\tifs-database\DSO-1';
imNames = dir(dataDir);
imNames = imNames(3:end);
for i = 19*10+(1:10)
    img = imread(fullfile(dataDir, imNames(i).name));
    data.hFigure = figure('Name', imNames(i).name);
    imshow(img);
    hold on;
    lm = landmarksA{i};
    data.idx = i;
    for j = 1:size(lm, 3)
        text(mean(lm(:,1,j)), mean(lm(:,2,j)), num2str(j));
    end
    lmTile = [];
    for ii = 1:size(lm, 3)
        lmTile = [lmTile; lm(:,:,ii)];
    end
    data.lmTile = lmTile;
    data.hLM = plot(lmTile(:,1), lmTile(:,2), 'g-*');
    set(gcf, 'WindowButtonDownFcn',@mystartDragFcn);
    set(gcf, 'WindowKeyPressFcn', @mypresskeycallback);
    set(gcf, 'WindowButtonUpFcn',@mystopDragFcn);
    set(gcf, 'UserData', data);
end
end

function mystartDragFcn(varargin)
    data = get(gcbf, 'UserData');
    set(gcbf, 'WindowButtonMotionFcn', @mydraggingFcn );
    pt = get(get(gcbf, 'CurrentAxes'), 'CurrentPoint');
    pt = pt(1, 1:2);
% %     find which lm point is the closest
    lmTile = data.lmTile;
    faces = delaunay(lmTile(:,1), lmTile(:,2));
    [data.idxCP, ~] = dsearchn(lmTile, faces, pt);   % closest point search for the clicking point
    set(gcbf, 'UserData', data);
end

function mydraggingFcn(varargin)
    data = get(gcbf, 'UserData');
    pt = get(get(gcbf, 'CurrentAxes'), 'CurrentPoint');
    pt = pt(1, 1:2);
    XData = get(data.hLM, 'XData');
    XData(data.idxCP) = pt(1);
    set(data.hLM, 'XData', XData);
    YData = get(data.hLM, 'YData');
    YData(data.idxCP) = pt(2);
    set(data.hLM, 'YData', YData);
    drawnow ;
    data.lmTile(data.idxCP, :) = pt;
    set(gcbf, 'UserData', data);
end

function mystopDragFcn(obj,evd)
    set(obj, 'WindowButtonMotionFcn', '');  % here obj is the same as gcbf
end

function mypresskeycallback(obj, evd)
    if (strcmp(evd.Key, 'return'))       % press 'return'/'enter' to output the adjusted lm to "landmarksA"
        global landmarksA;
        data = get(gcbf, 'UserData');
        lm = [];
        lmTile = data.lmTile;
        nFace = size(lmTile, 1)/68;     % Here 68 is the number of landmark pts for each face
        for ii = 1:nFace
            lm(:,:,ii) = lmTile(68*(ii-1)+(1:68), :);
        end
        landmarksA{data.idx} = lm;
        msgbox(sprintf('The %d th image updated.', data.idx));
    end
end