#!/bin/bash

#
# JS Var2Param
# Discover hidden parameters from JavaScript variables
# Author: r7al38
# Usage: ./js_param_extractor.sh urls.txt
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
info() { echo -e "${BLUE}[*]${NC} $*"; }
success() { echo -e "${GREEN}[+]${NC} $*"; }
warning() { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[-]${NC} $*"; }

# Display banner
echo -e "${CYAN}"
echo "╔════════════════════════════════════════════╗"
echo "║               Var2Param                    ║"
echo "║           Developed by r7al38              ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if input file provided
urls_file=$1
if [ -z "$urls_file" ]; then
    error "Usage: $0 urls.txt"
    info "Example: $0 targets.txt"
    exit 1
fi

# Check if file exists
if [ ! -f "$urls_file" ]; then
    error "File not found: $urls_file"
    exit 1
fi

# Count total URLs
total_urls=$(grep -c . "$urls_file" 2>/dev/null || echo 0)
info "Processing $total_urls URLs from: $urls_file"

# Output file
output_file="js_parameters_$(date +%Y%m%d_%H%M%S).txt"
info "Output will be saved to: $output_file"

# Counters
processed=0
found_vars=0
total_params=0

# Process each URL
while read -r url; do
    # Skip empty lines and comments
    [ -z "$url" ] && continue
    [[ "$url" =~ ^[[:space:]]*# ]] && continue
    
    ((processed++))
    echo -e "\n${YELLOW}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${NC}"
    info "[$processed/$total_urls] Testing: $url"
    
    # Fetch page content with timeout and follow redirects
    content=$(curl -m 10 -s -L "$url" -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" 2>/dev/null)
    
    if [ -z "$content" ]; then
        error "Failed to fetch: $url"
        continue
    fi

    # Extract JavaScript variables with improved patterns
    vars=$(echo "$content" | \
           grep -Eo "(var|let|const|window\.)[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*" | \
           sed -E 's/(var|let|const|window\.)[[:space:]]*//g' | \
           sort -u)

    # Additional pattern: object properties that might be parameters
    obj_props=$(echo "$content" | \
                grep -Eo "[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*:[[:space:]]*\{?" | \
                grep -Eo "^[a-zA-Z_][a-zA-Z0-9_]*" | \
                sort -u)

    # Combine all variables
    all_vars=$(echo -e "$vars\n$obj_props" | sort -u | grep -v '^$')
    
    if [ -z "$all_vars" ]; then
        warning "No JS variables found"
        continue
    fi

    # Count variables found
    var_count=$(echo "$all_vars" | wc -l)
    ((found_vars++))
    ((total_params += var_count))
    
    success "Found $var_count potential parameters"
    
    # Build URLs with different payload types
    echo -e "${GREEN}[+] Generated URLs:${NC}"
    
    for param in $all_vars; do
        # Skip very short or very long parameter names (likely not parameters)
        if [ ${#param} -lt 2 ] || [ ${#param} -gt 30 ]; then
            continue
        fi
        
        # Skip common JavaScript built-in names
        if [[ "$param" =~ ^(function|return|typeof|instanceof|console|document|window|length|name|value)$ ]]; then
            continue
        fi
        
        # Determine separator (? or &)
        if [[ "$url" == *"?"* ]]; then
            separator="&"
        else
            separator="?"
        fi
        
        # Generate different payload types
        echo "${url}${separator}${param}=XSS" | tee -a "$output_file"
        #echo "${url}${separator}${param}=<script>alert(1)</script>" | tee -a "$output_file"
        #echo "${url}${separator}${param}=javascript:alert(1)" | tee -a "$output_file"
    done

done < "$urls_file"

# Summary
echo -e "\n${CYAN}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${NC}"
success "Scan completed!"
info "Processed: $processed URLs"
info "Found variables in: $found_vars URLs" 
info "Total parameters: $total_params"
info "Output file: $output_file"
echo -e "${CYAN}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${NC}"