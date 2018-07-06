//+------------------------------------------------------------------+
//|                                                KeyboardTrade.mqh |
//|                                        simple.continue@gmail.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "simple.continue@gmail.com"
#property link      "https://www.jforexcn.com"
#property version   "1.01"
#property strict


/*
The main purpose of this script is to manage orders with keyboard.

1. Send order, if the price is 0 or the current ASK/BID, the order type will be BUY/SELL.
If the command is b(Buy) and the price > ASK, it will be BUYSTOP, and the price < ASK, it will be BUYLIMIT.
If the command is s(Sell) and the price > BID, it will be SELLLIMIT, and the price < BID, it will be SELLSTOP.
Command:
   Buy: b,lots,price,sl,tp 
   Sell: s,lots,price,sl,tp 
Example: 
   Buy EURUSD 0.1 lots at price 1.16000 with stop loss at 1.15500 and take profit at 1.17000.
   The command is: b,0.1,1.16,1.155,1.17x
   The last 'x' means to execute this command.

2. Modify order, the stop loss and the take profit.
Command:
   Set stop loss: sl,ticket,sl
   Set take profit: tp,ticket,tp
Example:
   Assuming that there is a EURUSD BUY order with stop loss at 1.1550, the ticket is '123456789'.
   and we want to set the stop loss to 1.1580.
   The command is: sl,123456789,1.1580x
   The last 'x' means to execute this command.

3. Close or delete: c ticket

4. Others
   - ',' to split command params(fields).
   - Double 'z' or 'ESC' to cancel the whole command.
   - 'x' to excute the command.
*/

string _kt_cmd = "";
long _kt_last_code = -1;
string _KT_CMD_LABEL_NAME = "KEYBOARDTR_TRADE_CMD_LABEL";
string _KT_GLOBAL_VAL_NAME = "KT_CMD_LPARAM";

void _kt_OnKeyDown(const long &lparam) {
   if (_kt_last_code == -1) { // last cmd finish
      _kt_cmd = "";
   }
   if (lparam == 88) { // 'x' Execute
      _kt_parseAndExecute();
      return;
   } else if (lparam == 27) { // 'ESC' to cancel _kt_cmd
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
   _kt_display_text(_kt_format_cmd(_kt_cmd));
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
   if (StringLen(_kt_cmd) > 0) {
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
      if (ret > 0) {
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
//| Format cmd to display text                                                 |
//+------------------------------------------------------------------+
string _kt_format_cmd(string cmd) {
   if (StringLen(cmd) > 0) {
      string fields[];
      StringSplit(cmd, ',', fields);
      if (fields[0] == "b") {
         return _kt_format_buy(fields);
      } else if (fields[0] == "s") {
         return _kt_format_sell(fields);
      } else if (fields[0] == "sl") {
         return _kt_format_stop_loss(fields);
      } else if (fields[0] == "tp") {
         return _kt_format_take_profit(fields);
      } else if (fields[0] == "c") {
         return _kt_format_close(fields);
      }
   }
   return cmd;
}

string _kt_format_buy(string &fields[]) {
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

string _kt_format_sell(string &fields[]) {
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

string _kt_format_stop_loss(string &fields[]) {
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

string _kt_format_take_profit(string &fields[]) {
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

string _kt_format_close(string &fields[]) {
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
   if (ObjectFind(current_chart_id, _KT_CMD_LABEL_NAME) < 0) {
      ObjectCreate(current_chart_id, _KT_CMD_LABEL_NAME, OBJ_LABEL, 0, 0, 0);
   }
   if (StringLen(text) > 0) {
      ObjectSet( _KT_CMD_LABEL_NAME, OBJPROP_CORNER, CORNER_LEFT_LOWER );
      ObjectSet( _KT_CMD_LABEL_NAME, OBJPROP_XDISTANCE, 500);
      ObjectSet( _KT_CMD_LABEL_NAME, OBJPROP_YDISTANCE, 10 );
      ObjectSetText( _KT_CMD_LABEL_NAME, "KT CMD: " + text, 10, "Courier New", SkyBlue);
   } else {
      ObjectSetText( _KT_CMD_LABEL_NAME, "", 10, "Arial", SkyBlue);
   }
}
   
//+------------------------------------------------------------------+
//| Callback for strategy tester.                          |
//| EA OnChartEvent won't be call                                    |
//+------------------------------------------------------------------+
int _kt_val_read_point = 0;
string _KT_VAL_READ_POINT_NAME = "_KT_VAL_READ_POINT_NAME";
int _kt_val_write_point = 0;
string _KT_VAL_WRITE_POINT_NAME = "_KT_VAL_WRITE_POINT_NAME";
// Call in OnTick() of test strategy.
void KeyboardTrade_Tester_Strategy_OnTick() {
               
   if (!IsTesting()) return;
   
   int write_point = (int) NormalizeDouble(GlobalVariableGet(_KT_VAL_WRITE_POINT_NAME), 0);
   if (write_point > 0 && write_point > _kt_val_read_point) {
      for (int i = _kt_val_read_point + 1; i <= write_point; i++) {
         string val_name = _KT_GLOBAL_VAL_NAME + IntegerToString(i);
         long lparam = (long) NormalizeDouble(GlobalVariableGet(val_name), 0);
         _kt_OnKeyDown(lparam);
         GlobalVariableDel(val_name);
      }
      _kt_val_read_point = write_point;
      GlobalVariableSet(_KT_VAL_READ_POINT_NAME, _kt_val_read_point);
   }
}


// Call in OnChartEvent() of a indicator which run with test strategy together.
void KeyboardTrade_Tester_Indicator_OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
                  
   if (!IsTesting()) return;
   
   if (id == CHARTEVENT_KEYDOWN) {
      _kt_val_write_point = _kt_val_write_point + 1;
      GlobalVariableSet(_KT_GLOBAL_VAL_NAME + IntegerToString(_kt_val_write_point), lparam);
      GlobalVariableSet(_KT_VAL_WRITE_POINT_NAME, _kt_val_write_point);
   }
}

//+------------------------------------------------------------------+
//| Callback for live EA.                                            |
//+------------------------------------------------------------------+
void KeyboardTrade_OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
   if (id == CHARTEVENT_KEYDOWN) {
      _kt_OnKeyDown(lparam);
   }
}

//+------------------------------------------------------------------+
//| Callback for both live and test mode.                            |
//| Only call in strategy, not in indicator.                         |
//+------------------------------------------------------------------+
void KeyboardTrade_OnInit() {
}

void KeyboardTrade_OnDeinit(const int reason) {
   ObjectDelete(_KT_CMD_LABEL_NAME);
   GlobalVariableDel(_KT_GLOBAL_VAL_NAME);
   if (IsTesting()) {
      int read_point = (int) NormalizeDouble(GlobalVariableGet(_KT_VAL_READ_POINT_NAME), 0);
      int write_point = (int) NormalizeDouble(GlobalVariableGet(_KT_VAL_WRITE_POINT_NAME), 0);
      if (read_point < write_point) {
         for (int i = read_point + 1; i <= write_point; i++) {
            string val_name = _KT_GLOBAL_VAL_NAME + IntegerToString(i);
            GlobalVariableDel(val_name);
         }
      }
      GlobalVariableDel(_KT_VAL_READ_POINT_NAME);
      GlobalVariableDel(_KT_VAL_WRITE_POINT_NAME);
   }
}