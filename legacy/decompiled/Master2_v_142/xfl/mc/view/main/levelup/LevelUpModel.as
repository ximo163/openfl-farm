package mc.view.main.levelup
{
   import common.INI;
   import mc.model.MData;
   import mc.view.farm.GetCropID;
   
   public class LevelUpModel
   {
      
      public static const DEN_UPDATE_INFO:Array = [0,1,4,8,12,16,20,24,30,36,43,51,59];
      
      public static const SHED_UPDATE_INFO:Array = [2,6,10,14,18,22,26,28,33,39,47,55,64];
      
      public static const DEN_UPDATE_INFO_NUM:Array = [2,1,2,1,1,1,1,1];
      
      public static const SHED_UPDATE_INFO_NUM:Array = [3,1,1,1,1,1,1,1];
      
      private var config:XML;
      
      public function LevelUpModel()
      {
         super();
         var _loc1_:XMLList = INI.getInstance().data.levelup;
         if(_loc1_)
         {
            this.config = _loc1_[0];
         }
      }
      
      public function getPanelURL() : String
      {
         return GetCropID.addPrefix(this.config.@url);
      }
      
      public function getYellowURL() : String
      {
         return "tools.php?mod=vip";
      }
      
      public function isYellow() : Boolean
      {
         var _loc1_:Object = MData.getInstance().mainData.host;
         return _loc1_["yellowstatus"] != undefined && _loc1_["yellowstatus"] >= 1;
      }
      
      public function getLevelUpPicURL() : String
      {
         return "module/mc/icon/levelUp.jpg";
      }
   }
}

