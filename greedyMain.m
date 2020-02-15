
function greedyMain()
profit = [10 5  15 7  6  18 3 ];
weight = [2  3  5  7  1  4  1 ];

maxWeight = 15;

% Two different greedy methods with the first set of weights and profits
byWeight = greedyByWeight(profit,weight,maxWeight);
byCombo = greedyByCombo(profit,weight,maxWeight);

altProfit = [15 2 2 7 13 10 8 6];
altWeight = [8  1 3 7  3  1 8 2];

% Two greedy methods with a different set of weights and profits
altByWeight = greedyByWeight(altProfit,altWeight,maxWeight);
altByCombo  = greedyByCombo(altProfit,altWeight,maxWeight);

end

function chosen = greedyByWeight(profit,weight,maxWeight)
% Current weight. Will end at m (the max weight)
cw = 0;
wtemp = weight;
% Which items were chosen, and how many KG of it? Partial weights allowed
% If partial weights are not allowed, comment the 2 lines in the second IF
% statement, except the break command
chosen = zeros(size(profit));
while(cw < maxWeight)
    if(max(weight) == 0)
        break;
    end
    [~,ind] = max(weight);
    if(cw + weight(ind) > maxWeight)
        chosen(ind) = (maxWeight-cw)/weight(ind);
        cw = cw + chosen(ind)*weight(ind);
        break;
    end
    chosen(ind) = 1;
    cw = cw + weight(ind);
    weight(ind) = 0;
end

usedWeights = wtemp(chosen ~= 0);
fprintf('By weight method used these weights at these percentages:\n');
fprintf('%d\t%.2f\n',[usedWeights',chosen(chosen~=0)'.*100]');
fprintf('For a total profit of\n');
fprintf('%0.2f\n',sum(chosen.*profit));
end

function chosen = greedyByCombo(profit,weight,maxWeight)
% Current weight. Will end at the max weight
cw = 0;
combo = profit./weight;
comboTemp = combo;
wtemp = weight;
% Which items were chosen, and how many KG of it? Partial weights allowed
% If partial weights are not allowed, comment the 2 lines in the second IF
% statement, except the break command
chosen = zeros(size(profit));
while(cw < maxWeight)
    if(max(weight) == 0)
        break;
    end
    [~,ind] = max(combo);
    if(cw + weight(ind) > maxWeight)
        chosen(ind) = (maxWeight-cw)/weight(ind);
        cw = cw + chosen(ind)*weight(ind);
        break;
    end
    chosen(ind) = 1;
    cw = cw + weight(ind);
    combo(ind) = 0;
end

usedWeights = wtemp(chosen ~= 0);
fprintf('By combo method used these weights at these percentages:\n');
fprintf('%d\t%.2f\n',[usedWeights',chosen(chosen~=0)'.*100]');
fprintf('For a total profit of\n');
fprintf('%0.2f\n',sum(chosen.*profit));

end
