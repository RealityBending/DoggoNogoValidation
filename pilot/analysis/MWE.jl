# Activate: using Pkg; Pkg.activate(@__DIR__); cd(@__DIR__)
using Turing, StatsFuns
using SequentialSamplingModels
using Downloads, CSV, DataFrames


include(Downloads.download("https://raw.githubusercontent.com/RealityBending/scripts/main/data_poly.jl"))


@model function model_ExGaussian(rt, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    μ_intercept ~ Normal(0.3, 0.5)
    μ_isi1 ~ Normal(0, 0.5)
    μ_isi2 ~ Normal(0, 0.5)

    σ_intercept ~ Normal(-3, 3)  # Softplus
    σ_isi1 ~ Normal(0, 3)
    σ_isi2 ~ Normal(0, 3)

    τ_intercept ~ Normal(-3, 3)  # Softplus
    τ_isi1 ~ Normal(0, 3)
    τ_isi2 ~ Normal(0, 3)

    # Priors - Random Effects
    μ_intercept_random_sd ~ truncated(Normal(0.0, 0.3), 0.0, Inf)
    μ_isi1_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)
    μ_isi2_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)
    σ_intercept_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)
    σ_isi1_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)
    σ_isi2_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)
    τ_intercept_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)
    τ_isi1_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)
    τ_isi2_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)

    # Participant-level priors
    μ_intercept_random ~ filldist(Normal(0, μ_intercept_random_sd), n)
    μ_isi1_random ~ filldist(Normal(0, μ_isi1_random_sd), n)
    μ_isi2_random ~ filldist(Normal(0, μ_isi2_random_sd), n)
    σ_intercept_random ~ filldist(Normal(0, σ_intercept_random_sd), n)
    σ_isi1_random ~ filldist(Normal(0, σ_isi1_random_sd), n)
    σ_isi2_random ~ filldist(Normal(0, σ_isi2_random_sd), n)
    τ_intercept_random ~ filldist(Normal(0, τ_intercept_random_sd), n)
    τ_isi1_random ~ filldist(Normal(0, τ_isi1_random_sd), n)
    τ_isi2_random ~ filldist(Normal(0, τ_isi2_random_sd), n)

    for i in 1:length(rt)
        # Compute μ
        μ = μ_intercept + μ_intercept_random[participant[i]]
        μ += (μ_isi1 + μ_isi1_random[participant[i]]) * isi[i, 1]
        μ += (μ_isi2 + μ_isi2_random[participant[i]]) * isi[i, 2]

        # Compute σ
        σ = σ_intercept + σ_intercept_random[participant[i]]
        σ += (σ_isi1 + σ_isi1_random[participant[i]]) * isi[i, 1]
        σ += (σ_isi2 + σ_isi2_random[participant[i]]) * isi[i, 2]

        # Compute τ
        τ = τ_intercept + τ_intercept_random[participant[i]]
        τ += (τ_isi1 + τ_isi1_random[participant[i]]) * isi[i, 1]
        τ += (τ_isi2 + τ_isi2_random[participant[i]]) * isi[i, 2]

        rt[i] ~ ExGaussian(μ, softplus(σ), softplus(τ))
    end
end

function model_ExGaussian(rt, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2; orthogonal=true)  # Transform ISI into polynomials
    ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
    n = length(unique(participant))

    return model_ExGaussian(rt, isi2, ppt_id, min_rt, n)
end




# Sampling ----------------------------------------------------------------------------------------
df = CSV.read(Downloads.download("https://raw.githubusercontent.com/RealityBending/DoggoNogo/main/study1/data/data_game.csv"), DataFrame)

fit = model_ExGaussian(df.RT[1:50], df.ISI[1:50], df.Participant[1:50])
posteriors = sample(fit, NUTS(), 200)

pred1 = predict(model_ExGaussian(fill(missing, length(df.ISI)), df.ISI, df.Participant; min_rt=minimum(df.RT)), posteriors)

names(pred1)
size(Array(pred1))
length(df.ISI)

