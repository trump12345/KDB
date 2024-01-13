clear;

data = xlsread("wine.xlsx");
data =data';
[nNodes,sample]=size(data);%取行，列数量
class_node = nNodes; % 分类/标签节点
node_flag = 'A';
[node_sizes, node_type,node_names] = get_node(data,node_flag);
root=randi([1,class_node-1]);
%dag=learn_struct_AODE(data,class_node,root);
%view(biograph(dag));
actual_Y = data(class_node,:); % 真实标签值最后一列的真实值
actual_Y_mat  = full(sparse(1:numel(actual_Y),actual_Y,1)); % 将Y值变为矩阵形式
cv =  crossval_ren(actual_Y, "CV-10");
dag_node=cell(1,class_node-1);
model=cell(1,class_node-1);
bnet_node=cell(1,class_node-1);

tic
for i = 1:cv.NumTestSets
    trainData= data(:,cv.train(i,:));
    testData =data(:,cv.test(i,:));
    testData =num2cell(testData);  % 测试数据转化为元组
    testData(class_node,:) = {[]}; %  remove class
    total_prob=zeros(node_sizes(class_node), size(testData,2));
    %# training
    learn_start_time = cputime; % 开始学习时间
    %dag = mk_naive_struct(nNodes,classify_node_num);
    for j=1:class_node-1  %每个节点都当一次根节点
        root=j;
        dag=learn_struct_AODE(data,class_node,root);
        dag_node{j}=dag;
        dNodes =1:nNodes;
        bnet = mk_bnet(dag_node{j}, node_sizes, 'discrete',dNodes, 'names',node_names);
        for node_i=1:numel(dNodes)
            name = node_names{dNodes(node_i)};%把node_names中的元素赋给name
            bnet.CPD{node_i} = tabular_CPD(bnet, node_i, ...
                'prior_type','dirichlet',"dirichlet_type","unif"); %BDeu  unif
            %'prior_type','dirichlet' 表示使用狄利克雷先验（Dirichlet prior）来估计节点的条件概率分布。
            %"dirichlet_type","unif" 表示使用均匀分布（uniform distribution）作为狄利克雷先验的参数之一来估计条件概率分布。
        end
        bnet_node{j}=bnet;
        bnet = learn_params(bnet_node{j}, trainData); %  参数学习 学习条件概率表
        model{j}=bnet;
    % # testing
    actual_Y_test = actual_Y_mat(cv.test(i,:),:);
    
    total_prob = classified_test_ren(model{j},class_node,...
        testData,node_sizes,total_prob);
    end
    total_mean_prob=total_prob/class_node;
    [confusion_matrix,correct_rate,RMSE_RESULT]=score(total_mean_prob,actual_Y_test);
    
    accuracy = correct_rate/100;
    correct_rate_matrix(i,1) = 1-correct_rate/100;
    correct_rate_matrix(i,2) = RMSE_RESULT;
    %correct_rate_matrix(i,3) = end_learn_time;
    %correct_rate_matrix(i,4) = end_classify_time;
    correct_rate_matrix(i,5) = accuracy;
    
end
%view(biograph(dag));
toc
%%%%%%  3 保存实验结果  %%%%%%

total_result{1,1}="序号";
total_result{1,2}="数据集";
total_result{1,3}="01损失";
total_result{1,4}="均方误差";
total_result{1,5}="学习时间";
total_result{1,6}="分类时间";
total_result{1,7}="准确度";

tatal_mean = mean(correct_rate_matrix);
total_result{2,1}=1;
total_result{2,2}="anneal";
total_result{2,3} = tatal_mean(1);
total_result{2,4} = tatal_mean(2);
total_result{2,5} = tatal_mean(3);
total_result{2,6} = tatal_mean(4);
total_result{2,7} = tatal_mean(5);

disp("=============AODE测试结束================");















%%
function [node_sizes,node_name,node_type] = get_node(data,node_flag)

[r,~] = size(data);  %忽略列输出
node_class_num = cell(1,r);%初始化元胞数组%1x32
node_sizes = cell(1,r);
node_name = cell(1,r);
node_type = cell(1,r);
for i = 1:r
    eval([node_flag, num2str(i) '=num2str(i);']);%  A=num2str(i)，node_flag=A1,A2...
    node_name{i} = [node_flag, num2str(i)];%节点名字，同上
    node_class_num{i} = unique(data(i,:));%第i行的唯一值 分几类？类节点数量？
    node_sizes{i} = length(node_class_num{i});%第i个节点的特征取值个数
    node_type{i} = 'tabular';
end
node_sizes = cell2mat(node_sizes);%元胞数组转成普通数组
end
