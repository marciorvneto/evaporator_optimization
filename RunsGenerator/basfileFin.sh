#!/bin/bash
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 12
#SBATCH --contiguous
#SBATCH --mem-per-cpu=3000 
#SBATCH --time 14-0:00:00
#SBATCH --job-name ev3E_Fin
#SBATCH --error ERRORLOG_ev3E_Fin.log
#SBATCH --output OUTPUTLOG_ev3E_Fin.log
#SBATCH --partition hydra
#SBATCH --mail-type=end
#SBATCH --mail-user=saari@lut.fi
module load matlab
cd /home/saari/FINAL_OPTIMIZER/RunsGenerator/
srun --mpi=pmi2 matlab -nodisplay -nosplash -r make
