# The Race Between Machine and Man — weekly repository 6

Daron Acemoglu and Pascual Restrepo, [NBER Working Paper 22252](https://www.nber.org/papers/w22252), **revised June 2017**. This repository uses the weekly structure of the [worked template](https://github.com/alexanderquispe/ai-01-aouad), with this paper's content and the required `lean/` folder.

## Question and unit of analysis

Can automation make labor redundant, or can the creation of new labor intensive tasks offset it? The paper's unit is the **aggregate economy**. Its central object is a unit interval of tasks, $[N-1,N]$. A higher automation frontier $I$ makes more tasks feasible for capital; a higher $N$ replaces old tasks with new ones where labor has comparative advantage. These are the **displacement** and **reinstatement** forces.

## The agents' problems

Competitive firms minimize each task's unit cost: for $i\le I$, they compare capital's rental cost $R$ with labor's effective cost $W/\gamma(i)$; for $i>I$, only labor is feasible. With strictly increasing labor productivity $\gamma(i)$, the equal-cost threshold solves $W/R=\gamma(\widetilde I)$ and the implemented threshold is $I^*=\min\{I,\widetilde I\}$. A representative household chooses consumption, labor supply, and, in the dynamic model, saving. Scientists choose between advancing $I$ and creating tasks at $N$ according to innovation payoffs. Prices, factor shares, and employment are equilibrium outcomes of these decisions.

## Main results, including the conditions

In the **static model**, capital $K$ and technology are fixed apart from the comparative static. Assume (1) strictly increasing $\gamma$, (2) either $\eta\to0$ or $\zeta=1$ so factor demands are homothetic, and (3) $K<\bar K$, ensuring $R>W/\gamma(N)$ and profitable adoption of new tasks. With positive labor supply elasticity $\varepsilon_L$ and positive task terms $\Lambda_I,\Lambda_N$, Proposition 2 says that if $I^*=I<\widetilde I$, an increase in $I$ lowers $W/R$, the labor share, and employment. If $I^*=\widetilde I<I$, extra feasible automation has **no marginal effect**. Raising $N$ increases those three outcomes in either regime. The equality boundary has different one-sided derivatives.

**Absolute wages are conditional.** Proposition 3's constrained-case decomposition, for $dN=0$, is

$$\frac{\partial\ln W}{\partial I}=\underbrace{\left.\frac{\partial\ln Y}{\partial I}\right|_{K,L}}_{P_I\text{ (productivity)}}-\underbrace{(1-s_L)\frac{\Lambda_I}{\widehat\sigma+\varepsilon_L}}_{D_I\text{ (displacement)}}.$$

Thus automation **raises** wages exactly when $P_I>D_I$, leaves them unchanged at equality, and lowers them when $P_I<D_I$. Under the paper's assumptions there is an admissible capital threshold: lower $K$ makes the productivity effect dominate, while higher admissible $K$ makes displacement dominate.

For the **endogenous innovation** result (Proposition 6), add Assumption $1'$ ($\gamma(i)=e^{Ai}$, $A>0$), Assumption 4 ($\widehat\sigma>\zeta$), and scientist supply $S<\bar S$, alongside Assumption 2. If $\rho<\bar\rho$, a full automation balanced growth path (BGP) exists. If $\rho>\bar\rho$, the ratio $\kappa_N/\kappa_I$ determines the outcome: above $\bar\kappa$, a unique interior BGP has both innovations and $\kappa_Nv_N=\kappa_Iv_I$; between $\underline\kappa$ and $\bar\kappa$, BGPs are multiple; below $\underline\kappa$, a unique no automation BGP exists. The unique interior equilibrium is globally saddle-path stable if $\theta=0$, and locally unique and asymptotically saddle-path stable if $\theta>0$. The stated strict inequalities leave equality boundaries separate.

## Materials and honest status

- [Presentation](presentation.pdf) and [LaTeX source](presentation.tex): 17 slides for 20 minutes, with a dedicated equation-to-Lean slide.
- [Raw prompts and answers](prompts.md).
- `hand/` is ready for **your photo** at `hand/derivation.jpg`. The deck currently shows the derivation in LaTeX and an explicit photo placeholder. Recompile after adding the photo.
- [Lean folder](lean/): the entire paper folder copied from this run of AppliedModelingLib. Two conditional supporting results are Lean checked; the equilibrium propositions and complete source-semantic audit remain open. The folder's own status and working memo explain the boundary.
- [Numerical sign check](analysis/wage_cases.py): illustrative arithmetic, not calibration.

The source PDF was used locally for verification and is not published here. The `lean/` copy respects its generated `.gitignore`.
