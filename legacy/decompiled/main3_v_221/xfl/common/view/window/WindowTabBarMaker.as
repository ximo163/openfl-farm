package common.view.window
{
   import com.qzone.qui.controls.TabBar;
   import com.qzone.qui.styles.Style;
   import com.qzone.qui.utils.TextFormatUtil;
   import common.misc.Utils;
   import flash.text.TextFormat;
   
   public class WindowTabBarMaker
   {
      
      public static var tabOverFormat:TextFormat;
      
      public static var tabDefaultFormat:TextFormat;
      
      public static var tabSelectedFormat:TextFormat;
      
      public function WindowTabBarMaker()
      {
         super();
      }
      
      public static function addTarget(param1:TabBar) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(tabDefaultFormat == null)
         {
            tabDefaultFormat = TextFormatUtil.clone(Style.getButtonFormat());
            tabDefaultFormat.color = 39423;
            tabOverFormat = TextFormatUtil.clone(Style.getButtonOverFormat());
            tabOverFormat.color = null;
            tabSelectedFormat = TextFormatUtil.clone(Style.getButtonSelectedFormat());
            tabSelectedFormat.color = 16777215;
            tabSelectedFormat.bold = true;
         }
         param1.height = 25;
         param1.paddingH = 25;
         param1.gapH = 3;
         param1.tabDefaultFormat = tabDefaultFormat;
         param1.tabOverFormat = tabOverFormat;
         param1.tabSelectedFormat = tabSelectedFormat;
         param1.defaultSkin = Utils.getClass("TabBg");
         param1.tabDefaultSkin = Utils.getClass("TabDefault");
         param1.tabSelectedSkin = Utils.getClass("TabSelected");
      }
   }
}

