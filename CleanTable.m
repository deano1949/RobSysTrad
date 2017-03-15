function [ClTble] = CleanTable(Tble)

% This function gets rid of NaN's and unwanted columns/rows of a table 
%(i.e empty ones) if missread from Excel, even though there is no data in
%the cells.

  TF = abs(ismissing(Tble,{'' '.' 'NA' NaN -99})-1);  
  HorIdx = size(TF,2) - find(flipud(sum(TF,1)'),1) + 1;
  VertIdx = size(TF,1) - find(flipud(sum(TF,2)),1) + 1;
  ClTble = Tble(1:VertIdx,1:HorIdx);

end