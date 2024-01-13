function hasCycle = check_cycle(adjacencyMatrix)
    % 创建图对象
    G = digraph(adjacencyMatrix);
    
    % 获取图的顶点数
    numVertices = numnodes(G);
    
    % 初始化访问状态和递归堆栈
    visited = false(numVertices, 1);
    recursionStack = false(numVertices, 1);
    
    % 深度优先搜索函数
    function result = dfs(node)
        visited(node) = true;
        recursionStack(node) = true;
        
        neighbors = successors(G, node);
        for i = 1:length(neighbors)
            neighbor = neighbors(i);
            
            % 如果邻居节点未被访问，则进行递归搜索
            if ~visited(neighbor)
                if dfs(neighbor)
                    result = true;
                    return;
                end
            elseif recursionStack(neighbor)
                % 如果邻居节点已经在递归堆栈中，则表示存在环路
                result = true;
                return;
            end
        end
        
        recursionStack(node) = false;
        result = false;
    end

    % 对每个节点进行深度优先搜索
    hasCycle = false;
    for node = 1:numVertices
        if ~visited(node)
            if dfs(node)
                hasCycle = true;
                return;
            end
        end
    end
end


