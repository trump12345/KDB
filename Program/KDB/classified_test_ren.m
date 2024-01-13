function [confusion_matrix,correct_rate,RMSE_RESULT] = classified_test_ren(bnet, classify_node_num,...
    test_data, true_Y_test, node_sizes)

prob = zeros(node_sizes(classify_node_num), size(test_data,2));%5x89
engine = jtree_inf_engine(bnet);         % Inference engine
for j = 1:size(test_data,2)%测试  1-89
    [engine,loglik] = enter_evidence(engine, test_data(:,j));
    marg = marginal_nodes(engine, classify_node_num);%计算边缘概率分布
    prob(:,j) = marg.T;  % 离散节点概率*测试样本
end

% 选出概率最大的值的状态设置为1，然后其他的类节点状态设置为0
predInd = prob;
predInd(max(predInd)==predInd)=1; % 将最大值位置设置为1 其他位置设置为0
predInd(max(predInd)~=predInd)=0;
predInd =  predInd'; %  转置后变形式为：true_Y_test = 898*5 ，sample*classnode_size

[C, RATE] = confmat(predInd, true_Y_test);%confmat(Y,T)计算预测值和真实值的混淆矩阵和正确率
correct_rate = RATE(:,1);
confusion_matrix =C;
%%%%%%%%%%%%%% 计算均方误差 %%%%%%%%%%
rmse_temp = prob';
rmse_temp(true_Y_test==0)=0;
rmse =rmse_temp-true_Y_test;
rmse2 = rmse.^2;
RMSE_RESULT = sqrt(sum(sum(rmse2))/size(true_Y_test,1));


end

