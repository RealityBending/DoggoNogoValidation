# Activate: using Pkg; using Revise; Pkg.activate(@__DIR__); cd(@__DIR__)
using Random
using DataFrames, CSV
using Serialization

include("1_models_definition.jl")
include(Downloads.download("https://raw.githubusercontent.com/RealityBending/scripts/main/data_poly.jl"))


# Data Preparaation ================================================================================
cd(@__DIR__)  # pwd()
df = CSV.read(Downloads.download("https://raw.githubusercontent.com/RealityBending/DoggoNogoValidation/main/pilot/data/data_game.csv"), DataFrame)
df = df[df.Session.=="S1", :]

# participants = [findfirst(ppt .== unique(df.Participant)) for ppt in df.Participant]  # Convert Participant to Integers
# isi = data_poly(df.ISI, 2; orthogonal=true)  # Transform ISI into polynomials
# fit = model_Gaussian(df.RT, df.ISI, df.Participant)
# sample(fit, NUTS(; init_ϵ=0.0001), 400)
# =================================================================================================
# Sampling ----------------------------------------------------------------------------------------
# =================================================================================================
function sample_and_save(m, df, name="name"; pt=false, optim=false)
    println(name)
    t0 = time()
    if any([occursin(x, name) for x in ["LBA", "LNR", "RDM"]])  # Needs choice variable
        fit = m([(choice=1, rt=df.RT[i]) for i in 1:length(df.RT)], min_rt=minimum(df.RT), isi=df.ISI)
    elseif name ∈ ["Gaussian"]
        fit = m(df.RT, df.ISI, df.Participant; min_rt=minimum(df.RT))
    else
        fit = m(df.RT, min_rt=minimum(df.RT), isi=df.ISI)
    end

    # Optimization
    if optim == true
        # MAP
        estim = maximum_a_posteriori(fit)
        # estim = maximum_likelihood(fit)
        map = StatsModels.coeftable(estim)
        initial_params = estim.values.array
    else
        map = false
        initial_params = nothing
    end

    if pt == false
        # Pathfinder
        # pf = pathfinder(fit; ndraws=200)
        # init_params = pf.draws_transformed.value[:, :, 1]
        # posteriors = sample(fit, NUTS(), 400; init_params=d)

        # MCMC
        # posteriors = sample(fit, NUTS(), MCMCThreads(), 200, 8)
        # posteriors = sample(fit, NUTS(; init_ϵ=0.0001, adtype=AutoMooncake(; config=nothing)), 400; initial_params=initial_params)
        posteriors = sample(fit, NUTS(), 400; initial_params=initial_params)
        # posteriors = sample(fit, NUTS(; init_ϵ=0.0001), 400; initial_params=initial_params)
        # posteriors = sample(fit, externalsampler(MCHMC(200, 0.01; adaptive=true)), 200)
    else
        pt = pigeons(target=TuringLogPotential(fit);
            record=[Pigeons.traces],
            n_rounds=8,
            # n_chains=10,
            # checkpoint=true,
            multithreaded=true,
            # explorer=AutoMALA(),
            seed=123)
        posteriors = Chains(pt)
    end
    duration = (time() - t0) / 60
    # See https://github.com/TuringLang/Turing.jl/issues/2309
    out = Dict("fit" => fit, "model" => "model_" * name, "pt" => pt, "posteriors" => posteriors, "duration" => duration)
    Serialization.serialize("models/" * name * ".turing", out)
    return out
end






Random.seed!(123)


gaussian = sample_and_save(model_Gaussian, df, "Gaussian"; pt=false, optim=false)
exgaussian = sample_and_save(model_ExGaussian, df, "ExGaussian"; pt=false)
lognormal = sample_and_save(model_LogNormal, df, "LogNormal"; pt=false)
inversegaussian = sample_and_save(model_InverseGaussian, df, "InverseGaussian"; pt=false)
weibull = sample_and_save(model_Weilbull, df, "models/Weilbull"; pt=false)
logweibull = sample_and_save(model_LogWeibull, df, "models/LogWeibull"; pt=false)
inverseweibull = sample_and_save(model_InverseWeibull, df, "models/InverseWeibull"; pt=false)
gamma = sample_and_save(model_Gamma, df, "models/Gamma"; pt=false)
inversegamma = sample_and_save(model_InverseGamma, df, "models/InverseGamma"; pt=false)
lnr = sample_and_save(model_LNR, df, "models/LNR"; pt=false)
lba = sample_and_save(model_LBA, df, "models/LBA"; pt=false)
rdm = sample_and_save(model_RDM, df, "models/RDM"; pt=false)


# Test
m = model_Gaussian
gaussian["duration"]
gaussian["map"]

StatsPlots.plot(gaussian["posteriors"]; size=(1000, 2000))


# Table ------------------------------------------------------------------------------------------

include(Downloads.download("https://raw.githubusercontent.com/RealityBending/scripts/main/p_direction.jl"))


p = DataFrame(summarystats(gaussian["posteriors"]))
p = p[:, [:parameters, :mean, :std]]
p[:, :pd] = [p_direction(DataFrame(gaussian["posteriors"])[:, c]) for c in p.parameters]
p[:, :sig] = ifelse.(p.pd .> 0.95, "*", "")
p

# Reliability -------------------------------------------------------------------------------------
draws = DataFrame(gaussian["posteriors"])
colnames = [replace(c, "_random_sd" => "") for c in names(select(draws, Regex("_random_")))]

reliability = DataFrame()
for param in colnames

    ind = select(draws, Regex("$(param)_random\\["))
    var_means = std([mean(c) for c in eachcol(ind)])
    mean_var = mean([std(c) for c in eachcol(ind)])

    rez = DataFrame(
        Parameter=[param],
        Posterior_SD=mean(draws[!, Symbol(param * "_random_sd")]),
        SD_of_Means=[var_means],
        Mean_of_SDs=[mean_var],
        Reliability=[var_means / mean_var]
    )
    append!(reliability, rez)
end
reliability