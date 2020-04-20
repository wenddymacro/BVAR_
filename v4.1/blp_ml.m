% function [log_dnsty] = blp_ml(shrinkage,hh,prior,olsreg_,F,G,Fo,positions_nylags,position_constant)
function [logpy] = blp_ml(shrinkage,hh,prior,olsreg_,F,G,Fo,positions_nylags,position_constant)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 'blp_ml' computes the marginal likelihood for the NMIW

% Inputs:
% - hyperpara, shrinkage hyperpara over which maximize the marginal
% likelihood

% Output: marginal data density

% Filippo Ferroni, 3/21/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%********************************************************
% SETTINGS
%********************************************************
ny   = size(G,2);
lags = size(G,2)/ny;
%********************************************************
% Conjugate Prior: N-IW
%********************************************************
% constructing the prior mean

[posterior1,prior1] = p2p(hh,shrinkage,prior,olsreg_,F,G,Fo,positions_nylags,position_constant);

% Giannone, Lenza Primiceri (2015) Appendix  A13
logpy = -(ny*(olsreg_.N-lags)/2) *log(pi);
logpy = logpy  -ny/2*log(det(prior.Phi.cov)) - prior.Sigma.df/2*log(det(prior.Sigma.scale));
FF    = prior.Sigma.scale + (posterior1.PhiHat - prior1.BetaMean)'* prior1.XXi * (posterior1.PhiHat - prior1.BetaMean) ...
    + posterior1.E_'* posterior1.E_; 
logpy = logpy - (ny*(olsreg_.N-lags + prior1.df)/2) * log(det( FF ));
logpy = logpy + ggammaln(ny,(olsreg_.N-lags + prior1.df)/2) + ggammaln(ny,prior1.df/2);

function lgg = ggammaln(m, df)
if df <= (m-1)
    error('too few df in ggammaln; increase the number of observations or reduce the number of lags')
else
    garg = 0.5*(df+(0:-1:1-m));
    lgg = sum(gammaln(garg));
end

