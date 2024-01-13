function matData=ARFFtoMAT(filename)
%读取arff文件完成缺失值填充，并对连续数据离散化，离散值为5
%并对其中离散化后的数据进行离散编码。
%input：文件路径
%output：matlab格式的编码矩阵

data = loadARFF(filename);
import weka.filters.unsupervised.attribute.Discretize;
import weka.core.Instances;
import weka.filters.Filter;
import weka.filters.unsupervised.attribute.ReplaceMissingValues;
import weka.core.converters.ConverterUtils.DataSource.*;
import weka.core.Instance;


% 创建ReplaceMissingValues对象
replaceMissing = Filter.makeCopy(ReplaceMissingValues());

% 应用过滤器
replaceMissing.setInputFormat(data);
data = Filter.useFilter(data, replaceMissing);
% 创建离散化过滤器并设置参数
discretizer = Discretize();
discretizer.setInputFormat(data);
discretizer.setOptions(weka.core.Utils.splitOptions('-B 5'));

% 应用离散化过滤器
discretizedData = weka.filters.Filter.useFilter(data, discretizer);
[matData,featureNames] =  weka2matlab(discretizedData);
%[mdata, featureNames, targetNDX, stringVals, relationName] = weka2matlab(discretizedData);

matData=[featureNames;num2cell(matData)];
matData=cell2table(matData);
%保存为xls文件
[filename, pathname] = uiputfile('*.xlsx','Save as');
% 如果取消了保存操作，则退出
if isequal(filename, 0) || isequal(pathname, 0)
    disp('保存操作已取消');
    return;
end
% 构建完整的文件路径
fullpath = fullfile(pathname, filename);
% 使用 writematrix 函数将矩阵保存为 Excel 文件
 writetable(matData, fullpath,'WriteVariableNames', false);
end
