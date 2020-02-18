function [sat, assignment] = satCreator(A)
% SATISFY SAT solver using Davis-Putnam-Logemann-Loveland recursion
%
% global variables 
initclauses = 1:size(A,1);
assignment = zeros(1,size(A,2));
attempt = 0;
sat = dpll(initclauses, assignment);
    %% embedded recursive function DPLL 
    % Davis-Putnam-Logemann-Loveland recurive SAT solver
    function [sat, assignment] = dpll(clauses, old_assignment)
        assignment = old_assignment;
        if isempty(clauses)
            sat = true;
            return
        end
        
        for i=1:length(clauses)
            clause = A(clauses(i),:);
            % if unit clause OR pure literal
            literals = find(clause);
            assigned = find(assignment);
            if length(setdiff(literals, assigned))==1 && isimplied()
                v = setdiff(literals, assigned); % implied literal
                assignment(v) = clause(v); %assign value
                newclauses = setdiff(clauses, clauses(i));
                sat = dpll(newclauses, assignment);
                return
            end
        end
        
        val = evalclauses(clauses, assignment);
        if val==-1
            sat = false;
            return
        elseif val==1
            sat = true;
            return
        end
        
        %% need to take a guess, for now take the first 
        % unassigned variable appears
        for i=1:length(clauses)
            clause = A(clauses(i),:);
            [row, v]= find(clause~=0 & assignment==0, 1, 'first');
            if ~isempty(row)
                v = v(1); % pick the first one
                assignment(v) = clause(v);
                break;
            end
        end
        if isempty(row)
            [row, v]= find(assignment==0, 1, 'first');
            if isempty(row)
                error('Must have unassigned');
            end
            assignment(v) = 1;
        end
        
        %% recursion
        % Record the attempt number and print it out
        attempt = attempt+1;
        fprintf('\b\b\b%3d', attempt);
        sat = dpll(clauses, assignment);
        if (sat)
            return
        else
            % 
            assignment(v) = -assignment(v);
            sat = dpll(clauses, assignment);
            return
        end
        %%
        %  Determine if the clause is a unit clause
        function yesno = isimplied()
            assigned = intersect(find(clause), find(assignment));
            yesno = all(clause(assigned).*assignment(assigned) == -1);
        end
    end
    
    % Evaluate the current set of clauses
    function val = evalclauses(clauses, assignment)
        assigned = find(assignment ~= 0);
        val = 0;
        values = zeros(1,length(clauses));
        for i=1:length(clauses)
            clause = A(clauses(i),:);
            literals = find(clause);
            if all(ismember(literals, assigned))
                % clause can be evaled
                if any(clause.*assignment ==1)
                    values(i)=1;
                else
                    val = -1;
                    return
                end
            end
        end
        if all(values==1)
            val = 1;
        elseif any(values==-1)
            val = -1;
        end
    end
end