//+------------------------------------------------------------------+
//|                                          TickValueHelperTest.mq4 |
//|                                        simple.continue@gmail.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "simple.continue@gmail.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <TickValueHelper.mqh>;
//+------------------------------------------------------------------+
//| Test TickValueHelper                                             |
//+------------------------------------------------------------------+
void OnStart()
  {
      double bid_price = MarketInfo("USDJPY", MODE_BID);
      double tick_value_in_jpy = 100;
      double tick_value_in_usd = tick_value_in_jpy / bid_price;
      double actual_tick_value = getTickValueInCurrency("USDJPY", "USD");
      if (tick_value_in_usd != actual_tick_value) {
         Print(__FILE__, " Test Failed!", " Expected: ", DoubleToStr(tick_value_in_usd, 5), " Acual: ", DoubleToStr(actual_tick_value, 5));
         return;
      }
      Print(__FILE__, "Test Success!");
      return;
  }
//+------------------------------------------------------------------+
