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
    μ_isi1 ~ Normal(0, 0.5)
    μ_isi2 ~ Normal(0, 0.5)

    σ ~ truncated(Normal(0.0, 1), 0.0, Inf)

    # Priors - Random Effects
    μ_intercept_random_sd ~ truncated(Normal(0.0, 0.3), 0.0, Inf)
    μ_isi1_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)
    μ_isi2_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)

    # Participant-level priors
    μ_intercept_random ~ filldist(Normal(0, μ_intercept_random_sd), n)
    μ_isi1_random ~ filldist(Normal(0, μ_isi1_random_sd), n)
    μ_isi2_random ~ filldist(Normal(0, μ_isi2_random_sd), n)

    for i in 1:length(rt)
        # Compute μ
        μ = μ_intercept + μ_intercept_random[participant[i]]
        μ += (μ_isi1 + μ_isi1_random[participant[i]]) * isi[i, 1]
        μ += (μ_isi2 + μ_isi2_random[participant[i]]) * isi[i, 2]

        # Likelihood
        rt[i] ~ Normal(μ, σ)
    end
end

function model_Linear(rt, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2; orthogonal=true)  # Transform ISI into polynomials
    ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
    n = length(unique(participant))

    return model_Linear(rt, isi2, ppt_id, min_rt, n)
end



# Gaussian ------------------------------------------------------------------------------------
@model function model_Gaussian(rt, isi, participant, min_rt=minimum(rt), n=length(unique(participant)))

    # Priors - Fixed Effects
    μ_intercept ~ Normal(0.3, 0.5)
    μ_isi1 ~ Normal(0, 0.5)
    μ_isi2 ~ Normal(0, 0.5)

    σ_intercept ~ Normal(-3, 3)  # Softplus link
    σ_isi1 ~ Normal(0, 3)
    σ_isi2 ~ Normal(0, 3)

    # Priors - Random Effects
    μ_intercept_random_sd ~ truncated(Normal(0.0, 0.3), 0.0, Inf)
    μ_isi1_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)
    μ_isi2_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)
    σ_intercept_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)
    σ_isi1_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)
    σ_isi2_random_sd ~ truncated(Normal(0, 0.3), 0.0, Inf)

    # Participant-level priors
    μ_intercept_random ~ filldist(Normal(0, μ_intercept_random_sd), n)
    μ_isi1_random ~ filldist(Normal(0, μ_isi1_random_sd), n)
    μ_isi2_random ~ filldist(Normal(0, μ_isi2_random_sd), n)
    σ_intercept_random ~ filldist(Normal(0, σ_intercept_random_sd), n)
    σ_isi1_random ~ filldist(Normal(0, σ_isi1_random_sd), n)
    σ_isi2_random ~ filldist(Normal(0, σ_isi2_random_sd), n)

    for i in 1:length(rt)
        # Compute μ
        μ = μ_intercept + μ_intercept_random[participant[i]]
        μ += (μ_isi1 + μ_isi1_random[participant[i]]) * isi[i, 1]
        μ += (μ_isi2 + μ_isi2_random[participant[i]]) * isi[i, 2]

        # Compute σ
        σ = σ_intercept + σ_intercept_random[participant[i]]
        σ += (σ_isi1 + σ_isi1_random[participant[i]]) * isi[i, 1]
        σ += (σ_isi2 + σ_isi2_random[participant[i]]) * isi[i, 2]

        # Likelihood
        rt[i] ~ Normal(μ, softplus(σ))
    end
end

function model_Gaussian(rt, isi, participant; min_rt=minimum(rt))

    # Data preparation
    isi2 = data_poly(isi, 2; orthogonal=true)  # Transform ISI into polynomials
    ppt_id = [findfirst(ppt .== unique(participant)) for ppt in participant] # Convert participant to integers
    n = length(unique(participant))

    return model_Gaussian(rt, isi2, ppt_id, min_rt, n)
end




# Exgaussian ------------------------------------------------------------------------------------
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


# LogNormal --------------------------------------------------------------------------------------
@model function model_LogNormal(rt; min_rt=minimum(rt), isi=nothing)

    # Transform ISI into polynomials
    isi = data_poly(isi, 2; orthogonal=true)

    # Priors
    μ_intercept ~ Normal(0, 2)
    μ_isi1 ~ Normal(0, 2)
    μ_isi2 ~ Normal(0, 2)

    σ_intercept ~ Normal(0, 3)  # Log-link
    σ_isi1 ~ Normal(0, 1)
    σ_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    for i in 1:length(rt)
        μ = μ_intercept + (μ_isi1 * isi[i, 1]) + (μ_isi2 * isi[i, 2])
        σ = σ_intercept + (σ_isi1 * isi[i, 1]) + (σ_isi2 * isi[i, 2])
        τ = τ_intercept + (τ_isi1 * isi[i, 1]) + (τ_isi2 * isi[i, 2])
        rt[i] ~ ShiftedLogNormal(μ, exp(σ), min_rt * logistic(τ))
    end
end



# Inverse Gaussian (Wald) ------------------------------------------------------------------------------------------
@model function model_InverseGaussian(rt; min_rt=minimum(rt), isi=nothing)

    # Transform ISI into polynomials
    isi = data_poly(isi, 2; orthogonal=true)

    # Priors
    ν_intercept ~ Normal(0, 1)
    ν_isi1 ~ Normal(0, 1)
    ν_isi2 ~ Normal(0, 1)

    α_intercept ~ Normal(0, 1)
    α_isi1 ~ Normal(0, 1)
    α_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    for i in 1:length(rt)
        ν = ν_intercept + (ν_isi1 * isi[i, 1]) + (ν_isi2 * isi[i, 2])
        α = α_intercept + (α_isi1 * isi[i, 1]) + (α_isi2 * isi[i, 2])
        τ = τ_intercept + (τ_isi1 * isi[i, 1]) + (τ_isi2 * isi[i, 2])
        rt[i] ~ Wald(exp(ν), exp(α), exp(τ))
    end
end


# Weibull ========================================================================================
# Weibull ----------------------------------------------------------------------------------------
@model function model_Weilbull(rt; min_rt=minimum(rt), isi=nothing)

    # Transform ISI into polynomials
    isi = data_poly(isi, 2; orthogonal=true)

    # Priors
    α_intercept ~ Normal(0, 2)
    α_isi1 ~ Normal(0, 2)
    α_isi2 ~ Normal(0, 2)

    θ_intercept ~ Normal(0, 3)  # Log-link
    θ_isi1 ~ Normal(0, 1)
    θ_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    for i in 1:length(rt)
        α = α_intercept + (α_isi1 * isi[i, 1]) + (α_isi2 * isi[i, 2])
        θ = θ_intercept + (θ_isi1 * isi[i, 1]) + (θ_isi2 * isi[i, 2])
        τ = τ_intercept + (τ_isi1 * isi[i, 1]) + (τ_isi2 * isi[i, 2])
        rt[i] ~ LocationScale(min_rt * logistic(τ), 1, Weibull(exp(α) + eps(), exp(θ)))
    end
end


# Log-Weibull (Gumbel) -------------------------------------------------------------------------
# https://en.wikipedia.org/wiki/Gumbel_distribution

@model function model_LogWeibull(rt; min_rt=minimum(rt), isi=nothing)

    # Transform ISI into polynomials
    isi = data_poly(isi, 2; orthogonal=true)

    # Priors
    μ_intercept ~ Normal(0, 2)
    μ_isi1 ~ Normal(0, 2)
    μ_isi2 ~ Normal(0, 2)

    θ_intercept ~ Normal(-3, 3)  # Log-link
    θ_isi1 ~ Normal(0, 1)
    θ_isi2 ~ Normal(0, 1)

    for i in 1:length(rt)
        μ = μ_intercept + (μ_isi1 * isi[i, 1]) + (μ_isi2 * isi[i, 2])
        θ = θ_intercept + (θ_isi1 * isi[i, 1]) + (θ_isi2 * isi[i, 2])
        rt[i] ~ Gumbel(μ, exp(θ))
    end
end

# Inverse-Weibull (Fréchet) -------------------------------------------------------
# https://en.wikipedia.org/wiki/Fr%C3%A9chet_distribution

@model function model_InverseWeibull(rt; min_rt=minimum(rt), isi=nothing)

    # Transform ISI into polynomials
    isi = data_poly(isi, 2; orthogonal=true)

    # Priors
    α_intercept ~ Normal(0, 2)
    α_isi1 ~ Normal(0, 2)
    α_isi2 ~ Normal(0, 2)

    θ_intercept ~ Normal(-3, 3)  # Log-link
    θ_isi1 ~ Normal(0, 1)
    θ_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    for i in 1:length(rt)
        α = α_intercept + (α_isi1 * isi[i, 1]) + (α_isi2 * isi[i, 2])
        θ = θ_intercept + (θ_isi1 * isi[i, 1]) + (θ_isi2 * isi[i, 2])
        τ = τ_intercept + (τ_isi1 * isi[i, 1]) + (τ_isi2 * isi[i, 2])
        rt[i] ~ LocationScale(min_rt * logistic(τ), 1, Frechet(exp(α), exp(θ)))
    end
end

# Gamma ==========================================================================================
# Gamma ------------------------------------------------------------------------------------------
@model function model_Gamma(rt; min_rt=minimum(rt), isi=nothing)

    # Transform ISI into polynomials
    isi = data_poly(isi, 2; orthogonal=true)

    # Priors
    α_intercept ~ Normal(0, 2)
    α_isi1 ~ Normal(0, 2)
    α_isi2 ~ Normal(0, 2)

    θ_intercept ~ Normal(0, 3)  # Log-link
    θ_isi1 ~ Normal(0, 1)
    θ_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    for i in 1:length(rt)
        α = α_intercept + (α_isi1 * isi[i, 1]) + (α_isi2 * isi[i, 2])
        θ = θ_intercept + (θ_isi1 * isi[i, 1]) + (θ_isi2 * isi[i, 2])
        τ = τ_intercept + (τ_isi1 * isi[i, 1]) + (τ_isi2 * isi[i, 2])
        rt[i] ~ LocationScale(min_rt * logistic(τ), 1, Gamma(exp(α), exp(θ)))
    end
end

# Inverse-Gamma ----------------------------------------------------------------------------------
@model function model_InverseGamma(rt; min_rt=minimum(rt), isi=nothing)

    # Transform ISI into polynomials
    isi = data_poly(isi, 2; orthogonal=true)

    # Priors
    α_intercept ~ Normal(0, 2)
    α_isi1 ~ Normal(0, 2)
    α_isi2 ~ Normal(0, 2)

    θ_intercept ~ Normal(0, 3)  # Log-link
    θ_isi1 ~ Normal(0, 1)
    θ_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    for i in 1:length(rt)
        α = α_intercept + (α_isi1 * isi[i, 1]) + (α_isi2 * isi[i, 2])
        θ = θ_intercept + (θ_isi1 * isi[i, 1]) + (θ_isi2 * isi[i, 2])
        τ = τ_intercept + (τ_isi1 * isi[i, 1]) + (τ_isi2 * isi[i, 2])
        rt[i] ~ LocationScale(min_rt * logistic(τ), 1, InverseGamma(exp(α), exp(θ)))
    end
end

# SSM ============================================================================================
# Log-Normal Race (LNR) ------------------------------------------------------------------------
@model function model_LNR(data; min_rt=minimum(rt), isi=nothing)

    # Transform ISI into polynomials
    isi = data_poly(isi, 2; orthogonal=true)

    # Priors
    ν_intercept ~ filldist(Normal(4, 3), 1)
    ν_isi1 ~ filldist(Normal(0, 1), 1)
    ν_isi2 ~ filldist(Normal(0, 1), 1)

    σ_intercept ~ filldist(Normal(log(0.2), 3), 1)  # Log-link
    σ_isi1 ~ filldist(Normal(0, 1), 1)
    σ_isi2 ~ filldist(Normal(0, 1), 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    for i in 1:length(data)
        ν = ν_intercept .+ (ν_isi1 * isi[i, 1]) .+ (ν_isi2 * isi[i, 2])
        σ = σ_intercept .+ (σ_isi1 * isi[i, 1]) .+ (σ_isi2 * isi[i, 2])
        τ = τ_intercept + (τ_isi1 * isi[i, 1]) + (τ_isi2 * isi[i, 2])
        data[i] ~ LNR(ν, exp.(σ), min_rt * logistic(τ))
    end
end

# Linear Ballistic Accumulator (LBA) ------------------------------------------------------------
@model function model_LBA(data; min_rt=minimum(rt), isi=nothing)

    # Transform ISI into polynomials
    isi = data_poly(isi, 2; orthogonal=true)

    # Priors
    ν_intercept ~ filldist(Normal(4, 3), 1)
    ν_isi1 ~ filldist(Normal(0, 1), 1)
    ν_isi2 ~ filldist(Normal(0, 1), 1)

    σ_intercept ~ filldist(Normal(log(0.2), 3), 1)  # Log-link
    σ_isi1 ~ filldist(Normal(0, 1), 1)
    σ_isi2 ~ filldist(Normal(0, 1), 1)

    A_intercept ~ Normal(log(0.8), 3)  # Log-link
    A_isi1 ~ Normal(0, 1)
    A_isi2 ~ Normal(0, 1)

    k_intercept ~ Normal(log(0.5), 1)  # Log-link
    k_isi1 ~ Normal(0, 1)
    k_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    for i in 1:length(data)
        ν = ν_intercept .+ (ν_isi1 * isi[i, 1]) .+ (ν_isi2 * isi[i, 2])
        σ = σ_intercept .+ (σ_isi1 * isi[i, 1]) .+ (σ_isi2 * isi[i, 2])
        A = A_intercept + (A_isi1 * isi[i, 1]) + (A_isi2 * isi[i, 2])
        k = k_intercept + (k_isi1 * isi[i, 1]) + (k_isi2 * isi[i, 2])
        τ = τ_intercept + (τ_isi1 * isi[i, 1]) + (τ_isi2 * isi[i, 2])
        data[i] ~ LBA(; ν=ν, σ=exp.(σ), A=exp(A), k=exp(k), τ=min_rt * logistic(τ))
    end
end

# Racing Diffusion Model (RDM) ----------------------------------------------------------------
@model function model_RDM(data; min_rt=minimum(rt), isi=nothing)

    # Transform ISI into polynomials
    isi = data_poly(isi, 2; orthogonal=true)

    # Priors
    ν_intercept ~ filldist(Normal(8, 2), 1)
    ν_isi1 ~ filldist(Normal(0, 1), 1)
    ν_isi2 ~ filldist(Normal(0, 1), 1)

    A_intercept ~ Normal(log(0.8), 3)  # Log-link
    A_isi1 ~ Normal(0, 1)
    A_isi2 ~ Normal(0, 1)

    k_intercept ~ Normal(log(0.5), 1)  # Log-link
    k_isi1 ~ Normal(0, 1)
    k_isi2 ~ Normal(0, 1)

    τ_intercept ~ Normal(0, 3)  # Scaled logit-link
    τ_isi1 ~ Normal(0, 1)
    τ_isi2 ~ Normal(0, 1)

    for i in 1:length(data)
        ν = ν_intercept .+ (ν_isi1 * isi[i, 1]) .+ (ν_isi2 * isi[i, 2])
        A = A_intercept + (A_isi1 * isi[i, 1]) + (A_isi2 * isi[i, 2])
        k = k_intercept + (k_isi1 * isi[i, 1]) + (k_isi2 * isi[i, 2])
        τ = τ_intercept + (τ_isi1 * isi[i, 1]) + (τ_isi2 * isi[i, 2])
        data[i] ~ RDM(; ν=ν, A=exp(A), k=exp(k), τ=min_rt * logistic(τ))
    end
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