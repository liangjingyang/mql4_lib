//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                                        simple.continue@gmail.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "simple.continue@gmail.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <L_SimpleLib.mqh>;
#include <hash.mqh>;
#include <hash_unit.mqh>;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   Print(" 1MODE_LOW  当日最低价_LOW= ", MarketInfo(Symbol(), MODE_LOW ));
   Print(" MODE_HIGH  当日最高价_HIGH= ", MarketInfo(Symbol(), MODE_HIGH));
   Print(" MODE_TIME  最后的K线变动时间_TIME= ", MarketInfo(Symbol(), MODE_TIME));   // (服务器显示时间)。 
   Print(" MODE_BID  该货币最后叫买价_BID= ", MarketInfo(Symbol(), MODE_BID));   // (取得相应货币对的即时价位，而不管这个EA是放在哪个货币对图表上.如 bid =MarketInfo("GBPUSD",MODE_BID); // 取得 Bid 价位)
   Print(" MODE_ASK 该货币最后叫卖价_ASK= ", MarketInfo(Symbol(), MODE_ASK));
   Print(" MODE_POINT 该货币最小变动单位点值_POINT= ", MarketInfo(Symbol(), MODE_POINT)); 
   Print(" MODE_DIGITS 小数位数_DIGITS= ", MarketInfo(Symbol(), MODE_DIGITS));
   Print(" MODE_SPREAD 点差_SPREAD= ", MarketInfo(Symbol(), MODE_SPREAD)); 
   Print(" MODE_STOPLEVEL 规定最小止赢止损线_STOP LEVEL= ", MarketInfo(Symbol(), MODE_STOPLEVEL)); 
   Print(" MODE_LOTSIZE 一标准手所用资金_LOT SIZE= ", MarketInfo(Symbol(), MODE_LOTSIZE));   // 标准手大小，黄金是100盎司，每次交易必须是100盎司的倍数 （ 黄金： 100 ） 。
   Print(" MODE_TICKVALUE 一手每点该货币的价值_TICK VALUE= ", MarketInfo(Symbol(), MODE_TICKVALUE)); //  跳动的基值，价格每次跳动的值都是它的倍数。如黄金，价格每次跳动都是0.05的倍数 （ 黄金： 0.05 ） 。     
   Print(" MODE_TICKSIZE 报价最小单位_TICK SIZE= ", MarketInfo(Symbol(), MODE_TICKSIZE)); 
   Print(" MODE_SWAPLONG 多头掉期_SWAP LONG= ", MarketInfo(Symbol(), MODE_SWAPLONG));
   Print(" MODE_SWAPSHORT 空头掉期_SWAP SHORT= ", MarketInfo(Symbol(), MODE_SWAPSHORT));
   Print(" MODE_STARTING 市场开始日期_STARTING= ", MarketInfo(Symbol(), MODE_STARTING),"    (主要用于期货)"); 
   Print(" MODE_EXPIRATION 市场截止周期_EXPIRATION= ", MarketInfo(Symbol(), MODE_EXPIRATION),"    (主要用于期货)"); 
   Print(" MODE_TRADEALLOWED 交易允许货币对数量_TRADE ALLOWED= ", MarketInfo(Symbol(), MODE_TRADEALLOWED)); 
   Print(" MODE_MINLOT 允许的最小手数_MIN LOT= ", MarketInfo(Symbol(), MODE_MINLOT)); 
   Print(" MODE_LOTSTEP 改变标准手步幅_LOT STEP= ", MarketInfo(Symbol(), MODE_LOTSTEP)); 
   Print(" MODE_MAXLOT 允许的最大标准手数_MAX LOT= ", MarketInfo(Symbol(), MODE_MAXLOT)); 
   Print(" MODE_SWAPTYPE 掉期计算的方式_SWAP TYPE= ", MarketInfo(Symbol(), MODE_SWAPTYPE),"    (0:点; 1 -基本货币对; 2: 兴趣; 3: 货币保证金)"); 
   Print(" MODE_PROFITCALCMODE 赢利计算模式_PROFIT CALC MODE= ", MarketInfo(Symbol(), MODE_PROFITCALCMODE),"    (0: Forex(外汇); 1: CFD(黄金); 2: Futrues(期货)) ");
   Print(" MODE_MARGINCALCMODE 保证金计算模式_MARGIN CALC MODE= ", MarketInfo(Symbol(), MODE_MARGINCALCMODE),"    (0: Forex(外汇); 1: CFD(黄金); 2: Futrues(期货); 3: CFD for indices(黄金指数))"); 
   Print(" MODE_MARGININIT 一个标准手的初始保证金_MARGIN INIT= ", MarketInfo(Symbol(), MODE_MARGININIT));  
   Print(" MODE_MARGINMAINTENANCE 一个标准手的开仓保证金_MARGIN MAINTENANCE= ", MarketInfo(Symbol(), MODE_MARGINMAINTENANCE));   
   Print(" MODE_MARGINHEDGED 一个标准手的护盘保证金_MARGIN HEDGED= ", MarketInfo(Symbol(), MODE_MARGINHEDGED));   
   Print(" MODE_MARGINREQUIRED 一个标准手的自由保证金_MARGIN REQUIRED= ", MarketInfo(Symbol(), MODE_MARGINREQUIRED));   
   Print(" MODE_FREEZELEVEL 冻结订单水平点_FREEZE LEVEL= ", MarketInfo(Symbol(), MODE_FREEZELEVEL)); 

   Print("============================================");
   Print("Account balance = ",AccountBalance());
   Print("Account company name ", AccountCompany());
   Print("Account number ", AccountCredit());
   Print("Account currency is ", AccountCurrency());
   Print("Account equity = ",AccountEquity());
   Print("Account free margin = ",AccountFreeMargin());
   Print("Account #",AccountNumber(), " leverage is ", AccountLeverage());
   Print("Account free margin = ",AccountFreeMargin());
   Print("Account` margin = ",AccountMargin());
   Print("Account name ", AccountName());
   Print("Account number ", AccountNumber());
   Print("Account profit ", AccountProfit());
   Print("Server name is ", AccountServer());
   Print("StopOut level = ", AccountStopoutLevel());
   
   Print("20 %%%% 5: ", 17 % 5);
   datetime local = TimeLocal();
   int day_of_week = TimeDayOfWeek(local);
   int hour = TimeHour(local);
   Print("TimeCurrent: ", TimeCurrent());
   Print("TimeLocal: ", TimeLocal());
   Print("TimeDayOfWeek: ", day_of_week);
   Print("TimeHour: ", hour);
 

   Print("Current bar for CHFUSD H1: ",iTime("USDCHF",PERIOD_H1,0),", ",  iOpen("USDCHF",PERIOD_H1,0),", ",
                                         iHigh("USDCHF",PERIOD_H1,0),", ",  iLow("USDCHF",PERIOD_H1,0),", ",
                                         iClose("USDCHF",PERIOD_H1,0),", ", iVolume("USDCHF",PERIOD_H1,0));
   Print("Second Currency: ", StringSubstr("XXXXXX", 3, 3));
   Print("ASK: ", MarketInfo("EURUSD", MODE_BID));
   Print("ASK: ", MarketInfo("XXXXXX", MODE_ASK));
   Print("iClose: ", iClose("EURUSD", PERIOD_M1, 1));
   Print("iClose: ", iClose("XXXXXX", PERIOD_M1, 0));
   Print("EURUSD MODE_PROFITCALCMODE: ", MarketInfo("EURUSD", MODE_PROFITCALCMODE));
   Print("XAUUSD MODE_PROFITCALCMODE: ", MarketInfo("XAUUSD", MODE_PROFITCALCMODE));
   Print("DXY MODE_PROFITCALCMODE: ", MarketInfo("DXY", MODE_PROFITCALCMODE));
   
   Print("USDJPY getTickValueInUSD: ", getTickValueInAccountCurrency("USDJPY"));
   
   Print("EURUSD MODE_POINT: ", MarketInfo("EURUSD", MODE_POINT));
   Print("USDJPY MODE_POINT: ", MarketInfo("USDJPY", MODE_POINT));
   Print("XAUUSD MODE_POINT: ", MarketInfo("XAUUSD", MODE_POINT));
   Print("XAGUSD MODE_POINT: ", MarketInfo("XAGUSD", MODE_POINT));
   Print("DXY MODE_POINT: ", MarketInfo("DXY", MODE_POINT));
   
   Print("EURUSD MODE_TICKSIZE: ", MarketInfo("EURUSD", MODE_TICKSIZE));
   Print("USDJPY MODE_TICKSIZE: ", MarketInfo("USDJPY", MODE_TICKSIZE));
   Print("XAUUSD MODE_TICKSIZE: ", MarketInfo("XAUUSD", MODE_TICKSIZE));
   Print("XAGUSD MODE_TICKSIZE: ", MarketInfo("XAGUSD", MODE_TICKSIZE));
   Print("DXY MODE_TICKSIZE: ", MarketInfo("DXY", MODE_TICKSIZE));
   
   Print("EURUSD MODE_TICKVALUE: ", MarketInfo("EURUSD", MODE_TICKVALUE));
   Print("USDJPY MODE_TICKVALUE: ", MarketInfo("USDJPY", MODE_TICKVALUE));
   Print("XAUUSD MODE_TICKVALUE: ", MarketInfo("XAUUSD", MODE_TICKVALUE));
   Print("XAGUSD MODE_TICKVALUE: ", MarketInfo("XAGUSD", MODE_TICKVALUE));
   Print("DXY MODE_TICKVALUE: ", MarketInfo("DXY", MODE_TICKVALUE));
   
   Print("EURUSD MODE_LOTSIZE: ", MarketInfo("EURUSD", MODE_LOTSIZE));
   Print("USDJPY MODE_LOTSIZE: ", MarketInfo("USDJPY", MODE_LOTSIZE));
   Print("XAUUSD MODE_LOTSIZE: ", MarketInfo("XAUUSD", MODE_LOTSIZE));
   Print("XAGUSD MODE_LOTSIZE: ", MarketInfo("XAGUSD", MODE_LOTSIZE));
   Print("DXY MODE_LOTSIZE: ", MarketInfo("DXY", MODE_LOTSIZE));
   
   Print("EURUSD MODE_LOTSTEP: ", MarketInfo("EURUSD", MODE_LOTSTEP));
   Print("USDJPY MODE_LOTSTEP: ", MarketInfo("USDJPY", MODE_LOTSTEP));
   Print("XAUUSD MODE_LOTSTEP: ", MarketInfo("XAUUSD", MODE_LOTSTEP));
   Print("XAGUSD MODE_LOTSTEP: ", MarketInfo("XAGUSD", MODE_LOTSTEP));
   Print("DXY MODE_LOTSTEP: ", MarketInfo("DXY", MODE_LOTSTEP));
   
   Print("EURUSD MODE_MINLOT: ", MarketInfo("EURUSD", MODE_MINLOT));
   Print("USDJPY MODE_MINLOT: ", MarketInfo("USDJPY", MODE_MINLOT));
   Print("XAUUSD MODE_MINLOT: ", MarketInfo("XAUUSD", MODE_MINLOT));
   Print("XAGUSD MODE_MINLOT: ", MarketInfo("XAGUSD", MODE_MINLOT));
   Print("DXY MODE_MINLOT: ", MarketInfo("DXY", MODE_MINLOT));
   
   Print("EURUSD MODE_MAXLOT: ", MarketInfo("EURUSD", MODE_MAXLOT));
   Print("USDJPY MODE_MAXLOT: ", MarketInfo("USDJPY", MODE_MAXLOT));
   Print("XAUUSD MODE_MAXLOT: ", MarketInfo("XAUUSD", MODE_MAXLOT));
   Print("XAGUSD MODE_MAXLOT: ", MarketInfo("XAGUSD", MODE_MAXLOT));
   Print("DXY MODE_MAXLOT: ", MarketInfo("DXY", MODE_MAXLOT));

   Print("EURUSD MODE_DIGITS: ", MarketInfo("EURUSD", MODE_DIGITS));
   Print("USDJPY MODE_DIGITS: ", MarketInfo("USDJPY", MODE_DIGITS));
   Print("XAUUSD MODE_DIGITS: ", MarketInfo("XAUUSD", MODE_DIGITS));
   Print("XAGUSD MODE_DIGITS: ", MarketInfo("XAGUSD", MODE_DIGITS));
   Print("DXY MODE_DIGITS: ", MarketInfo("DXY", MODE_DIGITS));
   
   Print("DXY MODE_STOPLEVEL: ", MarketInfo("DXY", MODE_STOPLEVEL));
   
   Print("USDJPY getMoneyByPointAndLots:", getMoneyByPointAndLots("USDJPY", 100, 1));
   
   
   
   Print("DXY SYMBOL_CURRENCY_BASE: ", SymbolInfoString("DXY", SYMBOL_CURRENCY_BASE));
   Print("DXY SYMBOL_CURRENCY_PROFIT: ", SymbolInfoString("DXY", SYMBOL_CURRENCY_PROFIT));
   Print("DXY SYMBOL_CURRENCY_MARGIN: ", SymbolInfoString("DXY", SYMBOL_CURRENCY_MARGIN));
   
   Print("EURUSD SYMBOL_CURRENCY_BASE: ", SymbolInfoString("EURUSD", SYMBOL_CURRENCY_BASE));
   Print("EURUSD SYMBOL_CURRENCY_PROFIT: ", SymbolInfoString("EURUSD", SYMBOL_CURRENCY_PROFIT));
   Print("EURUSD SYMBOL_CURRENCY_MARGIN: ", SymbolInfoString("EURUSD", SYMBOL_CURRENCY_MARGIN));
   
   Print("USDJPY SYMBOL_CURRENCY_BASE: ", SymbolInfoString("USDJPY", SYMBOL_CURRENCY_BASE));
   Print("USDJPY SYMBOL_CURRENCY_PROFIT: ", SymbolInfoString("USDJPY", SYMBOL_CURRENCY_PROFIT));
   Print("USDJPY SYMBOL_CURRENCY_MARGIN: ", SymbolInfoString("USDJPY", SYMBOL_CURRENCY_MARGIN));
   
   Print("XAGUSD SYMBOL_CURRENCY_BASE: ", SymbolInfoString("XAGUSD", SYMBOL_CURRENCY_BASE));
   Print("XAGUSD SYMBOL_CURRENCY_PROFIT: ", SymbolInfoString("XAGUSD", SYMBOL_CURRENCY_PROFIT));
   Print("XAGUSD SYMBOL_CURRENCY_MARGIN: ", SymbolInfoString("XAGUSD", SYMBOL_CURRENCY_MARGIN));
   
   string GLOBAL_TAG = "1123456";
   Print("GlobalVariableCheck: ", (GlobalVariableCheck(GLOBAL_TAG) ? "TRUE" : "FALSE"));
   Print("GlobalVariableSet: ", GlobalVariableSet(GLOBAL_TAG, 111));
   Print("GlobalVariableGet: ", GlobalVariableGet(GLOBAL_TAG));
   
   int total_order = OrdersTotal();
   int order_ticket = 0;
   for( int i = 0; i < total_order; i++ )
   {
     if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) )
     {
         Print("Order MagicNumber: " + IntegerToString(OrderMagicNumber()));
         Print("Order Ticket: " + IntegerToString(OrderTicket()));
     }
   }
   
   Print("Datetime to int: ", TimeCurrent());
   Print("Datetime to int: ", (int) TimeCurrent());
   Print("Datetime to int: ", (int) TimeCurrent() + 10);
   
   testHash();
  
  }
//+------------------------------------------------------------------+
