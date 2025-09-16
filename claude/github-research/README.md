# GitHub Research System

This system monitors upstream GitHub repositories and analyzes activity for relevant updates, issues, and PRs based on your keywords.

## Folder Structure

### `/reports/`
Contains analysis reports and insights:
- Format: `analysis-YYYY-MM-DD.md`
- Relevance scoring for issues/PRs
- Trending topics and patterns
- Action items and recommendations

### `/tracking/`
Contains raw tracking data and configurations:
- Format: `repos-YYYY-MM-DD.json`
- Repository monitoring settings
- Keyword performance metrics
- Historical tracking data

## How to Use

1. **Run `/github-research` command**
2. **Provide repository list and keywords**:
   ```
   Repositories:
   - kubernetes/kubernetes
   - open-cluster-management-io/ocm
   - kubernetes-sigs/kueue
   
   Keywords:
   - "multi-cluster"
   - "scheduling" 
   - "addon"
   ```
3. **System will**:
   - Fetch recent issues and PRs from repositories
   - Filter content using your keywords
   - Analyze relevance and impact
   - Generate actionable tracking strategy
   - Save analysis and tracking data

## System Components

- **Main Command**: `/github-research` - Orchestrates repository monitoring
- **GitHub Analyzer**: Analyzes issues, PRs, and repository activity
- **Upstream Tracker**: Creates monitoring strategies and action plans
- **Auto-organization**: Saves everything to date-stamped files

## Perfect For

- **Open Source Maintainers**: Monitor upstream dependencies and ecosystem changes
- **CNCF Contributors**: Track cloud-native project developments
- **Enterprise Teams**: Stay current with critical upstream updates
- **Technical Leaders**: Understand ecosystem trends and strategic directions

## Quality Standards

- Filters noise to focus on relevant upstream activity
- Provides actionable intelligence, not just data dumps
- Scores relevance based on keywords and impact
- Includes specific next steps for high-priority items
- Helps maintain awareness without information overload