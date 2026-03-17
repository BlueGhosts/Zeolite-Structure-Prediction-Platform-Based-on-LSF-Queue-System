# Zeolite Structure Prediction Platform
A high-throughput computing platform for zeolite structure prediction based on LSF (Load Sharing Facility) queue system.
## Overview
This platform implements a structure construction method based on Wyckoff position combination enumeration. By constraining and enumerating the symmetric positions of each atom in the unit cell, it achieves balanced exploration of conformational space and decomposes complex structure prediction tasks into multiple subtasks with significantly reduced complexity.
## Features
- **Wyckoff Position Enumeration**: Systematic exploration of atomic symmetric positions for balanced conformational space sampling
- **Dynamic Resource Allocation**: Automatically terminates low-yield tasks and allocates more cycles to high-yield combinations
- **Self-Repair Mechanism**: Detects failed geometry optimizations, fine-tunes atomic coordinates, and retries (up to 5 attempts)
- **Complete Workflow**: Structure generation → Deduplication → Bridging oxygen addition → Geometry optimization → Rationality assessment
## Requirements
- LSF (Load Sharing Facility) queue system
- Python 3.6+
- [FraGen](link-to-fragen) - Framework structure generator
- [GULP](https://gulp.curtin.edu.au/) - Geometry optimization
## Installation
```bash
git clone https://github.com/yourusername/zeolite-prediction.git
cd zeolite-prediction
Ensure FraGen and GULP are properly installed and accessible in your PATH.

Usage
Step 1: Generate Initial Structures
<BASH>
./FraGen.sh
Generates initial zeolite structure models based on Wyckoff position combinations.

Step 2: Post-Processing and Evaluation
<BASH>
./GetZeolite.sh
Performs structure deduplication, bridging oxygen addition, geometry optimization (via GULP), and LID rationality assessment.

Output
<TEXT>
project/
├── AllGULP_cif/      # Successfully optimized structures
├── AllLID_cif/       # Structures passing LID rationality rules
├── FraGen_lsf/       # Logs for structure generation
└── GetZeolite_lsf/   # Logs for post-processing
Directory	Description
AllGULP_cif/	CIF files of structures that passed GULP geometry optimization
AllLID_cif/	CIF files of structures satisfying LID (Local Interatomic Distance) rules
How It Works
Traditional structure prediction methods use atomic fusion, where atoms are placed at non-special positions and may fuse when meeting at symmetric positions. However, this approach has limitations:

Fusion at positions requiring multiple atoms is difficult due to atomic repulsion
Once fused, atoms cannot separate, often reducing the number of atoms in the unit cell
Our method addresses these challenges by directly enumerating Wyckoff position combinations, enabling systematic exploration of structures where T atoms occupy special symmetric positions (which occurs in ~70% of zeolite structures).