function [IndustryWeights,UniqueSectorList] = GetMarketCapAcrossIndustries(Data,IndustryClassification)
    
    SectorList = Data(2:end,strcmp(Data(1,:),IndustryClassification));
    UniqueSectorList = unique(SectorList); 
    
    IndustryWeights = nan( size(UniqueSectorList) );
    for jj=1:length( UniqueSectorList )
        
        Sector_Idx = strmatch( UniqueSectorList(jj),SectorList );
        MCap_Column = strcmp( Data(1,:),'Market Cap');
        MCap_Data = cell2mat( Data( 2:end,MCap_Column ) );
        IndustryWeights(jj) = nansum( MCap_Data(Sector_Idx) )./nansum( MCap_Data );
        
    end
    
    if abs(nansum(IndustryWeights) - 1)>0.001
       error('IndustryWeights do not sum up to 1!'); 
    end
    
end