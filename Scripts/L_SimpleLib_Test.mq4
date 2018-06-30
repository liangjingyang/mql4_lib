//+------------------------------------------------------------------+
//|                                                  L_SimpleLib.mq4 |
//|                                        simple.continue@gmail.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "simple.continue@gmail.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <L_SimpleLib.mqh>
#include <UnitTest.mqh>

UnitTest *unitTest;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
      testAll();
  }
//+------------------------------------------------------------------+

void testAll() {
   unitTest = new UnitTest();
   
   test_spreadInBigPoint();
   test_spreadInPoint();
   test_pointToBigPoint();
   test_bigPointToPoint();
   test_priceDistanceInPoint();
   test_priceDistanceInBigPoint();
   test_normalizeLots();
   test_normalizePrice();
   test_priceMovePoint();
   
   unitTest.printSummary();
   delete unitTest;
}

void test_spreadInBigPoint() {
   unitTest.testCase(__FUNCTION__);
   string symbol = "EURUSD";
   double actual_spread = MarketInfo(symbol, MODE_SPREAD);
   double expected_spread = spreadInBigPoint(symbol) * 10;
   unitTest.assertEquals("Test " + symbol + " spreadInBigPoint", expected_spread, actual_spread);
   
   symbol = "USDJPY";
   actual_spread = MarketInfo(symbol, MODE_SPREAD);
   expected_spread = spreadInBigPoint(symbol) * 10;
   unitTest.assertEquals("Test " + symbol + " spreadInBigPoint", expected_spread, actual_spread);
   
   symbol = "XAUUSD";
   actual_spread = MarketInfo(symbol, MODE_SPREAD);
   expected_spread = spreadInBigPoint(symbol);
   unitTest.assertEquals("Test " + symbol + " spreadInBigPoint", expected_spread, actual_spread);
   
   symbol = "XAGUSD";
   actual_spread = MarketInfo(symbol, MODE_SPREAD);
   expected_spread = spreadInBigPoint(symbol) * 10;
   unitTest.assertEquals("Test " + symbol + " spreadInBigPoint", expected_spread, actual_spread);
   
   symbol = "DXY";
   actual_spread = MarketInfo(symbol, MODE_SPREAD);
   expected_spread = spreadInBigPoint(symbol) * 10;
   unitTest.assertEquals("Test " + symbol + " spreadInBigPoint", expected_spread, actual_spread);
}

void test_spreadInPoint() {
   unitTest.testCase(__FUNCTION__);
   string symbol = "EURUSD";
   double actual_spread = MarketInfo(symbol, MODE_SPREAD);
   double expected_spread = spreadInPoint(symbol);
   unitTest.assertEquals("Test " + symbol + " spreadInPoint", expected_spread, actual_spread);
   
   symbol = "USDJPY";
   actual_spread = MarketInfo(symbol, MODE_SPREAD);
   expected_spread = spreadInPoint(symbol);
   unitTest.assertEquals("Test " + symbol + " spreadInPoint", expected_spread, actual_spread);
   
   symbol = "XAUUSD";
   actual_spread = MarketInfo(symbol, MODE_SPREAD);
   expected_spread = spreadInPoint(symbol);
   unitTest.assertEquals("Test " + symbol + " spreadInPoint", expected_spread, actual_spread);
   
   symbol = "XAGUSD";
   actual_spread = MarketInfo(symbol, MODE_SPREAD);
   expected_spread = spreadInPoint(symbol);
   unitTest.assertEquals("Test " + symbol + " spreadInPoint", expected_spread, actual_spread);
   
   symbol = "DXY";
   actual_spread = MarketInfo(symbol, MODE_SPREAD);
   expected_spread = spreadInPoint(symbol);
   unitTest.assertEquals("Test " + symbol + " spreadInPoint", expected_spread, actual_spread);
}

//double pointToBigPoint(string symbol, double point);
void test_pointToBigPoint() {
   unitTest.testCase(__FUNCTION__);
   string symbol = "EURUSD";
   double point = 100;
   double actual_point = point;
   double expected_point = pointToBigPoint(symbol, point) * 10;
   unitTest.assertEquals("Test " + symbol + " pointToBigPoint", expected_point, actual_point);
   
   symbol = "USDJPY";
   point = 100;
   actual_point = point;
   expected_point = pointToBigPoint(symbol, point) * 10;
   unitTest.assertEquals("Test " + symbol + " pointToBigPoint", expected_point, actual_point);
   
   symbol = "XAUUSD";
   point = 100;
   actual_point = point;
   expected_point = pointToBigPoint(symbol, point);
   unitTest.assertEquals("Test " + symbol + " pointToBigPoint", expected_point, actual_point);
   
   symbol = "XAGUSD";
   point = 100;
   actual_point = point;
   expected_point = pointToBigPoint(symbol, point) * 10;
   unitTest.assertEquals("Test " + symbol + " pointToBigPoint", expected_point, actual_point);
   
   symbol = "DXY";
   point = 100;
   actual_point = point;
   expected_point = pointToBigPoint(symbol, point) * 10;
   unitTest.assertEquals("Test " + symbol + " pointToBigPoint", expected_point, actual_point);
}

//double bigPointToPoint(string symbol, double big_point);
void test_bigPointToPoint() {
   unitTest.testCase(__FUNCTION__);
   string symbol = "EURUSD";
   double point = 100;
   double actual_point = point * 10;
   double expected_point = bigPointToPoint(symbol, point);
   unitTest.assertEquals("Test " + symbol + " bigPointToPoint", expected_point, actual_point);
   
   symbol = "USDJPY";
   point = 100;
   actual_point = point * 10;
   expected_point = bigPointToPoint(symbol, point);
   unitTest.assertEquals("Test " + symbol + " bigPointToPoint", expected_point, actual_point);
   
   symbol = "XAUUSD";
   point = 100;
   actual_point = point;
   expected_point = bigPointToPoint(symbol, point);
   unitTest.assertEquals("Test " + symbol + " bigPointToPoint", expected_point, actual_point);
   
   symbol = "XAGUSD";
   point = 100;
   actual_point = point * 10;
   expected_point = bigPointToPoint(symbol, point);
   unitTest.assertEquals("Test " + symbol + " bigPointToPoint", expected_point, actual_point);
   
   symbol = "DXY";
   point = 100;
   actual_point = point * 10;
   expected_point = bigPointToPoint(symbol, point);
   unitTest.assertEquals("Test " + symbol + " bigPointToPoint", expected_point, actual_point);
}

//double priceDistanceInPoint(string symbol, double price1, double price2);
void test_priceDistanceInPoint() {
   unitTest.testCase(__FUNCTION__);
   string symbol = "EURUSD";
   double price1 = 1.16000;
   double price2 = 1.16300;
   double expected_distance = 300;
   double actual_distance = priceDistanceInPoint(symbol, price1, price2);
   unitTest.assertEquals("Test " + symbol + " priceDistanceInPoint", expected_distance, actual_distance);
   
   symbol = "USDJPY";
   price1 = 110.100;
   price2 = 110.000;
   expected_distance = 100;
   actual_distance = priceDistanceInPoint(symbol, price1, price2);
   unitTest.assertEquals("Test " + symbol + " priceDistanceInPoint", expected_distance, actual_distance);
   
   symbol = "XAUUSD";
   price1 = 1252.70;
   price2 = 1252.20;
   expected_distance = 50;
   actual_distance = priceDistanceInPoint(symbol, price1, price2);
   unitTest.assertEquals("Test " + symbol + " priceDistanceInPoint", expected_distance, actual_distance);
   
   symbol = "XAGUSD";
   price1 = 16.100;
   price2 = 16.000;
   expected_distance = 100;
   actual_distance = priceDistanceInPoint(symbol, price1, price2);
   unitTest.assertEquals("Test " + symbol + " priceDistanceInPoint", expected_distance, actual_distance);
   
   symbol = "DXY";
   price1 = 952.100;
   price2 = 953.000;
   expected_distance = 900;
   actual_distance = priceDistanceInPoint(symbol, price1, price2);
   unitTest.assertEquals("Test " + symbol + " priceDistanceInPoint", expected_distance, actual_distance);
}

//double priceDistanceInBigPoint(string symbol, double price1, double price2);
void test_priceDistanceInBigPoint() {
   unitTest.testCase(__FUNCTION__);
   string symbol = "EURUSD";
   double price1 = 1.16000;
   double price2 = 1.16300;
   double expected_distance = 30;
   double actual_distance = priceDistanceInBigPoint(symbol, price1, price2);
   unitTest.assertEquals("Test " + symbol + " priceDistanceInBigPoint", expected_distance, actual_distance);
   
   symbol = "USDJPY";
   price1 = 110.100;
   price2 = 110.000;
   expected_distance = 10;
   actual_distance = priceDistanceInBigPoint(symbol, price1, price2);
   unitTest.assertEquals("Test " + symbol + " priceDistanceInBigPoint", expected_distance, actual_distance);
   
   symbol = "XAUUSD";
   price1 = 1252.70;
   price2 = 1252.20;
   expected_distance = 50;
   actual_distance = priceDistanceInBigPoint(symbol, price1, price2);
   unitTest.assertEquals("Test " + symbol + " priceDistanceInBigPoint", expected_distance, actual_distance);
   
   symbol = "XAGUSD";
   price1 = 16.100;
   price2 = 16.000;
   expected_distance = 10;
   actual_distance = priceDistanceInBigPoint(symbol, price1, price2);
   unitTest.assertEquals("Test " + symbol + " priceDistanceInBigPoint", expected_distance, actual_distance);
   
   symbol = "DXY";
   price1 = 952.100;
   price2 = 953.000;
   expected_distance = 90;
   actual_distance = priceDistanceInBigPoint(symbol, price1, price2);
   unitTest.assertEquals("Test " + symbol + " priceDistanceInBigPoint", expected_distance, actual_distance);
}

//double normalizeLots(string symbol, double lots);
void test_normalizeLots() {
   unitTest.testCase(__FUNCTION__);
   string symbol = "EURUSD";
   double lots = 0.1201;
   double expected_lots = 0.12;
   double actual_lots = normalizeLots(symbol, lots);
   unitTest.assertEquals("Test " + symbol + " test_normalizeLots", expected_lots, actual_lots);
   
   symbol = "USDJPY";
   lots = 21.21;
   expected_lots = 20;
   actual_lots = normalizeLots(symbol, lots);
   unitTest.assertEquals("Test " + symbol + " test_normalizeLots", expected_lots, actual_lots);
   
   symbol = "XAUUSD";
   lots = 0.001;
   expected_lots = 0;
   actual_lots = normalizeLots(symbol, lots);
   unitTest.assertEquals("Test " + symbol + " test_normalizeLots", expected_lots, actual_lots);
}

//double normalizePrice(string symbol, double price);
void test_normalizePrice() {
   unitTest.testCase(__FUNCTION__);
   string symbol = "EURUSD";
   double price = 1.160128;
   double expected_price = 1.16013;
   double actual_price = normalizePrice(symbol, price);
   unitTest.assertEquals("Test " + symbol + " test_normalizePrice", expected_price, actual_price);
   
   symbol = "USDJPY";
   price = 110.210001;
   expected_price = 110.210;
   actual_price = normalizePrice(symbol, price);
   unitTest.assertEquals("Test " + symbol + " test_normalizePrice", expected_price, actual_price);
   
   symbol = "XAUUSD";
   price = 1234.01376;
   expected_price = 1234.01;
   actual_price = normalizePrice(symbol, price);
   unitTest.assertEquals("Test " + symbol + " test_normalizePrice", expected_price, actual_price);
}


//double priceMovePoint(string symbol, double price, double point);
void test_priceMovePoint() {
   unitTest.testCase(__FUNCTION__);
   string symbol = "EURUSD";
   double price = 1.160128;
   double point = 300;
   double expected_price = 1.16313;
   double actual_price = priceMovePoint(symbol, price, point);
   unitTest.assertEquals("Test " + symbol + " test_priceMovePoint", expected_price, actual_price);
   
   symbol = "USDJPY";
   price = 110.100;
   point = -300;
   expected_price = 109.800;
   actual_price = priceMovePoint(symbol, price, point);
   unitTest.assertEquals("Test " + symbol + " test_priceMovePoint", expected_price, actual_price);
   
   symbol = "XAUUSD";
   price = 1234.223;
   point = -300;
   expected_price = 1231.22;
   actual_price = priceMovePoint(symbol, price, point);
   unitTest.assertEquals("Test " + symbol + " test_priceMovePoint", expected_price, actual_price);
   
   symbol = "DXY";
   price = 110.100;
   point = -300;
   expected_price = 109.800;
   actual_price = priceMovePoint(symbol, price, point);
   unitTest.assertEquals("Test " + symbol + " test_priceMovePoint", expected_price, actual_price);
}
 
/**
double getLotsByPointAndMoney(string symbol, double point, double money);
double getPointByLotsAndMoney(string symbol, double lots, double money);
double getMoneyByPointAndLots(string symbol, double point, double lots);
bool isOrderLong(int order_type);

void notifyApp(string level, string message);
void alertAndNotifyApp(string level, string message);

**/