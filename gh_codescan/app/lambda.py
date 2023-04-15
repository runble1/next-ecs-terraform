import json
import os
import requests
from urllib.parse import parse_qs


SLACK_WEBHOOK_URL = os.environ['SLACK_WEBHOOK_URL']
GITHUB_API_TOKEN = os.environ['GITHUB_API_TOKEN']
GITHUB_API_BASE_URL = "https://api.github.com"


def lambda_handler(event, context):
    print("Event: ", event)
    payload = json.loads(event['body'])
    headers = {
        "Authorization": f"token {GITHUB_API_TOKEN}",
        "Accept": "application/vnd.github+json"
    }

    # Check for X-GitHub-Event header
    if 'X-GitHub-Event' not in event['headers']:
        return {
            "statusCode": 400,
            "body": "X-GitHub-Event header not found."
        }

    github_event = event['headers']['X-GitHub-Event']

    if github_event == "code_scanning_alert":
        if 'alert' in payload:
            alert = payload['alert']
            repository = payload['repository']['full_name']
            alert_id = alert['number']
            alert_action = payload['action']
            alert_title = alert['rule']['description']
            alert_severity = alert['rule']['severity']
            alert_created_at = alert['created_at']
            alert_url = alert['html_url']

            message = (f"Code scanning alert (ID: {alert_id}) for {repository}\n"
                       f"Action: {alert_action}\n"
                       f"Severity: {alert_severity}\n"
                       f"Title: {alert_title}\n"
                       f"Created at: {alert_created_at}\n"
                       f"URL: {alert_url}")

            payload_slack = {
                "text": message
            }

            response = requests.post(SLACK_WEBHOOK_URL, json=payload_slack)
            response.raise_for_status()

            return {
                "statusCode": 200,
                "body": "Notification sent to Slack."
            }
        else:
            return {
                "statusCode": 400,
                "body": "Alert key not found in payload."
            }
    else:
        return {
            "statusCode": 200,
            "body": "Unhandled GitHub event."
        }
