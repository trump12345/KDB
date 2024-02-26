function visited_nodes = dfs(adj_matrix, start_node)
%input:领接矩阵，开始节点
%output：从初始节点深度优先遍历的节点数组
    n = size(adj_matrix, 1);
    visited = false(1, n);
    visited_nodes = []; % 新增的数组，用于记录被访问的节点

    [visited, visited_nodes] = dfs_search(adj_matrix, start_node, visited, visited_nodes);
end

function [visited, visited_nodes] = dfs_search(adj_matrix, node, visited, visited_nodes)
    visited(node) = true;
    visited_nodes = [visited_nodes, node]; % 将被访问的节点加入数组
    
    disp(['Visited node: ', num2str(node)]);
    
    for adj = 1:length(adj_matrix(node, :))
        if adj_matrix(node, adj) == 1 && ~visited(adj)
            [visited, visited_nodes] = dfs_search(adj_matrix, adj, visited, visited_nodes); % 更新visited_nodes
        end
    end
end
