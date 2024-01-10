#!/bin/sh
# This script can be used to download all the necessary Timesketch configuration
# files locally to this machine. Please run when you'd like to make some more
# changes to the config file before deployment.
# Copied and modified from here: https://github.com/google/osdfir-infrastructure/tree/main/tools
set -o posix
set -e

# Create config directory
mkdir -p configs/

echo "* Fetching configuration files..."
GITHUB_TS_BASE_URL="https://raw.githubusercontent.com/google/timesketch/master"
GITHUB_TS_MOD_URL="https://raw.githubusercontent.com/jkppr/timesketch-configs/main"
# Fetch default & modified Timesketch config files
wget $GITHUB_TS_MOD_URL/data/timesketch.conf -O configs/timesketch.conf
wget $GITHUB_TS_BASE_URL/data/tags.yaml -O configs/tags.yaml
wget $GITHUB_TS_BASE_URL/data/plaso.mappings -O configs/plaso.mappings
wget $GITHUB_TS_BASE_URL/data/plaso_formatters.yaml -O configs/plaso_formatters.yaml
wget $GITHUB_TS_BASE_URL/data/generic.mappings -O configs/generic.mappings
wget $GITHUB_TS_BASE_URL/data/winevt_features.yaml -O configs/winevt_features.yaml
wget $GITHUB_TS_BASE_URL/data/regex_features.yaml -O configs/regex_features.yaml
wget $GITHUB_TS_BASE_URL/data/ontology.yaml -O configs/ontology.yaml
wget $GITHUB_TS_BASE_URL/data/intelligence_tag_metadata.yaml -O configs/intelligence_tag_metadata.yaml
wget $GITHUB_TS_BASE_URL/data/sigma_config.yaml -O configs/sigma_config.yaml
wget $GITHUB_TS_BASE_URL/data/sigma/rules/lnx_susp_zmap.yml -O configs/lnx_susp_zmap.yml
wget $GITHUB_TS_MOD_URL/data/context_links.yaml -O configs/context_links.yaml
wget $GITHUB_TS_BASE_URL/data/scenarios/facets.yaml -O configs/facets.yaml
wget $GITHUB_TS_BASE_URL/data/scenarios/questions.yaml -O configs/questions.yaml
wget $GITHUB_TS_BASE_URL/data/scenarios/scenarios.yaml -O configs/scenarios.yaml
echo "DONE"
