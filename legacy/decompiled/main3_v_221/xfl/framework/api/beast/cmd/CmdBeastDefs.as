package framework.api.beast.cmd
{
   import common.Settings;
   import flash.utils.Dictionary;
   
   public class CmdBeastDefs
   {
      
      private static var instance:CmdBeastDefs;
      
      public static const CMD_WILD_GET_USER_BEAST:uint = 10001;
      
      public static const CMD_WILD_OPEN_SLOT:uint = 10002;
      
      public static const CMD_WILD_GET_MORALEXP:uint = 10003;
      
      public static const CMD_WILD_RAISE_BEAST:uint = 10004;
      
      public static const CMD_WILD_REWARD_BEAST:uint = 10005;
      
      public static const CMD_WILD_DONATE_BEAST:uint = 10006;
      
      public static const CMD_WILD_ATTACK_BEAST:uint = 10007;
      
      public static const CMD_WILD_ADOPT_BEAST:uint = 10008;
      
      public static const CMD_WILD_PICKUP_CRYSTAL:uint = 10009;
      
      public static const CMD_WILD_GET_USER_CRYSTAL:uint = 10010;
      
      public static const CMD_WILD_HPAGE_BEAST:uint = 10011;
      
      public static const CMD_WILD_GET_NICK:uint = 10012;
      
      private static var cgi:Dictionary = new Dictionary();
      
      private static var cmdId:Dictionary = new Dictionary();
      
      cgi[CMD_WILD_GET_USER_BEAST] = "cgi_farm_get_userbeast";
      cgi[CMD_WILD_OPEN_SLOT] = "cgi_farm_open_slot";
      cgi[CMD_WILD_GET_MORALEXP] = "cgi_farm_get_moralexp";
      cgi[CMD_WILD_RAISE_BEAST] = "cgi_farm_raise_beast";
      cgi[CMD_WILD_REWARD_BEAST] = "cgi_farm_reward_beast";
      cgi[CMD_WILD_DONATE_BEAST] = "cgi_farm_donate_beast";
      cgi[CMD_WILD_ATTACK_BEAST] = "cgi_farm_attack_beast";
      cgi[CMD_WILD_ADOPT_BEAST] = "cgi_farm_adopt_beast";
      cgi[CMD_WILD_PICKUP_CRYSTAL] = "cgi_farm_pickup_crystal";
      cgi[CMD_WILD_GET_USER_CRYSTAL] = "cgi_farm_get_usercrystal&phpye=phpye";
      cgi[CMD_WILD_HPAGE_BEAST] = "cgi_farm_hpage_beast";
      cgi[CMD_WILD_GET_NICK] = "cgi_farm_beast_getnick";
      cmdId[cgi[CMD_WILD_GET_USER_BEAST]] = CMD_WILD_GET_USER_BEAST;
      cmdId[cgi[CMD_WILD_OPEN_SLOT]] = CMD_WILD_OPEN_SLOT;
      cmdId[cgi[CMD_WILD_GET_MORALEXP]] = CMD_WILD_GET_MORALEXP;
      cmdId[cgi[CMD_WILD_RAISE_BEAST]] = CMD_WILD_RAISE_BEAST;
      cmdId[cgi[CMD_WILD_REWARD_BEAST]] = CMD_WILD_REWARD_BEAST;
      cmdId[cgi[CMD_WILD_DONATE_BEAST]] = CMD_WILD_DONATE_BEAST;
      cmdId[cgi[CMD_WILD_ATTACK_BEAST]] = CMD_WILD_ATTACK_BEAST;
      cmdId[cgi[CMD_WILD_ADOPT_BEAST]] = CMD_WILD_ADOPT_BEAST;
      cmdId[cgi[CMD_WILD_PICKUP_CRYSTAL]] = CMD_WILD_PICKUP_CRYSTAL;
      cmdId[cgi[CMD_WILD_GET_USER_CRYSTAL]] = CMD_WILD_GET_USER_CRYSTAL;
      cmdId[cgi[CMD_WILD_HPAGE_BEAST]] = CMD_WILD_HPAGE_BEAST;
      cmdId[cgi[CMD_WILD_GET_NICK]] = CMD_WILD_GET_NICK;
      
      public var defMaps:Array;
      
      private var _mcCommUrl:String = Settings.getInstance().mcCommUrl;
      
      private var _ncCommUrl:String = Settings.getInstance().ncCommUrl;
      
      public function CmdBeastDefs()
      {
         super();
         this.defMaps = [];
         this.defMaps.push({
            "id":CMD_WILD_GET_USER_BEAST,
            "url":this._mcCommUrl + cgi[CMD_WILD_GET_USER_BEAST]
         });
         this.defMaps.push({
            "id":CMD_WILD_OPEN_SLOT,
            "url":this._mcCommUrl + cgi[CMD_WILD_OPEN_SLOT]
         });
         this.defMaps.push({
            "id":CMD_WILD_GET_MORALEXP,
            "url":this._mcCommUrl + cgi[CMD_WILD_GET_MORALEXP]
         });
         this.defMaps.push({
            "id":CMD_WILD_RAISE_BEAST,
            "url":this._mcCommUrl + cgi[CMD_WILD_RAISE_BEAST]
         });
         this.defMaps.push({
            "id":CMD_WILD_REWARD_BEAST,
            "url":this._mcCommUrl + cgi[CMD_WILD_REWARD_BEAST]
         });
         this.defMaps.push({
            "id":CMD_WILD_DONATE_BEAST,
            "url":this._mcCommUrl + cgi[CMD_WILD_DONATE_BEAST]
         });
         this.defMaps.push({
            "id":CMD_WILD_ATTACK_BEAST,
            "url":this._ncCommUrl + cgi[CMD_WILD_ATTACK_BEAST]
         });
         this.defMaps.push({
            "id":CMD_WILD_ADOPT_BEAST,
            "url":this._mcCommUrl + cgi[CMD_WILD_ADOPT_BEAST]
         });
         this.defMaps.push({
            "id":CMD_WILD_PICKUP_CRYSTAL,
            "url":this._ncCommUrl + cgi[CMD_WILD_PICKUP_CRYSTAL]
         });
         this.defMaps.push({
            "id":CMD_WILD_GET_USER_CRYSTAL,
            "url":this._ncCommUrl + cgi[CMD_WILD_GET_USER_CRYSTAL]
         });
         this.defMaps.push({
            "id":CMD_WILD_HPAGE_BEAST,
            "url":this._ncCommUrl + cgi[CMD_WILD_HPAGE_BEAST]
         });
         this.defMaps.push({
            "id":CMD_WILD_GET_NICK,
            "url":this._ncCommUrl + cgi[CMD_WILD_GET_NICK]
         });
      }
      
      public static function getInstance() : CmdBeastDefs
      {
         if(!instance)
         {
            instance = new CmdBeastDefs();
         }
         return instance;
      }
      
      public static function getIdByCgi(param1:String) : int
      {
         if(cmdId[param1])
         {
            return cmdId[param1];
         }
         return -1;
      }
   }
}

