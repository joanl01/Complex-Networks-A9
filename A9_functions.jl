# Function to add nodes and edges
function add_node_and_edge!(G, node_to_index, index_to_node, tea_name, attribute)
    if !haskey(node_to_index, tea_name)
        push!(index_to_node, tea_name)
        node_to_index[tea_name] = length(index_to_node)
        add_vertex!(G)
    end
    
    if !haskey(node_to_index, attribute)
        push!(index_to_node, attribute)
        node_to_index[attribute] = length(index_to_node)
        add_vertex!(G)
    end
    
    add_edge!(G, node_to_index[tea_name], node_to_index[attribute])
end


function recommend_tea(tea_name, G, node_to_index, index_to_node, top_n=3)
    tea_index = node_to_index[tea_name]
    neighbors = Graphs.neighbors(G, tea_index) 
    
    similarities = []
    for node in 1:nv(G)
        if node != tea_index && (index_to_node[node] in keys(node_to_index))
            common_neighbors = intersect(neighbors, Graphs.neighbors(G, node))  
            jaccard_similarity = length(common_neighbors) / length(union(neighbors, Graphs.neighbors(G, node))) 
            push!(similarities, (index_to_node[node], jaccard_similarity))
        end
    end
    
    similarities = sort(similarities, by=x->x[2], rev=true)
    return similarities[1:min(top_n, length(similarities))]
end


# Function to filter and return a single DataFrame based on a vector of tea names
function get_tea_rows(df::DataFrame, tea_names::Vector{String})
    # Filter the DataFrame to find the rows corresponding to the tea_names
    selected_teas = df[in(tea_names ,df."Tea Name"), :]
    
    return selected_teas
end
 



# Building a function that calculates the average node degree
function avg_node_degree(A)
    # input : an adjacency matrix

    # output : average node degree

    # Step 1: Sum each row to get the degree of each node
    node_degrees = sum(A, dims=2)
    # Step 2: Calculate the total degree
    total_degree = sum(node_degrees)
    # Step 3: Calculate the average node degree
    average_node_degree = total_degree / size(A, 1)
    return average_node_degree
end


# Functions:
# 1. depth first search of visited neighbours
function dfs(A, visited, node)
    # Get number of nodes
    n = size(A,1)
    # Mark the node in visited as true
    visited[node] = true
    # Loop through all the nodes to find nodes that are not in visited but is a neighbour 
    for k in 1:n
        if A[node, k] >= 1 && !visited[k]
            dfs(A, visited, k)
        end
    end
end


# 2. count connected components
function count_connected_components(A)
    n = size(A, 1)
    # Initialise the vector of visited as all falses
    visited = falses(n)
    # Start number of connected components at 0
    num_connected_components = 0
    # Check if the current node has not been visited yet
    # If it hasn't, it means it's the start of a new connected component
    for node in 1:n
        if !visited[node]
            #start another depth first search to find neighbours
            dfs(A, visited, node)
            num_connected_components += 1
        end
    end
    return num_connected_components
end


function calc_clustering(A)
    # input : an adjacency matrix

    # output : global clustering coefficient

    # Calculate the number of connected triples
    D = A^2 .- diagm(diag(A^2))  # Remove diagonals
    connected_triples = sum(D) / 2

    # Calculate the number of triangles
    triangles = sum(diag(A^3)) / 6

    # Calculate the clustering coefficient
    if connected_triples >= 1
        C = 3 * triangles / connected_triples
    else
        println("No")  
        # c=0 if no connected triples
        C = 0.0
        
    end    
    return C
end


# Define a custom layout function
function custom_layout(G)
    spring_layout(G)
end



