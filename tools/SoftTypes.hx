package;

import haxe.io.Bytes;

/** 软件 canvas 的共享形状定义（typedef 集中一个模块，见 SoftCanvasContext.hx 类头）。 */
typedef ColorSample = {
	r:Int,
	g:Int,
	b:Int,
	a:Int
};

/** 软件面（图案/drawImage 的采样源）：直色 RGBA 字节。 */

typedef SoftSurface = {
	w:Int,
	h:Int,
	rgba:Bytes
};

typedef CtxState = {
	a:Float,
	b:Float,
	c:Float,
	d:Float,
	e:Float,
	f:Float,
	alpha:Float,
	composite:String,
	fillStyle:Dynamic,
	strokeStyle:Dynamic,
	lineWidth:Float,
	lineCap:String,
	lineJoin:String,
	miterLimit:Float,
	font:String,
	clipMask:Bytes
};

typedef SubPath = {
	/** 用户坐标折线（描边几何用），成对存。 */
	usr:Array<Float>,
	/** 设备坐标折线（填充/裁剪用），成对存。 */
	dev:Array<Float>,
	closed:Bool,
	/** 构造时 CTM 快照（描边几何变换用）。 */
	m:{a:Float, b:Float, c:Float, d:Float, e:Float, f:Float}
};

typedef Edge = {
	x1:Float,
	y1:Float,
	x2:Float,
	y2:Float,
	dir:Int
};

typedef Mat6 = {
	a:Float,
	b:Float,
	c:Float,
	d:Float,
	e:Float,
	f:Float
};
