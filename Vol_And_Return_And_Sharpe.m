function [Ret,Vol,Sharpe] = Vol_And_Return_And_Sharpe(Price_TS,AnnFac)
    
    Ret = (Price_TS(end)/Price_TS(1))^(AnnFac/(length(Price_TS)-1))-1;
    Price_TS_RetVec = Price_TS(2:end)./Price_TS(1:end-1)-1; %Return Vector 
    Vol = std(Price_TS_RetVec(2:end))*sqrt(AnnFac); %Vol Number
    Sharpe = Ret/Vol;
    
end