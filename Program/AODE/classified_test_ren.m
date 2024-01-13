function total_prob = classified_test_ren(bnet, classify_node_num,...
    test_data, node_sizes,total_prob)

prob = zeros(node_sizes(classify_node_num), size(test_data,2));%5x89
engine = jtree_inf_engine(bnet);         % Inference engine

for j = 1:size(test_data,2)%测试
    [engine,loglik] = enter_evidence(engine, test_data(:,j));
    marg = marginal_nodes(engine, classify_node_num);%计算给定条件下类节点的边缘概率分布
    prob(:,j) = marg.T;  % 边缘概率分布存在T中赋值给prob的第j列
end
total_prob=prob+total_prob;


end

