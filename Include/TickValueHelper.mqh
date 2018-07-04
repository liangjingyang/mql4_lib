//+------------------------------------------------------------------+
//|                                              TickValueHelper.mqh |
//|                                        simple.continue@gmail.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "simple.continue@gmail.com"
#property link      "https://www.mql5.com"
#property strict

//+------------------------------------------------------------------+
//| Get TICKVALUE in account currency,                               |
//| Supported account currency: EUR, GBP, AUD, JPY                   |
//+------------------------------------------------------------------+
double getTickValueInAccountCurrency(string symbol) export {
   double tick_value = getTickValueInUSD(symbol);
   string account_currency = AccountCurrency();
   if (account_currency == "EUR") {
      double bid_price = MarketInfo("EURUSD", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (account_currency == "GBP") {
      double bid_price = MarketInfo("GBPUSD", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;  
   } else if (account_currency == "AUD") {
      double bid_price = MarketInfo("AUDUSD", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (account_currency == "JPY") {
      double bid_price = MarketInfo("USDJPY", MODE_BID);
      if (bid_price > 0) return tick_value * bid_price;
   }
   return tick_value;
}

//+------------------------------------------------------------------+
//| Get TICKVALUE in specific currency,                               |
//| Supported account currency: EUR, GBP, AUD, JPY                   |
//+------------------------------------------------------------------+
double getTickValueInCurrency(string symbol, string currency) export {
   double tick_value = getTickValueInUSD(symbol);
   if (currency == "EUR") {
      double bid_price = MarketInfo("EURUSD", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (currency == "GBP") {
      double bid_price = MarketInfo("GBPUSD", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;  
   } else if (currency == "AUD") {
      double bid_price = MarketInfo("AUDUSD", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (currency == "JPY") {
      double bid_price = MarketInfo("USDJPY", MODE_BID);
      if (bid_price > 0) return tick_value * bid_price;
   }
   return tick_value;
}

//+------------------------------------------------------------------+
//| Get TICKVALUE in USD,                                            |
//+------------------------------------------------------------------+
double getTickValueInUSD(string symbol) export {
   double tick_value = MarketInfo(symbol, MODE_TICKVALUE);
   double bid_price = 0.0;
   string second = SymbolInfoString(symbol, SYMBOL_CURRENCY_PROFIT);
      
   if (second == "EUR") {
      bid_price = MarketInfo("EURUSD", MODE_BID);
      if (bid_price > 0) return tick_value * bid_price;
   } else if (second == "GBP") {
      bid_price = MarketInfo("GBPUSD", MODE_BID);
      if (bid_price > 0) return tick_value * bid_price;
   } else if (second == "AUD") {
      bid_price = MarketInfo("AUDUSD", MODE_BID);
      if (bid_price > 0) return tick_value * bid_price;
   } else if (second == "NZD") {
      bid_price = MarketInfo("NZDUSD", MODE_BID);
      if (bid_price > 0) return tick_value * bid_price;
      
   
   } else if (second == "CAD") {
      bid_price = MarketInfo("USDCAD", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "CHF") {
      bid_price = MarketInfo("USDCHF", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "CNH") {
      bid_price = MarketInfo("USDCNH", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "CZK") {
      bid_price = MarketInfo("USDCZK", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "DKK") {
      bid_price = MarketInfo("USDDKK", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "HKD") {
      bid_price = MarketInfo("USDHKD", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "HUF") {
      bid_price = MarketInfo("USDHUF", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "JPY") {
      bid_price = MarketInfo("USDJPY", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "MXN") {
      bid_price = MarketInfo("USDMXN", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "NOK") {
      bid_price = MarketInfo("USDNOK", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "PLN") {
      bid_price = MarketInfo("USDPLN", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "RON") {
      bid_price = MarketInfo("USDRON", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "RUB") {
      bid_price = MarketInfo("USDRUB", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "SEK") {
      bid_price = MarketInfo("USDSEK", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "SGD") {
      bid_price = MarketInfo("USDSGD", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "THB") {
      bid_price = MarketInfo("USDTHB", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "TRY") {
      bid_price = MarketInfo("USDTRY", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (second == "ZAR") {
      bid_price = MarketInfo("USDZAR", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   }
   return(tick_value);
}

