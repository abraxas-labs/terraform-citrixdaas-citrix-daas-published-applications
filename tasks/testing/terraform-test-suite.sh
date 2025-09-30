#!/bin/bash

# =============================================================================
# Citrix DaaS Terraform Test Suite
# =============================================================================
# Interactive testing framework for safe Terraform destroy/deploy operations
# Created: 2025-09-26
# Version: 1.0.0

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# =============================================================================
# Configuration
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../../terraform"
LOG_DIR="${SCRIPT_DIR}/logs"
BACKUP_DIR="${SCRIPT_DIR}/backups"
PERFORMANCE_DIR="${SCRIPT_DIR}/performance"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
LOG_FILE="${LOG_DIR}/terraform-test-${TIMESTAMP}.log"
PERFORMANCE_FILE="${PERFORMANCE_DIR}/timing-history.json"

# Environment Variables (parsed from customer.auto.tfvars)
CUSTOMER_TFVARS="${TERRAFORM_DIR}/customer.auto.tfvars"
ENV_MANDANT="UNKNOWN"
ENV_ENVIRONMENT="UNKNOWN"
ENV_CUSTOMER="UNKNOWN"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# =============================================================================
# Utility Functions
# =============================================================================

# Performance tracking functions
save_performance_data() {
    local operation="$1"
    local duration_seconds="$2"
    local success="${3:-true}"
    local resource_count="${4:-0}"

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Create new run entry
    local new_run=$(cat <<EOF
{
  "timestamp": "$timestamp",
  "operation": "$operation",
  "environment": "$ENV_ENVIRONMENT",
  "mandant": "$ENV_MANDANT",
  "customer": "$ENV_CUSTOMER",
  "duration_seconds": $duration_seconds,
  "resource_count": $resource_count,
  "success": $success
}
EOF
    )

    # Read existing data, add new run, keep only last 10
    if [[ -f "$PERFORMANCE_FILE" ]]; then
        # Use jq to add new run and keep only last 10
        local temp_file="${PERFORMANCE_FILE}.tmp"
        echo "$new_run" | jq -s ". as [\$new] | $(cat "$PERFORMANCE_FILE") | .runs += [\$new] | .runs |= .[-10:]" > "$temp_file"
        mv "$temp_file" "$PERFORMANCE_FILE"
    else
        # Create new file with first run
        echo "{\"runs\": [$new_run]}" | jq '.' > "$PERFORMANCE_FILE"
    fi

    print_success "Performance data saved: $operation completed in ${duration_seconds}s"
}

format_duration() {
    local seconds=$1
    local minutes=$((seconds / 60))
    local remaining_seconds=$((seconds % 60))

    if [[ $minutes -gt 0 ]]; then
        echo "${minutes}m ${remaining_seconds}s"
    else
        echo "${seconds}s"
    fi
}

# Parse environment variables from customer.auto.tfvars
parse_customer_tfvars() {
    if [[ -f "$CUSTOMER_TFVARS" ]]; then
        # Parse mvd_mandant
        if grep -q '^mvd_mandant' "$CUSTOMER_TFVARS"; then
            ENV_MANDANT=$(grep '^mvd_mandant' "$CUSTOMER_TFVARS" | sed 's/.*=\s*"\([^"]*\)".*/\1/' | tr -d ' ')
        fi

        # Parse mvd_environment
        if grep -q '^mvd_environment' "$CUSTOMER_TFVARS"; then
            ENV_ENVIRONMENT=$(grep '^mvd_environment' "$CUSTOMER_TFVARS" | sed 's/.*=\s*"\([^"]*\)".*/\1/' | tr -d ' ')
        fi

        # Parse mvd_customer_code
        if grep -q '^mvd_customer_code' "$CUSTOMER_TFVARS"; then
            ENV_CUSTOMER=$(grep '^mvd_customer_code' "$CUSTOMER_TFVARS" | sed 's/.*=\s*"\([^"]*\)".*/\1/' | tr -d ' ')
        fi
    fi
}

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

print_header() {
    echo -e "\n${PURPLE}=== $1 ===${NC}" | tee -a "$LOG_FILE"
}

# Confirmation prompt
confirm() {
    local message="$1"
    local default="${2:-n}"

    if [[ "$default" == "y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi

    while true; do
        read -p "$(echo -e "${CYAN}$message $prompt: ${NC}")" response
        response=${response:-$default}
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]) return 1 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

# Create directories
setup_directories() {
    mkdir -p "$LOG_DIR" "$BACKUP_DIR" "$PERFORMANCE_DIR"
    print_success "Created log, backup and performance directories"

    # Initialize performance file if it doesn't exist
    if [[ ! -f "$PERFORMANCE_FILE" ]]; then
        echo '{"runs": []}' > "$PERFORMANCE_FILE"
        print_success "Initialized performance tracking file"
    fi
}

# Change to terraform directory
cd_terraform() {
    if [[ ! -d "$TERRAFORM_DIR" ]]; then
        print_error "Terraform directory not found: $TERRAFORM_DIR"
        exit 1
    fi
    cd "$TERRAFORM_DIR"
    print_info "Working directory: $(pwd)"
}

# =============================================================================
# Environment Validation Functions
# =============================================================================

check_environment_variables() {
    print_header "Environment Variables Validation"

    local required_vars=(
        "TF_VAR_mvd_mandant"
        "TF_VAR_mvd_customer_code"
        "TF_VAR_mvd_environment"
        "TF_VAR_customer_id"
        "TF_VAR_client_id"
        "TF_VAR_client_secret"
        "TF_VAR_azure_subscription_id"
        "TF_VAR_azure_tenant_id"
        "TF_VAR_azure_application_id"
        "TF_VAR_azure_application_secret"
        "TF_VAR_azure_vm_admin_username"
        "TF_VAR_gitlab_token"
        "TF_VAR_gitlab_url"
        "TF_VAR_target_project_path"
    )

    local missing_vars=()

    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("$var")
            print_error "Missing required environment variable: $var"
        else
            # Mask sensitive variables in logs
            if [[ "$var" == *"secret"* || "$var" == *"token"* ]]; then
                print_success "$var: ***MASKED***"
            else
                print_success "$var: ${!var}"
            fi
        fi
    done

    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        print_error "Missing ${#missing_vars[@]} required environment variables"
        print_info "Please set the following variables and run the script again:"
        printf '%s\n' "${missing_vars[@]}"
        return 1
    fi

    print_success "All required environment variables are set"
    return 0
}

check_tools() {
    print_header "Required Tools Check"

    local required_tools=("terraform" "az" "git")
    local missing_tools=()

    for tool in "${required_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            local version
            case "$tool" in
                terraform) version=$(terraform version -json | jq -r '.terraform_version') ;;
                az) version=$(az version --query '"azure-cli"' -o tsv) ;;
                git) version=$(git --version | cut -d' ' -f3) ;;
            esac
            print_success "$tool: $version"
        else
            missing_tools+=("$tool")
            print_error "Missing required tool: $tool"
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Missing ${#missing_tools[@]} required tools"
        return 1
    fi

    print_success "All required tools are available"
    return 0
}

check_terraform_version() {
    print_header "Terraform Version Validation"

    local tf_version
    tf_version=$(terraform version -json | jq -r '.terraform_version')
    local required_version="1.9.0"

    if [[ "$(printf '%s\n' "$required_version" "$tf_version" | sort -V | head -n1)" == "$required_version" ]]; then
        print_success "Terraform version $tf_version meets requirement (>= $required_version)"
        return 0
    else
        print_error "Terraform version $tf_version does not meet requirement (>= $required_version)"
        return 1
    fi
}

check_provider_connectivity() {
    print_header "Provider Connectivity Check"

    # Azure connectivity
    print_info "Checking Azure connectivity..."
    if az account show >/dev/null 2>&1; then
        local subscription
        subscription=$(az account show --query 'name' -o tsv)
        print_success "Azure CLI authenticated - Subscription: $subscription"
    else
        print_error "Azure CLI not authenticated. Run 'az login'"
        return 1
    fi

    # Terraform init check
    print_info "Checking Terraform initialization..."
    if terraform init -backend=false >/dev/null 2>&1; then
        print_success "Terraform initialization successful"
    else
        print_error "Terraform initialization failed"
        return 1
    fi

    return 0
}

validate_terraform_config() {
    print_header "Terraform Configuration Validation"

    # Format check
    if terraform fmt -check -recursive >/dev/null 2>&1; then
        print_success "Terraform formatting is correct"
    else
        print_warning "Terraform files need formatting"
        if confirm "Run 'terraform fmt -recursive' now?"; then
            terraform fmt -recursive
            print_success "Terraform formatting applied"
        fi
    fi

    # Validate syntax
    if terraform validate >/dev/null 2>&1; then
        print_success "Terraform configuration is valid"
    else
        print_error "Terraform configuration validation failed"
        terraform validate
        return 1
    fi

    return 0
}

# =============================================================================
# Backup and State Management Functions
# =============================================================================

backup_state_file() {
    print_header "State File Backup"

    # Check if using remote backend (GitLab HTTP backend)
    if [[ -f ".terraform/terraform.tfstate" ]]; then
        # Local state file in .terraform directory
        local local_state=".terraform/terraform.tfstate"
        local backup_file="${BACKUP_DIR}/terraform.tfstate.backup-${TIMESTAMP}"
        cp "$local_state" "$backup_file"
        print_success "Local state file backed up to: $backup_file"
    elif terraform state pull > /dev/null 2>&1; then
        # Remote state (GitLab HTTP backend) - pull and backup
        local backup_file="${BACKUP_DIR}/terraform.tfstate.backup-${TIMESTAMP}"
        if terraform state pull > "$backup_file" 2>/dev/null; then
            print_success "Remote state backed up from GitLab to: $backup_file"
        else
            print_warning "Failed to pull remote state for backup"
            return 1
        fi
    elif [[ -f "terraform.tfstate" ]]; then
        # Traditional local state file
        local backup_file="${BACKUP_DIR}/terraform.tfstate.backup-${TIMESTAMP}"
        cp "terraform.tfstate" "$backup_file"
        print_success "State file backed up to: $backup_file"
    else
        print_warning "No state file found (local or remote) - this might be a fresh deployment"
        return 0
    fi

    # Also backup lock file if it exists
    if [[ -f ".terraform.lock.hcl" ]]; then
        cp ".terraform.lock.hcl" "${BACKUP_DIR}/.terraform.lock.hcl.backup-${TIMESTAMP}"
        print_success "Lock file backed up"
    fi

    return 0
}

document_current_state() {
    print_header "Current State Documentation"

    local state_file="${BACKUP_DIR}/pre-test-state-${TIMESTAMP}.txt"
    local resources_file="${BACKUP_DIR}/pre-test-resources-${TIMESTAMP}.txt"

    if terraform show > "$state_file" 2>/dev/null; then
        print_success "Current state documented: $state_file"
    else
        print_warning "Could not document current state (empty or no state)"
    fi

    if terraform state list > "$resources_file" 2>/dev/null; then
        local resource_count
        resource_count=$(wc -l < "$resources_file")
        print_success "Resource list documented: $resources_file ($resource_count resources)"
    else
        print_warning "Could not list resources (empty or no state)"
    fi

    return 0
}

restore_state_backup() {
    print_header "State File Restoration"

    # List available backups
    local backups
    backups=($(ls "$BACKUP_DIR"/terraform.tfstate.backup-* 2>/dev/null | sort -r || true))

    if [[ ${#backups[@]} -eq 0 ]]; then
        print_error "No state file backups found"
        return 1
    fi

    echo "Available backups:"
    for i in "${!backups[@]}"; do
        local backup="${backups[$i]}"
        local timestamp
        timestamp=$(basename "$backup" | sed 's/terraform.tfstate.backup-//')
        echo "  $((i+1))) $timestamp"
    done

    read -p "Select backup to restore (1-${#backups[@]}): " selection

    if [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -le ${#backups[@]} ]]; then
        local selected_backup="${backups[$((selection-1))]}"

        if confirm "Restore state from $(basename "$selected_backup")?"; then
            # Check if using remote backend (GitLab HTTP backend)
            if terraform state pull > /dev/null 2>&1; then
                # Remote state - push backup to remote backend
                if terraform state push "$selected_backup"; then
                    print_success "State file restored to GitLab remote backend"
                    return 0
                else
                    print_error "Failed to push state to remote backend"
                    return 1
                fi
            else
                # Local state - copy backup to local state file
                cp "$selected_backup" "terraform.tfstate"
                print_success "State file restored from backup"
                return 0
            fi
        fi
    else
        print_error "Invalid selection"
        return 1
    fi

    return 1
}

# =============================================================================
# Terraform Operations
# =============================================================================

generate_plan() {
    local plan_type="$1"  # "deploy" or "destroy"
    local plan_file="${plan_type}.tfplan"
    local auto_mode="${2:-false}"  # Auto mode flag

    print_header "Generating $plan_type Plan"

    local tf_command="terraform plan -var-file=customer.auto.tfvars -var-file=sklad.auto.tfvars -out=$plan_file"
    if [[ "$plan_type" == "destroy" ]]; then
        tf_command="terraform plan -destroy -var-file=customer.auto.tfvars -var-file=sklad.auto.tfvars -out=$plan_file"
    fi

    print_info "Running: $tf_command"

    if eval "$tf_command"; then
        print_success "$plan_type plan generated successfully: $plan_file"

        # Skip plan review in auto mode
        if [[ "$auto_mode" != "true" ]] && confirm "Review $plan_type plan?"; then
            terraform show "$plan_file"
        fi

        return 0
    else
        print_error "$plan_type plan generation failed"
        return 1
    fi
}

apply_plan() {
    local plan_file="$1"
    local operation="${2:-apply}"
    local auto_mode="${3:-false}"  # Auto mode flag

    print_header "Applying Plan: $plan_file"

    if [[ ! -f "$plan_file" ]]; then
        print_error "Plan file not found: $plan_file"
        return 1
    fi

    print_warning "About to apply plan: $plan_file"

    # Skip confirmation in auto mode
    if [[ "$auto_mode" != "true" ]] && ! confirm "Continue with $operation operation?" "n"; then
        print_info "Operation cancelled by user"
        return 1
    fi

    local start_time=$(date +%s)

    if terraform apply "$plan_file"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        print_success "$operation completed successfully in ${duration}s"
        rm -f "$plan_file"  # Clean up plan file
        return 0
    else
        print_error "$operation failed"
        return 1
    fi
}

verify_deployment() {
    print_header "Deployment Verification"

    # Check for configuration drift
    print_info "Checking for configuration drift..."
    if terraform plan -detailed-exitcode -var-file=customer.auto.tfvars -var-file=sklad.auto.tfvars >/dev/null 2>&1; then
        print_success "No configuration drift detected"
    else
        local exit_code=$?
        if [[ $exit_code -eq 2 ]]; then
            print_warning "Configuration drift detected"
            if confirm "Show drift details?"; then
                terraform plan -var-file=customer.auto.tfvars -var-file=sklad.auto.tfvars
            fi
        else
            print_error "Error checking for drift"
            return 1
        fi
    fi

    # List current resources
    local current_resources
    current_resources=$(terraform state list | wc -l)
    print_success "Current resource count: $current_resources"

    return 0
}

verify_deployment_auto() {
    print_header "Deployment Verification (Automated)"

    # Check for configuration drift
    print_info "Checking for configuration drift..."
    if terraform plan -detailed-exitcode -var-file=customer.auto.tfvars -var-file=sklad.auto.tfvars >/dev/null 2>&1; then
        print_success "No configuration drift detected"
    else
        local exit_code=$?
        if [[ $exit_code -eq 2 ]]; then
            print_warning "Configuration drift detected"
            # Show drift details automatically in auto mode
            terraform plan -var-file=customer.auto.tfvars -var-file=sklad.auto.tfvars
        else
            print_error "Error checking for drift"
            return 1
        fi
    fi

    # List current resources
    local current_resources
    current_resources=$(terraform state list | wc -l)
    print_success "Current resource count: $current_resources"

    return 0
}

# =============================================================================
# Performance Statistics Functions
# =============================================================================

show_performance_statistics() {
    print_header "Performance Statistics Dashboard"

    if [[ ! -f "$PERFORMANCE_FILE" ]]; then
        print_warning "No performance data available yet. Run some tests first!"
        return 0
    fi

    # Check if jq is available
    if ! command -v jq >/dev/null 2>&1; then
        print_error "jq is required for performance statistics. Please install jq."
        return 1
    fi

    local total_runs
    total_runs=$(jq '.runs | length' "$PERFORMANCE_FILE")

    if [[ $total_runs -eq 0 ]]; then
        print_warning "No performance data available yet. Run some tests first!"
        return 0
    fi

    print_info "Total recorded runs: $total_runs"
    echo ""

    # Recent Operations (Last 5)
    echo -e "${PURPLE}=== Recent Operations (Last 5) ===${NC}"
    jq -r '.runs[-5:] | reverse | .[] | "\(.timestamp | strftime("%Y-%m-%d %H:%M")) | \(.operation | ascii_upcase) | \(.duration_seconds)s | \(if .success then "✅" else "❌" end) | Resources: \(.resource_count)"' "$PERFORMANCE_FILE" 2>/dev/null || {
        print_warning "Error reading recent operations"
    }
    echo ""

    # Performance Comparison
    echo -e "${PURPLE}=== Deploy vs Destroy Comparison ===${NC}"

    local deploy_runs destroy_runs full_cycle_runs
    deploy_runs=$(jq '[.runs[] | select(.operation == "deploy" and .success == true)]' "$PERFORMANCE_FILE")
    destroy_runs=$(jq '[.runs[] | select(.operation == "destroy" and .success == true)]' "$PERFORMANCE_FILE")
    full_cycle_runs=$(jq '[.runs[] | select(.operation == "full_cycle" and .success == true)]' "$PERFORMANCE_FILE")

    local deploy_count destroy_count full_cycle_count
    deploy_count=$(echo "$deploy_runs" | jq 'length')
    destroy_count=$(echo "$destroy_runs" | jq 'length')
    full_cycle_count=$(echo "$full_cycle_runs" | jq 'length')

    if [[ $deploy_count -gt 0 ]]; then
        local deploy_avg deploy_min deploy_max deploy_last
        deploy_avg=$(echo "$deploy_runs" | jq '[.[].duration_seconds] | add / length | floor')
        deploy_min=$(echo "$deploy_runs" | jq '[.[].duration_seconds] | min')
        deploy_max=$(echo "$deploy_runs" | jq '[.[].duration_seconds] | max')
        deploy_last=$(echo "$deploy_runs" | jq '.[-1].duration_seconds')

        echo -e "${GREEN}🚀 Deploy Operations ($deploy_count runs):${NC}"
        echo -e "  Last:    $(format_duration $deploy_last)"
        echo -e "  Average: $(format_duration $deploy_avg)"
        echo -e "  Best:    $(format_duration $deploy_min)"
        echo -e "  Worst:   $(format_duration $deploy_max)"
    else
        echo -e "${YELLOW}🚀 Deploy: No successful runs yet${NC}"
    fi

    if [[ $destroy_count -gt 0 ]]; then
        local destroy_avg destroy_min destroy_max destroy_last
        destroy_avg=$(echo "$destroy_runs" | jq '[.[].duration_seconds] | add / length | floor')
        destroy_min=$(echo "$destroy_runs" | jq '[.[].duration_seconds] | min')
        destroy_max=$(echo "$destroy_runs" | jq '[.[].duration_seconds] | max')
        destroy_last=$(echo "$destroy_runs" | jq '.[-1].duration_seconds')

        echo -e "${RED}💥 Destroy Operations ($destroy_count runs):${NC}"
        echo -e "  Last:    $(format_duration $destroy_last)"
        echo -e "  Average: $(format_duration $destroy_avg)"
        echo -e "  Best:    $(format_duration $destroy_min)"
        echo -e "  Worst:   $(format_duration $destroy_max)"
    else
        echo -e "${YELLOW}💥 Destroy: No successful runs yet${NC}"
    fi

    if [[ $full_cycle_count -gt 0 ]]; then
        local cycle_avg cycle_min cycle_max cycle_last
        cycle_avg=$(echo "$full_cycle_runs" | jq '[.[].duration_seconds] | add / length | floor')
        cycle_min=$(echo "$full_cycle_runs" | jq '[.[].duration_seconds] | min')
        cycle_max=$(echo "$full_cycle_runs" | jq '[.[].duration_seconds] | max')
        cycle_last=$(echo "$full_cycle_runs" | jq '.[-1].duration_seconds')

        echo -e "${BLUE}🔄 Full Cycle Operations ($full_cycle_count runs):${NC}"
        echo -e "  Last:    $(format_duration $cycle_last)"
        echo -e "  Average: $(format_duration $cycle_avg)"
        echo -e "  Best:    $(format_duration $cycle_min)"
        echo -e "  Worst:   $(format_duration $cycle_max)"
    else
        echo -e "${YELLOW}🔄 Full Cycle: No successful runs yet${NC}"
    fi

    # Performance Ratio
    if [[ $deploy_count -gt 0 && $destroy_count -gt 0 ]]; then
        echo ""
        echo -e "${PURPLE}=== Performance Ratio ===${NC}"
        local ratio
        ratio=$(echo "scale=1; $deploy_avg / $destroy_avg" | bc 2>/dev/null || echo "N/A")
        if [[ "$ratio" != "N/A" ]]; then
            echo -e "Deploy/Destroy Ratio: ${CYAN}${ratio}x${NC} (Deploy is ${ratio}x slower than Destroy)"
        fi
    fi

    echo ""
    echo -e "${CYAN}Performance data stored in: $PERFORMANCE_FILE${NC}"
}

# =============================================================================
# Test Operations
# =============================================================================

run_pre_test_validation() {
    print_header "Pre-Test Validation Suite"

    local tests=(
        check_tools
        check_terraform_version
        check_provider_connectivity
        validate_terraform_config
        backup_state_file
        document_current_state
    )

    local failed_tests=()

    for test in "${tests[@]}"; do
        if ! "$test"; then
            failed_tests+=("$test")
        fi
    done

    if [[ ${#failed_tests[@]} -eq 0 ]]; then
        print_success "All pre-test validations passed"
        return 0
    else
        print_error "Failed validations: ${#failed_tests[@]}"
        printf '%s\n' "${failed_tests[@]}"
        return 1
    fi
}

run_destroy_test() {
    print_header "Infrastructure Destroy Test"

    local start_time=$(date +%s)

    if ! run_pre_test_validation; then
        print_error "Pre-test validation failed. Aborting destroy test."
        return 1
    fi

    print_warning "DANGER: This will destroy all infrastructure managed by this Terraform configuration"
    print_warning "Current environment: ${TF_VAR_mvd_environment:-UNKNOWN}"
    print_warning "Current mandant: ${TF_VAR_mvd_mandant:-UNKNOWN}"

    if ! confirm "Are you absolutely sure you want to proceed with destroy?" "n"; then
        print_info "Destroy operation cancelled"
        return 1
    fi

    # Generate and apply destroy plan
    if generate_plan "destroy" && apply_plan "destroy.tfplan" "destroy"; then
        # Verify destruction
        local remaining_resources
        remaining_resources=$(terraform state list | wc -l)

        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        if [[ $remaining_resources -eq 0 ]]; then
            print_success "Destroy test completed successfully in $(format_duration $duration) - no resources remaining"
            save_performance_data "destroy" "$duration" "true" "0"
        else
            print_warning "Destroy completed in $(format_duration $duration) but $remaining_resources resources remain in state"
            terraform state list
            save_performance_data "destroy" "$duration" "false" "$remaining_resources"
        fi

        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        print_error "Destroy test failed after $(format_duration $duration)"
        save_performance_data "destroy" "$duration" "false" "0"
        return 1
    fi
}

run_deploy_test() {
    print_header "Infrastructure Deploy Test"

    local start_time=$(date +%s)

    # Clean up any existing plans
    rm -f deploy.tfplan destroy.tfplan

    # Re-initialize to ensure clean state
    print_info "Re-initializing Terraform..."
    if ! terraform init; then
        print_error "Terraform initialization failed"
        return 1
    fi

    # Generate and apply deploy plan
    if generate_plan "deploy" && apply_plan "deploy.tfplan" "deploy"; then
        # Verify deployment and get resource count
        local resource_count
        resource_count=$(terraform state list | wc -l)

        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        if verify_deployment; then
            print_success "Deploy test completed successfully in $(format_duration $duration) with $resource_count resources"
            save_performance_data "deploy" "$duration" "true" "$resource_count"
            return 0
        else
            print_warning "Deploy completed in $(format_duration $duration) but verification had issues"
            save_performance_data "deploy" "$duration" "false" "$resource_count"
            return 1
        fi
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        print_error "Deploy test failed after $(format_duration $duration)"
        save_performance_data "deploy" "$duration" "false" "0"
        return 1
    fi
}

run_deploy_test_auto() {
    print_header "Infrastructure Deploy Test (Automated)"

    local start_time=$(date +%s)

    # Clean up any existing plans
    rm -f deploy.tfplan destroy.tfplan

    # Re-initialize to ensure clean state
    print_info "Re-initializing Terraform..."
    if ! terraform init; then
        print_error "Terraform initialization failed"
        return 1
    fi

    # Generate and apply deploy plan in auto mode
    if generate_plan "deploy" "true" && apply_plan "deploy.tfplan" "deploy" "true"; then
        # Verify deployment and get resource count
        local resource_count
        resource_count=$(terraform state list | wc -l)

        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        if verify_deployment_auto; then
            print_success "Automated deploy test completed successfully in $(format_duration $duration) with $resource_count resources"
            save_performance_data "deploy" "$duration" "true" "$resource_count"
            return 0
        else
            print_warning "Deploy completed in $(format_duration $duration) but verification had issues"
            save_performance_data "deploy" "$duration" "false" "$resource_count"
            return 1
        fi
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        print_error "Automated deploy test failed after $(format_duration $duration)"
        save_performance_data "deploy" "$duration" "false" "0"
        return 1
    fi
}

run_full_cycle_test() {
    print_header "Full Destroy → Deploy Cycle Test"

    # Warning with environment information
    echo -e "${RED}!!! WARNING: AUTOMATED FULL CYCLE TEST !!!${NC}"
    echo -e "${YELLOW}Environment: ${ENV_ENVIRONMENT}${NC}"
    echo -e "${YELLOW}Mandant: ${ENV_MANDANT}${NC}"
    echo -e "${YELLOW}Customer: ${ENV_CUSTOMER}${NC}"
    echo -e "${RED}This will DESTROY and REDEPLOY all infrastructure without confirmation!${NC}"
    echo -e "${YELLOW}Press Ctrl+C within 10 seconds to abort...${NC}"

    # 10 second countdown
    for i in {10..1}; do
        echo -ne "\r${RED}Starting in $i seconds... ${NC}"
        sleep 1
    done
    echo -e "\n${GREEN}Starting full cycle test...${NC}"

    local cycle_start_time=$(date +%s)
    local destroy_start_time destroy_duration deploy_start_time deploy_duration

    # Run destroy test without confirmation (already warned)
    print_header "Phase 1: Automated Destroy"
    destroy_start_time=$(date +%s)

    if ! run_pre_test_validation; then
        print_error "Pre-test validation failed. Aborting destroy test."
        return 1
    fi

    # Generate and apply destroy plan without confirmation
    if generate_plan "destroy" "true" && apply_plan "destroy.tfplan" "destroy" "true"; then
        # Verify destruction
        local remaining_resources
        remaining_resources=$(terraform state list | wc -l)

        destroy_duration=$(($(date +%s) - destroy_start_time))

        if [[ $remaining_resources -eq 0 ]]; then
            print_success "Automated destroy completed successfully in $(format_duration $destroy_duration) - no resources remaining"
            save_performance_data "destroy" "$destroy_duration" "true" "0"
        else
            print_warning "Destroy completed in $(format_duration $destroy_duration) but $remaining_resources resources remain in state"
            terraform state list
            save_performance_data "destroy" "$destroy_duration" "false" "$remaining_resources"
        fi
    else
        destroy_duration=$(($(date +%s) - destroy_start_time))
        print_error "Automated destroy failed after $(format_duration $destroy_duration)"
        save_performance_data "destroy" "$destroy_duration" "false" "0"
        return 1
    fi

    # Run deploy test with auto mode
    print_header "Phase 2: Automated Deploy"
    deploy_start_time=$(date +%s)

    if run_deploy_test_auto; then
        deploy_duration=$(($(date +%s) - deploy_start_time))
        local total_cycle_duration=$(($(date +%s) - cycle_start_time))

        print_success "Full cycle test completed successfully in $(format_duration $total_cycle_duration)"
        print_info "Performance Summary:"
        print_info "  Destroy: $(format_duration $destroy_duration)"
        print_info "  Deploy:  $(format_duration $deploy_duration)"
        print_info "  Total:   $(format_duration $total_cycle_duration)"

        save_performance_data "full_cycle" "$total_cycle_duration" "true" "$(terraform state list | wc -l)"
        return 0
    else
        deploy_duration=$(($(date +%s) - deploy_start_time))
        local total_cycle_duration=$(($(date +%s) - cycle_start_time))

        print_error "Full cycle test failed during deploy phase after $(format_duration $total_cycle_duration)"
        save_performance_data "full_cycle" "$total_cycle_duration" "false" "0"
        return 1
    fi
}

run_emergency_rollback() {
    print_header "Emergency Rollback Procedure"

    print_warning "Emergency rollback will attempt to restore from the most recent backup"

    if confirm "Proceed with emergency rollback?" "n"; then
        if restore_state_backup; then
            print_info "State restored. Verifying current state..."
            if terraform plan -detailed-exitcode -var-file=customer.auto.tfvars -var-file=sklad.auto.tfvars; then
                print_success "Emergency rollback completed successfully"
            else
                print_warning "State restored but configuration drift detected"
                print_info "You may need to run 'terraform apply' to align actual infrastructure with state"
            fi
        else
            print_error "Emergency rollback failed"
            return 1
        fi
    else
        print_info "Emergency rollback cancelled"
        return 1
    fi
}

# =============================================================================
# Main Menu
# =============================================================================

show_menu() {
    # Parse customer.auto.tfvars before showing menu
    parse_customer_tfvars

    echo -e "\n${PURPLE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║        Citrix DaaS Terraform Test Suite   ║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Environment:${NC} ${ENV_ENVIRONMENT}"
    echo -e "${CYAN}Mandant:${NC} ${ENV_MANDANT}"
    echo -e "${CYAN}Customer:${NC} ${ENV_CUSTOMER}"
    echo -e "${CYAN}Working Directory:${NC} $(pwd)"
    echo ""
    echo "1) 🔍 Pre-Test Validation"
    echo "2) 💥 Destroy Infrastructure"
    echo "3) 🚀 Deploy Infrastructure"
    echo "4) 🔄 Full Destroy → Deploy Cycle (AUTO-RUN)"
    echo "5) 🆘 Emergency Rollback"
    echo "6) 📊 View Test Logs"
    echo "7) 🧹 Cleanup Plan Files & Logs"
    echo "8) 📈 Performance Statistics"
    echo "0) ❌ Exit"
    echo ""
}

main() {
    # Setup
    setup_directories
    cd_terraform

    print_header "Citrix DaaS Terraform Test Suite Started"
    print_info "Log file: $LOG_FILE"
    print_info "Backup directory: $BACKUP_DIR"

    # Main loop
    while true; do
        show_menu
        read -p "Select an option (0-8): " choice

        case $choice in
            1)
                run_pre_test_validation
                ;;
            2)
                run_destroy_test
                ;;
            3)
                run_deploy_test
                ;;
            4)
                run_full_cycle_test
                ;;
            5)
                run_emergency_rollback
                ;;
            6)
                if [[ -f "$LOG_FILE" ]]; then
                    echo -e "\n${BLUE}=== Test Log ===${NC}"
                    tail -50 "$LOG_FILE"
                else
                    print_warning "No log file found"
                fi
                ;;
            7)
                print_header "Cleanup Plan Files and Logs"

                local plan_files_count=0
                local log_files_count=0

                # Count and clean plan files
                if ls *.tfplan >/dev/null 2>&1; then
                    plan_files_count=$(ls *.tfplan | wc -l)
                    print_info "Found $plan_files_count plan file(s)"
                    rm -f *.tfplan
                    print_success "Plan files cleaned up"
                else
                    print_info "No plan files to clean up"
                fi

                # Count and clean log files
                if ls "$LOG_DIR"/terraform-test-*.log >/dev/null 2>&1; then
                    log_files_count=$(ls "$LOG_DIR"/terraform-test-*.log | wc -l)
                    print_info "Found $log_files_count log file(s) in $LOG_DIR"
                    rm -f "$LOG_DIR"/terraform-test-*.log
                    print_success "Log files cleaned up"
                else
                    print_info "No log files to clean up"
                fi

                # Summary
                local total_cleaned=$((plan_files_count + log_files_count))
                if [[ $total_cleaned -gt 0 ]]; then
                    print_success "Cleanup completed: $plan_files_count plan files + $log_files_count log files = $total_cleaned files removed"
                else
                    print_info "No files to clean up"
                fi
                ;;
            0)
                print_info "Exiting Terraform Test Suite"
                exit 0
                ;;
            8)
                show_performance_statistics
                ;;
            *)
                print_error "Invalid option. Please select 0-8."
                ;;
        esac

        echo -e "\nPress Enter to continue..."
        read
    done
}

# =============================================================================
# Script Entry Point
# =============================================================================

# Trap to ensure cleanup on exit
trap 'print_info "Script interrupted or completed"' EXIT

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
