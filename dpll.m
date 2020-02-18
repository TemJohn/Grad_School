function dpll()
% Requires dimacs format problem
fileid =...
    fullfile('C:\Users\johnathan.hall\Documents\otherGits\grad_school',...
    'random_ksat.dimacs');

[satProb,numVars,~] = loadFile(fileid);

% To use the unit propogation function, some variables need to be left
% unset. Use NaN to signify unset variables.
vars = NaN(1,numVars);

sat = dpllMain(satProb,vars);

keyboard;
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

function vars = dpllMain(prob,vars)
if(isempty(prob))
    vars = true;
    return;
end

% Guess a variable, start with the first in the clause
% Check if it created any unit clauses (ones where only one more variable
% is unassigned)
% If a unit clause is created set the last variable and check its validity.
%   If it's false, change that last variable
%   If it's still false, recursively jump back and edit variables
%   either the recursion will stop at the first variable and thus
%   unsatisfyable or a solution will be found.

% Clause number. For every clause
for clause = 1:size(prob,1)
    % Set the variable, check if unit propagation is possible. If it is,
    % perform it. If not, call dpllMain with current clause removed
    
    % Get the index of the first nan (unset) literal for this clause
    v = find(isnan(vars(abs(prob(clause,:)))),1,'first');
    
    if(isempty(v))
        return;
    end
    
    % Set the literal to -1 if the clause is negated and 1 if there is
    % no negation
    if(prob(clause,v) < 0)
        vars(v) = -1;
    else
        vars(v) = 1;
    end
    
    % If the sum of non-nan variables for this clause is the number of
    % literals in this clause - 1
    if(sum(~isnan(vars(abs(prob(clause,:))))) == size(prob,2)-1)
        vars = unitPropagate(prob(clause,:),vars);
        return;
    end
    
    remainingClauses = setdiff(prob,prob(clause,:),'rows');
    vars = dpllMain(remainingClauses,vars);
    
end

end

function vars = unitPropagate(clause,vars)
% Find literal in this clause that is unset, assign it and recurse back
% (outside this function)
v = intersect(find(isnan(vars)),abs(clause));

% If none of the literals in this clause are nan, negate one of the
% currently assigned literals. How to ensure modifying the right variable
% and that the following variables are nan so that they can be modified at
% the right time.

if(clause(abs(clause)==v) < 0)
    vars(v) = -1;
else
    vars(v) = 1;
end

end

function literalEliminate()
% find pure literals: variables that are only one polarity (never preceeded
% by not or always preceeded by not). When a pure literal is found, set so
% that the result is true and remove it from consideration.
end

function result = checkSat(prob,vars)
% at least one variable per clause must evaluate to true. A negated
% literal must have a value of -1 or a positive literal must have a value
% of 1

% for each clause
% get the assignments of the literals in this clause
% multiply clause value by literal value
% if any are >0, set the sat of this clause to true
% if all are <0, immediately return that sat for this clause is false
% (must try a different assignment, so recurse back)

% prob may be just one clause
if(any(isnan(vars(prob))))
    result = false;
    return;
end

end
