# Flowdock Relay

Relays messages from multiple flows to one flow.

  heroku config:set FLOWDOCK_RELAY_USER_TOKEN="<token of the user who relays messages, must be present in flows that are relayed>"
  heroku config:set FLOWDOCK_RELAY_ORGANIZATION="<name of your flowdock organization>"
  heroku config:set FLOWDOCK_RELAY_FLOWS_TO_RELAY="['flowname1_in_lowercase', 'flowname2_in_lowercase']"
  heroku config:set FLOWDOCK_RELAY_TARGET_FLOW_TOKEN="<token of the flow where messages are relayed>"
  heroku config:set FLOWDOCK_RELAY_USERS_FLOW="<name of the flow to get user names from>"

  heroku ps:scale relay=1