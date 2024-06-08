function out = edges_to_graph(edges)
    % EDGES_TO_GRAPH Convert a column vector of edges to a graph
    %
    % Params:
    %     edges: colun vector of edges
    %
    % Returns:
    %     out: a graph

    EPS = 0.001;

    N = size(edges, 1);
    dim = edges.Dim;

    vertices = zeros(N, dim);

    % len / dim should be a decent guess for number of actual edges
    % although a slight underestimate as world edges are not duplicated
    num_edges = zeros(N, 2, "uint32");

    storeV = 0;
    for i = 1:N
        edge = edges(i);
        V = graph.fast_vertices_of_edge(edge);

        if height(V) ~= 2
            fprintf("skipped %d with %d\n", i, size(V, 1));
            continue;
        end

        v1 = V(1, :);
        v2 = V(2, :);

        n1 = 0;
        n2 = 0;

        % fprintf("--\nstarting with %d vertices\n", size(vertices, 1));
        
        for j = 1:storeV
            if norm(v1 - vertices(j, :)) < EPS
                n1 = j;
            end
            if norm(v2 - vertices(j, :)) < EPS
                n2 = j;
            end
            if n1 > 0 && n2 > 0
                break;
            end
        end

        if n1 == 0
            storeV = storeV + 1;
            vertices(storeV, :) = v1;
            n1 = storeV;
            % fprintf("creating new for n1 (%d)\n", n1);
        end

        if n2 == 0
            storeV = storeV + 1;
            vertices(storeV, :) = v2;
            n2 = storeV;
            % fprintf("creating new for n2 (%d)\n", n2);
        end
   
        num_edges(i, 1) = min(n1, n2);
        num_edges(i, 2) = max(n1, n2);
    end
    
    vertices = vertices(1:storeV, :);
    edges = unique(num_edges, 'rows');

    sq_distances =  (vertices(edges(:,1), :) - vertices(edges(:,2), :) ).^2;
    distances = sqrt(sum(sq_distances, 2));

    node_data = table(vertices, 'VariableNames', {'position'});
    edge_table = table(edges, distances, 'VariableNames', {'EndNodes', 'Weight'});

    out = graph(edge_table, node_data);
end


