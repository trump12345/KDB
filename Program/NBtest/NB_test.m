

%% Ŀ�ģ���anneal���ݼ�����NB�ķ���Ч��

clc;
clear all;
close all;

%%%%%% 1 ���ݴ��� %%%%%%
data = xlsread("anneal21.xlsx");
data =data';
[nNodes,sample]=size(data);
classify_node_num = nNodes; % ����/��ǩ�ڵ�
node_flag = 'A';
[node_sizes, node_type,node_names] = get_node(data,node_flag);


%%%%%% 2 ģ�͹�������֤ %%%%%%
actual_Y = data(classify_node_num,:); % ��ʵ��ǩֵ
actual_Y_mat  = full(sparse(1:numel(actual_Y),actual_Y,1)); % ��Yֵ��Ϊ������ʽ
cv =  crossval_ren(actual_Y, "CV-10"); % ʮ�۽�����֤ 

for i = 1:cv.NumTestSets
    trainData= data(:,cv.train(i,:));
    testData =data(:,cv.test(i,:));
    testData =num2cell(testData);  % ��������ת��ΪԪ��
    testData(classify_node_num,:) = {[]}; %  remove class

    %# training    
    learn_start_time = cputime; % ��ʼѧϰʱ��

    %% �ṹѧϰ
    %  2.1 ����ѧϰ
    dag = mk_naive_struct(nNodes,classify_node_num);

    % view(biograph(dag));  %   �鿴�������˽ṹ

    % 2.2 ����ѧϰ
    dNodes =1:nNodes;
    bnet = mk_bnet(dag, node_sizes, 'discrete',dNodes, 'names',node_names);
    for node_i=1:numel(dNodes)
        name = node_names{dNodes(node_i)};
        bnet.CPD{node_i} = tabular_CPD(bnet, node_i, ...
            'prior_type','dirichlet',"dirichlet_type","unif"); %BDeu  unif
    end
    bnet = learn_params(bnet, trainData); %  ����ѧϰ
    end_learn_time = cputime - learn_start_time ; % ����ѧϰʱ��

    %% 2.3 ����
    start_classify_time = cputime;
    % # testing
    actual_Y_test = actual_Y_mat(cv.test(i,:),:);
    [~,correct_rate,rmse] = classified_test_ren(bnet,classify_node_num,testData,actual_Y_test,node_sizes);
    end_classify_time = cputime -start_classify_time ;

    accuracy = correct_rate/100;
    correct_rate_matrix(i,1) = 1-correct_rate/100;
    correct_rate_matrix(i,2) = rmse;
    correct_rate_matrix(i,3) = end_learn_time;
    correct_rate_matrix(i,4) = end_classify_time;
    correct_rate_matrix(i,5) = accuracy;

end

%%%%%%  3 ����ʵ����  %%%%%%

total_result{1,1}="���";
total_result{1,2}="���ݼ�";
total_result{1,3}="01��ʧ";
total_result{1,4}="�������";
total_result{1,5}="ѧϰʱ��";
total_result{1,6}="����ʱ��";
total_result{1,7}="׼ȷ��";

tatal_mean = mean(correct_rate_matrix);
total_result{2,1}=1;
total_result{2,2}="anneal";
total_result{2,3} = tatal_mean(1);
total_result{2,4} = tatal_mean(2);
total_result{2,5} = tatal_mean(3);
total_result{2,6} = tatal_mean(4);
total_result{2,7} = tatal_mean(5);

disp("=============NB���Խ���================");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get node sizes
function [node_sizes,node_name,node_type] = get_node(data,node_flag)

[r,~] = size(data);
node_class_num = cell(1,r);
node_sizes = cell(1,r);
node_name = cell(1,r);
node_type = cell(1,r);
for i = 1:r
    eval([node_flag, num2str(i) '=num2str(i);']);
    node_name{i} = [node_flag, num2str(i)];
    node_class_num{i} = unique(data(i,:));
    node_sizes{i} = length(node_class_num{i});
    node_type{i} = 'tabular';
end
node_sizes = cell2mat(node_sizes);
end


