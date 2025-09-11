# OCM Kueue Addon Upstream Tracking System

This directory contains the comprehensive upstream tracking system for monitoring kubernetes-sigs/kueue developments that impact OCM Kueue Addon development.

## Quick Start

### 1. Set up monitoring (one-time setup)
```bash
# Make the script executable
chmod +x github-cli-commands.sh

# Set up repository watching
./github-cli-commands.sh setup
```

### 2. Daily monitoring routine
```bash
# Quick check for your daily standup
./github-cli-commands.sh standup

# Full daily critical monitoring
./github-cli-commands.sh daily
```

### 3. Weekly comprehensive review
```bash
# Run every Monday morning
./github-cli-commands.sh weekly
```

## File Overview

### `upstream-strategy-2025-09-12.md`
**Purpose**: Comprehensive tracking strategy document
**Contains**: 
- Monitoring dashboard with daily/weekly/monthly priorities
- Repository-specific action plans
- Automation workflows and GitHub CLI commands
- Keyword optimization and search queries
- Escalation procedures and metrics

### `ocm-kueue-monitoring-2025-09-12.json`
**Purpose**: Machine-readable configuration for automation
**Contains**:
- Repository watch settings
- Keyword performance metrics
- Search query templates
- Alert thresholds and escalation levels
- Success indicators and review questions

### `github-cli-commands.sh`
**Purpose**: Practical GitHub CLI commands for daily use
**Contains**:
- Setup commands for repository monitoring
- Daily critical issue checking
- Weekly comprehensive reviews
- Specific KEP-693 monitoring
- Breaking change detection
- Quick standup summaries

## Command Reference

| Command | Purpose | Frequency |
|---------|---------|-----------|
| `./github-cli-commands.sh setup` | One-time repository watch setup | Once |
| `./github-cli-commands.sh standup` | Quick summary for daily standup | Daily |
| `./github-cli-commands.sh daily` | Critical issue monitoring | Daily |
| `./github-cli-commands.sh weekly` | Comprehensive upstream review | Weekly |
| `./github-cli-commands.sh kep693` | KEP-693 ClusterProfile status | As needed |
| `./github-cli-commands.sh production` | MultiKueue production readiness | Weekly |
| `./github-cli-commands.sh breaking` | Breaking change detection | Weekly |
| `./github-cli-commands.sh all` | Full monitoring suite | On-demand |

## Key Monitoring Targets

### 🚨 Critical (Daily Monitoring)
- **kubernetes-sigs/kueue**: MultiKueue developments, KEP-693 ClusterProfile integration
- **Specific Issues**: #6786 (ClusterProfile), #6732 (workload re-evaluation), #6790/#6788 (preemption fixes)
- **Keywords**: "multikueue", "ClusterProfile", "workload-revaluation", "preemption"

### 📊 Important (Weekly Monitoring)
- **kubernetes/kubernetes**: Scheduler API changes, cluster-scoped resources
- **open-cluster-management-io/ocm**: Addon framework updates, scheduling integration

### 📈 Strategic (Monthly Analysis)
- MultiKueue production readiness timeline
- Cross-repository trend analysis
- OCM integration opportunities

## Integration with OCM Development

### Daily Workflow
1. Run `./github-cli-commands.sh standup` during team standup
2. Share any critical upstream changes affecting current sprint
3. Update Jira tickets with upstream issue links if needed

### Weekly Planning
1. Run `./github-cli-commands.sh weekly` every Monday
2. Review impact on current sprint and upcoming work
3. Adjust OCM addon roadmap based on MultiKueue developments
4. Plan any necessary code changes or integration work

### Monthly Strategy
1. Review tracking metrics and keyword effectiveness
2. Update OCM addon roadmap based on upstream trends
3. Plan contributions to upstream projects
4. Assess need for additional automation or monitoring

## Automation Setup

### GitHub Notifications
The setup command configures GitHub watch settings for:
- **kubernetes-sigs/kueue**: All activity (high priority)
- **open-cluster-management-io/ocm**: Addon-related activity
- **kubernetes/kubernetes**: Filtered searches only (too noisy for full watch)

### Slack Integration (Optional)
Add webhook URL to script for Slack notifications:
```bash
export SLACK_WEBHOOK_URL="your-webhook-url"
```

### Calendar Reminders
Recommended calendar events:
- **Daily 9:00 AM**: Quick standup check
- **Monday 8:00 AM**: Weekly upstream review
- **First Monday 9:00 AM**: Monthly strategy review

## Customization

### Adding New Keywords
Edit `ocm-kueue-monitoring-2025-09-12.json` to add new keywords:
```json
"keywords": [
  "multikueue",
  "cluster-profile",
  "your-new-keyword"
]
```

### Adding New Repositories
Add new repository to monitoring configuration:
```json
"your-org/your-repo": {
  "priority": "MEDIUM",
  "monitoring": "weekly",
  "keywords": ["relevant", "keywords"]
}
```

### Adjusting Alert Thresholds
Modify escalation levels in the JSON configuration:
```json
"escalationLevels": {
  "monitor": {"frequency": "weekly"},
  "attention": {"frequency": "daily"},
  "critical": {"frequency": "real-time"}
}
```

## Troubleshooting

### GitHub CLI Authentication
If commands fail with authentication errors:
```bash
gh auth login
gh auth status
```

### Rate Limiting
If you hit GitHub API rate limits:
- Reduce monitoring frequency
- Use more specific search queries
- Check `gh api rate_limit` for current status

### No Results Found
If searches return no results:
- Verify repository names are correct
- Check if keywords are too specific
- Try broader search terms first

## Success Metrics

Track these indicators monthly:
- **Early Detection**: Catching critical changes within 24 hours
- **Relevance Score**: >90% of flagged items impact OCM addon
- **Response Time**: Acting on critical items within 48 hours
- **Planning Accuracy**: Quarterly roadmap adjustments based on trends

## Support and Updates

This tracking system should be reviewed and updated quarterly to:
- Adjust keywords based on effectiveness
- Add new repositories as ecosystem evolves
- Refine automation based on usage patterns
- Update escalation procedures based on team needs

For questions or improvements, contact the OCM team or update the tracking configuration files directly.