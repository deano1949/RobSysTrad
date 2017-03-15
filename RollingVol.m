function [RollVol] = RollingVol(rets,w,AnnFac,ann,input,rettype)
    
% Calculates the rolling realised volatility of a financial time series of
% prices
    if nargin < 6
       rettype = 'Log';
    elseif nargin < 5
       rettype = 'Log';
       input = 'Returns';
    elseif nargin < 4
       rettype = 'Log';
       input = 'Returns';
       ann = 'annualised';
    elseif nargin < 3
       rettype = 'Log';
       input = 'Returns';
       ann = 'annualised';
       AnnFac = 252;
    elseif nargin < 2
       rettype = 'Log';
       input = 'Returns';
       ann = 'annualised';
       AnnFac = 252;
       w = 60;
    end
    
    RollVol = nan(size(rets));
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
          RollVol(w+i-1,:) = sqrt( sum((data(i:w+i-1,:)-...
            ( repmat(sum(data(i:w+i-1,:),1)/w,size(data(i:w+i-1,:),1),1 ))).^2,1) )...
                            .*sqrt( AnnFac/(w-1) );  
        else
            RollVol(w+i-1,:) = sqrt( sum((data(i:w+i-1,:)-...
            ( repmat(sum(data(i:w+i-1,:),1)/w,size(data(i:w+i-1,:),1),1 ))).^2,1) )...
                            .*sqrt( 1/(w-1) );
        end                
    end
    if isa(rets,'fints')
        RollVol = fints(rets.dates,RollVol);
        %change names to initial series
        nameVol = fieldnames(RollVol);
        nameTs = fieldnames(rets);
        idx = ~strcmp(nameVol,nameTs);
        if sum(idx)>0
            RollVol = chfield(RollVol,nameVol(idx),nameTs(idx));
        end
    end
    
    
end