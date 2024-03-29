%Author: Zsolt T. Koszty�n Ph.D habil., University of Pannonia,
%Faculty of Economics, Department of Quantitative Methods
%----------------
%GA target function (fitness function) for resource-constrained
%Hybrid Discrete Time-Cost Trade-off Problems (rc-HDTCTP)
%----------------
%Standard output:
%target: is a real value, which has to be minimized
%---------------- 
%Standard inputs:
%chromosome: is a set of genomes
%---------------- 
%Usage:
%target=targetfcndr(chromosome)
%---------------- 
%Example:
%This is is not executed as a stand-alone fuinction. Instead of specifying
%global values this function is cannot be run.
%---------------- 
%Prepositions and Requirements:
%1.)Global variables must be specified.

function target=targetfcndr(chromosome)
global P Q T C R Ct Cc CR Cs Typ
%global variables: 
% P is the score matrix of inclusion task dependencies/completions 
%the logic domain (initially PEM=P)
% Q is the score matrix of exclusion task dependencies/completions. 
%In this simulation Q=1-P
% T is the column vector of time demands (=the time domain)
% C is the column vector of cost demands (=the cost domain)
% R is the N by nR matrix of resource demands (=the resource domain)
% Ct is the time constraint
% Cc is the cost constraint
% CR is the row vector of resource constraint
% Cs is the score constraint
% Typ is the selection number of the target functions (see above)

%-----------Calculation of maximal, minimal values--------------%
%-----------for determining the effectiveness of GA-------------%

PopSize=numel(chromosome(:,1)); %Number of chromosomes
nA=numel(P(P>0&P<1)); %Number of uncertain activities/dependencies
N=size(P,1); %Number of activities
w=size(T,2); %Number of modes
nR=size(R,2)/w; %number of resources
chromosome(:,1:nA+N)=round(chromosome(:,1:nA+N));
for i=1:PopSize
    s(i).f1 = chromosome(i,:);
end
dsm=floor(P);
Dsm=ceil(triu(P,1))+diag(floor(diag(P)));
dsmdiag=diag(dsm);
Dsm(diag(Dsm)==0,:)=0;
Dsm(:,diag(Dsm)==0)=0;
if size(T,2)>1
    t=min(T')';
else
    t=T;
end
if size(C,2)>1
    c=min(C')';
else
    c=C;
end
r=zeros(N,nR);
if size(R,2)>nR
    for i=0:nR-1
        r(:,i+1)=min(R(:,i*w+1:i*w+2)')';
    end
else
    r=R;
end
t(dsmdiag==0)=0;
c(dsmdiag==0)=0;
r(diag(Dsm)==0,:)=0;
W=3+nR;
dT=1;
dC=1;
dS=1;
dR=ones(1,nR);
TPTmin=tptfast(dsm,t);
TPCmin=tpcfast(dsm,c);
TPRmin=max(r);
TPSmax=maxscore_PEM(round(P),P,Q);
if (Ct-TPTmin)>0
    dT=Ct-TPTmin;
end
if (Cc-TPCmin)>0
    dC=Cc-TPCmin;
end
dR=CR-TPRmin;
dR(dR==0)=1;
if (TPSmax-Cs)>0
    dS=TPSmax-Cs;
end
%----End of calculating minimal, maximal values----

tpts=zeros(PopSize,1); %PopSize by 1 vector of TPTs
tpcs=zeros(PopSize,1); %PopSize by 1 vector of TPCs
UF=zeros(PopSize,1);   %PopSize by 1 vector of utilized floats
maxR=zeros(PopSize,nR); %PopSize by nR matrix of maximal resource demands
maxRangeR=zeros(1,PopSize); %1 by PopSize vector of max-min resource dem.s.
c=zeros(1,PopSize); %Penalty part of target function
d=zeros(PopSize,1); %Rewarding part of target function

A=arrayfun(@(x) updatepemdr(x.f1), s,'UniformOutput',false); %set of PSMs
for i=1:PopSize
    PSM=A{i};
    DSM=PSM(:,1:size(PSM,1));
    MODES=PSM(:,end-1);
    SST=PSM(:,end);
    TD=zeros(N,1);
    CD=zeros(N,1);
    RD=zeros(N,nR);
    for I=1:N
        if MODES(I)==0
            TD(I)=0;
            CD(I)=0;
            for J=1:nR
                RD(I,J)=0;
            end
        else
            TD(I)=T(I,MODES(I));
            CD(I)=C(I,MODES(I));
            for J=1:nR
                RD(I,J)=R(I,(J-1)*w+MODES(I));
            end
        end
    end
    [~,EST,~,~]=tptfast(DSM,TD);
    maxRangeR(i)=max(stdresfun(SST,DSM,TD,RD));
    tpts(i)=tptsst(DSM,TD,SST);
    UF(i)=sum(abs(SST-EST));
    tpcs(i)=diag(DSM)'*CD;
    maxR(i,:)=maxresfun(SST,DSM,TD,RD)';
    c(i)=max([tpts(i)-Ct,tpcs(i)-Cc,Cs-maxscore_PEM(DSM,P,Q),...
        maxR(i,:)-CR]);
    if c(i)>0 %Penalty case: if constraints are NOT satisfied
        % XXX QUICK AND DIRTY FIX! XXX
        if c(i) > 695 % causes Inf for reallog(realmax)--> 709, so exp(710) gives Inf, exp(709) not, but we also multiply => 695 is the last safe value
            c(i) = 695; % limit to maximum value without Inf as result
        end
        
        c(i)=1e6*(exp(c(i))-1);
        d(i)=c(i);
    else %Rewarding case: if constraints are satisfied
        d(i)=(((Ct-tpts(i))/dT)^(1/W)*((Cc-tpcs(i))/dC)^(1/W)*...
            ((maxscore_PEM(A{i},P,Q)-Cs)/dS)^(1/W));
        for J=1:nR
            d(i)=d(i)*((CR(J)-maxR(i,J))/dR(J))^(1/W);
        end
        d(i)=1-d(i);
        if Typ<3
            c(i)=0; %Penalty part is deleted in the rewarding cases
        end
    end
end
typ=Typ;
switch typ
    case 1 %minimize TPT
        target=tpts+c';
    case 2 %minimize TPC
        target=tpcs+c';
    case 3 %maximize TPS
        target=-(maxscore_PEM_cell(A,P,Q)'*100+maxscore_SNPM_cell(A,P,Q)');
    case 4 %minimize the sum of utlitized floats
        target=UF+c';
    otherwise %maximize efectiveness
        target=d;
end