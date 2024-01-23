%Author: Zsolt T. Koszty�n Ph.D habil., University of Pannonia,
%Faculty of Economics, Department of Quantitative Methods
%----------------
%Feasibility check for crossover function of GA approach for RC-HDTCTPs
%----------------
%Output:
%loout=logical value of the feasibility
%---------------- 
%Inputs:
%DSM=N by N upper trisngle binary matrix of logic domain
%MODES=N by 1 vector of completion modes
%SST=N by 1 vector of scheduled start time
%---------------- 
%Usage:
%loout=isfeasibledq(DSM,MODES,SST)
%---------------- 
%Example:
%This is not executed as a stand-alone fuinction. Instead of specifying
%global values this function is cannot be run.
%---------------- 
%Prepositions and Requirements:
%1.)Global values must be specified.

function loout=isfeasibledr(DSM,MODES,SST)
global P T C R Ct Cc CR Cs

%global values: 
% P is the PopSize by PopSize scores matrix of task/dependency inclusion
% T is the column vector of time demands (=the time domain)
% C is the column vector of cost demands (=the cost domain)
% R is the N by nR matrix of resource demands (=the resource domain)
% Ct is the time constraint
% Cc is the cost constraint
% Cs is the score constraint
% CR is the 1 by nR row vector of resource constraints

w=size(T,2); %Number of modes
loout=false;
DSM=round(DSM); %DSM must be upper triangular binary matrix
MODES=round(MODES); %MODES must be integer vector
TD=zeros(numel(MODES),1); %Calculation of realized time demands
CD=zeros(numel(MODES),1); %Calculation of realized cost demands
RD=zeros(numel(MODES),numel(CR));%Calculation of realized reseource demands

for i=1:numel(MODES)
    if DSM(i,i)==0
    else
        TD(i)=T(i,MODES(i));
        CD(i)=C(i,MODES(i));
        for j=1:numel(CR)
            RD(i,j)=R(i,(j-1)*w+MODES(i));
        end
    end
end
TPS=maxscore_PEM(DSM,P,ones(size(P,1))-P);
TPT=tptsst(DSM,TD,SST);
TPC=tpcfast(DSM,CD);
TPR=maxresfun(SST,DSM,TD,RD)';
if max([TPT-Ct,TPC-Cc,TPR-CR,Cs-TPS])<=0 %The TPT should be lower than Ct
    loout=true; %TPC should be lower than Cc and TPS should be greater than
end                                          %Cs. TPR must be lower than CR