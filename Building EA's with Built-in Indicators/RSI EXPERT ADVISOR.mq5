//+------------------------------------------------------------------+
//|                                           RSI EXPERT ADVISOR.mq5 |
//|                                 Abioye Israel Pelumi (Forex YMN) |
//|                             https://linktr.ee/abioyeisraelpelumi |
//+------------------------------------------------------------------+
#property copyright "Abioye Israel Pelumi"
#property link      "https://linktr.ee/abioyeisraelpelumi"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade trade;

// Magic number
input int    MagicNumber = 1111;
input double account_balance          = 1000;  // Account Balance
input double percentage_risk = 2.0;   //     How many percent of the account do you want to risk per trade?
input bool   allow_modify  = false; // Do you allow break even modifications?
input int    rrr           = 3;      // Choose Risk Reward Ratio

int       rsi_handle;
double    rsi_buffer[];
string end = "23:59";

double open[];
double close[];
double high[];
double low[];
datetime time[];

double max_high = 0;
datetime min_time1 = 0;
double min_low = 0;
datetime min_time2 = 0;

datetime time_low = 0;
datetime times_high = 0;

string high_obj_name = "High_Line";
string low_obj_name = "Low_Line";

long chart_id;
double take_profit;
double  ask_price = 0;
double lot_size;
double risk_Amount;
double points_risk;

// Risk modification
double positionProfit = 0;
double positionopen = 0;
double positionTP = 0;
double positionSL = 0;
double modifyLevel = 0.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Configure RSI buffer as a series for easier indexing
   ArraySetAsSeries(rsi_buffer, true);

// Initialize RSI handle for the current symbol, timeframe, and parameters
   rsi_handle = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);

// Configure candlestick arrays as series
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(time, true);

// Set the magic number
   trade.SetExpertMagicNumber(MagicNumber);

   return (INIT_SUCCEEDED); // Indicate successful initialization
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   
   int currBars = iBars(_Symbol,_Period);
   static int prevBars = currBars;
   if(prevBars == currBars)
      return;
   prevBars = currBars;
// Copy RSI values from the indicator into the buffer
   CopyBuffer(rsi_handle, 0, 1, 100, rsi_buffer);

// Copy candlestick data
   CopyOpen(_Symbol, PERIOD_CURRENT, 1, 100, open);
   CopyClose(_Symbol, PERIOD_CURRENT, 1, 100, close);
   CopyHigh(_Symbol, PERIOD_CURRENT, 1, 100, high);
   CopyLow(_Symbol, PERIOD_CURRENT, 1, 100, low);
   CopyTime(_Symbol, PERIOD_CURRENT, 1, 100, time);

   static double max_high_static = max_high;
   static datetime min_time1_static = min_time1;

   static double min_low_static = min_low;
   static datetime min_time2_static = min_time2;




//GETTING TOTAL POSITIONS

   int totalPositions = 0;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);

      if(PositionSelectByTicket(ticket))
        {

         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber && PositionGetString(POSITION_SYMBOL) == ChartSymbol(chart_id))
           {


            totalPositions++;

           }
        }
     }

   ask_price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);


   if(totalPositions < 1)
     {

      if(((low[0] < min_low_static && close[0] > min_low_static && close[0] > open[0]) || (low[1] < min_low_static && close[0] > min_low_static
            && close[0] > open[0]) || (low[2] < min_low_static && close[0] > min_low_static
                                       && close[0] > open[0] && close[1] < open[1])))
        {


         take_profit = (close[0] - low[0]) * rrr + close[0];
         points_risk = close[0] - low[0];

         double riskAmount = account_balance * (percentage_risk / 100.0);
         double minus = NormalizeDouble(close[0] - low[0],5);
         lot_size = CalculateLotSize(_Symbol, riskAmount, minus);

         trade.Buy(lot_size,_Symbol,ask_price, low[0], take_profit);

        }

      else
         if(((high[0] > max_high_static && close[0] < max_high_static && close[0] < open[0]) || (high[1] > max_high_static && close[0] < max_high_static
               && close[0] < open[0]) || (high[2] > max_high_static && close[0] < max_high_static
                                          && close[0] < open[0] && close[1] > open[1])))
           {


            take_profit = MathAbs((high[0] - close[0]) * rrr - close[0]); // Adjusted take-profit calculation
            points_risk = MathAbs(high[0] - close[0]);

            double riskAmount = account_balance * (percentage_risk / 100.0);
            double minus = NormalizeDouble(high[0] - close[0],5);
            lot_size = CalculateLotSize(_Symbol, riskAmount, minus);


            trade.Sell(lot_size,_Symbol,ask_price, high[0], take_profit);
           }

     }



//CHART ID
   chart_id = ChartID();

   int total_bar_high = Bars(_Symbol,PERIOD_CURRENT,min_time1_static,TimeCurrent());

   for(int i = 0; i < 12; i++)
     {

      if(close[i] < open[i] && close[i+1] > open[i+1])
        {

         max_high = (double)MathMax(high[i],high[i+1]);
         min_time1 = (datetime)MathMin(time[i],time[i+1]);

         break;


        }
     }


   int total_bar_low = Bars(_Symbol,PERIOD_CURRENT,min_time2_static,TimeCurrent());
   for(int i = 0; i < 12; i++)
     {

      if(close[i] > open[i] && close[i+1] < open[i+1])
        {

         min_low = (double)MathMin(low[i],low[i+1]);

         min_time2 = (datetime)MathMin(time[i],time[i+1]);
         break;

        }

     }

   for(int i = 0; i < 12; i++)
     {

      if(rsi_buffer[i+1] < 30 && rsi_buffer[i] > rsi_buffer[i+1])
        {

         time_low = time[i+1];
         break;

        }

     }

   for(int i = 0; i < 12; i++)
     {

      if(rsi_buffer[i+1] > 70 && rsi_buffer[i] < rsi_buffer[i+1])
        {

         times_high = time[i+1];
         break;

        }

     }


   if((total_bar_high == 0 || total_bar_high > 12) && (min_time1 == times_high))
     {

      max_high_static = max_high;
      min_time1_static = min_time1;

     }
   else
      if(min_time1 != times_high && total_bar_high > 13)
        {
         max_high_static = 0;
         min_time1_static = 0;
        }

   if((total_bar_low == 0 || total_bar_low > 12) && (min_time2 == time_low))
     {

      min_low_static = min_low;
      min_time2_static = min_time2;

     }

   else
      if(min_time2 != time_low && total_bar_low > 13)
        {
         min_low_static = 0;
         min_time2_static = 0;
        }

   ObjectCreate(ChartID(),high_obj_name,OBJ_TREND,0,min_time1_static,max_high_static,TimeCurrent(),max_high_static);
   ObjectSetInteger(chart_id,high_obj_name,OBJPROP_COLOR,clrGreen);
   ObjectSetInteger(chart_id,high_obj_name,OBJPROP_WIDTH,3);


   ObjectCreate(ChartID(),low_obj_name,OBJ_TREND,0,min_time2_static,min_low_static,TimeCurrent(),min_low_static);
   ObjectSetInteger(chart_id,low_obj_name,OBJPROP_COLOR,clrRed);
   ObjectSetInteger(chart_id,low_obj_name,OBJPROP_WIDTH,3);
   
   if(allow_modify)
     {
      for(int i = 0; i < PositionsTotal(); i++)
        {
         ulong ticket = PositionGetTicket(i);


         if(PositionSelectByTicket(ticket))
           {
            positionopen = PositionGetDouble(POSITION_PRICE_OPEN);
            positionTP = PositionGetDouble(POSITION_TP);
            positionSL = PositionGetDouble(POSITION_SL);
            positionProfit = PositionGetDouble(POSITION_PROFIT);




            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PositionGetInteger(POSITION_MAGIC) == MagicNumber && PositionGetString(POSITION_SYMBOL) == ChartSymbol(chart_id))
              {

               modifyLevel = MathAbs(NormalizeDouble((positionSL - positionopen) - positionopen,4));

               if(ask_price <= modifyLevel)
                 {

                  trade.PositionModify(ticket, positionopen, positionTP);
                 }
              }


            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && PositionGetInteger(POSITION_MAGIC) == MagicNumber && PositionGetString(POSITION_SYMBOL) == ChartSymbol(chart_id))
              {

               modifyLevel = MathAbs(NormalizeDouble((positionopen - positionSL) + positionopen,4));

               if(ask_price >= modifyLevel)
                 {
                  trade.PositionModify(ticket, positionopen, positionTP);
                 }
              }

           }
        }

     }

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Function to calculate the lot size based on risk amount and stop loss
//+------------------------------------------------------------------+
double CalculateLotSize(string symbol, double riskAmount, double stopLossPips)
  {
// Get symbol information
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);

// Calculate pip value per lot
   double pipValuePerLot = tickValue / point;

// Calculate the stop loss value in currency
   double stopLossValue = stopLossPips * pipValuePerLot;

// Calculate the lot size
   double lotSize = riskAmount / stopLossValue;

// Round the lot size to the nearest acceptable lot step
   double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   lotSize = MathFloor(lotSize / lotStep) * lotStep;

// Ensure the lot size is within the allowed range
   double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   if(lotSize < minLot)
      lotSize = minLot;
   if(lotSize > maxLot)
      lotSize = maxLot;

   return lotSize;
  }
