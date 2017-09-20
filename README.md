# Jstack-JT-TT-Attempt
Use this script to collect Jstack  of JJ , TT or Attempt for a job.

Use "collectJstack.sh" to start jstack collection and "stopJstackcollect.sh" for stopping the collection. This will collect all require logs under /tmp/jstack

# Important
Jstack for attempt is controlled by "lightPollingInterval" and jstack for JT and TT is controlled by "heavyPollingInterval" .  Both the values are set in seconds.

- lightPollingInterval=1 # every second
- heavyPollingInterval=5 # every 5 second

- jtJstack=1   #Set this to "0" to disable jstack collection for JobTracker
- ttJstack=1   #Set this to "0" to disable jstack collection for TaskTracker
- taskJstack=1 #Set this to "0" to disable jstack collection for task attempts

