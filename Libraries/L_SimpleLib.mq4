//+------------------------------------------------------------------+
//|                                                  L_SimpleLib.mq4 |
//|                                        simple.continue@gmail.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "simple.continue@gmail.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| get decimals of a double                                                                |
//+------------------------------------------------------------------+
int decimals(double a) export {
    int num = 0;
    while(a != NormalizeDouble(a, 0)) {
        num += 1;
        a *= 10;
    }
    return(num);   
}

//+------------------------------------------------------------------+
//| Get tick value in account currency                               |
//+------------------------------------------------------------------+

double getTickValueInAccountCurrency(string symbol) export {
   double tick_value = getTickValueInUSD(symbol);
   string account_currency = AccountCurrency();
   if (account_currency == "EUR") {
      double bid_price = MarketInfo("EURUSD", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (account_currency == "EUR") {
      double bid_price = MarketInfo("EURUSD", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   } else if (account_currency == "GBP") {
      double bid_price = MarketInfo("GBPUSD", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;  
   } else if (account_currency == "AUD") {
      double bid_price = MarketInfo("AUDUSD", MODE_BID);
      if (bid_price > 0) return tick_value / bid_price;
   }
   return tick_value;
}

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


//+------------------------------------------------------------------+
//| Get spread                                                       |
//+------------------------------------------------------------------+
double spreadInBigPoint(string symbol) export {
   double spread = MarketInfo( symbol, MODE_SPREAD );
   double digits = MarketInfo( symbol, MODE_DIGITS );
   if ( digits == 3 || digits == 5 ) {
      spread = NormalizeDouble( spread / 10, 1 );
   } else {
      spread = NormalizeDouble( spread, 0 );
   } 
   return(spread);
}

double spreadInPoint(string symbol) export {
   double spread = NormalizeDouble( MarketInfo( symbol, MODE_SPREAD ), 0 );
   return(spread);
}


//+------------------------------------------------------------------+
//| Get point                                                        |
//+------------------------------------------------------------------+
double pointToBigPoint(string symbol, double point) export {
   double big_point = point;
   double digits = MarketInfo( symbol, MODE_DIGITS );
   if ( digits == 3 || digits == 5 ) {
      big_point = NormalizeDouble( point / 10, 1 );
   } else {
      big_point = NormalizeDouble( point, 0 );
   } 
   return(big_point);
}

double bigPointToPoint(string symbol, double big_point) export {
   double point = big_point;
   double digits = MarketInfo( symbol, MODE_DIGITS );
   if ( digits == 3 || digits == 5 ) {
      point = NormalizeDouble( big_point * 10, 0 );
   } else {
      point = NormalizeDouble( big_point, 0 );
   } 
   return(point);
}


double priceDistanceInPoint(string symbol, double price1, double price2) export {
   double digits = MarketInfo( symbol, MODE_DIGITS );
   double tick_size = MarketInfo( symbol, MODE_TICKSIZE );
   double distance = NormalizeDouble(MathAbs(price1 - price2) / tick_size, 0);
   return(distance);
}

double priceDistanceInBigPoint(string symbol, double price1, double price2) export {
   double digits = MarketInfo( symbol, MODE_DIGITS );
   double distance = priceDistanceInPoint(symbol, price1, price2);
   if ( digits == 3 || digits == 5 ) {
      distance = NormalizeDouble( distance / 10, 1 );
   } else {
      distance = NormalizeDouble( distance, 0 );
   } 
   return(distance);
}


//+------------------------------------------------------------------+
//| normalize price and lots                                         |
//+------------------------------------------------------------------+
double normalizeLots(string symbol, double lots) export {
   double min_lot = MarketInfo(symbol, MODE_MINLOT);
   double max_lot = MarketInfo(symbol, MODE_MAXLOT);
   double lot_step = MarketInfo(symbol, MODE_LOTSTEP);
   int lot_digits = decimals(lot_step);
   double new_lots = NormalizeDouble(lots, lot_digits);
   if (new_lots > lots) {
      new_lots -= lot_step;
   }
   if (new_lots > max_lot) {
      new_lots = max_lot;
   }
   return(new_lots);
}

double normalizePrice(string symbol, double price) export {
   int digits = (int) MarketInfo(symbol, MODE_DIGITS);
   return NormalizeDouble(price, digits);
}  

double priceMovePoint(string symbol, double price, double point) export {
   int digits = (int) MarketInfo(symbol, MODE_DIGITS);
   double tick_size = MarketInfo(symbol, MODE_TICKSIZE);
   return NormalizeDouble(price + point * tick_size, digits);
}


double priceMovePointMoreThanStopLevel(string symbol, double price, double point) export {
   double stop_level = MarketInfo(symbol, MODE_STOPLEVEL);
   int digits = (int) MarketInfo(symbol, MODE_DIGITS);
   double tick_size = MarketInfo(symbol, MODE_TICKSIZE);
   if (point > 0) {
      point = MathMax(stop_level, point);   
   } else if (point < 0) {
      point = MathMin(-stop_level, point);
   }
   return NormalizeDouble(price + point * tick_size, digits);
}
   

//+------------------------------------------------------------------+
//| Lots, Point, Money                                               |
//+------------------------------------------------------------------+
// Calculate Lots, point and money known
double getLotsByPointAndMoney(string symbol, double point, double money) export {
   double tick_value = getTickValueInAccountCurrency(symbol);
   double lots = money / (point * tick_value);
   lots = normalizeLots(symbol, lots);
   return(lots);
}

// Calculate point, lots and money known
double getPointByLotsAndMoney(string symbol, double lots, double money) export {
   double tick_value = getTickValueInAccountCurrency(symbol);
   double point = money / lots / tick_value;
   return NormalizeDouble(point, 0);
}

// Calculate money, lots and point known
double getMoneyByPointAndLots(string symbol, double point, double lots) export {
   double tick_value = getTickValueInAccountCurrency(symbol);
   double money = point * tick_value * lots;
   return NormalizeDouble(money, 2);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string orderTypeToString(int order_type) export {
   switch (order_type) {
      case OP_BUY:
         return "BUY";
      case OP_BUYLIMIT:
         return "BUYLIMIT";
      case OP_BUYSTOP:
         return "BUYSTOP";
      case OP_SELL:
         return "SELL";
      case OP_SELLLIMIT:
         return "SELLLIMIT";
      case OP_SELLSTOP:
         return "SELLSTOP";
      default:
         return "NULL";
   }
}

string priceToString(string symbol, double price) export {
   int digits = (int) MarketInfo(symbol, MODE_DIGITS);
   return(DoubleToStr(price, digits));
}

string moneyToString(double money) export {
   return(DoubleToStr(money, 2));
}

//+------------------------------------------------------------------+
//| Notify                                                           |
//+------------------------------------------------------------------+
void notifyApp(string tag, string level, string message) export {
   const string content = "#" + tag + "-" + level + "# " + message;
   SendNotification(content);
}
   
void alertAndNotifyApp(string tag, string level, string message) export {
   const string content = "#" + tag + "-" + level + "# " + message;
   Alert(content);
   SendNotification(content);
}

void alert(string tag, string level, string message) export {
   const string content = "#" + tag + "-" + level + "# " + message;
   Alert(content);
}


//+------------------------------------------------------------------+
//| Long or Short                                                    |
//+------------------------------------------------------------------+
bool isOrderLong(int order_type) export {
   return (order_type == OP_BUY || order_type == OP_BUYLIMIT || order_type == OP_BUYSTOP);
}