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
# Refactor to include input directory such that input files are in their own directory and script references input files within input directory


#------------------------------------------------------------#
#                                                            #
# User Variable Declarations                                 #
#                                                            #
#------------------------------------------------------------#

# Simulated annealing is a five step process. Step 1 is the basic minimization. Step 2 is the heating protocol. Step 3 is the production MD. Step 4 is the cooling protocol. Step 5 is the production MD post coooling.
# Requires 5 jobs. These should exist in the directory specified by ${path}.
# Requires prmtop and inpcrd files as created by tLEaP. These should exist in the directory specified by ${path}.
# Requires a molecule name. This should be the same as the first four characters of the pdb file.
# Requires a checkpoint file. This could be anything. I have used a file named chk.log in the outputStream directory.
# Sends email to target mail recipient when job completes (recipient must be set in line 4; multiple recipients can be entered by separating addresses with commas.)

path="${PBS_O_HOME}/prepBasics/phoenixData/exactCopy/"
inputDirectory="${path}inputStream/"
firstInput="i02-01_Min.in"
secondInput="i03-02_Heat.in"
thirdInput="i04-03_Prod.in"
fourthInput="i05-04_Cool.in"
fifthInput="i06-05_Prod.in"
moleculeName="1F6M"
chkFile="chk.log"


#------------------------------------------------------------#
#                                                            #
# Private Variable Declarations                              #
#                                                            #
#------------------------------------------------------------#

prmTop="${inputDirectory}${moleculeName}_l_u.prmtop"
inpCrd="${inputDirectory}${moleculeName}_l_u.inpcrd"
firstJob="${inputDirectory}${firstInput}"
secondJob="${inputDirectory}${secondInput}"
thirdJob="${inputDirectory}${thirdInput}"
fourthJob="${inputDirectory}${fourthInput}"
fifthJob="${inputDirectory}${fifthInput}"
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
trajDir="${outDir}trajAnalysis"
trajProd1=""
trajProd2=""
trajUnBound="${inputDirectory}${moleculeName}_l_u.pdb"
trajBound="${inputDirectory}${moleculeName}_l_b.pdb"
rmsd1="${trajDir}/rmsd1-1.in"
rmsd2="${trajDir}/rmsd2-1.in"
rmsd3="${trajDir}/rmsd3-1.in"
rmsd4="${trajDir}/rmsd1-2.in"
rmsd5="${trajDir}/rmsd2-2.in"
rmsd6="${trajDir}/rmsd3-2.in"


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

# Get the job name from the provided .in file
jobName=${firstJob##*-}
jobName=${jobName%%.*}
# Create strings for the various output files. S/b oX-jobName format
outOut="o${outInc}-${jobName}.out"
((outInc++))
rstOut="o${outInc}-${jobName}.rst"
((outInc++))
mdInfoOut="o${outInc}-${jobName}.mdinfo"
((outInc++))
mdCrdOut="o${outInc}-${jobName}.mdcrd"
((outInc++))

# Log & call Sander
echo $"$(date): Submitting job 1" >> ${chkPath}
mpirun sander -O -i ${firstJob} -o ${outPath}/${outOut} -p ${prmTop} -c $inpCrd -r ${outPath}/${rstOut} -inf ${outPath}/${mdInfoOut} -x ${outPath}/${mdCrdOut}

# Log checkpoint & update variables
echo $"$(date): Job 1 completed." >> ${chkPath}
outInc=1
lastPath=${outPath}
lastRst=${rstOut}
((outStep++))
outPath=${outDir}${outStep}


#------------------------------------------------------------#
#                                                            #
# Submit second job to cluster                               #
#                                                            #
#------------------------------------------------------------#

# See first job documentation
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

# See first job documentation
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

# Save .mdcrd file to a variable for reference later
trajProd1=${outPath}/${mdCrdOut}

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

# See first job documentation
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

# See first job documentation
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
trajProd2=${outPath}/${mdCrdOut}

echo $"$(date): Job 5 completed." >> "$chkPath"
outInc=1
lastPath=${outPath}
lastRst=${rstOut}
((outStep++))
outPath=${outDir}${outStep}


#------------------------------------------------------------#
#                                                            #
# cpptraj RMSD Analysis                                      #
#                                                            #
#------------------------------------------------------------# 

# Begin RMSD1 analysis
echo "$(date): Beginning cpptraj analysis. Making directory" >> ${chkPath}
mkdir ${trajDir}
touch ${rmsd1}
echo "parm ${prmTop}" >> ${rmsd1}
echo "trajin ${trajProd1}" >> ${rmsd1}
echo "rmsd ${moleculeName}_l_u_1_ffrmsd out ${trajDir}/rmsd1.agr first mass" >> ${rmsd1}
cp ${rmsd1} ${rmsd4}
sed -i "s|${trajProd1}|${trajProd2}|" ${rmsd4}
sed -i "s|rmsd1.agr|rmsd4.agr|" ${rmsd4}

echo "$(date): Running RMSD analysis 1-1" >> ${chkPath}
cpptraj -i ${rmsd1} >> ${chkPath}
echo "$(date): Running RMSD analysis 1-2" >> ${chkPath}
cpptraj -i ${rmsd4} >> ${chkPath}

# Begin RMSD2 analysis
echo "$(date): Creating RMSD2 input file" >> ${chkPath}
touch ${rmsd2}
echo "parm ${prmTop} [l_u_prmtop]" >> ${rmsd2}
echo "parm ${trajUnBound} [l_u_pdb]" >> ${rmsd2}
echo "trajin ${trajProd1} parm [l_u_prmtop]" >> ${rmsd2}
echo "reference ${trajUnBound} [l_u_rmsd2] parm [l_u_pdb]" >> ${rmsd2}
echo "rmsd ${moleculeName}_l_u_1-ubrmsd :*@CA out ${trajDir}/rmsd2.agr mass ref [l_u_rmsd2]" >> ${rmsd2}
cp ${rmsd2} ${rmsd5}
sed -i "s|${trajProd1}|${trajProd2}|" ${rmsd5}
sed -i "s|rmsd2.agr|rmsd5.agr|" ${rmsd5}

echo "$(date): Running RMSD analysis 2-1" >> ${chkPath}
cpptraj -i ${rmsd2} >> ${chkPath}
echo "$(date): Running RMSD analysis 2-2" >> ${chkPath}
cpptraj -i ${rmsd5} >> ${chkPath}

# Begin RMSD3 analysis
echo "$(date): Creating RMSD3 input file" >> ${chkPath}
touch ${rmsd3}
echo "parm ${prmTop} [l_u_prmtop]" >> ${rmsd3}
echo "parm ${trajBound} [l_b_pdb]" >> ${rmsd3}
echo "trajin ${trajProd1} parm [l_u_prmtop]" >> ${rmsd3}
echo "reference ${trajBound} [l_b_rmsd3] parm [l_b_pdb]" >> ${rmsd3}
echo "rmsd ${moleculeName}_l_u_3-brmsd :*@CA out ${trajDir}/rmsd3.agr mass ref [l_b_rmsd3]" >> ${rmsd3}
cp ${rmsd3} ${rmsd6}
sed -i "s|${trajProd1}|${trajProd2}|" ${rmsd6}
sed -i "s|rmsd3.agr|rmsd6.agr|" ${rmsd6}

echo "$(date): Running RMSD analysis 3-1" >> ${chkPath}
cpptraj -i ${rmsd3} >> ${chkPath}
echo "$(date): Running RMSD analysis 3-2" >> ${chkPath}
cpptraj -i ${rmsd6} >> ${chkPath}


#------------------------------------------------------------#
#                                                            #
# Exit script                                                #
#                                                            #
#------------------------------------------------------------#

echo $"$(date ${dateCode}): Script executed successfully. Exiting now." >> "$chkPath"
exit
