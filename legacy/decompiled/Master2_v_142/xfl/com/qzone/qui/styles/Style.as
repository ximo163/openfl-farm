package com.qzone.qui.styles
{
   import flash.filters.ColorMatrixFilter;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextFormat;
   
   public class Style
   {
      
      private static var alertTextFormat:TextFormat;
      
      private static var numericStepperFormat:TextFormat;
      
      private static var buttonSelectedFormat:TextFormat;
      
      private static var buttonTextFormat:TextFormat;
      
      private static var rollOutFilter:Array;
      
      private static var textGlowFilter:Array;
      
      private static var disableFilter:Array;
      
      private static var textTextFormat:TextFormat;
      
      private static var disabledFormat:TextFormat;
      
      private static var labelTextFormat:TextFormat;
      
      private static var shadowFilter:Array;
      
      private static var comboBoxFormat:TextFormat;
      
      private static var buttonOverFormat:TextFormat;
      
      private static var toolTipTextFormat:TextFormat;
      
      private static var progressBarTextFormat:TextFormat;
      
      private static var rollOverFilter:Array;
      
      private static var hitFilter:Array;
      
      private static var textInputFormat:TextFormat;
      
      public static var toolTipPaddingH:int = 2;
      
      public static var toolTipPaddingV:int = 1;
      
      public static var toolTipOffset:Point = new Point(0,-5);
      
      public static var textInputPaddingH:int = 1;
      
      public static var textInputPaddingV:int = 1;
      
      public static var checkBoxPaddingH:int = 3;
      
      public static var radioButtonPaddingH:int = 3;
      
      public static var boxPaddingH:int = 10;
      
      public static var boxPaddingV:int = 10;
      
      public static var boxGapH:int = 8;
      
      public static var boxGapV:int = 6;
      
      public static var panelPaddingH:int = 5;
      
      public static var panelPaddingV:int = 5;
      
      public static var panelHeadHeight:int = 22;
      
      public static var panelControlBarHeight:int = 28;
      
      public static var listPaddingH:int = 0;
      
      public static var listPaddingV:int = 0;
      
      public static var listBorderSizeH:int = 1;
      
      public static var listBorderSizeV:int = 1;
      
      public static var canvasBorderSizeH:int = 1;
      
      public static var canvasBorderSizeV:int = 1;
      
      public static var labelPaddingH:int = 0;
      
      public static var buttonPaddingH:int = 4;
      
      public static var comboBoxArrowPaddingH:int = 7;
      
      public static var comboBoxArrowWidth:int = 22;
      
      public static var numericStepperArrowWidth:int = 18;
      
      public static var alertPaddingH:int = 5;
      
      public static var alertPaddingV:int = 10;
      
      public static var popUpModalColor:uint = 16777215;
      
      public static var popUpModalAlpha:Number = 0.15;
      
      public static var vScrollBarWidth:int = 15;
      
      public static var hScrollBarHeight:int = 15;
      
      public static var ScrollBarMinSize:int = 8;
      
      public static var ScrollBarMinIconSize:int = 12;
      
      public static var containerBackgroundColor:uint = 16777215;
      
      public static var containerBackgroundAlpha:Number = 1;
      
      public static var boxBackgroundColor:uint = containerBackgroundColor;
      
      public static var boxBackgroundAlpha:Number = 0;
      
      public static var canvasBackgroundColor:uint = containerBackgroundColor;
      
      public static var canvasBackgroundAlpha:Number = 0;
      
      public static var fontSize:int = 12;
      
      public static var fontFace:String = "Verdana";
      
      public static var color:int = 6389917;
      
      public static var rollOverColor:int = 7187687;
      
      public static var selectedColor:int = 6389917;
      
      public static var disabledColor:int = 12632256;
      
      public static var toolTipColor:int = 0;
      
      public static var sliderTickSize:int = 2;
      
      public static var sliderTickColor:uint = 12632256;
      
      public function Style()
      {
         super();
      }
      
      public static function getToolTipFormat() : TextFormat
      {
         if(toolTipTextFormat == null)
         {
            toolTipTextFormat = new TextFormat(Style.fontFace,Style.fontSize,Style.toolTipColor);
         }
         return toolTipTextFormat;
      }
      
      public static function getShadowFilter() : Array
      {
         if(shadowFilter == null)
         {
            shadowFilter = [new DropShadowFilter(5,45,0,0.6,5,5)];
         }
         return shadowFilter;
      }
      
      public static function getButtonOverFormat() : TextFormat
      {
         if(buttonOverFormat == null)
         {
            buttonOverFormat = new TextFormat(Style.fontFace,Style.fontSize,Style.rollOverColor,null,null,null,null,null,"center");
         }
         return buttonOverFormat;
      }
      
      public static function getHitFilter() : Array
      {
         if(hitFilter == null)
         {
            hitFilter = [new ColorMatrixFilter([1,0,0,0,-5,0,1,0,0,-5,0,0,1,0,-5,0,0,0,1,0])];
         }
         return hitFilter;
      }
      
      public static function getAlertFormat() : TextFormat
      {
         if(alertTextFormat == null)
         {
            alertTextFormat = new TextFormat(Style.fontFace,Style.fontSize,Style.color,null,null,null,null,null,"center");
         }
         return alertTextFormat;
      }
      
      public static function getButtonFormat() : TextFormat
      {
         if(buttonTextFormat == null)
         {
            buttonTextFormat = new TextFormat(Style.fontFace,Style.fontSize,Style.color,false,null,null,null,null,"center");
         }
         return buttonTextFormat;
      }
      
      public static function getDisabledFormat() : TextFormat
      {
         if(disabledFormat == null)
         {
            disabledFormat = new TextFormat(Style.fontFace,Style.fontSize,Style.disabledColor);
         }
         return disabledFormat;
      }
      
      public static function getTextFormat() : TextFormat
      {
         if(textTextFormat == null)
         {
            textTextFormat = new TextFormat(Style.fontFace,Style.fontSize,Style.color,null,null,null,null,null,"left");
         }
         return textTextFormat;
      }
      
      public static function getTextGlowFilter() : Array
      {
         if(textGlowFilter == null)
         {
            textGlowFilter = [new GlowFilter(16777215,1,3,3,7)];
         }
         return textGlowFilter;
      }
      
      public static function getComboBoxFormat() : TextFormat
      {
         if(comboBoxFormat == null)
         {
            comboBoxFormat = new TextFormat(Style.fontFace,Style.fontSize,Style.color,null,null,null,null,null,"left");
            comboBoxFormat.indent = 4;
         }
         return comboBoxFormat;
      }
      
      public static function getNumericStepperFormat() : TextFormat
      {
         if(numericStepperFormat == null)
         {
            numericStepperFormat = new TextFormat(Style.fontFace,Style.fontSize,Style.color,null,null,null,null,null,"left");
         }
         return numericStepperFormat;
      }
      
      public static function getRollOverFilter() : Array
      {
         if(rollOverFilter == null)
         {
            rollOverFilter = [new ColorMatrixFilter([1,0,0,0,15,0,1,0,0,15,0,0,1,0,15,0,0,0,1,0])];
         }
         return rollOverFilter;
      }
      
      public static function getProgressBarFormat() : TextFormat
      {
         if(progressBarTextFormat == null)
         {
            progressBarTextFormat = new TextFormat(Style.fontFace,Style.fontSize,Style.color,null,null,null,null,null,"center");
         }
         return progressBarTextFormat;
      }
      
      public static function getButtonSelectedFormat() : TextFormat
      {
         if(buttonSelectedFormat == null)
         {
            buttonSelectedFormat = new TextFormat(Style.fontFace,Style.fontSize,Style.selectedColor,false,null,null,null,null,"center");
         }
         return buttonSelectedFormat;
      }
      
      public static function getTextInputFormat() : TextFormat
      {
         if(textInputFormat == null)
         {
            textInputFormat = new TextFormat(Style.fontFace,Style.fontSize,Style.color,null,null,null,null,null,"left");
         }
         return textInputFormat;
      }
      
      public static function getRollOutFilter() : Array
      {
         if(rollOutFilter == null)
         {
            rollOutFilter = [];
         }
         return rollOutFilter;
      }
      
      public static function getLabelFormat() : TextFormat
      {
         if(labelTextFormat == null)
         {
            labelTextFormat = new TextFormat(Style.fontFace,Style.fontSize,Style.color,null,null,null,null,null,"left");
         }
         return labelTextFormat;
      }
      
      public static function getDisableFilter() : Array
      {
         if(disableFilter == null)
         {
            disableFilter = [new ColorMatrixFilter([0.3,0.6,0.082,0,0,0.3,0.6,0.082,0,0,0.3,0.6,0.082,0,0,0,0,0,1,0])];
         }
         return disableFilter;
      }
   }
}

