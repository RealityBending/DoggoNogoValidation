# Activate: using Pkg; Pkg.activate(@__DIR__); cd(@__DIR__)
using Turing, StatsFuns
using SequentialSamplingModels
using Downloads


include(Downloads.download("https://raw.githubusercontent.com/RealityBending/scripts/main/data_poly.jl"))


# Normal ======================================================================================
# Linear ------------------------------------------------------------------------------------
@model function model_Linear(rt, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    μ_intercept ~ Normal(0.3, 0.5)
    μ_isi1 ~ Normal(0, 0.2)
    μ_isi2 ~ Normal(0, 0.2)

    σ ~ Normal(-3, 3)  # Softplus link

    # Priors - Random Effects
    μ_intercept_random_sd ~ truncated(Normal(0.0, 0.3), lower=0)
    μ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    μ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)

    # Participant-level priors
    if participant !== nothing
        μ_intercept_random ~ filldist(Normal(0, μ_intercept_random_sd), n)
        μ_isi1_random ~ filldist(Normal(0, μ_isi1_random_sd), n)
        μ_isi2_random ~ filldist(Normal(0, μ_isi2_random_sd), n)
    end

    # Track parameters
    tracked_μ = similar(rt, eltype(μ_intercept))
    tracked_σ = similar(rt, eltype(σ))

    for i in 1:length(rt)
        # Fixed effects
        μ = μ_intercept + μ_isi1 * isi[i, 1] + μ_isi2 * isi[i, 2]

        # Track
        tracked_μ[i] = μ
        tracked_σ[i] = softplus(σ)

        # Random effects
        if participant !== nothing
            μ = μ + μ_intercept_random[participant[i]] + μ_isi1_random[participant[i]] * isi[i, 1] + μ_isi2_random[participant[i]] * isi[i, 2]
        end

        # Likelihood
        rt[i] ~ Normal(μ, softplus(σ))
    end

    # Make parameters accessible
    return (μ=tracked_μ, σ=tracked_σ,)
end

function model_Linear(rt, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2)  # Transform ISI into polynomials
    if participant !== nothing
        ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
        n = length(unique(participant))
    else
        ppt_id = nothing
        n = 0
    end

    return model_Linear(rt, isi2, ppt_id, min_rt, n)
end


# Gaussian ------------------------------------------------------------------------------------
@model function model_Gaussian(rt, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    μ_intercept ~ Normal(0.3, 0.5)
    μ_isi1 ~ Normal(0, 0.2)
    μ_isi2 ~ Normal(0, 0.2)

    σ_intercept ~ Normal(-3, 3)  # Softplus link
    σ_isi1 ~ Normal(0, 3)
    σ_isi2 ~ Normal(0, 3)

    # Priors - Random Effects
    μ_intercept_random_sd ~ truncated(Normal(0.0, 0.3), lower=0)
    μ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    μ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)

    # Participant-level priors
    if participant !== nothing
        μ_intercept_random ~ filldist(Normal(0, μ_intercept_random_sd), n)
        μ_isi1_random ~ filldist(Normal(0, μ_isi1_random_sd), n)
        μ_isi2_random ~ filldist(Normal(0, μ_isi2_random_sd), n)
        σ_intercept_random ~ filldist(Normal(0, σ_intercept_random_sd), n)
        σ_isi1_random ~ filldist(Normal(0, σ_isi1_random_sd), n)
        σ_isi2_random ~ filldist(Normal(0, σ_isi2_random_sd), n)
    end

    # Track parameters
    tracked_μ = similar(rt, eltype(μ_intercept))
    tracked_σ = similar(rt, eltype(σ_intercept))

    for i in 1:length(rt)
        # Fixed effects
        μ = μ_intercept + μ_isi1 * isi[i, 1] + μ_isi2 * isi[i, 2]
        σ = σ_intercept + σ_isi1 * isi[i, 1] + σ_isi2 * isi[i, 2]

        # Track
        tracked_μ[i] = μ
        tracked_σ[i] = softplus(σ)

        # Random effects
        if participant !== nothing
            μ = μ + μ_intercept_random[participant[i]] + μ_isi1_random[participant[i]] * isi[i, 1] + μ_isi2_random[participant[i]] * isi[i, 2]
            σ = σ + σ_intercept_random[participant[i]] + σ_isi1_random[participant[i]] * isi[i, 1] + σ_isi2_random[participant[i]] * isi[i, 2]
        end

        # Likelihood
        rt[i] ~ Normal(μ, softplus(σ))
    end

    # Make parameters accessible
    return (μ=tracked_μ, σ=tracked_σ,)
end

function model_Gaussian(rt, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2)  # Transform ISI into polynomials
    if participant !== nothing
        ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
        n = length(unique(participant))
    else
        ppt_id = nothing
        n = 0
    end

    return model_Gaussian(rt, isi2, ppt_id, min_rt, n)
end




# Exgaussian ------------------------------------------------------------------------------------
@model function model_ExGaussian(rt, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    μ_intercept ~ Normal(0.3, 0.5)
    μ_isi1 ~ Normal(0, 0.2)
    μ_isi2 ~ Normal(0, 0.2)

    σ_intercept ~ Normal(-3, 3)  # Softplus
    σ_isi1 ~ Normal(0, 3)
    σ_isi2 ~ Normal(0, 3)

    τ_intercept ~ Normal(-3, 3)  # Softplus
    τ_isi1 ~ Normal(0, 3)
    τ_isi2 ~ Normal(0, 3)

    # Priors - Random Effects
    μ_intercept_random_sd ~ truncated(Normal(0.0, 0.3), lower=0)
    μ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    μ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)

    # Participant-level priors
    if participant !== nothing
        μ_intercept_random ~ filldist(Normal(0, μ_intercept_random_sd), n)
        μ_isi1_random ~ filldist(Normal(0, μ_isi1_random_sd), n)
        μ_isi2_random ~ filldist(Normal(0, μ_isi2_random_sd), n)
        σ_intercept_random ~ filldist(Normal(0, σ_intercept_random_sd), n)
        σ_isi1_random ~ filldist(Normal(0, σ_isi1_random_sd), n)
        σ_isi2_random ~ filldist(Normal(0, σ_isi2_random_sd), n)
        τ_intercept_random ~ filldist(Normal(0, τ_intercept_random_sd), n)
        τ_isi1_random ~ filldist(Normal(0, τ_isi1_random_sd), n)
        τ_isi2_random ~ filldist(Normal(0, τ_isi2_random_sd), n)
    end

    # Track parameters
    tracked_μ = similar(rt, eltype(μ_intercept))
    tracked_σ = similar(rt, eltype(σ_intercept))
    tracked_τ = similar(rt, eltype(τ_intercept))

    for i in 1:length(rt)
        # Fixed effects
        μ = μ_intercept + μ_isi1 * isi[i, 1] + μ_isi2 * isi[i, 2]
        σ = σ_intercept + σ_isi1 * isi[i, 1] + σ_isi2 * isi[i, 2]
        τ = τ_intercept + τ_isi1 * isi[i, 1] + τ_isi2 * isi[i, 2]

        # Track
        tracked_μ[i] = μ
        tracked_σ[i] = softplus(σ)
        tracked_τ[i] = softplus(τ)

        # Random effects
        if participant !== nothing
            μ = μ + μ_intercept_random[participant[i]] + μ_isi1_random[participant[i]] * isi[i, 1] + μ_isi2_random[participant[i]] * isi[i, 2]
            σ = σ + σ_intercept_random[participant[i]] + σ_isi1_random[participant[i]] * isi[i, 1] + σ_isi2_random[participant[i]] * isi[i, 2]
            τ = τ + τ_intercept_random[participant[i]] + τ_isi1_random[participant[i]] * isi[i, 1] + τ_isi2_random[participant[i]] * isi[i, 2]
        end

        # Likelihood
        rt[i] ~ ExGaussian(μ, softplus(σ), softplus(τ))
    end

    # Make parameters accessible
    return (μ=tracked_μ, σ=tracked_σ, τ=tracked_τ,)
end

function model_ExGaussian(rt, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2)  # Transform ISI into polynomials
    if participant !== nothing
        ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
        n = length(unique(participant))
    else
        ppt_id = nothing
        n = 0
    end

    return model_ExGaussian(rt, isi2, ppt_id, min_rt, n)
end


# LogNormal --------------------------------------------------------------------------------------
@model function model_LogNormal(rt, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    μ_intercept ~ Normal(0, 3)
    μ_isi1 ~ Normal(0, 0.3)
    μ_isi2 ~ Normal(0, 0.3)

    σ_intercept ~ Normal(-3, 3)  # softplus link
    σ_isi1 ~ Normal(0, 1)
    σ_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    # Priors - Random Effects
    μ_intercept_random_sd ~ truncated(Normal(0.0, 0.3), lower=0)
    μ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    μ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)

    # Participant-level priors
    if participant !== nothing
        μ_intercept_random ~ filldist(Normal(0, μ_intercept_random_sd), n)
        μ_isi1_random ~ filldist(Normal(0, μ_isi1_random_sd), n)
        μ_isi2_random ~ filldist(Normal(0, μ_isi2_random_sd), n)
        σ_intercept_random ~ filldist(Normal(0, σ_intercept_random_sd), n)
        σ_isi1_random ~ filldist(Normal(0, σ_isi1_random_sd), n)
        σ_isi2_random ~ filldist(Normal(0, σ_isi2_random_sd), n)
        τ_intercept_random ~ filldist(Normal(0, τ_intercept_random_sd), n)
        τ_isi1_random ~ filldist(Normal(0, τ_isi1_random_sd), n)
        τ_isi2_random ~ filldist(Normal(0, τ_isi2_random_sd), n)
    end

    # Track parameters
    tracked_μ = similar(rt, eltype(μ_intercept))
    tracked_σ = similar(rt, eltype(σ_intercept))
    tracked_τ = similar(rt, eltype(τ_intercept))

    for i in 1:length(rt)
        # Fixed effects
        μ = μ_intercept + μ_isi1 * isi[i, 1] + μ_isi2 * isi[i, 2]
        σ = σ_intercept + σ_isi1 * isi[i, 1] + σ_isi2 * isi[i, 2]
        τ = τ_intercept + τ_isi1 * isi[i, 1] + τ_isi2 * isi[i, 2]

        # Track
        tracked_μ[i] = μ
        tracked_σ[i] = softplus(σ)
        tracked_τ[i] = min_rt * logistic(τ)

        # Random effects
        if participant !== nothing
            μ = μ + μ_intercept_random[participant[i]] + μ_isi1_random[participant[i]] * isi[i, 1] + μ_isi2_random[participant[i]] * isi[i, 2]
            σ = σ + σ_intercept_random[participant[i]] + σ_isi1_random[participant[i]] * isi[i, 1] + σ_isi2_random[participant[i]] * isi[i, 2]
            τ = τ + τ_intercept_random[participant[i]] + τ_isi1_random[participant[i]] * isi[i, 1] + τ_isi2_random[participant[i]] * isi[i, 2]
        end

        # Likelihood
        rt[i] ~ ShiftedLogNormal(μ, softplus(σ), min_rt * logistic(τ))
    end

    # Make parameters accessible
    return (μ=tracked_μ, σ=tracked_σ, τ=tracked_τ,)
end


function model_LogNormal(rt, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2)  # Transform ISI into polynomials
    if participant !== nothing
        ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
        n = length(unique(participant))
    else
        ppt_id = nothing
        n = 0
    end

    return model_LogNormal(rt, isi2, ppt_id, min_rt, n)
end

# Inverse Gaussian (Wald) ------------------------------------------------------------------------------------------
@model function model_InverseGaussian(rt, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    ν_intercept ~ Normal(0, 1)
    ν_isi1 ~ Normal(0, 1)
    ν_isi2 ~ Normal(0, 1)

    α_intercept ~ Normal(0, 1)
    α_isi1 ~ Normal(0, 0.1)
    α_isi2 ~ Normal(0, 0.1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    # Priors - Random Effects
    ν_intercept_random_sd ~ truncated(Normal(0.0, 0.3), lower=0)
    ν_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    ν_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    α_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    α_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    α_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)

    # Participant-level priors
    if participant !== nothing
        ν_intercept_random ~ filldist(Normal(0, ν_intercept_random_sd), n)
        ν_isi1_random ~ filldist(Normal(0, ν_isi1_random_sd), n)
        ν_isi2_random ~ filldist(Normal(0, ν_isi2_random_sd), n)
        α_intercept_random ~ filldist(Normal(0, α_intercept_random_sd), n)
        α_isi1_random ~ filldist(Normal(0, α_isi1_random_sd), n)
        α_isi2_random ~ filldist(Normal(0, α_isi2_random_sd), n)
        τ_intercept_random ~ filldist(Normal(0, τ_intercept_random_sd), n)
        τ_isi1_random ~ filldist(Normal(0, τ_isi1_random_sd), n)
        τ_isi2_random ~ filldist(Normal(0, τ_isi2_random_sd), n)
    end

    # Track parameters
    tracked_ν = similar(rt, eltype(ν_intercept))
    tracked_α = similar(rt, eltype(α_intercept))
    tracked_τ = similar(rt, eltype(τ_intercept))

    for i in 1:length(rt)
        # Fixed effects
        ν = ν_intercept + ν_isi1 * isi[i, 1] + ν_isi2 * isi[i, 2]
        α = α_intercept + α_isi1 * isi[i, 1] + α_isi2 * isi[i, 2]
        τ = τ_intercept + τ_isi1 * isi[i, 1] + τ_isi2 * isi[i, 2]

        # Track
        tracked_ν[i] = softplus(ν)
        tracked_α[i] = softplus(α) + eps()
        tracked_τ[i] = min_rt * logistic(τ)

        # Random effects
        if participant !== nothing
            ν = ν + ν_intercept_random[participant[i]] + ν_isi1_random[participant[i]] * isi[i, 1] + ν_isi2_random[participant[i]] * isi[i, 2]
            α = α + α_intercept_random[participant[i]] + α_isi1_random[participant[i]] * isi[i, 1] + α_isi2_random[participant[i]] * isi[i, 2]
            τ = τ + τ_intercept_random[participant[i]] + τ_isi1_random[participant[i]] * isi[i, 1] + τ_isi2_random[participant[i]] * isi[i, 2]
        end

        # Likelihood
        rt[i] ~ Wald(softplus(ν), softplus(α) + eps(), min_rt * logistic(τ))
    end

    # Make parameters accessible
    return (ν=tracked_ν, α=tracked_α, τ=tracked_τ,)
end

function model_InverseGaussian(rt, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2)  # Transform ISI into polynomials
    if participant !== nothing
        ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
        n = length(unique(participant))
    else
        ppt_id = nothing
        n = 0
    end

    return model_InverseGaussian(rt, isi2, ppt_id, min_rt, n)
end


# Weibull ========================================================================================
# Weibull ----------------------------------------------------------------------------------------
@model function model_Weilbull(rt, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    α_intercept ~ Normal(0, 2)
    α_isi1 ~ Normal(0, 2)
    α_isi2 ~ Normal(0, 2)

    θ_intercept ~ Normal(0, 3)  # Log-link
    θ_isi1 ~ Normal(0, 1)
    θ_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    # Priors - Random Effects
    α_intercept_random_sd ~ truncated(Normal(0.0, 0.3), lower=0)
    α_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    α_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)

    # Participant-level priors
    if participant !== nothing
        α_intercept_random ~ filldist(Normal(0, α_intercept_random_sd), n)
        α_isi1_random ~ filldist(Normal(0, α_isi1_random_sd), n)
        α_isi2_random ~ filldist(Normal(0, α_isi2_random_sd), n)
        θ_intercept_random ~ filldist(Normal(0, θ_intercept_random_sd), n)
        θ_isi1_random ~ filldist(Normal(0, θ_isi1_random_sd), n)
        θ_isi2_random ~ filldist(Normal(0, θ_isi2_random_sd), n)
        τ_intercept_random ~ filldist(Normal(0, τ_intercept_random_sd), n)
        τ_isi1_random ~ filldist(Normal(0, τ_isi1_random_sd), n)
        τ_isi2_random ~ filldist(Normal(0, τ_isi2_random_sd), n)
    end

    # Track parameters
    tracked_α = similar(rt, eltype(α_intercept))
    tracked_θ = similar(rt, eltype(θ_intercept))
    tracked_τ = similar(rt, eltype(τ_intercept))

    for i in 1:length(rt)
        # Fixed effects
        α = α_intercept + α_isi1 * isi[i, 1] + α_isi2 * isi[i, 2]
        θ = θ_intercept + θ_isi1 * isi[i, 1] + θ_isi2 * isi[i, 2]
        τ = τ_intercept + τ_isi1 * isi[i, 1] + τ_isi2 * isi[i, 2]

        # Track
        tracked_α[i] = softplus(α) + eps()
        tracked_θ[i] = softplus(θ)
        tracked_τ[i] = min_rt * logistic(τ)

        # Random effects
        if participant !== nothing
            α = α + α_intercept_random[participant[i]] + α_isi1_random[participant[i]] * isi[i, 1] + α_isi2_random[participant[i]] * isi[i, 2]
            θ = θ + θ_intercept_random[participant[i]] + θ_isi1_random[participant[i]] * isi[i, 1] + θ_isi2_random[participant[i]] * isi[i, 2]
            τ = τ + τ_intercept_random[participant[i]] + τ_isi1_random[participant[i]] * isi[i, 1] + τ_isi2_random[participant[i]] * isi[i, 2]
        end

        # Likelihood
        rt[i] ~ LocationScale(min_rt * logistic(τ), 1, Weibull(softplus(α) + eps(), softplus(θ)))
    end

    # Make parameters accessible
    return (α=tracked_α, θ=tracked_θ, τ=tracked_τ,)
end

function model_Weilbull(rt, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2)  # Transform ISI into polynomials
    if participant !== nothing
        ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
        n = length(unique(participant))
    else
        ppt_id = nothing
        n = 0
    end

    return model_Weilbull(rt, isi2, ppt_id, min_rt, n)
end



# Log-Weibull (Gumbel) -------------------------------------------------------------------------
# https://en.wikipedia.org/wiki/Gumbel_distribution

@model function model_LogWeibull(rt, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    μ_intercept ~ Normal(0, 3)
    μ_isi1 ~ Normal(0, 0.3)
    μ_isi2 ~ Normal(0, 0.3)

    θ_intercept ~ Normal(0, 3)  # Log-link
    θ_isi1 ~ Normal(0, 1)
    θ_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    # Priors - Random Effects
    μ_intercept_random_sd ~ truncated(Normal(0.0, 0.3), lower=0)
    μ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    μ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)

    # Participant-level priors
    if participant !== nothing
        μ_intercept_random ~ filldist(Normal(0, μ_intercept_random_sd), n)
        μ_isi1_random ~ filldist(Normal(0, μ_isi1_random_sd), n)
        μ_isi2_random ~ filldist(Normal(0, μ_isi2_random_sd), n)
        θ_intercept_random ~ filldist(Normal(0, θ_intercept_random_sd), n)
        θ_isi1_random ~ filldist(Normal(0, θ_isi1_random_sd), n)
        θ_isi2_random ~ filldist(Normal(0, θ_isi2_random_sd), n)
        τ_intercept_random ~ filldist(Normal(0, τ_intercept_random_sd), n)
        τ_isi1_random ~ filldist(Normal(0, τ_isi1_random_sd), n)
        τ_isi2_random ~ filldist(Normal(0, τ_isi2_random_sd), n)
    end

    # Track parameters
    tracked_μ = similar(rt, eltype(μ_intercept))
    tracked_θ = similar(rt, eltype(θ_intercept))
    tracked_τ = similar(rt, eltype(τ_intercept))

    for i in 1:length(rt)
        # Fixed effects
        μ = μ_intercept + μ_isi1 * isi[i, 1] + μ_isi2 * isi[i, 2]
        θ = θ_intercept + θ_isi1 * isi[i, 1] + θ_isi2 * isi[i, 2]
        τ = τ_intercept + τ_isi1 * isi[i, 1] + τ_isi2 * isi[i, 2]

        # Track
        tracked_μ[i] = μ
        tracked_θ[i] = softplus(θ)
        tracked_τ[i] = min_rt * logistic(τ)

        # Random effects
        if participant !== nothing
            μ = μ + μ_intercept_random[participant[i]] + μ_isi1_random[participant[i]] * isi[i, 1] + μ_isi2_random[participant[i]] * isi[i, 2]
            θ = θ + θ_intercept_random[participant[i]] + θ_isi1_random[participant[i]] * isi[i, 1] + θ_isi2_random[participant[i]] * isi[i, 2]
            τ = τ + τ_intercept_random[participant[i]] + τ_isi1_random[participant[i]] * isi[i, 1] + τ_isi2_random[participant[i]] * isi[i, 2]
        end

        # Likelihood
        rt[i] ~ LocationScale(min_rt * logistic(τ), 1, Gumbel(μ, softplus(θ)))
    end

    # Make parameters accessible
    return (μ=tracked_μ, θ=tracked_θ, τ=tracked_τ,)
end


function model_LogWeibull(rt, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2)  # Transform ISI into polynomials
    if participant !== nothing
        ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
        n = length(unique(participant))
    else
        ppt_id = nothing
        n = 0
    end

    return model_LogWeibull(rt, isi2, ppt_id, min_rt, n)
end
# Inverse-Weibull (Fréchet) -------------------------------------------------------
# https://en.wikipedia.org/wiki/Fr%C3%A9chet_distribution

@model function model_InverseWeibull(rt, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    α_intercept ~ Normal(0, 2)
    α_isi1 ~ Normal(0, 2)
    α_isi2 ~ Normal(0, 2)

    θ_intercept ~ Normal(0, 3)  # Log-link
    θ_isi1 ~ Normal(0, 1)
    θ_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    # Priors - Random Effects
    α_intercept_random_sd ~ truncated(Normal(0.0, 0.3), lower=0)
    α_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    α_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)

    # Participant-level priors
    if participant !== nothing
        α_intercept_random ~ filldist(Normal(0, α_intercept_random_sd), n)
        α_isi1_random ~ filldist(Normal(0, α_isi1_random_sd), n)
        α_isi2_random ~ filldist(Normal(0, α_isi2_random_sd), n)
        θ_intercept_random ~ filldist(Normal(0, θ_intercept_random_sd), n)
        θ_isi1_random ~ filldist(Normal(0, θ_isi1_random_sd), n)
        θ_isi2_random ~ filldist(Normal(0, θ_isi2_random_sd), n)
        τ_intercept_random ~ filldist(Normal(0, τ_intercept_random_sd), n)
        τ_isi1_random ~ filldist(Normal(0, τ_isi1_random_sd), n)
        τ_isi2_random ~ filldist(Normal(0, τ_isi2_random_sd), n)
    end

    # Track parameters
    tracked_α = similar(rt, eltype(α_intercept))
    tracked_θ = similar(rt, eltype(θ_intercept))
    tracked_τ = similar(rt, eltype(τ_intercept))

    for i in 1:length(rt)
        # Fixed effects
        α = α_intercept + α_isi1 * isi[i, 1] + α_isi2 * isi[i, 2]
        θ = θ_intercept + θ_isi1 * isi[i, 1] + θ_isi2 * isi[i, 2]
        τ = τ_intercept + τ_isi1 * isi[i, 1] + τ_isi2 * isi[i, 2]

        # Track
        tracked_α[i] = softplus(α) + eps()
        tracked_θ[i] = softplus(θ)
        tracked_τ[i] = min_rt * logistic(τ)

        # Random effects
        if participant !== nothing
            α = α + α_intercept_random[participant[i]] + α_isi1_random[participant[i]] * isi[i, 1] + α_isi2_random[participant[i]] * isi[i, 2]
            θ = θ + θ_intercept_random[participant[i]] + θ_isi1_random[participant[i]] * isi[i, 1] + θ_isi2_random[participant[i]] * isi[i, 2]
            τ = τ + τ_intercept_random[participant[i]] + τ_isi1_random[participant[i]] * isi[i, 1] + τ_isi2_random[participant[i]] * isi[i, 2]
        end

        # Likelihood
        rt[i] ~ LocationScale(min_rt * logistic(τ), 1, Frechet(softplus(α) + eps(), softplus(θ)))
    end

    # Make parameters accessible
    return (α=tracked_α, θ=tracked_θ, τ=tracked_τ,)
end


function model_InverseWeibull(rt, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2)  # Transform ISI into polynomials
    if participant !== nothing
        ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
        n = length(unique(participant))
    else
        ppt_id = nothing
        n = 0
    end

    return model_InverseWeibull(rt, isi2, ppt_id, min_rt, n)
end


# Gamma ==========================================================================================
# Gamma ------------------------------------------------------------------------------------------
@model function model_Gamma(rt, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    α_intercept ~ Normal(0, 2)
    α_isi1 ~ Normal(0, 2)
    α_isi2 ~ Normal(0, 2)

    θ_intercept ~ Normal(0, 3)
    θ_isi1 ~ Normal(0, 1)
    θ_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    # Priors - Random Effects
    α_intercept_random_sd ~ truncated(Normal(0.0, 0.3), lower=0)
    α_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    α_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)

    # Participant-level priors
    if participant !== nothing
        α_intercept_random ~ filldist(Normal(0, α_intercept_random_sd), n)
        α_isi1_random ~ filldist(Normal(0, α_isi1_random_sd), n)
        α_isi2_random ~ filldist(Normal(0, α_isi2_random_sd), n)
        θ_intercept_random ~ filldist(Normal(0, θ_intercept_random_sd), n)
        θ_isi1_random ~ filldist(Normal(0, θ_isi1_random_sd), n)
        θ_isi2_random ~ filldist(Normal(0, θ_isi2_random_sd), n)
        τ_intercept_random ~ filldist(Normal(0, τ_intercept_random_sd), n)
        τ_isi1_random ~ filldist(Normal(0, τ_isi1_random_sd), n)
        τ_isi2_random ~ filldist(Normal(0, τ_isi2_random_sd), n)
    end

    # Track parameters  
    tracked_α = similar(rt, eltype(α_intercept))
    tracked_θ = similar(rt, eltype(θ_intercept))
    tracked_τ = similar(rt, eltype(τ_intercept))

    for i in 1:length(rt)
        # Fixed effects
        α = α_intercept + α_isi1 * isi[i, 1] + α_isi2 * isi[i, 2]
        θ = θ_intercept + θ_isi1 * isi[i, 1] + θ_isi2 * isi[i, 2]
        τ = τ_intercept + τ_isi1 * isi[i, 1] + τ_isi2 * isi[i, 2]

        # Track
        tracked_α[i] = softplus(α)
        tracked_θ[i] = softplus(θ)
        tracked_τ[i] = min_rt * logistic(τ)

        # Random effects
        if participant !== nothing
            α = α + α_intercept_random[participant[i]] + α_isi1_random[participant[i]] * isi[i, 1] + α_isi2_random[participant[i]] * isi[i, 2]
            θ = θ + θ_intercept_random[participant[i]] + θ_isi1_random[participant[i]] * isi[i, 1] + θ_isi2_random[participant[i]] * isi[i, 2]
            τ = τ + τ_intercept_random[participant[i]] + τ_isi1_random[participant[i]] * isi[i, 1] + τ_isi2_random[participant[i]] * isi[i, 2]
        end

        # Likelihood
        rt[i] ~ LocationScale(min_rt * logistic(τ), 1, Gamma(softplus(α), softplus(θ)))
    end

    # Make parameters accessible
    return (α=tracked_α, θ=tracked_θ, τ=tracked_τ,)
end


function model_Gamma(rt, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2)  # Transform ISI into polynomials
    if participant !== nothing
        ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
        n = length(unique(participant))
    else
        ppt_id = nothing
        n = 0
    end

    return model_Gamma(rt, isi2, ppt_id, min_rt, n)
end


# Inverse-Gamma ----------------------------------------------------------------------------------
@model function model_InverseGamma(rt, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    α_intercept ~ Normal(0, 2)
    α_isi1 ~ Normal(0, 2)
    α_isi2 ~ Normal(0, 2)

    θ_intercept ~ Normal(0, 3)
    θ_isi1 ~ Normal(0, 1)
    θ_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    # Priors - Random Effects
    α_intercept_random_sd ~ truncated(Normal(0.0, 0.3), lower=0)
    α_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    α_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    θ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)

    # Participant-level priors
    if participant !== nothing
        α_intercept_random ~ filldist(Normal(0, α_intercept_random_sd), n)
        α_isi1_random ~ filldist(Normal(0, α_isi1_random_sd), n)
        α_isi2_random ~ filldist(Normal(0, α_isi2_random_sd), n)
        θ_intercept_random ~ filldist(Normal(0, θ_intercept_random_sd), n)
        θ_isi1_random ~ filldist(Normal(0, θ_isi1_random_sd), n)
        θ_isi2_random ~ filldist(Normal(0, θ_isi2_random_sd), n)
        τ_intercept_random ~ filldist(Normal(0, τ_intercept_random_sd), n)
        τ_isi1_random ~ filldist(Normal(0, τ_isi1_random_sd), n)
        τ_isi2_random ~ filldist(Normal(0, τ_isi2_random_sd), n)
    end

    # Track parameters
    tracked_α = similar(rt, eltype(α_intercept))
    tracked_θ = similar(rt, eltype(θ_intercept))
    tracked_τ = similar(rt, eltype(τ_intercept))

    for i in 1:length(rt)
        # Fixed effects
        α = α_intercept + α_isi1 * isi[i, 1] + α_isi2 * isi[i, 2]
        θ = θ_intercept + θ_isi1 * isi[i, 1] + θ_isi2 * isi[i, 2]
        τ = τ_intercept + τ_isi1 * isi[i, 1] + τ_isi2 * isi[i, 2]

        # Track
        tracked_α[i] = softplus(α)
        tracked_θ[i] = softplus(θ) + eps()
        tracked_τ[i] = min_rt * logistic(τ)

        # Random effects
        if participant !== nothing
            α = α + α_intercept_random[participant[i]] + α_isi1_random[participant[i]] * isi[i, 1] + α_isi2_random[participant[i]] * isi[i, 2]
            θ = θ + θ_intercept_random[participant[i]] + θ_isi1_random[participant[i]] * isi[i, 1] + θ_isi2_random[participant[i]] * isi[i, 2]
            τ = τ + τ_intercept_random[participant[i]] + τ_isi1_random[participant[i]] * isi[i, 1] + τ_isi2_random[participant[i]] * isi[i, 2]
        end

        # Likelihood
        rt[i] ~ LocationScale(min_rt * logistic(τ), 1, InverseGamma(softplus(α), softplus(θ) + eps()))
    end

    # Make parameters accessible
    return (α=tracked_α, θ=tracked_θ, τ=tracked_τ,)
end


function model_InverseGamma(rt, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2)  # Transform ISI into polynomials
    if participant !== nothing
        ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
        n = length(unique(participant))
    else
        ppt_id = nothing
        n = 0
    end

    return model_InverseGamma(rt, isi2, ppt_id, min_rt, n)
end

# SSM ============================================================================================
# Log-Normal Race (LNR) ------------------------------------------------------------------------
@model function model_LNR(data, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    ν_intercept ~ Normal(4, 3)
    ν_isi1 ~ Normal(0, 1)
    ν_isi2 ~ Normal(0, 1)

    σ_intercept ~ Normal(0, 1)
    σ_isi1 ~ Normal(0, 1)
    σ_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    # Priors - Random Effects
    ν_intercept_random_sd ~ truncated(Normal(0.0, 0.3), lower=0)
    ν_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    ν_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)

    # Participant-level priors
    if participant !== nothing
        ν_intercept_random ~ filldist(Normal(0, ν_intercept_random_sd), n)
        ν_isi1_random ~ filldist(Normal(0, ν_isi1_random_sd), n)
        ν_isi2_random ~ filldist(Normal(0, ν_isi2_random_sd), n)
        σ_intercept_random ~ filldist(Normal(0, σ_intercept_random_sd), n)
        σ_isi1_random ~ filldist(Normal(0, σ_isi1_random_sd), n)
        σ_isi2_random ~ filldist(Normal(0, σ_isi2_random_sd), n)
        τ_intercept_random ~ filldist(Normal(0, τ_intercept_random_sd), n)
        τ_isi1_random ~ filldist(Normal(0, τ_isi1_random_sd), n)
        τ_isi2_random ~ filldist(Normal(0, τ_isi2_random_sd), n)
    end

    # Track parameters
    tracked_ν = similar(data, eltype(ν_intercept))
    tracked_σ = similar(data, eltype(σ_intercept))
    tracked_τ = similar(data, eltype(τ_intercept))

    for i in 1:length(data)
        # Fixed effects
        ν = ν_intercept + ν_isi1 * isi[i, 1] + ν_isi2 * isi[i, 2]
        σ = σ_intercept + σ_isi1 * isi[i, 1] + σ_isi2 * isi[i, 2]
        τ = τ_intercept + τ_isi1 * isi[i, 1] + τ_isi2 * isi[i, 2]

        # Track
        tracked_ν[i] = ν
        tracked_σ[i] = softplus(σ)
        tracked_τ[i] = min_rt * logistic(τ)

        # Random effects
        if participant !== nothing
            ν = ν + ν_intercept_random[participant[i]] + ν_isi1_random[participant[i]] * isi[i, 1] + ν_isi2_random[participant[i]] * isi[i, 2]
            σ = σ + σ_intercept_random[participant[i]] + σ_isi1_random[participant[i]] * isi[i, 1] + σ_isi2_random[participant[i]] * isi[i, 2]
            τ = τ + τ_intercept_random[participant[i]] + τ_isi1_random[participant[i]] * isi[i, 1] + τ_isi2_random[participant[i]] * isi[i, 2]
        end

        # Likelihood
        data[i] ~ LNR([ν], [softplus(σ)], min_rt * logistic(τ))
    end

    # Make parameters accessible
    return (ν=tracked_ν, σ=tracked_σ, τ=tracked_τ,)
end


function model_LNR(data, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2)  # Transform ISI into polynomials
    if participant !== nothing
        ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
        n = length(unique(participant))
    else
        ppt_id = nothing
        n = 0
    end

    return model_LNR(data, isi2, ppt_id, min_rt, n)
end



# Linear Ballistic Accumulator (LBA) ------------------------------------------------------------
@model function model_LBA(data, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    ν_intercept ~ Normal(4, 3)
    ν_isi1 ~ Normal(0, 1)
    ν_isi2 ~ Normal(0, 1)

    σ_intercept ~ Normal(0, 1)
    σ_isi1 ~ Normal(0, 1)
    σ_isi2 ~ Normal(0, 1)

    A_intercept ~ Normal(0, 3)
    A_isi1 ~ Normal(0, 1)
    A_isi2 ~ Normal(0, 1)

    k_intercept ~ Normal(0, 1)
    k_isi1 ~ Normal(0, 1)
    k_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    # Priors - Random Effects
    ν_intercept_random_sd ~ truncated(Normal(0.0, 0.3), lower=0)
    ν_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    ν_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    σ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    A_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    A_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    A_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    k_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    k_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    k_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)

    # Participant-level priors
    if participant !== nothing
        ν_intercept_random ~ filldist(Normal(0, ν_intercept_random_sd), n)
        ν_isi1_random ~ filldist(Normal(0, ν_isi1_random_sd), n)
        ν_isi2_random ~ filldist(Normal(0, ν_isi2_random_sd), n)
        σ_intercept_random ~ filldist(Normal(0, σ_intercept_random_sd), n)
        σ_isi1_random ~ filldist(Normal(0, σ_isi1_random_sd), n)
        σ_isi2_random ~ filldist(Normal(0, σ_isi2_random_sd), n)
        A_intercept_random ~ filldist(Normal(0, A_intercept_random_sd), n)
        A_isi1_random ~ filldist(Normal(0, A_isi1_random_sd), n)
        A_isi2_random ~ filldist(Normal(0, A_isi2_random_sd), n)
        k_intercept_random ~ filldist(Normal(0, k_intercept_random_sd), n)
        k_isi1_random ~ filldist(Normal(0, k_isi1_random_sd), n)
        k_isi2_random ~ filldist(Normal(0, k_isi2_random_sd), n)
        τ_intercept_random ~ filldist(Normal(0, τ_intercept_random_sd), n)
        τ_isi1_random ~ filldist(Normal(0, τ_isi1_random_sd), n)
        τ_isi2_random ~ filldist(Normal(0, τ_isi2_random_sd), n)
    end

    # Track parameters
    tracked_ν = similar(data, eltype(ν_intercept))
    tracked_σ = similar(data, eltype(σ_intercept))
    tracked_A = similar(data, eltype(A_intercept))
    tracked_k = similar(data, eltype(k_intercept))
    tracked_τ = similar(data, eltype(τ_intercept))

    for i in 1:length(data)
        # Fixed effects
        ν = ν_intercept + ν_isi1 * isi[i, 1] + ν_isi2 * isi[i, 2]
        σ = σ_intercept + σ_isi1 * isi[i, 1] + σ_isi2 * isi[i, 2]
        A = A_intercept + A_isi1 * isi[i, 1] + A_isi2 * isi[i, 2]
        k = k_intercept + k_isi1 * isi[i, 1] + k_isi2 * isi[i, 2]
        τ = τ_intercept + τ_isi1 * isi[i, 1] + τ_isi2 * isi[i, 2]

        # Track
        tracked_ν[i] = ν
        tracked_σ[i] = softplus(σ)
        tracked_A[i] = softplus(A)
        tracked_k[i] = softplus(k)
        tracked_τ[i] = min_rt * logistic(τ)

        # Random effects
        if participant !== nothing
            ν = ν + ν_intercept_random[participant[i]] + ν_isi1_random[participant[i]] * isi[i, 1] + ν_isi2_random[participant[i]] * isi[i, 2]
            σ = σ + σ_intercept_random[participant[i]] + σ_isi1_random[participant[i]] * isi[i, 1] + σ_isi2_random[participant[i]] * isi[i, 2]
            A = A + A_intercept_random[participant[i]] + A_isi1_random[participant[i]] * isi[i, 1] + A_isi2_random[participant[i]] * isi[i, 2]
            k = k + k_intercept_random[participant[i]] + k_isi1_random[participant[i]] * isi[i, 1] + k_isi2_random[participant[i]] * isi[i, 2]
            τ = τ + τ_intercept_random[participant[i]] + τ_isi1_random[participant[i]] * isi[i, 1] + τ_isi2_random[participant[i]] * isi[i, 2]
        end

        # Likelihood
        data[i] ~ LBA([ν], [softplus(σ)], softplus(A), softplus(k), min_rt * logistic(τ))
    end

    # Make parameters accessible
    return (ν=tracked_ν, σ=tracked_σ, A=tracked_A, k=tracked_k, τ=tracked_τ,)
end



function model_LBA(data, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2)  # Transform ISI into polynomials
    if participant !== nothing
        ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
        n = length(unique(participant))
    else
        ppt_id = nothing
        n = 0
    end

    return model_LBA(data, isi2, ppt_id, min_rt, n)
end



# Racing Diffusion Model (RDM) ----------------------------------------------------------------
@model function model_RDM(data, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    ν_intercept ~ Normal(8, 2)
    ν_isi1 ~ Normal(0, 1)
    ν_isi2 ~ Normal(0, 1)

    A_intercept ~ Normal(0, 3)
    A_isi1 ~ Normal(0, 1)
    A_isi2 ~ Normal(0, 1)

    k_intercept ~ Normal(0, 1)
    k_isi1 ~ Normal(0, 1)
    k_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    # Priors - Random Effects
    ν_intercept_random_sd ~ truncated(Normal(0.0, 0.3), lower=0)
    ν_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    ν_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    A_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    A_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    A_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    k_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    k_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    k_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_intercept_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi1_random_sd ~ truncated(Normal(0, 0.3), lower=0)
    τ_isi2_random_sd ~ truncated(Normal(0, 0.3), lower=0)

    # Participant-level priors
    if participant !== nothing
        ν_intercept_random ~ filldist(Normal(0, ν_intercept_random_sd), n)
        ν_isi1_random ~ filldist(Normal(0, ν_isi1_random_sd), n)
        ν_isi2_random ~ filldist(Normal(0, ν_isi2_random_sd), n)
        A_intercept_random ~ filldist(Normal(0, A_intercept_random_sd), n)
        A_isi1_random ~ filldist(Normal(0, A_isi1_random_sd), n)
        A_isi2_random ~ filldist(Normal(0, A_isi2_random_sd), n)
        k_intercept_random ~ filldist(Normal(0, k_intercept_random_sd), n)
        k_isi1_random ~ filldist(Normal(0, k_isi1_random_sd), n)
        k_isi2_random ~ filldist(Normal(0, k_isi2_random_sd), n)
        τ_intercept_random ~ filldist(Normal(0, τ_intercept_random_sd), n)
        τ_isi1_random ~ filldist(Normal(0, τ_isi1_random_sd), n)
        τ_isi2_random ~ filldist(Normal(0, τ_isi2_random_sd), n)
    end

    # Track parameters
    tracked_ν = similar(data, eltype(ν_intercept))
    tracked_A = similar(data, eltype(A_intercept))
    tracked_k = similar(data, eltype(k_intercept))
    tracked_τ = similar(data, eltype(τ_intercept))

    for i in 1:length(data)
        # Fixed effects
        ν = ν_intercept + ν_isi1 * isi[i, 1] + ν_isi2 * isi[i, 2]
        A = A_intercept + A_isi1 * isi[i, 1] + A_isi2 * isi[i, 2]
        k = k_intercept + k_isi1 * isi[i, 1] + k_isi2 * isi[i, 2]
        τ = τ_intercept + τ_isi1 * isi[i, 1] + τ_isi2 * isi[i, 2]

        # Track
        tracked_ν[i] = ν
        tracked_A[i] = softplus(A)
        tracked_k[i] = softplus(k)
        tracked_τ[i] = min_rt * logistic(τ)

        # Random effects
        if participant !== nothing
            ν = ν + ν_intercept_random[participant[i]] + ν_isi1_random[participant[i]] * isi[i, 1] + ν_isi2_random[participant[i]] * isi[i, 2]
            A = A + A_intercept_random[participant[i]] + A_isi1_random[participant[i]] * isi[i, 1] + A_isi2_random[participant[i]] * isi[i, 2]
            k = k + k_intercept_random[participant[i]] + k_isi1_random[participant[i]] * isi[i, 1] + k_isi2_random[participant[i]] * isi[i, 2]
            τ = τ + τ_intercept_random[participant[i]] + τ_isi1_random[participant[i]] * isi[i, 1] + τ_isi2_random[participant[i]] * isi[i, 2]
        end

        # Likelihood
        data[i] ~ RDM([ν], softplus(A), softplus(k), min_rt * logistic(τ))
    end

    # Make parameters accessible
    return (ν=tracked_ν, A=tracked_A, k=tracked_k, τ=tracked_τ,)
end

function model_RDM(data, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2)  # Transform ISI into polynomials
    if participant !== nothing
        ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
        n = length(unique(participant))
    else
        ppt_id = nothing
        n = 0
    end

    return model_RDM(data, isi2, ppt_id, min_rt, n)
end


# =================================================================================================
MODELS = Dict{String,Any}(
    "model_Linear" => model_Linear,
    "model_Gaussian" => model_Gaussian,
    "model_ExGaussian" => model_ExGaussian,
    "model_LogNormal" => model_LogNormal,
    "model_InverseGaussian" => model_InverseGaussian,
    "model_Weilbull" => model_Weilbull,
    "model_LogWeibull" => model_LogWeibull,
    "model_InverseWeibull" => model_InverseWeibull,
    "model_Gamma" => model_Gamma,
    "model_InverseGamma" => model_InverseGamma,
    "model_LNR" => model_LNR,
    "model_LBA" => model_LBA,
    "model_RDM" => model_RDM
)