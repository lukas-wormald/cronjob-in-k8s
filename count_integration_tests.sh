#!/bin/bash

# This script outputs the number of integration tests currently written to date:
# This script is to be run Monday, Wednesday, and Friday each week at 4:30pm using a cron job

# give cron access to the big directory to run the dazel query
cd /home/lwormald/git/big

# Variable for pathway to dazel query:
dazel_path=/home/lwormald/.local/bin/dazel

current_day=$(date +"%m-%d-%y")

# Separate the integration tests from the manual ones so the number of manual tests are not included in the final count
# wc -l outputs just the number of tests instead of having each file listed including the pathway to that file
# also have variables for the number of integration tests with a manual tag

livemonitor_count=$($dazel_path query 'filter("integration_test_*", tests(//livemonitor/...))' | wc -l)
livemonitor_manual_count=$($dazel_path query 'attr("tags", "manual", filter("integration_test_*", tests(//livemonitor/...)))' | wc -l)

vodmonitor_count=$($dazel_path query 'filter("integration_test_*", tests(//vodmonitor/...))' | wc -l)
vodmonitor_manual_count=$($dazel_path query 'attr("tags", "manual", filter("integration_test_*", tests(//vodmonitor/...)))' | wc -l)

deployment_count=$($dazel_path query 'filter("integration_test_*", tests(//deploy/...))' | wc -l)
deployment_manual_count=$($dazel_path query 'attr("tags", "manual", filter("integration_test_*", tests(//deploy/...)))' | wc -l)

# function to output the data to the slack channel: integration_tests

slack_output ()
{
	curl -X POST -H 'Content-type: application/json' --data '{"text": "'"$1 $2"'"}' https://hooks.slack.com/services/letters
}

# function to output the data to a csv file

csv_output ()
{
	printf '%s' "$1" "$2" ' and ' "$3" ' are set to manual' | paste -sd ' ' >> tools/test/num_integration_tests.csv
}

# slack channel output

slack_output "Number of Livemonitor Integration Tests: $livemonitor_count and $livemonitor_manual_count are set to manual"

slack_output "Number of Vodmonitor Integration Tests: $vodmonitor_count and $vodmonitor_manual_count are set to manual"

slack_output "Number of Deployment Related Integration Tests: $deployment_count and $deployment_manual_count are set to manual"

# csv file output

csv_output 'Current Date: ' $current_day

csv_output 'Number of Livemonitor Integration Tests: ' $livemonitor_count $livemonitor_manual_count

csv_output 'Number of Vodmonitor Integration Tests: ' $vodmonitor_count $vodmonitor_manual_count

csv_output 'Number of Deployment Related Integration Tests: ' $deployment_count $deployment_manual_count
