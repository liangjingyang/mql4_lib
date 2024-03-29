//+------------------------------------------------------------------+
//|                                                         test.mq4 |
//|                                        simple.continue@gmail.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "simple.continue@gmail.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <L_SimpleLib.mqh>;
#include <hash.mqh>;
#include <KeyboardTrade.mqh>;

input long InitBalance = 50000; //risk per trade is based on the initial balance which is set at year start
input double OrderRiskPercent = 1; //risk per trade
input double AccountRiskPercent = 5; //risk per trade
input long BalancePerLots = 10000; //balance per order
input double MarginLevelWeekend = 3000;
input bool EnableNotification = false;
input bool Debug = false;

const string DANGER = "DANGER";
const string WARNING = "WARNING";
const string INFO = "INFO";

const string GLOBAL_TAG = __FILE__;
int second_counter = 0;

Hash *notification_hash;
int notify_interval = 60; // the interval of notification
int timer_interval = 1;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   if (GlobalVariableCheck(GLOBAL_TAG)) 
   {
      Alert(GLOBAL_TAG + " has already been started on other chart!");
      return(INIT_FAILED);
   }
   GlobalVariableSet(GLOBAL_TAG, 1);
   
   notification_hash = new Hash();
   EventSetTimer(timer_interval);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
  KeyboardTrade_OnDeinit(reason);
  if (GlobalVariableCheck(GLOBAL_TAG)) 
  {
      GlobalVariableDel(GLOBAL_TAG);
      Alert(GLOBAL_TAG + " is stoped!");
      Print(GLOBAL_TAG + " is stoped!");
  }
  EventKillTimer();
  delete notification_hash;

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   if (IsTesting()) {
      KeyboardTrade_Tester_Strategy_OnTick();
   }
   // About last order should be in onTick
   CheckLastOrderAgainstTrendAndAlert();
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
   if (second_counter % 3 == 0) { // 3 seconds
      CheckLockPositionAndAlert();
      CheckLotsLimitAndAlert();
   }
   
   if (second_counter % 30 == 0) { // 30 seconds
      CheckStopLossAndSet();
      
   }
   
   if (second_counter % 60 == 0) { // 1 minute
      RefreshNotifyHash();
      CheckAccountRiskAndAlert();
      CheckLossPerOrderAndAlert();
   }
   
   if (second_counter % 300 == 0) { // 5 minutes
   }
   
   if (second_counter % 900 == 0) { // 15 minutes
   }
   
   if (second_counter % 1800 == 0) { // 30 minutes
   }
   
   if (second_counter % 3600 == 0) { // 1 hour
      CheckTimeAndAlert();
   }
   second_counter += 1;
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
   KeyboardTrade_OnChartEvent(id, lparam, dparam, sparam);
}
//+------------------------------------------------------------------+

void NotifyApp(string level, string message) {
   if (EnableNotification)
   {
      notifyApp("BSQD", level, message);
   }
   
}
   
void AlertAndNotifyApp(string key, string level, string message) {
   if (notification_hash.hGetDatetime(key) == NULL) {
      notification_hash.hPutDatetime(key, TimeCurrent());
      alert("BSQD", level, message);
      NotifyApp(level, message);
   }
}
   
void RefreshNotifyHash() {
    HashLoop *l ;
    Hash *del_keys = new Hash();
    datetime now = TimeCurrent();
    for( l = new HashLoop(notification_hash) ; l.hasNext() ; l.next()) {
        Print("notification_hash getKey");
        string key = l.key();
        datetime t = l.valDatetime();
        Print(key," = ",t);
        if (t + notify_interval < now) {
            del_keys.hPutInt(key, 1);
        }
    }
    delete l;
    
    HashLoop *m;
    for( m = new HashLoop(del_keys) ; m.hasNext() ; m.next()) {
        Print("del_keys getKey");
        string key = m.key();
        Print("del ", key);
        notification_hash.hDel(key);
    }
    delete m;
    delete del_keys;
}

double GetLossLimitPerOrder() {
  return (OrderRiskPercent / 100) * InitBalance;
}
  
/*The function returns the risk value of open orders*/
double GetOrderRiskMoney(int ticket) {
   double risk_money = 0;
   if (OrderSelect(ticket, SELECT_BY_TICKET))
   {
      double stop_loss = OrderStopLoss();
      double open_price = OrderOpenPrice();
      int order_type = OrderType();
      string order_symbol = OrderSymbol();
      double order_lots = OrderLots();
      if (isOrderLong(order_type)) {
         if (stop_loss < open_price) {
            double pointDistance = priceDistanceInPoint(order_symbol, stop_loss, open_price);
            risk_money = getMoneyByPointAndLots(order_symbol, pointDistance, order_lots);
         }
      } else {
         if (stop_loss > open_price) {
            double pointDistance = priceDistanceInPoint(order_symbol, stop_loss, open_price);
            risk_money = getMoneyByPointAndLots(order_symbol, pointDistance, order_lots);
         }
      }
   }
   return(risk_money);
}
   
/* the function returns the ticket of the last opened position*/
int GetLastOrderTicket(){
    int orders_total = OrdersTotal();
    int ticket = 0;
    datetime open_time = 0;
    
    for( int i = 0; i < orders_total; i++ )
    {
        if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) )
        {
           if( OrderOpenTime() > open_time )
           {     
             ticket = OrderTicket();
             open_time = OrderOpenTime();
           }           
        }
    }
    
    return(ticket);
}
 
// /* the function close the selected ticket of the last opened position*/
//void CloseSelectOrder(int ticket)
//  {
//    if( OrderSelect(ticket,SELECT_BY_TICKET) )
//      { 
//        if( OrderType() == OP_BUY )
//          if(OrderClose(ticket,OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),30,Red)) 
//            return;
//        
//        if( OrderType() == OP_SELL)  
//          if(OrderClose(ticket,OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),30,Red)) 
//            return;
//          
//        if( OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP )
//          if( OrderDelete(ticket))
//            return;         
//      }
//     return;  
//  }
  
///* the function close all the limit orders */
//void DeleteAllLimitOrders()
//  {
//    for(int i = 0; OrdersTotal(); i++)
//    {
//      if( OrderSelect(i, MODE_TRADES) )
//      {
//        if( OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP )
//        {  
//          Print(OrderTicket());
//          if( OrderDelete(OrderTicket()) )        
//            break;
//        }
//      }
//    }
//    
//    return;
//  }
  
void printLog(string msg) {
   if (Debug) {
      Print("=== DEBUG === " + msg);
   }
}

// -------------------------------------------------------------------------------------------------
/*
  Execute in onTick
  
  The function is to check whether every order is with stoploss, if not close or delete this order
*/   
//void CheckStopLossAndCloseOrder()
//  {
//    int total_order =  OrdersTotal();
//    int order_ticket = 0;   
//  
//    for( int i = 0; i < total_order; i++ )
//    {
//        if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) )
//        {
//            order_ticket = OrderTicket();
//                        
//            // no stoploss, close open order
//            if(OrderStopLoss() == 0)
//            {
//              //close order
//              // CloseSelectOrder(order_ticket);
//              AlertAndNotifyApp(DANGER, "订单入场未设止损，尝试关闭该订单！Symbol: " + OrderSymbol() + ", Profit: " + moneyToString(OrderTakeProfit()));
//              
//              break;             
//            }
//            else
//              continue; 
//         }
//     }
//     //Print("CheckStopLossAndCloseOrder finished!");
//     return;             
//  }
  
/*
  Execute in onTick
  
  The function is to check whether every order is with stoploss, if not close or delete this order
*/   
void CheckStopLossAndSet() {
    int total_order =  OrdersTotal();
    int order_ticket = 0;   
   
    for( int i = 0; i < total_order; i++ )
    {
        if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) )
        {
            order_ticket = OrderTicket();
                        
            // no stoploss, close open order
            if(OrderStopLoss() == 0)
            {
              string order_symbol = OrderSymbol();
              double take_profit = OrderTakeProfit();    // TP of the selected order
              double open_price = OrderOpenPrice();     // Price of the selected order
              //set default stop loss
              double risk_money = GetLossLimitPerOrder();
              double stop_loss = 0.0;
              double tick_value_usd = getTickValueInAccountCurrency(order_symbol);
              double order_lots = OrderLots();
              if( OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP )
              { 
                  double distance = getPointByLotsAndMoney(order_symbol, order_lots, risk_money);
                  stop_loss = priceMovePointMoreThanStopLevel(order_symbol, open_price, -distance);
              } else if ( OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP )
              {
                  double distance = getPointByLotsAndMoney(order_symbol, order_lots, risk_money);
                  stop_loss = priceMovePointMoreThanStopLevel(order_symbol, open_price, distance);
              }
               
              bool ans = OrderModify(order_ticket, open_price, stop_loss, take_profit, 0);
              if (ans) {
                  string notify_key = __FUNCTION__ + "@" + IntegerToString(OrderTicket());
                  AlertAndNotifyApp(notify_key, DANGER, "订单入场未设止损，尝试以1%风险值设置默认止损！ StopLoss: " + 
                     priceToString(order_symbol, stop_loss) + ", OpenPrice: " + priceToString(order_symbol, OrderOpenPrice()));
              } else
              {
                  Print("CheckStopLossAndSet error " + IntegerToString(GetLastError()));
              }
              
              break;
            }         
         }
     }
     printLog(__FUNCTION__ + " finished!");
     return;             
}

/*
  The function is to check whether every order is with stoploss, if not close or delete this order
*/  
void CheckLotsLimitAndAlert() {
   double equity_limit_lots = AccountEquity() / BalancePerLots;
   double current_lots = 0.0;
   int total_order = OrdersTotal();
   int order_ticket = 0;   
   for( int i = 0; i < total_order; i++ )
   {
     if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) )
     {
         order_ticket = OrderTicket();
         current_lots += OrderLots();
     }
   }
   
   if (current_lots > equity_limit_lots)
   {
      //int last_order_ticket = GetLastOrderTicket();
      //CloseSelectOrder(last_order_ticket);
      string notify_key = __FUNCTION__;
      AlertAndNotifyApp(notify_key, DANGER, "已超过最大手数！ 手数上限为: " + DoubleToString(equity_limit_lots, 3) + ", 当前实际手数：" + DoubleToStr(current_lots, 3));
   }
   printLog(__FUNCTION__ + " finished!");
   return;
}

/*
  Execute in onTimer
  
  The function is to check margin level and alert
*/  
void CheckTimeAndAlert() {
   int friday = 5;
   int saturday = friday + 1;
   datetime local = TimeLocal();
   int day_of_week = TimeDayOfWeek(local);
   int hour = TimeHour(local);
   int rem = hour % 2;
   int day = TimeDay(local);
   double account_profit = AccountProfit();
   
   // 周五18点开始，每2小时提示一次， 浮亏不允许隔周；
   if (((day_of_week == friday && hour >= 18) || (day_of_week == saturday)) && (rem == 0))
   {
      
      if (account_profit < 0)
      {
         string notify_key = __FUNCTION__ + "@weekend";
         AlertAndNotifyApp(notify_key, DANGER, "浮亏不许隔周! 当前浮亏：" + moneyToString(account_profit));
      }
   }
   
   // 非农（每月第一个周五晚上18：00和20：00提示空仓）
   if (day_of_week == friday && day < 8 && (hour == 18 || hour == 20)) {
      if (account_profit != 0)
      {
         string notify_key = __FUNCTION__ + "@Non-farm";
         AlertAndNotifyApp(notify_key, WARNING, "非农临近请保持空仓！当前浮动盈亏：" + moneyToString(account_profit));
      }
      
   }
   printLog(__FUNCTION__ + " finished!");
   return;
}
   
   
/*
  Execute in OnTick
  
  The function is to check if the last order is the third order which is against trend, if it is, close is.
*/
void CheckLastOrderAgainstTrendAndAlert() {
   int order_ticket = GetLastOrderTicket();
   
   if (order_ticket == 0) 
   {
      return;
   }
   
   if (OrderSelect(order_ticket, SELECT_BY_TICKET, MODE_TRADES))
   {
      string order_symbol = OrderSymbol();
      int order_type = OrderType();
      int total_order = OrdersTotal();
      double open_price = OrderOpenPrice();
      datetime open_time = OrderOpenTime();
      double profit = 0;
      int count = 0;
      for( int i = 0; i < total_order; i++ )
      {
        if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) )
        {
            if (order_ticket != OrderTicket() && OrderSymbol() == order_symbol)
            {
               if (isOrderLong(order_type) && isOrderLong(OrderType()))
               {
                  count += 1;
                  profit += OrderProfit();
               } else if (!isOrderLong(order_type) && !isOrderLong(OrderType()))
               {
                  count += 1;
                  profit += OrderProfit();
               }
            }
         }
     }
     if (profit < 0 && count >= 2)
     {
         //CloseSelectOrder(order_ticket);
         string notify_key = __FUNCTION__ + "@" + IntegerToString(order_ticket);
         AlertAndNotifyApp(notify_key, DANGER, order_symbol + " 逆势加仓" + IntegerToString(count) + "次, 超过限制！订单方向：" + orderTypeToString(order_type));
     }
   }
   printLog(__FUNCTION__ + " finished!");
   return;
}

/*
  The function is to check whether risk per trade is over 2%, if not close or delete this order
*/
void CheckAccountRiskAndAlert() {
    double accountEquity = AccountEquity();
    double accountRiskLimit = InitBalance * (AccountRiskPercent / 100);
    double lossEquity = InitBalance - AccountEquity();
    if (lossEquity >= accountRiskLimit) {
      double lossPercent = lossEquity / InitBalance * 100;
      string notify_key = __FUNCTION__;
      AlertAndNotifyApp(notify_key, DANGER, "账户总亏损" + DoubleToStr(lossPercent, 1) + "%, 超过" + DoubleToStr(AccountRiskPercent, 1) + "%, 当前余额: " + moneyToString(accountEquity));
    }
    printLog(__FUNCTION__ + " finished!");
}     


/*
  The function is to check whether the loss per trade is over limit
*/
void CheckLossPerOrderAndAlert() {
   int total_order = OrdersTotal();
   int order_ticket = 0;
   double loss_limit = GetLossLimitPerOrder();
   for( int i = 0; i < total_order; i++ )
   {
     if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) )
     {
         double profit = OrderProfit();
         if (profit < 0 && profit < -loss_limit) {
            string notify_key = __FUNCTION__ + "@" + IntegerToString(OrderTicket());
            AlertAndNotifyApp(notify_key, DANGER, OrderSymbol() + " " + IntegerToString(OrderTicket()) + 
            "单笔亏损超过上限！ 上限：" + moneyToString(loss_limit) + ", 浮亏：" + moneyToString(profit));
         }
     }
   }
   printLog(__FUNCTION__ + " finished!");
}

/*
* This function is to check wether has hedge;
*/
void CheckLockPositionAndAlert() {
   int total_order = OrdersTotal();
   int order_ticket = 0;
   double loss_limit = GetLossLimitPerOrder();
   Hash *long_hash = new Hash();
   Hash *short_hash = new Hash();
   for( int i = 0; i < total_order; i++ )
   {
     if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) )
     {
         double lots = OrderLots();
         string symbol = OrderSymbol();
         int order_type = OrderType();
         double old_lots = 0;
         if (isOrderLong(order_type)) {
            old_lots = long_hash.hGetDouble(symbol);
            if (old_lots == NULL) {
               old_lots = 0;
            }
            long_hash.hPutDouble(symbol, old_lots + lots);
         } else {
            old_lots = short_hash.hGetDouble(symbol);
            if (old_lots == NULL) {
               old_lots = 0;
            }
            short_hash.hPutDouble(symbol, old_lots + lots);
         } 
     }
   }
   
   HashLoop *l;
   for (l = new HashLoop(long_hash); l.hasNext(); l.next()) {
      string symbol = l.key();
      double long_lots = l.valDouble();
      
      if (long_lots > 0) {
         double short_lots = short_hash.hGetDouble(symbol);
         if (short_lots != NULL) {
            if (long_lots == short_lots) {
               string notify_key = __FUNCTION__ + "@" + symbol;
               AlertAndNotifyApp(notify_key, DANGER, "禁止完全对冲锁仓！" +  symbol + " BUY Lots: " + DoubleToStr(long_lots, 3) + ", SELL Lots: " + DoubleToStr(short_lots, 3));
            } else if (short_lots > 0) {
               string notify_key = __FUNCTION__ + "@" + symbol;
               AlertAndNotifyApp(notify_key, DANGER, "禁止锁仓！" + symbol + " BUY Lots: " + DoubleToStr(long_lots, 3) + ", SELL Lots: " + DoubleToStr(short_lots, 3));
            }
         }
      }
   }
   
   delete l;
   delete long_hash;
   delete short_hash;
   printLog(__FUNCTION__ + " finished!");
}
   
// -------------------------------------------------------------------------------------------------