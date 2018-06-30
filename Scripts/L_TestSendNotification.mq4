//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                                        simple.continue@gmail.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "simple.continue@gmail.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


const string DANGER = "DANGER";
const string WARNING = "WARNING";
const string INFO = "INFO";
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
      Print("TimeCurrent: " + TimeToString(TimeCurrent()));
      Print("TimeLocal: " + TimeToString(TimeLocal()));
      if (TimeCurrent() > TimeLocal()) Print("current");
      if (TimeLocal() >= TimeCurrent()) Print("local");
      //NotifyApp(DANGER, "More than 5 Lots");
   
  }
//+------------------------------------------------------------------+

void NotifyApp(string level, string message) {
   const string content = "#BSQD-" + level + "# " + message;
   SendNotification(content);
}