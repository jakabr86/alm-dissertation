clear all

% load data
load('data/ADM_V3.mat','PDM', 'PDM_planned'); % get PDM + PDM without unplanned tasks for calculating constraints with ratio parameters

% setup
xPMAs = ["TPMA","APMA","HPMA"]; % 1=TPMA, 2=APMA, 3=HPMA
typefcns = [1,2,3,4,9]; % {0=maxTPQ}, 1=minTPT, 2=minTPC, 3=maxTPS, {4=minUF}, ~ =composite

pCs = [1.00,0.75,0.50,0.25]; % keep order(s) to start with the hardest constraint first
pRs = [0.125];
pSs = [0.00,0.25,0.50,0.75];
pTs = [1.00,0.75,0.50,0.25];

count = 1;
order = 1;

for agent = 1:size(xPMAs,2)
    for func = 1:size(typefcns,2)
        for cost = 1:size(pCs,2)
            for res = 1:size(pRs,2)
                for score = 1:size(pSs,2)
                    for time = 1:size(pTs,2)
                        
                        try
                            
                            if ~exist(strcat('result/XPMA/',xPMAs(agent),'_typefcn-',num2str(typefcns(func)),'_pC-',num2str(pCs(cost)),'_pR-',num2str(pRs(res)),'_pS-',num2str(pSs(score)),'_pT-',num2str(pTs(time)),'.mat'), 'file')
                                % uncomment to list what is left
                                
                                fprintf('#%d, agent: %s function: %d cost: %f res: %f score: %f time: %f\n', order, xPMAs(agent), typefcns(func), pCs(cost), pRs(res), pSs(score), pTs(time))
                                order = order + 1;
                            else
                                % uncomment to list all to do
                                                               
                                %fprintf('#%d, agent: %s function: %d cost: %f res: %f score: %f time: %f\n', count, xPMAs(agent), typefcns(func), pCs(cost), pRs(res), pSs(score), pTs(time))
                            end
                            %simalm(PDM, PDM_planned, xPMAs(agent), typefcns(func), pCs(cost), pRs(res), pSs(score), pTs(time)); % run & save the instance
                            
                        catch exception
                            disp(['Error occurred, skipping iteration due: ' exception.message]);
                            errorLog = fopen('errors.txt', 'a');  % 'a' for append mode
                            fprintf(errorLog, 'FAILED ITERATION: #%d, agent: %s function: %d cost: %f res: %f score: %f time: %f\n', count, xPMAs(agent), typefcns(func), pCs(cost), pRs(res), pSs(score), pTs(time));
                            fclose(errorLog);
                        end
                        
                        count = count + 1;
                        
                    end
                end
            end
        end
    end
end




