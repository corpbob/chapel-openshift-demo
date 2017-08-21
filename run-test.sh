export GASNET_SPAWNFN=S
source /home/chapel/mnt/exports

./hello6-taskpar-dist -nl $*
