function  cv_ren =  crossval_ren(goal, classify_algorithm)

sample = size(goal,2);
switch classify_algorithm    
    case 'HOLD_OUT'
        cv = cvpartition(goal, 'HoldOut',1/3);%cvpartition 是一个用于创建交叉验证分区对象的函数。
        %它接受三个参数：数据集 goal、分区类型和测试集的比例。
    case 'CV-5'
        cv = cvpartition(goal, 'kfold',5);
    case 'CV-10'
        indices = ceil(10*(1:sample)/sample);
        %matlab中/不是取整，ceil（）实现了这个功能。将数据10等分10x（1~898）/898=1~10,每个样本所属区间的索引存在indices中
        cv_ren.NumTestSets = 10;%设置了交叉验证对象 cv_ren 的测试集数量为 10。
        %整个交叉验证过程将会进行 10 次，每次选择其中一份作为测试集，剩下的部分作为训练集。
        for i = 1:10  
            cv_ren.test(i,:) = logical(indices == i);%当您有数据要放入新的结构体中时，可以使用圆点表示法创建结构体
            %当索引值和当前i相等则置true那test矩阵中的第i行就记录了当前测试集的样本索引
            cv_ren.train(i,:)  = ~cv_ren.test(i,:);%不是测试集就当训练集
        end
    otherwise
        % error classify algorithm
        fprintf('%s classifier algorithm is not support',classify_algorithm);
        return;
end

end
