% Knapsack without repitition

function main()

profit = [9 14 16 30];
weight = [ 2 3 4 6];
maxWeight = 10;

% 2D array to hold all solutions
k = zeros(length(profit)+1,maxWeight+1);

% Start at index 2 because the first row and first column need to be zeros
for p = 2:length(profit)+1
    % w is the current small knapsack max weight
	for w = 2:maxWeight+1
        % Assign the value from the row above (the previous profit). Build
        % on previous profits to inform the current small knapsack
		k(p,w) = k(p-1,w);
        % If the weight being tested is larger than the current small
        % knapsack, skip it
        if(weight(p-1)+1 > w)
            continue
        end
        % The candidate is the value of the previous small knapsack plus
        % this small knapsack
        candidate = k(p-1,w-weight(p-1)) + profit(p-1);
        % If this candidate profit is greater than the previous profit,
        % update the profit array
        if(candidate > k(p,w))
    		k(p,w) = candidate;
        end
	end
end

end


