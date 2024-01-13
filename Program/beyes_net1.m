clear all;
N=8;    %节点个数
dag=zeros(N,N);%创建无环图对应的矩阵
A=1;S=2;T=3;L=4;B=5;E=6;P=7;D=8;%按拓扑矩阵给各个节点编号
dag(A,T)=1;%按拓扑结构关系赋值
dag(S,L)=1;
dag(S,B)=1;
dag(T,E)=1;
dag(L,E)=1;
dag(E,P)=1;
dag(E,D)=1;
dag(B,D)=1;
discrete_nodes = 1:N;%赋予各个节点类型，用1：N表示各个节点种类不同
node_sizes = 2*ones(1,N);%赋予节点的大小,节点独立地有几种可能
bnet=mk_bnet(dag,node_sizes,'names',{'A','S','T','L','B','E','P','D'},'discrete',discrete_nodes);%创建节点
bnet.CPD{A}=tabular_CPD(bnet,A,[0.99,0.01]);%赋概率值
bnet.CPD{S}=tabular_CPD(bnet,S,[0.50,0.50]);
bnet.CPD{T}=tabular_CPD(bnet,T,[0.99,0.95,0.01,0.05]);
bnet.CPD{L}=tabular_CPD(bnet,L,[0.99 0.9 0.01 0.1]);
bnet.CPD{B}=tabular_CPD(bnet,B,[0.70,0.40,0.30,0.60]);
bnet.CPD{E}=tabular_CPD(bnet,E,[1,0,0,0,0,1,1,1]);
bnet.CPD{P}=tabular_CPD(bnet,P,[0.95,0.02,0.05,0.98]);
bnet.CPD{D}=tabular_CPD(bnet,D,[0.9,0.2,0.3,0.1,0.1,0.8,0.7,0.9]);
draw_graph(dag)
