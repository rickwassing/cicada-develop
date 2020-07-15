function wasoBouts = waso2bouts(waso, nAwake, startDate, endDate)

nAwake = round(nAwake);
wBout = (waso/nAwake) / (24*60);

startBouts = startDate-wBout/2:(endDate-startDate)/(nAwake+1):endDate+wBout/2;
endBouts = startBouts+wBout;

wasoBouts = [startBouts(2:end-1)', endBouts(2:end-1)'];

end
