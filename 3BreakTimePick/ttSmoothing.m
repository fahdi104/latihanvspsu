function ttSmoothing(inputFile)
%need to run cosine correction here
%todo cosine correction
%todo interval velocity calculation
%todo rms velocity calculation

input=load(inputFile);
fileName=split(inputFile,'.');
outputFile=strcat(fileName(1,:),'_smooth');
tt=input(:,1);
depth=input(:,2);
%ttsmooth=filter(ones(1,5)/10, 1, tt);
ttsmooth=spline(depth(1:1:length(depth)),tt(1:1:length(depth)),depth);
%y = filter(ones(1,10)/10, 1, x); 
out=[ttsmooth;depth];
%plot(tt,depth);hold on
%plot(ttsmooth,depth,'r');
fid = fopen(outputFile, 'w');
for i=1:length(ttsmooth)
	fprintf(fid, "%6.4f \t %6.4f\n", ttsmooth(i),depth(i));
end
fclose(fid);
