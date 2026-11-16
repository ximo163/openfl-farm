package mc.view.main.cursor
{
   public class CursorClassLib
   {
      
      private static var cusrsorLib:Object = {
         "CursorArrow":CursorArrow,
         "Cursor_ShengChan":Cursor_ShengChan,
         "Cursor_ShouHuo":Cursor_ShouHuo,
         "Cursor_Theft":Cursor_Theft,
         "CursorArrow":CursorArrow,
         "CursorTool":CursorTool,
         "Cursor_Fly":Cursor_Fly,
         "Cursor_Flapper":Cursor_Flapper,
         "Cursor_ClearBB":Cursor_ClearBB,
         "Cursor_ShouHuoAll":Cursor_ShouHuoAll,
         "Cursor_Donate":Cursor_Donate,
         "Cursor_Tanabata":Cursor_Tanabata
      };
      
      public function CursorClassLib()
      {
         super();
      }
      
      public static function getClass(param1:String) : Class
      {
         if(cusrsorLib == null)
         {
            return null;
         }
         return cusrsorLib[param1];
      }
      
      public static function register(param1:String, param2:Class) : void
      {
         if(cusrsorLib == null)
         {
            cusrsorLib = new Object();
         }
         cusrsorLib[param1] = param2;
      }
   }
}

