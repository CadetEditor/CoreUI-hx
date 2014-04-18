package core.ui.util;

import flash.errors.Error;
import flash.display.Sprite;
import flash.geom.Rectangle;

class Scale9GridUtil
{
	public static function setScale9Grid(skin : Sprite, grid : Rectangle) : Void
	{
		while (skin.scale9Grid == null) {
			try {
				skin.scale9Grid = grid;
            } catch (e : Error){  
				//trace("setScale9Grid "+e.errorID+" "+e.message);  
            }
        }
    }

    public function new()
    {
    }
}