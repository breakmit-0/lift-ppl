
function [oa, ob] = find(Obstacles)
    import util.*;

    tic

    min_convexity = sdpvar(1,1);

    N = size(Obstacles, 1); % nombre d'obstacles
    D = Obstacles(1).Dim; % dimension de l'espace
    

    a = sdpvar(N, D);
    b = sdpvar(N, 1);
   
    % vectors of every variable sequentially
    % find a_i at index 1 + (D+1)*(i-1)
    % find b_i at index (D+1)*i - 1
    % length is N * (D+1) + 1
    e_ab = reshape(cat(2, a, b)', [], 1);
    e = cat(1, e_ab, min_convexity);


    N_constr = 0;
    for obs = 1:N
        N_constr = N_constr + (N-1) * size(Obstacles(obs).V, 1);
    end

    cmat = zeros(N_constr, N * (D+1) + 1);
    i = 0;

    for obs = 1:N
        
        for vertex_id = 1:size(Obstacles(obs).V, 1)
            vertex = Obstacles(obs).V(vertex_id, :)';

            assert_shape(vertex, [D 1]);
            for other = 1:N
                if other ~= obs
                    
                    i = i+1;

                    cmat(i, (D+1)*obs) = 1;
                    cmat(i, (D+1)*other) = -1;
                    cmat(i, (D+1)*(obs-1)+1 : (D+1)*(obs-1)+D) = vertex';
                    cmat(i, (D+1)*(other-1)+1 : (D+1)*(other-1)+D) = -vertex';
                    cmat(i, (D+1) * N + 1) = -1;
                    
                end
            end
        end
        fprintf("done #%d\n", obs);
    end
    
    assert(i == N_constr);

    dt = toc;
    fprintf("constraint constr time = %d\n", dt);
    tic;

    constraints = cmat * e >= 0;

    dt = toc;
    fprintf("constraint time = %d\n", dt);
    tic
        
    e = cat(2, a, b);
    opt = sdpsettings();
    diag = optimize(constraints, -min_convexity, []);
  
    dt = toc;

    disp(diag);
    fprintf("success = %d\n", diag.problem)
    fprintf("convexity = %d\n", value(min_convexity));
    fprintf("opt time = %d\n", dt);

    % disp(diag);
    %
    % disp(value(a));
    % disp(value(b));
    % disp(value(min_convexity));

    %optimize(constraints, norm(b) + norm(a));
    oa = value(a);
    ob = value(b);
    % os = value(s);
end
