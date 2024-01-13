function dag=learn_struct_TAN(data,class_node,root,node_size)
%tan结构学习
%data:样本数据
%class_node：类节点
%root:根节点
%node_size:每个节点的离散取值范围
%计算方法为条件互信息值
if nargin<4
    error('请输入正确的变量数，4个');
end

N=size(data,1);
node_type=cell(1,(N-1));
for i=1:N-1
    node_type{i}='tabular';
end
notclass=setdiff(1:N,class_node);
%变量的数量

%计算条件互信息矩阵
cond_mi_mat=zeros(N,N);
cond_mi_mat(:,class_node)=inf;
cond_mi_mat(class_node,:)=inf;

for i = setdiff(1:(N-1),class_node)
    for j = setdiff((i+1):N,class_node)
        cmi = -cond_mutual_info_score(i,node_size(i), j,node_size(j), class_node,node_size(class_node),data);  % 计算条件互信息
        cond_mi_mat(i, j) = cmi;
        cond_mi_mat(j, i) = cmi;  % 对称性：mi_matrix(i, j) = mi_matrix(j, i)
    end
end

variab=setdiff(1:N,class_node);
G=minimum_spanning_tree(cond_mi_mat(variab,variab));%最大生成树
if root>class_node  %若根节点>类节点，则一直减
    root=root-1;
end
T=mk_rooted_tree(G,root);%添加边构建一个从根的有向树
T1=full(T);%填充生成邻接矩阵
T=zeros(N);
T(variab,variab)=T1;

dag=T;
dag(class_node,notclass)=1;%加入类节点到其他节点的边

end



