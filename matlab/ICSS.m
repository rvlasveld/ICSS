function [ change_points ] = ICSS( data )

    range_stack = CStack();
    range_stack.push([1, length(data)]);
    
%     change_points_stack = CStack();
    change_points = [];

    while ~range_stack.isempty()
        current_range = range_stack.pop()
        [change_points_sub, range] = ICSS_non_recursive(data(current_range(1):current_range(2)));
        range;
        change_points_sub;
        if length(range) == 2
            range_stack.push(range+current_range(1));
        end
        
%         for i = 1 : length(change_points_sub)
%             change_points_stack.push(change_points_sub(i)+current_range(1));
%         end
        potential_change_points = change_points_sub + current_range(1);
        potential_change_points = unique([0, sort(potential_change_points), length(data)]);
   
        % Step 3: check each potential change point
        converged = false;
        while ~converged
            % Store the new retrieved change points of this loop
            new_cps = [];

            % check every potential change point by inspecting from and to 
            % the surrounding change points
            for i=2:(length(potential_change_points)-1)
                from    = potential_change_points(i-1)+1;
                to      = potential_change_points(i+1);

                % Calculate the Dk and M again for this section of the data
                Dk                  = CenteredCusumValues(data(from:to));
                [exceeds, position] = check_critical_value(Dk);

                if exceeds
                    % Keep this (new) change point
                    new_cps(end+1) = from + position;
                end
            end

            new_cps = [0, sort(new_cps), length(data)];
            converged = is_converged(potential_change_points, new_cps);

            if ~converged
                potential_change_points = new_cps;
            end
            
            new_cps
        end
        

    end
    
%     change_points = potential_change_points(2:end-1);
    
end

function [ change_points, range ] = ICSS_non_recursive( data )
%#codegen
% ICSS Run the 'Iterative Cumulative Sums of Squares' algorithm
%   Based on 'Use of Cumulative Sums of Squares for Retrospective Detection
%   of Changes of Variance', by Inclan and Tiao, 1994
%   input: raw data
%   output: vector of change-points

    % Perform first two steps of the algorithm (which is recursive)
    [potential_change_points, range] = ICSS_step_1_and_2(data);
    potential_change_points = unique([0, sort(potential_change_points), length(data)]);
   
    % Step 3: check each potential change point
    converged = false;
    while ~converged
        % Store the new retrieved change points of this loop
        new_cps = [];
        
        % check every potential change point by inspecting from and to 
        % the surrounding change points
        for i=2:(length(potential_change_points)-1)
            from    = potential_change_points(i-1)+1;
            to      = potential_change_points(i+1);
            
            % Calculate the Dk and M again for this section of the data
            Dk                  = CenteredCusumValues(data(from:to));
            [exceeds, position] = check_critical_value(Dk);
            
            if exceeds
                % Keep this (new) change point
                new_cps(end+1) = from + position;
            end
        end

        new_cps = [0, sort(new_cps), length(data)];
        converged = is_converged(potential_change_points, new_cps);

        if ~converged
            potential_change_points = new_cps;
        end
    end

    % Remove additional 0 and end change point
    change_points = potential_change_points(2:end-1);
end


function converged = is_converged(old, new, difference)
% IS_CONVERGED Check if two sets of changepoints are converged
%   The two sets are converged if they are of the same length and,
%   if each element in the two sets are no more than
%   -difference- (default: 2) fom the other apart

    if nargin < 3
        difference = 2;
    end

    converged = true;
    
    if length(old) == length(new)
        for i=1:length(new)
            low  = min(old(i), new(i));
            high = max(old(i), new(i));
            if high - low > difference
                converged = false;
                return;
            end
        end
    else
        converged = false;
    end
end



function [change_points, range] = ICSS_step_1_and_2(data)
% ICSS_STEP_1_AND_2 Perform the first two steps of the ICSS alg, recursive
%   The first two steps find all the potential change points. Due to its
%   recursive nature, the masking effect of changes is minimized.

    change_points = [];
    range = [];
    if length(data) < 0
        return;
    end
    
    % Step 1
    Dk = CenteredCusumValues(data);
    [exceeds, position_step1] = check_critical_value(Dk);
    if exceeds
        % There is a change point
        
        
        % Step 2a
        % -------
        
        position = position_step1;
        while exceeds
            % Scan first part
            t2 = position;
            Dk_step2a = CenteredCusumValues(data(1:t2));
            [exceeds, position] = check_critical_value(Dk_step2a);
        end
        
        k_first = t2;
        
        
        % Step 2b
        % -------
        
        position = position_step1 + 1;        
        exceeds = true;
        while exceeds
            % Scan last part
            t1 = position;
            Dk_step2b = CenteredCusumValues(data(t1:end));
            [exceeds, position2] = check_critical_value(Dk_step2b);
            position = position2 + position;
        end
        
        k_last = t1 - 1;
        
        
        % Step 2c
        % -------
        
        if k_first == k_last
            % Just one change-point, stop here
            change_points = k_first;
        else
            % Multiple change points; repeat for the section between them
%             deep = ICSS(data(k_first:k_last));
            range = [k_first,k_last];
            % Add the first position to all the returned change points of
            % the recursive, to get the correct offset
%             change_points = [k_first, deep + k_first, k_last];
            change_points = [k_first, k_last];
            
        end
    end
end

function [exceeds, position] = check_critical_value(Dk, D_star)
% CHECK_CRITICAL_VALUE Check if the max value of a range exceeds the
% critcal
%   Check if M over the range of Dk exceeds D_star (default: 1.358), 
%   if so, it is at -position-

    if nargin < 2
        D_star = 1.358;
    end

    [value, position] = max(abs(Dk));
    M = (sqrt(length(Dk)/2) * value);
    exceeds = M > D_star;
end