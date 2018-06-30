//+------------------------------------------------------------------+
//|                                                         test.mq4 |
//|                                        simple.continue@gmail.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "simple.continue@gmail.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input long InitBalance = 50000; //risk per trade is based on the initial balance which is set at year start
input double RiskPerTrade = 0.01; //risk per trade
input long BalancePerLots = 10000; //balance per order
input double MarginLevelWeekend = 3000;
input bool EnableNotification = true;

const string DANGER = "DANGER";
const string WARNING = "WARNING";
const string INFO = "INFO";

const string GLOBAL_TAG = "RiskManagementA";
int Minute_Counter = 0;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
     if (GlobalVariableCheck(GLOBAL_TAG)) 
     {
         Alert(GLOBAL_TAG + " has already been started!");
         return(INIT_FAILED);
     }
//--- create timer
   EventSetTimer(60);
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
     if (GlobalVariableCheck(GLOBAL_TAG)) 
     {
         GlobalVariableDel(GLOBAL_TAG);
         Alert(GLOBAL_TAG + " is stoped!");
         Print(GLOBAL_TAG + " is stoped!");
     }
//--- destroy timer
     EventKillTimer();
      
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
         const string content = "#BSQD-" + level + "# " + message;
         SendNotification(content);
      }
      
   }
   
void AlertAndNotifyApp(string level, string message) 
   {
      Alert(message);
      NotifyApp(level, message);
   }
   
bool IsOrderLong(int order_type)
   {
      return (order_type == OP_BUY || order_type == OP_BUYLIMIT || OP_BUYSTOP);
   }

double GetRiskMoney()
  {
     return RiskPerTrade * InitBalance;
  }

double GetRiskMultiplier(string symbol)
  {
     double multiplier = 10;
     //Print(symbol);
     //commodities
     //XAU
     if(symbol == "XAUUSD")
       {
         multiplier = 1;
       }
     //XAG Symbol
     if(symbol == "XAGUSD")
       {
         multiplier = 50;         
       }  
     //XTI oil
     if(symbol == "XTIUSD")
       {
         multiplier = 1;                 
       }
     //Indices CFD,
     if(symbol == "US30" ||symbol == "US500" || symbol == "NAS100" || symbol == "JPN225"|| symbol == "GER30" )
       {
         multiplier = 0.1;         
       }   
     //Print(multiplier);     
     return multiplier;               
  }
  
double XGetPoint( string symbol ) 
  {
     double point;
   
     point = MarketInfo( symbol, MODE_POINT );
     double digits = NormalizeDouble( MarketInfo( symbol, MODE_DIGITS ), 0 );
   
     if( digits == 3 || digits == 5 ) {
        return(point*10.0);
     }
   
     return(point);
  }
  
/*The function returns the risk value of open orders*/
double GetRiskperTrade(int ticket)
  {
    double risk = 0;
    double point = 0;
    string symbol;
    
    if( OrderSelect(ticket, SELECT_BY_TICKET) )
      { 
        symbol = OrderSymbol();
        point = XGetPoint(symbol);
        
        if( OrderType() == OP_BUY )
        { 
            risk = GetRiskMultiplier(symbol)* OrderLots() * ((OrderOpenPrice() - OrderStopLoss())/point);
            return risk;
        }
        
        if( OrderType() == OP_SELL )
        { 
            risk = GetRiskMultiplier(symbol)* OrderLots() * ((OrderStopLoss() - OrderOpenPrice())/point);
            return risk;
        }
          
        if( OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP )
        { 
            risk = GetRiskMultiplier(symbol)* OrderLots() * (MathAbs(OrderStopLoss() - OrderOpenPrice())/point);
            return risk;
        }    
      }
      
      return risk;
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
  
string OrderTypeToString(int order_type)
   {
      switch (order_type)
      {
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
              AlertAndNotifyApp(DANGER, "订单入场未设止损，尝试关闭该订单！");
              
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
              double risk_money = GetRiskMoney();
              double tick_size = MarketInfo(order_symbol, MODE_TICKSIZE);
              int digits = (int) MarketInfo(order_symbol, MODE_DIGITS);
              double stop_loss = 0.0;
              double tick_value_usd = 0;
              double order_lots = OrderLots();
              if( OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP )
              { 
                  tick_value_usd = MathAbs(OrderProfit() / ((Bid - open_price) / tick_size)) / order_lots;
                  stop_loss = open_price - tick_size * (risk_money / tick_value_usd) / order_lots;
              } else if ( OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP )
              {
                  tick_value_usd = MathAbs(OrderProfit() / ((Ask - open_price) / tick_size)) / order_lots;
                  stop_loss = open_price + tick_size * (risk_money / tick_value_usd) / order_lots;
              }

              Print("CheckStopLossAndSet ====================== stoploss: " + DoubleToStr(stop_loss, digits) + ", open_price: " + DoubleToStr(open_price, digits) + ", tick_value_usd: " + DoubleToStr(tick_value_usd, 8) + ", profit: " + DoubleToStr(OrderProfit(), 2));
              bool ans = OrderModify(order_ticket, open_price, stop_loss, take_profit, 0);
              if (ans) {
                Print("CheckStopLossAndSet ======================");
                AlertAndNotifyApp(DANGER, "订单入场未设止损，尝试以1%风险值设置默认止损！ SL: " + DoubleToString(stop_loss, digits));
              } else
              {
                  Print("CheckStopLossAndSet error " + GetLastError());
              }
              
              break;             
            }
            else
              continue; 
         }
     }
     Print("CheckStopLossAndSet finished!");
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
         AlertAndNotifyApp(DANGER, "已超过最大手数， 尝试强制关闭上一个订单！ Lots: " + DoubleToString(current_lots, 3));
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
         double profit = 0;
         double count = 0;
         for( int i = 0; i < total_order; i++ )
         {
           if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) )
           {
               if (order_ticket != OrderTicket() && OrderSymbol() == order_symbol)
               {
                  if (IsOrderLong(order_type) && IsOrderLong(OrderType()))
                  {
                     count += 1;
                     profit += OrderProfit();
                  } else if (!IsOrderLong(order_type) && !IsOrderLong(OrderType()))
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
            AlertAndNotifyApp(DANGER, "第三次逆势加仓，尝试关闭该订单！ Symbol: " + order_symbol + ", OrderType: " + OrderTypeToString(order_type));
        }
      }
      return;
   }

/*
  The function is to check whether risk per trade is over 2%, if not close or delete this order
*/
//void CheckRiskperTrade()
//  {
//    int total_order =  OrdersTotal();
//    int order_ticket = 0;
//    double risk_per_trade = 0;    
//    
//    for( int i = 0; i < total_order; i++ )
//    {
//        if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) )
//        {
//            order_ticket = OrderTicket();         
//            
//            //to check Buy open positions whether risk is over 2%, trailing stoploss does not account
//            risk_per_trade = GetRiskperTrade(order_ticket);
//            //Print(risk_per_trade);
//            if( risk_per_trade > max_risk_per_trade)
//            {
//              CloseSelectOrder(order_ticket);
//              AlertAndNotifyApp(DANGER, "Risk per trade is over limit! order has been closed!");  
//              //push notifications
//              break; 
//            }
//            else 
//             continue; 
//        }          
//     }
//     //Print("Check Risk per trade finished!");
//     return;             
//  }     

   
// -------------------------------------------------------------------------------------------------