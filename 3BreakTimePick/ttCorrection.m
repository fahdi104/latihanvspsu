function ttCorrection(inputFile,outputFile)
%need to run cosine correction here
%todo cosine correction
%todo interval velocity calculation
%todo rms velocity calculation

input=load(inputFile);

tt=input(:,1);
depth=input(:,2);
fid = fopen(outputFile, 'w');
vint(1)=depth(1)/tt(1);
fprintf(fid, '%6.4f %6.2f\n', vint(1), depth(1));
for i=2:length(tt)
	vint(i)=(depth(i)-depth(i-1))/(tt(i)-tt(i-1));
	fprintf(fid, '%6.4f %6.2f\n', vint(i), depth(i));
	%tt(i)
end
fclose(fid);
