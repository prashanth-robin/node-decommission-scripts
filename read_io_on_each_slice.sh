function read_io_on_each_slice()
{
    vol=$1
    nslices=$(rio volume slices-list $vol | grep NSlices | awk -F ' ' '{print $4}')
    devpath=$(rio mounts list | grep ":$vol:" | awk -F '|' '{print $5}')
    devpath=`echo $devpath | sed 's/ *$//g'`
    for i in $(seq 1 $nslices)
    do
        four_k=`expr 4 \* 1024`
        slice_index=`expr $i - 1`
        offset=`expr 1024 \* 1024 \* 1024 \* $slice_index`
        skip=`expr $offset / $four_k`
        dd if=$devpath of=/dev/null bs=$four_k count=1 skip=$skip
    done
}

function read_io_on_each_slice_for_volumes()
{
    vol=$1
    if [ -z "$vol" ]
    then
        vols=($(rio volume list | grep ":" | awk -F ' | ' '{print $1}'))
        for vol in "${vol[@]}"
        do
            read_io_on_each_slice ${vol:2:1}
        done
    else
        read_io_on_each_slice $vol
    fi
}

vol=$1

read_io_on_each_slice $vol