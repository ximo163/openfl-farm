package common.view.window
{
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.styles.Style;
   import com.qzone.qui.utils.TextFormatUtil;
   import com.qzone.utils.GraphicsUtil;
   import flash.geom.Rectangle;
   import flash.text.TextFormat;
   
   public class WindowLabelMaker
   {
      
      public static var labelFormat:TextFormat;
      
      public function WindowLabelMaker()
      {
         super();
      }
      
      public static function addTarget(param1:Label) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(labelFormat == null)
         {
            labelFormat = TextFormatUtil.clone(Style.getLabelFormat());
            labelFormat.color = 12547910;
            labelFormat.align = "center";
         }
         param1.textDefaultFormat = labelFormat;
         GraphicsUtil.draw(param1,16777176,1,null,true);
         GraphicsUtil.hLine(param1,15590344,1,new Rectangle(0,param1.height,param1.width));
      }
   }
}

