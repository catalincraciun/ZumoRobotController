Documentation
=============

This class is very useful and it is the way you can "talk" with your Zumo Robot. <br></br>

How to use
----------

1. ZumoRobotManager is a singleton, so every time want to use it you should do it this way:
```obj-c
  [[ZumoRobotManager sharedZumoRobotManager] (...)];
  // (...) representing your code
```
2. For getting logs from the ZumoRobotManager you should implement ZumoRobotManagerDelegate.
3. ZumoRobotManager knows how to connect or disconnect from a device.
```obj-c
  [[ZumoRobotManager sharedZumoRobotManager] connectToDevice];
  //    OR
  [[ZumoRobotManager sharedZumoRobotManager] disconnectFromDevice];
```
4. For sending a string to the robot you should use this method:
```obj-c
  [[ZumoRobotManager sharedZumoRobotManager] sendString:(...) avoidingRestriction:NO];
  // (...) representing the string you want to send
  // If what you want to send is very important and should be sent right away, you should have YES at avoidingRestriction
```
