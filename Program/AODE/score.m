function [confusion_matrix,correct_rate,RMSE_RESULT]=score(total_mean_prob,true_Y_test)
% 选出概率最大的值的状态设置为1，然后其他的类节点状态设置为0
predInd = total_mean_prob;
predInd(max(predInd)==predInd)=1; % 将最大值位置设置为1 其他位置设置为0
predInd(max(predInd)~=predInd)=0;
predInd =  predInd'; %  转置后变形式为：true_Y_test = 898*5 ，sample*classnode_size

[C, RATE] = confmat(predInd, true_Y_test);%confmat(Y,T)计算预测值和真实值的混淆矩阵和正确率
correct_rate = RATE(:,1);%RATE有两列，第一列是正确率，第二列是正确分类的数量
confusion_matrix =C;
%%%%%%%%%%%%%% 计算均方误差 %%%%%%%%%%
rmse_temp = total_mean_prob';
rmse_temp(true_Y_test==0)=0;
rmse =rmse_temp-true_Y_test;
rmse2 = rmse.^2;
RMSE_RESULT = sqrt(sum(sum(rmse2))/size(true_Y_test,1));

end