function simalm(PDM,PDM_planned,xPMA,typefcn,pC,pR,pS,pT)

% input parameters for the simulation
Select=9; %RC-(H)DTCTP

% folder to save results
dir_out = 'result/XPMA/'; % where the data is stored
[~,~] = mkdir(dir_out); % always create dir, ignore if existing
filename = strcat(dir_out,xPMA,'_typefcn-',num2str(typefcn),'_pC-',num2str(pC),'_pR-',num2str(pR),'_pS-',num2str(pS),'_pT-',num2str(pT),'.mat'); % prepare filename string according to naming convention

% check for an existing result to avoid redundant runs, or continue where left off (except if already running!)
if ~exist(filename, 'file')

% create an empty placeholder / dummy file before actual simulation to notify other workers that work is in progress for this combination (do not overlap / work on same task)
fid = fopen(filename, 'wb');
fclose(fid); % close placeholder file's write stream

% constants for the simulation
N = size(PDM,1); % number of activities
num_activities = N; % copy/rename
DSM = PDM(:,1:N); % nxn
TD = PDM(:,N+2); % td for the 2nd mode
num_r_resources = 2; % programmer, tester
nR = num_r_resources; % copy/rename
num_modes = 3; % number of completion/execution modes
w = num_modes; % copy/rename

% calculate constraints from ratio and for the planned tasks/dependencies only
Cc=percentc(PDM_planned,w,pC); % calculated, actual constraint according to parameter
Cr=percentr(PDM_planned,w,pR)'; % calculated, actual constraint according to parameter
Cs=percents(PDM_planned,pS); % calculated, actual constraint according to parameter
Ct=percentt(PDM_planned,w,pT); % calculated, actual constraint according to parameter

CONS=[Ct,Cc,Cr,Cs]; % [Ct,Cc,Cr,Cs] array of calculated constraints

TPCmin=percentc(PDM,w,0);
TPCmax=percentc(PDM,w,1);
TPRmin=percentr(PDM,w,0);
TPRmax=percentr(PDM,w,1);
TPSmin=percents(PDM,0);
TPSmax=percents(PDM,1);
TPTmin=percentt(PDM,w,0);
TPTmax=percentt(PDM,w,1);

% calculate results for planned PDM also (not considering unplanned tasks)
TPCmin_planned=percentc(PDM_planned,w,0);
TPCmax_planned=percentc(PDM_planned,w,1);
TPRmin_planned=percentr(PDM_planned,w,0);
TPRmax_planned=percentr(PDM_planned,w,1);
TPSmin_planned=percents(PDM_planned,0);
TPSmax_planned=percents(PDM_planned,1);
TPTmin_planned=percentt(PDM_planned,w,0);
TPTmax_planned=percentt(PDM_planned,w,1);

f_ratio=fratio(PDM); % calculate actual flexibility of dependencies
s_ratio=sratio(PDM); % calculate actual flexibility of tasks

f_ratio_planned=fratio(PDM_planned); % calculate actual flexibility of dependencies for planned activities only
s_ratio_planned=sratio(PDM_planned); % calculate actual flexibility of tasks for planned activities only

result_feasible = 1; % assume feasibility

% run & time each simulation
tic
disp([datestr(now, 'yyyy-mm-dd HH:MM:SS') ' simulation started' ]); % print the actual timestamp to track simulation

switch xPMA
    case "TPMA"
        disp('TPMA is running...')
        PSM_tpma=mtpma(PDM,CONS,Select,typefcn,w);

        TPC_tpma=tpcfast(PSM_tpma(:,1:N),PSM_tpma(:,N+2));
        TPR_tpma=maxresfun(PSM_tpma(:,end),PSM_tpma(:,1:N),PSM_tpma(:,N+1),PSM_tpma(:,end-nR:end-1))';
        TPS_tpma=maxscore_PEM(PSM_tpma(:,1:N),PDM(:,1:N),1-PDM(:,1:N));
        TPT_tpma=tptsst(PSM_tpma(:,1:N),PSM_tpma(:,N+1),PSM_tpma(:,end)); % for the selected mode according to PSM solution
        
        % if TPMA was feasible?
        if feasibilitycheck(PSM_tpma,PDM,CONS)==false
            result_feasible = 0;
        end
        
    case "APMA"
        disp('APMA is running...')
        PSM_apma=mapma(PDM,CONS,Select,typefcn,w);
        
        TPC_apma=tpcfast(PSM_apma(:,1:N),PSM_apma(:,N+2));
        TPR_apma=maxresfun(PSM_apma(:,end),PSM_apma(:,1:N),PSM_apma(:,N+1),PSM_apma(:,end-nR:end-1))';
        TPS_apma=maxscore_PEM(PSM_apma(:,1:N),PDM(:,1:N),1-PDM(:,1:N));
        TPT_apma=tptsst(PSM_apma(:,1:N),PSM_apma(:,N+1),PSM_apma(:,end));

        % if APMA was feasible?
        if feasibilitycheck(PSM_apma,PDM,CONS)==false
            result_feasible = 0;
        end
        
    case "HPMA"
        disp('HPMA is running...')
        PSM_hpma=mhpma(PDM,CONS,Select,typefcn,w);
        
        TPC_hpma=tpcfast(PSM_hpma(:,1:N),PSM_hpma(:,N+2));
        TPR_hpma=maxresfun(PSM_hpma(:,end),PSM_hpma(:,1:N),PSM_hpma(:,N+1),PSM_hpma(:,end-nR:end-1))';
        TPS_hpma=maxscore_PEM(PSM_hpma(:,1:N),PDM(:,1:N),1-PDM(:,1:N));
        TPT_hpma=tptsst(PSM_hpma(:,1:N),PSM_hpma(:,N+1),PSM_hpma(:,end));
        
        % if HPMA was feasible?
        if feasibilitycheck(PSM_hpma,PDM,CONS)==false
            result_feasible = 0;
        end
        
%         % if HPMA was feasible? try to fall back to apma, if also not, to tpma, if not, then infeasible
%         if feasibilitycheck(PSM_hpma,PDM,CONS)==false
%             if feasibilitycheck(PSM_apma,PDM,CONS)==true
%                 PSM_hpma=PSM_apma;
%             else
%                 if feasibilitycheck(PSM_tpma,PDM,CONS)==true
%                     PSM_hpma=PSM_tpma;
%                 else
%                     result_feasible = 0;
%                 end
%             end
%         end
        
    otherwise
        disp('Error: wrong agent selected!')
        
end

% save all variable in the workspace for post-processing and reporting results
save(filename); % overwrite dummy with actual values
toc
disp([datestr(now, 'yyyy-mm-dd HH:MM:SS') ' simulation finished.'])

else
        disp('Result already exists, skipping iteration...')
end







