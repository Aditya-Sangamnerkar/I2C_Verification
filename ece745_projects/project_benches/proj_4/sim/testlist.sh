#!/bin/bash
start_time=$(date +%s)
echo "deleting old log files.."
rm -f *.log
log=output_log.log
log2=results.log
echo "deleting old ucdb files.."
make delete
echo "running i2cmb_test ..."
make cli GEN_TEST_TYPE=i2cmb_test TEST_SEED=12345 > $log
echo "running i2cmb random test ..."
make cli GEN_TEST_TYPE=i2cmb_random_test TEST_SEED=54321 >> $log
echo "running i2cmb register test ..."
make cli GEN_TEST_TYPE=i2cmb_register_test TEST_SEED=54321 >> $log
echo "generating results ..."
grep 'tst.env.scbd\|I2C\|MATCH\|register values' $log > $log2
end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
echo "elapsed time : ${elapsed} seconds" >> $log2
make merge_coverage 
make view_coverage 
echo "test results in results.log.."

