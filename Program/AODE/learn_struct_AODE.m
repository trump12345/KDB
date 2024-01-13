function dag=learn_struct_AODE(data,class_node,root)
%AODE学习算法
%data：数据集
%class_node：类标签
%root：除了类节点之外的根节点
%node_size：节点大小

if nargin<3
    error('请输入正确的变量数，3个');
end

N=size(data,1);
node_type=cell(1,(N-1));
for i=1:N-1
    node_type{i}='tabular';
end
notclass=setdiff(1:N,class_node);
aode_mat=zeros(N,N);
aode_mat(:,class_node)=0;
aode_mat(root,notclass)=1;%非类根节点到其他非类节点的边
aode_mat(:,root)=0;
aode_mat(class_node,notclass)=1;%类节点到其他非类节点的边
%aode_mat(class_node,root)=1;%类到根节点的边
dag=aode_mat;
end




