clear all;
N=4;
dag=zeros(N,N);%无向环用矩阵表示
C=1;S=2;R=3;W=4;%按拓扑矩阵给各个节点编号,方便下一步赋值
dag(C,[R S])=1;%按逻辑关系赋值
dag([S R],W)=1;
discrete_nodes = 1:N;%定义类型
node_sizes = 2*ones(1,N);%分配大小
bnet=mk_bnet(dag,node_sizes,'names',{'C','S','R','W'},'discrete',discrete_nodes);%创建网络
%dag:有向无环图，node_size：节点可以取值的数量例如好/坏两种，names：节点名字，string，
%discrete：离散型随机变量discrete_node：离散节点个数equiv_class：表示节点从CPD获得参数
%{}表示cell数组
bnet.CPD{C}=tabular_CPD(bnet,C,[0.5 0.5]);%赋上各个事件的概率值,CPD:条件概率分布，CPT：条件概率表
bnet.CPD{S}=tabular_CPD(bnet,S,[0.5 0.9 0.5 0.1]);
bnet.CPD{R}=tabular_CPD(bnet,R,[0.8 0.2 0.2 0.8]);
bnet.CPD{W}=tabular_CPD(bnet,W,[1.0 0.1 0.1 0.01 0 0.9 0.9 0.99]);
draw_graph(dag) %绘制出贝叶斯网络图


engine=jtree_inf_engine(bnet); %J树，贝叶斯网络，创建一个"引擎"
evidence=cell(1,N);
evidence{W}=2;%计算当观察到玻璃是湿的时候，下雨的可能性有多大
[engine,loglik]=enter_evidence(engine,evidence);
m=marginal_nodes(engine,C);
bar(m.T)%m.T
