function [CriteriaList] = GetPercentilefromCriteria(List,Criteria,Order,LowerPercentile,UpperPercentile,Direction)
    
%Takes a Bloomberg EQS list and returns the top percentile of the list
%according to one criteria given in the list

    if ~strcmp(Order,'ascend') && ~strcmp(Order,'descend')
       error('ErrorInGetPercentilefromCriteria::OrderTypeMustBeOneOf"descend"Or"ascend"!'); 
    end
    if ~strcmp(Direction,'top') && ~strcmp(Direction,'bottom')
       error('ErrorInGetPercentilefromCriteria::DirectionTypeMustBeOneOf"top"Or"bottom"!'); 
    end
    
    List_Ticker = List(2:end,strcmp(List(1,:),'Ticker'));
    List_Criteria = cell2mat( List(2:end,strcmp(List(1,:),Criteria)) );
    List_Ticker = List_Ticker(~isnan(List_Criteria));
    List_Criteria  = List_Criteria(~isnan(List_Criteria ));
    
    %Order here then and pick top percentile!!!
    [~,sort_idx] = sort(List_Criteria,Order);
    List_Ticker = List_Ticker(sort_idx);
    if strcmp(Direction,'top')
        lowerBound = floor( prctile(1:length(List_Criteria),LowerPercentile) );
        upperBound = ceil( prctile(1:length(List_Criteria),UpperPercentile) );   
    elseif strcmp(Direction,'bottom')
        upperBound = floor( prctile(1:length(List_Criteria),1-LowerPercentile) );
        lowerBound = ceil( prctile(1:length(List_Criteria),1-UpperPercentile) );
    end
    N = upperBound - lowerBound;
    if N<1
       error('ErrorInGetPercentilefromCriteria::PercentilesTooSmall!'); 
    end
    Long_Leg_Ticker = List_Ticker(lowerBound:upperBound);
    
    %Give me the list according to characteristics
    [~,~,idx]=intersect( Long_Leg_Ticker,List(:,strcmp(List(1,:),'Ticker')) );
    CriteriaList = [List(1,:);List(idx,:)];
    
    
end