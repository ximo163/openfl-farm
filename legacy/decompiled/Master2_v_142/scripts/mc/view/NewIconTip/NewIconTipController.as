package mc.view.NewIconTip
{
   import flash.display.DisplayObject;
   import flash.geom.Point;
   
   public class NewIconTipController
   {
      
      public function NewIconTipController()
      {
         super();
      }
      
      public static function show(param1:Point, param2:String, param3:String = null, param4:DisplayObject = null) : void
      {
         var _loc5_:NewIconTipModel = NewIconTipModel.gi();
         _loc5_.Data = {
            "newPoint":param1,
            "tipTxt":param2,
            "tipType":param3,
            "tartget":param4
         };
      }
   }
}

