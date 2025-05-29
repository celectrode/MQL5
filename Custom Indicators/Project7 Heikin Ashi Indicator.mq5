//+------------------------------------------------------------------+
//|                                         Project7 Heikin Ashi.mq5 |
//|                                             ABIOYE ISRAEL PELUMI |
//|                                             crownsoyin@gmail.com |
//+------------------------------------------------------------------+
#property copyright "ABIOYE ISRAEL PELUMI"
#property link      "crownsoyin@gmail.com"
#property version   "1.00"



// PROPERTY SETTINGS
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2

// PLOT SETTINGS FOR HEIKIN ASHI CANDLES
#property indicator_label1  "Heikin Ashi"
#property indicator_type1   DRAW_COLOR_CANDLES  
#property indicator_color1  clrGreen, clrRed    
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//PROPERTIES OF THE Heikin MA
#property indicator_label2  "Heikin MA"   
#property indicator_type2   DRAW_LINE  
#property indicator_style2  STYLE_DASH 
#property indicator_width2  1          
#property indicator_color2  clrBrown   



// INDICATOR BUFFERS
double HA_Open[];
double HA_High[];
double HA_Low[];
double HA_Close[];
double ColorBuffer[]; 

double Heikin_MA_Buffer[];

int input  heikin_ma_period = 20;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // SET BUFFERS
    SetIndexBuffer(0, HA_Open, INDICATOR_DATA);
    SetIndexBuffer(1, HA_High, INDICATOR_DATA);
    SetIndexBuffer(2, HA_Low, INDICATOR_DATA);
    SetIndexBuffer(3, HA_Close, INDICATOR_DATA);
    SetIndexBuffer(4, ColorBuffer, INDICATOR_COLOR_INDEX);
    
    SetIndexBuffer(5, Heikin_MA_Buffer, INDICATOR_DATA);
    
    PlotIndexSetInteger(5, PLOT_DRAW_BEGIN, heikin_ma_period);
     

    return INIT_SUCCEEDED;
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
    if (rates_total < 2) return 0; // ENSURE ENOUGH DATA
    
  
    for (int i = 1; i < rates_total; i++) // START FROM SECOND BAR
    {
        // HEIKIN ASHI CLOSE FORMULA
        HA_Close[i] = (open[i] + high[i] + low[i] + close[i]) / 4.0;

        // HEIKIN ASHI OPEN FORMULA
        HA_Open[i] = (HA_Open[i - 1] + HA_Close[i - 1]) / 2.0;

        // HEIKIN ASHI HIGH FORMULA
        HA_High[i] = MathMax(high[i], MathMax(HA_Open[i], HA_Close[i]));

        // HEIKIN ASHI LOW FORMULA
        HA_Low[i] = MathMin(low[i], MathMin(HA_Open[i], HA_Close[i]));

        // SET COLOR: GREEN FOR BULLISH, RED FOR BEARISH
        ColorBuffer[i] = (HA_Close[i] >= HA_Open[i]) ? 0 : 1;
    }
    
    
    
    
     for(int i = heikin_ma_period - 1; i < rates_total; i++)
     {

      double sum = 0.0;
      for(int j = 0; j < heikin_ma_period; j++)
        {
         sum += HA_Close[i - j];
        }

      Heikin_MA_Buffer[i] = sum / heikin_ma_period;


     }
     
     

    return rates_total;
    
}


