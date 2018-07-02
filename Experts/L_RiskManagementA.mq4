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

input long InitBalance = 50000; //risk per trade is based on the initial balance which is set at year start
input double OrderRiskPercent = 1; //risk per trade
input double AccountRiskPercent = 5; //risk per trade
input long BalancePerLots = 10000; //balance per order
input double MarginLevelWeekend = 3000;
input bool EnableNotification = true;

const string DANGER = "DANGER";
const string WARNING = "WARNING";
const string INFO = "INFO";

const string GLOBAL_TAG = __FILE__;
int Minute_Counter = 0;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
      if (GlobalVariableCheck(GLOBAL_TAG)) 
      {
         Alert(GLOBAL_TAG + " has already been started on other chart!");
         return(INIT_FAILED);
      }
      GlobalVariableSet(GLOBAL_TAG, 1);
      EventSetTimer(60);
         
      return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  //--- destroy timer
     EventKillTimer();
     if (GlobalVariableCheck(GLOBAL_TAG)) 
     {
         GlobalVariableDel(GLOBAL_TAG);
         Alert(GLOBAL_TAG + " is stoped!");
         Print(GLOBAL_TAG + " is stoped!");
     }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
      CheckStopLossAndSet();
      //CheckStopLossAndCloseOrder();
      CheckLotsLimitAndCloseLast();
      CheckLastOrderAgainstTrendAndClose();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
    if (Minute_Counter % 5 == 0) // 5 minutes
      {
         CheckAccountRisk();
      } else if (Minute_Counter % 60 == 0) // 1 hour
      {
         CheckMarginLevelAndAlertAtWeekend();
      }
      Minute_Counter += 1;
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+

void NotifyApp(string level, string message) 
   {
      if (EnableNotification)
      {
         notifyApp("BSQD", level, message);
      }
      
   }
   
void AlertAndNotifyApp(string level, string message) 
   {
      alert("BSQD", level, message);
      NotifyApp(level, message);
   }
   
bool isOrderLong(int order_type)
   {
      return (order_type == OP_BUY || order_type == OP_BUYLIMIT || OP_BUYSTOP);
   }

double GetRiskMoneyPerOrder()
  {
     return (OrderRiskPercent / 100) * InitBalance;
  }
  
/*The function returns the risk value of open orders*/
double GetOrderRiskMoney(int ticket)
   {
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
int GetLastOrderTicket()
  {
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
 
 /* the function close the selected ticket of the last opened position*/
void CloseSelectOrder(int ticket)
  {
    if( OrderSelect(ticket,SELECT_BY_TICKET) )
      { 
        if( OrderType() == OP_BUY )
          if(OrderClose(ticket,OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),30,Red)) 
            return;
        
        if( OrderType() == OP_SELL)  
          if(OrderClose(ticket,OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),30,Red)) 
            return;
          
        if( OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP )
          if( OrderDelete(ticket))
            return;         
      }
     return;  
  }
  
/* the function close all the limit orders */
void DeleteAllLimitOrders()
  {
    for(int i = 0; OrdersTotal(); i++)
    {
      if( OrderSelect(i, MODE_TRADES) )
      {
        if( OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP )
        {  
          Print(OrderTicket());
          if( OrderDelete(OrderTicket()) )        
            break;
        }
      }
    }
    
    return;
  }

// -------------------------------------------------------------------------------------------------
/*
  Execute in onTick
  
  The function is to check whether every order is with stoploss, if not close or delete this order
*/   
void CheckStopLossAndCloseOrder()
  {
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
              //close order
              CloseSelectOrder(order_ticket);
              AlertAndNotifyApp(DANGER, "订单入场未设止损，尝试关闭该订单！Symbol: " + OrderSymbol() + ", Profit: " + moneyToString(OrderTakeProfit()));
              
              break;             
            }
            else
              continue; 
         }
     }
     //Print("CheckStopLossAndCloseOrder finished!");
     return;             
  }
  
/*
  Execute in onTick
  
  The function is to check whether every order is with stoploss, if not close or delete this order
*/   
void CheckStopLossAndSet()
  {
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
              double risk_money = GetRiskMoneyPerOrder();
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
                AlertAndNotifyApp(DANGER, "订单入场未设止损，尝试以1%风险值设置默认止损！ StopLoss: " + 
                  priceToString(order_symbol, stop_loss) + ", OpenPrice: " + priceToString(order_symbol, OrderOpenPrice()));
              } else
              {
                  Print("CheckStopLossAndSet error " + IntegerToString(GetLastError()));
              }
              
              break;
            }         
         }
     }
     // Print("CheckStopLossAndSet finished!");
     return;             
  }

/*
  Execute in onTick

  The function is to check whether every order is with stoploss, if not close or delete this order
*/  
void CheckLotsLimitAndCloseLast() 
   {
      double equity_limit_lots = AccountEquity() / BalancePerLots;
      double current_lots = 0.0;
      double break_limit = false;
      int total_order = OrdersTotal();
      int order_ticket = 0;   
      for( int i = 0; i < total_order; i++ )
      {
        if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) )
        {
            order_ticket = OrderTicket();
            current_lots += OrderLots();
            if (current_lots > equity_limit_lots)
            {  
               break_limit = true;
               break;
            }
        }
      }
      
      if (break_limit)
      {
         int last_order_ticket = GetLastOrderTicket();
         CloseSelectOrder(last_order_ticket);
         AlertAndNotifyApp(DANGER, "已超过最大手数， 尝试强制关闭上一个订单！ Lots Limit: " + DoubleToString(equity_limit_lots, 3));
      }
      //Print("checkOrderCountAndCloseLast finished!");
      return;   
   }

/*
  Execute in onTimer
  
  The function is to check margin level and alert
*/  
void CheckMarginLevelAndAlertAtWeekend() 
   {
      datetime local = TimeLocal();
      int day_of_week = TimeDayOfWeek(local);
      int hour = TimeHour(local);
      if ((day_of_week == 5 && hour >= 14) || (day_of_week == 6))
      {
         double margin = AccountMargin();
         if (margin > 0)
         {
            double margin_level = AccountEquity() / AccountMargin();
            if (margin_level <= MarginLevelWeekend && AccountProfit() < 0)
            {
               AlertAndNotifyApp(DANGER, "预付款比例小于" + DoubleToStr(MarginLevelWeekend, 2) + "，浮亏不许隔周!");
            }
         }
      }
      return;   
   }
   
   
/*
  Execute in OnTick
  
  The function is to check if the last order is the third order which is against trend, if it is, close is.
*/
void CheckLastOrderAgainstTrendAndClose()
   {
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
         double count = 0;
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
            CloseSelectOrder(order_ticket);
            AlertAndNotifyApp(DANGER, "逆势加仓超过一次，尝试关闭上一个订单！" + orderDesctiption(order_symbol, order_type, open_price, open_time));
        }
      }
      return;
   }

/*
  The function is to check whether risk per trade is over 2%, if not close or delete this order
*/
void CheckAccountRisk()
  {
    double accountEquity = AccountEquity();
    double accountRiskLimit = InitBalance * (AccountRiskPercent / 100);
    double lossEquity = InitBalance - AccountEquity();
    if (lossEquity >= accountRiskLimit) {
      double lossPercent = lossEquity / InitBalance * 100;
      AlertAndNotifyApp(DANGER, "账户总亏损" + DoubleToStr(lossPercent, 1) + "%, 超过" + DoubleToStr(AccountRiskPercent, 1) + "%, 当前余额: " + moneyToString(accountEquity));
    }
  }     

string orderDesctiption(string symbol, int orderType, double openPrice, datetime openTime) {
   return "Symbol: " + symbol + ", OrderType: " + orderTypeToString(orderType) + ", OpenPrice: " + priceToString(symbol, openPrice) + ", OpenTime: " + openTime;
}
   
// -------------------------------------------------------------------------------------------------