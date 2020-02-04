% Knapsack without repitition

function main()

item   = [ 1  2  3 4 5 6  7];
profit = [9 14 16 30];
weight = [ 2 3 4 6];
maxWeight = 10;

% 2D array to hold all solutions
k = zeros(length(profit)+1,maxWeight+1);

% Start at index 2 because the first row and first column need to be zeros
for i = 2:length(profit)+1
    % j is the current small knapsack max weight
	for j = 2:maxWeight+1
        % Assign the weight from the row above (the previous profit). Build
        % on previous profits to inform the current small knapsack
		k(i,j) = k(i-1,j);
        % If the weight being tested is larger than the current small
        % knapsack, skip it
        if(weight(i-1)+1 > j)
            continue
        end
        % The candidate is the value of the previous small knapsack plus
        % this small knapsack
        candidate = k(i-1,j-weight(i-1)) + profit(i-1);
        % If this candidate profit is greater than the previous profit,
        % update the weight array
        if(candidate > k(i,j))
    		k(i,j) = candidate;
        end
	end
end

% 2D array to hold all solutions
m = zeros(length(profit)+1,maxWeight+1);

% Start at index 2 because the first row and first column need to be zeros
for i = 2:length(profit)+1
    % j is the current small knapsack max weight
    for j = 2:maxWeight+1
        m(i,j) = max([m(i-1,profit(j)-weight(i-1)) + profit(i-1),m(i-1,j)+1]);
    end
end


end


