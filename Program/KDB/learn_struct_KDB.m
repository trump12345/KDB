function dag=learn_struct_KDB(data,class_node,node_size,k)
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
cond_mi_mat(:,class_node)=inf;
cond_mi_mat(class_node,:)=inf;
for i = setdiff(1:(num_node-1),class_node)
    for j = setdiff((i+1):num_node,class_node)
        cmi = cond_mutual_info_score(i,node_size(i), j,node_size(j), class_node,node_size(class_node),data);  % 计算条件互信息
        cond_mi_mat(i, j) = cmi;
        cond_mi_mat(j, i) = cmi;  % 对称性：mi_matrix(i, j) = mi_matrix(j, i)
    end
end
%属性排序
for i=1:num_node-1
    MI_sort(i,1)=i;
    MI_sort(i,2)=mi_mat(i,class_node);
end
MI_sort = MI_sort(MI_sort(:,2)>0,:);%从 MI_sort 中移除值小于或等于零的行。
[~, I] = sort(MI_sort(:,2),'descend');%对 MI_sort 的第2列进行降序排序，
%并将排序后的索引保存在 I 中。按照属性的互信息值进行排序。
A=MI_sort(I,:);%A第一列是排序后的索引值，第二列是对应互信息值
sort_attribute = A(:,1)';
%结构学习
for  i =1:length(sort_attribute)
    if i ==1 %第一个节点
        dag(class_node,sort_attribute(i))=1;
    else
        if i<=3  %到第三个节点才可能有节点有两个父节点
            dag(class_node,sort_attribute(i))=1;
            for  j =1:i-1
                dag(sort_attribute(j),sort_attribute(i))=1;
            end
        else
            for  j =1:i-1
                temp(j,1) = sort_attribute(j);
                temp(j,2) = cond_mi_mat(sort_attribute(i),sort_attribute(j));
            end
            [~,I]=sort(temp(:,2),'descend');
            A=temp(I,:);
            parent_set = A(1:k,1);%取A的前k行，第1列，找第i个节点的k个父节点
            dag(class_node,sort_attribute(i))=1;
            dag(parent_set,sort_attribute(i))=1;
            clear temp;
        end
    end
end
end




