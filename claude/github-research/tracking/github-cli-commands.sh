#!/bin/bash
# GitHub CLI Commands for OCM Kueue Addon Upstream Monitoring
# Created: 2025-09-12
# Purpose: Practical commands for daily/weekly upstream tracking

echo "🔧 OCM Kueue Addon Upstream Monitoring Commands"
echo "==============================================="

# Function to setup repository watching
setup_monitoring() {
    echo "📡 Setting up repository monitoring..."
    
    # Enable critical monitoring for kubernetes-sigs/kueue
    echo "Setting up kubernetes-sigs/kueue monitoring..."
    gh api -X PUT /repos/kubernetes-sigs/kueue/subscription \
        -f subscribed=true \
        -f ignored=false \
        -f reason="multikueue-ocm-integration" || echo "Failed to set up kueue monitoring"
    
    # Enable OCM repository monitoring
    echo "Setting up open-cluster-management-io/ocm monitoring..."
    gh api -X PUT /repos/open-cluster-management-io/ocm/subscription \
        -f subscribed=true \
        -f ignored=false \
        -f reason="addon-framework-updates" || echo "Failed to set up OCM monitoring"
    
    echo "✅ Repository monitoring setup complete"
}

# Daily critical monitoring
daily_check() {
    echo "🚨 Daily Critical Check - $(date)"
    echo "================================"
    
    # Check for new critical MultiKueue issues
    echo "## Critical MultiKueue Issues (Last 24h)"
    gh search issues --repo kubernetes-sigs/kueue \
        --match title,body "multikueue OR ClusterProfile" \
        --state open \
        --updated ">$(date -d '1 day ago' --iso-8601)" \
        --json title,url,labels,updatedAt \
        --template '{{range .}}🔴 {{.title}}
   URL: {{.url}}
   Updated: {{.updatedAt}}
   Labels: {{range .labels}}{{.name}} {{end}}
{{"\n"}}{{end}}' || echo "No critical issues found"
    
    # Check for merged PRs affecting MultiKueue
    echo -e "\n## Recently Merged MultiKueue PRs"
    gh search prs --repo kubernetes-sigs/kueue \
        --match title,body "multikueue OR ClusterProfile" \
        --state merged \
        --merged ">$(date -d '1 day ago' --iso-8601)" \
        --json title,url,mergedAt \
        --template '{{range .}}✅ {{.title}}
   URL: {{.url}}
   Merged: {{.mergedAt}}
{{"\n"}}{{end}}' || echo "No recent merges found"
    
    # Check specific critical issues
    echo -e "\n## Critical Issue Status Updates"
    for issue in 6786 6732 6790 6788; do
        echo "### Issue #$issue"
        gh issue view $issue --repo kubernetes-sigs/kueue \
            --json title,state,updatedAt,labels \
            --template 'Title: {{.title}}
State: {{.state}}
Updated: {{.updatedAt}}
Labels: {{range .labels}}{{.name}} {{end}}
' || echo "Could not fetch issue #$issue"
        echo ""
    done
}

# Weekly comprehensive review
weekly_review() {
    echo "📊 Weekly Upstream Review - $(date)"
    echo "==================================="
    
    # MultiKueue developments
    echo "## MultiKueue Developments (Last 7 days)"
    gh search issues --repo kubernetes-sigs/kueue \
        --match title,body "multikueue OR \"multi kueue\"" \
        --updated ">$(date -d '7 days ago' --iso-8601)" \
        --json title,url,state,updatedAt,labels \
        --template '{{range .}}📋 {{.title}} ({{.state}})
   URL: {{.url}}
   Updated: {{.updatedAt}}
   Labels: {{range .labels}}{{.name}} {{end}}
{{"\n"}}{{end}}' || echo "No recent MultiKueue activity"
    
    # Kubernetes scheduler changes
    echo -e "\n## Kubernetes Scheduler Changes (Last 7 days)"
    gh search issues --repo kubernetes/kubernetes \
        --match title,body "scheduler" \
        --label sig/scheduling \
        --updated ">$(date -d '7 days ago' --iso-8601)" \
        --json title,url,state,labels \
        --template '{{range .}}🎛️ {{.title}} ({{.state}})
   URL: {{.url}}
   Labels: {{range .labels}}{{.name}} {{end}}
{{"\n"}}{{end}}' | head -20 || echo "No recent scheduler changes"
    
    # OCM addon framework updates
    echo -e "\n## OCM Addon Framework Updates (Last 7 days)"
    gh search issues --repo open-cluster-management-io/ocm \
        --match title,body "addon OR kueue OR scheduling" \
        --updated ">$(date -d '7 days ago' --iso-8601)" \
        --json title,url,state,updatedAt \
        --template '{{range .}}🔧 {{.title}} ({{.state}})
   URL: {{.url}}
   Updated: {{.updatedAt}}
{{"\n"}}{{end}}' || echo "No recent OCM addon activity"
    
    # Release activity
    echo -e "\n## Recent Releases"
    echo "### Kueue Releases"
    gh release list --repo kubernetes-sigs/kueue \
        --limit 5 \
        --json tagName,publishedAt,name \
        --template '{{range .}}🚀 {{.name}} ({{.tagName}})
   Published: {{.publishedAt}}
{{"\n"}}{{end}}' || echo "No recent Kueue releases"
}

# Monitor specific KEP-693 (ClusterProfile integration)
kep_693_status() {
    echo "📋 KEP-693 ClusterProfile Integration Status"
    echo "==========================================="
    
    # Search for KEP-693 related activity
    gh search issues --repo kubernetes-sigs/kueue \
        --match title,body "KEP-693 OR ClusterProfile" \
        --json title,url,state,updatedAt,body \
        --template '{{range .}}📄 {{.title}} ({{.state}})
   URL: {{.url}}
   Updated: {{.updatedAt}}
   ---
{{"\n"}}{{end}}' || echo "No KEP-693 activity found"
}

# Search for production readiness discussions
production_readiness() {
    echo "🏭 MultiKueue Production Readiness Status"
    echo "========================================"
    
    gh search issues --repo kubernetes-sigs/kueue \
        --match title,body "multikueue AND (production OR stable OR GA OR beta)" \
        --json title,url,state,updatedAt,labels \
        --template '{{range .}}🏭 {{.title}} ({{.state}})
   URL: {{.url}}
   Updated: {{.updatedAt}}
   Labels: {{range .labels}}{{.name}} {{end}}
{{"\n"}}{{end}}' || echo "No production readiness discussions found"
}

# Check for breaking changes
breaking_changes() {
    echo "⚠️ Potential Breaking Changes Monitoring"
    echo "======================================="
    
    # Look for breaking changes in MultiKueue
    gh search issues --repo kubernetes-sigs/kueue \
        --match title,body "multikueue AND (breaking OR deprecat OR remov)" \
        --json title,url,state,updatedAt,labels \
        --template '{{range .}}⚠️ {{.title}} ({{.state}})
   URL: {{.url}}
   Updated: {{.updatedAt}}
   Labels: {{range .labels}}{{.name}} {{end}}
{{"\n"}}{{end}}' || echo "No breaking changes detected"
    
    # Check Kubernetes API changes affecting scheduling
    echo -e "\n## Kubernetes API Changes (Scheduling Related)"
    gh search issues --repo kubernetes/kubernetes \
        --match title,body "API AND (deprecat OR breaking) AND schedul" \
        --updated ">$(date -d '30 days ago' --iso-8601)" \
        --json title,url,state \
        --template '{{range .}}⚠️ {{.title}} ({{.state}})
   URL: {{.url}}
{{"\n"}}{{end}}' | head -10 || echo "No recent API changes"
}

# Generate quick summary for standup
standup_summary() {
    echo "🏃 Quick Standup Summary - $(date)"
    echo "================================"
    
    # Count new issues in last 24h
    critical_count=$(gh search issues --repo kubernetes-sigs/kueue \
        --match title,body "multikueue OR ClusterProfile" \
        --state open \
        --updated ">$(date -d '1 day ago' --iso-8601)" \
        --json title | jq length 2>/dev/null || echo "0")
    
    echo "📊 New critical MultiKueue issues (24h): $critical_count"
    
    # Check if any critical issues updated
    if [ "$critical_count" -gt 0 ]; then
        echo "🚨 ACTION REQUIRED: Review new critical issues"
        gh search issues --repo kubernetes-sigs/kueue \
            --match title,body "multikueue OR ClusterProfile" \
            --state open \
            --updated ">$(date -d '1 day ago' --iso-8601)" \
            --json title,url \
            --template '{{range .}}   • {{.title}}: {{.url}}{{"\n"}}{{end}}'
    else
        echo "✅ No new critical issues detected"
    fi
    
    # Check specific critical issues for updates
    echo -e "\n📋 Critical Issue Status:"
    for issue in 6786 6732 6790 6788; do
        status=$(gh issue view $issue --repo kubernetes-sigs/kueue --json state --template '{{.state}}' 2>/dev/null || echo "unknown")
        echo "   • #$issue: $status"
    done
}

# Main function to show usage
show_usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Available commands:"
    echo "  setup         - Set up repository monitoring"
    echo "  daily         - Run daily critical check"
    echo "  weekly        - Run weekly comprehensive review"
    echo "  kep693        - Check KEP-693 ClusterProfile status"
    echo "  production    - Check MultiKueue production readiness"
    echo "  breaking      - Monitor for breaking changes"
    echo "  standup       - Quick summary for daily standup"
    echo "  all           - Run daily + weekly + breaking changes check"
    echo ""
    echo "Examples:"
    echo "  $0 daily      # Run daily monitoring"
    echo "  $0 weekly     # Run weekly review"
    echo "  $0 standup    # Quick summary for standup"
}

# Main execution
case "$1" in
    setup)
        setup_monitoring
        ;;
    daily)
        daily_check
        ;;
    weekly)
        weekly_review
        ;;
    kep693)
        kep_693_status
        ;;
    production)
        production_readiness
        ;;
    breaking)
        breaking_changes
        ;;
    standup)
        standup_summary
        ;;
    all)
        daily_check
        echo -e "\n" && weekly_review
        echo -e "\n" && breaking_changes
        ;;
    *)
        show_usage
        ;;
esac