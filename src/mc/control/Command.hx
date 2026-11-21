package mc.control;

import openfl.errors.Error;
import openfl.events.EventDispatcher;

/**
 * mc.control.Command —— Command.as 逐句对应（issue #19 Master2 闭包顺手译）。
 * 命令单例注册表：各 *Command 惰性建（MainCommand 等为牧场片 stub，真身
 * 待译——#pasture）。
 */
@:keep
class Command extends EventDispatcher {
	// Command.as:8
	private static var instance:Command;

	// Command.as:10-18（惰性命令字段）
	private var _tinCmd:mc.control.TinItemCommand = null;
	private var _diyCmd:mc.control.DiyItemCommand = null;
	private var _taskCommand:mc.control.TaskCommand = null;
	private var _mainCommand:mc.control.MainCommand;
	private var _toolCommand:mc.control.ToolCommand = null;
	private var _farmCommand:mc.control.FarmCommand;

	public function new() {
		super();
		if (instance != null) {
			throw new Error("实例化单例类出错-Command");
		}
	}

	// Command.as:27-34
	public static function getInstance():Command {
		if (instance == null) {
			instance = new Command();
		}
		return instance;
	}

	// Command.as:36-43
	public var toolCommand(get, never):mc.control.ToolCommand;

	private function get_toolCommand():mc.control.ToolCommand {
		if (this._toolCommand == null) {
			this._toolCommand = new mc.control.ToolCommand();
		}
		return this._toolCommand;
	}

	// Command.as:45-52
	public var taskCommand(get, never):mc.control.TaskCommand;

	private function get_taskCommand():mc.control.TaskCommand {
		if (this._taskCommand == null) {
			this._taskCommand = new mc.control.TaskCommand();
		}
		return this._taskCommand;
	}

	// Command.as:54-61
	public var mainCommand(get, never):mc.control.MainCommand;

	private function get_mainCommand():mc.control.MainCommand {
		if (this._mainCommand == null) {
			this._mainCommand = new mc.control.MainCommand();
		}
		return this._mainCommand;
	}

	// Command.as:63-70
	public var farmCommand(get, never):mc.control.FarmCommand;

	private function get_farmCommand():mc.control.FarmCommand {
		if (this._farmCommand == null) {
			this._farmCommand = new mc.control.FarmCommand();
		}
		return this._farmCommand;
	}

	// Command.as:72-79
	public var diyCommand(get, never):mc.control.DiyItemCommand;

	private function get_diyCommand():mc.control.DiyItemCommand {
		if (this._diyCmd == null) {
			this._diyCmd = new mc.control.DiyItemCommand();
		}
		return this._diyCmd;
	}

	// Command.as:81-88
	public var tinCommand(get, never):mc.control.TinItemCommand;

	private function get_tinCommand():mc.control.TinItemCommand {
		if (this._tinCmd == null) {
			this._tinCmd = new mc.control.TinItemCommand();
		}
		return this._tinCmd;
	}
}
