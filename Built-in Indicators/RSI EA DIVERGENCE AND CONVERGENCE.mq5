//+------------------------------------------------------------------+
//|                                      MWL5INDICATORS_PROJECT5.mq5 |
//|                                                         ForexYMN |
//|                                             crownsoyin@gmail.com |
//+------------------------------------------------------------------+
#property copyright "ForexYMN"
#property link      "crownsoyin@gmail.com"
#property version   "1.00"
#include <Trade/Trade.mqh>
CTrade trade;

//INPUTS
input double risk_amount = 20; // $ PER TRADE
input double rrr = 4; //RRR
input int MagicNumber   = 9097; //MAGIC NUMBER


//DECLEAR INDICATOR HANDLES
int ma_handle;
int rsi_handle;
int stoch_handle;

//DECLEAR DOUBLE VARIABLES THAT STORES INDICATORS DATA
double ma_buffer[];
double rsi_buffer[];
double stoch_buffer_k[], stoch_buffer_d[];

//DECLEAR VARIABLES TO STORE CANDLE DATA
double open[];
double close[];
double high[];
double low[];
datetime time[];

//DECLEAR VARIBLE ROR RSI LOW AND CORESPONDING  PRICE
double   rsi_low_value;          // Stores the RSI value at the identified low point.
double   corresponding_low_value; // Stores the price (closing value) corresponding to the RSI low.
double   corresponding_low_ma;    // Stores the Moving Average value at the same point.
datetime rsi_low_time;           // Stores the timestamp of the RSI low.

//DECLEAR VARIABLE FOR THE MINIMUM CORRESPONDING PRICE VALUE
int  minimum_value_low;


//DECLEAR VARIBLE ROR NEW RSI LOW AND CORESPONDING  PRICE
double new_rsi_low_value;
datetime new_rsi_low_time;
double new_corresponding_low_value;


//DECLEAR VARIBLE ROR RSI HIGH AND CORESPONDING  PRICE
double   rsi_high_value;
double   corresponding_high_value;
double   corresponding_high_ma;
datetime rsi_high_time;

//DECLEAR VARIABLE FOR THE MAXIMUM CORRESPONDING PRICE VALUE
int maximum_value_high;

// DECLEAR VARIBLE ROR NEW RSI HIGH AND CORESPONDING PRICE
double new_rsi_high_value;
datetime new_rsi_high_time;
double new_corresponding_high_value;

datetime lastTradeBarTime = 0; // Store the time of the last trade bar



double take_profit;
double stop_loss;
double points_risk;
double lot_size;


double last_high;
double last_low;




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {


//INDICATOR PROPERTIES
   ma_handle = iMA(_Symbol,PERIOD_CURRENT,200,0,MODE_EMA,PRICE_CLOSE);
   rsi_handle = iRSI(_Symbol,PERIOD_CURRENT,14,PRICE_CLOSE);
   stoch_handle = iStochastic(_Symbol,PERIOD_CURRENT,5,3,3,MODE_SMA,STO_LOWHIGH);

//START FROM THE LATEST CANDLE ON THE CHART
   ArraySetAsSeries(ma_buffer,true);
   ArraySetAsSeries(rsi_buffer,true);
   ArraySetAsSeries(stoch_buffer_k,true);
   ArraySetAsSeries(stoch_buffer_d,true);


//START FROM THE LATEST CANDLE ON THE CHART
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);

//SET MAGIC NUMBER
   trade.SetExpertMagicNumber(MagicNumber);


   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

//ASK PRICE
   double ask_price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);

//COPY INDICATOR'S DATA FROM THE SECOND BAR ON THE CHART TO THE LAST 31st BAR ON THE CHART
   CopyBuffer(ma_handle,0,1,30,ma_buffer);
   CopyBuffer(stoch_handle,0,1,30,stoch_buffer_k);
   CopyBuffer(stoch_handle,1,1,30,stoch_buffer_d);
   CopyBuffer(rsi_handle,0,1,30,rsi_buffer);


//COPY CANDLE'S DATA FROM THE SECOND BAR ON THE CHART TO THE LAST 31st BAR ON THE CHART
   CopyOpen(_Symbol,PERIOD_CURRENT,1,30,open);
   CopyClose(_Symbol,PERIOD_CURRENT,1,30,close);
   CopyHigh(_Symbol,PERIOD_CURRENT,1,30,high);
   CopyLow(_Symbol,PERIOD_CURRENT,1,30,low);
   CopyTime(_Symbol,PERIOD_CURRENT,1,30,time);




//LOOP THROUGH THE LAST 30 BARS ON THE CHART
   for(int i = 0; i < 30; i++)
     {
      //PREVENT ARRAY OUT OF RANGE ERROR
      if((i+1 < 30) && (i+2 < 30) && (i < 30) && (i+3 < 30) && (i+4 < 30))
        {
         //LOGIC TO IDENTIFY THE LATEST RSI LOW
         if(rsi_buffer[i+4] > rsi_buffer[i+3] && rsi_buffer[i+2] > rsi_buffer[i+3] && rsi_buffer[i+1] > rsi_buffer[i+2] && rsi_buffer[i] > rsi_buffer[i+1])
           {
            //GETTING LATEST RSI LOW, CORRESPONDING PRICE, CORRESPONDING MA VALUE, and RSI TIME
            rsi_low_value = rsi_buffer[i+3];
            corresponding_low_value = close[i+3];
            corresponding_low_ma = ma_buffer[i+3];
            rsi_low_time = time[i+3];

            break;
           }

        }
     }




//TOTAL NUMBERS OF BARS FROM THE LAST SIGNIFICANT RSI LOW
   int total_bars_2 = 0;
   total_bars_2 = Bars(_Symbol,PERIOD_CURRENT,rsi_low_time, time[0]);

//MINIMUM CLOSE PRICE FROM THE LAST SIGNIFICANT RSI LOW
   minimum_value_low = ArrayMinimum(close,0,total_bars_2);

// Getting total positions
   int totalPositions = 0;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionGetInteger(POSITION_MAGIC) == MagicNumber && PositionGetString(POSITION_SYMBOL) == ChartSymbol(ChartID()))
        {
         totalPositions++;
        }
     }


//LOGIC FOR LAST HIGH
   for(int i = 0; i < 30; i++)
     {
      if(i < 30 && i+1 < 30)
        {
         if(close[i] < open[i] && close[i+1] > open[i+1])
           {

            last_high = MathMax(high[i],high[i+1]);

            break;
           }
        }


     }

//LOGIC FOR LAST LOW
   for(int i = 0; i < 30; i++)
     {
      if(i < 30 && i+1 < 30)
        {
         if(close[i] > open[i] && close[i+1] < open[i+1])
           {

            last_low = MathMin(low[i],low[i+1]);

            break;
           }
        }


     }


   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);

   if(corresponding_low_value > corresponding_low_ma && close[0] > ma_buffer[0] && close[minimum_value_low] >= corresponding_low_value)
     {
      //CREATE LINES TO MARK RSI AND CORRESPONDING PRICE
      ObjectCreate(ChartID(),"RSI LOW VALUE",OBJ_TREND,1,rsi_low_time,rsi_low_value,TimeCurrent(),rsi_low_value);
      ObjectCreate(ChartID(),"C-CANDLE",OBJ_TREND,0,rsi_low_time,corresponding_low_value,TimeCurrent(),corresponding_low_value);
      //SETTING OBJECTS COLOUR
      ObjectSetInteger(ChartID(),"RSI LOW VALUE",OBJPROP_COLOR,clrRed);
      ObjectSetInteger(ChartID(),"C-CANDLE",OBJPROP_COLOR,clrRed);

      //CREATE TWO LINES TO CONNECT RSI LOW AND THE CORRESPONDING PRICE ON THE CHART
      ObjectCreate(ChartID(),"C-CANDLE LINE",OBJ_TREND,0,rsi_low_time,corresponding_low_value,rsi_low_time,0);
      ObjectCreate(ChartID(),"RSI LOW LINE",OBJ_TREND,1,rsi_low_time,rsi_low_value,rsi_low_time,100);
      //SETTING OBJECTS COLOUR
      ObjectSetInteger(ChartID(),"C-CANDLE LINE",OBJPROP_COLOR,clrRed);
      ObjectSetInteger(ChartID(),"RSI LOW LINE",OBJPROP_COLOR,clrRed);

      //CREATE TEXTS TO MART RSI LOW AND CORRESPONDING PRICE (C-PRICE)
      ObjectCreate(ChartID(),"C-CANDLE TEXT",OBJ_TEXT,0,TimeCurrent(),corresponding_low_value);
      ObjectSetString(ChartID(),"C-CANDLE TEXT",OBJPROP_TEXT,"C-PRICE");
      ObjectCreate(ChartID(),"RSI LOW TEXT",OBJ_TEXT,1,TimeCurrent(),rsi_low_value);
      ObjectSetString(ChartID(),"RSI LOW TEXT",OBJPROP_TEXT,"RSI LOW");
      //SETTING TEXT COLOUR
      ObjectSetInteger(ChartID(),"C-CANDLE TEXT",OBJPROP_COLOR,clrRed);
      ObjectSetInteger(ChartID(),"RSI LOW TEXT",OBJPROP_COLOR,clrRed);


      //LOGIC TO GET THE NEW RSI LOW
      if(rsi_buffer[0] > rsi_buffer[1] && rsi_buffer[1] < rsi_buffer[2] && rsi_buffer[1] < rsi_low_value && close[1] > corresponding_low_value)
        {
         new_rsi_low_value = rsi_buffer[1];
         new_rsi_low_time = time[1];
         new_corresponding_low_value = close[1];

        }

      //GETTING THE NUMBER OF BARS FROM THE NEW LOW AND SETTING CONDITIONS FOR GOING LONG
      int  total_bars = Bars(_Symbol,PERIOD_CURRENT,new_rsi_low_time,TimeCurrent());

      if(total_bars < 11)
        {
         //CONDITION FOR HIDDEN BULLISH DIVERGENCE
         if(rsi_low_value > new_rsi_low_value && corresponding_low_value < new_corresponding_low_value)
           {
            //FOR RSI
            ObjectCreate(ChartID(),"RSI LOW TREND LINE",OBJ_TREND,1,rsi_low_time,rsi_low_value,new_rsi_low_time,new_rsi_low_value);
            ObjectCreate(ChartID(),"L",OBJ_TEXT,1,rsi_low_time,rsi_low_value);
            ObjectSetString(ChartID(),"L",OBJPROP_TEXT,"L");
            ObjectSetInteger(ChartID(),"L",OBJPROP_FONTSIZE,15);
            ObjectSetInteger(ChartID(),"RSI LOW TREND LINE",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(ChartID(),"L",OBJPROP_COLOR,clrRed);
            ObjectCreate(ChartID(),"LL",OBJ_TEXT,1,new_rsi_low_time,new_rsi_low_value);
            ObjectSetString(ChartID(),"LL",OBJPROP_TEXT,"LL");
            ObjectSetInteger(ChartID(),"LL",OBJPROP_FONTSIZE,15);
            ObjectSetInteger(ChartID(),"LL",OBJPROP_COLOR,clrRed);


            //FOR CORRESPONDING PRICE
            ObjectCreate(ChartID(),"C-CANDLE TREND LINE",OBJ_TREND,0,rsi_low_time,corresponding_low_value,new_rsi_low_time,new_corresponding_low_value);
            ObjectCreate(ChartID(),"CL",OBJ_TEXT,0,rsi_low_time,corresponding_low_value);
            ObjectSetString(ChartID(),"CL",OBJPROP_TEXT,"L");
            ObjectSetInteger(ChartID(),"CL",OBJPROP_FONTSIZE,15);
            ObjectSetInteger(ChartID(),"C-CANDLE TREND LINE",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(ChartID(),"CL",OBJPROP_COLOR,clrRed);
            ObjectCreate(ChartID(),"CLL",OBJ_TEXT,0,new_rsi_low_time,new_corresponding_low_value);
            ObjectSetString(ChartID(),"CLL",OBJPROP_TEXT,"HL");
            ObjectSetInteger(ChartID(),"CLL",OBJPROP_FONTSIZE,15);
            ObjectSetInteger(ChartID(),"CLL",OBJPROP_COLOR,clrRed);

            if(stoch_buffer_k[0] > 20 && stoch_buffer_k[1] < 20 && currentBarTime != lastTradeBarTime && totalPositions < 1)
              {
               take_profit  = ((ask_price - last_low) * rrr) + ask_price;
               points_risk = ask_price - low[0];
               lot_size = CalculateLotSize(_Symbol, risk_amount, points_risk);

               trade.Buy(lot_size,_Symbol,ask_price,last_low,take_profit);
               lastTradeBarTime = currentBarTime;

              }

           }

        }
     }

//LOGIC TO DELETE THE OBJECTS WHEN ITS NO LONGER RELEVEANT
   else
      if((close[0] < ma_buffer[0]) || (close[minimum_value_low] < corresponding_low_value))
        {

         ObjectDelete(ChartID(),"RSI LOW VALUE");
         ObjectDelete(ChartID(),"C-CANDLE");
         ObjectDelete(ChartID(),"C-CANDLE LINE");
         ObjectDelete(ChartID(),"RSI LOW LINE");
         ObjectDelete(ChartID(),"C-CANDLE TEXT");
         ObjectDelete(ChartID(),"RSI LOW TEXT");
         ObjectDelete(ChartID(),"RSI LOW TREND LINE");
         ObjectDelete(ChartID(),"L");
         ObjectDelete(ChartID(),"LL");
         ObjectDelete(ChartID(),"C-CANDLE TREND LINE");
         ObjectDelete(ChartID(),"CL");
         ObjectDelete(ChartID(),"RSI LOW TEXT");
         ObjectDelete(ChartID(),"CLL");

        }









//LOOP THROUGH THE LAST 30 BARS ON THE CHART
   for(int i = 0; i < 30; i++)
     {
      //PREVENT ARRAY OUT OF RANGE ERROR
      if((i+1 < 30) && (i+2 < 30) && (i < 30) && (i+3 < 30) && (i+4 < 30))
        {
         //LOGIC TO IDENTIFY THE LATEST RSI HIGH
         if(rsi_buffer[i+4] < rsi_buffer[i+3] && rsi_buffer[i+2] < rsi_buffer[i+3] && rsi_buffer[i+1] < rsi_buffer[i+2] && rsi_buffer[i] < rsi_buffer[i+1])
           {
            //GETTING LATEST RSI HIGH, CORRESPONDING PRICE, CORRESPONDING MA VALUE, and RSI TIME
            rsi_high_value = rsi_buffer[i+3];
            corresponding_high_value = close[i+3];
            corresponding_high_ma = ma_buffer[i+3];
            rsi_high_time = time[i+3];

            break;
           }

        }
     }



//TOTAL NUMBERS OF BARS FROM THE LAST SIGNIFICANT RSI HIGH
   int total_bars_3 = 0;
   total_bars_3 = Bars(_Symbol,PERIOD_CURRENT,time[0],rsi_high_time);

//MAXIMUM CLOSE PRICE FROM THE LAST SIGNIFICANT RSI LOW
   maximum_value_high = ArrayMaximum(close,0,total_bars_3);


   if(corresponding_high_value < corresponding_high_ma && close[0] < ma_buffer[0] && close[maximum_value_high] <= corresponding_high_value)
     {
      //CREATE LINES TO MARK RSI AND CORRESPONDING PRICE
      ObjectCreate(ChartID(),"RSI HIGH VALUE",OBJ_TREND,1,rsi_high_time,rsi_high_value,TimeCurrent(),rsi_high_value);
      ObjectCreate(ChartID(),"C-CANDLE HIGH",OBJ_TREND,0,rsi_high_time,corresponding_high_value,TimeCurrent(),corresponding_high_value);
      //SETTING OBJECTS COLOUR
      ObjectSetInteger(ChartID(),"RSI HIGH VALUE",OBJPROP_COLOR,clrRed);
      ObjectSetInteger(ChartID(),"C-CANDLE HIGH",OBJPROP_COLOR,clrRed);

      //CREATE TWO LINES TO CONNECT RSI HIGH AND THE CORRESPONDING PRICE ON THE CHART
      ObjectCreate(ChartID(),"C-CANDLE LINE HIGH",OBJ_TREND,0,rsi_high_time,corresponding_high_value,rsi_high_time,0);
      ObjectCreate(ChartID(),"RSI HIGH LINE",OBJ_TREND,1,rsi_high_time,rsi_high_value,rsi_high_time,100);
      //SETTING OBJECTS COLOUR
      ObjectSetInteger(ChartID(),"C-CANDLE LINE HIGH",OBJPROP_COLOR,clrRed);
      ObjectSetInteger(ChartID(),"RSI HIGH LINE",OBJPROP_COLOR,clrRed);

      //CREATE TEXTS TO MART RSI HIGH AND CORRESPONDING PRICE (C-PRICE)
      ObjectCreate(ChartID(),"C-CANDLE TEXT HIGH",OBJ_TEXT,0,TimeCurrent(),corresponding_high_value);
      ObjectSetString(ChartID(),"C-CANDLE TEXT HIGH",OBJPROP_TEXT,"C-PRICE");
      ObjectCreate(ChartID(),"RSI HIGH TEXT",OBJ_TEXT,1,TimeCurrent(),rsi_high_value);
      ObjectSetString(ChartID(),"RSI HIGH TEXT",OBJPROP_TEXT,"RSI HIGH");

      //SETTING TEXT COLOUR
      ObjectSetInteger(ChartID(),"C-CANDLE TEXT HIGH",OBJPROP_COLOR,clrRed);
      ObjectSetInteger(ChartID(),"RSI HIGH TEXT",OBJPROP_COLOR,clrRed);






      //21. LOGIC TO GET THE NEW RSI HIGH
      if(rsi_buffer[0] < rsi_buffer[1] && rsi_buffer[1] > rsi_buffer[2] && rsi_buffer[1] > rsi_high_value && close[1] < corresponding_high_value)
        {

         new_rsi_high_value = rsi_buffer[1];
         new_rsi_high_time = time[1];
         new_corresponding_high_value = close[1];

        }

      //24. GETTING THE NUMBER OF BARS FROM THE NEW HIGH AND SETTING CONDITIONS FOR GOING SHORT
      int total_bars = Bars(_Symbol,PERIOD_CURRENT,new_rsi_high_time,TimeCurrent());


      if(total_bars < 11)
        {

         if(rsi_high_value < new_rsi_high_value && corresponding_high_value > new_corresponding_high_value)
           {
            //for rsi
            ObjectCreate(ChartID(),"RSI HIGH TREND LINE",OBJ_TREND,1,rsi_high_time,rsi_high_value,new_rsi_high_time,new_rsi_high_value);
            ObjectCreate(ChartID(),"H",OBJ_TEXT,1,rsi_high_time,rsi_high_value);
            ObjectSetString(ChartID(),"H",OBJPROP_TEXT,"H");
            ObjectSetInteger(ChartID(),"H",OBJPROP_FONTSIZE,15);

            ObjectSetInteger(ChartID(),"RSI HIGH TREND LINE",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(ChartID(),"H",OBJPROP_COLOR,clrRed);



            ObjectCreate(ChartID(),"HH",OBJ_TEXT,1,new_rsi_high_time,new_rsi_high_value);
            ObjectSetString(ChartID(),"HH",OBJPROP_TEXT,"HH");
            ObjectSetInteger(ChartID(),"HH",OBJPROP_FONTSIZE,15);

            ObjectSetInteger(ChartID(),"HH",OBJPROP_COLOR,clrRed);


            //for candle
            ObjectCreate(ChartID(),"C-CANDLE TREND LINE HIGH",OBJ_TREND,0,rsi_high_time,corresponding_high_value,new_rsi_high_time,new_corresponding_high_value);
            ObjectCreate(ChartID(),"CH",OBJ_TEXT,0,rsi_high_time,corresponding_high_value);
            ObjectSetString(ChartID(),"CH",OBJPROP_TEXT,"H");
            ObjectSetInteger(ChartID(),"CH",OBJPROP_FONTSIZE,15);

            ObjectSetInteger(ChartID(),"C-CANDLE TREND LINE HIGH",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(ChartID(),"CH",OBJPROP_COLOR,clrRed);

            ObjectCreate(ChartID(),"CLH",OBJ_TEXT,0,new_rsi_high_time,new_corresponding_high_value);
            ObjectSetString(ChartID(),"CLH",OBJPROP_TEXT,"LH");
            ObjectSetInteger(ChartID(),"CLH",OBJPROP_FONTSIZE,15);

            ObjectSetInteger(ChartID(),"CLH",OBJPROP_COLOR,clrRed);

            if(stoch_buffer_k[0] < 80 && stoch_buffer_k[1] > 80 && currentBarTime != lastTradeBarTime && totalPositions < 1)
              {

               take_profit  = MathAbs(((last_high - ask_price) * rrr) - ask_price);
               points_risk = high[0] - ask_price;
               lot_size = CalculateLotSize(_Symbol, risk_amount, points_risk);

               trade.Sell(lot_size,_Symbol,ask_price,last_high,take_profit);
               lastTradeBarTime = currentBarTime;

              }
           }
        }

     }

//18. LOGIC TO DELETE THE OBJECTS WHEN ITS NO LONGER RELEVEANT
   else
      if((close[0] > ma_buffer[0]) || (close[maximum_value_high] > corresponding_high_value))
        {

         ObjectDelete(ChartID(),"RSI HIGH VALUE");
         ObjectDelete(ChartID(),"C-CANDLE HIGH");
         ObjectDelete(ChartID(),"C-CANDLE LINE HIGH");
         ObjectDelete(ChartID(),"RSI HIGH LINE");
         ObjectDelete(ChartID(),"C-CANDLE TEXT HIGH");
         ObjectDelete(ChartID(),"RSI HIGH TEXT");
         ObjectDelete(ChartID(),"RSI HIGH TREND LINE");
         ObjectDelete(ChartID(),"H");
         ObjectDelete(ChartID(),"HH");
         ObjectDelete(ChartID(),"C-CANDLE TREND LINE HIGH");
         ObjectDelete(ChartID(),"CH");
         ObjectDelete(ChartID(),"CLH");


        }


  }




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

   return lotSize;
  }
//+------------------------------------------------------------------+






















//+------------------------------------------------------------------+
