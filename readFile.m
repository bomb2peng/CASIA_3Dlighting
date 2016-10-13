function content = readFile(fn)
[fid, message] = fopen(fn, 'r');
if fid < 0, error(['Cannot open the file ' fn '\n' message]); end
i = 1;
tline = fgetl(fid);
content{i} = tline;
while ischar(tline)
    i = i+1;
    tline = fgetl(fid);
    content{i} = tline;
end
fclose(fid);
end