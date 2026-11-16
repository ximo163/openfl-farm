package mc.view.common
{
   import com.qzone.corelib.net.RSLManager;
   import common.MaterialLib;
   import flash.display.MovieClip;
   import mc.control.MainCommand;
   import mc.view.farm.GetCropID;
   
   public class WildMaterialLoaderProxy extends MaterialLoaderProxy
   {
      
      public function WildMaterialLoaderProxy()
      {
         super();
      }
      
      private function laodWildAnimal() : void
      {
         var _loc1_:String = GetCropID.getWildAnimalIcon(_type,_id);
         load(_loc1_);
      }
      
      private function loadWeapon() : void
      {
         var _loc1_:String = MainCommand.getModule2Url("wildaweapon")["url"] + "weapon" + _id + ".swf";
         RSLManager.getInstance().requestClass("Weapon_Icon_" + _addOn["type"] + "_" + _id,this.addWeapon,_loc1_,{"id":_id});
      }
      
      private function laodWild() : void
      {
         var _loc1_:String = GetCropID.getWildIcon(_type,_id,_addOn["type"]);
         load(_loc1_);
      }
      
      private function addWeapon(param1:Object = null) : void
      {
         var _loc2_:MovieClip = MaterialLib.getInstance().getMaterial("Weapon_Icon_" + _addOn["type"] + "_" + _id) as MovieClip;
         addChild(_loc2_);
      }
      
      override public function setContent(param1:String, param2:int, param3:Object = null, param4:Boolean = false, param5:Boolean = false, param6:Boolean = false, param7:Boolean = false) : void
      {
         super.setContent(param1,param2,param3);
         if(param1 == "wild_animal")
         {
            this.laodWildAnimal();
         }
         if(param1 == "wild_animal_big")
         {
            this.laodWildAnimal();
         }
         if(param1 == "wild_drop")
         {
            this.laodWild();
         }
         if(param1 == "weapon")
         {
            this.loadWeapon();
         }
      }
   }
}

