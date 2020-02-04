% Knapsack without repitition

function main()

item   = [ 1  2  3 4 5 6  7]
profit = [30 14 16 9];
weight = [ 6  3  4 2];
maxWeight = 10;

% 2D array of size 4x4 to hold all solutions
k = zeros(length(profit),maxWeight);

% Start at index 2 because the first row and first column need to be zeros
for j = 2:length(profit)
	for w = 2:maxWeight
		k(w,j) = k(j-1,w);
		k(w,j) = max([k(weight(w)-weight(j),j-1) + profit(j),k(w,j-1) ]);

	end
end

end


