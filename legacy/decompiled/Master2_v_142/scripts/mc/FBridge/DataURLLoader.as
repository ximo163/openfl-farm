package mc.FBridge
{
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class DataURLLoader extends URLLoader
   {
      
      private var _postData:Object;
      
      public function DataURLLoader(param1:URLRequest = null)
      {
         super(param1);
      }
      
      public function set postData(param1:Object) : void
      {
         this._postData = param1;
      }
      
      public function get postData() : Object
      {
         return this._postData;
      }
   }
}

