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
    final_dag=dag;
    [curr_score, ~] = score_dags(data, node_size, dags, 'scoring_fn', score_fn);
    best_score=curr_score;
    hascycle=check_cycle(dag);
    for n=1:k
        parent=parent_set(n,1);
        if dag(parent,i)==1 && dag(i,parent)==1
            dag_copy1 = dag;
            dag_copy1(parent, i) = 0;     % 删除一个父节点指向节点i的边
            % 计算修改后的DAG的得分
            modified_dags1 = {dag_copy1};
            [modified_score1, ~] = score_dags(data, node_size, modified_dags1, 'scoring_fn', score_fn);
            %hascycle=check_cycle(dag_copy1);
            % 如果得分更高，更新最终的有向无环图和得分
            if modified_score1 > best_score  %若删减后的比原来的得分大且不存在环路
                dag = dag_copy1;
                best_score = modified_score1;
            else     %若删减的比原来的得分小则删掉另一条比较一下
                dag_copy2= dag;
                dag_copy2(i, parent) = 0;     % 删除一个i指向父节点的边
                % 计算修改后的DAG的得分
                modified_dags2 = {dag_copy2};
                [modified_score2, ~] = score_dags(data, node_size, modified_dags2, 'scoring_fn', score_fn);
                 %hascycle=check_cycle(dag_copy2);
                if modified_score1 > modified_score2 %如果原来的比后删的大则保留原来的
                    dag=dag_copy1;
                    best_score = modified_score1;
                else
                    dag=dag_copy2;
                    best_score = modified_score2;
                end
            end
        else
            final_score = best_score;
            dag=dag;
        end
        hascycle=check_cycle(dag);
        
    end
    if hascycle==1
        disp(i);
        error('存在环路');
    end
    clear CMI_sort;
    
end
dag(class_node,notclass)=1;
view(biograph(dag));
end





