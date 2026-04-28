database -open waves -shm
# probe -create top -depth all -all -shm -database waves -memories
probe -create top -depth all -all -shm -database waves -memories -unpacked 65536
#probe -create -shm top -all -memories -depth all
run 
exit
