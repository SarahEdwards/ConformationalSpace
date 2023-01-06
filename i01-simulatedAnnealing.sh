#!/bin/bash

#PBS -m e
#PBS -M xxx@xxxxx.edu
#PBS -j eo
#PBS -t 1-3

#------------------------------------------------------------#
#                                                            #
# Simulated Annealing Protocol Submission Script             #
#                                                            #
#------------------------------------------------------------#

# Notes on PBS Environment variables above:
# -m e mail users on end
# -M xxx@xxxxx.edu email address to notify on job completion
# -j eo join the output file to the error file
# -t 1-3 run the trial in simultaneous triplicate. Use -t 1-3%1 to run consecutive triplicate.



#------------------------------------------------------------#
#                                                            #
# ToDo:                                                      #
#                                                            #
#------------------------------------------------------------#

# Should be updated to accept args later (possibly from command line; alternatively, can pass through qsub)
# Should be updated to add a job name option
# Should copy completed files to new directory for safekeeping (wip. bugged out atm)


#------------------------------------------------------------#
#                                                            #
# User Variable Declarations                                 #
#                                                            #
#------------------------------------------------------------#

# Simulated annealing is a five step process. Step 1 is the basic minimization. Step 2 is the heating protocol. Step 3 is the production MD. Step 4 is the cooling protocol. Step 5 is the production MD post coooling.
# Requires 5 jobs. These should exist in the directory specified by ${path}.
# Requires prmtop and inpcrd files as created by tLEaP. These should exist in the directory specified by ${path}.
# Requires a molecule name. For simplicity, best practice would be to use the same name as the PDB molecule code.
# Requires a checkpoint file. This could be anything. I have used a file named chk.log in the outputStream directory.
# Sends email to target mail recipient when job completes (recipient must be set in line 4; multiple recipients can be entered by separating addresses with commas.)

path="${PBS_O_HOME}/prepBasics/phoenixData/exactCopy/"
firstJob="i02-01_Min.in"
secondJob="i03-02_Heat.in"
thirdJob="i04-03_Prod.in"
fourthJob="i05-04_Cool.in"
fifthJob="i06-05_Prod.in"
prmTop="1F6M_l_u.prmtop"
inpCrd="1F6M_l_u.inpcrd"
moleculeName="1F6M"
chkFile="chk.log"



#------------------------------------------------------------#
#                                                            #
# Private Variable Declarations                              #
#                                                            #
#------------------------------------------------------------#

jobName=""
outOut=""
rstOut=""
mdCrdOut=""
mdInfoOut=""
outInc=1
outStep=1
dateCode=$(date "+%Y-%m-%d_%H-%M-%S")
containerDir="${path}outputStream_${dateCode}/"
outDir="${containerDir}${moleculeName}-${PBS_ARRAYID}/"
chkPath=${outDir}${chkFile}
outPath=${outDir}${outInc}
lastPath=${outPath}
lastRst=""


#------------------------------------------------------------#
#                                                            #
# Setting Up                                                 #
#                                                            #
#------------------------------------------------------------#

cd ${path}
mkdir ${containerDir}
mkdir ${outDir}
touch ${chkPath}
echo $"$(date): Changed working directory to:" >> ${chkPath}
pwd >> ${chkPath}
echo $"Beginning simulated annealing" >> ${chkPath}
mkdir "${outPath}"


#------------------------------------------------------------#
#                                                            #
# Submit first job to cluster                                #
#                                                            #
#------------------------------------------------------------#

jobName=${firstJob##*-}
jobName=${jobName%%.*}
outOut="o${outInc}-${jobName}.out"
((outInc++))
rstOut="o${outInc}-${jobName}.rst"
((outInc++))
mdInfoOut="o${outInc}-${jobName}.mdinfo"
((outInc++))
mdCrdOut="o${outInc}-${jobName}.mdcrd"
((outInc++))

echo $"$(date): Submitting job 1" >> ${chkPath}
mpirun sander -O -i ${firstJob} -o ${outPath}/${outOut} -p ${prmTop} -c $inpCrd -r ${outPath}/${rstOut} -inf ${outPath}/${mdInfoOut} -x ${outPath}/${mdCrdOut}

# qsub -N "01_Min" -z "AmberSubmit_1.sh"  
echo $"$(date): Job 1 completed." >> ${chkPath}
outInc=1
lastPath=${outPath}
lastRst=${rstOut}
# echo ${outPath} >> ${chkPath}
((outStep++))
outPath=${outDir}${outStep}


#------------------------------------------------------------#
#                                                            #
# Submit second job to cluster                               #
#                                                            #
#------------------------------------------------------------#

jobName=${secondJob##*-}
jobName=${jobName%%.*}
outOut="o${outInc}-${jobName}.out"
((outInc++))
rstOut="o${outInc}-${jobName}.rst"
((outInc++))
mdInfoOut="o${outInc}-${jobName}.mdinfo"
((outInc++))
mdCrdOut="o${outInc}-${jobName}.mdcrd"
((outInc++))

mkdir ${outPath}
echo $"$(date): Submitting job 2" >> ${chkPath}
mpirun sander -O -i ${secondJob} -o ${outPath}/${outOut} -p ${prmTop} -c ${lastPath}/${lastRst} -r ${outPath}/${rstOut} -x ${outPath}/${mdCrdOut} -inf ${outPath}/${mdInfoOut}

echo $"$(date): Job 2 completed." >> ${chkPath}
outInc=1
lastPath=${outPath}
lastRst=${rstOut}
((outStep++))
outPath=${outDir}${outStep}


#------------------------------------------------------------#
#                                                            #
# Submit third job to cluster                                #
#                                                            #
#------------------------------------------------------------#

jobName=${thirdJob##*-}
jobName=${jobName%%.*}
outOut="o${outInc}-${jobName}.out"
((outInc++))
rstOut="o${outInc}-${jobName}.rst"
((outInc++))
mdInfoOut="o${outInc}-${jobName}.mdinfo"
((outInc++))
mdCrdOut="o${outInc}-${jobName}.mdcrd"
((outInc++))


mkdir ${outPath}
echo $"$(date): Submitting job 3" >> ${chkPath}
mpirun sander -O -i ${thirdJob} -o ${outPath}/${outOut} -p ${prmTop} -c ${lastPath}/${lastRst} -r ${outPath}/${rstOut} -x ${outPath}/${mdCrdOut} -inf ${outPath}/${mdInfoOut}

echo $"$(date): Job 3 completed." >> "$chkPath"
outInc=1
lastPath=${outPath}
lastRst=${rstOut}
((outStep++))
outPath=${outDir}${outStep}


#------------------------------------------------------------#
#                                                            #
# Submit fourth job to cluster                               #
#                                                            #
#------------------------------------------------------------#

jobName=${fourthJob##*-}
jobName=${jobName%%.*}
outOut="o${outInc}-${jobName}.out"
((outInc++))
rstOut="o${outInc}-${jobName}.rst"
((outInc++))
mdInfoOut="o${outInc}-${jobName}.mdinfo"
((outInc++))
mdCrdOut="o${outInc}-${jobName}.mdcrd"
((outInc++))

mkdir ${outPath}
echo $"$(date): Submitting job 4" >> ${chkPath}
mpirun sander -O -i ${fourthJob} -o ${outPath}/${outOut} -p ${prmTop} -c ${lastPath}/${lastRst} -r ${outPath}/${rstOut} -x ${outPath}/${mdCrdOut} -inf ${outPath}/${mdInfoOut}

echo $"$(date): job 4 completed." >> "$chkPath"
outInc=1
lastPath=${outPath}
lastRst=${rstOut}
((outStep++))
outPath=${outDir}${outStep}


#------------------------------------------------------------#
#                                                            #
# Submit fifth job to cluster                                #
#                                                            #
#------------------------------------------------------------#

jobName=${fifthJob##*-}
jobName=${jobName%%.*}
outOut="o${outInc}-${jobName}.out"
((outInc++))
rstOut="o${outInc}-${jobName}.rst"
((outInc++))
mdInfoOut="o${outInc}-${jobName}.mdinfo"
((outInc++))
mdCrdOut="o${outInc}-${jobName}.mdcrd"
((outInc))

mkdir ${outPath}
echo $"$(date): Submitting job 5" >> ${chkPath}
mpirun sander -O -i $fifthJob -o ${outPath}/${outOut} -p ${prmTop} -c ${lastPath}/${lastRst} -r ${outPath}/${rstOut} -x ${outPath}/${mdCrdOut} -inf ${outPath}/${mdInfoOut}
echo $"$(date): Job 5 completed." >> "$chkPath"
outInc=1
lastPath=${outPath}
lastRst=${rstOut}
((outStep++))
outPath=${outDir}${outStep}


#------------------------------------------------------------#
#                                                            #
# Finishing Up                                               #
#                                                            #
#------------------------------------------------------------#

# Save output to unique directory

# find ./ -type d -iname "outputStream/" -exec bash -c cp -r -b -S "(1)" {} ${path}${moleculeName} \;


#------------------------------------------------------------#
#                                                            #
# Exit script                                                #
#                                                            #
#------------------------------------------------------------#

echo $"$(date ${dateCode}): Script executed successfully. Exiting now." >> "$chkPath"
exit
