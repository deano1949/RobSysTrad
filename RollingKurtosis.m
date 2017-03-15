function [RollKurt] = RollingKurtosis(rets,w,input,rettype)
    
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
    
    RollKurt = nan(size(rets));
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
          RollKurt(w+i-1,:) = NaN;
        else
          RollKurt(w+i-1,:) = kurtosis(data(i:w+i-1,:),1);
        end                
    end
    
    if isa(rets,'fints')
        RollKurt = fints(rets.dates,RollKurt);
        %change names to initial series
        nameVol = fieldnames(RollKurt);
        nameTs = fieldnames(rets);
        idx = ~strcmp(nameVol,nameTs);
        if sum(idx)>0
            RollKurt = chfield(RollKurt,nameVol(idx),nameTs(idx));
        end
    end
    
end