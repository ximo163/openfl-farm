package module.mainScene.background
{
   import com.qzone.utils.ObjectUtil;
   import common.Consts;
   import common.GetCropID;
   import common.Session;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   
   public class BackgroundModel extends EventDispatcher
   {
      
      internal static const DECOR_INDEX_BG:int = 0;
      
      internal static const DECOR_INDEX_HOUSE:int = 1;
      
      internal static const DECOR_INDEX_FENCE:int = 2;
      
      internal static const DECOR_INDEX_DOG_HOUSE:int = 3;
      
      internal static const DECOR_INDEX_BOARD:int = 4;
      
      internal static const DECOR_INDEX_MAX:int = 5;
      
      internal static const EVENT_DECORS_CHANGED:String = "DecorDataChanged";
      
      private var m_decors:Array;
      
      public function BackgroundModel()
      {
         super();
         this.m_decors = null;
      }
      
      internal static function INDEX_TO_TYPE_MAP(param1:int) : int
      {
         if(param1 == DECOR_INDEX_BG)
         {
            return Consts.DECOR_BACKGROUND;
         }
         if(param1 == DECOR_INDEX_HOUSE)
         {
            return Consts.DECOR_HOUSE;
         }
         if(param1 == DECOR_INDEX_FENCE)
         {
            return Consts.DECOR_FENCE;
         }
         if(param1 == DECOR_INDEX_DOG_HOUSE)
         {
            return Consts.DECOR_DOGHOUSE;
         }
         if(param1 == DECOR_INDEX_BOARD)
         {
            return Consts.DECOR_BILLBOARD;
         }
         return -1;
      }
      
      internal static function TYPE_TO_INDEX_MAP(param1:int) : int
      {
         if(param1 == Consts.DECOR_BACKGROUND)
         {
            return DECOR_INDEX_BG;
         }
         if(param1 == Consts.DECOR_HOUSE)
         {
            return DECOR_INDEX_HOUSE;
         }
         if(param1 == Consts.DECOR_FENCE)
         {
            return DECOR_INDEX_FENCE;
         }
         if(param1 == Consts.DECOR_DOGHOUSE)
         {
            return DECOR_INDEX_DOG_HOUSE;
         }
         if(param1 == Consts.DECOR_BILLBOARD)
         {
            return DECOR_INDEX_BOARD;
         }
         return -1;
      }
      
      public function removeDecor(param1:int, param2:int) : void
      {
         var _loc3_:int = TYPE_TO_INDEX_MAP(param2);
         if(_loc3_ == -1)
         {
            return;
         }
         var _loc4_:String = "";
         if(param2 == Consts.DECOR_BACKGROUND)
         {
            if(param1 == -1)
            {
               param1 = 1;
            }
            _loc4_ = GetCropID.idToDiyUrl2(param1.toString());
            if(_loc4_ == "")
            {
               return;
            }
         }
         this.m_decors[_loc3_]["url"] = _loc4_;
         this.m_decors[_loc3_]["id"] = param1;
         dispatchEvent(new CommonEvent(EVENT_DECORS_CHANGED,{"type":param2}));
      }
      
      public function changeDecor(param1:int, param2:int) : Object
      {
         var _loc6_:* = undefined;
         var _loc3_:* = null;
         var _loc4_:int = TYPE_TO_INDEX_MAP(param2);
         if(_loc4_ == -1)
         {
            return _loc3_;
         }
         if(param1 == -1)
         {
            _loc3_ = ObjectUtil.clone(this.m_decors[_loc4_]);
            this.removeDecor(param1,param2);
            return _loc3_;
         }
         var _loc5_:String = "";
         if(param2 == Consts.DECOR_BILLBOARD)
         {
            _loc5_ = GetCropID.idToBoardUrl(param1.toString());
         }
         else
         {
            _loc5_ = GetCropID.idToDiyUrl2(param1.toString());
         }
         if(_loc5_ == "" || _loc5_ == this.m_decors[_loc4_]["url"])
         {
            return _loc3_;
         }
         _loc3_ = ObjectUtil.clone(this.m_decors[_loc4_]);
         this.m_decors[_loc4_]["id"] = param1;
         this.m_decors[_loc4_]["url"] = _loc5_;
         if(param2 != Consts.DECOR_DOG)
         {
            _loc6_ = Session.getInstance().sceneDecorates;
            if(_loc6_ != null)
            {
               _loc6_[param2.toString()] = {"itemId":param1};
            }
         }
         dispatchEvent(new CommonEvent(EVENT_DECORS_CHANGED,{"type":param2}));
         return _loc3_;
      }
      
      public function setDecors(param1:Object) : void
      {
         this.m_decors = new Array();
         this.buildDecor(param1,Consts.DECOR_BACKGROUND.toString());
         this.buildDecor(param1,Consts.DECOR_HOUSE.toString());
         this.buildDecor(param1,Consts.DECOR_FENCE.toString());
         this.buildDecor(param1,Consts.DECOR_DOGHOUSE.toString());
         this.buildDecor(param1,Consts.DECOR_BILLBOARD.toString());
         dispatchEvent(new CommonEvent(EVENT_DECORS_CHANGED,{"type":-1}));
      }
      
      public function set decors(param1:Array) : void
      {
         this.m_decors = param1;
      }
      
      public function get decors() : Array
      {
         return this.m_decors;
      }
      
      private function buildDecor(param1:Object, param2:String) : void
      {
         var _loc3_:* = undefined;
         var _loc4_:String = null;
         var _loc5_:* = undefined;
         if(param1 == null)
         {
            return;
         }
         if(param1.hasOwnProperty(param2) == true)
         {
            _loc3_ = param1[param2];
            _loc4_ = "";
            if(param2 == Consts.DECOR_BILLBOARD.toString())
            {
               _loc4_ = GetCropID.idToBoardUrl(_loc3_["itemId"]);
            }
            else
            {
               _loc4_ = GetCropID.idToDiyUrl2(_loc3_["itemId"]);
            }
            _loc5_ = {
               "id":_loc3_["itemId"],
               "type":param2,
               "url":_loc4_
            };
            this.m_decors.push(_loc5_);
         }
         else if(param2 == Consts.DECOR_BACKGROUND.toString())
         {
            this.m_decors.push({
               "id":-1,
               "type":param2,
               "url":GetCropID.idToDiyUrl2("1")
            });
         }
         else
         {
            this.m_decors.push({
               "id":-1,
               "type":param2,
               "url":""
            });
         }
      }
   }
}

