package com.qzone.qfa.net
{
   public interface IRequest
   {
      
      function send(param1:Object = null) : void;
      
      function close() : void;
   }
}

