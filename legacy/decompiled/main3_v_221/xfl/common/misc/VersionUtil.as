package common.misc
{
   import flash.display.Sprite;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import flash.utils.ByteArray;
   
   public class VersionUtil
   {
      
      public static var versionString:String;
      
      private static var versionXml:Class = VersionUtil_versionXml;
      
      public function VersionUtil()
      {
         super();
      }
      
      public static function setRightMenu(param1:Sprite, param2:String = "Build @build") : void
      {
         var _loc3_:ByteArray = new versionXml() as ByteArray;
         var _loc4_:XML = new XML(_loc3_.readUTFBytes(_loc3_.length));
         var _loc5_:Array = _loc4_.build.@time.split(" ");
         var _loc6_:String = _loc5_[0].split("-").join("");
         var _loc7_:Number = Number(_loc4_.build.@count);
         var _loc8_:String = _loc7_.toString(36).toLocaleUpperCase();
         param2 = param2.replace("@build",_loc6_ + "." + _loc8_);
         versionString = param2;
         param1.contextMenu = param1.contextMenu || new ContextMenu();
         param1.contextMenu.hideBuiltInItems();
         param1.contextMenu.customItems.push(new ContextMenuItem(param2,false,false));
      }
   }
}

