---
title: "Atomic Layer Etching: The Key to High Aspect Ratio Semiconductor Manufacturing"
date: "2026-02-07T10:00:00+08:00"
tags:
  - Semiconductor
  - Atomic Layer Etching
  - 3D NAND
categories:
  - Technical
slug: "ale-high-aspect-ratio-etching-semiconductor"
description: "How atomic layer etching solves aspect ratio dependent etching challenges in 3D NAND, DRAM, and advanced logic."
---

## Key Takeaways

- **ALE eliminates ARDE in principle:** Self-limiting surface reactions make etch depth independent of reactant flux, removing the aspect ratio dependence that limits conventional RIE.
- **Production results are impressive:** Lam Research's Cryo 3.0 achieves less than 0.1% CD deviation at 10-micrometer depth in 3D NAND channel holes.
- **Challenges remain at extreme ratios:** At 100:1 aspect ratio, neutral species flux drops to just 1.3% of surface levels, requiring innovative solutions in reactant delivery and pulsed plasma control.

---

## The Growing Challenge of Etching Deeper

Every generation of 3D NAND flash memory demands deeper, narrower features. A 96-layer device requires channel holes with aspect ratios around 50:1. The 400-layer devices entering production today push past 60:1. And the 1,000-layer architectures on industry roadmaps will demand aspect ratios approaching 100:1.

The fundamental problem is transport. In conventional reactive ion etching (RIE), reactive species must travel to the bottom of these deep, narrow features to do their work. As features deepen, fewer ions and neutral radicals reach the bottom --- a phenomenon known as aspect ratio dependent etching, or ARDE. The result: etch rates slow down, profiles distort, and dimensional control degrades precisely where it matters most.

Atomic layer etching (ALE) offers a fundamentally different approach. By decomposing the etch process into self-limiting half-reactions, ALE converts a flux-dependent process into a dose-dependent one --- and that distinction changes everything for high aspect ratio manufacturing.

---

## How ALE Overcomes ARDE

In conventional RIE, the etch rate at any point is proportional to the local flux of reactive species. Deep inside a high aspect ratio feature, that flux can be dramatically reduced. Joubert and colleagues recently quantified this: at an aspect ratio of 100:1, the neutral flux at the feature bottom is just 1.3% of the incoming flux. That is a 98.7% reduction in available etchant.

ALE sidesteps this problem through self-limitation. In each ALE cycle, a reactive gas modifies exactly one atomic layer of the surface --- and stops. Then a second step removes that modified layer --- and stops. Because both steps saturate, the etch amount per cycle depends not on the instantaneous flux, but on whether the cumulative dose is sufficient to reach saturation.

This means a feature bottom receiving 1% of the surface flux should still achieve the same etch per cycle as a flat surface. It simply takes a longer exposure to get there.

Huard, Kanarik, Kushner, and colleagues at Lam Research and the University of Michigan demonstrated this principle through detailed modeling of chlorine/argon ALE in 3D silicon structures. When both steps reach full saturation, the etch per cycle is truly independent of aspect ratio. ARDE is eliminated.

---

## From Theory to Production

The theoretical promise of ALE has increasingly been validated in production-relevant demonstrations:

**Thermal ALE in deep features.** Fischer and colleagues at Lam Research demonstrated thermal ALE of hafnium oxide in 3D NAND test structures with aspect ratios exceeding 50:1. Using HF for surface fluorination and dimethylaluminum chloride (DMAC) for ligand-exchange removal, they achieved a uniform etch per cycle of 0.6 nanometers throughout the structure.

**Aspect-ratio-independent plasma ALE.** Dallorto, Goodyear, and colleagues demonstrated plasma ALE of silicon dioxide using CHF3/Ar chemistry that achieved aspect-ratio-independent etching during pattern transfer. By operating at a substrate temperature of -10 degrees C to minimize parasitic reactions, they confirmed that the self-limiting mechanism can overcome ARDE even in a plasma-based process.

**Pulsed plasma for ARDE reduction.** Kim and colleagues showed that asynchronously pulsed plasma --- which creates an ALE-like cycle of chemical adsorption followed by ion bombardment removal --- reduces ARDE from 35% in continuous-wave mode to just 8%. Mask selectivity simultaneously improved by 10 times.

---

## Cryogenic ALE: A Game-Changer for 3D NAND

Perhaps the most impactful development is the convergence of cryogenic processing with ALE concepts. At temperatures of -60 to -110 degrees C, the physics of surface adsorption changes dramatically: reactive gases physisorb onto surfaces in self-limiting layers that serve as the modification step of an ALE cycle.

Lam Research's Cryo 3.0 technology, launched in July 2024, combines cryogenic temperatures with pulsed plasma ALE on the Vantex platform. The results are remarkable:

- Channel hole depths up to 10 micrometers
- Less than 0.1% critical dimension deviation from top to bottom
- Compatible with all leading memory manufacturers' platforms
- Path to 1,000-layer 3D NAND scaling

Tokyo Electron has pursued a complementary approach, developing cryogenic etch technology that achieves ultra-fast 10-micrometer-deep etching for 400-layer 3D NAND with an 84% reduction in global warming potential --- addressing both performance and sustainability demands.

---

## What Remains Challenging

Despite these advances, several challenges persist as the industry pushes toward extreme aspect ratios:

**Saturation at depth.** Ensuring that both ALE half-reactions reach complete saturation at the bottom of a 100:1 feature requires exposure times that scale roughly as the square of the aspect ratio. This creates a direct tension between ALE precision and manufacturing throughput.

**Purge efficiency.** Between ALE half-steps, unreacted species must be removed from the feature. The same Knudsen transport that limits reactant delivery also limits purge efficiency, potentially causing parasitic reactions.

**Integration complexity.** Production processes increasingly use hybrid approaches --- ALE for critical steps, continuous RIE for bulk removal --- that require sophisticated recipe management and equipment capabilities.

---

## The Industry is Responding

The ALE equipment market, valued at approximately 1.36 billion dollars in 2025, is projected to reach 2.74 billion dollars by 2033. This growth is driven primarily by 3D NAND scaling and the transition to gate-all-around transistor architectures, both of which demand high aspect ratio etching at atomic-scale precision.

---

## References

1. Kanarik, K. J. et al. (2018). Atomic layer etching: Rethinking the art of etch. *The Journal of Physical Chemistry Letters*, 9(16), 4814-4821.
2. Huard, C. M. et al. (2017). Atomic layer etching of 3D structures in silicon. *Journal of Vacuum Science & Technology A*, 35(3), 031306.
3. Fischer, A. et al. (2022). Control of etch profiles in high aspect ratio holes via precise reactant dosing in thermal ALE. *Journal of Vacuum Science & Technology A*, 40(2), 022603.
4. Dallorto, S. et al. (2019). Atomic layer etching of SiO2: A self-limiting process for aspect ratio independent etching. *Plasma Processes and Polymers*, 16(7), e1900051.
5. Kim, S. J. et al. (2023). Asynchronously pulsed plasma for high aspect ratio nanoscale Si trench etch. *ACS Applied Nano Materials*, 6(12), 10602-10611.
6. Joubert, O. et al. (2023). Neutral transport during etching of high aspect ratio features. *Journal of Vacuum Science & Technology A*, 41(3), 033006.
7. Antoun, G. et al. (2021). Mechanism understanding in cryo atomic layer etching of SiO2. *Scientific Reports*, 11, 22579.
