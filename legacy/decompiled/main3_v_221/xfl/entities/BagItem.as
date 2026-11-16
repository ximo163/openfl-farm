package entities
{
   import common.misc.Utils;
   
   public final class BagItem
   {
      
      public var _depict:String;
      
      public var _level:int;
      
      public var _lifeCycle:int;
      
      public var _name:String;
      
      public var _amount:int;
      
      public var _type:int;
      
      public var _sort:int;
      
      public var _cId:int;
      
      public function BagItem(param1:*)
      {
         super();
         this.importObject(param1);
      }
      
      public function importObject(param1:*) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1["cId"] != undefined)
         {
            this._cId = Utils.getIntAttribute(param1,"cId");
         }
         if(param1["tId"] != undefined)
         {
            this._cId = Utils.getIntAttribute(param1,"tId");
         }
         if(param1["fId"] != undefined)
         {
            this._cId = Utils.getIntAttribute(param1,"fId");
         }
         this._type = Utils.getIntAttribute(param1,"type");
         if(param1["cName"] != undefined)
         {
            this._name = Utils.getStrAttribute(param1,"cName");
         }
         if(param1["tName"] != undefined)
         {
            this._name = Utils.getStrAttribute(param1,"tName");
         }
         if(param1["amount"] != undefined)
         {
            this._amount = Utils.getIntAttribute(param1,"amount");
         }
         if(param1["level"] != undefined)
         {
            this._level = Utils.getIntAttribute(param1,"level");
         }
         if(param1["lifecycle"] != undefined)
         {
            this._lifeCycle = Utils.getIntAttribute(param1,"lifecycle");
         }
         this._depict = Utils.getStrAttribute(param1,"depict");
         this._sort = 0;
      }
   }
}

