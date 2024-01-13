clear;
data = xlsread("anneal.xlsx");
data =data';
[nNodes,sample]=size(data);%取行，列数量
classify_node_num = nNodes; % 分类/标签节点
node_flag = 'A';
[node_sizes, node_type,node_names] = get_node(data,node_flag);
%dag=learn_struct_KDB(data,classify_node_num,node_sizes,2);
%view(biograph(dag));
actual_Y = data(classify_node_num,:); % 真实标签值最后一列的真实值
actual_Y_mat  = full(sparse(1:numel(actual_Y),actual_Y,1)); % 将Y值变为矩阵形式
cv =  crossval_ren(actual_Y, "CV-10");
tic
for i = 1:cv.NumTestSets
    trainData= data(:,cv.train(i,:));
    testData =data(:,cv.test(i,:));
    testData =num2cell(testData);  % 测试数据转化为元组
    testData(classify_node_num,:) = {[]}; %  remove class

    %# training    
    learn_start_time = cputime; % 开始学习时间
    %dag = mk_naive_struct(nNodes,classify_node_num);
    dag=learn_struct_KDB(data,classify_node_num,node_sizes,3);
    %view(biograph(dag));  %   查看网络拓扑结构
    %draw_graph(dag)
    % 2.2 参数学习
    dNodes =1:nNodes;
    bnet = mk_bnet(dag, node_sizes, 'discrete',dNodes, 'names',node_names);
    for node_i=1:numel(dNodes)
        name = node_names{dNodes(node_i)};%把node_names中的元素赋给name
        bnet.CPD{node_i} = tabular_CPD(bnet, node_i, ...
            'prior_type','dirichlet',"dirichlet_type","unif"); %BDeu  unif
        %'prior_type','dirichlet' 表示使用狄利克雷先验（Dirichlet prior）来估计节点的条件概率分布。
        %"dirichlet_type","unif" 表示使用均匀分布（uniform distribution）作为狄利克雷先验的参数之一来估计条件概率分布。
    end
    bnet = learn_params(bnet, trainData); %  参数学习
    end_learn_time = cputime - learn_start_time ; % 结束学习时间
    start_classify_time = cputime;
    % # testing
    actual_Y_test = actual_Y_mat(cv.test(i,:),:);
    [~,correct_rate,rmse] = classified_test_ren(bnet,classify_node_num, ...
        testData,actual_Y_test,node_sizes);
    end_classify_time = cputime -start_classify_time ;

    accuracy = correct_rate/100;
    correct_rate_matrix(i,1) = 1-correct_rate/100;
    correct_rate_matrix(i,2) = rmse;
    correct_rate_matrix(i,3) = end_learn_time;
    correct_rate_matrix(i,4) = end_classify_time;
    correct_rate_matrix(i,5) = accuracy;

end
view(biograph(dag)); 
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

disp("=============kdb测试结束================");