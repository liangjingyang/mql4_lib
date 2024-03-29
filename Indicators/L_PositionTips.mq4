//+------------------------------------------------------------------+
//|                                                 PositionTips.mq4 |
//|                                           Copyright 2018, Simple |
//+------------------------------------------------------------------+

#property copyright "Copyright 2018, Simple"
#property link      ""
#property indicator_chart_window
#property description ""
#property strict // Extern/Input box trick ;) - http://docs.mql4.com/basis/preprosessor/compilation

#include <L_SimpleLib.mqh>

enum __position{
   
   TopLeft = 0,      // Top Left
   TopRight = 1,     // Top Right
   BottomLeft = 2,   // Bottom Left
   BottomRight = 3   // Bottom Right

};

extern string  Info            = "--------------------------------------------------------";         // ------- 指标信息
extern string  Name            = "Position Tips";
extern string  Version         = "v.1.0.6";
extern string  Contact         = "simple.continue@gmail.com";

// Account Global
extern string Account_Setup    = "--------------------------------------------------------";         // ------- 账户设置
extern double InitBalance      = 50000;      // 账户初始本金
extern double AccountRiskPercent = 5;          // 风险百分比
extern double BalancePerLots   = 10000;       // 有多少本金才能做一手

// Current Chart
extern string Chart_Setup      = "--------------------------------------------------------";         // ------- 当前图表设置
extern double StopLossPips     = 50;         // 止损点数（pips）

extern string Box              = "--------------------------------------------------------";         // ------- 显示设置
extern color Color_BackGround  = clrNONE;    // 背景颜色
extern color Color_Normal      = Aqua;       // Normal Color
extern int Font_Size           = 8;         // 字体大小
extern string Font_Face        = "Arial";   // 字体
extern __position Position     = TopRight;   // 显示位置
extern int Distance_X          = 14;         // 横向距离
extern int Distance_Y          = 12;         // 纵向距离

double MyPoint = 0.0;
string MySymbol = "";
color Color_Danger = Red;        // Danger Color
color Color_Warning = Orange;     // Warning Color
color theColor;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
   
   MyPoint = Point;
   if( Digits == 3 || Digits == 5 )MyPoint = Point * 10;
   
   MySymbol = Symbol();
   
   return( 0 );
   
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit(){

   remove_box();
   return( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){

   create_box();   
   return( 0 );
   
}

//+------------------------------------------------------------------+
//| Current Spread for current pair                                  |
//+------------------------------------------------------------------+
double current_spread(){
   double spread = spreadInBigPoint(MySymbol);
   return(spread);
}

//+------------------------------------------------------------------+
//| Create a box information                                         |
//+------------------------------------------------------------------+
int create_box(){
   
   double riskMoney = InitBalance * ( AccountRiskPercent / 100 );
   
   double tickValue = getTickValueInAccountCurrency(MySymbol);
   double tickSize = MarketInfo( MySymbol, MODE_TICKSIZE );
   double equityLimitLots = AccountEquity() / BalancePerLots;
   
   double totalProfit = 0.0, usedRiskMoney = 0.0, usedLots = 0.0;
   int noSLOrder = 0, orderCount = 0;
   check_orders(totalProfit, usedRiskMoney, noSLOrder, usedLots, orderCount);
   double availableRiskMoney = riskMoney - usedRiskMoney;
   
   int availableOrderCount = 1;
   if (totalProfit < 0) {
      availableOrderCount = 2 - orderCount;
   }
   
   // TODO: tickValue in USD;
   double positionSize = getLotsByPointAndMoney(MySymbol, bigPointToPoint(MySymbol, StopLossPips), availableRiskMoney);
   if (positionSize + usedLots > equityLimitLots) {
      positionSize = equityLimitLots - usedLots;
   }


   ObjectCreate("InitBalance", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "InitBalance", OBJPROP_CORNER, Position );
   ObjectSet( "InitBalance", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "InitBalance", OBJPROP_YDISTANCE, 5 + Distance_Y * 1 );
   ObjectSetText( "InitBalance", "Initial Balance : " + DoubleToStr( InitBalance, 2 ) , Font_Size, Font_Face, Color_Normal);
   
   ObjectCreate("AccountRiskPercent", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "AccountRiskPercent", OBJPROP_CORNER, Position );
   ObjectSet( "AccountRiskPercent", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "AccountRiskPercent", OBJPROP_YDISTANCE, 5 + Distance_Y * 2 );
   ObjectSetText( "AccountRiskPercent", "Account Risk Percent : " + DoubleToStr( AccountRiskPercent / 100, 2 ) , Font_Size, Font_Face, Color_Normal);

   ObjectCreate("RiskM", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "RiskM", OBJPROP_CORNER, Position );
   ObjectSet( "RiskM", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "RiskM", OBJPROP_YDISTANCE, 5 + Distance_Y * 3 );
   ObjectSetText( "RiskM", "Allowed Risk : " + DoubleToStr( riskMoney, 2 ) , Font_Size, Font_Face, Color_Normal);
   
   ObjectCreate("UsedRiskM", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "UsedRiskM", OBJPROP_CORNER, Position );
   ObjectSet( "UsedRiskM", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "UsedRiskM", OBJPROP_YDISTANCE, 5 + Distance_Y * 4 );
   ObjectSetText( "UsedRiskM", "Used Risk : " + DoubleToStr( usedRiskMoney, 2 ) , Font_Size, Font_Face, Color_Normal);
   
   ObjectCreate("AvailableRiskM", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "AvailableRiskM", OBJPROP_CORNER, Position );
   ObjectSet( "AvailableRiskM", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "AvailableRiskM", OBJPROP_YDISTANCE, 5 + Distance_Y * 5 );
   ObjectSetText( "AvailableRiskM", "Available Risk : " + DoubleToStr( availableRiskMoney, 2 ) , Font_Size, Font_Face, Color_Normal);
   
   

   ObjectCreate("AskPrice", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "AskPrice", OBJPROP_CORNER, Position );
   ObjectSet( "AskPrice", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "AskPrice", OBJPROP_YDISTANCE, 5 + Distance_Y * 7 );
   ObjectSetText( "AskPrice", MySymbol + " Ask : " + DoubleToStr( Ask, Digits ), Font_Size, Font_Face, Color_Normal);
   
   ObjectCreate("BidPrice", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "BidPrice", OBJPROP_CORNER, Position );
   ObjectSet( "BidPrice", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "BidPrice", OBJPROP_YDISTANCE, 5 + Distance_Y * 8 );
   ObjectSetText( "BidPrice", MySymbol + " Bid : " + DoubleToStr( Bid, Digits ), Font_Size, Font_Face, Color_Normal);
   
   ObjectCreate( "Spread", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "Spread", OBJPROP_CORNER, Position );
   ObjectSet( "Spread", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "Spread", OBJPROP_YDISTANCE, 5 + Distance_Y * 9 );
   ObjectSetText( "Spread", MySymbol + " Spread : " + DoubleToStr( current_spread(), 2 ) , Font_Size, Font_Face, Color_Normal); 

   ObjectCreate("Profit", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "Profit", OBJPROP_CORNER, Position );
   ObjectSet( "Profit", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "Profit", OBJPROP_YDISTANCE, 5 + Distance_Y * 10 );
   ObjectSetText( "Profit", MySymbol + " Profit : " + DoubleToStr(totalProfit , 2 ) , Font_Size, Font_Face, Color_Normal);
   
   
   
   ObjectCreate("StopLoss", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "StopLoss", OBJPROP_CORNER, Position );
   ObjectSet( "StopLoss", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "StopLoss", OBJPROP_YDISTANCE, 5 + Distance_Y * 12 );
   ObjectSetText( "StopLoss", "Stop Loss : " + DoubleToStr( StopLossPips, 2 ) , Font_Size, Font_Face, Color_Normal);
   
   theColor = ( positionSize > 0 ) ? Color_Normal : Color_Danger;
   string pSize = ( positionSize > 0 ) ? DoubleToStr( positionSize, 3 ) : "0.000" ;
   ObjectCreate("PositionSize", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "PositionSize", OBJPROP_CORNER, Position );
   ObjectSet( "PositionSize", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "PositionSize", OBJPROP_YDISTANCE, 5 + Distance_Y * 13 );
   ObjectSetText( "PositionSize", "Available Lots: " + pSize , Font_Size, Font_Face, theColor); 
   
   theColor = ( availableOrderCount > 0 ) ? Color_Normal : Color_Danger;
   string theCount = ( availableOrderCount > 0 ) ? IntegerToString( availableOrderCount ) : "0" ;
   ObjectCreate("AvailableOrder", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "AvailableOrder", OBJPROP_CORNER, Position );
   ObjectSet( "AvailableOrder", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "AvailableOrder", OBJPROP_YDISTANCE, 5 + Distance_Y * 14 );
   ObjectSetText( "AvailableOrder", "Available Order: " + theCount , Font_Size, Font_Face, theColor); 
   
   
   theColor = ( noSLOrder > 0 ) ? Color_Danger : Color_Normal;
   ObjectCreate("NoSLOrder", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "NoSLOrder", OBJPROP_CORNER, Position );
   ObjectSet( "NoSLOrder", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "NoSLOrder", OBJPROP_YDISTANCE, 5 + Distance_Y * 16 );
   ObjectSetText( "NoSLOrder", "No SL Orders : " + IntegerToString( noSLOrder ) , Font_Size, Font_Face, theColor);
   
   theColor = ( usedLots >= equityLimitLots ) ? Color_Danger : Color_Normal;
   ObjectCreate("UsedLots", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "UsedLots", OBJPROP_CORNER, Position );
   ObjectSet( "UsedLots", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "UsedLots", OBJPROP_YDISTANCE, 5 + Distance_Y * 17 );
   ObjectSetText( "UsedLots", "Used Lots : " +  DoubleToStr( usedLots, 3 ) , Font_Size, Font_Face, theColor);



   ObjectCreate("TickValue", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "TickValue", OBJPROP_CORNER, Position );
   ObjectSet( "TickValue", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "TickValue", OBJPROP_YDISTANCE, 5 + Distance_Y * 19 );
   ObjectSetText( "TickValue", "Tick Value : " + DoubleToStr( tickValue, 5 ) , Font_Size, Font_Face, Color_Normal);

   ObjectCreate("TickSize", OBJ_LABEL, 0, 0, 0);
   ObjectSet( "TickSize", OBJPROP_CORNER, Position );
   ObjectSet( "TickSize", OBJPROP_XDISTANCE, Distance_X);
   ObjectSet( "TickSize", OBJPROP_YDISTANCE, 5 + Distance_Y * 20 );
   ObjectSetText( "TickSize", "Tick Size : " +  DoubleToStr( tickSize, 5 ) , Font_Size, Font_Face, Color_Normal);

   return( 0 );
      
}

//+------------------------------------------------------------------+
//| Remove a box information                                         |
//+------------------------------------------------------------------+
void remove_box(){

   ObjectDelete( "BoxBackground" );
   ObjectDelete( "AskPrice" );
   ObjectDelete( "BidPrice" );
   ObjectDelete( "Spread" );
   ObjectDelete( "Profit" );
   ObjectDelete( "StopLoss" );
   ObjectDelete( "InitBalance" );
   ObjectDelete( "AccountRiskPercent" );
   ObjectDelete( "RiskM" );
   ObjectDelete( "UsedRiskM" );
   ObjectDelete( "AvailableRiskM" );
   ObjectDelete( "PositionSize" );
   ObjectDelete( "NoSLOrder" );
   ObjectDelete( "UsedLots" );
   ObjectDelete("AvailableOrder");
   ObjectDelete( "TickValue" );
   ObjectDelete("TickSize");
   
}

//+------------------------------------------------------------------+
//| Total profit                                                     |
//+------------------------------------------------------------------+
void check_orders(double& ttProfit, double& usedRiskMoney, int& noSLOrder, double& usedLots, int& orderCount){
   
   for( int x = 0; x < OrdersTotal(); x++ ) {
   
       if( OrderSelect( x, SELECT_BY_POS, MODE_TRADES ) ) {
       
         if( OrderSymbol() == MySymbol ) {
            ttProfit += OrderProfit();
            orderCount += 1;
         }
         
         usedRiskMoney += order_used_risk_money();
         if (OrderStopLoss() == 0) noSLOrder += 1;
         usedLots += OrderLots();
       
       } else {
         Print("==PositionTips== OrderSelect failed error code is",GetLastError());
       }
          
   }
}

double order_used_risk_money() {
   double stop_loss = OrderStopLoss();
   double open_price = OrderOpenPrice();
   int order_type = OrderType();
   string order_symbol = OrderSymbol();
   double order_lots = OrderLots();
   if (isOrderLong(order_type)) {
      if (stop_loss >= open_price) {
         return 0;
      }
   } else {
      if (stop_loss <= open_price) {
         return 0;
      }
   }
   double pointDistance = priceDistanceInPoint(order_symbol, stop_loss, open_price);
   return getMoneyByPointAndLots(order_symbol, pointDistance, order_lots);
}