package mx.core
{
   import flash.display.SimpleButton;
   import mx.utils.NameUtil;
   
   public class FlexSimpleButton extends SimpleButton
   {
      
      §§namespace("http://www.adobe.com/2006/flex/mx/internal") static const VERSION:String = "3.2.0.3958";
      
      public function FlexSimpleButton()
      {
         super();
         try
         {
            name = NameUtil.createUniqueName(this);
         }
         catch(e:Error)
         {
         }
      }
      
      override public function toString() : String
      {
         return NameUtil.displayObjectToString(this);
      }
   }
}

