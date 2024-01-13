function total_prob = classified_test_ren(bnet, classify_node_num,...
    test_data, node_sizes,total_prob)

prob = zeros(node_sizes(classify_node_num), size(test_data,2));%5x89
engine = jtree_inf_engine(bnet);         % Inference engine

for j = 1:size(test_data,2)%����
    [engine,loglik] = enter_evidence(engine, test_data(:,j));
    marg = marginal_nodes(engine, classify_node_num);%���������������ڵ�ı�Ե���ʷֲ�
    prob(:,j) = marg.T;  % ��Ե���ʷֲ�����T�и�ֵ��prob�ĵ�j��
end
total_prob=prob+total_prob;


end

