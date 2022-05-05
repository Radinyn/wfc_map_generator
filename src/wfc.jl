module MapGenerator

include("./tiles.jl")

println("⛬ Importing setup ...")
import .Setup

println("⛬ Importing Images.jl ...")
using Images

println("⛬ Importing DataStructures.jl ...")
using DataStructures

using Random

NEIGHBOUR_VERSION = false
MAX_DEPTH = 3

f0(a, b) = a*b
f1(a, b) = (a+b)/2
f2(a, b) = a^2 * b

g(x) = log(ℯ, 10*x)+4
f3(a, b) = a * max(0, g(b))/g(1)

activation(b) = (1-b^4)^(1/4)

saturation(a, b, factor = 4) = (max(1 - a^factor - b^factor, 0))^(1/factor)

function f4(a, b)
    s = saturation(a, b, 4)
    return (a*b)*s + a*(1-s)
end

f = NEIGHBOUR_VERSION ? f0 : f4

function add_probability(a::Vector{Float64}, b::Vector{Float64})
    v = a .* b
    v /= sum(v)
    return v
end

function aggregate_probability(a::Vector{Float64}, b::Vector{Float64})
    v = f.(a, b)
    v /= sum(v)
    return v
end

function get_propagation_value(weights)
    v = zeros(length(weights))
    for i in 1:length(weights)
        v = v .+ (Setup.PROBABILITIES[i]*weights[i])
    end
    v /= sum(v)
    return v
end

function get_diffused_propagation(i, depth)
    v = Vector{Vector{Float64}}()

    curr = Setup.PROBABILITIES[i]

    for i in 1:depth
        push!(v, curr)
        curr = get_propagation_value(curr)
    end

    return v
end

function get_ones_index(weights)
    for i in 1:length(weights)
        if weights[i] == 1
            return i
        end
    end
    return -1
end

function in_bounds(bounds, element)
    return (1 ≤ element[1] ≤ bounds[1]) && (1 ≤ element[2] ≤ bounds[2])
end

function get_neighbours(s, element)
    v = Vector{Tuple{Int64, Int64}}()

    moves = [ (1, 0), (0, 1), (-1, 0), (0, -1) ]
        
    for move in moves
        new = element .+ move
        if in_bounds(s, new)
            push!(v, new) 
        end
    end

    return v
end

function get_color(weights)
    for i in 1:length(weights)
        if weights[i] == 1
            return RGB(Setup.COLOR_MAP[i]...)
        end
    end

    return RGB(1, 0, 1)
    return RGB(122/255, 115/255, 114/255) # MOUNTAINS
end

#=
    Get the indiecies of an element that is most likely to collapse a certatin way
=#
function get_most_likely(matrix, collapsed)
    log2_fix(x) = x == 0 ? 0 : log2(x)
    entropy(weights) = log2(sum(weights)) - (sum(weights .* log2_fix.(weights))/sum(weights))
    f(i) = collapsed[i...] ? Inf64 : entropy(matrix[i...])
    n, m = size(matrix)

    min_val = f((1, 1))
    mins = Vector{Tuple{Int64, Int64}}()
    push!(mins, (1, 1))

    for i in 1:n
        for j in 1:m
            val = f((i, j))

            if min_val > val
                min_val = val
                mins = Vector{Tuple{Int64, Int64}}()
                push!(mins, (i, j))
            elseif min_val == val
                push!(mins, (i, j)) 
            end 
        end
    end

    return rand(mins)
end

#=
    Collapse a single element based on probabilities
=#
function collapse(weights)

    weights = cumsum(weights)
    r = rand()
    index = findfirst(weights .> r)

    new = zeros(length(weights))
    new[index] = 1

    return new
end

function force_collapse(index)
    new = zeros(length(Setup.PROBABILITIES))
    new[index] = 1
    return new
end

function get_probabilities(weights)
    for i in 1:length(weights)
        if weights[i] == 1
            return Setup.PROBABILITIES[i]
        end
    end
    return get_propagation_value(weights)
end

function get_noise(len)
    #return zeros(len)

    fmod(x) = mod(x, 0.1)
    return fmod.(rand(len))
end

function get_starting_matrix(s)
    matrix = [ deepcopy(Setup.BIOMS[1]) for i=1:s[1], j=1:s[2] ]
    len = length(Setup.BIOMS)
    r = min(s...)/2

    dist(x, y) = √( (x-floor(s[1]/2))^2 + (y-floor(s[2]/2))^2 )
    m0(x) = max(x, 0)

    for i in 1:s[1]
        for j in 1:s[2]
            for k in 2:len
                if dist(i, j) < r*((len-k+1)/len)
                    matrix[i, j] = deepcopy( m0.(normalise(Setup.BIOMS[k] - get_noise(length(Setup.BIOMS[k])))) )
                end
            
            end
        end
    end

    return matrix
end

#=
    Perform a breadth-first-search
    propagating the changes to probabilities
=#
function propagate!(matrix, collapsed, start)

    propagation_values = get_diffused_propagation(get_ones_index(matrix[start...]), MAX_DEPTH)

    s = size(matrix)
    q = Queue{Tuple{Tuple{Int64, Int64}, Int64}}()

    neighbours = get_neighbours(s, start)
    for neighbour in neighbours
        enqueue!(q, (neighbour, 1))
    end

    vis = falses(s)

    while !isempty(q)
        curr, d = dequeue!(q)

        if d > MAX_DEPTH
            continue
        end

        if !in_bounds(s, curr)
            continue
        end

        if vis[curr...]
            continue
        end

        vis[curr...] = true

        if !collapsed[curr...]

            if NEIGHBOUR_VERSION
                neighbours = get_neighbours(s, curr)

                probabs = [get_probabilities(matrix[neighbour...]) for neighbour in neighbours]

                for p in probabs
                    matrix[curr...] = aggregate_probability(matrix[curr...], p)
                end
            else
                matrix[curr...] = aggregate_probability(matrix[curr...], propagation_values[d])
            end

            for neighbour in neighbours
                enqueue!(q, (neighbour, d+1))
            end
        end
    end
end
#=
    1. Add beaches
    2. Blobify based on type # TODO
    3. Remove blobs of size < treshold # TODO
=#
function cleanup_outliers!(matrix)
    s = size(matrix)

    is_ocean(x) = (x[Setup.OCEAN] + x[Setup.DEEP_OCEAN]) ≈ 1

    for i in 1:s[1]
        for j in 1:s[2]
            if !is_ocean(matrix[i, j])
                if any(is_ocean(matrix[x...]) for x in get_neighbours(s, (i, j)))
                    matrix[i, j] = force_collapse(Setup.BEACH)
                end
            end
        end
    end

    #
end

#=
    Main WaveFunctionCollapse function
=#
function wave_function_collapse(s)
    Random.seed!(round(Int64, time()))
    matrix = get_starting_matrix(s)
    collapsed = falses(s)
    
    curr = (rand(1:s[1]), rand(1:s[2]))

    println("⛬ Starting collapsing ...")
    count = 0

    while !collapsed[curr...]
        matrix[curr...] = collapse(matrix[curr...])
        collapsed[curr...] = true
        propagate!(matrix, collapsed, curr)
        curr = get_most_likely(matrix, collapsed)
        count += 1

        if count % 1000 == 0
            println("⛬ Collapsed $(round(Int64, count*100/(s[1]*s[2])))% ...")
        end
    end

    cleanup_outliers!(matrix)

    return [ get_color(matrix[i, j]) for i=1:s[1], j=1:s[2] ]
end

#=
    Function that saves the image
=#
function generate_image(s, filepath)
    save(filepath, wave_function_collapse(s))
end

end