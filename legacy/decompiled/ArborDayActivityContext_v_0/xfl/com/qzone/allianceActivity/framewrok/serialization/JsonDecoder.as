package com.qzone.allianceActivity.framewrok.serialization
{
   internal class JsonDecoder
   {
      
      public static const DOUBLE_QUOTATION:String = "\"";
      
      public static const SINGLE_QUOTATION:String = "\'";
      
      public static const LEFT_BRACE:String = "{";
      
      public static const RIGHT_BRACE:String = "}";
      
      public static const LEFT_BRACKET:String = "[";
      
      public static const RIGHT_BRACKET:String = "]";
      
      public static const COMMA:String = ",";
      
      public static const COLON:String = ":";
      
      public static const QUOTE:String = "\\";
      
      public static const STRING_TYPE:String = "string";
      
      public static const NUMBER_TYPE:String = "number";
      
      public static const CONTROL_TYPE:String = "control";
      
      public static const KEYWORD_TYPE:String = "keyworkd";
      
      private var _str:String;
      
      private var _index:int;
      
      private var _type:String;
      
      private var _inDicKey:Boolean = false;
      
      private var _dicKey:String = null;
      
      private var _stack:Array = new Array();
      
      public function JsonDecoder(param1:String)
      {
         super();
         this._str = param1;
      }
      
      public function get depth() : int
      {
         return this._stack.length - 1;
      }
      
      public function get current() : *
      {
         try
         {
            return this._stack[this._stack.length - 1];
         }
         catch(e:Error)
         {
            return null;
         }
      }
      
      public function parse() : *
      {
         var _loc2_:* = undefined;
         var _loc1_:int = this._str.length;
         this._index = 0;
         while(this._index < _loc1_)
         {
            _loc2_ = this.next();
            if(_loc2_ != null)
            {
               if(this._type == STRING_TYPE)
               {
                  this.c2string(_loc2_);
               }
               else if(this._type == NUMBER_TYPE)
               {
                  this.c2string(_loc2_);
               }
               else if(this._type == KEYWORD_TYPE)
               {
                  this.c2string(_loc2_);
               }
               else if(this._type == CONTROL_TYPE)
               {
                  if(_loc2_ == LEFT_BRACKET)
                  {
                     this.c2listStart();
                  }
                  else if(_loc2_ == RIGHT_BRACKET)
                  {
                     this.c2listEnd();
                  }
                  else if(_loc2_ == LEFT_BRACE)
                  {
                     this.c2dicStart();
                  }
                  else if(_loc2_ == RIGHT_BRACE)
                  {
                     this.c2dicEnd();
                  }
                  else if(_loc2_ == COMMA)
                  {
                     this.c2splitter();
                  }
                  else if(_loc2_ == COLON)
                  {
                     this.c2keyvalueSplitter();
                  }
               }
            }
         }
         return this._stack[0];
      }
      
      private function next() : *
      {
         var _loc1_:String = this._str.substr(this._index,1);
         if(_loc1_ == DOUBLE_QUOTATION || _loc1_ == SINGLE_QUOTATION)
         {
            this._type = STRING_TYPE;
            return this.parseString();
         }
         if(this.isDigit(_loc1_) || _loc1_ == "-" || _loc1_ == ".")
         {
            this._type = NUMBER_TYPE;
            return this.parseNumber();
         }
         if(_loc1_ == LEFT_BRACKET)
         {
            ++this._index;
            this._type = CONTROL_TYPE;
            return _loc1_;
         }
         if(_loc1_ == LEFT_BRACE)
         {
            ++this._index;
            this._type = CONTROL_TYPE;
            return _loc1_;
         }
         if(_loc1_ == RIGHT_BRACKET)
         {
            ++this._index;
            this._type = CONTROL_TYPE;
            return _loc1_;
         }
         if(_loc1_ == RIGHT_BRACE)
         {
            ++this._index;
            this._type = CONTROL_TYPE;
            return _loc1_;
         }
         if(_loc1_ == COMMA)
         {
            ++this._index;
            this._type = CONTROL_TYPE;
            return _loc1_;
         }
         if(_loc1_ == COLON)
         {
            ++this._index;
            this._type = CONTROL_TYPE;
            return _loc1_;
         }
         if(this.isWhiteSpace(_loc1_))
         {
            ++this._index;
            this._type = null;
            return null;
         }
         this._type = KEYWORD_TYPE;
         return this.parseKeyword();
      }
      
      private function parseString() : String
      {
         var _loc1_:String = this._str.substr(this._index,1);
         if(_loc1_ != DOUBLE_QUOTATION && _loc1_ != SINGLE_QUOTATION)
         {
            throw new Error("parseString error");
         }
         ++this._index;
         var _loc2_:int = this._index;
         var _loc3_:int = _loc2_;
         var _loc4_:String = _loc1_;
         while(true)
         {
            _loc3_ = this._str.indexOf(_loc4_,_loc2_);
            if(this._str.substr(_loc3_ - 1) != QUOTE)
            {
               break;
            }
            this._index = _loc3_ + 1;
         }
         this._index = _loc3_ + 1;
         return this._str.substring(_loc2_,_loc3_);
      }
      
      private function parseNumber() : *
      {
         var _loc1_:String = "";
         var _loc2_:int = this._str.length;
         var _loc3_:int = 1;
         var _loc4_:String = this._str.substr(this._index,1);
         if(_loc4_ == "-")
         {
            _loc3_ = -1;
            ++this._index;
         }
         while(this._index < _loc2_)
         {
            _loc4_ = this._str.substr(this._index,1);
            if(!(_loc4_ == "." || this.isDigit(_loc4_)))
            {
               break;
            }
            _loc1_ += _loc4_;
            ++this._index;
         }
         if(_loc1_.indexOf("."))
         {
            return Number(_loc1_) * _loc3_;
         }
         return int(_loc1_) * _loc3_;
      }
      
      private function parseKeyword() : *
      {
         var _loc1_:String = this._str.substr(this._index).match(/[a-zA-Z0-9_]+/).toString();
         if(_loc1_ == null || _loc1_ == "")
         {
            return null;
         }
         this._type = KEYWORD_TYPE;
         this._index += _loc1_.length;
         if(_loc1_ == "true")
         {
            return true;
         }
         if(_loc1_ == "false")
         {
            return false;
         }
         if(_loc1_ == "null")
         {
            return null;
         }
         return _loc1_;
      }
      
      private function append(param1:*) : void
      {
         var _loc2_:* = this.current;
         if(_loc2_ is Array)
         {
            _loc2_.push(param1);
            this._stack.push(param1);
         }
         else if(typeof _loc2_ == "object")
         {
            _loc2_[this._dicKey] = param1;
            this._stack.push(param1);
         }
         else
         {
            this._stack.push(param1);
            this._stack.push(param1);
         }
      }
      
      private function c2string(param1:*) : void
      {
         if(param1 is String)
         {
         }
         if(this._inDicKey)
         {
            this._dicKey = param1;
         }
         else if(this.current is Array)
         {
            this.current.push(param1);
         }
         else if(typeof this.current == "object")
         {
            this.current[this._dicKey] = param1;
         }
         else
         {
            this._stack.push(param1);
         }
      }
      
      private function c2dicStart() : void
      {
         this._inDicKey = true;
         this.append(new Object());
      }
      
      private function c2dicEnd() : void
      {
         this._stack.pop();
      }
      
      private function c2listStart() : void
      {
         this.append(new Array());
      }
      
      private function c2listEnd() : void
      {
         this._stack.pop();
      }
      
      private function c2splitter() : void
      {
         if(typeof this.current == "object" && !(this.current is Array))
         {
            this._inDicKey = true;
         }
      }
      
      private function c2keyvalueSplitter() : void
      {
         this._inDicKey = false;
      }
      
      private function isDigit(param1:String) : Boolean
      {
         return param1 >= "0" && param1 <= "9";
      }
      
      private function isWhiteSpace(param1:String) : Boolean
      {
         return param1 == " " || param1 == "\t" || param1 == "\n" || param1 == "\r";
      }
   }
}

