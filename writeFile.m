function writeFile(fn, content)
[fid, message] = fopen(fn, 'w');
if fid < 0, error(['Cannot open the file ' fn '\n' message]); end
for i = 1:numel(content)
    if content{i+1} == -1
        fprintf(fid,'%s', content{i});
        break
    else
        fprintf(fid,'%s\n', content{i});
    end
end
fclose(fid);
end