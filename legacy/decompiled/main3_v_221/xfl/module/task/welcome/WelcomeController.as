package module.task.welcome
{
   import common.Consts;
   import entities.StartupData;
   import entities.Task;
   import events.CommonEvent;
   import framework.base.Controller;
   import interfaces.IModule;
   import interfaces.IMsgCenter;
   
   public class WelcomeController extends Controller
   {
      
      public function WelcomeController(param1:IModule)
      {
         super(param1);
      }
      
      public function startNewTask() : void
      {
         var _loc1_:Task = new Task(null);
         _loc1_._taskId = 0;
         _loc1_._taskFlag = 2;
         this.model.currentTask = _loc1_;
      }
      
      private function onCheckTaskComplete(param1:CommonEvent) : void
      {
         var _loc3_:String = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:* = param1.data;
         for(_loc3_ in _loc2_)
         {
            this.model.taskComp(_loc3_,_loc2_[_loc3_]);
         }
      }
      
      private function onStartupData(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:StartupData = param1.data as StartupData;
         if(_loc2_ == null)
         {
            return;
         }
         if(m_view == null)
         {
            m_view = new WelcomeView(this);
            if(super.module.container != null)
            {
               super.module.container.addChild(m_view);
            }
         }
         if(_loc2_._welcome == true)
         {
            m_view.showNewGuide();
         }
         else
         {
            this.model.currentTask = _loc2_._task;
         }
      }
      
      public function get model() : WelcomeModel
      {
         return m_model as WelcomeModel;
      }
      
      override public function initialze() : void
      {
         if(m_model == null)
         {
            m_model = new WelcomeModel();
         }
         var _loc1_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(Consts.MSG_STARTUP_DATA,this.onStartupData,false,0,true);
            _loc1_.addEventListener(Consts.MSG_CHECK_TASK,this.onCheckTaskComplete,false,0,true);
         }
      }
   }
}

