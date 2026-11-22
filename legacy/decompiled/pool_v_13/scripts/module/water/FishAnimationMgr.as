package module.water
{
   import com.qzone.qfa.managers.LoadManager;
   import common.Consts;
   import common.misc.time.CountDown;
   import entities.PoolFish;
   import flash.display.MovieClip;
   import flash.system.ApplicationDomain;
   
   public class FishAnimationMgr
   {
      
      private static var _instance:FishAnimationMgr;
      
      private var _loadMgr:LoadManager;
      
      private var m_recycleFreq:CountDown;
      
      private var _poolMgr:FishMCPoolObjectMgr;
      
      public function FishAnimationMgr()
      {
         super();
         this._poolMgr = new FishMCPoolObjectMgr();
         this._loadMgr = new LoadManager(ApplicationDomain.currentDomain);
         this._loadMgr.maxThreadCount = 3;
         this.m_recycleFreq = new CountDown(Consts.FISH_POOL_GC_COUNTDOWN);
      }
      
      public static function getInstance() : FishAnimationMgr
      {
         if(_instance != null)
         {
            return _instance;
         }
         _instance = new FishAnimationMgr();
         return _instance;
      }
      
      public function destroyMC(param1:MovieClip) : void
      {
         if(param1 == null)
         {
            return;
         }
         param1.stop();
         param1.x = param1.y = 0;
         param1.scaleX = param1.scaleY = 1;
         if(param1.parent != null)
         {
            param1.parent.removeChild(param1);
         }
         this._poolMgr.returnObject(param1);
      }
      
      public function createFishMC(param1:String) : MovieClip
      {
         if(param1 == null || param1 == "")
         {
            return null;
         }
         if(this._poolMgr.contains(param1) == false)
         {
            this._poolMgr.register(param1);
         }
         return this._poolMgr.getObject(param1) as MovieClip;
      }
      
      public function onGameLoop(param1:Number) : void
      {
         if(this.m_recycleFreq.isReady() == false)
         {
            return;
         }
         this.m_recycleFreq.reset(Consts.FISH_POOL_GC_COUNTDOWN);
         this._poolMgr.gc();
      }
      
      public function loadFishes(param1:Array) : Boolean
      {
         var _loc3_:PoolFish = null;
         var _loc4_:String = null;
         var _loc2_:Boolean = false;
         if(param1 == null || param1.length == 0)
         {
            return _loc2_;
         }
         for each(_loc3_ in param1)
         {
            if(_loc3_ != null)
            {
               _loc4_ = _loc3_.animationUrl;
               if(!(_loc4_ == null || _loc4_ == ""))
               {
                  if(this._loadMgr.add(_loc4_) != null)
                  {
                     _loc2_ = true;
                  }
               }
            }
         }
         this._loadMgr.start();
         return _loc2_;
      }
   }
}

