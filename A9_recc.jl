using DataFrames, XLSX, GraphPlot, Graphs, GraphIO, Random, Plots, GraphPlot, LinearAlgebra, Colors, SimpleWeightedGraphs, Compose

include("A9_functions.jl")

# Load the dataset
df = DataFrame(XLSX.readtable("T2_dataset.xlsx", "Sheet1"))

# Split the Ingredients using ; as a separator
df.Ingredients_Cleaned = [split(ingredients, "; ") for ingredients in df.Ingredients_Cleaned]

# Initialize a graph
G = SimpleGraph()

# Dictionaries to map node names to indices
node_to_index = Dict{String, Int}()
index_to_node = String[]


# Add nodes and edges
for row in eachrow(df)
    tea_name = row[:"Tea Name"]
    ingredients = row[:Ingredients_Cleaned]
    time_of_day = split(row[:Time_of_day], ";")
    enjoy_with = split(row[:enjoy_with], "; ")
    category = split(row[:Category], "; ")
    
    # Add edges for ingredients
    for ingredient in ingredients
        add_node_and_edge!(G, node_to_index, index_to_node, tea_name, ingredient)
    end
    
    # Add edges for time of day
    for time in time_of_day
        add_node_and_edge!(G, node_to_index, index_to_node, tea_name, strip(time))
    end
    
    # Add edges for enjoy with
    for enjoy in enjoy_with
        add_node_and_edge!(G, node_to_index, index_to_node, tea_name, strip(enjoy))
    end

    for cat in category
        add_node_and_edge!(G, node_to_index, index_to_node, tea_name, strip(cat))
    end
end

# Recommend teas similar to X'
recommendations = recommend_tea("iced", G, node_to_index, index_to_node)
println("Recommendations: ", recommendations)


num_rec_teas = size(recommendations,1)
reced_tea_v = String[]
prob = []
for i in 1:num_rec_teas
    reced_tea,prob = recommendations[i]
    push!(reced_tea_v,reced_tea )
end
reced_tea_v


# Create a mapping from tea names to node indices
tea_indices = Dict{String, Int}()
for (i, tea_name) in enumerate(df."Tea Name")
    tea_indices[tea_name] = i
end

print_index = zeros(Int,num_rec_teas)

for i in 1:num_rec_teas
    print_index[i] = tea_indices[reced_tea_v[i]]
end

tea_indices["Melbourne Breakfast "]
print_index
df[58,:]
print(df[print_index,:],)

df = DataFrame(XLSX.readtable("T2_dataset.xlsx", "Sheet1"))

# Extract unique ingredients, teas, enjoy_with, time_of_day, and category
ingredients = unique(vcat([split(ingredients, "; ") for ingredients in df.Ingredients_Cleaned]...))
teas = unique(df[!, "Tea Name"])
enjoy_with = unique(vcat([split(enjoy_with, "; ") for enjoy_with in df.enjoy_with]...))
time_of_day = unique(vcat([split(time_of_day, "; ") for time_of_day in df.Time_of_day]...))
category = unique(vcat([split(cat, "; ") for cat in df.Category]...))

# Define color mappings
ingredient_color = colorant"red"     # red
tea_color = RGB(0, 0, 1)             # blue
enjoy_with_color = colorant"green"     # green
time_of_day_color = RGB(1, 0.5, 0)   # orange
category_color = RGB(0.5, 0, 0.5)    # purple

# Create a color vector based on node membership
color_vector = [ingredient_color for _ in 1:nv(G)]  # Initialize with ingredient color

# Update colors based on membership
for (node, index) in node_to_index
    if node in ingredients
        color_vector[index] = ingredient_color
    elseif node in teas
        color_vector[index] = tea_color
    elseif node in enjoy_with
        color_vector[index] = enjoy_with_color
    elseif node in time_of_day
        color_vector[index] = time_of_day_color
    elseif node in category
        color_vector[index] = category_color
    end
end


layout=(args...)->spring_layout(args...; C=30)
white = colorant"white"
# gplot(G, layout = layout, nodelabel = index_to_node, NODELABELSIZE = 1, nodefillc =color_vector, background_color = white)
draw(PDF("plot.pdf", 10cm, 10cm), gplot(G, layout = layout, NODELABELSIZE = 1, nodefillc =color_vector))


el = collect(Graphs.edges(G))
num_nodes = Graphs.nv(G)
num_edges = Graphs.ne(G)

adj_matrix = zeros(num_nodes,num_nodes)

for i in 1:num_edges
    source = src(el[i])
    dest = dst(el[i])
    adj_matrix[source,dest]+=1
    adj_matrix[dest,source]+=1
end


avg_node_degree(adj_matrix)
count_connected_components(adj_matrix)
calc_clustering(adj_matrix)

betweenness_centrality(G)
findmax(betweenness_centrality(G))

index_to_node[11]

findmax(closeness_centrality(G))
index_to_node[11]

findmax(eigenvector_centrality(G))
index_to_node[11]

findmax(Graphs.pagerank(G, 0.85, 100, 1.0e-6))
index_to_node[11]
