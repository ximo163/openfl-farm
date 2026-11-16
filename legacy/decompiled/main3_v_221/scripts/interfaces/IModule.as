package interfaces
{
   import framework.base.BaseLayer;
   import module.FarmApplication;
   
   public interface IModule
   {
      
      function get container() : BaseLayer;
      
      function get loaded() : Boolean;
      
      function onGameLoop(param1:Number) : void;
      
      function loadLater(param1:Array, param2:BaseLayer) : void;
      
      function get app() : FarmApplication;
      
      function get name() : String;
      
      function onNetRequestStopped() : void;
      
      function load(param1:BaseLayer) : void;
      
      function unload() : void;
   }
}

