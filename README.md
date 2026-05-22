# EEG Motor Execution Analysis (BCI Project)

This repository contains the implementation of three exercises from a Brain-Computer Interface (BCI) experiment based on EEG recordings during upper-limb movements.

The project is structured in a modular way using functions for clarity and reproducibility.

---

# Dataset

EEG recordings from 15 subjects (in this case: S1, S3, S4, S5, S6, S7, S9 and S12)  performing 6 movements + rest:

- Elbow flexion / extension
- Supination / pronation
- Hand open / close
- Rest

Recording setup:

- 61 EEG channels
- Sampling rate: 512 Hz
- 10 runs per subject
- 60 trials per class

--- 

# Exercise 1 — Preprocessing (ERP)

Objective:

Clean EEG data, remove artifacts and analyze event-related potentials (ERP).

Steps:

- Detrend
- Band-pass filter (0.3 – 70 Hz)
- Notch filter (50 Hz)
- Bad channel detection
- Re-referencing (CAR)
- ICA (artifact removal)
- Channel interpolation
- Trial extraction ([-2.5s, 6s] from stimulus onset)
- Compute response time (RT)
- Trial rejection
- Calculate % of valid trials
- Averaging (subject + grand-mean) in Cz channel
  
Outputs:

- Bad channels
- % of valid trials
- Inter-subject variability and grand-mean ERP plots (Cz channel)

---

# Exercise 2 — MRCP

Objective:

Analyze motor-related cortical potentials (movement preparation).

Steps:

- Detrend
- Band-pass filter (0.3 – 70 Hz)
- Notch filter (50 Hz)
- Bad channel detection
- Re-referencing (CAR)
- ICA (artifact removal)
- Channel interpolation
- Decimation
- Band-pass filter (0.3 – 3 Hz)
- Trial extraction ([-2.5s, 2.5s] from movement onset)
- Compute response time (RT)
- Trial rejection
- Averaging (subject + grand-mean) in Cz channel
- MRCP Topographic mapping

Outputs:

- Inter-subject variability and grand-mean MRCP plots (Cz channel)
- MRCP Topographic maps

---
  
# Exercise 3 — ERD/ERS

Objective:

Analyze sensorimotor rhythms.

Frequency bands:

- Mu: 8–13 Hz
- Beta: 13–30 Hz
  
Steps:

- Detrend
- Band-pass filter (0.3 – 70 Hz)
- Notch filter (50 Hz)
- Bad channel detection
- Re-referencing (CAR)
- ICA (artifact removal)
- Channel interpolation
- Trial extraction ([-2.5s, 5.5s] from movement onset)
- Compute response tiem (RT)
- Mu band filtering (8 - 13 Hz)
- Beta band fitering (13 - 30 Hz)
- Trial rejection
- Power computation
- Temporal smoothing (Movmean) (150 ms)
- Mean between trials
- Baseline normalization
- ERD calculation (%)
- Averaging (subject + grand-mean) in ROI and for Mu/Beta bands
- ERD topographic mapping

Outputs:

- Inter-subject variability and grand-mean plots for Mu/Beta bands (ROI 10%)
- ERD Topographic maps

---

# Design

- Modular implementation (functions)
- Separation of preprocessing/analysis
- NaN masking for bad trials/channels

---

# Notes

Movement onset:

- From dataset events (recommended)
- Or computed from sensors
  
Results depend on preprocessing choices

---

# References

- Ofner et al., 2017
- Pfurtscheller & Lopes da Silva, 1999

---

# License

MIT
