function [Assignment_elem, problem] = o_subarrayToAntennaElements(Assignment,conf,problem)
    if strcmp(conf.genStructure, 'nchoosek')
        num_subarrays_selected = (numel(Assignment)-1)/2;
    
        Taper_value = Assignment(2:(1+num_subarrays_selected)) .* ...
            exp(1i.*Assignment(((num_subarrays_selected+1)+1):end));
        
        antenna_selection = nchoosek_index(1:problem.N_Subarrays, ...
            num_subarrays_selected, Assignment(1));
    elseif strcmp(conf.genStructure, 'allAntennas')
        antenna_selection = find(Assignment(1:round(end/2)));
        num_subarrays_selected = numel(antenna_selection);
    
        Taper_value = Assignment(antenna_selection) .* ...
            exp(1i.*Assignment(round(end/2)+antenna_selection));
    else
        num_subarrays_selected = (numel(Assignment)-1)/3; 
        % The last position (Assignment(end)) is Fbb, and the rest of array's 
        % size is num_subarrays*3
        Taper_value = Assignment(end) * ...
            Assignment((num_subarrays_selected+1):(num_subarrays_selected*2)) .* ...
            exp(1i.*Assignment((num_subarrays_selected*2+1):(num_subarrays_selected*3)));
        
        antenna_selection = Assignment(1:num_subarrays_selected);
    end
    
    
    
    
    ant_elem = [problem.Partition{antenna_selection}];
    subpos = problem.possible_locations(:,ant_elem);
        % This is OK always in the case where we only have phase shifters 
        % for the elements in the subarray (i.e. in the analog weighting)
        
    [~,index] = max(problem.alphaChannels(problem.IDUserAssigned,:));
    wT_analog = exp(1i*angle(steervec(subpos/problem.lambda,...
    [problem.phiChannels(problem.IDUserAssigned,index);...
    problem.thetaChannels(problem.IDUserAssigned,index)])));
%         wT_analog = steervec(subpos/problem.lambda,...
%         [pi/2-problem.phiUsers(problem.IDUserAssigned);...
%         pi/2-problem.thetaUsers(problem.IDUserAssigned)]);
        % From the system perspective, the effect of the hybrid beamforming can
        % be represented by hybrid weights as shown below.
    Taper = (Taper_value.*wT_analog');
    %Taper = kron(Taper_value,wT_analog)';
%     for n=1:num_subarrays_selected
%         ant = problem.Partition{antenna_selection(n)};
%         subpos = problem.possible_locations(:,ant);
%         % This is OK always in the case where we only have phase shifters 
%         % for the elements in the subarray (i.e. in the analog weighting)
%         
%         wT_analog = exp(1i*angle(steervec(subpos/problem.lambda,...
%         [problem.phiUsers(problem.IDUserAssigned);...
%         problem.thetaUsers(problem.IDUserAssigned)])));
% %         wT_analog = steervec(subpos/problem.lambda,...
% %         [pi/2-problem.phiUsers(problem.IDUserAssigned);...
% %         pi/2-problem.thetaUsers(problem.IDUserAssigned)]);
%         ant_elem = [ant_elem,ant];
%         % From the system perspective, the effect of the hybrid beamforming can
%         % be represented by hybrid weights as shown below.
%         Taper = [Taper,kron(Taper_value(n),wT_analog)'];
%     end
    %ant_elem = sort(ant_elem);
       
    problem.ant_elem = numel(ant_elem); % refresh the actual number of antenna elements
    
    Assignment_elem = [ant_elem,abs(Taper),angle(Taper)];
end

