clear all % clear all obsolete variables

% constants
extension_filter = '*.mat'; % select extension
dir_in = 'result/'; % where the data is stored
dir_out = 'report/';

dirlist = dir(fullfile(dir_in, '**')); % get list of files and folders in any subfolder
dirlist = dirlist([dirlist.isdir]); % keep only folders and subfolders in list
tf = ismember( {dirlist.name}, {'.', '..'}); % remove "." and ".." entries
dirlist(tf) = []; % remove current and parent directory

currdate = datestr(now,'yyyymmdd-HHMMSS');
[~,~] = mkdir(dir_out); % always create dir, ignore if existing
results = strcat(dir_out,'results-',currdate,'.csv');
data = fopen(results,'w');


% start to store header in file first
fprintf(data,'filename;num_activities;fr;sr;fr_planned;sr_planned;num_modes;num_r_resources;pC;pR;pS;pT;Cc;Cr;Cr1;Cr2;Cs;Ct;CONS;typefcn;Select;Agent;TPCmin;TPCmax;TPRmin;TPRmax;TPR1min;TPR1max;TPR2min;TPR2max;TPSmin;TPSmax;TPTmin;TPTmax;TPCmin_planned;TPCmax_planned;TPRmin_planned;TPRmax_planned;TPR1min_planned;TPR1max_planned;TPR2min_planned;TPR2max_planned;TPSmin_planned;TPSmax_planned;TPTmin_planned;TPTmax_planned;TPC_XPMA;TPR_XPMA;TPR_XPMA_R1;TPR_XPMA_R2;TPS_XPMA;TPT_XPMA;Feasible;');
fprintf(data,'\n');

for d=1:size(dirlist,1) % go through all directories
    
    browse_dir = fullfile(dirlist(d).folder,dirlist(d).name,extension_filter); % look for all files with the extension in current subfolder
    filelist = dir(browse_dir);
    
    for i=1:size(filelist)
        
        % clearvars -except dirlist browse_dir filelist data results i d % it is safer, has same result, but slower
        
        load(fullfile(filelist(i).folder,filelist(i).name));
        % print results into file
        
        % do some aggregation for the agent's results
        if exist('TPC_tpma','var') == 1 % TPMA result variable exists, can be merged
            
            TPC_XPMA = TPC_tpma;
            TPR_XPMA = TPR_tpma;
            TPS_XPMA = TPS_tpma;
            TPT_XPMA = TPT_tpma;
            
            clear TPC_tpma; % clear "flag" before next iteration
            clear TPR_tpma; % clear before next iteration
            clear TPS_tpma; % clear before next iteration
            clear TPT_tpma; % clear before next iteration
            
        else
            if exist('TPC_apma','var') == 1 % APMA result variable exists, can be merged
                
                TPC_XPMA = TPC_apma;
                TPR_XPMA = TPR_apma;
                TPS_XPMA = TPS_apma;
                TPT_XPMA = TPT_apma;
                
                clear TPC_apma; % clear "flag" before next iteration
                clear TPR_apma; % clear before next iteration
                clear TPS_apma; % clear before next iteration
                clear TPT_apma; % clear before next iteration
                
            else
                if exist('TPC_hpma','var') == 1 % HPMA result variable exists, can be merged
                    
                    TPC_XPMA = TPC_hpma;
                    TPR_XPMA = TPR_hpma;
                    TPS_XPMA = TPS_hpma;
                    TPT_XPMA = TPT_hpma;
                    
                    clear TPC_hpma; % clear "flag" before next iteration
                    clear TPR_hpma; % clear before next iteration
                    clear TPS_hpma; % clear before next iteration
                    clear TPT_hpma; % clear before next iteration
                    
                end
            end
        end
        
        
        fprintf(data, '%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s', filelist(i).name, num2str(num_activities), num2str(f_ratio), num2str(s_ratio), num2str(f_ratio_planned), num2str(s_ratio_planned), num2str(num_modes), num2str(num_r_resources), num2str(pC), num2str(pR), num2str(pS), num2str(pT), num2str(Cc), mat2str(Cr), num2str(Cr(1)), num2str(Cr(2)), num2str(Cs), num2str(Ct), mat2str(CONS), num2str(typefcn), num2str(Select), xPMA, num2str(TPCmin), num2str(TPCmax), mat2str(TPRmin'), mat2str(TPRmax'), num2str(TPRmin(1)), num2str(TPRmax(1)), num2str(TPRmin(2)), num2str(TPRmax(2)), num2str(TPSmin), num2str(TPSmax), num2str(TPTmin), num2str(TPTmax), num2str(TPCmin_planned), num2str(TPCmax_planned), mat2str(TPRmin_planned'), mat2str(TPRmax_planned'), num2str(TPRmin_planned(1)), num2str(TPRmax_planned(1)), num2str(TPRmin_planned(2)), num2str(TPRmax_planned(2)), num2str(TPSmin_planned), num2str(TPSmax_planned), num2str(TPTmin_planned), num2str(TPTmax_planned), num2str(TPC_XPMA), mat2str(TPR_XPMA), num2str(TPR_XPMA(1)), num2str(TPR_XPMA(2)), num2str(TPS_XPMA), num2str(TPT_XPMA), num2str(result_feasible));
        
        fprintf(data,'\n'); % end with a newline
    end % loop files
    fprintf('Processing directory: %d of %d\n', d, size(dirlist,1)); % end with a newline
    
end % loop folders

status = fclose(data); % close result file and get the status of the operation
