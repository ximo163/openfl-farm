package common.view.tip
{
   import common.Consts;
   import flash.filters.GlowFilter;
   import flash.text.TextFormat;
   
   public class CropInfoTip extends MouseTip
   {
      
      public function CropInfoTip()
      {
         super();
         super._tipName = Consts.TIP_NAME_CROPINFO_MOUSE;
         var _loc1_:TextFormat = new TextFormat("Verdana",12,6710886);
         _loc1_.leading = 10;
         _tipText.defaultTextFormat = _loc1_;
         _tipText.filters = [new GlowFilter(16777215,1,3,3)];
         _tipText.multiline = true;
      }
      
      override public function set data(param1:Object) : void
      {
         if(param1 == null)
         {
            param1 = "";
         }
         _tipText.htmlText = param1.toString();
         _tipBg.width = _tipText.width + 10;
         _tipBg.height = _tipText.height + 10;
         _data = param1;
      }
   }
}

