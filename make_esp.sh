#!/bin/bash
#written by Alechania Misturini - 2018

#whats necessary? .xyz
#		  marathon

# usage: ./make-esp.sh  xyz(without .xyz) optlevel(scape special characters)  nprocs-opt  nprocs-esp
#    ex: ./make-esp.sh compound MP2/6-311G\* 8 2
#     or
#    ex: nohup ./make-esp.sh compound MP2/6-311G\* 8 2 &
#      (still running, even if you exit terminal, in background)

#for neutral molecules in a singlet state!
#kill tail with ctrl+D

#variables
xyz="$1"
optlevel="$2"
nproc1="$3"
nproc2="$4"

enter="If this step is ok, press [Enter] key to continue..."
end="If it's all ok, press [Enter] to finish. Good Job!"

#Colors
RED='\033[0;31m'
NC='\033[0m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
MAG='\033[0;95m'

#pause
function pause(){
   read -p "$*"
}

###

#generate gjf opt-----------------------------------------------------------------
echo -e "${RED}GENERATE GJF FILE OPT ${optlevel} ${NC}"

echo -e "%nproc=${nproc1}
%chk=${xyz}_opt
#P ${optlevel} Opt

${xyz} opt

0 1

" > ${xyz}_opt.gjf

tail -n+3 ${xyz}.xyz > xyzcut

sed -i '7 r xyzcut' ${xyz}_opt.gjf

cat ${xyz}_opt.gjf

rm -f xyzcut

pause $(echo -e ${BLUE}$enter${NC})

#run opt-----------------------------------------------------------------

echo -e "${MAG}RUN OPT WITH GAUSSIAN09: kill tail with ctrl+D ${NC}"

marathon g09 ${xyz}_opt.gjf &

pause $(echo -e ${BLUE}$enter${NC})

tail -f ${xyz}_opt.out &       #put & to execute on backgroud
read -sn 1                     #wait for user input
kill %1                        #kill the first background progress

pause $(echo -e ${BLUE}$enter${NC})

cp ${xyz}_opt.chk ./${xyz}_esp.chk

#generate gjf esp -----------------------------------------------------------------
echo -e "${RED}GENERATE GJF FILE OPT B3LYP/6-31G*${NC}"

echo -e "%nproc=${nproc2}
%mem=256MB
%chk=${xyz}_esp
#P HF/6-31G* Geom=check SCF=Tight Pop=MK IOp(6/33=2,6/41=10,6/42=17)

${xyz} esp HF

0 1


" > ${xyz}_esp.gjf

cat ${xyz}_esp.gjf

pause $(echo -e ${BLUE}$enter${NC})

#run single-point-----------------------------------------------------------------
echo -e "${MAG}RUN ESP WITH GAUSSIAN09: kill tail with ctrl+D ${NC}"

marathon g09 ${xyz}_esp.gjf &

pause $(echo -e ${BLUE}$enter${NC})

tail -f ${xyz}_esp.out &           #put & to execute on backgroud
read -sn 1                 #wait for user input
kill %1                    #kill the first background progress

pause $(echo -e ${GREEN}$end${NC})
