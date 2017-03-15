%Systematic Equity Strategy!
tic;
javaaddpath('C:\Program Files\BLP\API\blpapi3.jar'); %you'll have to change s
BBConn = blp;
%First Date! This is S&P specific so a bit of a cheat for now!! (Think
%about better solution)
DailyDateVec = datenum('31/01/1993','dd/mm/yyyy'):datenum(date);
DailyDateVec = DailyDateVec';
%monthly frequency at the moment!
DateVecTs = fints( DailyDateVec ,ones(length(DailyDateVec),1));

% DateVecTs = tomonthly( DateVecTs ); %monthly
% DateVecTs = toquarterly( DateVecTs ); %quarterly
DateVecTs = toannual( DateVecTs ); %annually, otherwise this is super slow

Portfolio = nan(length(DailyDateVec)+1,1);
PortfolioDates = nan(length(DailyDateVec)+1,1);
Portfolio(1) = 100;
Count = 0;

%Blanks for analysis
IndustryExposure = struct();
IndustryExposure.IndustrieWeights = cell(size(DateVecTs));
MedianSize = nan(size(DateVecTs));
MedianValue = nan(size(DateVecTs));
NumberofStocks = nan(size(DateVecTs));
MedianEarningsGrowth = nan(size(DateVecTs));

FundamentalSpreadMatrix = nan(length(DailyDateVec)+1,1);
FundamentalsTopMatrix = nan(length(DailyDateVec)+1,1);
FundamentalsBottomMatrix = nan(length(DailyDateVec)+1,1);


for jj=2:length(DateVecTs.dates)

FirstDate = {'PiTDate',num2str( datestr(DateVecTs.dates(jj-1),'yyyymmdd') ) };
NextDate = {'PiTDate',num2str( datestr(DateVecTs.dates(jj),'yyyymmdd') ) };
List1 = eqs(BBConn,'S&PConstituents',[],[],[],'overrideFields',FirstDate); %my name for the EQS list on Bloomberg...

%Can run this on a measure using multiple valuation metrics! Seems to work
%better for the S&P500 universe...
%Standardise the values here first... P/CF
% Normalised_Characteristic1 = cell2mat( List1(2:end,strcmp(List1(1,:),'P/CF')) );
% Normalised_Characteristic1 = ( Normalised_Characteristic1 - nanmean(Normalised_Characteristic1) )./sqrt(nanvar(Normalised_Characteristic1));
% List1 = [ List1,['Norm_P/CF';num2cell(Normalised_Characteristic1)] ];
% 
% %Standardise the values here first... P/E
% Normalised_Characteristic2 = cell2mat( List1(2:end,strcmp(List1(1,:),'P/E')) );
% Normalised_Characteristic2 = ( Normalised_Characteristic2 - nanmean(Normalised_Characteristic2) )./sqrt(nanvar(Normalised_Characteristic2));
% List1 = [ List1,['Norm_P/E';num2cell(Normalised_Characteristic2)] ];
% 
% %Standardise the values here first... P/S
% Normalised_Characteristic3 = cell2mat( List1(2:end,strcmp(List1(1,:),'P/S')) );
% Normalised_Characteristic3 = ( Normalised_Characteristic3 - nanmean(Normalised_Characteristic3) )./sqrt(nanvar(Normalised_Characteristic3));
% List1 = [ List1,['Norm_P/S';num2cell(Normalised_Characteristic3)] ];
% 
% %Standardise the values here first... P/B
% Normalised_Characteristic4 = cell2mat( List1(2:end,strcmp(List1(1,:),'P/B')) );
% Normalised_Characteristic4 = ( Normalised_Characteristic4 - nanmean(Normalised_Characteristic4) )./sqrt(nanvar(Normalised_Characteristic4));
% List1 = [ List1,['Norm_P/S';num2cell(Normalised_Characteristic4)] ];
% 
% %Combined Value measure - Average of the four measures
% Average_Characteristic = ( Normalised_Characteristic1 + Normalised_Characteristic2 + ...
%     Normalised_Characteristic3 + Normalised_Characteristic4 )./4 ;
% List1 = [ List1,['Norm_Value';num2cell(Average_Characteristic)] ];

%Rank according to P/E ratios
% [CriteriaListTop] = GetPercentilefromCriteria(List1,'Norm_Value','ascend',0,25,'top');
% GetPercentilefromCriteria(List,Criteria,Order,LowerPercentile,UpperPercentile,Direction)

[CriteriaListTop] = GetPercentilefromCriteria(List1,'P/E','ascend',0,10,'top');
CriteriaListTop_Ticker = CriteriaListTop(2:end,strcmp(CriteriaListTop(1,:),'Ticker'));
[CriteriaListBottom] = GetPercentilefromCriteria(List1,'P/E','ascend',90,100,'top');
CriteriaListBottom_Ticker = CriteriaListBottom(2:end,strcmp(CriteriaListBottom(1,:),'Ticker'));

% [CriteriaListTop] = GetPercentilefromCriteria(List1,'P/E','ascend',0,10,'top');
% CriteriaListTop_Ticker = CriteriaListTop(2:end,strcmp(CriteriaListTop(1,:),'Ticker'));

%Get Price and P/E Data for those from date1 to the next date2
[DailyDataTop,~] = history(BBConn,strcat( CriteriaListTop_Ticker,' Equity'),{'LAST_PRICE','PE_RATIO'},...
                  datestr(DateVecTs.dates(jj-1),'mm/dd/yyyy'),datestr(DateVecTs.dates(jj),'mm/dd/yyyy'));
[DailyDataBottom,~] = history(BBConn,strcat( CriteriaListBottom_Ticker,' Equity'),{'LAST_PRICE','PE_RATIO'},...
                  datestr(DateVecTs.dates(jj-1),'mm/dd/yyyy'),datestr(DateVecTs.dates(jj),'mm/dd/yyyy'));

%Data Adjustments in top ranked stocks...
MaxTop = length(DailyDataTop{1}(:,1));
IndexTop = 1;
 for kk=2:size(DailyDataTop(:),1)
     if MaxTop < size(DailyDataTop{kk},1)
        IndexTop = kk;
        MaxTop = size(DailyDataTop{kk},1);
     end
 end          
Long_N = length(CriteriaListTop_Ticker);
PriceMatrixTop = nan( MaxTop, Long_N );
FundamentalMatrixTop = nan( MaxTop, Long_N );
for ii=1:Long_N
    if length(DailyDataTop{ii}(:,1)) < MaxTop
        TradedPricesTop = DailyDataTop{ii}(:,2);
        PriceMatrixTop(:,ii) = [TradedPricesTop; ones( MaxTop-length( DailyDataTop{ii}(:,2)),1 ).* TradedPricesTop(end)];
        FundamentalMatrixTop(1:length(DailyDataTop{ii}(:,1)),ii) = DailyDataTop{ii}(:,3);
    else
        PriceMatrixTop(:,ii) = DailyDataTop{ii}(:,2);
        FundamentalMatrixTop(:,ii) = DailyDataTop{ii}(:,3);
    end
end
% ReturnMatrix = PriceMatrixTop(2:end,:)./PriceMatrixTop(1:end-1,:);

%Data Adjustments in bottom ranked stocks...
MaxBottom = length(DailyDataBottom{1}(:,1));
IndexBottom = 1;
 for kk=2:size(DailyDataBottom(:),1)
     if MaxBottom < size(DailyDataBottom{kk},1)
        IndexBottom = kk;
        MaxBottom = size(DailyDataBottom{kk},1);
     end
 end          
Short_N = length(CriteriaListBottom_Ticker);
PriceMatrixBottom = nan( MaxBottom, Short_N );
FundamentalMatrixBottom = nan( MaxBottom, Short_N );
for ii=1:Short_N
    if length(DailyDataBottom{ii}(:,1)) < MaxBottom
        TradedPricesBottom = DailyDataBottom{ii}(:,2);
        PriceMatrixBottom(:,ii) = [TradedPricesBottom; ones( MaxBottom-length( DailyDataBottom{ii}(:,2)),1 ).* TradedPricesBottom(end)];
        FundamentalMatrixBottom(1:length(DailyDataBottom{ii}(:,1)),ii) = DailyDataBottom{ii}(:,3);
    else
        PriceMatrixBottom(:,ii) = DailyDataBottom{ii}(:,2);
        FundamentalMatrixBottom(:,ii) = DailyDataBottom{ii}(:,3);
    end
end

%Portfolio Construction
%Equally weighted for now!!! (long only)
UnitsLong = ( Portfolio(1+Count)/Long_N )./ PriceMatrixTop(1,1:end);
UnitsShort = -( Portfolio(1+Count)/Short_N )./ PriceMatrixBottom(1,1:end);
% Portfolio(1+Count:1+Count+size(PriceMatrixTop,1)-1) = ( Units*(PriceMatrixTop') )';
Portfolio(1+Count:1+Count+size(PriceMatrixTop,1)-1) = ...
    ( UnitsLong*(PriceMatrixTop') )' + ( UnitsShort*(PriceMatrixBottom') )' + Portfolio(1+Count);
PortfolioDates(1+Count:1+Count+size(PriceMatrixTop,1)-1) = DailyDataTop{IndexTop}(:,1);


%Find median value for top and bottom spread
FundamentalSpreadMatrix(1+Count:1+Count+size(PriceMatrixTop,1)-1) = ...
    nanmedian(FundamentalMatrixBottom,2) - nanmedian(FundamentalMatrixTop,2);
FundamentalsTopMatrix(1+Count:1+Count+size(PriceMatrixTop,1)-1) = nanmedian(FundamentalMatrixTop,2);
FundamentalsBottomMatrix(1+Count:1+Count+size(PriceMatrixTop,1)-1) = nanmedian(FundamentalMatrixBottom,2);

Count = Count + size(PriceMatrixTop,1)-1;

%####################### Industry Exposure ################################
%get Industry exposure relative to whole universe
[BmkIndustryWeights,BmkSectorList] = GetMarketCapAcrossIndustries(List1,'ICB Sector Name');
% [~,~,idx]=intersect( Long_Leg_Ticker,List1(:,strcmp(List1(1,:),'Ticker')) );
% Longleg_List = [List1(1,:);List1(idx,:)];
[StratIndustryWeights,StratIndustryList] = GetMarketCapAcrossIndustries(CriteriaListTop,'ICB Sector Name');
    if isequal( StratIndustryList, BmkSectorList)
        ActiveIndustryWeight = StratIndustryWeights - BmkIndustryWeights;
    else
        [~,~,c]=intersect( StratIndustryList,BmkSectorList );
        StratIndustryWeight = StratIndustryWeights - BmkIndustryWeights(c);
        Others = BmkSectorList;
        Others(c) = [];
        ActiveIndustryList = [StratIndustryList;Others];
        ActiveIndustryWeight = [StratIndustryWeight;zeros(size(Others))];
        
    end
IndustryExposure.IndustrieWeights = {ActiveIndustryList,ActiveIndustryWeight};

%SOME CHARACTERISTICS/STATS ON THE STRATEGY
%####### Number of constituenst within the strategy over time #############
NumberofStocks(jj-1) = Long_N;

%####################### Size Exposure ################################
%Also look at median size!
MedianSize(jj-1) = nanmedian( cell2mat( CriteriaListTop(2:end,strcmp(CriteriaListTop(1,:),'Market Cap'))) );

%####################### Value Exposure ################################
%Also look at median value of P/Es!
MedianValue(jj-1) = nanmedian( cell2mat( CriteriaListTop(2:end,strcmp(CriteriaListTop(1,:),'P/E'))) );

%Why value works, can I get IBES 5 year earnings forecasts?
% DSISIN = getdata(BBConn,strcat( CriteriaListTop_Ticker,' Equity'),'ID_ISIN');
% data = fetch(DSConn, DSISIN.ID_ISIN, {'DIEP'},datestr(DateVecTs.dates(jj-1),'dd/mm/yyyy'));
MedianEarningsGrowth(jj-1) = nanmedian( cell2mat( CriteriaListTop(2:end,strcmp(CriteriaListTop(1,:),'BEst LTG EPS:D-1'))) );

end

NumberofStocksTS = fints(DateVecTs.dates,NumberofStocks,'NStocks');
MedianSizeTS = fints(DateVecTs.dates,MedianSize,'Median_Size');
MedianValueTS = fints(DateVecTs.dates,MedianValue,'Median_Value');
MedianEarningsGrowthTS = fints(DateVecTs.dates,MedianEarningsGrowth,'Median_LTE');

%What other statistics do I want??????
Portfolio = Portfolio(~isnan(Portfolio));
PortfolioDates = PortfolioDates(~isnan(PortfolioDates));

%Get 1, 3 5 year rolling annualised returns
RollRet_1Y = fints(PortfolioDates,RollingReturn(Portfolio,1*252,252,'annualised','Prices','Log'),'RollRet_1Y');
RollRet_3Y = fints(PortfolioDates,RollingReturn(Portfolio,2*252,252,'annualised','Prices','Log'),'RollRet_3Y');
RollRet_5Y = fints(PortfolioDates,RollingReturn(Portfolio,5*252,252,'annualised','Prices','Log'),'RollRet_5Y');

%Get 1, 3 5 year rolling annualised volatilities
RollVol_1Y = fints(PortfolioDates,RollingVol(Portfolio,1*252,252,'annualised','Prices','Log'),'RollVol_1Y');
RollVol_3Y = fints(PortfolioDates,RollingVol(Portfolio,3*252,252,'annualised','Prices','Log'),'RollVol_3Y');
RollVol_5Y = fints(PortfolioDates,RollingVol(Portfolio,5*252,252,'annualised','Prices','Log'),'RollVol_5Y');

%Get 1, 3 5 year rolling annualised sharpe ratios (not net of cash)
RollSharpe_1Y = fints(PortfolioDates,fts2mat(RollRet_1Y,0)./fts2mat(RollVol_1Y,0),'RollSharpe_1Y');
RollSharpe_3Y = fints(PortfolioDates,fts2mat(RollRet_3Y,0)./fts2mat(RollVol_3Y,0),'RollSharpe_3Y');
RollSharpe_5Y = fints(PortfolioDates,fts2mat(RollRet_5Y,0)./fts2mat(RollVol_5Y,0),'RollSharpe_5Y');

%Get 1, 3 5 year rolling skewness
RollSkew_Y1 = fints(PortfolioDates,RollingSkewness(Portfolio,1*252,'Prices','Log'),'RollSkew_1Y');
RollSkew_Y3 = fints(PortfolioDates,RollingSkewness(Portfolio,3*252,'Prices','Log'),'RollSkew_3Y');
RollSkew_Y5 = fints(PortfolioDates,RollingSkewness(Portfolio,5*252,'Prices','Log'),'RollSkew_5Y');

%Get 1, 3 5 year rolling kurtosis
RollKurt_Y1 = fints(PortfolioDates,RollingKurtosis(Portfolio,1*252,'Prices','Log'),'RollKurt_1Y');
RollKurt_Y3 = fints(PortfolioDates,RollingKurtosis(Portfolio,3*252,'Prices','Log'),'RollKurt_3Y');
RollKurt_Y5 = fints(PortfolioDates,RollingKurtosis(Portfolio,5*252,'Prices','Log'),'RollKurt_5Y');

%Get 1, 3 5 year rolling equity beta (not net of cash)
%Put it back in a financial time series object
PortfolioTS = fints(PortfolioDates,Portfolio,'ValueStrategy');
FundamentalSpreadMatrix = ...
    fints(PortfolioDates,FundamentalSpreadMatrix(~isnan(FundamentalSpreadMatrix)),'Spread');
FundamentalSpread_Zscore = (FundamentalSpreadMatrix - tsmovavg(FundamentalSpreadMatrix,'s',252) )./...
    RollingVol(Portfolio,252,1,'annualised','Returns','Log');

%Rolling 
toc;









