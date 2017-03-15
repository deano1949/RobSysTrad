function [RollSkew] = RollingSkewness(rets,w,input,rettype)
    
    if nargin < 4
       rettype = 'Log';
    elseif nargin < 3
       input = 'Returns';
       rettype = 'Log';
    elseif nargin < 2
       input = 'Returns';
       rettype = 'Log';
       w = 60;
    end
    
    RollSkew = nan(size(rets));
    if isa(rets,'fints')
       data = fts2mat(rets,0);
    else
       data = rets;
    end
    
    if ~strcmp(input,'Returns')
        if strcmp(rettype,'Log')
           data = [nan(1,size(data,2)); log( data(2:end,:)./(data(1:end-1,:))) ]; 
        else
           data = [nan(1,size(data,2));data(2:end,:)./(data(1:end-1,:))-1];
        end        
    end
    
    for i=1:size(data,1)-w+1
        if sum( isnan( data(i:w+i-1,:) ) )>0
          RollSkew(w+i-1,:) = NaN;
        else
          RollSkew(w+i-1,:) = skewness(data(i:w+i-1,:),1);
        end                
    end
    
    if isa(rets,'fints')
        RollSkew = fints(rets.dates,RollSkew);
        %change names to initial series
        nameVol = fieldnames(RollSkew);
        nameTs = fieldnames(rets);
        idx = ~strcmp(nameVol,nameTs);
        if sum(idx)>0
            RollSkew = chfield(RollSkew,nameVol(idx),nameTs(idx));
        end
    end
    
end