function [RollRet] = RollingReturn(rets,w,AnnFac,ann,input,rettype)
    
    if nargin < 6
       rettype = 'Log';
    elseif nargin < 5
       input = 'Returns';
       rettype = 'Log';
    elseif nargin < 4
       input = 'Returns';
       ann = 'annualised';
       rettype = 'Log';
    elseif nargin < 3
       input = 'Returns';
       ann = 'annualised';
       rettype = 'Log';
       AnnFac = 252;
    elseif nargin < 2
       input = 'Returns';
       ann = 'annualised';
       rettype = 'Log';
       AnnFac = 252;
       w = 60;
    end
    
    RollRet = nan(size(rets));
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
        if strcmp(ann,'annualised')
          RollRet(w+i-1,:) = prod( 1+data(i:w+i-1,:) )^(AnnFac/w)-1;
        else
          RollRet(w+i-1,:) = prod( 1+data(i:w+i-1,:) )^(1/w)-1;
        end                
    end
    
    if isa(rets,'fints')
        RollRet = fints(rets.dates,RollRet);
        %change names to initial series
        nameVol = fieldnames(RollRet);
        nameTs = fieldnames(rets);
        idx = ~strcmp(nameVol,nameTs);
        if sum(idx)>0
            RollRet = chfield(RollRet,nameVol(idx),nameTs(idx));
        end
    end
    
end