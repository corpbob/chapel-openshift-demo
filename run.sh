PROG=$1      
NL=$2
export GASNET_SPAWNFN=S

source /home/chapel/mnt/exports
$PROG -nl $NL 
