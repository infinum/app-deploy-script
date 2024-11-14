#!/usr/bin/env python3.8

import sys
from jira import JIRA

# Generate changelog
def generate_changelog(issues, server, jira_email, jira_token):

    if jira_email is None or jira_token is None or server is None:
        #Pass -99 from python as print inside python is not visible. Calling sys.exit will just stop execution.
        return "-99"

    options = {
        'server': server
    }

    try:
        jira = JIRA(options, basic_auth=(jira_email, jira_token))
    except:
        return "-1001"

    build_changelog = ""
    for issueId in issues.split():
        issueId = issueId.upper()
        issue = jira.issue(issueId)
        taskName = issue.fields.summary
        taskUrl = server + "/browse/" + issueId
        fullName = "\n* [" + issueId + " " + taskName + "](" + taskUrl + ")"
        build_changelog += fullName

    return build_changelog

# Main
if __name__ == "__main__":

    if len(sys.argv) != 5:
        sys.exit(1)

    input_string = sys.argv[1]
    server = sys.argv[2]
    jira_email = sys.argv[3]
    jira_token = sys.argv[4]
    result = generate_changelog(input_string, server, jira_email, jira_token)
    print(result)
