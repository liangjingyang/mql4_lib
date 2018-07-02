//+------------------------------------------------------------------+
//|                                                  L_SimpleLib.mqh |
//|                                        simple.continue@gmail.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "simple.continue@gmail.com"
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
#import "L_SimpleLib.ex4"

   int decimals(double a);
   
   double getTickValueInAccountCurrency(string symbol);
   //double getTickValueInUSD(string symbol);
   
   double spreadInBigPoint(string symbol);
   double spreadInPoint(string symbol);
   
   double pointToBigPoint(string symbol, double point);
   double bigPointToPoint(string symbol, double big_point);
   double priceDistanceInPoint(string symbol, double price1, double price2);
   double priceDistanceInBigPoint(string symbol, double price1, double price2);
   
   double normalizeLots(string symbol, double lots);
   double normalizePrice(string symbol, double price);
   double priceMovePoint(string symbol, double price, double point);
   double priceMovePointMoreThanStopLevel(string symbol, double price, double point);
   
   double getLotsByPointAndMoney(string symbol, double point, double money);
   double getPointByLotsAndMoney(string symbol, double lots, double money);
   double getMoneyByPointAndLots(string symbol, double point, double lots);
   
   string orderTypeToString(int order_type);
   string priceToString(string symbol, double price);
   string moneyToString(double money);
   
   void notifyApp(string tag, string level, string message);
   void alertAndNotifyApp(string tag, string level, string message);
   void alert(string tag, string level, string message);
   
   bool isOrderLong(int order_type);
   
#import