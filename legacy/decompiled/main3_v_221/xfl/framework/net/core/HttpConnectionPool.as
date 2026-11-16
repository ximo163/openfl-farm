package framework.net.core
{
   public class HttpConnectionPool
   {
      
      private static var _instance:HttpConnectionPool = null;
      
      private var _freeList:Array;
      
      public function HttpConnectionPool()
      {
         super();
         this._freeList = new Array();
      }
      
      public static function getInstance() : HttpConnectionPool
      {
         if(_instance != null)
         {
            return _instance;
         }
         _instance = new HttpConnectionPool();
         return _instance;
      }
      
      public function free(param1:HttpOperationEx) : void
      {
         this._freeList.push(param1);
      }
      
      public function borrow() : HttpOperationEx
      {
         var _loc1_:HttpOperationEx = null;
         trace("http connection " + this._freeList.length);
         if(this._freeList.length == 0)
         {
            return new HttpOperationEx();
         }
         return this._freeList.shift() as HttpOperationEx;
      }
   }
}

