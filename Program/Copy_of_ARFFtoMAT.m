function matData=Copy_of_ARFFtoMAT(filename)
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
% 将 weka.core.Instances 对象转换为 MATLAB 的矩阵
numInstances = discretizedData.numInstances();
numAttributes = discretizedData.numAttributes();
matData = nan(numInstances, numAttributes);

for i = 1:numInstances
    instance = discretizedData.instance(i - 1);
    for j = 1:numAttributes
        if ~instance.isMissing(j - 1)
            matData(i, j) = instance.value(j - 1);
        end
    end
end
matData=matData+1;

% 指定保存位置和文件名
savePath = fullfile('C:\Users\小范\Desktop\学学\dataset1', [filename, '.csv']);
csvwrite(savePath, matData);
end
