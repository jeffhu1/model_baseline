# #!/bin/bash

# TASK_ID="25094a63"
# NUM_RUNS=100
# NUM_JOBS=100
# BASE_DIR="submissions/deepseek-r1-25094a63"

# parallel --jobs $NUM_JOBS \
#     python3 -m main \
#     --data_dir data/arc-agi/data/evaluation \
#     --num_attempts 1 \
#     --provider deepseek \
#     --model deepseek-reasoner \
#     --task_id $TASK_ID \
#     --save_submission_dir "$BASE_DIR/run_{}" \
#     --print_logs ::: $(seq 1 $NUM_RUNS) 

#!/bin/bash

# TASK_ID="25094a63"
# NUM_RUNS=1
# NUM_JOBS=1
# BASE_DIR="submissions/deepseek-r1-25094a63"
# RESULTS_DIR="results/deepseek-r1-25094a63"

# # Create base directories
# mkdir -p "$BASE_DIR"
# mkdir -p "$RESULTS_DIR"

# # Run parallel commands
# parallel --jobs $NUM_JOBS \
#     'mkdir -p "$0/run_{1}" && \
#     python3 -m main \
#         --data_dir data/arc-agi/data/evaluation \
#         --num_attempts 1 \
#         --provider deepseek \
#         --model deepseek-reasoner \
#         --task_id '$TASK_ID' \
#         --save_submission_dir "$0/run_{1}" \
#         --print_logs && \
#     python3 -m src.scoring.scoring \
#         --task_dir data/arc-agi/data/evaluation \
#         --submission_dir "$0/run_{1}" \
#         --results_dir "$1/run_{1}"' \
#     ::: $BASE_DIR ::: $RESULTS_DIR ::: $(seq 1 $NUM_RUNS)

# # Create summary of results
# echo "Run,Score" > "$RESULTS_DIR/aggregate_results.csv"
# for i in $(seq 1 $NUM_RUNS); do
#     if [ -f "$RESULTS_DIR/run_$i/scores.json" ]; then
#         SCORE=$(jq '.score' "$RESULTS_DIR/run_$i/scores.json")
#         echo "$i,$SCORE" >> "$RESULTS_DIR/aggregate_results.csv"
#     else
#         echo "$i,failed" >> "$RESULTS_DIR/aggregate_results.csv"
#     fi
# done

# # Print summary statistics
# echo "Summary Statistics:"
# echo "Total runs: $NUM_RUNS"
# echo "Successful runs: $(grep -v "failed" "$RESULTS_DIR/aggregate_results.csv" | wc -l)"
# echo "Average score: $(grep -v "failed" "$RESULTS_DIR/aggregate_results.csv" | awk -F',' 'NR>1{sum+=$2; count++} END{print sum/count}')"

#!/bin/bash

TASK_ID="25094a63"
NUM_RUNS=100
NUM_JOBS=100  # Reduced from 100 to a more reasonable number
BASE_DIR="submissions/deepseek-r1-25094a63"
RESULTS_DIR="results/deepseek-r1-25094a63"

# Create base directories
mkdir -p "$BASE_DIR"
mkdir -p "$RESULTS_DIR"

# Run parallel commands
parallel --jobs $NUM_JOBS \
    mkdir -p "$BASE_DIR/run_{}" ";" \
    python3 -m main \
        --data_dir data/arc-agi/data/evaluation \
        --num_attempts 1 \
        --provider deepseek \
        --model deepseek-reasoner \
        --task_id "$TASK_ID" \
        --save_submission_dir "$BASE_DIR/run_{}" \
        --print_logs ";" \
    python3 -m src.scoring.scoring \
        --task_dir data/arc-agi/data/evaluation \
        --submission_dir "$BASE_DIR/run_{}" \
        --results_dir "$RESULTS_DIR/run_{}" \
    ::: $(seq 1 $NUM_RUNS)

# Create summary of results
echo "Run,Score" > "$RESULTS_DIR/aggregate_results.csv"
for i in $(seq 1 $NUM_RUNS); do
    if [ -f "$RESULTS_DIR/run_$i/scores.json" ]; then
        SCORE=$(jq '.score' "$RESULTS_DIR/run_$i/scores.json")
        echo "$i,$SCORE" >> "$RESULTS_DIR/aggregate_results.csv"
    else
        echo "$i,failed" >> "$RESULTS_DIR/aggregate_results.csv"
    fi
done

# Print summary statistics
echo "Summary Statistics:"
echo "Total runs: $NUM_RUNS"
SUCCESSFUL_RUNS=$(grep -v "failed" "$RESULTS_DIR/aggregate_results.csv" | wc -l)
echo "Successful runs: $((SUCCESSFUL_RUNS-1))"  # Subtract 1 for header

if [ $SUCCESSFUL_RUNS -gt 1 ]; then
    echo "Average score: $(grep -v "failed" "$RESULTS_DIR/aggregate_results.csv" | awk -F',' 'NR>1{sum+=$2; count++} END{if(count>0) print sum/count; else print "N/A"}')"
else
    echo "Average score: N/A"
fi