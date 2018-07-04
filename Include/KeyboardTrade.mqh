//+------------------------------------------------------------------+
//|                                                KeyboardTrade.mqh |
//|                                        simple.continue@gmail.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "simple.continue@gmail.com"
#property link      "https://www.mql5.com"
#property strict

/*
Buy: b lots price sl tp 
Sell: s lots price sl tp 

Set stop loss: sl ticket sl
Set take profit: tp ticket tp

Close or delete: c ticket

',' to split params(fields)
Double 'z' or 'ESC' to cancel the whole command

'x' to excute the command
*/

string _kt_cmd = "";
long _kt_last_code = -1;
string _kt_cmd_label_name = "KEYBOARDTR_TRADE_CMD_LABEL";

void KeyBoardTrade_OnInit() {
}

void KeyBoardTrade_OnDeinit(const int reason) {
   ObjectDelete(_kt_cmd_label_name);
}

void KeyBoardTrade_OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
   if (id == CHARTEVENT_KEYDOWN) {
      if (_kt_last_code == -1) { // last cmd finish
         _kt_cmd = "";
      }
      if (lparam == 88) { // 'x'
         _kt_parseAndExecute();
         return;
      } else if (lparam == 27) { // 'ESC'
         _kt_cancel_cmd();
         return;
      } else if (lparam == 90) { // 'z'
         if (_kt_last_code == 90) { // 'zz' to cancel _kt_cmd
            _kt_cancel_cmd();
            return;
         }
      } else if (lparam == 66) { // 'b'
         _kt_cmd = _kt_cmd + "b";
      } else if (lparam == 67) { // 'c'
         _kt_cmd = _kt_cmd + "c";
      } else if (lparam == 83) { // 's'
         _kt_cmd = _kt_cmd + "s";
      } else if (lparam == 76) { // 'l'
         _kt_cmd = _kt_cmd + "l";
      } else if (lparam == 84) { // 't'
         _kt_cmd = _kt_cmd + "t";
      } else if (lparam == 80) { // 'p'
         _kt_cmd = _kt_cmd + "p";
      } else if (lparam == 49) { // '1'
         _kt_cmd = _kt_cmd + "1";
      } else if (lparam == 50) { // '2'
         _kt_cmd = _kt_cmd + "2";
      } else if (lparam == 51) { // '3'
         _kt_cmd = _kt_cmd + "3";
      } else if (lparam == 52) { // '4'
         _kt_cmd = _kt_cmd + "4";
      } else if (lparam == 53) { // '5'
         _kt_cmd = _kt_cmd + "5";
      } else if (lparam == 54) { // '6'
         _kt_cmd = _kt_cmd + "6";
      } else if (lparam == 55) { // '7'
         _kt_cmd = _kt_cmd + "7";
      } else if (lparam == 56) { // '8'
         _kt_cmd = _kt_cmd + "8";
      } else if (lparam == 57) { // '9'
         _kt_cmd = _kt_cmd + "9";
      } else if (lparam == 48) { // '0'
         _kt_cmd = _kt_cmd + "0";
      } else if (lparam == 190) { // '.'
         _kt_cmd = _kt_cmd + ".";
      } else if (lparam == 188) { // ','
         _kt_cmd = _kt_cmd + ",";
      }
      _kt_last_code = lparam;
      Print("KT CMD: ", _kt_cmd, " lparam: ", lparam);
      _kt_display_text(_kt_to_display_text(_kt_cmd));
   }
   return;
}

void _kt_cancel_cmd() {
   _kt_cmd = "";
   _kt_display_text(_kt_cmd);
   _kt_last_code = -1;
}

//+------------------------------------------------------------------+
//| Parse and execute cmd                                            |
//+------------------------------------------------------------------+
void _kt_parseAndExecute() {
   string fields[];
   StringSplit(_kt_cmd, ',', fields);
   Print("=== split[0]: ", fields[0]);
   int ret = 0;
   if (fields[0] == "b") {
      ret = _kt_buy(fields);
   } else if (fields[0] == "s") {
      ret = _kt_sell(fields);
   } else if (fields[0] == "sl") {
      ret = _kt_stop_loss(fields);
   } else if (fields[0] == "tp") {
      ret = _kt_take_profit(fields);
   } else if (fields[0] == "c") {
      ret = _kt_close(fields);
   }
   if (ret > 999999) {
      string text = "Success! Order Ticket: " + IntegerToString(ret);
      _kt_display_text(text);
      Print(text);
   } else if (ret == 0) {
      string text = "Failed! Can't parse cmd!";
      _kt_display_text(text);
   } else {
      string text = "Failed! GetLastError " + IntegerToString(GetLastError());
      _kt_display_text(text);
      Print(text);
   }
   _kt_last_code = -1;
}

int _kt_buy(string &fields[]) {
   if (ArraySize(fields) < 5) {
      return 0;
   }
   //OrderSend(Symbol(),OP_BUY,1,price,3,stoploss,takeprofit,"My order",16384,0,clrGreen);
   string symbol = Symbol();
   int digits = (int) MarketInfo(symbol, MODE_DIGITS);
   double current_price = MarketInfo(symbol, MODE_ASK);
   double lots = NormalizeDouble(StringToDouble(fields[1]), 2);
   double price = NormalizeDouble(StringToDouble(fields[2]), digits);
   double sl = NormalizeDouble(StringToDouble(fields[3]), digits);
   double tp = NormalizeDouble(StringToDouble(fields[4]), digits);
   Print("_kt_buy, symbol:", symbol, " lots:", lots, " price:", price, " current_price:", current_price, " sl:", sl, " tp:", tp);
   if (price == 0 || current_price == price) {
      return OrderSend(symbol, OP_BUY, lots, current_price, 3, sl, tp);
   } else if (price > current_price) {
      return OrderSend(symbol, OP_BUYSTOP, lots, price, 3, sl, tp);
   } else if (price < current_price) {
      return OrderSend(symbol, OP_BUYLIMIT, lots, price, 3, sl, tp);
   }
   return 0;
}

int _kt_sell(string &fields[]) {
   if (ArraySize(fields) < 5) {
      return 0;
   }
   //OrderSend(Symbol(),OP_BUY,1,price,3,stoploss,takeprofit,"My order",16384,0,clrGreen);
   string symbol = Symbol();
   int digits = (int) MarketInfo(symbol, MODE_DIGITS);
   double current_price = MarketInfo(symbol, MODE_BID);
   double lots = NormalizeDouble(StringToDouble(fields[1]), 2);
   double price = NormalizeDouble(StringToDouble(fields[2]), digits);
   double sl = NormalizeDouble(StringToDouble(fields[3]), digits);
   double tp = NormalizeDouble(StringToDouble(fields[4]), digits);
   Print("_kt_sell, symbol:", symbol, " lots:", lots, " price:", price, " current_price:", current_price, " sl:", sl, " tp:", tp);
   if (price == 0 || current_price == price) {
      return OrderSend(symbol, OP_SELL, lots, current_price, 3, sl, tp);
   } else if (price > current_price) {
      return OrderSend(symbol, OP_SELLLIMIT, lots, price, 3, sl, tp);
   } else if (price < current_price) {
      return OrderSend(symbol, OP_SELLSTOP, lots, price, 3, sl, tp);
   }
   return 0;
}

int _kt_stop_loss(string &fields[]) {
   if (ArraySize(fields) < 3) {
      return 0;
   }
   int ticket = (int) StringToInteger(fields[1]);
   //OrderSend(Symbol(),OP_BUY,1,price,3,stoploss,takeprofit,"My order",16384,0,clrGreen);
   if (OrderSelect(ticket, SELECT_BY_TICKET)) {
      string symbol = OrderSymbol();
      int digits = (int) MarketInfo(symbol, MODE_DIGITS);
      double sl = NormalizeDouble(StringToDouble(fields[2]), digits);
      Print("_kt_stop_loss, symbol:", symbol, " ticket:", ticket, " sl:", sl);
      if (OrderModify(ticket, OrderOpenPrice(), sl, OrderTakeProfit(), OrderExpiration())) {
         return ticket;
      }
   }
   return 0;
}

int _kt_take_profit(string &fields[]) {
   if (ArraySize(fields) < 3) {
      return 0;
   }
   //OrderSend(Symbol(),OP_BUY,1,price,3,stoploss,takeprofit,"My order",16384,0,clrGreen);
   int ticket = (int) StringToInteger(fields[1]);
   if (OrderSelect(ticket, SELECT_BY_TICKET)) {
      string symbol = OrderSymbol();
      int digits = (int) MarketInfo(symbol, MODE_DIGITS);
      double tp = NormalizeDouble(StringToDouble(fields[2]), digits);
      Print("_kt_take_profit, symbol:", symbol, " ticket:", ticket, " tp:", tp);
      if (OrderModify(ticket, OrderOpenPrice(), OrderStopLoss(), tp, OrderExpiration())) {
         return ticket;
      }
   }
   return 0;
}

int _kt_close(string &fields[]) {
   if (ArraySize(fields) < 2) {
      return 0;
   }
   int ticket = (int) StringToInteger(fields[1]);
   if (OrderSelect(ticket, SELECT_BY_TICKET)) {
     if( OrderType() == OP_BUY )
       if(OrderClose(ticket,OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),30,Red)) 
         return ticket;
     
     if( OrderType() == OP_SELL)  
       if(OrderClose(ticket,OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),30,Red)) 
         return ticket;
       
     if( OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP )
       if( OrderDelete(ticket) )
         return ticket;         
   }
   return 0;
}

//+------------------------------------------------------------------+
//| Display cmd text                                                 |
//+------------------------------------------------------------------+
string _kt_to_display_text(string cmd) {
   if (StringLen(cmd) > 0) {
      string fields[];
      StringSplit(_kt_cmd, ',', fields);
      if (fields[0] == "b") {
         return _kt_to_display_buy(fields);
      } else if (fields[0] == "s") {
         return _kt_to_display_sell(fields);
      } else if (fields[0] == "sl") {
         return _kt_to_display_stop_loss(fields);
      } else if (fields[0] == "tp") {
         return _kt_to_display_take_profit(fields);
      } else if (fields[0] == "c") {
         return _kt_to_display_close(fields);
      }
   }
   return _kt_cmd;
}

string _kt_to_display_buy(string &fields[]) {
   string text = "";
   if (fields[0] == "b") {
      text += "BUY";
      if (ArraySize(fields) > 1) {
         text += " Lots:";
         text += fields[1];
      }

      if (ArraySize(fields) > 2) {
         text += " Price:";
         text += fields[2];
      }
      if (ArraySize(fields) > 3) {
         text += " SL:";
         text += fields[3];
      }
      if (ArraySize(fields) > 4) {
         text += " TP:";
         text += fields[4];
      }
   }
   return text;
}

string _kt_to_display_sell(string &fields[]) {
   string text = "";
   if (fields[0] == "s") {
      text += "SELL";
      if (ArraySize(fields) > 1) {
         text += " Lots:";
         text += fields[1];
      }

      if (ArraySize(fields) > 2) {
         text += " Price:";
         text += fields[2];
      }
      if (ArraySize(fields) > 3) {
         text += " SL:";
         text += fields[3];
      }
      if (ArraySize(fields) > 4) {
         text += " TP:";
         text += fields[4];
      }
   }
   return text;
}

string _kt_to_display_stop_loss(string &fields[]) {
   string text = "";
   if (fields[0] == "sl") {
      text += "SetStopLoss";
      if (ArraySize(fields) > 1) {
         text += " Ticket:";
         text += fields[1];
      }

      if (ArraySize(fields) > 2) {
         text += " SL:";
         text += fields[2];
      }
   }
   return text;
}

string _kt_to_display_take_profit(string &fields[]) {
   string text = "";
   if (fields[0] == "tp") {
      text += "SetTakeProfit";
      if (ArraySize(fields) > 1) {
         text += " Ticket:";
         text += fields[1];
      }

      if (ArraySize(fields) > 2) {
         text += " TP:";
         text += fields[2];
      }
   }
   return text;
}

string _kt_to_display_close(string &fields[]) {
   string text = "";
   if (fields[0] == "c") {
      text += "CloseOrDelete";
      if (ArraySize(fields) > 1) {
         text += " Ticket:";
         text += fields[1];
      }
   }
   return text;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _kt_display_text(string text) {
   long current_chart_id = ChartID();
   if (ObjectFind(current_chart_id, _kt_cmd_label_name) < 0) {
      ObjectCreate(current_chart_id, _kt_cmd_label_name, OBJ_LABEL, 0, 0, 0);
   }
   if (StringLen(text) > 0) {
      ObjectSet( _kt_cmd_label_name, OBJPROP_CORNER, CORNER_LEFT_LOWER );
      ObjectSet( _kt_cmd_label_name, OBJPROP_XDISTANCE, 500);
      ObjectSet( _kt_cmd_label_name, OBJPROP_YDISTANCE, 10 );
      ObjectSetText( _kt_cmd_label_name, "KT CMD: " + text, 10, "Courier New", SkyBlue);
   } else {
      ObjectSetText( _kt_cmd_label_name, "", 10, "Arial", SkyBlue);
   }
}
   
