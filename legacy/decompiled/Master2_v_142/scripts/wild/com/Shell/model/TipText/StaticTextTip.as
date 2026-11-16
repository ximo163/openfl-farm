package wild.com.Shell.model.TipText
{
   import wild.com.Shell.DataShell;
   
   public class StaticTextTip
   {
      
      private static var instance:StaticTextTip;
      
      private var shopTipText:String = "";
      
      private var wildStageTipText:String = "";
      
      public function StaticTextTip()
      {
         super();
      }
      
      public static function getInstance() : StaticTextTip
      {
         if(instance == null)
         {
            instance = new StaticTextTip();
         }
         return instance;
      }
      
      public function get WildStageGetYellow() : String
      {
         if(DataShell.getYellowTip() == null)
         {
            return "";
         }
         if(DataShell.getYellowTip().@vip_tip != "")
         {
            this.wildStageTipText = DataShell.getYellowTip().@vip_tip;
         }
         else
         {
            this.wildStageTipText = "";
         }
         return this.wildStageTipText;
      }
      
      public function showYellowTool(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         if(DataShell.getYellowTip() == null)
         {
            return false;
         }
         var _loc3_:int = DataShell.getYellowTip().info.length();
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(DataShell.getYellowTip().info[_loc4_].@name == param1)
            {
               if(DataShell.getYellowTip().info[_loc4_].@vip_tip != "")
               {
                  _loc2_ = true;
                  break;
               }
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function ShopGetYellow(param1:String) : String
      {
         if(DataShell.getShowYellow(param1).@vip_tip != "")
         {
            this.shopTipText = DataShell.getShowYellow(param1).@vip_tip;
         }
         else
         {
            this.shopTipText = "";
         }
         return this.shopTipText;
      }
   }
}

