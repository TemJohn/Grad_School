function dpll()
% Requires dimacs format problem. 
% Generate from https://toughsat.appspot.com/ using the "Random k-sat"
% setting. 
% 
fileid =...
    fullfile('C:\Users\johnathan.hall\Documents\otherGits\grad_school',...
    'random_ksat-larger.dimacs');

[satProb,numVars,~] = loadFile(fileid);

% To use the unit propogation function, some variables need to be left
% unset. Use NaN to signify unset variables.
vars = NaN(1,numVars);

[sat,vars,assignmentOrder] = dpllMain(satProb,vars,{});

% sat: a logical variable. True if problem is satisfiable
% vars: the assignment of each literal
% assignmentOrder: the resulting stack used to explore the space
if(sat)
    fprintf('Sat problem was satisfied\n');
else
    fprintf('Sat problem was not satisfiable\n');
end
end

% Parse the text file. Requires dimacs format. Returns a matrix of numbers
% relating to the variable number. Negative values are variables that are
% negated. Each row in the matrix is a clause.
function [prob,vars,clauses] = loadFile(fileid)
fid = fopen(fileid);
s = {};
while(~feof(fid))
    s(end+1) = {fgetl(fid)};
end
fclose(fid);
s = s';

i = 1;
% Find the line where problem is defined
while(~strcmp(s{i}(1),'p') || i == length(s))
    i = i + 1;
end
% If no problem line was found, quit the program
if(i == length(s))
    return;
end

temp = strsplit(s{i},' ');
vars = str2double(temp{3});
clauses = str2double(temp{4});

% Separate each cell by the space delimiter
prob = cellfun(@(x) strsplit(x,' '),s(i+1:end),'uniformoutput',false);
% Turn the chars into double
prob = cellfun(@str2double,prob,'uniformoutput',false);
% Make the cell array of numbers a matrix
prob = cell2mat(prob);
% The last line contains '0' which signifies an end of line. Remove this
prob = prob(:,1:end-1);
end

function [sat,vars,assignmentOrder] = dpllMain(prob,vars,assignmentOrder)
sat = [];
if(isempty(prob))
    sat = true;
    return;
end

% Guess a variable, start with the first in the clause
% Check if it created any unit clauses (ones where only one more variable
% is unassigned)
% If a unit clause is created, set the last variable and check its validity
%   If it's false, change that last variable
%   If it's still false, recursively jump back and edit variables
%   either the recursion will stop at the first variable and thus
%   unsatisfyable or a solution will be found.

% Clause number. For every clause in the problem
for clause = 1:size(prob,1)
    % Set the variable, check if unit propagation is possible. If it is,
    % perform it. If not, call dpllMain with current clause removed
    
    thisclause = prob(clause,:);
   
    
    % If the sum of non-nan literals for this clause is the total number of
    % literals in this clause - 1, perform unit propogation and call
    % dpllMain on the remaining clauses
    if(sum(~isnan(vars(abs(thisclause)))) == size(prob,2)-1)
        newvars = unitPropagate(thisclause,vars);
        v = find(isnan(newvars) ~= isnan(vars));
        
        vars = newvars;
        assignmentOrder{1,end+1} = v;
        assignmentOrder{2,end} = vars(v);
        
        % If all variables have been set after unit propogation
        if(all(~isnan(vars)))
            sat = checkSat(prob,vars);
            if(sat)
                % Done!
                return;
            end
        end
        
        % Remove completed clauses from consideration
        remainingClauses = setdiff(prob,thisclause,'rows');
        [sat,vars,assignmentOrder] = dpllMain(remainingClauses,vars,assignmentOrder);
        if(~isempty(sat))
            return;
        end
    else
        % Else set the first nan literal in the clause
        % Get the index of the first nan (unset) literal for this clause
        v = thisclause(isnan(vars(abs(thisclause))));
        
        % If there's no unset literal, the last literal in the stack needs
        % to be modified
        if(isempty(v))
            % If every variable has been assigned twice (each branch fully
            % explored), and we're to this point, the problem is not
            % satisfiable
            if(all(cellfun(@numel,assignmentOrder(2,:)) == 2) && ...
                    size(assignmentOrder,2) == length(vars))
                sat = false;
                return;
            end
            
            % Find the last literal that hasn't been modified twice
            ind = size(assignmentOrder,2);
            while(numel(assignmentOrder{2,ind}) == 2)
                % Remove those who have been modified twice so we get back
                % to the top node. Unset literals as we backtrace
                vars(assignmentOrder{1,end}) = NaN;
                assignmentOrder(:,end) = [];
                ind = size(assignmentOrder,2);
            end
            
            % If a literal has only been modified once, update with a new
            % assignment and record the assignment and continue
            if(numel(assignmentOrder{2,end}) == 1)
                % Assign that literal to the NOT of what it currently is
                vars(assignmentOrder{1,end}) = -assignmentOrder{2,end};
                % Record this in the stack, so that it now has both
                % assignments
                assignmentOrder{2,end} = [assignmentOrder{2,end},-assignmentOrder{2,end}];
                % If all literals are assigned, check if the problem is
                % satisfied
                if(all(~isnan(vars)))
                    sat = checkSat(prob,vars);
                    if(sat)
                        return;
                    end
                end
                continue;
            else
                % Won't get here. The WHILE loop above cleans the end of
                % the stack
                
                
                % Unset the latest literal
                vars(assignmentOrder{1,end}) = NaN;
                % Clear the last in the stack
                assignmentOrder{:,end} = [];
                % Reassign the second to last (now the last) in the stack
                vars(assignmentOrder{1,end}) = -assignmentOrder{2,end};
            end
        end
        % From the set of literals in this clause that need to be assigned,
        % pick the first unassigned in the clause.
        v = v(1);
        % Add it to the stack
        assignmentOrder(1,end+1) = {abs(v)};
        
        
        % Set the literal to -1 if the clause is negated and 1 if there is
        % no negation
        if(v < 0)
            vars(abs(v)) = -1;
        else
            vars(v) = 1;
        end
        % Record its assignment in the stack
        assignmentOrder(2,end) = {vars(abs(v))};
    end
end

% After the variables have been set for all clauses, check their validity.
% If at least one variable is true in each clause is true, then the CNF is
% satisfiable. If not, then it is unsatisfiable
sat = checkSat(prob,vars);

end

function vars = unitPropagate(clause,vars)
% Find literal in this clause that is unset, assign it and recurse back
% (outside this function)
v = intersect(find(isnan(vars)),abs(clause));

% Assignment is each literal's value (the literal number including a minus
% symbol if it is a negated literal) times its boolean assignment. This
% produces the literal numbers again with their boolean assignment. If any
% one of these in the clause is positive, set the unset literal to
% negative, since it's not needed to satisfy the expression. If none in
% 'assignment' are positive, set the unset literal to positive
assignment = clause.* vars(abs(clause));
if(any(assignment > 0))
    vars(v) = -1;
else
    vars(v) = 1;
end
end

function sat = checkSat(prob,vars)
% at least one variable per clause must evaluate to true. A negated
% literal must have a value of -1 or a positive literal must have a value
% of 1

% for each clause
% get the assignments of the literals in this clause
% multiply clause value by literal value
% if any are >0, set the sat of this clause to true
% if all are <0, immediately return that sat for this clause is false
% (must try a different assignment, so recurse back)

for c = 1:size(prob,1)
    if(any(vars(abs(prob(c,:))) == 1))
        % Clause was satisfied
        sat = true;
    else
        sat = false;
        break;
    end
end
end
