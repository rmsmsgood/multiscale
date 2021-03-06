if length(ARGS) == 0
    push!(ARGS, "hard test")
    error("tag not found")
end # push!(ARGS, "")

if Sys.iswindows()
    try
        cd("E:/multiscale")
    catch
        cd("C:/multiscale")
    end
elseif Sys.islinux()
    cd("/home/ryu/multiscale")
end

@time using Statistics
@time using Base.Threads
@time using Dates
@time using Random
@time using Distances
@time using LinearAlgebra
@time using LightGraphs
@time using Distributions
@time using Plots

NOW = Dates.now()
println(Dates.now())
println("package loading complete")


function happen(threshold::Float64)
    if 0. <= threshold <= 1.
        return (rand(1)[1] < threshold)
    else
        throw("happen function error : wrong probability")
    end
end

function simulation(new_folder, seed, tag;
    σ = 0.5, β_A = 0.5, β_B = 0.001, p = 0.8, γ_A = 0.1,
    N = 3 * 10^5, hub = 30, backbone_size = 6000)

    m = 3 # number of new link, barabasi_albert
    m_0 = max(hub, m) # initial hub size, barabasi_albert

    Random.seed!(seed)
    if seed == 0
        report = open(new_folder * "/report " * string(seed) * ".txt", "a")

        println(report, "population = $N")
        println(report, "backbone size = $backbone_size")
        println(report, "m_0 = $m_0")
        println(report, "m = $m")
        println(report, "N = $N")
        println(report, "σ = $σ")
        println(report, "p = $p")
        println(report, "β_A = $β_A")
        println(report, "γ_A = $γ_A")
        println(report, "β_B = $β_B")
        println(report, "tag : $tag")

        time_histogram = open(new_folder * "/time_histogram " * string(seed) * ".csv", "a")
    end

    if seed < 1001
        time_evolution = open(new_folder * "/time_evolution " * string(seed) * ".csv", "a")
        println(time_evolution,"t, I_A, hub_S_B, R_B, V, hub_I_B, in_flux, out_flux, comp_I")
    end

    layerA = erdos_renyi(N, 2N)
    if hub > 0
        layerC = barabasi_albert(backbone_size, m_0, m, complete = true)
    else
        layerC = barabasi_albert(backbone_size, m, complete = true)
    end

    N = nv(layerA)
    M = nv(layerC)

    local stateA = ['S' for _ in 1:N]
    local stateB = ['S' for _ in 1:N]
    local location = [rand(1:M) for _ in 1:N]
    local host_ID = rand(1:N, 3)

    local hub_I = 0
    local comp_I = 0

    local hub_I_1 = 0
    local hub_I_2 = 0
    local hub_I_3 = 0
    local hub_I_4 = 0
    local hub_I_5 = 0
    local hub_I_6 = 0
    local hub_I_7 = 0
    local hub_I_8 = 0
    local hub_I_9 = 0
    local hub_I_10 = 0

    local from = 0
    local to = 0
    local in_flux = 0
    local out_flux = 0

    t = 0
    if seed == 0
        k_C = length.(layerC.fadjlist)
        k_C = replace(replace(string(k_C), "[" => ""), "]" => "")
        println(time_histogram, k_C)
    end

    # preiteration
    if σ != 0.0
        for t in (1:Int(round(10+3/(σ+0.05))))
            for i in (1:N)
                if happen(σ) & (Int64[] != layerC.fadjlist[location[i]])
                    location[i] = rand(layerC.fadjlist[location[i]])
                end
            end
        end
    end

    if seed == 0
        location[host_ID] .= 1
    end

    stateB[host_ID] .= 'I'
    stateA[host_ID] .= 'I'

    # while t < 30
    while sum(stateB .== 'I') != 0
        t = t + 1
        if t % 10 == 0 print('.') end

        in_flux = 0
        out_flux = 0

        if t != 1
            for i in (1:N)
                from = location[i]
                if happen(σ) & (Int64[] != layerC.fadjlist[location[i]])
                    location[i] = rand(layerC.fadjlist[location[i]])
                end
                to = location[i]

                if stateB[i] == 'I'
                    if (from ≤ 20) & (to ≥ 21)
                        out_flux += 1
                    elseif  (from ≥ 21) & (to ≤ 20)
                        in_flux += 1
                    end
                end
            end
        end

        if t == 1
            hub_I_1 = sum((stateB .== 'I') .& (location .< 21))
        elseif t == 2
            hub_I_2 = sum((stateB .== 'I') .& (location .< 21))
        elseif t == 3
            hub_I_3 = sum((stateB .== 'I') .& (location .< 21))
        elseif t == 4
            hub_I_4 = sum((stateB .== 'I') .& (location .< 21))
        elseif t == 5
            hub_I_5 = sum((stateB .== 'I') .& (location .< 21))
        elseif t == 6
            hub_I_6 = sum((stateB .== 'I') .& (location .< 21))
        elseif t == 7
            hub_I_7 = sum((stateB .== 'I') .& (location .< 21))
        elseif t == 8
            hub_I_8 = sum((stateB .== 'I') .& (location .< 21))
        elseif t == 9
            hub_I_9 = sum((stateB .== 'I') .& (location .< 21))
        elseif t == 10
            hub_I_10 = sum((stateB .== 'I') .& (location .< 21))
        end

        if seed < 1001
            k_B = [sum(location .== j) for j in 1:M]
            print(time_evolution, t, ", ")

            print(time_evolution, sum(stateA .== 'I'), ", ")

            print(time_evolution, sum((stateB .== 'S') .& (location .< 21)), ", ")
            print(time_evolution, sum(stateB .== 'R'), ", ")
            print(time_evolution, sum(stateB .== 'V'), ", ")

            print(time_evolution, sum((stateB .== 'I') .& (location .< 21)), ", ")
            print(time_evolution, in_flux, ", ")
            print(time_evolution, out_flux, ", ")
            print(time_evolution, sum((stateB .== 'I') .& (location .> 20)), "\n")
        end
        if seed == 0
            k_B = replace(replace(string(k_B), "[" => ""), "]" => "")
            println(time_histogram, k_B)
        end

        if hub > 0
        normalDist = Normal(0,0.05)
        uniformDdist = Uniform(0,1)

        for i in 1:hub
            walker = (1:N)[location .== i]
            if sum(stateB[walker] .== 'I') ≤ 0 continue end

            m = length(walker)
            coordinate = rand(uniformDdist, m, 2)
            for j in 1:5
                coordinate = mod.(coordinate + rand(normalDist, m, 2), 1)

                S = coordinate[(stateB[walker] .== 'S'),:]
                S_count = size(S,1)
                S_walker = walker[stateB[walker] .== 'S']
                I = coordinate[stateB[walker] .== 'I',:]
                I_count = size(I,1)

                D = zeros(S_count, I_count)
                for row in 1:S_count
                    for column in 1:I_count
                        D[row,column] = sum((S[row,:] .- I[column,:]).^2)
                    end
                end

                contact = 0.0 .< D .< 0.1
                # contact = 0.0 .< pairwise(Euclidean(), coordinate; dims=1) .< 0.2

                # 그림 그리기
                if (i ∈ location[host_ID]) & (seed == -1) & (t == 1)
                    shaping = Array{Symbol,1}(undef, m)
                    shaping[stateB[walker] .== 'R'] .= :xcross
                    shaping[stateB[walker] .== 'S'] .= :circle
                    shaping[stateB[walker] .== 'T'] .= :rect
                    shaping[stateB[walker] .== 'I'] .= :star5
                    coloring = Array{Symbol,1}(undef, m)
                    coloring[stateB[walker] .== 'R'] .= :black
                    coloring[stateB[walker] .== 'S'] .= :green
                    coloring[stateB[walker] .== 'T'] .= :orange
                    coloring[stateB[walker] .== 'I'] .= :red
                    png(plot(
                    coordinate[:,1], coordinate[:,2],
                    seriestype = :scatter,
                    size = (800,800),
                    xlims = (0,1),
                    ylims = (0,1),
                    markershape = shaping,
                    markercolor = coloring,
                    markersize = 8,
                    markerstrokecolor = :black,
                    legend = false
                    ), new_folder * "/" * "$j.png")
                end

                n_B = sum(contact, dims=2)[:,1]
                π_B = 1 .- (1 - β_B).^n_B
                infected = happen.(π_B)

                stateB[S_walker[infected]] .= 'T'
                stateA[walker[(stateA[walker] .== 'S') .& (stateB[walker] .== 'T')]] .= 'T'
            end
        end
        end

        local nA = [sum(stateA[layerA.fadjlist[i]] .== 'I') for i in 1:N]
        local π_A = [1 - (1 - β_A)^nA[i] for i in 1:N]

        local nB = [sum(stateB[location .== j] .== 'I') for j in 1:M]
        if hub==20 nB[1:20] .= 0 end
        local π_B = [1 - (1 - β_B)^nB[j] for j in 1:M]

        for i in (1:N)[
            ((π_A .+ π_B[location]) .> 0) .&
            ((stateA .== 'S') .| (stateB .== 'S'))]

            if (stateA[i] == 'S') & (stateB[i] == 'S')
                if happen(π_A[i]/(π_A[i] + π_B[location[i]]))
                    if happen(π_A[i])
                        stateA[i] = 'T'
                    end
                    if happen(p) & (stateA[i] == 'T')
                        stateB[i] = 'U'
                    end
                else
                    if happen(π_B[location[i]])
                        stateB[i] = 'T'
                        stateA[i] = 'T'
                    end
                end
            elseif (stateA[i] == 'I') & (stateB[i] == 'S')
                if happen(π_B[location[i]])
                    stateB[i] = 'T'
                    stateA[i] = 'T'
                end
            end
        end

        for i in (1:N)[(stateA .== 'I') .| (stateB .== 'V')]
            if happen(γ_A)
                if stateA[i] == 'I'
                    stateA[i] = 'S'
                end
                if stateB[i] == 'V'
                    stateB[i] = 'S'
                end
            end
        end

        stateA[stateA .== 'T'] .= 'I'
        stateB[stateB .== 'U'] .= 'V'

        stateB[stateB .== 'I'] .= 'R'
        stateB[stateB .== 'T'] .= 'I'
    end

    if seed == 0
        close(report)
        close(time_histogram)
    end
    if seed < 1001
        close(time_evolution)
    end

    hub_I_max = max(hub_I_1, hub_I_2, hub_I_3, hub_I_4, hub_I_5, hub_I_6, hub_I_7, hub_I_8, hub_I_9, hub_I_10)

    return [seed, t, sum(stateA .== 'I'), sum(stateB .== 'R'), sum(stateB .== 'V'), hub_I_max,
    hub_I_1, hub_I_2, hub_I_3, hub_I_4, hub_I_5, hub_I_6, hub_I_7, hub_I_8, hub_I_9, hub_I_10]
end

#---
itr_begin = 1
itr_end = 100
# itr_begin = itr_end = 0
println("itr : ", itr_end)
println("number of threads : ", nthreads())

#---

# seed = [0]
# new_folder = string(NOW)[3:10] * "@" * string(NOW)[12:13] * "-" *
#  string(NOW)[15:16] * " (" * string(seed[1]) * ")";
# mkdir(new_folder)
#
# global meta_data = open(new_folder * "/meta_data " * string(seed[1]) * ".csv", "a")
# println(meta_data,"seed, t, I_A, R_B, V, hub_I_max, hub_I_1, hub_I_2, hub_I_3, hub_I_4, hub_I_5, hub_I_6, hub_I_7, hub_I_8, hub_I_9, hub_I_10")
# close(meta_data)
#
# r = Array{Array{Int64,1},1}()
#
# itr_container = Array{Array{Int64,1},1}()
# let temp = Array{Int64,1}()
#     for i in itr_begin:itr_end
#         if ((i-1) % 100) == 0
#             push!(itr_container, temp)
#             temp = Array{Int64,1}()
#         end
#         push!(temp, i)
#     end
#     push!(itr_container, temp)
# end
# if itr_begin != itr_end itr_container[1] = [0] end
#
#
# @time for itr_block in itr_container
#     global meta_data = open(new_folder * "/meta_data " * string(seed[1]) * ".csv", "a")
#     @threads for j in itr_block
#         push!(r,simulation(new_folder, j, ARGS[1]))
#         println(meta_data, replace(replace(string(r[end]), "[" => ""), "]" => ""))
#         print("|")
#     end
#     println(itr_block[end])
#     close(meta_data)
# end
# println("")
#
# close(meta_data)

#---

# parameter_length = 20
parameter_begin = 0.2
parameter_end = 1.0
change = parameter_begin:0.05:parameter_end
seed = rand(10000:99999,length(change))
@time for t in 1:length(change)
    print(seed[t])

    new_folder = "p=" * string(change[t]) * "..." * string(NOW)[3:10] * "@" * string(NOW)[12:13] * "-" *
     string(NOW)[15:16] * " (" * string(seed[t]) * ")";
    mkdir(new_folder)

    global meta_data = open(new_folder * "/meta_data " * string(seed[1]) * ".csv", "a")
    println(meta_data,"seed, t, I_A, R_B, V, hub_I_max, hub_I_1, hub_I_2, hub_I_3, hub_I_4, hub_I_5, hub_I_6, hub_I_7, hub_I_8, hub_I_9, hub_I_10")
    close(meta_data)

    r = Array{Array{Int64,1},1}()

    itr_container = Array{Array{Int64,1},1}()
    let temp = Array{Int64,1}()
        for i in itr_begin:itr_end
            if ((i-1) % 100) == 0
                push!(itr_container, temp)
                temp = Array{Int64,1}()
            end
            push!(temp, i)
        end
        push!(itr_container, temp)
    end
    if itr_begin != itr_end itr_container[1] = [0] end

    @time for itr_block in itr_container
        global meta_data = open(new_folder * "/meta_data " * string(seed[1]) * ".csv", "a")
        @threads for j in itr_block
            push!(r,simulation(new_folder, j, ARGS[1], p = change[t]))
            println(meta_data, replace(replace(string(r[end]), "[" => ""), "]" => ""))
            print("|")
        end
        println(itr_block[end])
        close(meta_data)
    end
    println("")

    close(meta_data)
end
