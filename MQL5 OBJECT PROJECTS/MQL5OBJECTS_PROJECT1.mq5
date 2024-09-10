//+------------------------------------------------------------------+
//|                                                  MQL5OBJECTS.mq5 |
//|                                                         ForexYMN |
//|                                             crownsoyin@gmail.com |
//+------------------------------------------------------------------+
#property copyright "ForexYMN"
#property link      "crownsoyin@gmail.com"
#property version   "1.00"

// Variables to store position details
double open_price;          // Variable to store the entry price of the position
double stop_loss;           // Variable to store the Stop Loss level of the position
double take_profit;         // Variable to store the Take Profit level of the position
datetime position_open_time; // Variable to store the open time of the position


// Define the position index for the first position
input int position_index  = 0; // POSITION INDEX (Index starts from 0)

// Get the ID of the current chart
long chart_id = ChartID();  // Store the ID of the current chart

string time = "23:59";      // Define a specific time as a string

// Define the color for the losing zone
input color sl_zonez_color   = clrPink; // Choose a color for Losing Zone

// Define the color for the winning zone
input color tp_zonez_color   = clrSpringGreen; // Choose a color for Winning Zone

// Define the color for the trend line
input color line_zonez_color = clrYellow; // Choose a color for the line

// Define whether to show past history or not
input string show_history = "no"; // Type yes to show past history

// Define the start date to show history
input datetime date1 = D'1970.08.10 00:00:00'; // Show history from this date

// Define the end date to show history
input datetime date2 = D'2024.08.15 00:00:00'; // To this date
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Return the initialization status
    return(INIT_SUCCEEDED);
 
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
 // Delete all objects from the chart
    ObjectsDeleteAll(chart_id);
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

// Get the current ask price
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

// Convert the string time to datetime
   datetime close_zone = StringToTime(time);

// Loop through all open positions
   for(int i = 0; i < PositionsTotal(); i++)
     {
      // Get the ticket number of the position at index 'i'
      ulong ticket = PositionGetTicket(i);

      // Check if the position matches the specified index and symbol of the current chart
      if(PositionGetInteger(POSITION_TICKET) == PositionGetTicket(position_index) && PositionGetString(POSITION_SYMBOL) == ChartSymbol(chart_id))
        {

         // Retrieve and store the entry price of the position
         open_price = PositionGetDouble(POSITION_PRICE_OPEN);

         // Retrieve and store the Stop Loss level of the position
         stop_loss = PositionGetDouble(POSITION_SL);

         // Retrieve and store the Take Profit level of the position
         take_profit = PositionGetDouble(POSITION_TP);

         // Retrieve and store the open time of the position
         position_open_time = (int)PositionGetInteger(POSITION_TIME);



         if(stop_loss > 0)
           {
            // Create a rectangle to represent the Stop Loss (SL) zone on the chart
            ObjectCreate(chart_id, "SL Zone", OBJ_RECTANGLE, 0, position_open_time, open_price, close_zone, stop_loss);
           }

         if(take_profit > 0)
           {
            // Create a rectangle to represent the Take Profit (TP) zone on the chart
            ObjectCreate(chart_id, "TP zone", OBJ_RECTANGLE, 0, position_open_time, open_price, close_zone, take_profit);
           }

         // Set properties for the SL zone rectangle
         ObjectSetInteger(chart_id, "SL Zone", OBJPROP_COLOR, sl_zonez_color); // Set color to the selected SL zone color
         ObjectSetInteger(chart_id, "SL Zone", OBJPROP_STYLE, STYLE_SOLID);    // Set style to solid
         ObjectSetInteger(chart_id, "SL Zone", OBJPROP_WIDTH, 1);              // Set the width of the rectangle border
         ObjectSetInteger(chart_id, "SL Zone", OBJPROP_FILL, sl_zonez_color);  // Fill the rectangle with the selected SL zone color
         ObjectSetInteger(chart_id, "SL Zone", OBJPROP_BACK, true);            // Set the rectangle to appear behind the chart objects

         // Set properties for the TP zone rectangle
         ObjectSetInteger(chart_id, "TP zone", OBJPROP_COLOR, tp_zonez_color); // Set color to the selected TP zone color
         ObjectSetInteger(chart_id, "TP zone", OBJPROP_STYLE, STYLE_SOLID);    // Set style to solid
         ObjectSetInteger(chart_id, "TP zone", OBJPROP_WIDTH, 1);              // Set the width of the rectangle border
         ObjectSetInteger(chart_id, "TP zone", OBJPROP_FILL, tp_zonez_color);  // Fill the rectangle with the selected TP zone color
         ObjectSetInteger(chart_id, "TP zone", OBJPROP_BACK, true);            // Set the rectangle to appear behind the chart objects

         // Create a trend line object on the chart from the position's open time and price to the current time and ask price
         ObjectCreate(chart_id, "Trend Line", OBJ_TREND, 0, position_open_time, open_price, TimeCurrent(), ask);

         // Set Trend Line properties
         ObjectSetInteger(chart_id, "Trend Line", OBJPROP_COLOR, line_zonez_color);
         ObjectSetInteger(chart_id, "Trend Line", OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(chart_id, "Trend Line", OBJPROP_WIDTH, 2);



         // Calculate the profit of the current position
         double profit = PositionGetDouble(POSITION_PROFIT);

         // Variables to store the formatted profit text
         string curent_profits;
         string profit_to_string;

         // Check if the profit is positive or zero
         if(profit >= 0)
           {
            // Convert the profit to a string with 2 decimal places
            profit_to_string = DoubleToString(profit, 2);
            // Format the profit as a positive amount with a '+' sign
            curent_profits = StringFormat("+$%s", profit_to_string);
           }
         // Check if the profit is negative
         else
            if(profit < 0)
              {
               // Convert the negative profit to a positive number
               double profit_to_positive = MathAbs(profit);
               // Convert the positive profit to a string with 2 decimal places
               profit_to_string = DoubleToString(profit_to_positive, 2);
               // Format the profit as a negative amount with a '-' sign
               curent_profits = StringFormat("-$%s", profit_to_string);
              }

         // Create a text label on the chart to display the current profit
         string text_object_name = "Profit";
         ObjectCreate(chart_id, text_object_name, OBJ_TEXT, 0, TimeCurrent(), ask);
         ObjectSetString(chart_id, text_object_name, OBJPROP_TEXT, curent_profits);

         // Set the color of the profit text based on whether the profit is positive or negative
         if(profit > 0)
           {
            ObjectSetInteger(chart_id, text_object_name, OBJPROP_COLOR, clrMediumBlue); // Positive profit in blue
           }
         else
            if(profit < 0)
              {
               ObjectSetInteger(chart_id, text_object_name, OBJPROP_COLOR, clrRed); // Negative profit in red
              }

         // Display the Take Profit (TP) level on the chart
         string tp_display = "TP";
         string t_display = StringFormat("Take Profit: %.5f", take_profit);
         ObjectCreate(chart_id, tp_display, OBJ_TEXT, 0, close_zone, take_profit);
         ObjectSetString(chart_id, tp_display, OBJPROP_TEXT, t_display);
         ObjectSetInteger(chart_id, tp_display, OBJPROP_COLOR, clrBlue); // TP text in blue
         ObjectSetInteger(chart_id, tp_display, OBJPROP_FONTSIZE, 8); // Set font size for TP

         // Display the Stop Loss (SL) level on the chart
         string sl_display = "SL";
         string s_display = StringFormat("Stop Loss: %.5f", stop_loss);
         ObjectCreate(chart_id, sl_display, OBJ_TEXT, 0, close_zone, stop_loss);
         ObjectSetString(chart_id, sl_display, OBJPROP_TEXT, s_display);
         ObjectSetInteger(chart_id, sl_display, OBJPROP_COLOR, clrRed); // SL text in red
         ObjectSetInteger(chart_id, sl_display, OBJPROP_FONTSIZE, 8); // Set font size for SL

         // Display the Entry Price on the chart
         string en_display = "Entry Price";
         string e_display = StringFormat("Entry Point: %.5f", open_price);
         ObjectCreate(chart_id, en_display, OBJ_TEXT, 0, close_zone, open_price);
         ObjectSetString(chart_id, en_display, OBJPROP_TEXT, e_display);
         ObjectSetInteger(chart_id, en_display, OBJPROP_COLOR, clrPaleVioletRed); // Entry Price text in pale violet red
         ObjectSetInteger(chart_id, en_display, OBJPROP_FONTSIZE, 8); // Set font size for Entry Price


        }
     }
     
      
     // Check if history display is enabled
    if (show_history == "yes")
    {
      Comment(""); // Clear previous comments

      // Select deal history within the specified date range
      bool deal_history = HistorySelect(date1, date2);

      // Variables to store deal details
      double deal_close_price = 0.0;
      double deal_open_price = 0.0;
      double deal_sl = 0.0;
      double deal_tp = 0.0;
      double deal_profit = 0.0;
      datetime deal_close_time = 0;
      datetime deal_open_time = 0;

      // Check if deal history is available
      if (deal_history)
      {
        // Loop through all history deals
        for (int i = 0; i < HistoryDealsTotal(); i++)
        {
          ulong ticket = HistoryDealGetTicket(i);

          // Check for deal entry in
          if (HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_IN)
          {
            if (HistoryDealGetString(ticket, DEAL_SYMBOL) == ChartSymbol(chart_id))
            {
              deal_open_price = HistoryDealGetDouble(ticket, DEAL_PRICE);
              deal_open_time = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
            }
          }

          // Check for deal entry out
          if (HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
          {
            deal_profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
            deal_close_price = HistoryDealGetDouble(ticket, DEAL_PRICE);
            deal_sl = HistoryDealGetDouble(ticket, DEAL_SL);
            deal_tp = HistoryDealGetDouble(ticket, DEAL_TP);
            deal_close_time = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);

            if(HistoryDealGetString(ticket, DEAL_SYMBOL) == ChartSymbol(chart_id))
            {
              string deal_string;
              string current_deal_profit;
              string object_name;

              // Display deal profit/loss
              if (deal_profit > 0)
              {
                deal_string = DoubleToString(deal_profit, 2);
                current_deal_profit = StringFormat("YOU WON +$%s", deal_string);
                object_name = StringFormat("PROFIT %d", i);
                ObjectCreate(chart_id, object_name, OBJ_TEXT, 0, deal_close_time, deal_close_price);
                ObjectSetString(chart_id, object_name, OBJPROP_TEXT, current_deal_profit);
                ObjectSetInteger(chart_id, object_name, OBJPROP_COLOR, clrMediumBlue);
                ObjectSetInteger(chart_id, object_name, OBJPROP_FONTSIZE,8);
              }
              else if (deal_profit < 0)
              {
                double deal_to_positive = MathAbs(deal_profit);
                deal_string = DoubleToString(deal_to_positive, 2);
                object_name = StringFormat("PROFIT %d", i);
                current_deal_profit = StringFormat("YOU LOST -$%s", deal_string);
                ObjectCreate(chart_id, object_name, OBJ_TEXT, 0, deal_close_time, deal_close_price);
                ObjectSetString(chart_id, object_name, OBJPROP_TEXT, current_deal_profit);
                ObjectSetInteger(chart_id, object_name, OBJPROP_COLOR, clrRed);
                ObjectSetInteger(chart_id, object_name, OBJPROP_FONTSIZE,8);              
              }

              // Display deal SL zone
              string sl_obj_name = StringFormat("SL ZONE %d", i);
              if (deal_sl > 0)
              {
                ObjectCreate(chart_id, sl_obj_name, OBJ_RECTANGLE, 0, deal_open_time, deal_open_price, deal_close_time, deal_sl);
              }
              ObjectSetInteger(chart_id, sl_obj_name, OBJPROP_COLOR, sl_zonez_color);
              ObjectSetInteger(chart_id, sl_obj_name, OBJPROP_STYLE, STYLE_SOLID);
              ObjectSetInteger(chart_id, sl_obj_name, OBJPROP_WIDTH, 1);
              ObjectSetInteger(chart_id, sl_obj_name, OBJPROP_FILL, sl_zonez_color);
              ObjectSetInteger(chart_id, sl_obj_name, OBJPROP_BACK, true);

              // Display deal TP zone
              string tp_obj_name = StringFormat("TP ZONE %d", i);
              if (deal_tp > 0)
              {
                ObjectCreate(chart_id, tp_obj_name, OBJ_RECTANGLE, 0, deal_open_time, deal_open_price, deal_close_time, deal_tp);
              }
              ObjectSetInteger(chart_id, tp_obj_name, OBJPROP_COLOR, tp_zonez_color);
              ObjectSetInteger(chart_id, tp_obj_name, OBJPROP_STYLE, STYLE_SOLID);
              ObjectSetInteger(chart_id, tp_obj_name, OBJPROP_WIDTH, 1);
              ObjectSetInteger(chart_id, tp_obj_name, OBJPROP_FILL, tp_zonez_color);
              ObjectSetInteger(chart_id, tp_obj_name, OBJPROP_BACK, true);

              // Display deal trend line
              string line_obj_name = StringFormat("line %d", i);
              ObjectCreate(chart_id, line_obj_name, OBJ_TREND, 0, deal_open_time, deal_open_price, deal_close_time, deal_close_price);
              ObjectSetInteger(chart_id, line_obj_name, OBJPROP_COLOR, line_zonez_color);
              ObjectSetInteger(chart_id, line_obj_name, OBJPROP_STYLE, STYLE_DASH);
              ObjectSetInteger(chart_id, line_obj_name, OBJPROP_WIDTH, 2);
              
              
            }
          }
        }
      }
    }

   
  }
//+------------------------------------------------------------------+
