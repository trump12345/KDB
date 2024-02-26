function dag=learn_struct_KDB_NEW(data,class_node,node_size,score_fn,k)
%学习KDB结构
%input:data,class_node,node_size,k
%class_node:类节点
%node_size：特征节点大小
%k:每个节点可以有多少个父节点
%output: dag
if nargin==3
    k=2;
end
[num_node sample]=size(data);
notclass=setdiff(1:class_node,class_node);
dag=zeros(num_node,num_node);
%计算互信息矩阵
mi_mat=zeros(num_node,num_node);
mi_mat=calculate_mutual_information_array(data);
mi_mat(class_node,:)=0;
%计算条件互信息矩阵
cond_mi_mat=zeros(num_node,num_node);
cond_mi_mat(:,class_node)=0;
cond_mi_mat(class_node,:)=0;
for i = setdiff(1:(num_node-1),class_node)
    for j = setdiff((i+1):num_node,class_node)
        cmi = cond_mutual_info_score(i,node_size(i), j,node_size(j), class_node,node_size(class_node),data);  % 计算条件互信息
        cond_mi_mat(i, j) = cmi;
        cond_mi_mat(j, i) = cmi;  % 对称性：mi_matrix(i, j) = mi_matrix(j, i)
    end
end
%为每个节点找到条件互信息最大的K个父节点，会存在环
CMI_sort=zeros(num_node,2);
CMI_sort(:,1)=1:num_node;
CMI_sort(class_node,1)=0;
for i=1:num_node-1
    CMI_sort(:,1)=1:num_node;
    CMI_sort(class_node,1)=0;
    CMI_sort(:,2)=cond_mi_mat(:,i);
    CMI_sort = CMI_sort(CMI_sort(:,2)>0,:);%从 MI_sort 中移除值小于或等于零的行。
    [~, I] = sort(CMI_sort(:,2),'descend');%对 MI_sort 的第2列进行降序排序，
    %并将排序后的索引保存在 I 中。按照属性的互信息值进行排序。
    A=CMI_sort(I,:);%A第一列是排序后的索引值，第二列是对应互信息值
    %sort_attribute = A(:,1)';
    parent_set = A(1:k,1);%取A的前k行，第1列，找第i个节点的k个父节点
    dag(parent_set,i)=1;
    dags={dag};
    [curr_score, ~] = score_dags(data, node_size, dags, 'scoring_fn', score_fn);
    %best_score=curr_score;
    hascycle=check_cycle(dag);
    %disp(['hascycle:',num2str(hascycle)]);
    for n=1:k
        parent=parent_set(n,1);
        if dag(parent,i)==1 && dag(i,parent)==1
            dag_copy1 = dag;
            dag_copy2 = dag;
            dag_copy1(parent, i) = 0;     % 删除一个父节点指向节点i的边
            % 计算修改后的DAG的得分
            modified_dags1 = {dag_copy1};
            [modified_score1, ~] = score_dags(data, node_size, modified_dags1, 'scoring_fn', score_fn);
            dag_copy2(i, parent) = 0;     % 删除一个i指向父节点的边
            % 计算修改后的DAG的得分
            modified_dags2 = {dag_copy2};
            [modified_score2, ~] = score_dags(data, node_size, modified_dags2, 'scoring_fn', score_fn);
            %hascycle=check_cycle(dag_copy1);
            if (curr_score-modified_score1) > (curr_score-modified_score2)%若dag1损失的比dag2要多，则选择dag2
                dag = dag_copy2;
                %best_score = modified_score2;
            else     %否则选择dag1
                dag=dag_copy1;
                %best_score = modified_score1;
            end
        end % dag(parent,i)==1 && dag(i,parent)==1
        last_cycle_edge{n} = [parent, i];%记录可能得导致环的节点对
    end % for 1：k
    hascycle=check_cycle(dag);
    if hascycle==1
        % 若有环存在则删掉可能导致环的边
        parent = last_cycle_edge{2}(1);  % 父节点
        i = last_cycle_edge{2}(2);  % 节点
        dag(parent, i) = 0;  % 删除最后一个边（可能性最大）
        % 重新检查是否存在环路
        hascycle = check_cycle(dag);
        if hascycle == 1
            parent = last_cycle_edge{1}(1);  % 父节点
            i = last_cycle_edge{1}(2);  % 节点
            dag(parent, i) = 0;  % 删除第一个可能导致环的边
        end
    end
     clear CMI_sort;
end %for 1：num_node
%disp(['未达边上限的分数: ' num2str(best_score)]);
 num_edges = nnz(dag);%计算图的边数
%%%%%%%%%思路：用dfs或者拓扑排序，指定度为0的节点进行遍历，找到分别属于各个子图的节点
%%%%%%%接着再进行根节点的选取自己的孩子不可以作为自己的父亲，只能是分属两个子图的节点可以作为度为0节点的父节点。
% disp(['图中的边数量为: ' num2str(num_edges)]);
%找出入度为0的节点，选择一个当根节点
nodes_with_zero_indegree = [];
nodes_with_one_indegree = [];%找到入度为1的节点为他们添加父节点
if num_edges < (2*(num_node-1)-3)
    for node=1:num_node-1
        indegree=sum(dag(:,node));
        if indegree==0
            nodes_with_zero_indegree = [nodes_with_zero_indegree,node];
        end
        if indegree==1
            nodes_with_one_indegree = [nodes_with_one_indegree,node];
        end
    end
    nodes_with_zero_indegree_copy=nodes_with_zero_indegree;
    child_graph={};
    for node=nodes_with_zero_indegree
        visited_nodes = dfs(dag,node);
        child_graph{end+1} = visited_nodes; % 将每个节点的遍历结果添加到元组中
    end
    %%%已经找到分属于不同根节点的子图的节点了下一步要确定谁当根节点，使得分最大为目标

    n=find(nodes_with_zero_indegree==max_mi_node);
    
    nodes_with_zero_indegree(:,n)=[];
    %把除去根节点的入度为0的节点和入度为1的节点放一起，为他们添加边直到边数达到2n-3
    nodes_with_one_indegree = [nodes_with_one_indegree,nodes_with_zero_indegree];
    
    %为剩下的入度为1的节点加边，要找到只有一个入度的节点，剩下的入度都应该是2
    
    for i=nodes_with_one_indegree
        CMI_sort(:,1)=1:num_node;
        CMI_sort(class_node,1)=0;
        CMI_sort(:,2)=cond_mi_mat(:,i);
        CMI_sort = CMI_sort(CMI_sort(:,2)>0,:);%从 MI_sort 中移除值小于或等于零的行。
        [~, I] = sort(CMI_sort(:,2),'descend');%对 MI_sort 的第2列进行降序排序，
        %并将排序后的索引保存在 I 中。按照属性的互信息值进行排序。
        A=CMI_sort(I,:);%A第一列是排序后的索引值，第二列是对应互信息值
        % 遍历所有可能的父节点
        sort_attribute = A(:,1)';
        for candidate_parent = sort_attribute
            % 如果原来的图中已经存在候选父节点到该节点的边则继续下一轮循环
            if dag(candidate_parent, i) == 1
                continue;
            end
            dag(candidate_parent, i)=1;
            hascycle = check_cycle(dag);
            % 检查是否存在环路
            if ~hascycle 
                dag(candidate_parent, i) = 1;
                break;
            end
            
            % 移除候选父节点
            dag(candidate_parent, i) = 0;
            
        end
        clear CMI_sort;
    end

    for j=nodes_with_zero_indegree
%         if dag(max_mi_node,j)==1
%             continue;
%         else 
            CMI_sort(:,1)=1:num_node;
            CMI_sort(class_node,1)=0;
            CMI_sort(:,2)=cond_mi_mat(:,j);
            CMI_sort = CMI_sort(CMI_sort(:,2)>0,:);%从 MI_sort 中移除值小于或等于零的行。
            [~, I] = sort(CMI_sort(:,2),'descend');%对 MI_sort 的第2列进行降序排序，
            %并将排序后的索引保存在 I 中。按照属性的互信息值进行排序。
            A=CMI_sort(I,:);%A第一列是排序后的索引值，第二列是对应互信息值
            % 遍历所有可能的父节点
            sort_attribute = A(:,1)';
            for candidate_parent = sort_attribute
                % 如果原来的图中已经存在候选父节点到该节点的边则继续下一轮循环
                if dag(candidate_parent, j) == 1
                    continue;
                end
                dag(candidate_parent, j)=1;
                hascycle = check_cycle(dag);
                % 检查是否存在环路
                if ~hascycle
                    dag(candidate_parent, j) = 1;
                    break;
                end
                
                % 移除候选父节点
                dag(candidate_parent, j) = 0;    
            end
            clear CMI_sort;
        %end
    end
end   
%disp(['达边上限的分数: ' num2str(best_score)]);
num_edges = nnz(dag);
% disp(['边数: ' num2str(num_edges)]);
if num_edges==(2*(num_node-1)-3)
    dag(class_node,notclass)=1;
else
    disp('边数不正确。');
end
%dag(class_node,notclass)=1;
%view(biograph(dag));
end





