//+------------------------------------------------------------------+
//|                              Project 10 Head and Shoulder EA.mq5 |
//|                                             Abioye Israel Pelumi |
//|                             https://linktr.ee/abioyeisraelpelumi |
//+------------------------------------------------------------------+
#property copyright "Abioye Israel Pelumi"
#property link      "https://linktr.ee/abioyeisraelpelumi"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade trade;
int MagicNumber = 5122025;

input ENUM_TIMEFRAMES    timeframe = PERIOD_CURRENT; // MA Time Frame
input int bars_check  = 1000; // Number of bars to check for swing points
input bool show_sell = true; // Display sell signals
input bool show_buy = true; // Display buy signals
input color txt_clr = clrBlue; // Texts color
input color head_clr = clrCornflowerBlue; // Head color
input color shoulder_clr = clrLightSeaGreen; // Shoulder color
input color wz_clr = clrPaleGreen; // Winning zone color
input color lz_clr = clrDarkSalmon; // Losing zone color
input double lot_size = 0.6; //LotSize


// Variable to store how many bars are available on the chart for the selected timeframe
int rates_total;

double open[];   // Array for opening prices
double close[];  // Array for closing prices
double low[];    // Array for lowest prices
double high[];   // Array for highest prices
datetime time[]; // Array for time (timestamps) of each bar


//X
double X; // Price of the swing low (X).
datetime X_time; // Time of the swing low (X).
string X_letter; // Unique name for the text label object.

int x_a_bars;
int x_lowest_index;
double x_a_ll;
datetime x_a_ll_t;

int x_highest_index;
double x_a_hh;
datetime x_a_hh_t;


//A
double A; // Price of the swing high (A).
datetime A_time; // Time of the swing high (A).
string A_letter; // Unique name for the text label object.


int a_b_bars;
int a_highest_index;
double a_b_hh;
datetime a_b_hh_t;

string A_zone;
double A_low;

int a_lowest_index;
double a_b_ll;
datetime a_b_ll_t;

double A_high;


//B
double B; // Price of the swing low (B).
datetime B_time; // Time of the swing low (B).
string B_letter; // Unique name for the text label object.

int b_c_bars;
int b_lowest_index;
double b_c_ll;
datetime b_c_ll_t;

string B_zone;
double B_high;

int b_highest_index;
double b_c_hh;
datetime b_c_hh_t;
double B_low;


//C
double C; // Price of the swing low (B).
datetime C_time; // Time of the swing low (B).
string C_letter; // Unique name for the text label object.

int c_d_bars;
int c_highest_index;
double c_d_hh;
datetime c_d_hh_t;

int c_lowest_index;
double c_d_ll;
datetime c_d_ll_t;

//D
double D; // Price of the swing low (B).
datetime D_time; // Time of the swing low (B).
string D_letter; // Unique name for the text label object.

int d_e_bars;
int d_lowest_index;
double d_e_ll;
datetime d_e_ll_t;

double D_3bar_high;

int d_highest_index;
double d_e_hh;
datetime d_e_hh_t;
double D_3bar_low;



//E
double E; // Price of the swing low (B).
datetime E_time; // Time of the swing low (B).
string E_letter; // Unique name for the text label object.
double E_3bar_low;

double E_3bar_high;

string xa; // Unique name for the trendline for XA.
string ab; // Unique name for the trendline for AB.
string bc; // Unique name for the trendline for BC.
string cd; // Unique name for the trendline for CD.
string de; // Unique name for the trendline for DE.
string ex; // Unique name for the trendline for EX.



long chart_id = ChartID();

string X_A_B;
string B_C_D;
string D_E_X;

datetime xa_line_t;
datetime ex_line_t;

int n_bars;
int n_bars_2;

string sl_t;
string tp_t;

double sl_price;
double tp_price;

datetime lastTradeBarTime = 0;

double ask_price;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   trade.SetExpertMagicNumber(MagicNumber);


//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(chart_id);

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

// Get the total number of bars available on the selected symbol and timeframe
   rates_total = Bars(_Symbol, timeframe);

// Copy the open prices of the last 'rates_total' bars into the 'open' array
   CopyOpen(_Symbol, timeframe, 0, rates_total, open);

// Copy the close prices of the last 'rates_total' bars into the 'close' array
   CopyClose(_Symbol, timeframe, 0, rates_total, close);

// Copy the low prices of the last 'rates_total' bars into the 'low' array
   CopyLow(_Symbol, timeframe, 0, rates_total, low);

// Copy the high prices of the last 'rates_total' bars into the 'high' array
   CopyHigh(_Symbol, timeframe, 0, rates_total, high);

// Copy the time (timestamps) of the last 'rates_total' bars into the 'time' array
   CopyTime(_Symbol, timeframe, 0, rates_total, time);

   ask_price = ask_price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   datetime currentBarTime = iTime(_Symbol, timeframe, 0);


//FOR SELL
   if(show_sell)
     {
      if(rates_total >= bars_check)
        {

         for(int z = 7; z <= 10; z++)
           {

            for(int i = rates_total - bars_check; i < rates_total - z; i++)
              {

               if(IsSwingLow(low, i, z))
                 {

                  // If a swing low is found, store its price, time, and create a name for the objects to mark the X.
                  X = low[i]; // Price of the swing low (X).
                  X_time = time[i]; // Time of the swing low (X).
                  X_letter = StringFormat("X%d", i); // Unique name for the text label object.


                  for(int j = i; j < rates_total - z; j++)
                    {
                     if(IsSwingHigh(high, j, z) && time[j] > X_time)
                       {

                        A = high[j]; // Price of the swing high (A).
                        A_time = time[j]; // Time of the swing high (A)
                        A_letter = StringFormat("A%d", j); // Unique name for the text label object


                        for(int k = j; k < rates_total - z; k++)
                          {
                           if(IsSwingLow(low, k, z) && time[k] > A_time)
                             {

                              B = low[k]; // Price of the swing low (B).
                              B_time = time[k]; // Time of the swing low (B).
                              B_letter = StringFormat("B%d", k); // Unique name for the text label object.


                              for(int l = k ; l < rates_total - z; l++)
                                {

                                 if(IsSwingHigh(high, l, z) && time[l] > B_time)
                                   {

                                    C = high[l]; // Price of the swing high (C).
                                    C_time = time[l]; // Time of the swing high (C).
                                    C_letter = StringFormat("C%d", l); // Unique name for the text label object.

                                    for(int m = l; m < rates_total - z; m++)
                                      {

                                       if(IsSwingLow(low, m, z) && time[m] > C_time)
                                         {

                                          D = low[m]; // Price of the swing low (D).
                                          D_time = time[m]; // Time of the swing low (D).
                                          D_letter = StringFormat("D%d", m); // Unique name for the text label object.

                                          for(int n = m ; n < rates_total - (z/2) - 1; n++)
                                            {

                                             if(IsSwingHigh(high, n, (z/2)) && time[n] > D_time)
                                               {

                                                E = high[n]; // Price of the swing high (E).
                                                E_time = time[n]; // Time of the swing high (E).
                                                E_letter = StringFormat("E%d", n); // Unique name for the text label object.


                                                d_e_bars = Bars(_Symbol, PERIOD_CURRENT, D_time, E_time); // Count the number of bars between D and E
                                                d_lowest_index = ArrayMinimum(low, m, d_e_bars); // Find the index of the lowest low in the range
                                                d_e_ll = low[d_lowest_index]; // Store the lowest low (D - E lowest point)
                                                d_e_ll_t = time[d_lowest_index]; // Store the corresponding time
                                                D_3bar_high = high[d_lowest_index - 3]; // The high price of the third bar before the bar that formed D

                                                c_d_bars = Bars(_Symbol,PERIOD_CURRENT,C_time,d_e_ll_t); // Count the number of bars between C and V
                                                c_highest_index = ArrayMaximum(high,l,c_d_bars); // Find the index of the highest high in the range
                                                c_d_hh = high[c_highest_index];  // Store the lowest high (C - D lowest point)
                                                c_d_hh_t = time[c_highest_index]; // Store the corresponding time

                                                b_c_bars = Bars(_Symbol, PERIOD_CURRENT, B_time, c_d_hh_t); // Count the number of bars between B and C
                                                b_lowest_index = ArrayMinimum(low, k, b_c_bars); // Find the index of the lowest low in the range
                                                b_c_ll = low[b_lowest_index]; // Store the lowest low B - C lowest point)
                                                b_c_ll_t = time[b_lowest_index]; // Store the corresponding time
                                                B_high = high[b_lowest_index];  // The high price of the bar that formed swing low D


                                                a_b_bars = Bars(_Symbol,PERIOD_CURRENT,A_time,b_c_ll_t); // Count the number of bars between A and B
                                                a_highest_index = ArrayMaximum(high,j,a_b_bars); // Find the index of the highest high in the range
                                                a_b_hh = high[a_highest_index]; // Store the lowest low A - B lowest point)
                                                a_b_hh_t = time[a_highest_index];  // Store the corresponding time
                                                A_low = low[a_highest_index];

                                                x_a_bars = Bars(_Symbol, PERIOD_CURRENT, X_time, a_b_hh_t); // Count the number of bars between C and D
                                                x_lowest_index = ArrayMinimum(low, i, x_a_bars); // Find the index of the lowest low in the range
                                                x_a_ll = low[x_lowest_index]; // Store the lowest low (C - D lowest point)
                                                x_a_ll_t = time[x_lowest_index]; // Store the corresponding time for C - D

                                                E_3bar_low = low[n - 3]; // The LOW price of the third bar before the bar that formed E


                                                if(a_b_hh > x_a_ll && b_c_ll < a_b_hh && b_c_ll > x_a_ll && c_d_hh > a_b_hh && E < c_d_hh && d_e_ll > x_a_ll
                                                   && d_e_ll <= B_high && D_3bar_high >= B_high && E > A_low && E_3bar_low < a_b_hh)
                                                  {

                                                   ObjectCreate(chart_id,X_letter,OBJ_TEXT,0,X_time,X);
                                                   ObjectSetString(chart_id,X_letter,OBJPROP_TEXT,"X");
                                                   ObjectSetInteger(chart_id,X_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,A_letter,OBJ_TEXT,0,A_time,A);
                                                   ObjectSetString(chart_id,A_letter,OBJPROP_TEXT,"A");
                                                   ObjectSetInteger(chart_id,A_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,B_letter,OBJ_TEXT,0,B_time,B);
                                                   ObjectSetString(chart_id,B_letter,OBJPROP_TEXT,"B");
                                                   ObjectSetInteger(chart_id,B_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,C_letter,OBJ_TEXT,0,C_time,C);
                                                   ObjectSetString(chart_id,C_letter,OBJPROP_TEXT,"C");
                                                   ObjectSetInteger(chart_id,C_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,D_letter,OBJ_TEXT,0,D_time,D);
                                                   ObjectSetString(chart_id,D_letter,OBJPROP_TEXT,"D");
                                                   ObjectSetInteger(chart_id,D_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,E_letter,OBJ_TEXT,0,E_time,E);
                                                   ObjectSetString(chart_id,E_letter,OBJPROP_TEXT,"E");
                                                   ObjectSetInteger(chart_id,E_letter,OBJPROP_COLOR,txt_clr);

                                                   xa = StringFormat("XA line%d", i);
                                                   ab = StringFormat("AB line%d", i);
                                                   bc = StringFormat("BC line%d", i);
                                                   cd = StringFormat("CD line%d", i);
                                                   de = StringFormat("DE line%d", i);
                                                   ex = StringFormat("EX line%d", i);


                                                   ObjectCreate(chart_id,X_letter,OBJ_TEXT,0,x_a_ll_t,x_a_ll);
                                                   ObjectSetString(chart_id,X_letter,OBJPROP_TEXT,"X");
                                                   ObjectSetInteger(chart_id,X_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,A_letter,OBJ_TEXT,0,a_b_hh_t,a_b_hh);
                                                   ObjectSetString(chart_id,A_letter,OBJPROP_TEXT,"A");
                                                   ObjectSetInteger(chart_id,A_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,B_letter,OBJ_TEXT,0,b_c_ll_t,b_c_ll);
                                                   ObjectSetString(chart_id,B_letter,OBJPROP_TEXT,"B");
                                                   ObjectSetInteger(chart_id,B_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,C_letter,OBJ_TEXT,0,c_d_hh_t,c_d_hh);
                                                   ObjectSetString(chart_id,C_letter,OBJPROP_TEXT,"C");
                                                   ObjectSetInteger(chart_id,C_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,D_letter,OBJ_TEXT,0,d_e_ll_t,d_e_ll);
                                                   ObjectSetString(chart_id,D_letter,OBJPROP_TEXT,"D");
                                                   ObjectSetInteger(chart_id,D_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,E_letter,OBJ_TEXT,0,E_time,E);
                                                   ObjectSetString(chart_id,E_letter,OBJPROP_TEXT,"E");
                                                   ObjectSetInteger(chart_id,E_letter,OBJPROP_COLOR,txt_clr);


                                                   ObjectCreate(chart_id, xa,OBJ_TREND,0,x_a_ll_t,x_a_ll,a_b_hh_t,a_b_hh);
                                                   ObjectSetInteger(chart_id,xa,OBJPROP_WIDTH,3);
                                                   ObjectSetInteger(chart_id,xa,OBJPROP_COLOR,clrSaddleBrown);
                                                   ObjectSetInteger(chart_id, xa, OBJPROP_BACK, true);

                                                   ObjectCreate(chart_id, ab,OBJ_TREND,0,a_b_hh_t,a_b_hh,b_c_ll_t,b_c_ll);
                                                   ObjectSetInteger(chart_id,ab,OBJPROP_WIDTH,3);
                                                   ObjectSetInteger(chart_id,ab,OBJPROP_COLOR,clrSaddleBrown);
                                                   ObjectSetInteger(chart_id, ab, OBJPROP_BACK, true);

                                                   ObjectCreate(chart_id, bc,OBJ_TREND,0,b_c_ll_t,b_c_ll,c_d_hh_t,c_d_hh);
                                                   ObjectSetInteger(chart_id,bc,OBJPROP_WIDTH,3);
                                                   ObjectSetInteger(chart_id,bc,OBJPROP_COLOR,clrSaddleBrown);
                                                   ObjectSetInteger(chart_id, bc, OBJPROP_BACK, true);

                                                   ObjectCreate(chart_id, cd,OBJ_TREND,0,c_d_hh_t,c_d_hh,d_e_ll_t,d_e_ll);
                                                   ObjectSetInteger(chart_id,cd,OBJPROP_WIDTH,3);
                                                   ObjectSetInteger(chart_id,cd,OBJPROP_COLOR,clrSaddleBrown);
                                                   ObjectSetInteger(chart_id, cd, OBJPROP_BACK, true);

                                                   ObjectCreate(chart_id, de,OBJ_TREND,0,d_e_ll_t,d_e_ll,E_time,E);
                                                   ObjectSetInteger(chart_id,de,OBJPROP_WIDTH,3);
                                                   ObjectSetInteger(chart_id,de,OBJPROP_COLOR,clrSaddleBrown);
                                                   ObjectSetInteger(chart_id, de, OBJPROP_BACK, true);

                                                   ObjectCreate(chart_id, ex,OBJ_TREND,0,E_time,E,time[n+(z/2)],x_a_ll);
                                                   ObjectSetInteger(chart_id,ex,OBJPROP_WIDTH,3);
                                                   ObjectSetInteger(chart_id,ex,OBJPROP_COLOR,clrSaddleBrown);
                                                   ObjectSetInteger(chart_id, ex, OBJPROP_BACK, true);

                                                   A_zone = StringFormat("A ZONEe%d", i);
                                                   B_zone = StringFormat("B ZONEe%d", i);

                                                   ObjectCreate(chart_id,A_zone,OBJ_RECTANGLE,0,a_b_hh_t,a_b_hh,E_time,A_low);
                                                   ObjectCreate(chart_id,B_zone,OBJ_RECTANGLE,0,b_c_ll_t,b_c_ll,d_e_ll_t,B_high);

                                                   xa_line_t = ObjectGetTimeByValue(chart_id,xa,b_c_ll,0);
                                                   ex_line_t = ObjectGetTimeByValue(chart_id,ex,d_e_ll,0);

                                                   X_A_B = StringFormat("XAB %d", i);
                                                   ObjectCreate(chart_id,X_A_B,OBJ_TRIANGLE,0,xa_line_t,b_c_ll,a_b_hh_t,a_b_hh,b_c_ll_t,b_c_ll);
                                                   ObjectSetInteger(chart_id, X_A_B, OBJPROP_FILL, true);
                                                   ObjectSetInteger(chart_id, X_A_B, OBJPROP_BACK, true);
                                                   ObjectSetInteger(chart_id, X_A_B, OBJPROP_COLOR, shoulder_clr);

                                                   B_C_D = StringFormat("BCD %d", i);
                                                   ObjectCreate(chart_id, B_C_D, OBJ_TRIANGLE, 0, b_c_ll_t, b_c_ll, c_d_hh_t, c_d_hh, d_e_ll_t, d_e_ll);
                                                   ObjectSetInteger(chart_id, B_C_D, OBJPROP_COLOR, head_clr);
                                                   ObjectSetInteger(chart_id, B_C_D, OBJPROP_FILL, true);
                                                   ObjectSetInteger(chart_id, B_C_D, OBJPROP_BACK, true);

                                                   D_E_X = StringFormat("DEX %d", i);
                                                   ObjectCreate(chart_id, D_E_X, OBJ_TRIANGLE, 0, d_e_ll_t, d_e_ll, E_time, E, ex_line_t, d_e_ll);
                                                   ObjectSetInteger(chart_id, D_E_X, OBJPROP_COLOR, shoulder_clr);
                                                   ObjectSetInteger(chart_id, D_E_X, OBJPROP_FILL, true);
                                                   ObjectSetInteger(chart_id, D_E_X, OBJPROP_BACK, true);

                                                   for(int o = n; o < rates_total - 1; o++)
                                                     {

                                                      if(close[o] < d_e_ll && time[o] >= time[n+(z/2)])
                                                        {

                                                         n_bars = Bars(_Symbol,PERIOD_CURRENT,x_a_ll_t, E_time);
                                                         n_bars_2 = Bars(_Symbol,PERIOD_CURRENT,time[n+(z/2)], time[o]);
                                                         if(n_bars_2 <= n_bars)
                                                           {


                                                            double sl_zone = MathAbs(E - close[o]);
                                                            double tp_zone = MathAbs(close[o] - x_a_ll);



                                                            bool no_cross = false;

                                                            for(int p = n + (z/2); p < o; p++)
                                                              {

                                                               if(close[p] < d_e_ll)
                                                                 {

                                                                  no_cross = true;

                                                                  break;

                                                                 }

                                                              }

                                                            if(no_cross == false)
                                                              {
                                                               if(tp_zone >= sl_zone)
                                                                 {

                                                                  string loss_zone = StringFormat("Loss %d", i);
                                                                  ObjectCreate(chart_id,loss_zone,OBJ_RECTANGLE,0,E_time,E,time[o],close[o]);
                                                                  ObjectSetInteger(chart_id, loss_zone, OBJPROP_FILL, true);
                                                                  ObjectSetInteger(chart_id, loss_zone, OBJPROP_BACK, true);
                                                                  ObjectSetInteger(chart_id, loss_zone, OBJPROP_COLOR, lz_clr);



                                                                  string   sell_object = StringFormat("Sell Object%d", i);
                                                                  ObjectCreate(chart_id,sell_object,OBJ_ARROW_SELL,0,time[o],close[o]);

                                                                  string win_zone = StringFormat("Win %d", i);
                                                                  ObjectCreate(chart_id,win_zone,OBJ_RECTANGLE,0,E_time,close[o],time[o],x_a_ll);
                                                                  ObjectSetInteger(chart_id, win_zone, OBJPROP_FILL, true);
                                                                  ObjectSetInteger(chart_id, win_zone, OBJPROP_BACK, true);
                                                                  ObjectSetInteger(chart_id, win_zone, OBJPROP_COLOR, wz_clr);


                                                                  sl_price =  E;
                                                                  tp_price =  x_a_ll;

                                                                  string sl_d_s = DoubleToString(sl_price,_Digits);
                                                                  string tp_d_s = DoubleToString(tp_price,_Digits);

                                                                  sl_t = StringFormat("sl %d", i);
                                                                  tp_t = StringFormat("tp %d", i);

                                                                  ObjectCreate(chart_id,sl_t,OBJ_TEXT,0,time[o],sl_price);
                                                                  ObjectSetString(chart_id,sl_t,OBJPROP_TEXT,"SL - " + sl_d_s);
                                                                  ObjectSetInteger(chart_id,sl_t,OBJPROP_FONTSIZE,8);
                                                                  ObjectSetInteger(chart_id,sl_t,OBJPROP_COLOR,txt_clr);

                                                                  ObjectCreate(chart_id,tp_t,OBJ_TEXT,0,time[o],x_a_ll);
                                                                  ObjectSetString(chart_id,tp_t,OBJPROP_TEXT,"TP - " + tp_d_s);
                                                                  ObjectSetInteger(chart_id,tp_t,OBJPROP_FONTSIZE,8);
                                                                  ObjectSetInteger(chart_id,tp_t,OBJPROP_COLOR,txt_clr);

                                                                 }

                                                               if(tp_zone < sl_zone)
                                                                 {
                                                                  string loss_zone = StringFormat("Loss %d", i);
                                                                  ObjectCreate(chart_id,loss_zone,OBJ_RECTANGLE,0,E_time,E,time[o],close[o]);
                                                                  ObjectSetInteger(chart_id, loss_zone, OBJPROP_FILL, true);
                                                                  ObjectSetInteger(chart_id, loss_zone, OBJPROP_BACK, true);
                                                                  ObjectSetInteger(chart_id, loss_zone, OBJPROP_COLOR, lz_clr);

                                                                  string   sell_object = StringFormat("Sell Object%d", i);
                                                                  ObjectCreate(chart_id,sell_object,OBJ_ARROW_SELL,0,time[o],close[o]);

                                                                  double n_tp = MathAbs(close[o] - (sl_zone * 2));

                                                                  string win_zone = StringFormat("Win %d", i);
                                                                  ObjectCreate(chart_id,win_zone,OBJ_RECTANGLE,0,E_time,close[o],time[o],n_tp);
                                                                  ObjectSetInteger(chart_id, win_zone, OBJPROP_FILL, true);
                                                                  ObjectSetInteger(chart_id, win_zone, OBJPROP_BACK, true);
                                                                  ObjectSetInteger(chart_id, win_zone, OBJPROP_COLOR, wz_clr);

                                                                  sl_price =  E;
                                                                  tp_price =  n_tp;

                                                                  string sl_d_s = DoubleToString(sl_price,_Digits);
                                                                  string tp_d_s = DoubleToString(tp_price,_Digits);

                                                                  sl_t = StringFormat("sl %d", i);
                                                                  tp_t = StringFormat("tp %d", i);

                                                                  ObjectCreate(chart_id,sl_t,OBJ_TEXT,0,time[o],sl_price);;
                                                                  ObjectSetString(chart_id,sl_t,OBJPROP_TEXT,"SL - " + sl_d_s);
                                                                  ObjectSetInteger(chart_id,sl_t,OBJPROP_FONTSIZE,8);
                                                                  ObjectSetInteger(chart_id,sl_t,OBJPROP_COLOR,txt_clr);

                                                                  ObjectCreate(chart_id,tp_t,OBJ_TEXT,0,time[o],tp_price);
                                                                  ObjectSetString(chart_id,tp_t,OBJPROP_TEXT,"TP - " + tp_d_s);
                                                                  ObjectSetInteger(chart_id,tp_t,OBJPROP_FONTSIZE,8);
                                                                  ObjectSetInteger(chart_id,tp_t,OBJPROP_COLOR,txt_clr);


                                                                 }

                                                               if(time[o] == time[rates_total-2] && currentBarTime != lastTradeBarTime)
                                                                 {

                                                                  trade.Sell(lot_size,_Symbol,ask_price, sl_price,tp_price);
                                                                  lastTradeBarTime = currentBarTime;

                                                                 }

                                                              }



                                                           }

                                                         break;

                                                        }
                                                     }




                                                  }

                                                break;
                                               }
                                            }

                                          break;
                                         }
                                      }

                                    break;
                                   }
                                }

                              break;
                             }
                          }

                        break;
                       }
                    }
                 }
              }
           }

        }
     }



//FOR BUY
   if(show_buy)
     {

      if(rates_total >= bars_check)
        {
         for(int z = 7; z <= 10; z++)
           {

            for(int i = rates_total - bars_check; i < rates_total - z; i++)
              {

               if(IsSwingHigh(high, i, z))
                 {

                  X = high[i];
                  X_time = time[i];
                  X_letter = StringFormat("BX%d", i);

                  for(int j = i; j < rates_total - z; j++)
                    {
                     if(IsSwingLow(low, j, z) && time[j] > X_time)
                       {
                        A = low[j];
                        A_time = time[j];
                        A_letter = StringFormat("BA%d", j);
                        A_zone =  StringFormat("BAZone%d", j);
                        A_high = high[j];

                        for(int k = j; k < rates_total - z; k++)
                          {
                           if(IsSwingHigh(high, k, z) && time[k] > A_time)
                             {

                              B = high[k];
                              B_time = time[k];
                              B_letter = StringFormat("BB%d", k);
                              B_zone =  StringFormat("BBZone%d", k);

                              for(int l = k ; l < rates_total - z; l++)
                                {

                                 if(IsSwingLow(low, l, z) && time[l] > B_time)
                                   {

                                    C = low[l];
                                    C_time = time[l];
                                    C_letter = StringFormat("BC%d", l);

                                    for(int m = l; m < rates_total - z; m++)
                                      {

                                       if(IsSwingHigh(high, m, z) && time[m] > C_time)
                                         {

                                          D = high[m];
                                          D_time = time[m];
                                          D_letter = StringFormat("BD%d", m);

                                          for(int n = m ; n < rates_total - (z/2) - 1; n++)
                                            {

                                             if(IsSwingLow(low, n, (z/2)) && time[n] > D_time)
                                               {

                                                E = low[n];
                                                E_time = time[n];
                                                E_letter = StringFormat("BE%d", n);

                                                d_e_bars = Bars(_Symbol, PERIOD_CURRENT, D_time, E_time);
                                                d_highest_index = ArrayMaximum(high, m, d_e_bars);
                                                d_e_hh = high[d_highest_index];
                                                d_e_hh_t = time[d_highest_index];
                                                D_3bar_low = low[d_highest_index - 3];

                                                c_d_bars = Bars(_Symbol,PERIOD_CURRENT,C_time,d_e_hh_t);
                                                c_lowest_index = ArrayMinimum(low,l,c_d_bars);
                                                c_d_ll = low[c_lowest_index];
                                                c_d_ll_t = time[c_lowest_index];

                                                b_c_bars = Bars(_Symbol,PERIOD_CURRENT,B_time,c_d_ll_t);
                                                b_highest_index = ArrayMaximum(high, k, b_c_bars);
                                                b_c_hh = high[b_highest_index];
                                                b_c_hh_t = time[b_highest_index];
                                                B_low = low[b_highest_index];

                                                a_b_bars = Bars(_Symbol,PERIOD_CURRENT,A_time,b_c_hh_t);
                                                a_lowest_index = ArrayMinimum(low,j,a_b_bars);
                                                a_b_ll = low[a_lowest_index];
                                                a_b_ll_t = time[a_lowest_index];

                                                x_a_bars = Bars(_Symbol, PERIOD_CURRENT, X_time, a_b_ll_t);
                                                x_highest_index = ArrayMaximum(high, i, x_a_bars);
                                                x_a_hh = high[x_highest_index];
                                                x_a_hh_t = time[x_highest_index];


                                                E_3bar_high = high[n - 3];


                                                xa = StringFormat("BXA line%d", i);
                                                ab = StringFormat("BAB line%d", i);
                                                bc = StringFormat("BBC line%d", i);
                                                cd = StringFormat("BCD line%d", i);
                                                de = StringFormat("BDE line%d", i);
                                                ex = StringFormat("BEX line%d", i);

                                                if(a_b_ll < x_a_hh && b_c_hh > a_b_ll && b_c_hh < x_a_hh && c_d_ll < a_b_ll && E > c_d_ll && d_e_hh < x_a_hh
                                                   && d_e_hh >= B_low && D_3bar_low <= b_c_hh && E < A_high && E_3bar_high > a_b_ll)
                                                  {


                                                   ObjectCreate(chart_id,X_letter,OBJ_TEXT,0,x_a_hh_t,x_a_hh);
                                                   ObjectSetString(chart_id,X_letter,OBJPROP_TEXT,"X");
                                                   ObjectSetInteger(chart_id,X_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,A_letter,OBJ_TEXT,0,a_b_ll_t,a_b_ll);
                                                   ObjectSetString(chart_id,A_letter,OBJPROP_TEXT,"A");
                                                   ObjectSetInteger(chart_id,A_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,B_letter,OBJ_TEXT,0,b_c_hh_t,b_c_hh);
                                                   ObjectSetString(chart_id,B_letter,OBJPROP_TEXT,"B");
                                                   ObjectSetInteger(chart_id,B_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,C_letter,OBJ_TEXT,0,c_d_ll_t,c_d_ll);
                                                   ObjectSetString(chart_id,C_letter,OBJPROP_TEXT,"C");
                                                   ObjectSetInteger(chart_id,C_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,D_letter,OBJ_TEXT,0,d_e_hh_t,d_e_hh);
                                                   ObjectSetString(chart_id,D_letter,OBJPROP_TEXT,"D");
                                                   ObjectSetInteger(chart_id,D_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id,E_letter,OBJ_TEXT,0,E_time,E);
                                                   ObjectSetString(chart_id,E_letter,OBJPROP_TEXT,"E");
                                                   ObjectSetInteger(chart_id,E_letter,OBJPROP_COLOR,txt_clr);

                                                   ObjectCreate(chart_id, xa,OBJ_TREND,0,x_a_hh_t,x_a_hh,a_b_ll_t,a_b_ll);
                                                   ObjectSetInteger(chart_id,xa,OBJPROP_WIDTH,3);
                                                   ObjectSetInteger(chart_id,xa,OBJPROP_COLOR,clrSaddleBrown);
                                                   ObjectSetInteger(chart_id, xa, OBJPROP_BACK, true);

                                                   ObjectCreate(chart_id, ab,OBJ_TREND,0,a_b_ll_t,a_b_ll,b_c_hh_t,b_c_hh);
                                                   ObjectSetInteger(chart_id,ab,OBJPROP_WIDTH,3);
                                                   ObjectSetInteger(chart_id,ab,OBJPROP_COLOR,clrSaddleBrown);
                                                   ObjectSetInteger(chart_id, ab, OBJPROP_BACK, true);

                                                   ObjectCreate(chart_id, bc,OBJ_TREND,0,b_c_hh_t,b_c_hh,c_d_ll_t,c_d_ll);
                                                   ObjectSetInteger(chart_id,bc,OBJPROP_WIDTH,3);
                                                   ObjectSetInteger(chart_id,bc,OBJPROP_COLOR,clrSaddleBrown);
                                                   ObjectSetInteger(chart_id, bc, OBJPROP_BACK, true);

                                                   ObjectCreate(chart_id, cd,OBJ_TREND,0,c_d_ll_t,c_d_ll,d_e_hh_t,d_e_hh);
                                                   ObjectSetInteger(chart_id,cd,OBJPROP_WIDTH,3);
                                                   ObjectSetInteger(chart_id,cd,OBJPROP_COLOR,clrSaddleBrown);
                                                   ObjectSetInteger(chart_id, cd, OBJPROP_BACK, true);

                                                   ObjectCreate(chart_id, de,OBJ_TREND,0,d_e_hh_t,d_e_hh,E_time,E);
                                                   ObjectSetInteger(chart_id,de,OBJPROP_WIDTH,3);
                                                   ObjectSetInteger(chart_id,de,OBJPROP_COLOR,clrSaddleBrown);
                                                   ObjectSetInteger(chart_id, de, OBJPROP_BACK, true);

                                                   ObjectCreate(chart_id, ex,OBJ_TREND,0,E_time,E,time[n+(z/2)],x_a_hh);
                                                   ObjectSetInteger(chart_id,ex,OBJPROP_WIDTH,3);
                                                   ObjectSetInteger(chart_id,ex,OBJPROP_COLOR,clrSaddleBrown);
                                                   ObjectSetInteger(chart_id, ex, OBJPROP_BACK, true);

                                                   xa_line_t = ObjectGetTimeByValue(chart_id,xa,b_c_hh,0);
                                                   ex_line_t = ObjectGetTimeByValue(chart_id,ex,d_e_hh,0);

                                                   X_A_B = StringFormat("BXAB %d", i);
                                                   ObjectCreate(chart_id,X_A_B,OBJ_TRIANGLE,0,xa_line_t,b_c_hh,a_b_ll_t,a_b_ll,b_c_hh_t,b_c_hh);
                                                   ObjectSetInteger(chart_id, X_A_B, OBJPROP_FILL, true);
                                                   ObjectSetInteger(chart_id, X_A_B, OBJPROP_BACK, true);
                                                   ObjectSetInteger(chart_id, X_A_B, OBJPROP_COLOR, shoulder_clr);

                                                   B_C_D = StringFormat("BBCD %d", i);
                                                   ObjectCreate(chart_id, B_C_D, OBJ_TRIANGLE, 0, b_c_hh_t, b_c_hh, c_d_ll_t, c_d_ll, d_e_hh_t, d_e_hh);
                                                   ObjectSetInteger(chart_id, B_C_D, OBJPROP_COLOR, head_clr);
                                                   ObjectSetInteger(chart_id, B_C_D, OBJPROP_FILL, true);
                                                   ObjectSetInteger(chart_id, B_C_D, OBJPROP_BACK, true);

                                                   D_E_X = StringFormat("BDEX %d", i);
                                                   ObjectCreate(chart_id, D_E_X, OBJ_TRIANGLE, 0, d_e_hh_t, d_e_hh, E_time, E, ex_line_t, d_e_hh);
                                                   ObjectSetInteger(chart_id, D_E_X, OBJPROP_COLOR, shoulder_clr);
                                                   ObjectSetInteger(chart_id, D_E_X, OBJPROP_FILL, true);
                                                   ObjectSetInteger(chart_id, D_E_X, OBJPROP_BACK, true);

                                                   for(int o = n; o < rates_total - 1; o++)
                                                     {

                                                      if(close[o] > d_e_hh && time[o] >= time[n+(z/2)])
                                                        {

                                                         n_bars = Bars(_Symbol,PERIOD_CURRENT,x_a_hh_t, E_time);
                                                         n_bars_2 = Bars(_Symbol,PERIOD_CURRENT,time[n+(z/2)], time[o]);

                                                         if(n_bars_2 < n_bars)
                                                           {


                                                            double sl_zone = MathAbs(close[o] - E);
                                                            double tp_zone = MathAbs(x_a_hh - close[o]);

                                                            bool no_cross = false;

                                                            for(int p = n + (z/2); p < o; p++)
                                                              {

                                                               if(close[p] > d_e_hh)
                                                                 {

                                                                  no_cross = true;

                                                                  break;

                                                                 }

                                                              }


                                                            if(no_cross == false)
                                                              {

                                                               if(tp_zone >= sl_zone)
                                                                 {

                                                                  string loss_zone = StringFormat("BLoss %d", i);
                                                                  ObjectCreate(chart_id,loss_zone,OBJ_RECTANGLE,0,E_time,E,time[o],close[o]);
                                                                  ObjectSetInteger(chart_id, loss_zone, OBJPROP_FILL, true);
                                                                  ObjectSetInteger(chart_id, loss_zone, OBJPROP_BACK, true);
                                                                  ObjectSetInteger(chart_id, loss_zone, OBJPROP_COLOR, lz_clr);

                                                                  string   buy_object = StringFormat("Buy Object%d", i);
                                                                  ObjectCreate(chart_id,buy_object,OBJ_ARROW_BUY,0,time[o],close[o]);

                                                                  string win_zone = StringFormat("BWin %d", i);
                                                                  ObjectCreate(chart_id,win_zone,OBJ_RECTANGLE,0,E_time,close[o],time[o],x_a_hh);
                                                                  ObjectSetInteger(chart_id, win_zone, OBJPROP_FILL, true);
                                                                  ObjectSetInteger(chart_id, win_zone, OBJPROP_BACK, true);
                                                                  ObjectSetInteger(chart_id, win_zone, OBJPROP_COLOR, wz_clr);

                                                                  sl_price =  E;
                                                                  tp_price =  x_a_hh;

                                                                  string sl_d_s = DoubleToString(sl_price,_Digits);
                                                                  string tp_d_s = DoubleToString(tp_price,_Digits);

                                                                  sl_t = StringFormat("Bsl %d", i);
                                                                  tp_t = StringFormat("Btp %d", i);

                                                                  ObjectCreate(chart_id,sl_t,OBJ_TEXT,0,time[o],sl_price);
                                                                  ObjectSetString(chart_id,sl_t,OBJPROP_TEXT,"SL - " + sl_d_s);
                                                                  ObjectSetInteger(chart_id,sl_t,OBJPROP_FONTSIZE,8);
                                                                  ObjectSetInteger(chart_id,sl_t,OBJPROP_COLOR,txt_clr);

                                                                  ObjectCreate(chart_id,tp_t,OBJ_TEXT,0,time[o],x_a_hh);
                                                                  ObjectSetString(chart_id,tp_t,OBJPROP_TEXT,"TP - " + tp_d_s);
                                                                  ObjectSetInteger(chart_id,tp_t,OBJPROP_FONTSIZE,8);
                                                                  ObjectSetInteger(chart_id,tp_t,OBJPROP_COLOR,txt_clr);

                                                                 }
                                                                 
                                                                 
                                                                 if(tp_zone < sl_zone)
                                                                 {
                                                                  string loss_zone = StringFormat("BLoss %d", i);
                                                                  ObjectCreate(chart_id,loss_zone,OBJ_RECTANGLE,0,E_time,E,time[o],close[o]);
                                                                  ObjectSetInteger(chart_id, loss_zone, OBJPROP_FILL, true);
                                                                  ObjectSetInteger(chart_id, loss_zone, OBJPROP_BACK, true);
                                                                  ObjectSetInteger(chart_id, loss_zone, OBJPROP_COLOR, lz_clr);

                                                                  string   buy_object = StringFormat("Buy Object%d", i);
                                                                  ObjectCreate(chart_id,buy_object,OBJ_ARROW_BUY,0,time[o],close[o]);

                                                                  double n_tp = MathAbs(close[o] + (sl_zone * 2));

                                                                  string win_zone = StringFormat("BWin %d", i);
                                                                  ObjectCreate(chart_id,win_zone,OBJ_RECTANGLE,0,E_time,close[o],time[o],n_tp);
                                                                  ObjectSetInteger(chart_id, win_zone, OBJPROP_FILL, true);
                                                                  ObjectSetInteger(chart_id, win_zone, OBJPROP_BACK, true);
                                                                  ObjectSetInteger(chart_id, win_zone, OBJPROP_COLOR, wz_clr);

                                                                  sl_price =  E;
                                                                  tp_price =  n_tp;

                                                                  string sl_d_s = DoubleToString(sl_price,_Digits);
                                                                  string tp_d_s = DoubleToString(tp_price,_Digits);

                                                                  sl_t = StringFormat("Bsl %d", i);
                                                                  tp_t = StringFormat("Btp %d", i);

                                                                  ObjectCreate(chart_id,sl_t,OBJ_TEXT,0,time[o],sl_price);
                                                                  ObjectSetString(chart_id,sl_t,OBJPROP_TEXT,"SL - " + sl_d_s);
                                                                  ObjectSetInteger(chart_id,sl_t,OBJPROP_FONTSIZE,8);
                                                                  ObjectSetInteger(chart_id,sl_t,OBJPROP_COLOR,txt_clr);

                                                                  ObjectCreate(chart_id,tp_t,OBJ_TEXT,0,time[o],n_tp);
                                                                  ObjectSetString(chart_id,tp_t,OBJPROP_TEXT,"TP - " + tp_d_s);
                                                                  ObjectSetInteger(chart_id,tp_t,OBJPROP_FONTSIZE,8);
                                                                  ObjectSetInteger(chart_id,tp_t,OBJPROP_COLOR,txt_clr);


                                                                 }
                                                                 
                                                                 if(time[o] == time[rates_total-2] && currentBarTime != lastTradeBarTime )
                                                                 {

                                                                  trade.Buy(lot_size,_Symbol,ask_price, sl_price,tp_price);
                                                                  lastTradeBarTime = currentBarTime;

                                                                 }

                                                              }


                                                           }


                                                         break;

                                                        }

                                                     }


                                                  }
                                                break;

                                               }
                                            }

                                          break;

                                         }
                                      }

                                    break;
                                   }
                                }



                              break;
                             }

                          }

                        break;
                       }
                    }


                 }

              }


           }
        }
     }




  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| FUNCTION FOR SWING LOW                                           |
//+------------------------------------------------------------------+
bool IsSwingLow(const double &low_price[], int index, int lookback)
  {
   for(int i = 1; i <= lookback; i++)
     {
      if(low_price[index] > low_price[index - i] || low_price[index] > low_price[index + i])
         return false;
     }
   return true;
  }


//+------------------------------------------------------------------+
//| FUNCTION FOR SWING HIGH                                          |
//+------------------------------------------------------------------+
bool IsSwingHigh(const double &high_price[], int index, int lookback)
  {
   for(int i = 1; i <= lookback; i++)
     {
      if(high_price[index] < high_price[index - i] || high_price[index] < high_price[index + i])
         return false; // If the current high is not the highest, return false.
     }
   return true;
  }
//+------------------------------------------------------------------+
