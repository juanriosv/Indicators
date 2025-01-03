//+------------------------------------------------------------------+
//|                                                    iMaVShift.mq5 |
//|                                              Juan Rios Villasmil |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Juan Rios Villasmil"
#property link      ""
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 1 // How many data buffers are we using
#property indicator_plots 1   // How many indicators are being drawn on screen

#property indicator_type1  DRAW_LINE   //	This type draws a simple line
#property indicator_label1 "SlowMA"    //	label to show in the data window
#property indicator_color1 clrGray     //	Line colour
#property indicator_style1 STYLE_SOLID //	Solid, dotted etc
#property indicator_width1 2           //	4 because it's easier to see in the demo


// Parámetros de entrada
input ENUM_TIMEFRAMES inpTimeFrame;               // Período
input int     inpPeriods = 200;                   // Cantidad de período de la Media
input int     inpHShift = 0;                      // Desplazamiento horizontal de la Media
input double  inpVShift = 1200;                   // Desplazamiento vertical de la Media
input ENUM_MA_METHOD inpMethod = MODE_EMA;        // Método calculo de la Media
input ENUM_APPLIED_PRICE inpPrice = PRICE_CLOSE;  // Tipo de precio: Cierre por defecto

// Variables
int  SlowHandle;
int  MaxPeriod;

// Buffers
double EMA_Buffer[];

//+------------------------------------------------------------------+
//| Indicador de Inicialización                                      |
//+------------------------------------------------------------------+
int OnInit()
  {

// Handle
   SlowHandle = iMA(Symbol(), Period(), inpPeriods, inpHShift, inpMethod, inpPrice);

   MaxPeriod = (int) inpPeriods;

// Asignar el buffer al indicador
   SetIndexBuffer(0, EMA_Buffer, INDICATOR_DATA);

// Configuración del indicador
   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Custom EMA (" + IntegerToString(inpPeriods) +
                      ", Offset=" + DoubleToString(inpVShift, 1) + ")");

   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, MaxPeriod);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Cálculo del indicador                                            |
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
// Verificar si hay suficientes barras para calcular la EMA
//---
   if(IsStopped())
      return (0);   // Must respect the stop flag

   if(rates_total < MaxPeriod)
      return (0);   // Check that we have enough bars available to calculate


// Check that the moving averages have all been calculated
   if(BarsCalculated(SlowHandle) < rates_total) return (0);

   int copyBars = 0;
   int startBar = 0;
   if(prev_calculated > rates_total || prev_calculated <= 0)
     {
      copyBars = rates_total;
      startBar = 0;
     }
   else
     {
      copyBars = rates_total - prev_calculated;
      if(prev_calculated > 0)
         copyBars++;
      startBar = prev_calculated - 1;
     }


   if ( IsStopped() ) return ( 0 ); //	Must respect the stop flag
   if ( CopyBuffer( SlowHandle, 0, 0, copyBars, EMA_Buffer ) <= 0 ) return ( 0 );
   
   // Factor de conversión de puntos a precio
   double pointFactor = inpVShift * _Point;   
   
   for(int i=startBar;i<rates_total;i++)
     {
      EMA_Buffer[i] = EMA_Buffer[i] + pointFactor;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   if(SlowHandle != INVALID_HANDLE)
      IndicatorRelease(SlowHandle);

  }
//+------------------------------------------------------------------+
