#!/bin/bash

start=$(date +%s)

make FLASH

end=$(date +%s)
execution_time=$((end - start))

echo "Total flashing time: $execution_time seconds"
