import os
import json
import urllib.request

SLACK_URL = "https://slack.com/api/chat.postMessage"
SLACK_BOT_USER_ACCESS_TOKEN = os.environ['SLACK_BOT_USER_ACCESS_TOKEN']

# 使ってない
GITHUB_API_TOKEN = os.environ['GITHUB_API_TOKEN']
GITHUB_API_BASE_URL = "https://api.github.com"


def lambda_handler(event, context):
    print("Event:")
    print(event)
    headers = event["headers"]

    # Check for x-github-event header
    if 'x-github-event' not in headers:
        print("NOT GITHUB EVENT")
        return {
            "statusCode": 400,
            "body": "x-github-event header not found."
        }

    if headers['x-github-event'] == "code_scanning_alert":
        body = json.loads(event["body"])

        repo = body["repository"]["full_name"]
        rule = body["alert"]["rule"]["name"]
        url = body["alert"]["html_url"]

        message = ""
        if body["action"] == "created" and body["alert"]["state"] == "open":
            message = f"Code Scanning Alert *Opened*: *{rule}* in {repo}\nURL: {url}"
        elif body["action"] == "fixed" and body["alert"]["state"] == "fixed":  # trivyの場合？
            message = f"Code Scanning Alert *Fixed*: *{rule}* in {repo}\nURL: {url}"

        headers = {
            "Content-Type": "application/json; charset=UTF-8",
            "Authorization": "Bearer {0}".format(os.environ["SLACK_BOT_USER_ACCESS_TOKEN"])
        }
        data = {
            "token": os.environ["SLACK_BOT_USER_ACCESS_TOKEN"],
            "channel": os.environ["SLACK_CHANNEL_ID"],
            "text":  message,
            "username": "sec-aws-alert",
        }

        req = urllib.request.Request(SLACK_URL, data=json.dumps(
            data).encode("utf-8"), method="POST", headers=headers)

        try:
            urllib.request.urlopen(req)
            print("end")
        except urllib.error.HTTPError as err:
            print(err.code)
        except urllib.error.URLError as err:
            print(err.reason)

        return {
            "statusCode": 200,
            "body": "Notification sent to Slack."
        }
    else:
        return {
            "statusCode": 200,
            "body": "Unhandled GitHub event."
        }
