# /tf-best-practices - Terraform Best Practices Analyzer & Optimizer

Comprehensive Terraform configuration analyzer that validates and optimizes code against current 2024-2025 HashiCorp Best Practices, AWS Prescriptive Guidance, and industry standards.

**Arguments:**
- `--analyze-only` (optional): Perform analysis only without implementing changes
- `--skip-plan` (optional): Skip terraform plan validation step

## Core Workflow

1. **Best Practices Research**: Query latest HashiCorp and industry standards
2. **Configuration Analysis**: Deep analysis of current Terraform structure
3. **Optimization Implementation**: Apply naming convention and structural improvements
4. **Validation**: Execute terraform plan to ensure changes work correctly

## Analysis Categories

### File Structure & Organization
**Standards Validation:**
- ✅ Standard file organization (`main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`)
- ✅ Logical resource grouping (network.tf, compute.tf, storage.tf)
- ✅ Module structure compliance (`modules/` directory organization)
- ✅ Configuration separation (locals.tf, versions.tf)

**Quality Checks:**
- File naming consistency across project
- Resource organization and logical grouping
- Module structure and reusability patterns
- Documentation file presence and structure

### Naming Convention Validation
**Resource Naming Standards:**
- ✅ snake_case formatting consistency
- ✅ Descriptive, meaningful resource names
- ✅ Singular resource naming (no plurals)
- ✅ No provider type redundancy (avoid `aws_instance "aws_web_server"`)
- ✅ Consistent use of `main` or `this` for singleton resources

**Variable & Output Standards:**
- ✅ Descriptive variable names with units (`ram_size_gb`, `timeout_seconds`)
- ✅ Positive boolean naming (`enable_encryption` vs `disable_encryption`)
- ✅ Comprehensive validation rules and constraints
- ✅ Sensitive marking for secrets and credentials
- ✅ Output naming pattern: `{name}_{type}_{attribute}`

**Data Source Optimization:**
- ✅ Remove provider prefix redundancy (`azure_resource_group_main` → `main`)
- ✅ Descriptive names that indicate information type
- ✅ Proper placement (near resources or in dedicated data.tf)

### Module Best Practices
**Module Structure:**
- ✅ Repository naming: `terraform-<PROVIDER>-<NAME>`
- ✅ Standard module files (main.tf, variables.tf, outputs.tf, README.md)
- ✅ Nested module organization in `modules/` directory
- ✅ Version constraints and semantic versioning

**Module Interface Design:**
- ✅ Clear, intuitive variable interfaces
- ✅ Comprehensive output definitions with descriptions
- ✅ Input validation and error handling
- ✅ Documentation and usage examples

### Security & Compliance
**Security Standards:**
- ✅ No hardcoded secrets or credentials
- ✅ Sensitive variable and output marking
- ✅ Proper backend configuration for state management
- ✅ Provider version constraints and security updates

**Tagging Strategy:**
- ✅ Comprehensive resource tagging taxonomy
- ✅ Provider-level default tags implementation
- ✅ Environment, cost center, and ownership tags
- ✅ Management metadata (ManagedBy: Terraform)

### Multi-Environment Patterns
**Environment Strategy:**
- ✅ Compound workspace naming patterns
- ✅ Environment-specific variable management
- ✅ Consistent naming across environments
- ✅ Regional and multi-cloud considerations

## Phase-by-Phase Implementation Strategy

### Recommended 5-Phase Approach

Implementation follows a proven methodology with incremental value delivery:

#### Phase 1: Security & Compliance Foundation (2-3 hours) 🔴 **CRITICAL**
**Focus**: Immediate security improvements and compliance alignment
**Time Investment**: 2-3 hours | **Risk**: Low | **Impact**: High

**Core Deliverables:**
- [ ] Provider modernization (`null_resource` → native providers like `time_sleep`)
- [ ] Explicit backend configuration with state locking documentation
- [ ] Sensitive data handling (environment variables vs CLI arguments)
- [ ] Security scanner critical findings resolution
- [ ] Naming convention standardization (verb_noun patterns)

**Success Criteria:**
- ✅ Zero critical security findings in scanning tools
- ✅ 100% terraform fmt compliance
- ✅ Explicit backend configuration documented
- ✅ No credentials visible in CLI arguments

#### Phase 2: Resource Robustness & Scalability (2-3 hours) 🟡 **HIGH**
**Focus**: `count` → `for_each` migration for stable state management
**Time Investment**: 2-3 hours | **Risk**: Medium | **Impact**: High

**Core Deliverables:**
- [ ] Multi-resource patterns with `for_each` instead of fragile `count[0]`
- [ ] Enhanced variable validation with preconditions
- [ ] Robust resource referencing patterns
- [ ] Dynamic configuration based on deployment scenarios

**Success Criteria:**
- ✅ No hardcoded `[0]` references in production code
- ✅ Resources support scaling without recreation
- ✅ Comprehensive variable validation coverage
- ✅ Performance impact <10% from baseline

#### Phase 3: Monitoring & Observability (1.5-2 hours) 🟢 **MEDIUM**
**Focus**: Proactive error detection and operational visibility
**Time Investment**: 1.5-2 hours | **Risk**: Low | **Impact**: Medium

**Core Deliverables:**
- [ ] Preconditions and postconditions for critical resources
- [ ] Check blocks for environment readiness validation
- [ ] Enhanced outputs with health indicators and monitoring data
- [ ] Integration points for external monitoring systems

**Success Criteria:**
- ✅ All critical resources have preconditions
- ✅ Health check outputs validate successfully
- ✅ Check blocks validate without false positives
- ✅ Monitoring integration points functional

#### Phase 4: Pipeline Integration & Automation (2-3 hours) 🔵 **ENHANCEMENT**
**Focus**: Modern DevOps practices and CI/CD integration
**Time Investment**: 2-3 hours | **Risk**: Medium | **Impact**: High

**Core Deliverables:**
- [ ] CI/CD pipeline templates (GitLab, GitHub Actions, Azure DevOps)
- [ ] Automated quality gates and testing workflows
- [ ] Dynamic configuration and deployment strategies
- [ ] Infrastructure-as-Code maturity improvements

**Success Criteria:**
- ✅ CI/CD pipeline integration tested end-to-end
- ✅ Automated quality gates functional
- ✅ Team training on new workflows completed
- ✅ Deployment automation successful in staging

#### Phase 5: Documentation & Knowledge Transfer (1 hour) 📚 **ENABLEMENT**
**Focus**: Team enablement and long-term maintainability
**Time Investment**: 1 hour | **Risk**: Low | **Impact**: High

**Core Deliverables:**
- [ ] Comprehensive documentation templates and guides
- [ ] Troubleshooting runbooks and decision records
- [ ] Team training materials and best practice guides
- [ ] Architecture documentation and maintenance procedures

**Success Criteria:**
- ✅ Complete documentation coverage
- ✅ Self-service capability for team members
- ✅ Clear troubleshooting procedures documented
- ✅ Knowledge transfer materials available

### Implementation Process

#### Pre-Implementation Checklist
**Before starting any phase:**
- [ ] Create feature branch for all changes
- [ ] Backup Terraform state before major modifications
- [ ] Test all changes in staging environment first
- [ ] Document rollback procedures for each phase
- [ ] Establish stakeholder communication plan

#### Quality Assurance Process
**Applied to all phases:**
- Terraform format (`terraform fmt -recursive`)
- Configuration validation (`terraform validate`)
- Plan execution and analysis (`terraform plan`)
- Pre-commit hook integration testing
- Security scanning and compliance validation

## Advanced Patterns & Automation

### Dynamic Naming Generation
**Local Values Integration:**
```hcl
locals {
  # Environment-aware naming patterns
  name_prefix = "${var.environment}-${var.application}"

  # Resource naming with organizational context
  resource_names = {
    vpc    = "${local.name_prefix}-vpc"
    subnet = "${local.name_prefix}-subnet-${var.availability_zone}"
    sg     = "${local.name_prefix}-sg-${var.component}"
  }

  # Comprehensive tagging strategy
  common_tags = merge(var.common_tags, {
    Environment   = var.environment
    ManagedBy     = "Terraform"
    Project       = var.project_name
    CostCenter    = var.cost_center
    CreationDate  = formatdate("YYYY-MM-DD", timestamp())
  })
}
```

### Provisioner Modernization Patterns

#### time_sleep vs null_resource Migration
**❌ Legacy Pattern (Security Risk):**
```hcl
# Deprecated: Insecure and fragile approach
resource "null_resource" "wait_for_service" {
  provisioner "local-exec" {
    command = "sleep 300"  # Security scanner warnings, no proper error handling
  }

  depends_on = [aws_instance.example]
}

# Problematic downstream usage
data "aws_instance" "ready" {
  instance_id = aws_instance.example.id
  depends_on  = [null_resource.wait_for_service]  # Fragile dependency
}
```

**✅ Modern Pattern (Recommended):**
```hcl
# Modern: Native Terraform provider, secure and reliable
resource "time_sleep" "wait_for_service" {
  create_duration = "5m"
  depends_on      = [aws_instance.example]
}

# Enhanced with validation
data "aws_instance" "ready" {
  instance_id = aws_instance.example.id
  depends_on  = [time_sleep.wait_for_service]

  lifecycle {
    postcondition {
      condition     = self.instance_state == "running"
      error_message = "Instance failed to reach running state within timeout period"
    }
  }
}
```

#### Secure Provisioner Patterns
**❌ Insecure Credential Handling:**
```hcl
# Security risk: Credentials visible in CLI arguments and logs
resource "null_resource" "configure_service" {
  provisioner "local-exec" {
    command = "ansible-playbook setup.yml -u admin -p ${var.admin_password}"
    # ❌ Password visible in process list and logs
  }
}
```

**✅ Secure Environment Variable Pattern:**
```hcl
# Secure: Use environment variables for sensitive data
resource "null_resource" "configure_service" {
  provisioner "local-exec" {
    command = "./scripts/secure-deployment.sh"

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_USERNAME         = var.admin_username
      ANSIBLE_PASSWORD         = var.admin_password  # Marked sensitive
      TARGET_HOST             = aws_instance.example.private_ip
    }
  }

  depends_on = [time_sleep.wait_for_service]
}
```

**Enhanced Security Script Pattern:**
```bash
#!/bin/bash
# scripts/secure-deployment.sh
set -euo pipefail

# Create temporary inventory with credentials from environment
INVENTORY_FILE=$(mktemp)
trap 'rm -f "$INVENTORY_FILE"' EXIT

cat > "$INVENTORY_FILE" << EOF
[targets]
${TARGET_HOST}

[targets:vars]
ansible_user=${ANSIBLE_USERNAME}
ansible_password=${ANSIBLE_PASSWORD}
ansible_connection=ssh
EOF

# Execute with secure inventory
ansible-playbook -i "$INVENTORY_FILE" setup.yml
```

### Workspace-Based Environment Management
**Compound Workspace Patterns:**
```hcl
locals {
  # Parse workspace name: account_env_region
  workspace_parts = split("_", terraform.workspace)
  account_id      = local.workspace_parts[0]
  environment     = local.workspace_parts[1]
  region          = local.workspace_parts[2]

  # Dynamic resource configuration based on workspace context
  instance_size = local.environment == "prod" ? "t3.large" : "t3.micro"
  backup_enabled = local.environment == "prod" ? true : false
}
```

### Provider-Level Default Tags
**Comprehensive Tagging Strategy:**
```hcl
# Provider configuration with default tags
provider "aws" {
  default_tags {
    tags = {
      Environment   = var.environment
      Project       = var.project_name
      ManagedBy     = "Terraform"
      CostCenter    = var.cost_center
      Owner         = var.team_name
      Repository    = var.repository_url
      TerraformPath = path.cwd
    }
  }
}
```

## Risk Assessment & Mitigation Framework

### Implementation Risk Matrix

Systematic risk analysis for each implementation phase:

#### Phase-Specific Risk Assessment
| Risk Category | Probability | Impact | Phase | Mitigation Strategy |
|---------------|-------------|--------|-------|-------------------|
| **Provider Breaking Changes** | Medium | High | 1,2 | Version pinning, staging environment testing |
| **State File Corruption** | Low | Critical | 2 | State backups, gradual rollout, feature branches |
| **Team Skill Gap** | Medium | Medium | 4,5 | Training programs, pair programming, documentation |
| **Pipeline Complexity** | High | Medium | 4 | Incremental implementation, rollback procedures |
| **Performance Degradation** | Medium | Medium | 2,3 | Benchmarking, performance testing, monitoring |
| **Security Vulnerabilities** | Low | High | 1 | Security scanning, code review, compliance checks |

### Risk Mitigation Strategies

#### Pre-Implementation Risk Management
**Essential preparation steps:**
- [ ] **Feature Branch Strategy**: Never work directly on main branch
- [ ] **State Backup Procedures**: Document and test state recovery
- [ ] **Staging Environment**: Mirror production for safe testing
- [ ] **Rollback Documentation**: Clear procedures for each phase
- [ ] **Team Communication**: Stakeholder notification and approval process

#### During Implementation Risk Controls
**Active risk monitoring:**
- [ ] **Phase-by-Phase Validation**: Complete one phase before starting next
- [ ] **Automated Testing**: Comprehensive test suite execution after changes
- [ ] **Performance Monitoring**: Track metrics for regression detection
- [ ] **Security Scanning**: Continuous vulnerability assessment
- [ ] **State Consistency Checks**: Validate state integrity throughout process

#### Emergency Response Procedures
```bash
# Emergency Rollback Process
git checkout main                    # Return to stable branch
terraform state pull > state-backup # Additional state backup
terraform plan                      # Verify rollback plan safety
terraform apply                     # Execute rollback
# Document incident, root cause, and prevention measures
```

#### Go/No-Go Decision Framework
**Quality gates that must pass before proceeding:**

**Phase 1 Go/No-Go Criteria:**
- [ ] Zero critical security scanner findings
- [ ] All provisioners use environment variables for credentials
- [ ] Backend configuration explicitly documented and tested
- [ ] 100% terraform fmt compliance across all files
- [ ] Rollback procedures documented and validated

**Phase 2 Go/No-Go Criteria:**
- [ ] No hardcoded array index references ([0], [1], etc.)
- [ ] Multi-resource scenarios tested successfully in staging
- [ ] Performance impact measured and acceptable (<10% degradation)
- [ ] All resources support scaling operations without destruction
- [ ] State migration completed without data loss

**Phase 3 Go/No-Go Criteria:**
- [ ] All critical resources have functional preconditions
- [ ] Health check outputs validate in staging environment
- [ ] Monitoring integration points tested and functional
- [ ] Check blocks validate without false positive errors
- [ ] Documentation includes troubleshooting procedures

**Phase 4 Go/No-Go Criteria:**
- [ ] CI/CD pipeline integration tested end-to-end
- [ ] Automated quality gates pass consistently
- [ ] Team training completed with knowledge validation
- [ ] Deployment automation tested in staging
- [ ] Pipeline rollback procedures verified

### Risk Escalation Matrix
**Issue escalation based on impact and urgency:**
- **P1 - Critical Production Impact**: Immediate escalation to senior engineering
- **P2 - Major Feature Blocking**: Same-day escalation to team lead
- **P3 - Minor Implementation Issues**: Next business day team discussion
- **P4 - Documentation/Enhancement**: Weekly team review

## Quality Gates & Validation

### Pre-Commit Integration
**Automated Quality Checks:**
- `terraform_fmt`: Automatic code formatting
- `terraform_validate`: Configuration syntax validation
- `terraform_docs`: Auto-generate module documentation
- `tflint`: Advanced linting with custom rules
- `trivy`: Security vulnerability scanning
- `checkov`: Infrastructure security policy validation

### Naming Convention Validation
**Custom TFLint Rules:**
```yaml
# .tflint.hcl
rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}
```

### Security Scanning Integration
**Comprehensive Security Analysis:**
- Resource configuration security review
- Secret detection and validation
- Network security rule analysis
- IAM policy and permission auditing
- Compliance framework alignment

## Platform-Specific Optimizations

### AWS Best Practices
- S3 bucket naming and versioning strategies
- IAM role and policy naming conventions
- VPC and networking resource organization
- Auto Scaling and Load Balancer configurations
- RDS and database security patterns

### Azure Best Practices
- Resource Group hierarchical organization
- Storage Account naming and configuration
- Virtual Network and NSG best practices
- Key Vault integration patterns
- Managed Identity usage

### for_each vs count Migration Strategy

Critical pattern for stable state management and resource scalability:

#### Problematic count Pattern
**❌ Fragile Implementation:**
```hcl
# Fragile: Array index dependencies break with scaling
resource "aws_instance" "web" {
  count           = var.instance_count
  instance_type   = "t3.micro"
  ami             = data.aws_ami.ubuntu.id
}

# Downstream resources become fragile
resource "aws_security_group_rule" "web_access" {
  security_group_id = aws_security_group.web.id
  cidr_blocks       = ["${aws_instance.web[0].private_ip}/32"]  # ❌ Breaks if [0] removed
}

# Output only shows first instance
output "web_server_ip" {
  value = aws_instance.web[0].private_ip  # ❌ Hardcoded [0] reference
}
```

**Problems with count:**
- Hardcoded `[0]` references break when first resource is removed
- Resource recreation when count changes affect array order
- Difficult to reference specific instances consistently
- State management becomes complex with dynamic scaling

#### Robust for_each Pattern
**✅ Stable Implementation:**
```hcl
# Stable: Map-based resources with consistent keys
variable "web_instances" {
  description = "Web server instance configurations"
  type = map(object({
    instance_type = string
    availability_zone = string
    environment = string
  }))
  default = {
    web-primary = {
      instance_type     = "t3.small"
      availability_zone = "us-east-1a"
      environment      = "prod"
    }
    web-secondary = {
      instance_type     = "t3.micro"
      availability_zone = "us-east-1b"
      environment      = "prod"
    }
  }
}

resource "aws_instance" "web" {
  for_each = var.web_instances

  instance_type     = each.value.instance_type
  ami               = data.aws_ami.ubuntu.id
  availability_zone = each.value.availability_zone

  tags = merge(local.common_tags, {
    Name        = each.key
    Environment = each.value.environment
    Role        = "web-server"
  })
}

# Stable downstream resources
resource "aws_security_group_rule" "web_access" {
  for_each = aws_instance.web

  security_group_id = aws_security_group.web.id
  cidr_blocks       = ["${each.value.private_ip}/32"]  # ✅ Stable reference
  description       = "Access for ${each.key}"
}

# Comprehensive outputs
output "web_servers" {
  description = "All web server details"
  value = {
    for instance_key, instance in aws_instance.web : instance_key => {
      private_ip        = instance.private_ip
      public_ip        = instance.public_ip
      availability_zone = instance.availability_zone
      instance_id      = instance.id
    }
  }
}
```

#### Migration Strategy
**Step-by-step migration from count to for_each:**

```hcl
# Step 1: Define resource configuration map
locals {
  # Convert count-based config to map-based
  instance_configs = {
    for i in range(var.instance_count) :
    "instance-${format("%02d", i + 1)}" => {
      index           = i
      instance_type   = var.instance_type
      availability_zone = data.aws_availability_zones.available.names[i % length(data.aws_availability_zones.available.names)]
    }
  }
}

# Step 2: Migrate resources gradually
resource "aws_instance" "web_new" {
  for_each = local.instance_configs

  instance_type     = each.value.instance_type
  ami               = data.aws_ami.ubuntu.id
  availability_zone = each.value.availability_zone

  # Preserve existing functionality
  tags = merge(local.common_tags, {
    Name  = each.key
    Index = each.value.index  # For backward compatibility
  })
}

# Step 3: Update dependent resources
data "aws_instance" "web_lookup" {
  for_each = aws_instance.web_new

  instance_id = each.value.id

  # Add validation
  lifecycle {
    postcondition {
      condition     = self.instance_state == "running"
      error_message = "Instance ${each.key} failed to start properly"
    }
  }
}
```

#### Advanced for_each Patterns
**Dynamic multi-tier architecture:**
```hcl
locals {
  # Multi-tier resource definition
  tier_configs = {
    web = {
      instance_count = 2
      instance_type  = "t3.small"
      subnets        = data.aws_subnets.public.ids
    }
    app = {
      instance_count = 3
      instance_type  = "t3.medium"
      subnets        = data.aws_subnets.private.ids
    }
    db = {
      instance_count = 2
      instance_type  = "t3.large"
      subnets        = data.aws_subnets.database.ids
    }
  }

  # Flatten to individual instances
  all_instances = merge([
    for tier_name, tier_config in local.tier_configs : {
      for i in range(tier_config.instance_count) :
      "${tier_name}-${format("%02d", i + 1)}" => {
        tier          = tier_name
        instance_type = tier_config.instance_type
        subnet_id     = tier_config.subnets[i % length(tier_config.subnets)]
        index         = i
      }
    }
  ]...)
}

resource "aws_instance" "multi_tier" {
  for_each = local.all_instances

  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id
  ami           = data.aws_ami.ubuntu.id

  tags = merge(local.common_tags, {
    Name = each.key
    Tier = each.value.tier
    Role = "${each.value.tier}-server"
  })
}
```

### Multi-Cloud Patterns
- Provider-agnostic naming strategies
- Cross-cloud resource referencing
- Platform-specific constraint handling
- Unified tagging across providers

## Documentation & Knowledge Transfer

### Automated Documentation Generation
**Module Documentation:**
```markdown
## Usage Example
\`\`\`hcl
module "example" {
  source = "./modules/terraform-aws-example"

  name_prefix     = "production-webapp"
  environment     = "prod"
  vpc_id          = data.aws_vpc.main.id

  tags = local.common_tags
}
\`\`\`

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Resource name prefix | `string` | n/a | yes |

## Outputs
| Name | Description |
|------|-------------|
| vpc_main_id | ID of the main VPC |
```

### Best Practices Documentation
**Repository Standards:**
- Comprehensive README.md with usage examples
- Module documentation with terraform-docs
- Architecture diagrams and decision records
- Troubleshooting guides and FAQs
- Contributing guidelines and code review standards

## Success Metrics & KPIs

### Code Quality Metrics
- ✅ 100% terraform fmt compliance
- ✅ Zero terraform validate errors
- ✅ All resources follow naming conventions
- ✅ Comprehensive variable validation coverage
- ✅ Security scanning with zero critical findings

### Operational Excellence
- ✅ Consistent resource tagging (100% coverage)
- ✅ Proper state backend configuration
- ✅ Version-controlled provider constraints
- ✅ Automated testing and validation
- ✅ Documentation completeness and accuracy

### Team Productivity
- ✅ Reduced onboarding time for new team members
- ✅ Standardized development workflows
- ✅ Improved code review efficiency
- ✅ Enhanced collaboration through consistency
- ✅ Reduced operational overhead and maintenance

## Business Value & ROI Calculator

### Implementation ROI Metrics

Calculate the return on investment for Terraform best practices implementation:

#### Time Savings Calculator
```bash
# Calculate annual savings based on your team metrics
deployment_frequency_per_month = 20  # Adjust for your team
current_deployment_hours = 4         # Before optimization
optimized_deployment_hours = 1.5     # After best practices
hourly_cost_engineer = $80           # Average engineer cost

monthly_savings = deployment_frequency * (current_hours - optimized_hours) * hourly_cost
annual_roi = monthly_savings * 12
# Typical result: $48,000+ annual savings for enterprise teams
```

#### Quality & Productivity Improvements
| Metric | Before Best Practices | After Implementation | Business Impact |
|--------|----------------------|---------------------|-----------------|
| **Deployment Success Rate** | 95% | 99% | Reduced incident response |
| **Mean Time to Recovery** | 45 min | 15 min | Lower operational overhead |
| **Team Onboarding Time** | 5 days | 2 days | Faster team scaling |
| **Code Review Efficiency** | 2 hours | 45 min | Higher development velocity |
| **Configuration Drift** | 8% | <2% | Improved reliability |

#### Business Value Calculation
```markdown
### Annual Business Impact
- **Time-to-Market Reduction**: 50% faster infrastructure delivery
- **Risk Mitigation**: 80% fewer security incidents through automation
- **Cost Optimization**: 40% lower operational costs
- **Team Productivity**: 100% increase in deployment frequency
- **Customer Satisfaction**: 95%+ through reliable deployments
```

### ROI Implementation Phases
Each phase delivers incremental value:
- **Phase 1** (Security): Immediate compliance and risk reduction
- **Phase 2** (Robustness): 60% fewer deployment failures
- **Phase 3** (Monitoring): 70% faster incident resolution
- **Phase 4** (Pipeline): 50% reduction in manual work
- **Phase 5** (Documentation): 80% faster team onboarding

## Command Usage Examples

```bash
# Full analysis and optimization
/tf-best-practices

# Analysis only (no changes)
/tf-best-practices --analyze-only

# Skip terraform plan validation
/tf-best-practices --skip-plan

# Combined analysis and implementation with validation
/tf-best-practices
```

## Integration with CI/CD

### GitLab CI/CD Integration
```yaml
terraform_best_practices:
  stage: validate
  script:
    - claude /tf-best-practices --analyze-only
  rules:
    - if: $CI_MERGE_REQUEST_ID
```

### GitHub Actions Integration
```yaml
- name: Terraform Best Practices Check
  run: claude /tf-best-practices --analyze-only
```

Always ensure that Terraform configurations follow current industry standards and maintain high code quality, security, and operational excellence standards.
