package common.misc
{
   import com.adobe.serialization.json.JSON;
   import flash.xml.XMLDocument;
   import flash.xml.XMLNode;
   import module.FarmApplication;
   
   public class ConfigMerger
   {
      
      private var _app:FarmApplication;
      
      private var _toMerge:XML;
      
      public function ConfigMerger(param1:FarmApplication, param2:String)
      {
         super();
         this._app = param1;
         this.parseXMLData(param2);
         this._toMerge = null;
      }
      
      private function checkTargetData(param1:String) : Object
      {
         var _loc2_:* = this._app.model.getData(param1);
         if(_loc2_ == null)
         {
            _loc2_ = {};
            this._app.model.setData(param1,_loc2_);
         }
         return _loc2_;
      }
      
      private function mergeCommonNode(param1:String) : void
      {
         var _loc7_:XML = null;
         var _loc8_:XML = null;
         var _loc2_:XMLList = this._toMerge.child(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:* = this.checkTargetData(param1);
         var _loc4_:* = null;
         var _loc5_:String = "";
         var _loc6_:XMLList = _loc2_.children();
         for each(_loc7_ in _loc6_)
         {
            _loc4_ = {};
            _loc5_ = _loc7_.@id == undefined ? _loc7_.name() : _loc7_.@id;
            if(_loc7_.attributes() != undefined)
            {
               for each(_loc8_ in _loc7_.attributes())
               {
                  if(_loc8_.name() != "id")
                  {
                     _loc4_[_loc8_.name().toString()] = _loc8_.toString();
                  }
               }
               _loc3_[_loc5_] = _loc4_;
            }
            else if(_loc7_.text() != undefined)
            {
               _loc3_[_loc5_] = _loc7_.text().toString();
            }
         }
      }
      
      private function checkTargetArrayData(param1:String) : Array
      {
         var _loc2_:Array = this._app.model.getData(param1) as Array;
         if(_loc2_ == null)
         {
            _loc2_ = [];
            this._app.model.setData(param1,_loc2_);
         }
         return _loc2_;
      }
      
      private function parseJSONData(param1:*) : void
      {
         var _loc3_:String = null;
         var _loc2_:Object = com.adobe.serialization.json.JSON.decode(param1);
         for(_loc3_ in _loc2_)
         {
            this._app.model.setData(_loc3_,_loc2_[_loc3_]);
         }
      }
      
      private function parseXMLData(param1:String) : void
      {
         var _loc2_:XMLNode = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc7_:XMLNode = null;
         var _loc8_:String = null;
         var _loc9_:XMLDocument = new XMLDocument();
         _loc9_.ignoreWhite = true;
         _loc9_.parseXML(param1);
         for each(_loc7_ in _loc9_.firstChild.childNodes)
         {
            _loc4_ = _loc7_.nodeName;
            _loc3_ = {};
            if(_loc7_.attributes.type == "json")
            {
               this.parseJSONData(_loc7_.childNodes[0].nodeValue);
            }
            else if(_loc7_.attributes.type == "xml")
            {
               this._app.model.setData(_loc4_,XML(_loc7_));
            }
            else
            {
               for each(_loc2_ in _loc7_.childNodes)
               {
                  _loc5_ = {};
                  _loc6_ = _loc2_.attributes.id == null ? _loc2_.nodeName : _loc2_.attributes.id;
                  for(_loc8_ in _loc2_.attributes)
                  {
                     _loc5_[_loc8_] = _loc2_.attributes[_loc8_];
                  }
                  _loc3_[_loc6_] = _loc5_;
               }
               this._app.model.setData(_loc4_,_loc3_);
            }
         }
      }
      
      public function mergeConfig(param1:XML) : void
      {
         if(param1 == null || this._app.model == null)
         {
            return;
         }
         this._toMerge = param1;
         this.mergeCommonNode("environment");
         this.mergeCommonNode("assets");
         this.mergeJsonArrayNode("secondList");
         this.mergeJsonArrayNode("plugins");
         this.mergeJsonArrayNode("boards");
         this.mergeJsonArrayNode("crops");
         this.mergeJsonArrayNode("item_info");
         this.mergeJsonArrayNode("fish_info");
         this.mergeJsonArrayNode("advertisement");
         this.mergeCommonNode("cardsGameRewards");
         this.mergeCommonNode("freegifts");
         this.mergeCommonNode("dynamicTips");
         this.mergeCommonNode("monthEnds");
         this.mergeCommonNode("magiccards");
         this.mergeCommonNode("qdseeds");
         this.mergeCommonNode("bigworlds");
         this.mergeCommonNode("luoyangs");
         this.mergeXml("wild");
      }
      
      private function mergeJsonArrayNode(param1:String) : void
      {
         var cfg:*;
         var toAdd:Array;
         var exist:Boolean;
         var a:* = undefined;
         var jsn:Object = null;
         var t:* = undefined;
         var att:* = undefined;
         var name:String = param1;
         var mNode:XMLList = this._toMerge.child(name);
         if(mNode == null || mNode.@type != "json")
         {
            return;
         }
         cfg = this.checkTargetArrayData(name);
         try
         {
            jsn = com.adobe.serialization.json.JSON.decode(mNode.children()[0]);
         }
         catch(e:Error)
         {
            trace("ERROR> parse json data failed.");
            return;
         }
         exist = false;
         toAdd = [];
         for each(a in jsn[name])
         {
            exist = false;
            for each(t in cfg)
            {
               if(a["id"] == t["id"])
               {
                  for(att in a)
                  {
                     t[att] = a[att];
                  }
                  exist = true;
                  break;
               }
            }
            if(exist == false)
            {
               toAdd.push(a);
            }
         }
         cfg = cfg.concat(toAdd);
         this._app.model.setData(name,cfg);
      }
      
      private function mergeXml(param1:String) : void
      {
         var _loc2_:XMLList = this._toMerge.child(param1);
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:XML = _loc2_[0];
         this._app.model.setData(param1,_loc3_);
      }
   }
}

