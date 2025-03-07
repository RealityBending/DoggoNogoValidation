# Activate: using Pkg; Pkg.activate(@__DIR__); cd(@__DIR__)
using CSV
using DataFrames
using Downloads
using Serialization
using ParetoSmooth
# using Turing
# using Pigeons
# using SequentialSamplingModels
# using StatsModels
# using Plots
using CairoMakie

include("1_models_definition.jl")

include(Downloads.download("https://raw.githubusercontent.com/RealityBending/scripts/main/data_grid.jl"))


df = CSV.read(Downloads.download("https://raw.githubusercontent.com/RealityBending/DoggoNogo/main/study1/data/data_game.csv"), DataFrame)
df.ppt = [findfirst(ppt .== unique(df.Participant)) for ppt in df.Participant]
df = df[df.Session.=="S1", :]

cd(@__DIR__)  # pwd()

objects = (
    Linear=Serialization.deserialize("models/Linear.turing"),
    Gaussian=Serialization.deserialize("models/Gaussian.turing"),
    ExGaussian=Serialization.deserialize("models/ExGaussian.turing"),
    LogNormal=Serialization.deserialize("models/LogNormal.turing"),
    InverseGaussian=Serialization.deserialize("models/InverseGaussian.turing"),
    Weibull=Serialization.deserialize("models/Weilbull.turing"),
    LogWeibull=Serialization.deserialize("models/LogWeibull.turing"),
    InverseWeibull=Serialization.deserialize("models/InverseWeibull.turing"),
    Gamma=Serialization.deserialize("models/Gamma.turing"),
    InverseGamma=Serialization.deserialize("models/InverseGamma.turing"),
    LNR=Serialization.deserialize("models/LNR.turing"),
    LBA=Serialization.deserialize("models/LBA.turing"),
    RDM=Serialization.deserialize("models/RDM.turing"),
)



colors = (
    Linear="#1A237E",
    Gaussian="#3F51B5",
    ExGaussian="#2196F3",
    LogNormal="#03A9F4",
    InverseGaussian="#00BCD4",
    Weibull="#FF5722",
    LogWeibull="#F44336",
    InverseWeibull="#E91E63",
    Gamma="#9C27B0",
    InverseGamma="#673AB7",
    LNR="#CDDC39",
    LBA="#FFEB3B",
    RDM="#FFC107",
)



# Durations -------------------------------------------------------------------------------------
order = sortperm([o["duration"] for o in values(objects)])
xaxis = [String(k) for k in keys(objects)][order]

f = Figure(size=(1200, 600))
ax = Axis(f[1, 1], title="Duration", xticks=(1:length(xaxis), xaxis), yscale=Makie.pseudolog10)
ax.yticks = [0, 0.5, 1, 2, 3, 5, 10, 20]
for (i, k) in enumerate(keys(objects))
    CairoMakie.barplot!(ax, findfirst(order .== i), objects[k]["duration"] / 60, color=colors[k], label=String(k))
end
f
save("models/241205_duration_mooncake.png", f)

# Posteriors -------------------------------------------------------------------------------------
f = Figure(size=(3000, 6000))
for (i, k) in enumerate(keys(objects))
    post = DataFrame(objects[k]["posteriors"])
    params = names(post)[occursin.(r"(?=.*[μστνααθkA])(?!.*\[)", names(post))]
    for (j, p) in enumerate(params)
        ax = Axis(f[j*2, i], title=p, ylabel="Density")
        CairoMakie.density!(ax, post[:, p], color=colors[k])
        ax = Axis(f[j*2+1, i], title=p, ylabel="Value")
        CairoMakie.lines!(post[:, p], color=colors[k])
    end
end
f
save("models/posteriors.png", f)


# Parameters =====================================================================================
# PP Check --------------------------------------------------------------------------------------
# info = objects[:RDM]
# data = df
# data = DataFrame(ISI=data_grid(df.ISI; n=20))
function make_predictions(data, info, df)
    # Generate predictions
    if "Participant" ∈ names(data)
        model_pred = MODELS[info["model"]]([missing for i in 1:length(data.ISI)], data.ISI, data.Participant; min_rt=minimum(df.RT))
    else
        model_pred = MODELS[info["model"]]([missing for i in 1:length(data.ISI)], data.ISI, nothing; min_rt=minimum(df.RT))

        # Extract parameters
        params = generated_quantities(model_pred, info["posteriors"])
        for p in keys(params[1])
            data[!, p] = vec(median(hcat([params[i][p] for i in 1:length(params)]...), dims=2))
        end
    end
    pred = predict(model_pred, info["posteriors"])


    # Format predictions
    if info["model"] ∈ Set(["model_LBA", "model_LNR", "model_RDM"])
        pred = Array(pred)[:, 2:2:end]
    else
        pred = Array(pred)
    end
    # Select random rows from Matrix
    # pred = pred[sample(1:size(pred, 1), 400; replace=false), :]
    return pred, data
end


function make_ppcheck(df, info, f, i; color="orange")
    pred, _ = make_predictions(df, info, df)

    # Make figure
    ax = Axis(f[i, 1], title=replace(info["model"], "model_" => ""), ylabel="Density")
    CairoMakie.density!(ax, df.RT, color="black")
    for i in 1:size(pred, 1)
        CairoMakie.density!(ax, pred[i, :], color=(:black, 0), strokecolor=(color, 0.05), strokewidth=1)
    end
    CairoMakie.xlims!(ax, (0, 1))
    return f
end

f = Figure(size=(1200, 1200))
for (i, k) in enumerate(keys(objects))
    f = make_ppcheck(df, objects[k], f, i; color=colors[i])
end
f

# ISI -------------------------------------------------------------------------------------------
function make_effectISI(df, info, f, i; color="orange")
    grid = DataFrame(ISI=data_grid(df.ISI; n=20))
    pred, _ = make_predictions(grid, info, df)

    xaxis = collect(1:nrow(grid)) * 10  # So that each distribution is separated

    xticks = range(minimum(xaxis), maximum(xaxis), length=6)
    xlabels = string.(round.(range(minimum(grid.ISI), maximum(grid.ISI), length=6); digits=2))
    ax = Axis(f[i, 2], title=replace(info["model"], "model_" => ""), xticks=(xticks, xlabels))
    for (i, isi) in enumerate(grid.ISI)
        CairoMakie.density!(ax, pred[:, i], offset=i * 10, direction=:y,
            # color=:y, colormap=:thermal, colorrange=(0, 1))
            color=(:darkgrey, 0.8))
    end
    lines!(ax, xaxis, vec(median(pred, dims=1)), color=color)
    CairoMakie.ylims!(ax, (0.1, 0.6))
    f
    return f
end

# f = Figure()
for (i, k) in enumerate(keys(objects))
    f = make_effectISI(df, objects[k], f, i; color=colors[i])
end
f


# Parameters -------------------------------------------------------------------------------------
function make_paramsISI(df, info, f, i; color="orange")
    grid = DataFrame(ISI=data_grid(df.ISI; n=20))
    pred, params = make_predictions(grid, info, df)

    pnames = names(params)[occursin.(r"(?=.*[μστνααθ])(?!.*\[)", names(params))]
    for (j, p) in enumerate(pnames)
        if j == 1
            ax = Axis(f[j, i], title=replace(info["model"], "model_" => ""), ylabel=p)
        else
            ax = Axis(f[j, i], ylabel=p)
        end
        CairoMakie.lines!(ax, grid.ISI, params[!, p], color=color)
    end
    return f
end

f = Figure(size=(1200, 1200))
for (i, k) in enumerate(keys(objects))
    f = make_paramsISI(df, objects[k], f, i; color=colors[i])
end
f

# Comparison =====================================================================================
# - cv_elpd: The difference in total leave-one-out cross validation scores between models.
# - cv_avg: The difference in average LOO-CV scores between models.
# - weight: A set of Akaike-like weights assigned to each model, which can be used in pseudo-Bayesian model averaging.
# Akaike weights are can be used in model averaging. They represent the relative likelihood of a model.
# Interpretation: "The ExGaussian model has a 95% chance of being the best model."
psis = []
for (i, k) in enumerate(keys(objects))
    push!(psis, psis_loo(objects[k]["fit"], objects[k]["posteriors"]; source="mcmc"))
end
rez = loo_compare(psis..., model_names=keys(objects))
rez

dat = DataFrame(rez.estimates)
dat = dat[dat.statistic.==:cv_elpd, :]
dat.relative = (dat.value .- minimum(dat.value)) ./ abs(minimum(dat.value))

f_comp = Figure()
ax = Axis(f_comp[1, 1], title="Performance", xticks=(1:length(dat.model), String.(dat.model)))
for (i, k) in enumerate(dat.model)
    CairoMakie.barplot!(ax, i, dat.relative[i], color=colors[k], label=String(k))
end
f_comp


# # Bayes factors
# mll_exg = stepping_stone(pt_exg)
# mll_wald = stepping_stone(pt_wald)

# # The BF is obtained by exponentiating the difference between marginal log likelihoods.
# bf = exp(mll_exg - mll_wald)