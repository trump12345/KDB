function [confusion_matrix,correct_rate,RMSE_RESULT] = classified_test_ren(bnet, classify_node_num,...
    test_data, true_Y_test, node_sizes)

prob = zeros(node_sizes(classify_node_num), size(test_data,2));%5x89
engine = jtree_inf_engine(bnet);         % Inference engine
for j = 1:size(test_data,2)%����  1-89
    [engine,loglik] = enter_evidence(engine, test_data(:,j));
    marg = marginal_nodes(engine, classify_node_num);%�����Ե���ʷֲ�
    prob(:,j) = marg.T;  % ��ɢ�ڵ����*��������
end

% ѡ����������ֵ��״̬����Ϊ1��Ȼ����������ڵ�״̬����Ϊ0
predInd = prob;
predInd(max(predInd)==predInd)=1; % �����ֵλ������Ϊ1 ����λ������Ϊ0
predInd(max(predInd)~=predInd)=0;
predInd =  predInd'; %  ת�ú����ʽΪ��true_Y_test = 898*5 ��sample*classnode_size

[C, RATE] = confmat(predInd, true_Y_test);%confmat(Y,T)����Ԥ��ֵ����ʵֵ�Ļ����������ȷ��
correct_rate = RATE(:,1);
confusion_matrix =C;
%%%%%%%%%%%%%% ���������� %%%%%%%%%%
rmse_temp = prob';
rmse_temp(true_Y_test==0)=0;
rmse =rmse_temp-true_Y_test;
rmse2 = rmse.^2;
RMSE_RESULT = sqrt(sum(sum(rmse2))/size(true_Y_test,1));


end

