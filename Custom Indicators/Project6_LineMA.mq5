//+------------------------------------------------------------------+
//|                          CUSTOM INDICATORS LINE MA PROJECT 6.mq5 |
//|                                                           Abioye |
//|                                             crownsoyin@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Abioye"
#property link      "crownsoyin@gmail.com"
#property version   "1.00"

//INDICATOR IN CHART WINDOW
#property indicator_chart_window

//SET INDICATOR BUFFER TO STORE DATA
#property indicator_buffers 3

//SET NUMBER FOR INDICATOR PLOTS
#property indicator_plots   3

//SETTING PLOTS PROPERTIES
//PROPERTIES OF THE FIRST MA (MA200)
#property indicator_label1  "MA 200"   //GIVE PLOT ONE A NAME
#property indicator_type1   DRAW_LINE  //TYPE OF PLOT THE FIRST MA 
#property indicator_style1  STYLE_DASHDOTDOT  //STYLE OF SPOT THE FIRST MA
#property indicator_width1  1         //LINE THICKNESS THE FIRST MA
#property indicator_color1  clrBlue    //LINE COLOR THE FIRST MA

//PROPERTIES OF THE SECOND MA (MA100)
#property indicator_label2  "MA 100"   //GIVE PLOT TWO A NAME
#property indicator_type2   DRAW_LINE  //TYPE OF PLOT THE SECOND MA
#property indicator_style2  STYLE_DASH  //STYLE OF SPOT THE SECOND MA
#property indicator_width2  1          //LINE THICKNESS THE SECOND MA
#property indicator_color2  clrBrown    //LINE COLOR THE SECOND MA

//PROPERTIES OF THE THIRD MA (MA50)
#property indicator_label3  "MA 50"    //GIVE PLOT TWO A NAME
#property indicator_type3   DRAW_LINE  //TYPE OF PLOT THE THIRD MA
#property indicator_style3  STYLE_DOT  //STYLE OF SPOT THE THIRD MA
#property indicator_width3  1          //LINE THICKNESS THE THIRD MA
#property indicator_color3  clrPurple    //LINE COLOR THE THIRD MA



//SET MA BUFFER TO STORE DATA
double buffer_mA200[];  //BUFFER FOR THE FIRST MA
double buffer_mA100[];  //BUFFER FOR THE SECOND MA
double buffer_mA50[];   //BUFFER FOR THE THIRD MA


//SET MA PERIOD
input int period_ma200 = 200;  //PERIOD FOR THE FIRST MA
input int period_ma100 = 100;  //PERIOD FOR THE SECOND MA
input int period_ma50  = 50;   //PERIOD FOR THE THIRD MA


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {


//SETTING BUFFER
   SetIndexBuffer(0, buffer_mA200, INDICATOR_DATA);  //INDEX 0 FOR MA200
   SetIndexBuffer(1, buffer_mA100, INDICATOR_DATA);  //INDEX 1 FOR MA100
   SetIndexBuffer(2, buffer_mA50, INDICATOR_DATA);   //INDEX 1 FOR MA50

//SETTING BARS TO START PLOTTING
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, period_ma200);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, period_ma100);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, period_ma50);



//---
   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {


//CALCULATE THE MOVING AVERAGE FOR THE THE First MA (MA200)
   for(int i = period_ma200 - 1; i < rates_total; i++)
     {

      double sum = 0.0;
      for(int j = 0; j < period_ma200; j++)
        {
         sum += high[i - j];
        }

      buffer_mA200[i] = sum / period_ma200;


     }


//CALCULATE THE MOVING AVERAGE FOR THE THE SECOND MA (MA100)
   for(int i = period_ma100 - 1; i < rates_total; i++)
     {

      double sum = 0.0;
      for(int j = 0; j < period_ma100; j++)
        {
         sum += close[i - j];
        }
      buffer_mA100[i] = sum / period_ma100;

     }



//CALCULATE THE MOVING AVERAGE FOR THE THE THIRD MA (MA50)
   for(int i = period_ma50 - 1; i < rates_total; i++)
     {
      double sum = 0.0;
      for(int j = 0; j < period_ma50; j++)
        {
         sum += open[i - j];
        }
      buffer_mA50[i] = sum / period_ma50;
     }




//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
